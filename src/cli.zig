// CLI launcher path
const std = @import("std");

const app_version = @import("version");
const loader = @import("loader.zig");
const strings = @import("strings.zig");
const c = @import("win32.zig");

const APP_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored");
const VERSION_STR = app_version.version_str;
const CLI_CONSOLE_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored CLI");
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
    efmi_search_enabled: bool = true,
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
    MutuallyExclusiveCliAndGuiArgs,
};

const CliWaitResult = union(enum) {
    quit,
    process_found: u32,
};

const ArgKind = enum {
    unknown,
    cli,
    silent,
    auto_yes,
    dx11,
    force_wine_mode,
    allow_minimize,
    efmi,
    game_path,
};

fn showErrorMessage(message: []const u8) void {
    var message_buf: [256]u16 = undefined;
    const message_utf16 = c.wtf8ToWtf16LeZ(message, &message_buf) catch return;
    _ = c.MessageBoxW(null, message_utf16.ptr, APP_TITLE, c.MB_OK | c.MB_ICONERROR);
}

pub fn showArgumentError(message: []const u8) void {
    showErrorMessage(message);
}

fn argBody(arg: []const u8) ?[]const u8 {
    if (arg.len == 0) return null;
    return switch (arg[0]) {
        '/' => if (arg.len > 1) arg[1..] else null,
        '-' => if (arg.len > 2 and arg[1] == '-') arg[2..] else if (arg.len > 1) arg[1..] else null,
        else => null,
    };
}

fn classifyArg(arg: []const u8) ArgKind {
    const body = argBody(arg) orelse return .unknown;
    if (std.ascii.eqlIgnoreCase(body, "c") or std.ascii.eqlIgnoreCase(body, "cli")) return .cli;
    if (std.ascii.eqlIgnoreCase(body, "s") or std.ascii.eqlIgnoreCase(body, "silent")) return .silent;
    if (std.ascii.eqlIgnoreCase(body, "y") or std.ascii.eqlIgnoreCase(body, "yes")) return .auto_yes;
    if (std.ascii.eqlIgnoreCase(body, "dx11")) return .dx11;
    if (std.ascii.eqlIgnoreCase(body, "wm") or
        std.ascii.eqlIgnoreCase(body, "fwm") or
        std.ascii.eqlIgnoreCase(body, "force-wine-mode"))
        return .force_wine_mode;
    if (std.ascii.eqlIgnoreCase(body, "am") or std.ascii.eqlIgnoreCase(body, "allow-minimize")) return .allow_minimize;
    if (std.ascii.eqlIgnoreCase(body, "efmi")) return .efmi;
    if (std.ascii.eqlIgnoreCase(body, "gp") or std.ascii.eqlIgnoreCase(body, "game-path")) return .game_path;
    return .unknown;
}

