// CLI launcher path
const builtin = @import("builtin");
const std = @import("std");

const app_version = @import("version.zig");
const loader = @import("loader.zig");
const strings = @import("strings.zig");
const c = @import("win32.zig");

const APP_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored");
const VERSION_STR = app_version.version_str;
const CLI_CONSOLE_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored CLI");
const FORCE_WINE_MODE_LONG = "--force-wine-mode";
const FORCE_WINE_MODE_SHORT = "-fwm";
const ALLOW_MINIMIZE_LONG = "--allow-minimize";
const SILENT_LONG = "--silent";
const EFMI_LONG = "--efmi";
const GAME_PATH_LONG = "--game-path";
const EFMI_WAIT_TIMEOUT_MS: u64 = 10_000;
const EFMI_DEFAULT_SUBPATH = "XXMI Launcher\\Resources\\Bin\\XXMI Launcher.exe";
const EFMI_MISSING_PATH_MESSAGE = "You need to specify a location with --EFMI <PATH_TO_XXMI Launcher.exe>.";
const BOOL_OVERRIDE_USAGE = "Use on/off, yes/no, true/false, y/n, or t/f.";

pub const BoolOverride = enum {
    auto,
    on,
    off,
};

pub const Mode = enum {
    visible,
    silent,
};

pub const LaunchConfig = struct {
    cli: bool = false,
    silent: bool = false,
    auto_yes: bool = false,
    dx11: bool = false,
    efmi_requested: bool = false,
    efmi_launcher_path: ?[]u8 = null,
    game_exe_override_path: ?[]u8 = null,
    wine_mode_override: BoolOverride = .auto,
    allow_minimize_override: BoolOverride = .auto,
};

pub const ParseArgsError = error{
    MissingForceWineModeValue,
    InvalidForceWineModeValue,
    MissingAllowMinimizeValue,
    InvalidAllowMinimizeValue,
    MissingGamePathValue,
    InvalidGamePathValue,
    MutuallyExclusiveDx11AndEfmi,
    MutuallyExclusiveGamePathAndEfmi,
    MutuallyExclusiveAutoYesAndGui,
    MutuallyExclusiveCliAndForceWineMode,
    MutuallyExclusiveSilentAndGui,
    MutuallyExclusiveCliAndGuiArgs,
};

const CliWaitResult = union(enum) {
    quit,
    process_found: u32,
};

// Argument parsing
fn wtf8ToWtf16LeZ(wtf8: []const u8, buf: []u16) ![:0]u16 {
    if (buf.len == 0) return error.NoSpaceLeft;
    const len = try std.unicode.wtf8ToWtf16Le(buf[0 .. buf.len - 1], wtf8);
    buf[len] = 0;
    return buf[0..len :0];
}

fn wtf16LeToWtf8Slice(wtf16le: []const u16, out_buf: []u8) ![]const u8 {
    const len = std.unicode.calcWtf8Len(wtf16le);
    if (len > out_buf.len) return error.NoSpaceLeft;
    return out_buf[0..std.unicode.wtf16LeToWtf8(out_buf, wtf16le)];
}

fn showErrorMessage(message: []const u8) void {
    var message_buf: [256]u16 = undefined;
    const message_utf16 = wtf8ToWtf16LeZ(message, &message_buf) catch return;
    _ = c.MessageBoxW(null, message_utf16.ptr, APP_TITLE, c.MB_OK | c.MB_ICONERROR);
}

pub fn showArgumentError(message: []const u8) void {
    showErrorMessage(message);
}

fn isCliArg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, "-c") or
        std.ascii.eqlIgnoreCase(arg, "--c") or
        std.ascii.eqlIgnoreCase(arg, "-cli") or
        std.ascii.eqlIgnoreCase(arg, "--cli") or
        std.ascii.eqlIgnoreCase(arg, "/cli");
}

fn isSilentArg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, "-s") or
        std.ascii.eqlIgnoreCase(arg, "--s") or
        std.ascii.eqlIgnoreCase(arg, "-silent") or
        std.ascii.eqlIgnoreCase(arg, SILENT_LONG) or
        std.ascii.eqlIgnoreCase(arg, "/silent");
}

