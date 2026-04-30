// Game discovery, launch, and injection helpers
const std = @import("std");
const strings = @import("strings.zig");

pub const c = @import("win32.zig");

pub const target_exe_name = "Endfield.exe";
pub const temp_dll_name_prefix = "EFU-";
pub const game_dx11_arg = "-force-d3d11";

pub const TempDllError = std.mem.Allocator.Error || error{
    TempPathUnavailable,
    TempFileCreateFailed,
    TempFileWriteFailed,
};

pub const InjectError = error{
    InvalidPid,
    BadDllPath,
    OpenProcessFailed,
    AllocateRemoteMemoryFailed,
    WriteRemoteMemoryFailed,
    Kernel32NotFound,
    LoadLibraryNotFound,
    CreateRemoteThreadFailed,
    RemoteThreadWaitFailed,
    RemoteThreadWaitTimedOut,
    GetRemoteThreadExitCodeFailed,
    LoadLibraryRemoteFailed,
};

pub const LaunchError = error{
    ExecutableNotFound,
    AccessDenied,
    InvalidExecutablePath,
    CreateProcessFailed,
};

const process_rights =
    c.PROCESS_CREATE_THREAD |
    c.PROCESS_QUERY_INFORMATION |
    c.PROCESS_VM_OPERATION |
    c.PROCESS_VM_WRITE |
    c.PROCESS_VM_READ;

const max_path_bytes = std.Io.Dir.max_path_bytes;
const file_attribute_directory: c.DWORD = 0x10;

pub fn describeTempDllError(err: TempDllError) []const u8 {
    return strings.describeTempDllError(err);
}

pub fn describeInjectError(err: InjectError) []const u8 {
    return strings.describeInjectError(err);
}

pub fn injectErrorSuggestsElevation(err: InjectError) bool {
    return switch (err) {
        error.OpenProcessFailed,
        error.AllocateRemoteMemoryFailed,
        error.WriteRemoteMemoryFailed,
        error.CreateRemoteThreadFailed,
        => true,
        else => false,
    };
}

pub fn describeLaunchError(err: LaunchError) []const u8 {
    return strings.describeLaunchError(err);
}

fn classifyCreateProcessError() LaunchError {
    return switch (c.GetLastError()) {
        c.ERROR_FILE_NOT_FOUND, c.ERROR_PATH_NOT_FOUND => error.ExecutableNotFound,
        c.ERROR_ACCESS_DENIED => error.AccessDenied,
        c.ERROR_INVALID_NAME, c.ERROR_INVALID_PARAMETER => error.InvalidExecutablePath,
        else => error.CreateProcessFailed,
    };
}

pub fn createProcessWide(application_name: ?c.LPCWSTR, command_line: ?c.LPWSTR) LaunchError!c.PROCESS_INFORMATION {
    var startup_info: c.STARTUPINFOW = undefined;
    var process_info: c.PROCESS_INFORMATION = undefined;
    @memset(std.mem.asBytes(&startup_info), 0);
    @memset(std.mem.asBytes(&process_info), 0);
    startup_info.cb = @sizeOf(c.STARTUPINFOW);

    if (c.CreateProcessW(
        application_name,
        command_line,
        null,
        null,
        c.FALSE,
        0,
        null,
        null,
        &startup_info,
        &process_info,
    ) == c.FALSE) {
        return classifyCreateProcessError();
    }

    return process_info;
}

pub fn closeProcessInformation(process_info: *const c.PROCESS_INFORMATION) void {
    _ = c.CloseHandle(process_info.hThread);
    _ = c.CloseHandle(process_info.hProcess);
}

// Path discovery
fn pathIsFileWtf8(wtf8_path: []const u8) bool {
    var path_buf: [max_path_bytes]u16 = undefined;
    const path_w = c.wtf8ToWtf16LeZ(wtf8_path, &path_buf) catch return false;
    const attrs = c.GetFileAttributesW(path_w.ptr);
    return attrs != c.INVALID_FILE_ATTRIBUTES and (attrs & file_attribute_directory) == 0;
}

fn eqlAsciiWideIgnoreCase(wide: []const u16, ascii: []const u8) bool {
    if (wide.len != ascii.len) return false;
    for (wide, ascii) |w, a| {
        if (w > 0x7F) return false;
        if (std.ascii.toLower(@as(u8, @intCast(w))) != std.ascii.toLower(a)) return false;
    }
    return true;
}

