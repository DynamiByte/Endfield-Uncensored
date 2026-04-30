// User-facing text and GUI font subset inputs.
// I intent on potentially supporting multiple languages in the future,
// likely by shipping seperate binaries for each language.
// If I did that, I'd make a build argument to define which locale to use, with an ALL option or something.
const std = @import("std");

// Application/window text
pub const app_title = "Endfield Uncensored";

// GUI labels
pub const label_launch = "Launch Game";
pub const label_minimize = "Minimize on Launch";
pub const label_stay_open = "Stay open on Launch";
pub const label_efmi = "EF\nMI";

// GUI version display text
pub const version_release_fmt = "v{s}.{s}.{s}";
pub const version_preview_fmt = "v{s}.{s}.{s} PREVIEW {s}";

// GUI textbox/status text
pub const status_waiting_for_target_fmt = "Waiting for {s}...";
pub const status_countdown_one_fmt = "{s} in {d} second...";
pub const status_countdown_many_fmt = "{s} in {d} seconds...";
pub const countdown_action_minimize = "Minimizing";
pub const countdown_action_close = "Closing";

pub const status_game_found = "Game found!";
pub const status_launch_here_or_external = "You can now launch the game here or externally...";
pub const status_game_not_found = "Game not found.";
pub const status_launch_externally = "Please launch the game externally...";
pub const status_monitor_failed = "Background game monitor failed to start.";
pub const status_game_process_closed = "Game process closed. Ready.";
pub const status_game_already_running_startup = "The game is already running! The mod can only be applied at startup!";
pub const status_process_found_fmt = "Process found (PID: {d})";
pub const status_extracting_mod = "Extracting mod to temp...";
pub const status_prepare_temp_dll_failed_fmt = "Failed to prepare temp DLL: {s}";
pub const status_injecting_mod = "Injecting mod...";
pub const status_injected_success = "Injected successfully!";
pub const status_injection_failed_fmt = "Injection failed: {s}";
pub const status_try_run_admin = "Try running as administrator.";
pub const status_minimized = "Minimized.";
pub const status_ready_for_injection_again = "Ready for injection again.";
pub const status_launch_requested_unavailable = "Launch requested, but the game path is unavailable.";
pub const status_launch_failed_fmt = "Failed to launch game: {s}";
pub const status_efmi_missing_path = "EFMI path unavailable.";
pub const status_efmi_launch_failed_fmt = "Failed to launch EFMI: {s}";
pub const status_launching_efmi = "Launching EFMI...";
pub const status_launching_game = "Launching game...";
pub const status_launching_game_dx11 = "Launching game in DX11...";
pub const status_launching_game_vulkan = "Launching game in Vulkan...";

// User-visible loader error descriptions. These can be shown by both GUI and CLI.
pub const temp_dll_out_of_memory = "The loader ran out of memory while preparing the temporary DLL.";
pub const temp_dll_temp_path_unavailable = "Windows did not provide a usable temp directory.";
pub const temp_dll_create_failed = "Failed to create the temporary DLL file.";
pub const temp_dll_write_failed = "Failed to write the temporary DLL file.";
pub const temp_dll_unknown = "Unknown temporary DLL error.";

pub const inject_invalid_pid = "No target process was provided.";
pub const inject_bad_dll_path = "The temporary DLL path could not be encoded for Windows.";
pub const inject_open_process_failed = "Failed to open the target process.";
pub const inject_allocate_remote_memory_failed = "Failed to allocate memory inside the target process.";
pub const inject_write_remote_memory_failed = "Failed to write the DLL path into the target process.";
pub const inject_kernel32_not_found = "Could not find kernel32.dll in the current process.";
pub const inject_load_library_not_found = "Could not locate LoadLibraryW.";
pub const inject_create_remote_thread_failed = "Failed to start the remote loader thread.";
pub const inject_remote_thread_wait_failed = "The remote loader thread could not be waited on.";
pub const inject_remote_thread_wait_timed_out = "The remote loader thread timed out.";
pub const inject_get_remote_thread_exit_code_failed = "Could not read the remote loader thread exit code.";
pub const inject_load_library_remote_failed = "The target process failed to load the DLL.";
pub const inject_unknown = "Unknown injection error.";