fn isAutoYesArg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, "-y") or
        std.ascii.eqlIgnoreCase(arg, "--y") or
        std.ascii.eqlIgnoreCase(arg, "/y") or
        std.ascii.eqlIgnoreCase(arg, "-yes") or
        std.ascii.eqlIgnoreCase(arg, "--yes") or
        std.ascii.eqlIgnoreCase(arg, "/yes");
}

fn isDx11Arg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, "-dx11") or
        std.ascii.eqlIgnoreCase(arg, "--dx11") or
        std.ascii.eqlIgnoreCase(arg, "/dx11");
}

fn isForceWineModeArg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, FORCE_WINE_MODE_LONG) or
        std.ascii.eqlIgnoreCase(arg, "-wm") or
        std.ascii.eqlIgnoreCase(arg, "--wm") or
        std.ascii.eqlIgnoreCase(arg, "-force-wine-mode") or
        std.ascii.eqlIgnoreCase(arg, "/force-wine-mode") or
        std.ascii.eqlIgnoreCase(arg, FORCE_WINE_MODE_SHORT) or
        std.ascii.eqlIgnoreCase(arg, "--fwm") or
        std.ascii.eqlIgnoreCase(arg, "/fwm");
}

fn isAllowMinimizeArg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, "-am") or
        std.ascii.eqlIgnoreCase(arg, "--am") or
        std.ascii.eqlIgnoreCase(arg, ALLOW_MINIMIZE_LONG) or
        std.ascii.eqlIgnoreCase(arg, "-allow-minimize") or
        std.ascii.eqlIgnoreCase(arg, "/allow-minimize");
}

fn isEfmiArg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, "-efmi") or
        std.ascii.eqlIgnoreCase(arg, EFMI_LONG) or
        std.ascii.eqlIgnoreCase(arg, "/efmi");
}

fn isGamePathArg(arg: []const u8) bool {
    return std.ascii.eqlIgnoreCase(arg, "-gp") or
        std.ascii.eqlIgnoreCase(arg, "--gp") or
        std.ascii.eqlIgnoreCase(arg, GAME_PATH_LONG) or
        std.ascii.eqlIgnoreCase(arg, "-game-path") or
        std.ascii.eqlIgnoreCase(arg, "/game-path");
}

fn isKnownArg(arg: []const u8) bool {
    return isCliArg(arg) or
        isAutoYesArg(arg) or
        isDx11Arg(arg) or
        isSilentArg(arg) or
        isForceWineModeArg(arg) or
        isAllowMinimizeArg(arg) or
        isEfmiArg(arg) or
        isGamePathArg(arg);
}

fn parseBoolOverrideValue(arg: []const u8) ?BoolOverride {
    if (std.ascii.eqlIgnoreCase(arg, "on") or
        std.ascii.eqlIgnoreCase(arg, "yes") or
        std.ascii.eqlIgnoreCase(arg, "true") or
        std.ascii.eqlIgnoreCase(arg, "t") or
        std.ascii.eqlIgnoreCase(arg, "y"))
    {
        return .on;
    }
    if (std.ascii.eqlIgnoreCase(arg, "off") or
        std.ascii.eqlIgnoreCase(arg, "no") or
        std.ascii.eqlIgnoreCase(arg, "false") or
        std.ascii.eqlIgnoreCase(arg, "f") or
        std.ascii.eqlIgnoreCase(arg, "n"))
    {
        return .off;
    }
    return null;
}

fn getEnvironmentVariableWtf8(environ: std.process.Environ, comptime name: []const u8, out_buf: []u8) ?[]const u8 {
    if (builtin.os.tag == .windows) {
        const value_w = std.process.Environ.getWindows(environ, std.unicode.wtf8ToWtf16LeStringLiteral(name)) orelse return null;
        return wtf16LeToWtf8Slice(value_w, out_buf) catch null;
    }

    const value = std.process.Environ.getPosix(environ, name) orelse return null;
    if (value.len > out_buf.len) return null;
    @memcpy(out_buf[0..value.len], value);
    return out_buf[0..value.len];
}