fn isKnownArg(arg: []const u8) bool {
    return classifyArg(arg) != .unknown;
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

fn pathExistsWtf8(wtf8_path: []const u8) bool {
    var path_buf: [std.Io.Dir.max_path_bytes]u16 = undefined;
    const path_w = c.wtf8ToWtf16LeZ(wtf8_path, &path_buf) catch return false;
    return c.GetFileAttributesW(path_w.ptr) != c.INVALID_FILE_ATTRIBUTES;
}

pub fn resolveDefaultEfmiLauncherPath(allocator: std.mem.Allocator, environ: std.process.Environ) !?[]u8 {
    var appdata_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const appdata = c.getEnvironmentVariableWtf8(environ, "APPDATA", &appdata_buf) orelse return null;

    var path_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const path = c.appendNormalizedPath(&path_buf, appdata, EFMI_DEFAULT_SUBPATH) catch return null;
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

        switch (classifyArg(arg)) {
            .cli => {
                config.cli = true;
                continue;
            },
            .silent => {
                config.silent = true;
                continue;
            },
            .auto_yes => {
                config.auto_yes = true;
                continue;
            },
            .dx11 => {
                config.dx11 = true;
                continue;
            },
            .force_wine_mode => {
                const value = args_it.next() orelse return error.MissingForceWineModeValue;
                switch (classifyArg(value)) {
                    .cli => {
                        config.cli = true;
                        continue;
                    },
                    .silent => {
                        config.silent = true;
                        continue;
                    },
                    else => {},
                }
                config.wine_mode_override = parseBoolOverrideValue(value) orelse return error.InvalidForceWineModeValue;
                continue;
            },
            .allow_minimize => {
                const value = args_it.next() orelse return error.MissingAllowMinimizeValue;
                config.allow_minimize_override = parseBoolOverrideValue(value) orelse return error.InvalidAllowMinimizeValue;
                continue;
            },
            .game_path => {
                const value = args_it.next() orelse return error.MissingGamePathValue;
                if (isKnownArg(value)) return error.MissingGamePathValue;
                if (!loader.validateGameExeOverridePath(value)) return error.InvalidGamePathValue;
                if (config.game_exe_override_path) |old_path| allocator.free(old_path);
                config.game_exe_override_path = try allocator.dupe(u8, value);
                continue;
            },
            .efmi => {
                if (config.efmi_launcher_path) |old_path| allocator.free(old_path);
                config.efmi_launcher_path = null;
                config.efmi_requested = true;
                config.efmi_search_enabled = true;

                const maybe_value = args_it.next();
                if (maybe_value) |value| {
                    if (isKnownArg(value)) {
                        pending_arg = value;
                        config.efmi_launcher_path = try resolveDefaultEfmiLauncherPath(allocator, environ);
                    } else if (parseBoolOverrideValue(value)) |enabled| {
                        switch (enabled) {
                            .on => {
                                config.efmi_launcher_path = try resolveDefaultEfmiLauncherPath(allocator, environ);
                            },
                            .off => {
                                config.efmi_requested = false;
                                config.efmi_search_enabled = false;
                            },
                            .auto => unreachable,
                        }
                    } else {
                        config.efmi_launcher_path = try allocator.dupe(u8, value);
                    }
                } else {
                    config.efmi_launcher_path = try resolveDefaultEfmiLauncherPath(allocator, environ);
                }
            },
            .unknown => {},
        }
    }

    if (config.silent and !config.cli) {
        config.cli = true;
    }
    if (config.cli and config.dx11 and config.efmi_requested) {
        return error.MutuallyExclusiveDx11AndEfmi;
    }
    if (config.cli and config.efmi_requested and config.game_exe_override_path != null) {
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

    return try c.wtf16LeToWtf8Slice(wide_buf[0..wide_len], out_buf);
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

pub fn describeEfmiLaunchError(err: loader.LaunchError) []const u8 {
    return switch (err) {
        error.ExecutableNotFound => "The path to XXMI is invalid.",
        error.AccessDenied => "Windows denied access to the EFMI launcher.",
        error.InvalidExecutablePath => "The path to XXMI is invalid.",
        error.CreateProcessFailed => "Windows failed to start the EFMI launcher.",
    };
}

pub fn launchEfmiLauncher(efmi_launcher_path: []const u8) loader.LaunchError!void {
    var path_buf: [std.Io.Dir.max_path_bytes]u16 = undefined;
    const launcher_path_w = c.wtf8ToWtf16LeZ(efmi_launcher_path, &path_buf) catch return error.InvalidExecutablePath;

    var command_line_utf8_buf: [std.Io.Dir.max_path_bytes + 32]u8 = undefined;
    const command_line_utf8 = std.fmt.bufPrint(&command_line_utf8_buf, "\"{s}\" --nogui --xxmi EFMI", .{efmi_launcher_path}) catch return error.InvalidExecutablePath;

    var command_line_wide_buf: [std.Io.Dir.max_path_bytes + 32]u16 = undefined;
    const command_line_wide = c.wtf8ToWtf16LeZ(command_line_utf8, &command_line_wide_buf) catch return error.InvalidExecutablePath;

    const process_info = try loader.createProcessWide(
        launcher_path_w.ptr,
        command_line_wide.ptr,
    );
    loader.closeProcessInformation(&process_info);
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
