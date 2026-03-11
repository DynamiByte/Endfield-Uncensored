const std = @import("std");
const windows = std.os.windows;

const HANDLE = windows.HANDLE;
const HMODULE = windows.HMODULE;
const BOOL = windows.BOOL;
const DWORD = windows.DWORD;
const LPVOID = windows.LPVOID;
const SIZE_T = windows.SIZE_T;
const INVALID_HANDLE_VALUE = windows.INVALID_HANDLE_VALUE;

const TARGET_EXE = "Endfield.exe";
const DLL_NAME = "EFU.dll";

const MAX_PATH = 260;

const PROCESS_CREATE_THREAD: DWORD = 0x0002;
const PROCESS_QUERY_INFORMATION: DWORD = 0x0400;
const PROCESS_QUERY_LIMITED_INFORMATION: DWORD = 0x1000;
const PROCESS_VM_OPERATION: DWORD = 0x0008;
const PROCESS_VM_WRITE: DWORD = 0x0020;
const PROCESS_VM_READ: DWORD = 0x0010;

const MEM_COMMIT: DWORD = 0x1000;
const MEM_RESERVE: DWORD = 0x2000;
const MEM_RELEASE: DWORD = 0x8000;
const PAGE_READWRITE: DWORD = 0x04;

const TH32CS_SNAPPROCESS: DWORD = 0x00000002;

const INVALID_FILE_ATTRIBUTES: DWORD = 0xFFFFFFFF;

const SECURITY_BUILTIN_DOMAIN_RID: DWORD = 0x00000020;
const DOMAIN_ALIAS_RID_ADMINS: DWORD = 0x00000220;

const SID_IDENTIFIER_AUTHORITY = extern struct {
    Value: [6]u8,
};
const SECURITY_NT_AUTHORITY = SID_IDENTIFIER_AUTHORITY{ .Value = .{ 0, 0, 0, 0, 0, 5 } };

const PROCESSENTRY32A = extern struct {
    dwSize: DWORD = @sizeOf(PROCESSENTRY32A),
    cntUsage: DWORD = 0,
    th32ProcessID: DWORD = 0,
    th32DefaultHeapID: usize = 0,
    th32ModuleID: DWORD = 0,
    cntThreads: DWORD = 0,
    th32ParentProcessID: DWORD = 0,
    pcPriClassBase: i32 = 0,
    dwFlags: DWORD = 0,
    szExeFile: [MAX_PATH]u8 = [_]u8{0} ** MAX_PATH,
};

const STD_OUTPUT_HANDLE: DWORD = @bitCast(@as(i32, -11));