fn appendNormalizedPath(out_buf: []u8, base: []const u8, leaf: []const u8) ![]const u8 {
    var len: usize = 0;

    for (base) |ch| {
        if (len >= out_buf.len) return error.NoSpaceLeft;
        out_buf[len] = if (ch == '/') '\\' else ch;
        len += 1;
    }

    while (len > 0 and (out_buf[len - 1] == '\\' or out_buf[len - 1] == '/')) : (len -= 1) {}

    if (len >= out_buf.len) return error.NoSpaceLeft;
    out_buf[len] = '\\';
    len += 1;

    var leaf_start: usize = 0;
    while (leaf_start < leaf.len and (leaf[leaf_start] == '\\' or leaf[leaf_start] == '/')) : (leaf_start += 1) {}

    for (leaf[leaf_start..]) |ch| {
        if (len >= out_buf.len) return error.NoSpaceLeft;
        out_buf[len] = if (ch == '/') '\\' else ch;
        len += 1;
    }

    return out_buf[0..len];
}

fn pathExistsWtf8(wtf8_path: []const u8) bool {
    var path_buf: [std.Io.Dir.max_path_bytes]u16 = undefined;
    const path_w = wtf8ToWtf16LeZ(wtf8_path, &path_buf) catch return false;
    return c.GetFileAttributesW(path_w.ptr) != c.INVALID_FILE_ATTRIBUTES;
}

fn resolveDefaultEfmiLauncherPath(allocator: std.mem.Allocator, environ: std.process.Environ) !?[]u8 {
    var appdata_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const appdata = getEnvironmentVariableWtf8(environ, "APPDATA", &appdata_buf) orelse return null;

    var path_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const path = appendNormalizedPath(&path_buf, appdata, EFMI_DEFAULT_SUBPATH) catch return null;
    if (!pathExistsWtf8(path)) return null;

    return try allocator.dupe(u8, path);
}

pub fn parseLaunchConfig(allocator: std.mem.Allocator, environ: std.process.Environ, args: std.process.Args) !LaunchConfig {
    var args_it = std.process.Args.Iterator.initAllocator(args, allocator) catch return error.OutOfMemory;
    defer args_it.deinit();

    var config = LaunchConfig{};
    errdefer {
        if (config.efmi_launcher_path) |path| allocator.free(path);
        if (config.game_exe_override_path) |path| allocator.free(path);
    }
    var pending_arg: ?[]const u8 = null;

    _ = args_it.next();
    while (true) {
        const arg = pending_arg orelse args_it.next() orelse break;
        pending_arg = null;

        if (isCliArg(arg)) {
            config.cli = true;
            continue;
        }

        if (isSilentArg(arg)) {
            config.silent = true;
            continue;
        }

        if (isAutoYesArg(arg)) {
            config.auto_yes = true;
            continue;
        }

        if (isDx11Arg(arg)) {
            config.dx11 = true;
            continue;
        }

        if (isForceWineModeArg(arg)) {
            const value = args_it.next() orelse return error.MissingForceWineModeValue;
            if (isCliArg(value)) {
                config.cli = true;
                continue;
            }
            if (isSilentArg(value)) {
                config.silent = true;
                continue;
            }
            config.wine_mode_override = parseBoolOverrideValue(value) orelse return error.InvalidForceWineModeValue;
            continue;
        }

        if (isAllowMinimizeArg(arg)) {
            const value = args_it.next() orelse return error.MissingAllowMinimizeValue;
            config.allow_minimize_override = parseBoolOverrideValue(value) orelse return error.InvalidAllowMinimizeValue;
            continue;
        }

        if (isGamePathArg(arg)) {
            const value = args_it.next() orelse return error.MissingGamePathValue;
            if (isKnownArg(value)) return error.MissingGamePathValue;
            if (!loader.validateGameExeOverridePath(value)) return error.InvalidGamePathValue;
            if (config.game_exe_override_path) |old_path| allocator.free(old_path);
            config.game_exe_override_path = try allocator.dupe(u8, value);
            continue;
        }

        if (isEfmiArg(arg)) {
            if (config.efmi_launcher_path) |old_path| allocator.free(old_path);
            config.efmi_launcher_path = null;
            config.cli = true;
            config.efmi_requested = true;

            const maybe_value = args_it.next();
            if (maybe_value) |value| {
                if (isKnownArg(value)) {
                    pending_arg = value;
                    config.efmi_launcher_path = try resolveDefaultEfmiLauncherPath(allocator, environ);
                } else {
                    config.efmi_launcher_path = try allocator.dupe(u8, value);
                }
            } else {
                config.efmi_launcher_path = try resolveDefaultEfmiLauncherPath(allocator, environ);
            }
        }
    }

    if (config.silent and !config.cli) {
        config.cli = true;
    }
    if (config.dx11 and config.efmi_requested) {
        return error.MutuallyExclusiveDx11AndEfmi;
    }
    if (config.efmi_requested and config.game_exe_override_path != null) {
        return error.MutuallyExclusiveGamePathAndEfmi;
    }
    if (config.auto_yes and !config.cli) {
        return error.MutuallyExclusiveAutoYesAndGui;
    }
    if (config.cli and (config.wine_mode_override != .auto or config.allow_minimize_override != .auto)) {
        return error.MutuallyExclusiveCliAndGuiArgs;
    }

    return config;
}

