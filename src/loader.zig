const std = @import("std");

// Platform Imports
pub const c = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", {});
    @cDefine("NOMINMAX", {});
    @cInclude("windows.h");
    @cInclude("tlhelp32.h");
});

pub const target_exe_name = "Endfield.exe";
pub const temp_dll_name = "EFU_temp.dll";

// Process Access Constants
const process_rights =
    c.PROCESS_CREATE_THREAD |
    c.PROCESS_QUERY_INFORMATION |
    c.PROCESS_VM_OPERATION |
    c.PROCESS_VM_WRITE |
    c.PROCESS_VM_READ;

// Path And Process Discovery Helpers
fn utf16SliceZ(buf: []const u16) []const u16 {
    var len: usize = 0;
    while (len < buf.len and buf[len] != 0) : (len += 1) {}
    return buf[0..len];
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

fn normalizePathSeparators(path: []u8) void {
    for (path) |*ch| {
        if (ch.* == '/') ch.* = '\\';
    }
}

fn getEnvironmentVariableUtf8(allocator: std.mem.Allocator, comptime name: []const u8) !?[]u8 {
    const wide_name = std.unicode.utf8ToUtf16LeStringLiteral(name);
    var buf: [32767]u16 = undefined;
    const len = c.GetEnvironmentVariableW(wide_name, &buf, buf.len);
    if (len == 0 or len >= buf.len) return null;
    return @as(?[]u8, try std.unicode.utf16LeToUtf8Alloc(allocator, buf[0..len]));
}

fn pathExistsUtf8(allocator: std.mem.Allocator, utf8_path: []const u8) !bool {
    const wide = try std.unicode.utf8ToUtf16LeAllocZ(allocator, utf8_path);
    defer allocator.free(wide);

    const attrs = c.GetFileAttributesW(wide.ptr);
    return attrs != c.INVALID_FILE_ATTRIBUTES and (attrs & c.FILE_ATTRIBUTE_DIRECTORY) == 0;
}

fn extractInstallDirFromLine(allocator: std.mem.Allocator, line: []const u8) !?[]u8 {
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

    const out = try allocator.dupe(u8, line[path_start..path_end]);
    normalizePathSeparators(out);
    return out;
}

fn readWholeFileUtf8(allocator: std.mem.Allocator, utf8_path: []const u8) !?[]u8 {
    const wide_path = try std.unicode.utf8ToUtf16LeAllocZ(allocator, utf8_path);
    defer allocator.free(wide_path);

    const handle = c.CreateFileW(
        wide_path.ptr,
        c.GENERIC_READ,
        c.FILE_SHARE_READ | c.FILE_SHARE_WRITE | c.FILE_SHARE_DELETE,
        null,
        c.OPEN_EXISTING,
        c.FILE_ATTRIBUTE_NORMAL,
        null,
    );
    if (handle == c.INVALID_HANDLE_VALUE) return null;
    defer _ = c.CloseHandle(handle);

    var size_info: c.LARGE_INTEGER = undefined;
    if (c.GetFileSizeEx(handle, &size_info) == 0 or size_info.QuadPart <= 0) return null;

    const file_size: usize = @intCast(size_info.QuadPart);
    var buffer = try allocator.alloc(u8, file_size);
    errdefer allocator.free(buffer);

    var total_read: usize = 0;
    while (total_read < buffer.len) {
        var chunk_read: c.DWORD = 0;
        const chunk_len: u32 = @intCast(@min(buffer.len - total_read, @as(usize, std.math.maxInt(u32))));
        if (c.ReadFile(handle, buffer[total_read..].ptr, chunk_len, &chunk_read, null) == 0) {
            return error.FileReadFailed;
        }
        if (chunk_read == 0) break;
        total_read += chunk_read;
    }

    if (total_read == buffer.len) return buffer;
    return @as(?[]u8, try allocator.realloc(buffer, total_read));
}

fn detectGameExeFromPlayerLog(allocator: std.mem.Allocator) !?[:0]u16 {
    const appdata = try getEnvironmentVariableUtf8(allocator, "APPDATA") orelse return null;
    defer allocator.free(appdata);

    const roaming_parent = std.fs.path.dirname(appdata) orelse return null;
    const player_log = try std.fs.path.join(allocator, &.{ roaming_parent, "LocalLow", "Gryphline", "Endfield", "Player.log" });
    defer allocator.free(player_log);

    const contents = try readWholeFileUtf8(allocator, player_log) orelse return null;
    defer allocator.free(contents);

    var lines = std.mem.splitScalar(u8, contents, '\n');
    while (lines.next()) |line| {
        const install_dir = try extractInstallDirFromLine(allocator, line) orelse continue;
        defer allocator.free(install_dir);

        const exe_utf8 = try std.fs.path.join(allocator, &.{ install_dir, "Endfield.exe" });
        defer allocator.free(exe_utf8);

        if (try pathExistsUtf8(allocator, exe_utf8)) {
            return try std.unicode.utf8ToUtf16LeAllocZ(allocator, exe_utf8);
        }
    }

    return null;
}

fn detectGameExeFromKnownPaths(allocator: std.mem.Allocator) !?[:0]u16 {
    const fixed = [_][]const u8{
        "C:\\Program Files\\GRYPHLINK\\games\\EndField Game\\Endfield.exe",
        "A:\\GRYPHLINK\\games\\EndField Game\\Endfield.exe",
        "B:\\GRYPHLINK\\games\\EndField Game\\Endfield.exe",
    };

    for (fixed) |candidate| {
        if (try pathExistsUtf8(allocator, candidate)) {
            return try std.unicode.utf8ToUtf16LeAllocZ(allocator, candidate);
        }
    }

    var drive: u8 = 'D';
    while (drive <= 'Z') : (drive += 1) {
        const candidate = try std.fmt.allocPrint(allocator, "{c}:\\GRYPHLINK\\games\\EndField Game\\Endfield.exe", .{drive});
        defer allocator.free(candidate);

        if (try pathExistsUtf8(allocator, candidate)) {
            return try std.unicode.utf8ToUtf16LeAllocZ(allocator, candidate);
        }
    }

    return null;
}

pub fn detectGameExe(allocator: std.mem.Allocator) !?[:0]u16 {
    if (try detectGameExeFromPlayerLog(allocator)) |path| return path;
    return try detectGameExeFromKnownPaths(allocator);
}

// Injection And Launch
pub fn findTargetProcess() u32 {
    const snapshot = c.CreateToolhelp32Snapshot(c.TH32CS_SNAPPROCESS, 0);
    if (snapshot == c.INVALID_HANDLE_VALUE) return 0;
    defer _ = c.CloseHandle(snapshot);

    var entry: c.PROCESSENTRY32W = std.mem.zeroInit(c.PROCESSENTRY32W, .{});
    entry.dwSize = @sizeOf(c.PROCESSENTRY32W);

    if (c.Process32FirstW(snapshot, &entry) == 0) return 0;

    while (true) {
        const exe_name = utf16SliceZ(entry.szExeFile[0..]);
        if (eqlAsciiWideIgnoreCase(exe_name, target_exe_name)) {
            return entry.th32ProcessID;
        }
        if (c.Process32NextW(snapshot, &entry) == 0) break;
    }

    return 0;
}

pub fn isProcessAlive(pid: u32) bool {
    if (pid == 0) return false;
    const handle = c.OpenProcess(c.SYNCHRONIZE, c.FALSE, pid) orelse return false;
    defer _ = c.CloseHandle(handle);
    return c.WaitForSingleObject(handle, 0) == c.WAIT_TIMEOUT;
}

pub fn writeEmbeddedDllToTemp(allocator: std.mem.Allocator, dll_bytes: []const u8) ![:0]u16 {
    var temp_buf: [c.MAX_PATH]u16 = undefined;
    const temp_len = c.GetTempPathW(temp_buf.len, &temp_buf);
    if (temp_len == 0 or temp_len >= temp_buf.len) return error.TempPathUnavailable;

    const temp_name = std.unicode.utf8ToUtf16LeStringLiteral(temp_dll_name);
    const path = try allocator.allocSentinel(u16, temp_len + temp_name.len, 0);
    @memcpy(path[0..temp_len], temp_buf[0..temp_len]);
    @memcpy(path[temp_len .. temp_len + temp_name.len], temp_name);

    const handle = c.CreateFileW(
        path.ptr,
        c.GENERIC_WRITE,
        c.FILE_SHARE_READ,
        null,
        c.CREATE_ALWAYS,
        c.FILE_ATTRIBUTE_TEMPORARY,
        null,
    );
    if (handle == c.INVALID_HANDLE_VALUE) {
        allocator.free(path);
        return error.TempFileCreateFailed;
    }
    defer _ = c.CloseHandle(handle);

    var bytes_written: c.DWORD = 0;
    if (c.WriteFile(handle, dll_bytes.ptr, @intCast(dll_bytes.len), &bytes_written, null) == 0 or bytes_written != dll_bytes.len) {
        allocator.free(path);
        return error.TempFileWriteFailed;
    }

    return path;
}

pub fn injectDll(pid: u32, dll_path: [:0]const u16) bool {
    if (pid == 0) return false;

    const process = c.OpenProcess(process_rights, c.FALSE, pid) orelse return false;
    defer _ = c.CloseHandle(process);

    const path_bytes: usize = (dll_path.len + 1) * @sizeOf(u16);
    const remote_mem = c.VirtualAllocEx(process, null, path_bytes, c.MEM_COMMIT | c.MEM_RESERVE, c.PAGE_READWRITE);
    if (remote_mem == null) return false;
    defer _ = c.VirtualFreeEx(process, remote_mem, 0, c.MEM_RELEASE);

    if (c.WriteProcessMemory(process, remote_mem, dll_path.ptr, path_bytes, null) == 0) {
        return false;
    }

    const kernel32 = c.GetModuleHandleW(std.unicode.utf8ToUtf16LeStringLiteral("kernel32.dll")) orelse return false;
    const load_library = c.GetProcAddress(kernel32, "LoadLibraryW") orelse return false;

    const thread = c.CreateRemoteThread(
        process,
        null,
        0,
        @ptrCast(load_library),
        remote_mem,
        0,
        null,
    ) orelse return false;
    defer _ = c.CloseHandle(thread);

    _ = c.WaitForSingleObject(thread, 5000);
    return true;
}

pub fn launchGame(game_exe_path: [:0]const u16) !void {
    var startup_info: c.STARTUPINFOW = std.mem.zeroInit(c.STARTUPINFOW, .{});
    var process_info: c.PROCESS_INFORMATION = std.mem.zeroInit(c.PROCESS_INFORMATION, .{});
    startup_info.cb = @sizeOf(c.STARTUPINFOW);

    if (c.CreateProcessW(
        game_exe_path.ptr,
        null,
        null,
        null,
        c.FALSE,
        0,
        null,
        null,
        &startup_info,
        &process_info,
    ) == 0) {
        return error.GameLaunchFailed;
    }

    _ = c.CloseHandle(process_info.hThread);
    _ = c.CloseHandle(process_info.hProcess);
}