pub const launch_executable_not_found = "The game executable could not be found.";
pub const launch_access_denied = "Windows denied access to the game executable.";
pub const launch_invalid_executable_path = "The game executable path is not valid.";
pub const launch_create_process_failed = "Windows failed to start the game process.";
pub const launch_unknown = "Unknown game launch error.";

pub const efmi_launch_executable_not_found = "The path to XXMI is invalid.";
pub const efmi_launch_access_denied = "Windows denied access to the EFMI launcher.";
pub const efmi_launch_invalid_executable_path = "The path to XXMI is invalid.";
pub const efmi_launch_create_process_failed = "Windows failed to start the EFMI launcher.";
pub const efmi_launch_unknown = "Unknown EFMI launch error.";

pub fn describeTempDllError(err: anyerror) []const u8 {
    return switch (err) {
        error.OutOfMemory => temp_dll_out_of_memory,
        error.TempPathUnavailable => temp_dll_temp_path_unavailable,
        error.TempFileCreateFailed => temp_dll_create_failed,
        error.TempFileWriteFailed => temp_dll_write_failed,
        else => temp_dll_unknown,
    };
}

pub fn describeInjectError(err: anyerror) []const u8 {
    return switch (err) {
        error.InvalidPid => inject_invalid_pid,
        error.BadDllPath => inject_bad_dll_path,
        error.OpenProcessFailed => inject_open_process_failed,
        error.AllocateRemoteMemoryFailed => inject_allocate_remote_memory_failed,
        error.WriteRemoteMemoryFailed => inject_write_remote_memory_failed,
        error.Kernel32NotFound => inject_kernel32_not_found,
        error.LoadLibraryNotFound => inject_load_library_not_found,
        error.CreateRemoteThreadFailed => inject_create_remote_thread_failed,
        error.RemoteThreadWaitFailed => inject_remote_thread_wait_failed,
        error.RemoteThreadWaitTimedOut => inject_remote_thread_wait_timed_out,
        error.GetRemoteThreadExitCodeFailed => inject_get_remote_thread_exit_code_failed,
        error.LoadLibraryRemoteFailed => inject_load_library_remote_failed,
        else => inject_unknown,
    };
}

pub fn describeLaunchError(err: anyerror) []const u8 {
    return switch (err) {
        error.ExecutableNotFound => launch_executable_not_found,
        error.AccessDenied => launch_access_denied,
        error.InvalidExecutablePath => launch_invalid_executable_path,
        error.CreateProcessFailed => launch_create_process_failed,
        else => launch_unknown,
    };
}

pub fn describeEfmiLaunchError(err: anyerror) []const u8 {
    return switch (err) {
        error.ExecutableNotFound => efmi_launch_executable_not_found,
        error.AccessDenied => efmi_launch_access_denied,
        error.InvalidExecutablePath => efmi_launch_invalid_executable_path,
        error.CreateProcessFailed => efmi_launch_create_process_failed,
        else => efmi_launch_unknown,
    };
}