pub fn describeParseArgsError(err: ParseArgsError) []const u8 {
    return switch (err) {
        error.MissingForceWineModeValue => "Missing value for --force-wine-mode. " ++ BOOL_OVERRIDE_USAGE,
        error.InvalidForceWineModeValue => "Invalid value for --force-wine-mode. " ++ BOOL_OVERRIDE_USAGE,
        error.MissingAllowMinimizeValue => "Missing value for --allow-minimize. " ++ BOOL_OVERRIDE_USAGE,
        error.InvalidAllowMinimizeValue => "Invalid value for --allow-minimize. " ++ BOOL_OVERRIDE_USAGE,
        error.MissingGamePathValue => "Missing value for --game-path. Pass a path to Endfield.exe.",
        error.InvalidGamePathValue => "Invalid value for --game-path. It must point to an existing .exe file.",
        error.MutuallyExclusiveDx11AndEfmi => "-DX11 is mutually exclusive with -EFMI.",
        error.MutuallyExclusiveGamePathAndEfmi => "--game-path is mutually exclusive with --EFMI.",
        error.MutuallyExclusiveAutoYesAndGui => "-y and -yes are mutually exclusive with GUI mode.",
        error.MutuallyExclusiveCliAndForceWineMode => "-cli and --force-wine-mode are mutually exclusive.",
        error.MutuallyExclusiveSilentAndGui => "-silent is mutually exclusive with GUI mode.",
        error.MutuallyExclusiveCliAndGuiArgs => "CLI arguments are mutually exclusive with GUI-only arguments.",
    };
}

fn ensureCliConsole() void {
    _ = c.FreeConsole();
    if (c.AllocConsole() == c.FALSE) return;
    _ = c.SetConsoleTitleW(CLI_CONSOLE_TITLE);
}

// Console I/O
fn cliWrite(io: std.Io, message: []const u8) void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    stdout_writer.interface.writeAll(message) catch return;
    stdout_writer.interface.flush() catch {};
}

fn cliPrint(io: std.Io, comptime fmt: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    const message = std.fmt.bufPrint(&buf, fmt, args) catch return;
    cliWrite(io, message);
}

fn cliPrintHeader(io: std.Io) void {
    var version_buf: [64]u8 = undefined;
    const version_display = strings.computeVersionDisplay(&version_buf, VERSION_STR) catch VERSION_STR;
    cliPrint(io, "\n[EFU Loader {s}]\n\n", .{version_display});
}

fn getProcessPathWtf8(pid: u32, out_buf: []u8) !?[]const u8 {
    if (pid == 0) return null;

    const process = c.OpenProcess(c.PROCESS_QUERY_LIMITED_INFORMATION, c.FALSE, pid) orelse return null;
    defer _ = c.CloseHandle(process);

    var wide_buf: [32768]u16 = undefined;
    var wide_len: c.DWORD = wide_buf.len - 1;
    if (c.QueryFullProcessImageNameW(process, 0, wide_buf[0..].ptr, &wide_len) == c.FALSE or wide_len == 0) return null;

    return try wtf16LeToWtf8Slice(wide_buf[0..wide_len], out_buf);
}

