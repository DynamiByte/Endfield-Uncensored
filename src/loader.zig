// Game discovery, launch, and injection helpers
const std = @import("std");
const strings = @import("strings.zig");

pub const c = @import("win32.zig");

pub const target_exe_name = "Endfield.exe";
const target_data_dir_name = "Endfield_Data";
pub const temp_dll_name_prefix = "EFU-";
pub const game_dx11_arg = "-force-d3d11";

// Public error surface
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

pub const GameScan = struct {
    registry: bool = true,
    player_log: bool = true,
    known_paths: bool = true,
};

// Error descriptions and classification
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

// Process handle helpers
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

fn indexOfAsciiWideIgnoreCase(haystack: []const u16, needle: []const u8) ?usize {
    if (needle.len == 0 or haystack.len < needle.len) return null;

    var i: usize = 0;
    while (i + needle.len <= haystack.len) : (i += 1) {
        var matched = true;
        for (needle, 0..) |needle_ch, j| {
            const hay_ch = haystack[i + j];
            if (hay_ch > 0x7F or std.ascii.toLower(@as(u8, @intCast(hay_ch))) != std.ascii.toLower(needle_ch)) {
                matched = false;
                break;
            }
        }
        if (matched) return i;
    }

    return null;
}

fn isAsciiWideAlphabetic(ch: u16) bool {
    return (ch >= 'A' and ch <= 'Z') or (ch >= 'a' and ch <= 'z');
}