// CLI-only user-facing text. This section is intentionally not consumed by GUI
// font subset builders.
pub const cli = struct {
    pub const console_title = "Endfield Uncensored CLI";
    pub const efmi_missing_path_message = "You need to specify a location with --EFMI <PATH_TO_XXMI Launcher.exe>.";
    pub const bool_override_usage = "Use on/off, yes/no, true/false, y/n, or t/f.";

    pub const parse_missing_force_wine_mode_value = "Missing value for --force-wine-mode. " ++ bool_override_usage;
    pub const parse_invalid_force_wine_mode_value = "Invalid value for --force-wine-mode. " ++ bool_override_usage;
    pub const parse_missing_allow_minimize_value = "Missing value for --allow-minimize. " ++ bool_override_usage;
    pub const parse_invalid_allow_minimize_value = "Invalid value for --allow-minimize. " ++ bool_override_usage;
    pub const parse_missing_game_path_value = "Missing value for --game-path. Pass a path to Endfield.exe.";
    pub const parse_invalid_game_path_value = "Invalid value for --game-path. It must point to an existing .exe file.";
    pub const parse_mutually_exclusive_dx11_and_efmi = "-DX11 is mutually exclusive with -EFMI.";
    pub const parse_mutually_exclusive_game_path_and_efmi = "--game-path is mutually exclusive with --EFMI.";
    pub const parse_mutually_exclusive_auto_yes_and_gui = "-y and -yes are mutually exclusive with GUI mode.";
    pub const parse_mutually_exclusive_cli_and_gui_args = "CLI arguments are mutually exclusive with GUI-only arguments.";
    pub const parse_unknown = "Unknown argument error.";
    pub const parse_oom = "Not enough memory to parse command line.";

    pub const header_fmt = "\n[EFU Loader {s}]\n\n";
    pub const process_found_fmt = "Process found (PID: {d})\n";
    pub const process_path_fmt = "Process path: {s}\n";
    pub const process_path_warning = "Warning: Could not get process path\n";
    pub const injection_failed_fmt = "Injection failed: {s}\n";
    pub const injection_failed_elevation_fmt = "Injection failed: {s}\nTry running as administrator.";
    pub const injection_failed_fallback = "Injection failed.";
    pub const injection_successful = "Injection successful.\n\n";
    pub const closing_in_5_seconds = "Closing in 5 seconds...\n";
    pub const silent_mode_failed = "Silent mode failed.";
    pub const launch_ready_prompt = "Press L to launch game. Press Q to quit.\n";
    pub const quit_prompt = "Press Q to quit.\n";
    pub const waiting_for_target_fmt = "Waiting for {s}...\n\n";
    pub const launch_failed_fmt = "Launch failed: {s}\n\n";
    pub const launch_failed_plain_fmt = "Launch failed: {s}";
    pub const silent_missing_game_path_fmt = "{s}\nYou cannot use silent mode when the game path cannot be found.";
    pub const error_fmt = "Error: {s}";
    pub const error_line_fmt = "Error: {s}\n";
    pub const efmi_launch_failed_fmt = "EFMI launch failed: {s}";
    pub const efmi_launch_failed_line_fmt = "EFMI launch failed: {s}\n";
    pub const efmi_timeout = "EFMI timeout.";
    pub const efmi_timeout_line = "EFMI timeout.\n";
    pub const xxmi_found = "XXMI found.\n";
    pub const location_fmt = "Location: {s}\n\n";
    pub const efmi_launch_prompt = "Press Y to launch XXMI. Press Q to quit.\n";
    pub const launching_efmi_line = "Launching EFMI...\n";
    pub const xxmi_not_found_default = "XXMI was not found in the default location.";
    pub const xxmi_not_found_default_line = "XXMI was not found in the default location.\n";
    pub const xxmi_not_found_default_fmt = "XXMI was not found in the default location.\n{s}";
    pub const launch_info_prompt = "Press L for launch info. Press Q to quit.\n";
    pub const waiting_for_game_close = "Waiting for the game to close...\n\n";
    pub const ready_line = "Ready.\n";

    pub fn describeParseArgsError(err: anyerror) []const u8 {
        return switch (err) {
            error.MissingForceWineModeValue => parse_missing_force_wine_mode_value,
            error.InvalidForceWineModeValue => parse_invalid_force_wine_mode_value,
            error.MissingAllowMinimizeValue => parse_missing_allow_minimize_value,
            error.InvalidAllowMinimizeValue => parse_invalid_allow_minimize_value,
            error.MissingGamePathValue => parse_missing_game_path_value,
            error.InvalidGamePathValue => parse_invalid_game_path_value,
            error.MutuallyExclusiveDx11AndEfmi => parse_mutually_exclusive_dx11_and_efmi,
            error.MutuallyExclusiveGamePathAndEfmi => parse_mutually_exclusive_game_path_and_efmi,
            error.MutuallyExclusiveAutoYesAndGui => parse_mutually_exclusive_auto_yes_and_gui,
            error.MutuallyExclusiveCliAndGuiArgs => parse_mutually_exclusive_cli_and_gui_args,
            else => parse_unknown,
        };
    }
};