fn cliInputHandle() ?c.HANDLE {
    const handle = c.GetStdHandle(c.STD_INPUT_HANDLE) orelse return null;
    if (handle == c.INVALID_HANDLE_VALUE) return null;
    return handle;
}

fn cliReadCommand() ?u8 {
    const input = cliInputHandle() orelse return null;
    var record: c.INPUT_RECORD = undefined;
    var events_read: c.DWORD = 0;

    while (true) {
        if (c.PeekConsoleInputW(input, @ptrCast(&record), 1, &events_read) == c.FALSE or events_read == 0) return null;
        if (c.ReadConsoleInputW(input, @ptrCast(&record), 1, &events_read) == c.FALSE or events_read == 0) return null;
        if (record.EventType != c.KEY_EVENT) continue;

        const key_event = record.Event.KeyEvent;
        if (key_event.bKeyDown == c.FALSE) continue;
        if (key_event.uChar.UnicodeChar == 0 or key_event.uChar.UnicodeChar > 0x7F) continue;

        return std.ascii.toUpper(@intCast(key_event.uChar.UnicodeChar));
    }
}

fn describeEfmiLaunchError(err: loader.LaunchError) []const u8 {
    return switch (err) {
        error.ExecutableNotFound => "The path to XXMI is invalid.",
        error.AccessDenied => "Windows denied access to the EFMI launcher.",
        error.InvalidExecutablePath => "The path to XXMI is invalid.",
        error.CreateProcessFailed => "Windows failed to start the EFMI launcher.",
    };
}

fn launchEfmiLauncher(efmi_launcher_path: []const u8) loader.LaunchError!void {
    var startup_info: c.STARTUPINFOW = undefined;
    var process_info: c.PROCESS_INFORMATION = undefined;
    @memset(std.mem.asBytes(&startup_info), 0);
    @memset(std.mem.asBytes(&process_info), 0);
    startup_info.cb = @sizeOf(c.STARTUPINFOW);

    var path_buf: [std.Io.Dir.max_path_bytes]u16 = undefined;
    const launcher_path_w = wtf8ToWtf16LeZ(efmi_launcher_path, &path_buf) catch return error.InvalidExecutablePath;

    var command_line_utf8_buf: [std.Io.Dir.max_path_bytes + 32]u8 = undefined;
    const command_line_utf8 = std.fmt.bufPrint(&command_line_utf8_buf, "\"{s}\" --nogui --xxmi EFMI", .{efmi_launcher_path}) catch return error.InvalidExecutablePath;

    var command_line_wide_buf: [std.Io.Dir.max_path_bytes + 32]u16 = undefined;
    const command_line_wide = wtf8ToWtf16LeZ(command_line_utf8, &command_line_wide_buf) catch return error.InvalidExecutablePath;

    if (c.CreateProcessW(
        launcher_path_w.ptr,
        command_line_wide.ptr,
        null,
        null,
        c.FALSE,
        0,
        null,
        null,
        &startup_info,
        &process_info,
    ) == c.FALSE) {
        return switch (c.GetLastError()) {
            c.ERROR_FILE_NOT_FOUND, c.ERROR_PATH_NOT_FOUND => error.ExecutableNotFound,
            c.ERROR_ACCESS_DENIED => error.AccessDenied,
            c.ERROR_INVALID_NAME, c.ERROR_INVALID_PARAMETER => error.InvalidExecutablePath,
            else => error.CreateProcessFailed,
        };
    }

    _ = c.CloseHandle(process_info.hThread);
    _ = c.CloseHandle(process_info.hProcess);
}

fn waitForTargetProcessTimeout(timeout_ms: u64) u32 {
    const deadline = c.GetTickCount64() + timeout_ms;
    while (c.GetTickCount64() < deadline) {
        const pid = loader.findTargetProcess();
        if (pid != 0) return pid;
        c.Sleep(50);
    }
    return 0;
}