// kernel32 imports
extern "kernel32" fn GetStdHandle(nStdHandle: DWORD) callconv(.winapi) ?HANDLE;
extern "kernel32" fn WriteConsoleA(hConsoleOutput: HANDLE, lpBuffer: [*]const u8, nNumberOfCharsToWrite: DWORD, lpNumberOfCharsWritten: ?*DWORD, lpReserved: ?*anyopaque) callconv(.winapi) BOOL;
extern "kernel32" fn GetModuleHandleA(lpModuleName: ?[*:0]const u8) callconv(.winapi) ?HMODULE;
extern "kernel32" fn GetModuleFileNameA(hModule: ?HMODULE, lpFilename: [*]u8, nSize: DWORD) callconv(.winapi) DWORD;
extern "kernel32" fn GetProcAddress(hModule: HMODULE, lpProcName: [*:0]const u8) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn GetFileAttributesA(lpFileName: [*:0]const u8) callconv(.winapi) DWORD;
extern "kernel32" fn Sleep(dwMilliseconds: DWORD) callconv(.winapi) void;
extern "kernel32" fn CloseHandle(hObject: HANDLE) callconv(.winapi) BOOL;
extern "kernel32" fn OpenProcess(dwDesiredAccess: DWORD, bInheritHandle: BOOL, dwProcessId: DWORD) callconv(.winapi) ?HANDLE;
extern "kernel32" fn CreateToolhelp32Snapshot(dwFlags: DWORD, th32ProcessID: DWORD) callconv(.winapi) HANDLE;
extern "kernel32" fn Process32First(hSnapshot: HANDLE, lppe: *PROCESSENTRY32A) callconv(.winapi) BOOL;
extern "kernel32" fn Process32Next(hSnapshot: HANDLE, lppe: *PROCESSENTRY32A) callconv(.winapi) BOOL;
extern "kernel32" fn VirtualAllocEx(hProcess: HANDLE, lpAddress: ?LPVOID, dwSize: SIZE_T, flAllocationType: DWORD, flProtect: DWORD) callconv(.winapi) ?LPVOID;
extern "kernel32" fn VirtualFreeEx(hProcess: HANDLE, lpAddress: LPVOID, dwSize: SIZE_T, dwFreeType: DWORD) callconv(.winapi) BOOL;
extern "kernel32" fn WriteProcessMemory(hProcess: HANDLE, lpBaseAddress: LPVOID, lpBuffer: [*]const u8, nSize: SIZE_T, lpNumberOfBytesWritten: ?*SIZE_T) callconv(.winapi) BOOL;
extern "kernel32" fn CreateRemoteThread(hProcess: HANDLE, lpThreadAttributes: ?*anyopaque, dwStackSize: SIZE_T, lpStartAddress: ?*anyopaque, lpParameter: ?LPVOID, dwCreationFlags: DWORD, lpThreadId: ?*DWORD) callconv(.winapi) ?HANDLE;
extern "kernel32" fn WaitForSingleObject(hHandle: HANDLE, dwMilliseconds: DWORD) callconv(.winapi) DWORD;
extern "kernel32" fn QueryFullProcessImageNameA(hProcess: HANDLE, dwFlags: DWORD, lpExeName: [*]u8, lpdwSize: *DWORD) callconv(.winapi) BOOL;

// advapi32 imports
extern "advapi32" fn AllocateAndInitializeSid(
    pIdentifierAuthority: *const SID_IDENTIFIER_AUTHORITY,
    nSubAuthorityCount: u8,
    nSubAuthority0: DWORD,
    nSubAuthority1: DWORD,
    nSubAuthority2: DWORD,
    nSubAuthority3: DWORD,
    nSubAuthority4: DWORD,
    nSubAuthority5: DWORD,
    nSubAuthority6: DWORD,
    nSubAuthority7: DWORD,
    pSid: *?*anyopaque,
) callconv(.winapi) BOOL;
extern "advapi32" fn CheckTokenMembership(TokenHandle: ?HANDLE, SidToCheck: ?*anyopaque, IsMember: *BOOL) callconv(.winapi) BOOL;
extern "advapi32" fn FreeSid(pSid: ?*anyopaque) callconv(.winapi) ?*anyopaque;

fn writeConsole(msg: []const u8) void {
    const handle = GetStdHandle(STD_OUTPUT_HANDLE) orelse return;
    _ = WriteConsoleA(handle, msg.ptr, @intCast(msg.len), null, null);
}

fn print(comptime fmt: []const u8, args: anytype) void {
    var buf: [512]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, fmt, args) catch return;
    writeConsole(msg);
}

fn isAdmin() bool {
    var sid: ?*anyopaque = null;
    var authority = SECURITY_NT_AUTHORITY;
    if (AllocateAndInitializeSid(&authority, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, &sid) == 0) {
        return false;
    }
    defer _ = FreeSid(sid);
    var is_member: BOOL = 0;
    _ = CheckTokenMembership(null, sid, &is_member);
    return is_member != 0;
}

fn findProcess(name: [*:0]const u8) DWORD {
    const snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE) return 0;
    defer _ = CloseHandle(snapshot);

    var entry = PROCESSENTRY32A{};
    entry.dwSize = @sizeOf(PROCESSENTRY32A);

    if (Process32First(snapshot, &entry) == 0) return 0;

    while (true) {
        const exe_name = std.mem.sliceTo(&entry.szExeFile, 0);
        if (std.ascii.eqlIgnoreCase(exe_name, std.mem.sliceTo(name, 0))) {
            return entry.th32ProcessID;
        }
        if (Process32Next(snapshot, &entry) == 0) break;
    }
    return 0;
}