fn indexOfIgnoreCase(haystack: []const u8, needle: []const u8) ?usize {
    if (needle.len == 0 or haystack.len < needle.len) return null;
    var i: usize = 0;
    while (i + needle.len <= haystack.len) : (i += 1) {
        if (std.ascii.eqlIgnoreCase(haystack[i .. i + needle.len], needle)) return i;
    }
    return null;
}

fn trimRightPathNoise(path: []const u8) []const u8 {
    var end = path.len;
    while (end > 0) : (end -= 1) {
        const ch = path[end - 1];
        if (ch == '\r' or ch == '\n' or std.ascii.isWhitespace(ch) or ch == '"' or ch == '\'') continue;
        break;
    }
    return path[0..end];
}

fn pathExistsWtf8(io: std.Io, wtf8_path: []const u8) bool {
    var file = std.Io.Dir.openFileAbsolute(io, wtf8_path, .{ .allow_directory = false }) catch return false;
    file.close(io);
    return true;
}

fn extractInstallDirFromLine(line: []const u8) ?[]const u8 {
    const endfield_idx = indexOfIgnoreCase(line, "EndField") orelse return null;

    var start: ?usize = null;
    var i: usize = 0;
    while (i + 2 < line.len and i <= endfield_idx) : (i += 1) {
        if (std.ascii.isAlphabetic(line[i]) and line[i + 1] == ':' and (line[i + 2] == '\\' or line[i + 2] == '/')) {
            start = i;
        }
    }

    const path_start = start orelse return null;

    var path_end = trimRightPathNoise(line[path_start..]).len + path_start;
    if (indexOfIgnoreCase(line[path_start..path_end], "EndField_Data")) |data_idx| {
        path_end = path_start + data_idx;
    }

    while (path_end > path_start and (line[path_end - 1] == '\\' or line[path_end - 1] == '/')) : (path_end -= 1) {}
    if (path_end <= path_start) return null;
    return line[path_start..path_end];
}

fn readWholeFileWtf8(io: std.Io, allocator: std.mem.Allocator, wtf8_path: []const u8) !?[]u8 {
    var file = std.Io.Dir.openFileAbsolute(io, wtf8_path, .{ .allow_directory = false }) catch return null;
    defer file.close(io);

    const stat = file.stat(io) catch return null;
    if (stat.kind != .file or stat.size > 32 * 1024 * 1024) return null;

    var file_reader = file.reader(io, &.{});
    return try file_reader.interface.readAlloc(allocator, @intCast(stat.size));
}

fn detectGameExeFromPlayerLog(io: std.Io, environ: std.process.Environ, allocator: std.mem.Allocator) !?[:0]u16 {
    var appdata_buf: [max_path_bytes]u8 = undefined;
    const appdata = c.getEnvironmentVariableWtf8(environ, "APPDATA", &appdata_buf) orelse return null;
    const roaming_parent = std.fs.path.dirname(appdata) orelse return null;

    var player_log_buf: [max_path_bytes]u8 = undefined;
    const player_log = try c.appendNormalizedPath(&player_log_buf, roaming_parent, "LocalLow\\Gryphline\\Endfield\\Player.log");

    const contents = try readWholeFileWtf8(io, allocator, player_log) orelse return null;
    defer allocator.free(contents);

    var lines = std.mem.splitScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        const install_dir = extractInstallDirFromLine(line) orelse continue;
        var exe_buf: [max_path_bytes]u8 = undefined;
        const exe_utf8 = try c.appendNormalizedPath(&exe_buf, install_dir, target_exe_name);

        if (pathExistsWtf8(io, exe_utf8)) {
            return try std.unicode.wtf8ToWtf16LeAllocZ(allocator, exe_utf8);
        }
    }

    return null;
}

fn detectGameExeFromKnownPaths(io: std.Io, allocator: std.mem.Allocator) !?[:0]u16 {
    const fallback_drive_letters = "CDE";
    const fallback_relative_paths = [_][]const u8{
        "Program Files\\GRYPHLINK\\games\\EndField Game\\Endfield.exe",
        "GRYPHLINK\\games\\EndField Game\\Endfield.exe",
    };

    var buf: [max_path_bytes]u8 = undefined;

    for (fallback_drive_letters) |drive| {
        for (fallback_relative_paths) |relative_path| {
            const candidate = std.fmt.bufPrint(&buf, "{c}:\\{s}", .{ drive, relative_path }) catch unreachable;

            if (pathExistsWtf8(io, candidate)) {
                return try std.unicode.wtf8ToWtf16LeAllocZ(allocator, candidate);
            }
        }
    }

    return null;
}