// Injection flow
fn cliInjectFoundProcess(io: std.Io, allocator: std.mem.Allocator, temp_dll_path: []const u8, pid: u32) !u8 {
    cliPrint(io, "Process found (PID: {d})\n", .{pid});

    var process_path_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    if (try getProcessPathWtf8(pid, &process_path_buf)) |path| {
        cliPrint(io, "Process path: {s}\n", .{path});
    } else {
        cliPrint(io, "Warning: Could not get process path\n", .{});
    }

    c.Sleep(10);

    const injection_succeeded = blk: {
        loader.injectDll(pid, temp_dll_path) catch |err| {
            cliPrint(io, "Injection failed: {s}\n", .{loader.describeInjectError(err)});
            if (loader.injectErrorSuggestsElevation(err)) {
                cliPrint(io, "Try running as administrator.\n", .{});
            }
            cliPrint(io, "\n", .{});
            break :blk false;
        };
        cliPrint(io, "Injection successful.\n\n", .{});
        break :blk true;
    };

    cliPrint(io, "Closing in 5 seconds...\n", .{});
    c.Sleep(5000);
    _ = allocator;
    return if (injection_succeeded) 0 else 1;
}

fn silentCliError(comptime fmt: []const u8, args: anytype) noreturn {
    var buf: [512]u8 = undefined;
    const message = std.fmt.bufPrint(&buf, fmt, args) catch "Silent mode failed.";
    showErrorMessage(message);
    std.process.exit(1);
}

fn cliWaitForProcessExitOrQuit(io: std.Io, pid: u32, allow_launch_info: bool) bool {
    while (loader.isProcessAlive(pid)) {
        if (cliReadCommand()) |cmd| {
            switch (cmd) {
                'Q' => return false,
                'L' => if (allow_launch_info) cliPrint(io, "{s}\n\n", .{strings.status_game_already_running_startup}),
                else => {},
            }
        }
        c.Sleep(50);
    }
    return true;
}

fn cliPrintReadyState(io: std.Io, game_exe_path: ?[:0]const u16) void {
    if (game_exe_path != null) {
        cliPrint(io, "{s}\n", .{strings.status_game_found});
        cliPrint(io, "{s}\n", .{strings.status_launch_here_or_external});
        cliPrint(io, "Press L to launch game. Press Q to quit.\n", .{});
    } else {
        cliPrint(io, "{s}\n", .{strings.status_game_not_found});
        cliPrint(io, "{s}\n", .{strings.status_launch_externally});
        cliPrint(io, "Press Q to quit.\n", .{});
    }
    cliPrint(io, "Waiting for {s}...\n\n", .{loader.target_exe_name});
}

fn cliWaitForTargetProcessOrCommand(io: std.Io, game_exe_path: ?[:0]const u16, dx11: bool) CliWaitResult {
    var launch_requested = false;

    while (true) {
        const pid = loader.findTargetProcess();
        if (pid != 0) return .{ .process_found = pid };

        if (cliReadCommand()) |cmd| {
            switch (cmd) {
                'Q' => return .quit,
                'L' => {
                    if (game_exe_path != null and !launch_requested) {
                        launchConfiguredGame(game_exe_path.?, dx11) catch |err| {
                            cliPrint(io, "Launch failed: {s}\n\n", .{loader.describeLaunchError(err)});
                            continue;
                        };
                        launch_requested = true;
                        cliPrint(io, "{s}\n\n", .{launchConfiguredStatus(dx11)});
                    }
                },
                else => {},
            }
        }

        c.Sleep(50);
    }
}

fn launchConfiguredGame(game_exe_path: [:0]const u16, dx11: bool) loader.LaunchError!void {
    if (dx11) {
        return loader.launchGameWithArgs(game_exe_path, "-force-d3d11");
    }
    return loader.launchGame(game_exe_path);
}

fn launchConfiguredStatus(dx11: bool) []const u8 {
    return if (dx11) strings.status_launching_game_dx11 else strings.status_launching_game;
}