fn isAsciiWidePathSeparator(ch: u16) bool {
    return ch == '\\' or ch == '/';
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

fn fileModifiedTimeWtf8(wtf8_path: []const u8) u64 {
    var path_buf: [max_path_bytes]u16 = undefined;
    const path_w = c.wtf8ToWtf16LeZ(wtf8_path, &path_buf) catch return 0;

    var data: c.WIN32_FILE_ATTRIBUTE_DATA = undefined;
    if (c.GetFileAttributesExW(path_w.ptr, c.GetFileExInfoStandard, &data) == c.FALSE) return 0;

    return (@as(u64, data.ftLastWriteTime.dwHighDateTime) << 32) | @as(u64, data.ftLastWriteTime.dwLowDateTime);
}

fn basenameAnySeparator(path: []const u8) []const u8 {
    var start: usize = 0;
    for (path, 0..) |ch, i| {
        if (ch == '\\' or ch == '/') start = i + 1;
    }
    return path[start..];
}

const GameCandidate = struct {
    path: []u8,
    modified_time: u64,
};

fn freeGameCandidates(candidates: *std.ArrayListUnmanaged(GameCandidate), allocator: std.mem.Allocator) void {
    for (candidates.items) |candidate| allocator.free(candidate.path);
    candidates.deinit(allocator);
}

fn hasCandidate(candidates: []const GameCandidate, path: []const u8) bool {
    for (candidates) |candidate| {
        if (std.ascii.eqlIgnoreCase(candidate.path, path)) return true;
    }
    return false;
}

fn addCandidate(io: std.Io, candidates: *std.ArrayListUnmanaged(GameCandidate), allocator: std.mem.Allocator, path: []const u8) !void {
    const trimmed = trimRightPathNoise(path);
    if (trimmed.len == 0) return;
    if (!std.ascii.eqlIgnoreCase(basenameAnySeparator(trimmed), target_exe_name)) return;
    if (hasCandidate(candidates.items, trimmed)) return;
    if (!pathExistsWtf8(io, trimmed)) return;

    const owned = try allocator.dupe(u8, trimmed);
    errdefer allocator.free(owned);

    try candidates.append(allocator, .{
        .path = owned,
        .modified_time = fileModifiedTimeWtf8(trimmed),
    });
}

fn addInstallCandidate(io: std.Io, candidates: *std.ArrayListUnmanaged(GameCandidate), allocator: std.mem.Allocator, install_dir: []const u8) !void {
    var exe_buf: [max_path_bytes]u8 = undefined;
    const exe_utf8 = c.appendNormalizedPath(&exe_buf, install_dir, target_exe_name) catch return;
    try addCandidate(io, candidates, allocator, exe_utf8);
}

fn lineInstallDir(line: []const u8) ?[]const u8 {
    const endfield_idx = indexOfIgnoreCase(line, target_data_dir_name) orelse
        indexOfIgnoreCase(line, target_exe_name) orelse
        indexOfIgnoreCase(line, "Endfield") orelse
        return null;

    var start: ?usize = null;
    var i: usize = 0;
    while (i + 2 < line.len and i <= endfield_idx) : (i += 1) {
        if (std.ascii.isAlphabetic(line[i]) and line[i + 1] == ':' and (line[i + 2] == '\\' or line[i + 2] == '/')) {
            start = i;
        }
    }

    const path_start = start orelse return null;

    var path_end = trimRightPathNoise(line[path_start..]).len + path_start;
    if (indexOfIgnoreCase(line[path_start..path_end], target_data_dir_name)) |data_idx| {
        path_end = path_start + data_idx;
    } else if (indexOfIgnoreCase(line[path_start..path_end], target_exe_name)) |exe_idx| {
        path_end = path_start + exe_idx;
    }

    while (path_end > path_start and (line[path_end - 1] == '\\' or line[path_end - 1] == '/')) : (path_end -= 1) {}
    if (path_end <= path_start) return null;
    return line[path_start..path_end];
}

fn readFile(io: std.Io, allocator: std.mem.Allocator, wtf8_path: []const u8) !?[]u8 {
    var file = std.Io.Dir.openFileAbsolute(io, wtf8_path, .{ .allow_directory = false }) catch return null;
    defer file.close(io);

    const stat = file.stat(io) catch return null;
    if (stat.kind != .file or stat.size > 32 * 1024 * 1024) return null;

    var file_reader = file.reader(io, &.{});
    return try file_reader.interface.readAlloc(allocator, @intCast(stat.size));
}

const RegSource = struct {
    root: c.HKEY,
    subkey: c.LPCWSTR,
};

fn scanRegistryValue(io: std.Io, candidates: *std.ArrayListUnmanaged(GameCandidate), allocator: std.mem.Allocator, value_name: []const u16) !void {
    const exe_idx = indexOfAsciiWideIgnoreCase(value_name, target_exe_name) orelse return;

    var start: ?usize = null;
    var i: usize = 0;
    while (i + 2 < value_name.len and i <= exe_idx) : (i += 1) {
        if (isAsciiWideAlphabetic(value_name[i]) and value_name[i + 1] == ':' and isAsciiWidePathSeparator(value_name[i + 2])) {
            start = i;
        }
    }

    const path_start = start orelse return;
    const path_end = exe_idx + target_exe_name.len;
    if (path_end <= path_start or path_end > value_name.len) return;

    var path_buf: [max_path_bytes]u8 = undefined;
    const exe_path = c.wtf16LeToWtf8Slice(value_name[path_start..path_end], &path_buf) catch return;
    try addCandidate(io, candidates, allocator, exe_path);
}

fn scanRegistry(io: std.Io, candidates: *std.ArrayListUnmanaged(GameCandidate), allocator: std.mem.Allocator) !void {
    const reg_sources = [_]RegSource{
        .{ .root = c.HKEY_CLASSES_ROOT, .subkey = std.unicode.utf8ToUtf16LeStringLiteral("Local Settings\\Software\\Microsoft\\Windows\\Shell\\MuiCache") },
        .{ .root = c.HKEY_CURRENT_USER, .subkey = std.unicode.utf8ToUtf16LeStringLiteral("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FeatureUsage\\AppSwitched") },
        .{ .root = c.HKEY_CURRENT_USER, .subkey = std.unicode.utf8ToUtf16LeStringLiteral("Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FeatureUsage\\ShowJumpView") },
    };

    for (reg_sources) |source| {
        var key: c.HKEY = undefined;
        if (c.RegOpenKeyExW(source.root, source.subkey, 0, c.KEY_READ, &key) != c.ERROR_SUCCESS) continue;
        defer _ = c.RegCloseKey(key);

        var index: c.DWORD = 0;
        while (true) : (index += 1) {
            var value_buf: [max_path_bytes]u16 = undefined;
            var value_len: c.DWORD = value_buf.len;
            const result = c.RegEnumValueW(key, index, &value_buf, &value_len, null, null, null, null);
            if (result == c.ERROR_NO_MORE_ITEMS) break;
            if (result != c.ERROR_SUCCESS) continue;

            try scanRegistryValue(io, candidates, allocator, value_buf[0..value_len]);
        }
    }
}

fn scanPlayerLog(io: std.Io, environ: std.process.Environ, allocator: std.mem.Allocator, candidates: *std.ArrayListUnmanaged(GameCandidate)) !void {
    var appdata_buf: [max_path_bytes]u8 = undefined;
    const appdata = c.getEnvironmentVariableWtf8(environ, "APPDATA", &appdata_buf) orelse return;
    const roaming_parent = std.fs.path.dirname(appdata) orelse return;

    var log_buf: [max_path_bytes]u8 = undefined;
    const log_path = try c.appendNormalizedPath(&log_buf, roaming_parent, "LocalLow\\Gryphline\\Endfield\\Player.log");

    const contents = try readFile(io, allocator, log_path) orelse return;
    defer allocator.free(contents);

    var lines = std.mem.splitScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        const install_dir = lineInstallDir(line) orelse continue;
        try addInstallCandidate(io, candidates, allocator, install_dir);
    }
}