pub fn detectGameExe(environ: std.process.Environ, allocator: std.mem.Allocator) !?[:0]u16 {
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    if (try detectGameExeFromPlayerLog(io, environ, allocator)) |path| return path;
    return try detectGameExeFromKnownPaths(io, allocator);
}

pub fn validateGameExeOverridePath(wtf8_path: []const u8) bool {
    const trimmed = trimRightPathNoise(wtf8_path);
    if (trimmed.len == 0) return false;
    if (!std.ascii.eqlIgnoreCase(std.fs.path.extension(trimmed), ".exe")) return false;
    return pathIsFileWtf8(trimmed);
}

pub fn duplicateGameExePath(allocator: std.mem.Allocator, wtf8_path: []const u8) ![:0]u16 {
    return try std.unicode.wtf8ToWtf16LeAllocZ(allocator, trimRightPathNoise(wtf8_path));
}

pub fn resolveGameExe(game_exe_override_path: ?[]const u8, environ: std.process.Environ, allocator: std.mem.Allocator) !?[:0]u16 {
    if (game_exe_override_path) |path| {
        if (!validateGameExeOverridePath(path)) return null;
        return try duplicateGameExePath(allocator, path);
    }

    return try detectGameExe(environ, allocator);
}

// Injection and launch
pub fn findTargetProcess() u32 {
    const snapshot = c.CreateToolhelp32Snapshot(c.TH32CS_SNAPPROCESS, 0);
    if (snapshot == c.INVALID_HANDLE_VALUE) return 0;
    defer _ = c.CloseHandle(snapshot);

    var entry: c.PROCESSENTRY32W = std.mem.zeroes(c.PROCESSENTRY32W);
    entry.dwSize = @sizeOf(c.PROCESSENTRY32W);

    if (c.Process32FirstW(snapshot, &entry) == c.FALSE) return 0;

    while (true) {
        const exe_name = std.mem.sliceTo(entry.szExeFile[0..], 0);
        if (eqlAsciiWideIgnoreCase(exe_name, target_exe_name)) {
            return entry.th32ProcessID;
        }
        if (c.Process32NextW(snapshot, &entry) == c.FALSE) break;
    }

    return 0;
}

pub fn isProcessAlive(pid: u32) bool {
    if (pid == 0) return false;
    const handle = c.OpenProcess(c.SYNCHRONIZE, c.FALSE, pid) orelse return false;
    defer _ = c.CloseHandle(handle);
    return c.WaitForSingleObject(handle, 0) == c.WAIT_TIMEOUT;
}

fn makeUniqueTempDllName(out_buf: []u8) ![]const u8 {
    return std.fmt.bufPrint(out_buf, "{s}{x}-{x}.dll", .{
        temp_dll_name_prefix,
        c.GetCurrentProcessId(),
        c.GetTickCount64(),
    });
}

pub fn writeEmbeddedDllToTemp(allocator: std.mem.Allocator, dll_bytes: []const u8) TempDllError![]u8 {
    var temp_buf: [c.MAX_PATH]u16 = undefined;
    const temp_len = c.GetTempPathW(temp_buf.len, &temp_buf);
    if (temp_len == 0 or temp_len >= temp_buf.len) return error.TempPathUnavailable;

    var temp_name_buf: [32]u8 = undefined;
    const temp_name = makeUniqueTempDllName(&temp_name_buf) catch return error.TempFileCreateFailed;

    var temp_name_utf16_buf: [32]u16 = undefined;
    const temp_name_utf16 = c.wtf8ToWtf16LeZ(temp_name, &temp_name_utf16_buf) catch return error.TempFileCreateFailed;

    var path_utf16_buf: [c.MAX_PATH + 32]u16 = undefined;
    if (temp_len + temp_name_utf16.len > path_utf16_buf.len) return error.TempFileCreateFailed;
    @memcpy(path_utf16_buf[0..temp_len], temp_buf[0..temp_len]);
    @memcpy(path_utf16_buf[temp_len .. temp_len + temp_name_utf16.len], temp_name_utf16);

    var utf8_path_buf: [max_path_bytes]u8 = undefined;
    const utf8_path = c.wtf16LeToWtf8Slice(path_utf16_buf[0 .. temp_len + temp_name_utf16.len], &utf8_path_buf) catch {
        return error.TempFileCreateFailed;
    };
    const path = try allocator.dupe(u8, utf8_path);
    errdefer allocator.free(path);

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var file = std.Io.Dir.createFileAbsolute(io, path, .{}) catch {
        return error.TempFileCreateFailed;
    };
    defer file.close(io);

    var file_buffer: [4096]u8 = undefined;
    var file_writer = file.writer(io, &file_buffer);
    file_writer.interface.writeAll(dll_bytes) catch {
        return error.TempFileWriteFailed;
    };
    file_writer.interface.flush() catch {
        return error.TempFileWriteFailed;
    };

    return path;
}