fn cliWaitForEfmiLaunchOrQuit(auto_yes: bool) bool {
    if (auto_yes) return true;

    while (true) {
        if (cliReadCommand()) |cmd| {
            switch (cmd) {
                'Q' => return false,
                'Y' => return true,
                else => {},
            }
        }

        c.Sleep(50);
    }
}

// Run modes
fn runSilentCli(allocator: std.mem.Allocator, environ: std.process.Environ, embedded_dll: []const u8, game_exe_override_path: ?[]const u8, dx11: bool) !u8 {
    const game_exe_path = loader.resolveGameExe(game_exe_override_path, environ, allocator) catch null;
    defer if (game_exe_path) |path| allocator.free(path);

    const startup_pid = loader.findTargetProcess();
    if (startup_pid != 0) silentCliError("{s}", .{strings.status_game_already_running_startup});
    if (game_exe_path == null) silentCliError("{s}\nYou cannot use silent mode when the game path cannot be found.", .{strings.status_game_not_found});

    const temp_dll_path = loader.writeEmbeddedDllToTemp(allocator, embedded_dll) catch |err| {
        silentCliError("Error: {s}", .{loader.describeTempDllError(err)});
    };
    defer {
        loader.deleteTempDll(allocator, temp_dll_path);
        allocator.free(temp_dll_path);
    }

    launchConfiguredGame(game_exe_path.?, dx11) catch |err| {
        silentCliError("Launch failed: {s}", .{loader.describeLaunchError(err)});
    };

    var pid: u32 = 0;
    while (pid == 0) {
        pid = loader.findTargetProcess();
        if (pid == 0) c.Sleep(100);
    }

    c.Sleep(10);

    loader.injectDll(pid, temp_dll_path) catch |err| {
        var buf: [512]u8 = undefined;
        if (loader.injectErrorSuggestsElevation(err)) {
            const message = std.fmt.bufPrint(&buf, "Injection failed: {s}\nTry running as administrator.", .{loader.describeInjectError(err)}) catch "Injection failed.";
            showErrorMessage(message);
            std.process.exit(1);
        }
        silentCliError("Injection failed: {s}", .{loader.describeInjectError(err)});
    };

    return 0;
}

fn runSilentEfmiCli(allocator: std.mem.Allocator, embedded_dll: []const u8, efmi_launcher_path: []const u8) !u8 {
    const startup_pid = loader.findTargetProcess();
    if (startup_pid != 0) silentCliError("{s}", .{strings.status_game_already_running_startup});

    const temp_dll_path = loader.writeEmbeddedDllToTemp(allocator, embedded_dll) catch |err| {
        silentCliError("Error: {s}", .{loader.describeTempDllError(err)});
    };
    defer {
        loader.deleteTempDll(allocator, temp_dll_path);
        allocator.free(temp_dll_path);
    }

    launchEfmiLauncher(efmi_launcher_path) catch |err| {
        silentCliError("EFMI launch failed: {s}", .{describeEfmiLaunchError(err)});
    };

    const pid = waitForTargetProcessTimeout(EFMI_WAIT_TIMEOUT_MS);
    if (pid == 0) silentCliError("EFMI timeout.", .{});

    c.Sleep(10);
    loader.injectDll(pid, temp_dll_path) catch |err| {
        var buf: [512]u8 = undefined;
        if (loader.injectErrorSuggestsElevation(err)) {
            const message = std.fmt.bufPrint(&buf, "Injection failed: {s}\nTry running as administrator.", .{loader.describeInjectError(err)}) catch "Injection failed.";
            showErrorMessage(message);
            std.process.exit(1);
        }
        silentCliError("Injection failed: {s}", .{loader.describeInjectError(err)});
    };

    return 0;
}

