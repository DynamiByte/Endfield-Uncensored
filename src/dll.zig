// Runtime patch DLL
const std = @import("std");
const windows = std.os.windows;

const HMODULE = windows.HMODULE;
const HINSTANCE = windows.HINSTANCE;
const BOOL = windows.BOOL;
const DWORD = windows.DWORD;
const HANDLE = windows.HANDLE;
const LPVOID = windows.LPVOID;
const SIZE_T = windows.SIZE_T;

const DLL_PROCESS_ATTACH: DWORD = 1;
const PAGE_EXECUTE_READWRITE: DWORD = 0x40;

extern "kernel32" fn GetModuleHandleA(lpModuleName: ?[*:0]const u8) callconv(.winapi) ?HMODULE;
extern "kernel32" fn GetProcAddress(hModule: HMODULE, lpProcName: [*:0]const u8) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn Sleep(dwMilliseconds: DWORD) callconv(.winapi) void;
extern "kernel32" fn VirtualProtect(
    lpAddress: LPVOID,
    dwSize: SIZE_T,
    flNewProtect: DWORD,
    lpflOldProtect: *DWORD,
) callconv(.winapi) BOOL;
extern "kernel32" fn CreateThread(
    lpThreadAttributes: ?*anyopaque,
    dwStackSize: SIZE_T,
    lpStartAddress: *const fn (?*anyopaque) callconv(.winapi) DWORD,
    lpParameter: ?*anyopaque,
    dwCreationFlags: DWORD,
    lpThreadId: ?*DWORD,
) callconv(.winapi) ?HANDLE;
extern "kernel32" fn DisableThreadLibraryCalls(hLibModule: HMODULE) callconv(.winapi) BOOL;

const Il2CppDomainGetFn = *const fn () callconv(.c) ?*anyopaque;
const Il2CppDomainAssemblyOpenFn = *const fn (?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque;
const Il2CppAssemblyGetImageFn = *const fn (?*anyopaque) callconv(.c) ?*anyopaque;
const Il2CppClassFromNameFn = *const fn (?*anyopaque, [*:0]const u8, [*:0]const u8) callconv(.c) ?*anyopaque;
const Il2CppClassGetMethodFromNameFn = *const fn (?*anyopaque, [*:0]const u8, c_int) callconv(.c) ?*Il2CppMethodInfo;

const Il2CppMethodInfo = extern struct {
    address: usize,
};

fn winBool(value: bool) BOOL {
    return switch (@typeInfo(BOOL)) {
        .int => if (value) 1 else 0,
        .bool => value,
        .@"enum" => if (value) @enumFromInt(1) else @enumFromInt(0),
        else => @compileError("Unsupported Windows BOOL representation"),
    };
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

// Patch game
fn patchCameraCensorship(_: ?*anyopaque) callconv(.winapi) DWORD {
    const game_assembly = waitForModule("GameAssembly.dll");

    const il2cpp_domain_get: Il2CppDomainGetFn = @ptrCast(
        GetProcAddress(game_assembly, "il2cpp_domain_get") orelse return 0,
    );
    const il2cpp_domain_assembly_open: Il2CppDomainAssemblyOpenFn = @ptrCast(
        GetProcAddress(game_assembly, "il2cpp_domain_assembly_open") orelse return 0,
    );
    const il2cpp_assembly_get_image: Il2CppAssemblyGetImageFn = @ptrCast(
        GetProcAddress(game_assembly, "il2cpp_assembly_get_image") orelse return 0,
    );
    const il2cpp_class_from_name: Il2CppClassFromNameFn = @ptrCast(
        GetProcAddress(game_assembly, "il2cpp_class_from_name") orelse return 0,
    );
    const il2cpp_class_get_method_from_name: Il2CppClassGetMethodFromNameFn = @ptrCast(
        GetProcAddress(game_assembly, "il2cpp_class_get_method_from_name") orelse return 0,
    );

    const domain = il2cpp_domain_get() orelse return 0;
    const assembly = il2cpp_domain_assembly_open(domain, "Gameplay.Beyond.dll") orelse return 0;
    const image = il2cpp_assembly_get_image(assembly) orelse return 0;
    const camera_mono_class = il2cpp_class_from_name(image, "Beyond.Gameplay.View", "CameraMono") orelse return 0;
    const method = il2cpp_class_get_method_from_name(camera_mono_class, "EvaluateAllTouchedEntities", 0) orelse return 0;

    var old_protect: DWORD = 0;
    _ = VirtualProtect(@ptrFromInt(method.address), 1, PAGE_EXECUTE_READWRITE, &old_protect);
    const patch_ptr: *u8 = @ptrFromInt(method.address);
    patch_ptr.* = 0xC3;
    _ = VirtualProtect(@ptrFromInt(method.address), 1, old_protect, &old_protect);

    return 0;
}

pub export fn DllMain(hInstance: HINSTANCE, ul_reason_for_call: DWORD, _: ?LPVOID) callconv(.winapi) BOOL {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        _ = DisableThreadLibraryCalls(@ptrCast(hInstance));
        _ = CreateThread(null, 0, &patchCameraCensorship, null, 0, null);
    }
    return winBool(true);
}