fn scanKnownPaths(io: std.Io, allocator: std.mem.Allocator, candidates: *std.ArrayListUnmanaged(GameCandidate)) !void {
    const drives = "CDE";
    const parents = [_][]const u8{
        "Program Files\\GRYPHLINK\\games",
        "GRYPHLINK\\games",
    };
    const folders = [_][]const u8{
        "Arknights Endfield",
        "EndField Game",
    };

    var buf: [max_path_bytes]u8 = undefined;

    for (drives) |drive| {
        for (parents) |parent| {
            for (folders) |folder| {
                const candidate = std.fmt.bufPrint(&buf, "{c}:\\{s}\\{s}\\{s}", .{ drive, parent, folder, target_exe_name }) catch continue;
                try addCandidate(io, candidates, allocator, candidate);
            }
        }
    }
}

fn newerGameCandidate(_: void, a: GameCandidate, b: GameCandidate) bool {
    return a.modified_time > b.modified_time;
}

pub fn detectGameExeWithScan(environ: std.process.Environ, allocator: std.mem.Allocator, scan: GameScan) !?[:0]u16 {
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var candidates: std.ArrayListUnmanaged(GameCandidate) = .empty;
    defer freeGameCandidates(&candidates, allocator);

    if (scan.player_log) try scanPlayerLog(io, environ, allocator, &candidates);
    if (scan.known_paths) try scanKnownPaths(io, allocator, &candidates);
    if (scan.registry) try scanRegistry(io, &candidates, allocator);

    if (candidates.items.len == 0) return null;
    std.sort.block(GameCandidate, candidates.items, {}, newerGameCandidate);
    return try std.unicode.wtf8ToWtf16LeAllocZ(allocator, candidates.items[0].path);
}

pub fn detectGameExe(environ: std.process.Environ, allocator: std.mem.Allocator) !?[:0]u16 {
    return detectGameExeWithScan(environ, allocator, .{});
}

pub fn validateGameExeOverridePath(wtf8_path: []const u8) bool {
    return validateExecutablePath(wtf8_path);
}

pub fn trimExecutablePath(wtf8_path: []const u8) []const u8 {
    return trimRightPathNoise(wtf8_path);
}

pub fn validateExecutablePath(wtf8_path: []const u8) bool {
    const trimmed = trimRightPathNoise(wtf8_path);
    if (trimmed.len == 0) return false;
    if (!std.ascii.eqlIgnoreCase(std.fs.path.extension(trimmed), ".exe")) return false;
    return pathIsFileWtf8(trimmed);
}

pub fn duplicateGameExePath(allocator: std.mem.Allocator, wtf8_path: []const u8) ![:0]u16 {
    return try std.unicode.wtf8ToWtf16LeAllocZ(allocator, trimRightPathNoise(wtf8_path));
}

pub fn resolveGameExeWithScan(game_exe_override_path: ?[]const u8, environ: std.process.Environ, allocator: std.mem.Allocator, scan: GameScan) !?[:0]u16 {
    if (game_exe_override_path) |path| {
        if (!validateGameExeOverridePath(path)) return null;
        return try duplicateGameExePath(allocator, path);
    }

    return try detectGameExeWithScan(environ, allocator, scan);
}

pub fn resolveGameExe(game_exe_override_path: ?[]const u8, environ: std.process.Environ, allocator: std.mem.Allocator) !?[:0]u16 {
    return resolveGameExeWithScan(game_exe_override_path, environ, allocator, .{});
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

// Process state checks and temporary DLL staging
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

    switch (c.WaitForSingleObject(thread, 10_000)) {
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
