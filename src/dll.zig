// Runtime patch DLL
const std = @import("std");
const windows = std.os.windows;

const HMODULE = windows.HMODULE;
const HINSTANCE = windows.HINSTANCE;
const BOOL = windows.BOOL;
const DWORD = windows.DWORD;
const HANDLE = windows.HANDLE;
const HWND = windows.HWND;
const LPVOID = windows.LPVOID;
const SIZE_T = windows.SIZE_T;

const DLL_PROCESS_ATTACH: DWORD = 1;
const MEM_COMMIT: DWORD = 0x00001000;
const MEM_RESERVE: DWORD = 0x00002000;
const PAGE_EXECUTE_READWRITE: DWORD = 0x40;
const VK_MENU: c_int = 0x12;
const VK_F12: c_int = 0x7B;
const VK_LMENU: c_int = 0xA4;
const VK_RMENU: c_int = 0xA5;
const KEY_DOWN_MASK: u16 = 0x8000;
const POLL_MS: DWORD = 25;
const JUMP_SIZE: usize = 12;
const MAX_STOLEN_BYTES: usize = 32;

extern "kernel32" fn GetModuleHandleA(lpModuleName: ?[*:0]const u8) callconv(.winapi) ?HMODULE;
extern "kernel32" fn GetProcAddress(hModule: HMODULE, lpProcName: [*:0]const u8) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn Sleep(dwMilliseconds: DWORD) callconv(.winapi) void;
extern "kernel32" fn GetCurrentProcess() callconv(.winapi) HANDLE;
extern "kernel32" fn GetCurrentProcessId() callconv(.winapi) DWORD;
extern "kernel32" fn FlushInstructionCache(hProcess: HANDLE, lpBaseAddress: ?*const anyopaque, dwSize: SIZE_T) callconv(.winapi) BOOL;
extern "kernel32" fn VirtualAlloc(lpAddress: ?LPVOID, dwSize: SIZE_T, flAllocationType: DWORD, flProtect: DWORD) callconv(.winapi) ?LPVOID;
extern "kernel32" fn VirtualProtect(lpAddress: LPVOID, dwSize: SIZE_T, flNewProtect: DWORD, lpflOldProtect: *DWORD) callconv(.winapi) BOOL;
extern "kernel32" fn CreateThread(
    lpThreadAttributes: ?*anyopaque,
    dwStackSize: SIZE_T,
    lpStartAddress: *const fn (?*anyopaque) callconv(.winapi) DWORD,
    lpParameter: ?*anyopaque,
    dwCreationFlags: DWORD,
    lpThreadId: ?*DWORD,
) callconv(.winapi) ?HANDLE;
extern "kernel32" fn DisableThreadLibraryCalls(hLibModule: HMODULE) callconv(.winapi) BOOL;
extern "user32" fn GetAsyncKeyState(vKey: c_int) callconv(.winapi) c_short;
extern "user32" fn GetForegroundWindow() callconv(.winapi) ?HWND;
extern "user32" fn GetWindowThreadProcessId(hwnd: HWND, lpdw_process_id: ?*DWORD) callconv(.winapi) DWORD;
extern "user32" fn IsIconic(hwnd: HWND) callconv(.winapi) BOOL;

