const std = @import("std");
const app_version = @import("version.zig");
const loader = @import("loader.zig");

pub const label_launch = "Launch Game";
pub const label_minimize = "Minimize on Launch";
pub const label_stay_open = "Stay open on Launch";
pub const ui_toggle_labels_subset = label_minimize ++ "\n" ++ label_stay_open;

pub const version_release_fmt = "v{s}.{s}.{s}";
pub const version_preview_fmt = "v{s}.{s}.{s} PREVIEW {s}";

pub const status_waiting_for_target_fmt = "Waiting for {s}...";
pub const status_countdown_fmt = "{s} in {d} second{s}...";
pub const countdown_action_minimize = "Minimizing";
pub const countdown_action_close = "Closing";

pub const status_game_found = "Game found!";
pub const status_launch_here_or_external = "You can now launch the game here or externally.";
pub const status_game_not_found = "Game not found.";
pub const status_launch_externally = "Please launch the game externally.";
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
pub const status_launching_game = "Launching game...";

fn appendLine(list: *std.ArrayListUnmanaged(u8), allocator: std.mem.Allocator, line: []const u8) !void {
    try list.appendSlice(allocator, line);
    try list.append(allocator, '\n');
}

pub fn computeVersionDisplay(out_buf: []u8, version_str: []const u8) ![]const u8 {
    var parts: [4][]const u8 = .{ "", "", "", "" };
    var count: usize = 0;
    var parts_it = std.mem.splitScalar(u8, app_version.trimVersionPrefix(version_str), '.');
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

pub fn buildMonoSubsetText(allocator: std.mem.Allocator, version_str: []const u8) ![]u8 {
    var version_buf: [64]u8 = undefined;
    const version_display = try computeVersionDisplay(&version_buf, version_str);
    var lines: std.ArrayListUnmanaged(u8) = .empty;
    errdefer lines.deinit(allocator);

    try appendLine(&lines, allocator, version_display);
    try appendLine(&lines, allocator, status_game_found);
    try appendLine(&lines, allocator, status_launch_here_or_external);
    try appendLine(&lines, allocator, status_game_not_found);
    try appendLine(&lines, allocator, status_launch_externally);
    try appendLine(&lines, allocator, status_monitor_failed);
    try appendLine(&lines, allocator, status_game_already_running_startup);

    var line_buf: [160]u8 = undefined;
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_waiting_for_target_fmt, .{loader.target_exe_name}));
    try appendLine(&lines, allocator, status_game_process_closed);
    try appendLine(&lines, allocator, "Process found (PID: 0123456789)");
    try appendLine(&lines, allocator, status_extracting_mod);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_prepare_temp_dll_failed_fmt, .{
        loader.describeTempDllError(error.TempFileCreateFailed),
    }));
    try appendLine(&lines, allocator, status_injecting_mod);
    try appendLine(&lines, allocator, status_injected_success);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_injection_failed_fmt, .{
        loader.describeInjectError(error.CreateRemoteThreadFailed),
    }));
    try appendLine(&lines, allocator, status_try_run_admin);
    try appendLine(&lines, allocator, status_minimized);
    try appendLine(&lines, allocator, status_ready_for_injection_again);
    try appendLine(&lines, allocator, status_launch_requested_unavailable);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, status_launch_failed_fmt, .{
        loader.describeLaunchError(error.CreateProcessFailed),
    }));
    try appendLine(&lines, allocator, status_launching_game);
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, "{s} in 0123456789 second...", .{countdown_action_minimize}));
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, "{s} in 0123456789 seconds...", .{countdown_action_minimize}));
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, "{s} in 0123456789 second...", .{countdown_action_close}));
    try appendLine(&lines, allocator, try std.fmt.bufPrint(&line_buf, "{s} in 0123456789 seconds...", .{countdown_action_close}));

    try appendLine(&lines, allocator, loader.describeTempDllError(error.OutOfMemory));
    try appendLine(&lines, allocator, loader.describeTempDllError(error.TempPathUnavailable));
    try appendLine(&lines, allocator, loader.describeTempDllError(error.TempFileCreateFailed));
    try appendLine(&lines, allocator, loader.describeTempDllError(error.TempFileWriteFailed));

    try appendLine(&lines, allocator, loader.describeInjectError(error.InvalidPid));
    try appendLine(&lines, allocator, loader.describeInjectError(error.BadDllPath));
    try appendLine(&lines, allocator, loader.describeInjectError(error.OpenProcessFailed));
    try appendLine(&lines, allocator, loader.describeInjectError(error.AllocateRemoteMemoryFailed));
    try appendLine(&lines, allocator, loader.describeInjectError(error.WriteRemoteMemoryFailed));
    try appendLine(&lines, allocator, loader.describeInjectError(error.Kernel32NotFound));
    try appendLine(&lines, allocator, loader.describeInjectError(error.LoadLibraryNotFound));
    try appendLine(&lines, allocator, loader.describeInjectError(error.CreateRemoteThreadFailed));
    try appendLine(&lines, allocator, loader.describeInjectError(error.RemoteThreadWaitFailed));
    try appendLine(&lines, allocator, loader.describeInjectError(error.RemoteThreadWaitTimedOut));
    try appendLine(&lines, allocator, loader.describeInjectError(error.GetRemoteThreadExitCodeFailed));
    try appendLine(&lines, allocator, loader.describeInjectError(error.LoadLibraryRemoteFailed));

    try appendLine(&lines, allocator, loader.describeLaunchError(error.ExecutableNotFound));
    try appendLine(&lines, allocator, loader.describeLaunchError(error.AccessDenied));
    try appendLine(&lines, allocator, loader.describeLaunchError(error.InvalidExecutablePath));
    try appendLine(&lines, allocator, loader.describeLaunchError(error.CreateProcessFailed));
    try lines.appendSlice(allocator, "0123456789");

    return try lines.toOwnedSlice(allocator);
}