fn runEfmiCli(allocator: std.mem.Allocator, embedded_dll: []const u8, efmi_launcher_path: []const u8, auto_yes: bool) !u8 {
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    ensureCliConsole();
    cliPrintHeader(io);

    const startup_pid = loader.findTargetProcess();
    if (startup_pid != 0) {
        cliPrint(io, "{s}\n", .{strings.status_game_already_running_startup});
        cliPrint(io, "Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    }

    const temp_dll_path = loader.writeEmbeddedDllToTemp(allocator, embedded_dll) catch |err| {
        cliPrint(io, "Error: {s}\n", .{loader.describeTempDllError(err)});
        cliPrint(io, "Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    };
    defer {
        loader.deleteTempDll(allocator, temp_dll_path);
        allocator.free(temp_dll_path);
    }

    cliPrint(io, "XXMI found.\n", .{});
    cliPrint(io, "Location: {s}\n\n", .{efmi_launcher_path});
    if (!auto_yes) {
        cliPrint(io, "Press Y to launch XXMI. Press Q to quit.\n", .{});
        if (!cliWaitForEfmiLaunchOrQuit(false)) return 0;
        cliPrint(io, "\n", .{});
    }
    cliPrint(io, "Launching EFMI...\n", .{});
    launchEfmiLauncher(efmi_launcher_path) catch |err| {
        cliPrint(io, "EFMI launch failed: {s}\n", .{describeEfmiLaunchError(err)});
        cliPrint(io, "Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    };

    cliPrint(io, "Waiting for {s}...\n\n", .{loader.target_exe_name});
    const pid = waitForTargetProcessTimeout(EFMI_WAIT_TIMEOUT_MS);
    if (pid == 0) {
        cliPrint(io, "EFMI timeout.\n", .{});
        cliPrint(io, "Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    }

    return try cliInjectFoundProcess(io, allocator, temp_dll_path, pid);
}

pub fn run(allocator: std.mem.Allocator, environ: std.process.Environ, mode: Mode, embedded_dll: []const u8, config: LaunchConfig) !u8 {
    if (config.efmi_requested) {
        if (config.efmi_launcher_path) |path| {
            return if (mode == .silent) runSilentEfmiCli(allocator, embedded_dll, path) else runEfmiCli(allocator, embedded_dll, path, config.auto_yes);
        }

        if (mode == .silent) {
            silentCliError("XXMI was not found in the default location.\n{s}", .{EFMI_MISSING_PATH_MESSAGE});
        }

        var threaded_efmi: std.Io.Threaded = .init(allocator, .{});
        defer threaded_efmi.deinit();
        const efmi_io = threaded_efmi.io();

        ensureCliConsole();
        cliPrintHeader(efmi_io);
        cliPrint(efmi_io, "XXMI was not found in the default location.\n", .{});
        cliPrint(efmi_io, "{s}\n", .{EFMI_MISSING_PATH_MESSAGE});
        cliPrint(efmi_io, "Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    }

    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    if (mode == .silent) return runSilentCli(allocator, environ, embedded_dll, config.game_exe_override_path, config.dx11);

    ensureCliConsole();
    cliPrintHeader(io);

    const temp_dll_path = loader.writeEmbeddedDllToTemp(allocator, embedded_dll) catch |err| {
        cliPrint(io, "Error: {s}\n", .{loader.describeTempDllError(err)});
        cliPrint(io, "Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    };
    defer {
        loader.deleteTempDll(allocator, temp_dll_path);
        allocator.free(temp_dll_path);
    }

    const game_exe_path = loader.resolveGameExe(config.game_exe_override_path, environ, allocator) catch null;
    defer if (game_exe_path) |path| allocator.free(path);

    const startup_pid = loader.findTargetProcess();
    if (startup_pid != 0) {
        cliPrint(io, "{s}\n", .{strings.status_game_already_running_startup});
        if (game_exe_path != null) {
            cliPrint(io, "Press L for launch info. Press Q to quit.\n", .{});
        } else {
            cliPrint(io, "Press Q to quit.\n", .{});
        }
        cliPrint(io, "Waiting for the game to close...\n\n", .{});
        if (!cliWaitForProcessExitOrQuit(io, startup_pid, game_exe_path != null)) return 0;
        cliPrint(io, "{s}\n", .{strings.status_game_process_closed});
    }

    cliPrint(io, "Ready.\n", .{});
    cliPrintReadyState(io, game_exe_path);

    const pid = switch (cliWaitForTargetProcessOrCommand(io, game_exe_path, config.dx11)) {
        .quit => return 0,
        .process_found => |value| value,
    };

    return try cliInjectFoundProcess(io, allocator, temp_dll_path, pid);
}