const Il2CppDomainGetFn = *const fn () callconv(.c) ?*anyopaque;
const Il2CppDomainAssemblyOpenFn = *const fn (?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque;
const Il2CppAssemblyGetImageFn = *const fn (?*anyopaque) callconv(.c) ?*anyopaque;
const Il2CppClassFromNameFn = *const fn (?*anyopaque, [*:0]const u8, [*:0]const u8) callconv(.c) ?*anyopaque;
const Il2CppClassGetMethodFromNameFn = *const fn (?*anyopaque, [*:0]const u8, c_int) callconv(.c) ?*Il2CppMethodInfo;
const InstanceVoidMethod = *const fn (?*anyopaque, ?*Il2CppMethodInfo) callconv(.c) void;

const Il2CppMethodInfo = extern struct {
    address: usize,
};

const PatchTargets = struct {
    evaluate: *Il2CppMethodInfo,
    force_clear: *Il2CppMethodInfo,
};

const Hook = struct {
    target: ?*u8 = null,
    trampoline: ?LPVOID = null,
    original: [MAX_STOLEN_BYTES]u8 = [_]u8{0} ** MAX_STOLEN_BYTES,
    len: usize = 0,
};

var g_enabled = true;
var g_force_clear_method: ?*Il2CppMethodInfo = null;
var g_camera_hook = Hook{};

fn winBool(value: bool) BOOL {
    return switch (@typeInfo(BOOL)) {
        .int => if (value) 1 else 0,
        .bool => value,
        .@"enum" => if (value) @enumFromInt(1) else @enumFromInt(0),
        else => @compileError("Unsupported Windows BOOL representation"),
    };
}

fn keyDown(vkey: c_int) bool {
    return (@as(u16, @bitCast(GetAsyncKeyState(vkey))) & KEY_DOWN_MASK) != 0;
}

fn altDown() bool {
    return keyDown(VK_MENU) or keyDown(VK_LMENU) or keyDown(VK_RMENU);
}

fn hotkeyWindowActive() bool {
    const window = GetForegroundWindow() orelse return false;
    if (IsIconic(window) != winBool(false)) return false;

    var process_id: DWORD = 0;
    _ = GetWindowThreadProcessId(window, &process_id);
    return process_id == GetCurrentProcessId();
}

fn waitForModule(module_name: [*:0]const u8) HMODULE {
    var handle: ?HMODULE = null;
    while (handle == null) {
        handle = GetModuleHandleA(module_name);
        Sleep(200);
    }
    Sleep(2000);
    return handle.?;
}

fn readU32(bytes: [*]const u8, index: usize) u32 {
    return @as(u32, bytes[index]) |
        (@as(u32, bytes[index + 1]) << 8) |
        (@as(u32, bytes[index + 2]) << 16) |
        (@as(u32, bytes[index + 3]) << 24);
}

fn readI32(bytes: [*]const u8, index: usize) i32 {
    return @bitCast(readU32(bytes, index));
}

fn jumpOffset(base: usize, instruction_len: usize, offset: i32) usize {
    return base + instruction_len +% @as(usize, @bitCast(@as(isize, offset)));
}

fn resolveThunk(target: *u8) *u8 {
    const bytes: [*]const u8 = @ptrCast(target);
    if (bytes[0] == 0xE9) return @ptrFromInt(jumpOffset(@intFromPtr(target), 5, readI32(bytes, 1)));
    if (bytes[0] == 0xEB) return @ptrFromInt(jumpOffset(@intFromPtr(target), 2, @as(i8, @bitCast(bytes[1]))));
    if (bytes[0] == 0xFF and bytes[1] == 0x25) {
        const address_ptr: *align(1) const usize = @ptrFromInt(jumpOffset(@intFromPtr(target), 6, readI32(bytes, 2)));
        return @ptrFromInt(address_ptr.*);
    }
    return target;
}

fn hasModRm(opcode: u8) bool {
    return switch (opcode) {
        0x01, 0x03, 0x21, 0x23, 0x29, 0x2B, 0x31, 0x33, 0x39, 0x3B, 0x63, 0x69, 0x6B, 0x80, 0x81, 0x83, 0x85, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8D, 0xC6, 0xC7 => true,
        else => false,
    };
}

fn modRmLen(bytes: [*]const u8, index: usize) ?usize {
    const modrm = bytes[index];
    const mode = modrm >> 6;
    const rm = modrm & 0x07;
    var len: usize = 1;

    if (mode != 3 and rm == 4) {
        const sib = bytes[index + len];
        len += 1;
        if (mode == 0 and (sib & 0x07) == 5) return null;
    } else if (mode == 0 and rm == 5) {
        return null;
    }

    if (mode == 1) len += 1;
    if (mode == 2) len += 4;
    return len;
}

fn instructionLen(bytes: [*]const u8, start: usize) ?usize {
    var index = start;
    var rex_w = false;

    while (true) {
        const byte = bytes[index];
        switch (byte) {
            0x40...0x4F => {
                rex_w = (byte & 0x08) != 0;
                index += 1;
            },
            0x26, 0x2E, 0x36, 0x3E, 0x64, 0x65, 0x66, 0x67, 0xF2, 0xF3 => index += 1,
            else => break,
        }
    }

    const opcode = bytes[index];
    var len: usize = index - start + 1;

    switch (opcode) {
        0x50...0x5F, 0x90 => return len,
        0x68 => return len + 4,
        0x6A => return len + 1,
        0xB8...0xBF => return len + if (rex_w) @as(usize, 8) else 4,
        0xE8, 0xE9, 0xEB => return null,
        0x0F => {
            const next = bytes[index + 1];
            len += 1;
            switch (next) {
                0x1F => return len + (modRmLen(bytes, index + 2) orelse return null),
                0x80...0x8F => return null,
                else => return null,
            }
        },
        else => {},
    }

    if (!hasModRm(opcode)) return null;

    len += modRmLen(bytes, index + 1) orelse return null;
    switch (opcode) {
        0x69, 0x81, 0xC7 => len += 4,
        0x6B, 0x80, 0x83, 0xC6 => len += 1,
        else => {},
    }
    return len;
}

fn patchLen(target: *const u8) ?usize {
    const bytes: [*]const u8 = @ptrCast(target);
    var len: usize = 0;
    while (len < JUMP_SIZE) {
        len += instructionLen(bytes, len) orelse return null;
        if (len > MAX_STOLEN_BYTES) return null;
    }
    return len;
}

fn writeAbsoluteJump(dst: []u8, address: usize) void {
    dst[0] = 0x48;
    dst[1] = 0xB8;
    const value: u64 = @intCast(address);
    inline for (0..8) |i| {
        dst[2 + i] = @intCast((value >> (i * 8)) & 0xFF);
    }
    dst[10] = 0xFF;
    dst[11] = 0xE0;
}

fn installJumpHook(hook: *Hook, target: *u8, replacement_addr: usize) bool {
    const resolved_target = resolveThunk(target);
    const len = patchLen(resolved_target) orelse return false;
    const trampoline = VirtualAlloc(null, len + JUMP_SIZE, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE) orelse return false;
    const original_bytes = @as([*]const u8, @ptrCast(resolved_target))[0..len];
    const trampoline_bytes = @as([*]u8, @ptrCast(trampoline))[0 .. len + JUMP_SIZE];

    @memcpy(hook.original[0..len], original_bytes);
    @memcpy(trampoline_bytes[0..len], original_bytes);
    writeAbsoluteJump(trampoline_bytes[len .. len + JUMP_SIZE], @intFromPtr(resolved_target) + len);

    hook.target = resolved_target;
    hook.trampoline = trampoline;
    hook.len = len;

    var old_protect: DWORD = 0;
    if (VirtualProtect(resolved_target, len, PAGE_EXECUTE_READWRITE, &old_protect) == winBool(false)) return false;

    const target_bytes = @as([*]u8, @ptrCast(resolved_target))[0..len];
    writeAbsoluteJump(target_bytes[0..JUMP_SIZE], replacement_addr);
    if (len > JUMP_SIZE) @memset(target_bytes[JUMP_SIZE..len], 0x90);
    _ = FlushInstructionCache(GetCurrentProcess(), resolved_target, len);
    _ = VirtualProtect(resolved_target, len, old_protect, &old_protect);
    return true;
}

fn resolvePatchTargets() ?PatchTargets {
    const game_assembly = waitForModule("GameAssembly.dll");

    const domain_get: Il2CppDomainGetFn = @ptrCast(GetProcAddress(game_assembly, "il2cpp_domain_get") orelse return null);
    const assembly_open: Il2CppDomainAssemblyOpenFn = @ptrCast(GetProcAddress(game_assembly, "il2cpp_domain_assembly_open") orelse return null);
    const assembly_get_image: Il2CppAssemblyGetImageFn = @ptrCast(GetProcAddress(game_assembly, "il2cpp_assembly_get_image") orelse return null);
    const class_from_name: Il2CppClassFromNameFn = @ptrCast(GetProcAddress(game_assembly, "il2cpp_class_from_name") orelse return null);
    const method_from_name: Il2CppClassGetMethodFromNameFn = @ptrCast(GetProcAddress(game_assembly, "il2cpp_class_get_method_from_name") orelse return null);

    const domain = domain_get() orelse return null;
    const assembly = assembly_open(domain, "Gameplay.Beyond.dll") orelse return null;
    const image = assembly_get_image(assembly) orelse return null;
    const camera_class = class_from_name(image, "Beyond.Gameplay.View", "CameraMono") orelse return null;
    const evaluate = method_from_name(camera_class, "EvaluateAllTouchedEntities", 0) orelse return null;
    const force_clear = method_from_name(camera_class, "ForceClearDither", 0) orelse return null;

    if (evaluate.address == 0 or force_clear.address == 0) return null;
    return .{ .evaluate = evaluate, .force_clear = force_clear };
}

fn cameraEvaluateHook(instance: ?*anyopaque, method_info: ?*Il2CppMethodInfo) callconv(.c) void {
    const trampoline = g_camera_hook.trampoline orelse return;
    const original: InstanceVoidMethod = @ptrCast(trampoline);
    original(instance, method_info);

    if (!@atomicLoad(bool, &g_enabled, .acquire)) return;
    const method = g_force_clear_method orelse return;
    const force_clear: InstanceVoidMethod = @ptrFromInt(method.address);
    force_clear(instance, method);
}

fn patchThread(_: ?*anyopaque) callconv(.winapi) DWORD {
    const targets = resolvePatchTargets() orelse return 0;
    g_force_clear_method = targets.force_clear;
    if (!installJumpHook(&g_camera_hook, @ptrFromInt(targets.evaluate.address), @intFromPtr(&cameraEvaluateHook))) return 0;

    var was_combo_down = altDown() and keyDown(VK_F12);
    while (true) {
        Sleep(POLL_MS);
        const combo_down = altDown() and keyDown(VK_F12);
        if (hotkeyWindowActive() and combo_down and !was_combo_down) {
            const enabled = @atomicLoad(bool, &g_enabled, .acquire);
            @atomicStore(bool, &g_enabled, !enabled, .release);
        }
        was_combo_down = combo_down;
    }

    return 0;
}

pub export fn DllMain(hInstance: HINSTANCE, ul_reason_for_call: DWORD, _: ?LPVOID) callconv(.winapi) BOOL {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        _ = DisableThreadLibraryCalls(@ptrCast(hInstance));
        _ = CreateThread(null, 0, &patchThread, null, 0, null);
    }
    return winBool(true);
}