fn appendLine(list: *std.ArrayListUnmanaged(u8), allocator: std.mem.Allocator, line: []const u8) !void {
    try list.appendSlice(allocator, line);
    try list.append(allocator, '\n');
}

fn appendSubsetLabel(list: *std.ArrayListUnmanaged(u8), allocator: std.mem.Allocator, label: []const u8) !void {
    for (label) |ch| {
        if (ch == '\n' or ch == '\r') continue;
        try list.append(allocator, ch);
    }
}

fn hasVersionPrefix(version: []const u8) bool {
    return version.len > 0 and (version[0] == 'v' or version[0] == 'V');
}

fn trimVersionPrefix(version: []const u8) []const u8 {
    return if (hasVersionPrefix(version)) version[1..] else version;
}

// Version display text
pub fn computeVersionDisplay(out_buf: []u8, version_str: []const u8) ![]const u8 {
    var parts: [4][]const u8 = .{ "", "", "", "" };
    var count: usize = 0;
    var parts_it = std.mem.splitScalar(u8, trimVersionPrefix(version_str), '.');
    while (parts_it.next()) |part| {
        if (count == parts.len) break;
        parts[count] = part;
        count += 1;
    }

    return switch (count) {
        4 => try std.fmt.bufPrint(out_buf, version_preview_fmt, .{ parts[0], parts[1], parts[2], parts[3] }),
        3 => try std.fmt.bufPrint(out_buf, version_release_fmt, .{ parts[0], parts[1], parts[2] }),
        else => version_str,
    };
}

// Font subset text: only include strings actually drawn with each GUI font.
pub fn buildToggleLabelSubsetText(allocator: std.mem.Allocator) ![]u8 {
    var text: std.ArrayListUnmanaged(u8) = .empty;
    errdefer text.deinit(allocator);

    try appendSubsetLabel(&text, allocator, label_minimize);
    try appendSubsetLabel(&text, allocator, label_stay_open);
    try appendSubsetLabel(&text, allocator, label_efmi);
    return try text.toOwnedSlice(allocator);
}

pub fn buildVersionInfoSubsetText(allocator: std.mem.Allocator, version_str: []const u8) ![]u8 {
    var version_buf: [64]u8 = undefined;
    const version_display = try computeVersionDisplay(&version_buf, version_str);
    return try allocator.dupe(u8, version_display);
}