fn getProcessPath(pid: DWORD, buf: []u8) ?[]const u8 {
    const proc = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, 0, pid) orelse return null;
    defer _ = CloseHandle(proc);
    var size: DWORD = @intCast(buf.len);
    if (QueryFullProcessImageNameA(proc, 0, buf.ptr, &size) != 0) {
        return buf[0..size];
    }
    return null;
}

fn inject(pid: DWORD, dll_path: [*:0]const u8) bool {
    const rights: DWORD = PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ;
    const proc = OpenProcess(rights, 0, pid) orelse return false;
    defer _ = CloseHandle(proc);

    const path_len = std.mem.len(dll_path) + 1;
    const remote_mem = VirtualAllocEx(proc, null, path_len, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE) orelse return false;

    _ = WriteProcessMemory(proc, remote_mem, dll_path, path_len, null);

    const kernel32 = GetModuleHandleA("kernel32.dll") orelse {
        _ = VirtualFreeEx(proc, remote_mem, 0, MEM_RELEASE);
        return false;
    };
    const load_library_addr = GetProcAddress(kernel32, "LoadLibraryA") orelse {
        _ = VirtualFreeEx(proc, remote_mem, 0, MEM_RELEASE);
        return false;
    };

    const thread = CreateRemoteThread(proc, null, 0, load_library_addr, remote_mem, 0, null) orelse {
        _ = VirtualFreeEx(proc, remote_mem, 0, MEM_RELEASE);
        return false;
    };
    _ = WaitForSingleObject(thread, 5000);
    _ = CloseHandle(thread);
    _ = VirtualFreeEx(proc, remote_mem, 0, MEM_RELEASE);
    return true;
}

fn getExeDir(buf: []u8) ?[]const u8 {
    const len = GetModuleFileNameA(null, buf.ptr, @intCast(buf.len));
    if (len == 0) return null;
    const exe_slice = buf[0..len];
    const dir_end = std.mem.lastIndexOfScalar(u8, exe_slice, '\\') orelse return null;
    return exe_slice[0 .. dir_end + 1];
}

fn buildDllPath(dir: []const u8, out: []u8) [*:0]const u8 {
    const dll_name = DLL_NAME;
    @memcpy(out[0..dir.len], dir);
    @memcpy(out[dir.len .. dir.len + dll_name.len], dll_name);
    out[dir.len + dll_name.len] = 0;
    return @ptrCast(out[0 .. dir.len + dll_name.len :0]);
}

fn fileExists(path: [*:0]const u8) bool {
    return GetFileAttributesA(path) != INVALID_FILE_ATTRIBUTES;
}

pub fn main() void {
    print("\n[EFU Loader]\n\n", .{});


    // Build DLL path relative to executable
    var path_buf: [MAX_PATH]u8 = undefined;
    const dir = getExeDir(&path_buf) orelse {
        print("Error: Could not determine executable directory.\n", .{});
        Sleep(3000);
        return;
    };

    var dll_path_buf: [MAX_PATH]u8 = undefined;
    const dll_path = buildDllPath(dir, &dll_path_buf);

    // Check that EFU.dll exists alongside the exe
    if (!fileExists(dll_path)) {
        print("Error: " ++ DLL_NAME ++ " not found.\n", .{});
        print("Place " ++ DLL_NAME ++ " in the same folder as EFULoader.exe.\n", .{});
        Sleep(5000);
        return;
    }

    print("Ready.\nWaiting for " ++ TARGET_EXE ++ "...\n\n", .{});

    var pid: DWORD = 0;
    while (pid == 0) {
        pid = findProcess(TARGET_EXE);
        Sleep(100);
    }

    print("Process found (PID: {d})\n", .{pid});

    var proc_path_buf: [MAX_PATH]u8 = undefined;
    if (getProcessPath(pid, &proc_path_buf)) |path| {
        print("Process path: {s}\n", .{path});
    } else {
        print("Warning: Could not get process path\n", .{});
    }

    Sleep(10);

    if (inject(pid, dll_path)) {
        print("Injection successful.\n\n", .{});
    } else {
        print("Injection failed.\n", .{});
        print("Maybe you didn't run as admin?\n\n", .{});
    }

    print("Closing in 5 seconds...\n", .{});
    Sleep(5000);
}