pub fn deleteTempDll(allocator: std.mem.Allocator, temp_dll_path: []const u8) void {
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();
    std.Io.Dir.deleteFileAbsolute(io, temp_dll_path) catch {};
}

pub fn injectDll(pid: u32, dll_path: []const u8) InjectError!void {
    if (pid == 0) return error.InvalidPid;

    var wide_path_buf: [max_path_bytes]u16 = undefined;
    const dll_path_w = c.wtf8ToWtf16LeZ(dll_path, &wide_path_buf) catch return error.BadDllPath;

    const process = c.OpenProcess(process_rights, c.FALSE, pid) orelse return error.OpenProcessFailed;
    defer _ = c.CloseHandle(process);

    const path_bytes: usize = (dll_path_w.len + 1) * @sizeOf(u16);
    const remote_mem = c.VirtualAllocEx(process, null, path_bytes, c.MEM_COMMIT | c.MEM_RESERVE, c.PAGE_READWRITE);
    if (remote_mem == null) return error.AllocateRemoteMemoryFailed;
    defer _ = c.VirtualFreeEx(process, remote_mem.?, 0, c.MEM_RELEASE);

    if (c.WriteProcessMemory(process, remote_mem.?, dll_path_w.ptr, path_bytes, null) == c.FALSE) {
        return error.WriteRemoteMemoryFailed;
    }

    const kernel32 = c.GetModuleHandleA("kernel32.dll") orelse return error.Kernel32NotFound;
    const load_library = c.GetProcAddress(kernel32, "LoadLibraryW") orelse return error.LoadLibraryNotFound;

    const thread = c.CreateRemoteThread(
        process,
        null,
        0,
        @ptrCast(load_library),
        remote_mem,
        0,
        null,
    ) orelse return error.CreateRemoteThreadFailed;
    defer _ = c.CloseHandle(thread);

    switch (c.WaitForSingleObject(thread, 5000)) {
        c.WAIT_OBJECT_0 => {},
        c.WAIT_TIMEOUT => return error.RemoteThreadWaitTimedOut,
        else => return error.RemoteThreadWaitFailed,
    }

    var exit_code: c.DWORD = 0;
    if (c.GetExitCodeThread(thread, &exit_code) == c.FALSE) return error.GetRemoteThreadExitCodeFailed;
    if (exit_code == 0 or exit_code == c.STILL_ACTIVE) return error.LoadLibraryRemoteFailed;
}

pub fn launchGameWithArgs(game_exe_path: [:0]const u16, launch_args: ?[]const u8) LaunchError!void {
    var command_line_buf: [max_path_bytes + 64]u8 = undefined;
    var command_line_wide_buf: [max_path_bytes + 64]u16 = undefined;
    const command_line_wide = if (launch_args) |args| blk: {
        var path_utf8_buf: [max_path_bytes]u8 = undefined;
        const path_utf8 = c.wtf16LeToWtf8Slice(game_exe_path, &path_utf8_buf) catch return error.InvalidExecutablePath;
        const command_line = std.fmt.bufPrint(&command_line_buf, "\"{s}\" {s}", .{ path_utf8, args }) catch return error.InvalidExecutablePath;
        break :blk c.wtf8ToWtf16LeZ(command_line, &command_line_wide_buf) catch return error.InvalidExecutablePath;
    } else null;

    const process_info = try createProcessWide(
        game_exe_path.ptr,
        if (command_line_wide) |command_line| command_line.ptr else null,
    );
    closeProcessInformation(&process_info);
}

pub fn launchGame(game_exe_path: [:0]const u16) LaunchError!void {
    return launchGameWithArgs(game_exe_path, null);
}