pub fn buildTextboxSubsetText(allocator: std.mem.Allocator) ![]u8 {
    const subset_sample_target_exe_name = "Endfield.exe";
    var lines: std.ArrayListUnmanaged(u8) = .empty;
    errdefer lines.deinit(allocator);

    try appendLine(&lines, allocator, status_game_found);
    try appendLine(&lines, allocator, status_launch_here_or_external);
    try appendLine(&lines, allocator, status_game_not_found);
    try appendLine(&lines, allocator, status_launch_externally);
    try appendLine(&lines, allocator, status_monitor_failed);
    try appendLine(&lines, allocator, status_game_already_running_startup);

    var line_buf: [192]u8 = undefined;
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_waiting_for_target_fmt, .{subset_sample_target_exe_name}));
    try appendLine(&lines, allocator, status_game_process_closed);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_process_found_fmt, .{1234567890}));
    try appendLine(&lines, allocator, status_extracting_mod);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_prepare_temp_dll_failed_fmt, .{describeTempDllError(error.TempFileCreateFailed)}));
    try appendLine(&lines, allocator, status_injecting_mod);
    try appendLine(&lines, allocator, status_injected_success);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_injection_failed_fmt, .{describeInjectError(error.CreateRemoteThreadFailed)}));
    try appendLine(&lines, allocator, status_try_run_admin);
    try appendLine(&lines, allocator, status_minimized);
    try appendLine(&lines, allocator, status_ready_for_injection_again);
    try appendLine(&lines, allocator, status_launch_requested_unavailable);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_launch_failed_fmt, .{describeLaunchError(error.CreateProcessFailed)}));
    try appendLine(&lines, allocator, status_efmi_missing_path);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_efmi_launch_failed_fmt, .{describeEfmiLaunchError(error.CreateProcessFailed)}));
    try appendLine(&lines, allocator, status_launching_efmi);
    try appendLine(&lines, allocator, status_launching_game);
    try appendLine(&lines, allocator, status_launching_game_dx11);
    try appendLine(&lines, allocator, status_launching_game_vulkan);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_countdown_one_fmt, .{ countdown_action_minimize, 1234567890 }));
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_countdown_many_fmt, .{ countdown_action_minimize, 1234567890 }));
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_countdown_one_fmt, .{ countdown_action_close, 1234567890 }));
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_countdown_many_fmt, .{ countdown_action_close, 1234567890 }));

    try appendLine(&lines, allocator, describeTempDllError(error.OutOfMemory));
    try appendLine(&lines, allocator, describeTempDllError(error.TempPathUnavailable));
    try appendLine(&lines, allocator, describeTempDllError(error.TempFileCreateFailed));
    try appendLine(&lines, allocator, describeTempDllError(error.TempFileWriteFailed));

    try appendLine(&lines, allocator, describeInjectError(error.InvalidPid));
    try appendLine(&lines, allocator, describeInjectError(error.BadDllPath));
    try appendLine(&lines, allocator, describeInjectError(error.OpenProcessFailed));
    try appendLine(&lines, allocator, describeInjectError(error.AllocateRemoteMemoryFailed));
    try appendLine(&lines, allocator, describeInjectError(error.WriteRemoteMemoryFailed));
    try appendLine(&lines, allocator, describeInjectError(error.Kernel32NotFound));
    try appendLine(&lines, allocator, describeInjectError(error.LoadLibraryNotFound));
    try appendLine(&lines, allocator, describeInjectError(error.CreateRemoteThreadFailed));
    try appendLine(&lines, allocator, describeInjectError(error.RemoteThreadWaitFailed));
    try appendLine(&lines, allocator, describeInjectError(error.RemoteThreadWaitTimedOut));
    try appendLine(&lines, allocator, describeInjectError(error.GetRemoteThreadExitCodeFailed));
    try appendLine(&lines, allocator, describeInjectError(error.LoadLibraryRemoteFailed));

    try appendLine(&lines, allocator, describeLaunchError(error.ExecutableNotFound));
    try appendLine(&lines, allocator, describeLaunchError(error.AccessDenied));
    try appendLine(&lines, allocator, describeLaunchError(error.InvalidExecutablePath));
    try appendLine(&lines, allocator, describeLaunchError(error.CreateProcessFailed));

    try appendLine(&lines, allocator, describeEfmiLaunchError(error.ExecutableNotFound));
    try appendLine(&lines, allocator, describeEfmiLaunchError(error.AccessDenied));
    try appendLine(&lines, allocator, describeEfmiLaunchError(error.InvalidExecutablePath));
    try appendLine(&lines, allocator, describeEfmiLaunchError(error.CreateProcessFailed));

    try lines.appendSlice(allocator, "0123456789");

    return try lines.toOwnedSlice(allocator);
}
