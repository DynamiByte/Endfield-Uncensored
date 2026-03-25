const std = @import("std");

// Module Imports
const bytegui = @import("bytegui.zig");
const loader = @import("loader.zig");
const app_version = @import("version.zig");

// Platform Imports
pub const c = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", {});
    @cDefine("NOMINMAX", {});
    @cDefine("UNICODE", {});
    @cDefine("_UNICODE", {});
    @cInclude("windows.h");
    @cInclude("wtypes.h");
    @cInclude("d3d11.h");
    @cInclude("dxgi1_3.h");
    @cInclude("gdiplus.h");
});

const allocator = std.heap.c_allocator;

const ByteGui = bytegui.ByteGui;
const ByteGuiStyle = bytegui.ByteGuiStyle;
const ByteGuiStyleVar_Alpha = bytegui.ByteGuiStyleVar_Alpha;
const ByteGuiWindowFlags_NoBackground = bytegui.ByteGuiWindowFlags_NoBackground;
const ByteGuiWindowFlags_NoDecoration = bytegui.ByteGuiWindowFlags_NoDecoration;
const ByteGuiWindowFlags_NoMove = bytegui.ByteGuiWindowFlags_NoMove;
const ByteGuiWindowFlags_NoNav = bytegui.ByteGuiWindowFlags_NoNav;
const ByteGuiWindowFlags_NoResize = bytegui.ByteGuiWindowFlags_NoResize;
const ByteGuiWindowFlags_NoSavedSettings = bytegui.ByteGuiWindowFlags_NoSavedSettings;
const ByteGuiWindowFlags_NoScrollbar = bytegui.ByteGuiWindowFlags_NoScrollbar;
const ByteGuiWindowFlags_NoScrollWithMouse = bytegui.ByteGuiWindowFlags_NoScrollWithMouse;
const ByteDrawList = bytegui.ByteDrawList;
const ByteFont = bytegui.ByteFont;
const ByteFontConfig = bytegui.ByteFontConfig;
const Ui = bytegui.Ui;
const ByteGuiPlatformWindowConfig = bytegui.ByteGuiPlatformWindowConfig;
const ByteU32 = bytegui.ByteU32;
const ByteVec2 = bytegui.ByteVec2;
const ByteVec4 = bytegui.ByteVec4;
const bgc = bytegui.c;
const TextTexture = Ui.TextTexture;

// UI Constants And Embedded Assets
const VERSION_STR = app_version.version_str;
const APP_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored");
const WINDOW_CLASS = std.unicode.utf8ToUtf16LeStringLiteral("EndfieldUncensoredDComp");
const README_URL = std.unicode.utf8ToUtf16LeStringLiteral("https://github.com/DynamiByte/Endfield-Uncensored/blob/master/README.md");
const SEGOE_UI = std.unicode.utf8ToUtf16LeStringLiteral("Segoe UI");
const IMPACT = std.unicode.utf8ToUtf16LeStringLiteral("Impact");
const LABEL_LAUNCH = std.unicode.utf8ToUtf16LeStringLiteral("Launch Game");
const LABEL_MINIMIZE = std.unicode.utf8ToUtf16LeStringLiteral("Minimize on Launch");
const APP_ICON_RESOURCE_ID: u16 = 1;

const WINDOW_WIDTH = 500;
const WINDOW_HEIGHT = 200;
const CORNER_RADIUS = 15;
const WINDOW_SLIDE_IN_OFFSET = 80.0;
const WINDOW_SLIDE_IN_DURATION = 0.70;
const WINDOW_SLIDE_OUT_OFFSET = 80.0;
const WINDOW_SLIDE_OUT_DURATION = 0.30;

const CLOSE_X = 465.0;
const CLOSE_Y = 2.0;
const CLOSE_W = 30.0;
const CLOSE_H = 30.0;
const CLOSE_Y_OFFSET = 1.8;

const MIN_X = 443.0;
const MIN_Y = 0.0;
const MIN_W = 17.0;
const MIN_H = 32.0;
const MIN_Y_OFFSET = 1.5;

const INFO_X = 7.0;
const INFO_Y = 7.0;
const INFO_W = 20.0;
const INFO_H = 20.0;

const OUTPUT_X = 252.0;
const OUTPUT_Y = 42.0;
const OUTPUT_W = 224.0;
const OUTPUT_H = 115.0;

const VERSION_X = 10.0;
const VERSION_Y = 175.0;

const TOGGLE_X = 290.0;
const TOGGLE_Y = 10.0;
const TOGGLE_W = 140.0;
const TOGGLE_H = 22.0;
const TOGGLE_Y_OFFSET = -1.3;

const LAUNCH_X = 347.0;
const LAUNCH_Y = 150.0;
const LAUNCH_W = 136.0;
const LAUNCH_H = 35.0;

const DRAG_THRESHOLD = 12;
const PROCESS_POLL_MS: u64 = 175;
const LOGO_CANVAS_X = 62.0;
const LOGO_CANVAS_Y = 52.0;
const LOGO_CANVAS_W = 190.0;
const LOGO_CANVAS_H = 100.0;
const LOGO_SUPERSAMPLE = 2.0;
const BUTTON_LABEL_SUPERSAMPLE = 4.0;
const IDC_ARROW_ID: u16 = 32512;
const IDC_HAND_ID: u16 = 32649;
const embedded_dll = @embedFile("EFUHook");
const LOGO_SVG_PATH = "M3.37,13.25h7.9V9.68H3.37V7.37H9.68L11.46,5.6V3.82H0V19.45H11.6V15.81H3.37ZM7.52,1.18h.23l.36.62h.52L8.2,1.1A.51.51,0,0,0,8.53.59C8.53.16,8.19,0,7.77,0H7.05V1.8h.47Zm0-.81h.21c.22,0,.34,0,.34.22S8,.84,7.73.84H7.52ZM0,37H3.38V30.8H11V27.24H3.38v-2.3h7.8V21.41H0ZM.59,1.4h.58l.12.4h.49L1.17,0H.61L0,1.8H.48ZM.73.92C.78.74.83.54.88.35h0c0,.18.1.39.15.57l0,.15H.68Zm54.69.55a.82.82,0,0,1-.48-.18l-.27.29a1.19,1.19,0,0,0,.74.26c.47,0,.74-.26.74-.56A.49.49,0,0,0,55.77.8L55.52.71c-.17-.06-.3-.1-.3-.2s.09-.15.24-.15a.67.67,0,0,1,.4.14L56.1.23A1,1,0,0,0,55.46,0c-.42,0-.71.24-.71.54a.52.52,0,0,0,.39.48l.26.1c.16.06.27.09.27.2S55.59,1.47,55.42,1.47ZM12.46,37h3.39V26.09H12.5l3.35-3.34V21.41H12.46ZM21.35,1.22c0-.22,0-.46-.06-.66h0l.19.39L22,1.8h.48V0H22V.62a6.26,6.26,0,0,0,.06.65h0L21.87.88,21.38,0H20.9V1.8h.45ZM28.45,0H28V1.8h.48ZM39.34,19a6.45,6.45,0,0,0,2.22-1.22A5.88,5.88,0,0,0,42.9,16a7.87,7.87,0,0,0,.69-2,11.46,11.46,0,0,0,.18-2.09v-.63a11,11,0,0,0-.14-1.77,9.85,9.85,0,0,0-.45-1.69,4.78,4.78,0,0,0-.89-1.55A7.34,7.34,0,0,0,40.89,5a6.33,6.33,0,0,0-2-.85,12.06,12.06,0,0,0-2.74-.29H28.9V19.45h7.21A9.93,9.93,0,0,0,39.34,19Zm-7-3.28H28.94l3.36-3.36V7.52h3.54c2.91,0,4.36,1.33,4.36,4v.12q0,4-4.36,4ZM41.42,1.08h.65V1.8h.46V0h-.46V.71h-.65V0H41V1.8h.47Zm7,.72h.47V.39h.53V0H47.9V.39h.53Zm-13.59,0a1,1,0,0,0,.65-.22V.79h-.73v.35h.32v.29a.53.53,0,0,1-.19,0,.49.49,0,0,1-.54-.56.5.5,0,0,1,.5-.55.53.53,0,0,1,.36.14l.25-.27A.91.91,0,0,0,34.83,0a.91.91,0,0,0-1,.93A.88.88,0,0,0,34.84,1.84Zm-20.39-.5.21-.26.46.72h.52L14.93.74l.6-.71H15l-.56.7h0V0H14V1.8h.48Zm6.46,29.43h7.9V27.2h-7.9V24.88h6.33L29,23.13v-1.8H17.55V37h11.6V33.33H20.91Zm38.47,0h-.09v.12h.09ZM27.18,16.12V3.87H23.82v9.81L16.9,3.87H13.12v15.6h3.35V9.14l7.35,10.33ZM59.38,31h-.09v.13h.09Zm.56,0h-.18v.11h.18Zm8.89,2H66.91v.46h1.57v.74H66.91v.15l1.82,1.26v-.36l.5-.18V33.68h-.4ZM58.64,21.41V36.9h15.5V21.41Zm3.56,9.26h.22a.56.56,0,0,0,0-.12h.2l-.07.11h.32V31H63v.15h-.13v.25c0,.07,0,.11-.06.13a.36.36,0,0,1-.19,0,.42.42,0,0,0,0-.15h.1s0,0,0,0v-.24h-.39a.64.64,0,0,1-.2.42.63.63,0,0,0-.12-.11.52.52,0,0,0,.16-.31h-.14V31h.15Zm.38.75a.73.73,0,0,0-.18-.16l.1-.08a.55.55,0,0,1,.19.14Zm-1.51-.55v-.15h.45a.75.75,0,0,0-.06-.13l.16-.06s.06.12.08.16l-.08,0h.44v.15h-.55a.37.37,0,0,1,0,.11H62v.07c0,.29,0,.41-.09.46a.2.2,0,0,1-.13.06h-.19a.32.32,0,0,0-.06-.15h.24s0-.11.06-.28h-.32a.65.65,0,0,1-.31.46.45.45,0,0,0-.11-.13.61.61,0,0,0,.28-.59Zm-.87-.26H61v1h-.17V31.5h-.45v.07H60.2Zm-.59,0h.48v.82c0,.08,0,.12-.06.14a.38.38,0,0,1-.2,0,.47.47,0,0,0-.06-.15h.14s0,0,0,0v-.17h-.2a.54.54,0,0,1-.18.35.58.58,0,0,0-.12-.1.61.61,0,0,0,.17-.5Zm-.47,0h.38v.67h-.23v.09h-.15Zm0,2.74L60,31.76h.92l-1.23,2.33h-.57Zm2,2.84-2,.4v-.7l2-.41Zm12.79.41H71.45l-.72-.37V34.37l-.42.16v-.85h-.24v1l.46-.17v1l-1.62.6v.44l-2-1.42v1.38H66V35.21L64,36.6H62.82l-1.67-1.19.62-.46,1.65,1.14L66,34.31v-.15H64.41v-.74H66V33h-2v.18l-.86.6,1,.64v.88l-1.6-1.1-1.47,1v.12l-1.92.41v-.25l1.6-2.76H61l.68-.91h.9l-.32.43H66v-.46h.92v.46h2v.72h.27V32h.84v.94h.46v.6l.2-.08V32.29h.84v.85l.21-.08v-1.3h.84v1l1-.4v2.54l-.84.35V33.57l-.21.08V35.3l-.84.35V34l-.21.08v1.78h2.32Zm-12-1.78.63-.46.86.59v.92Zm.59-1.5L63,33H61.89Zm-2.5-2.58h-.18v.11h.18Zm1.14,3.07h-.21l-.43.83.38-.09v-.1l1-.72-.47-.32ZM42.62,33.2h0ZM34.05,21.39H30.66V37H41.59V33.11H34.05Zm22.86,3.87A4.74,4.74,0,0,0,56,23.72a6.75,6.75,0,0,0-1.4-1.24,6.06,6.06,0,0,0-2-.85,11.64,11.64,0,0,0-2.75-.3h-7.2V33.19l3.4-3.4V25h3.54q4.36,0,4.36,4v.13q0,4-4.36,4H42.63V37h7.22a9.91,9.91,0,0,0,3.22-.48,6.29,6.29,0,0,0,2.22-1.22,5.84,5.84,0,0,0,1.34-1.78,7.62,7.62,0,0,0,.69-2,11.54,11.54,0,0,0,.18-2.09v-.63A11.17,11.17,0,0,0,57.36,27,9.43,9.43,0,0,0,56.91,25.26Zm3.91,5.51h-.45V31h.45Zm0,.36h-.45v.21h.45Zm1.59-.23.1-.08h-.15V31h.19A.55.55,0,0,0,62.41,30.9Zm.17.12h.16v-.2h-.22a.61.61,0,0,1,.15.12Z";

// UI Animation And Loader State

const ScalarAnim = struct {
    value: f32 = 0.0,
    start: f32 = 0.0,
    target: f32 = 0.0,
    elapsed: f32 = 0.0,
    duration: f32 = 0.18,
    animating: bool = false,
};

const ColorAnim = struct {
    start: ByteVec4 = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 1.0 },
    current: ByteVec4 = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 1.0 },
    target: ByteVec4 = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 1.0 },
    elapsed: f32 = 0.0,
    duration: f32 = 0.12,
    animating: bool = false,
};

const WindowAnimType = enum {
    none,
    slide_in,
    slide_out_close,
    fade_out_minimize,
    fade_in_restore,
};

const WindowAnim = struct {
    typ: WindowAnimType = .none,
    elapsed: f32 = 0.0,
    duration: f32 = 0.0,
    start_pos: c.POINT = std.mem.zeroes(c.POINT),
    end_pos: c.POINT = std.mem.zeroes(c.POINT),
    start_opacity: f32 = 1.0,
    end_opacity: f32 = 1.0,
};

const CloseCountdown = struct {
    const Action = enum {
        close,
        minimize,
    };

    active: bool = false,
    action: Action = .close,
    remaining_seconds: i32 = 0,
    elapsed: f32 = 0.0,
};

const LoaderUiEvent = union(enum) {
    clear_status: void,
    status_line: []u8,
    replace_last_status_line: []u8,
    process_closed: void,
    minimize_after_inject: void,
    close_after_inject: void,
};

const ThreadMutex = if (@hasDecl(std.Thread, "Mutex"))
    std.Thread.Mutex
else
    struct {
        pub fn lock(_: *@This()) void {}
        pub fn unlock(_: *@This()) void {}
    };

const LoaderWorkerState = struct {
    tracked_pid: u32 = 0,
    last_failed_pid: u32 = 0,
    temp_dll_path: ?[:0]u16 = null,

    fn deinit(self: *LoaderWorkerState) void {
        if (self.temp_dll_path) |path| allocator.free(path);
        self.* = .{};
    }
};

extern "user32" fn LoadCursorW(h_instance: c.HINSTANCE, cursor_name: ?*anyopaque) callconv(.winapi) c.HCURSOR;
extern "shell32" fn ShellExecuteW(hwnd: c.HWND, operation: [*:0]const u16, file: [*:0]const u16, parameters: ?[*:0]const u16, directory: ?[*:0]const u16, show_cmd: c.INT) callconv(.winapi) c.HINSTANCE;

var g_hwnd: ?c.HWND = null;
var g_running = true;
var g_window_opacity: f32 = 0.0;

var g_font_ui: ?*ByteFont = null;
var g_font_ui_bold: ?*ByteFont = null;
var g_font_console: ?*ByteFont = null;
var g_font_version: ?*ByteFont = null;
var g_font_launch: ?*ByteFont = null;
var g_font_launch_hover: ?*ByteFont = null;
var g_font_launch_peak: ?*ByteFont = null;
var g_font_toggle: ?*ByteFont = null;
var g_font_toggle_hover: ?*ByteFont = null;
var g_font_toggle_peak: ?*ByteFont = null;
var g_font_impact: ?*ByteFont = null;

var g_logo_texture: ?*bgc.ID3D11ShaderResourceView = null;
var g_logo_origin_px: ByteVec2 = .{};
var g_logo_size_px: ByteVec2 = .{};
var g_launch_label_texture: TextTexture = .{};
var g_toggle_label_texture: TextTexture = .{};

var g_output_lines: std.ArrayListUnmanaged([]u8) = .{};
var g_minimize_on_launch = false;
var g_minimized_by_toggle = false;
var g_game_exe_path: ?[:0]u16 = null;
var g_launch_btn_enabled = false;
var g_version_display: []u8 = &.{};
var g_loader_thread: ?std.Thread = null;
var g_loader_control_mutex: ThreadMutex = .{};
var g_loader_events_mutex: ThreadMutex = .{};
var g_loader_should_stop = false;
var g_loader_minimize_on_launch = false;
var g_loader_events: std.ArrayListUnmanaged(LoaderUiEvent) = .{};

var g_hovered_button: i32 = 0;
var g_pressed_button: i32 = 0;
var g_press_captured = false;
var g_press_canceled = false;
var g_dragging = false;
var g_press_screen: c.POINT = std.mem.zeroes(c.POINT);
var g_press_rect: c.RECT = std.mem.zeroes(c.RECT);
var g_drag_offset: c.POINT = std.mem.zeroes(c.POINT);
var g_was_minimized = false;

var g_window_anim: WindowAnim = .{};
var g_close_countdown: CloseCountdown = .{};
var g_launch_anim: ScalarAnim = .{};
var g_toggle_anim: ScalarAnim = .{};
var g_button_colors = [_]ColorAnim{.{}} ** 5;
var g_toggle_current_color = ByteVec4{ .x = 220.0 / 255.0, .y = 220.0 / 255.0, .z = 220.0 / 255.0, .w = 1.0 };

const kControlIdleColor = ByteVec4{ .x = 51.0 / 255.0, .y = 51.0 / 255.0, .z = 51.0 / 255.0, .w = 1.0 };
const kControlHoverBlue = ByteVec4{ .x = 100.0 / 255.0, .y = 149.0 / 255.0, .z = 237.0 / 255.0, .w = 1.0 };
const clamp01 = Ui.Clamp01;
const easeOutQuad = Ui.EaseOutQuad;
const easeInOutCubic = Ui.EaseInOutCubic;
const lerpColor = Ui.LerpColor;
const applyOpacity = Ui.ApplyOpacity;
const toU32 = Ui.ColorToU32;
const scaleF = Ui.ScaleF;
const scaleI = Ui.ScaleI;
const scaleIF = Ui.ScaleIF;
const scaleVec2 = Ui.ScaleVec2;
const snapPixel = Ui.SnapPixel;
const snapPixelVec2 = Ui.SnapPixelVec2;

fn makeRectL(x: f32, y: f32, w: f32, h: f32) c.RECT {
    return .{
        .left = @intFromFloat(@floor(x)),
        .top = @intFromFloat(@floor(y)),
        .right = @intFromFloat(@ceil(x + w)),
        .bottom = @intFromFloat(@ceil(y + h)),
    };
}

fn pointInRect(rect: anytype, pt: c.POINT) bool {
    return pt.x >= rect.left and pt.x < rect.right and pt.y >= rect.top and pt.y < rect.bottom;
}

fn lowWordSigned(value: c.LPARAM) i32 {
    const bits: usize = @bitCast(value);
    const lo: u16 = @truncate(bits & 0xFFFF);
    return @as(i16, @bitCast(lo));
}

fn highWordSigned(value: c.LPARAM) i32 {
    const bits: usize = @bitCast(value);
    const hi: u16 = @truncate((bits >> 16) & 0xFFFF);
    return @as(i16, @bitCast(hi));
}

fn lowWordU(value: c.LPARAM) u16 {
    const bits: usize = @bitCast(value);
    return @truncate(bits & 0xFFFF);
}

fn highWordU(value: c.LPARAM) u16 {
    const bits: usize = @bitCast(value);
    return @truncate((bits >> 16) & 0xFFFF);
}

fn wideToUtf8Alloc(wide: [:0]const u16) ![]u8 {
    return std.unicode.utf16LeToUtf8Alloc(allocator, wide[0..wide.len]);
}

fn computeVersionDisplay() ![]u8 {
    var trimmed: []const u8 = VERSION_STR;
    if (trimmed.len > 0 and (trimmed[0] == 'v' or trimmed[0] == 'V')) trimmed = trimmed[1..];

    var parts_it = std.mem.splitScalar(u8, trimmed, '.');
    var parts: [4][]const u8 = undefined;
    var count: usize = 0;
    while (parts_it.next()) |part| {
        if (count == parts.len) break;
        parts[count] = part;
        count += 1;
    }

    return switch (count) {
        4 => std.fmt.allocPrint(allocator, "v{s}.{s}.{s} PREVIEW {s}", .{ parts[0], parts[1], parts[2], parts[3] }),
        3 => std.fmt.allocPrint(allocator, "v{s}.{s}.{s}", .{ parts[0], parts[1], parts[2] }),
        else => allocator.dupe(u8, VERSION_STR),
    };
}

fn toByteGuiHwnd(hwnd: c.HWND) bgc.HWND {
    return @ptrCast(hwnd);
}

fn fromByteGuiHwnd(hwnd: ?bgc.HWND) ?c.HWND {
    return if (hwnd) |value| @ptrCast(value) else null;
}

fn loadCursorResource(id: u16) c.HCURSOR {
    return LoadCursorW(null, @ptrFromInt(@as(usize, id)));
}

fn fromByteGuiRect(rect: bgc.RECT) c.RECT {
    return .{
        .left = rect.left,
        .top = rect.top,
        .right = rect.right,
        .bottom = rect.bottom,
    };
}

// CLI Mode
const CLI_CONSOLE_TITLE = std.unicode.utf8ToUtf16LeStringLiteral("Endfield Uncensored CLI");

fn shouldRunCli(args: std.process.Args) bool {
    var args_it = std.process.Args.Iterator.initAllocator(args, allocator) catch return false;
    defer args_it.deinit();

    _ = args_it.next();
    while (args_it.next()) |arg| {
        if (std.ascii.eqlIgnoreCase(arg, "-cli") or
            std.ascii.eqlIgnoreCase(arg, "--cli") or
            std.ascii.eqlIgnoreCase(arg, "/cli"))
        {
            return true;
        }
    }

    return false;
}

fn ensureCliConsole() void {
    _ = c.FreeConsole();
    if (c.AllocConsole() == 0) return;
    _ = c.SetConsoleTitleW(CLI_CONSOLE_TITLE);
}

fn cliWrite(message: []const u8) void {
    const stdout_handle = c.GetStdHandle(c.STD_OUTPUT_HANDLE);
    if (stdout_handle == null or stdout_handle == c.INVALID_HANDLE_VALUE) return;

    var bytes_written: c.DWORD = 0;
    _ = c.WriteFile(stdout_handle, message.ptr, @intCast(message.len), &bytes_written, null);
}

fn cliPrint(comptime fmt: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    const message = std.fmt.bufPrint(&buf, fmt, args) catch return;
    cliWrite(message);
}

fn getProcessPathUtf8Alloc(pid: u32) !?[]u8 {
    if (pid == 0) return null;

    const process = c.OpenProcess(c.PROCESS_QUERY_LIMITED_INFORMATION, c.FALSE, pid) orelse return null;
    defer _ = c.CloseHandle(process);

    var wide_buf: [32768]u16 = undefined;
    var wide_len: c.DWORD = wide_buf.len - 1;
    if (c.QueryFullProcessImageNameW(process, 0, wide_buf[0..].ptr, &wide_len) == 0 or wide_len == 0) return null;

    return @as(?[]u8, try std.unicode.utf16LeToUtf8Alloc(allocator, wide_buf[0..wide_len]));
}

fn runCli() !u8 {
    ensureCliConsole();
    cliPrint("\n[EFU Loader]\n\n", .{});

    const temp_dll_path = loader.writeEmbeddedDllToTemp(allocator, embedded_dll) catch {
        cliPrint("Error: Failed to create temp DLL.\n", .{});
        cliPrint("Closing in 5 seconds...\n", .{});
        c.Sleep(5000);
        return 1;
    };
    defer allocator.free(temp_dll_path);

    cliPrint("Ready.\nWaiting for {s}...\n\n", .{loader.target_exe_name});

    var pid: u32 = 0;
    while (pid == 0) {
        pid = loader.findTargetProcess();
        if (pid == 0) c.Sleep(100);
    }

    cliPrint("Process found (PID: {d})\n", .{pid});

    if (try getProcessPathUtf8Alloc(pid)) |path| {
        defer allocator.free(path);
        cliPrint("Process path: {s}\n", .{path});
    } else {
        cliPrint("Warning: Could not get process path\n", .{});
    }

    c.Sleep(10);

    const injected = loader.injectDll(pid, temp_dll_path);
    if (injected) {
        cliPrint("Injection successful.\n\n", .{});
    } else {
        cliPrint("Injection failed.\n", .{});
        cliPrint("Maybe you didn't run as admin?\n\n", .{});
    }

    cliPrint("Closing in 5 seconds...\n", .{});
    c.Sleep(5000);
    return if (injected) 0 else 1;
}

// Status Output
fn appendStatus(comptime fmt: []const u8, args: anytype) void {
    const line = std.fmt.allocPrint(allocator, fmt, args) catch return;
    appendOwnedStatusLine(line);
}

fn appendWaitingForTargetExeStatus() void {
    appendStatus("Waiting for {s}...", .{loader.target_exe_name});
}

fn appendOwnedStatusLine(line: []u8) void {
    g_output_lines.append(allocator, line) catch allocator.free(line);
}

fn setLastOwnedStatusLine(line: []u8) void {
    if (g_output_lines.items.len == 0) {
        appendOwnedStatusLine(line);
        return;
    }

    const last_index = g_output_lines.items.len - 1;
    allocator.free(g_output_lines.items[last_index]);
    g_output_lines.items[last_index] = line;
}

fn clearStatusLines() void {
    for (g_output_lines.items) |line| allocator.free(line);
    g_output_lines.deinit(allocator);
    g_output_lines = .{};
}

fn cancelCloseCountdown() void {
    g_close_countdown = .{};
}

fn makeCountdownStatusLine(action: CloseCountdown.Action, seconds_remaining: i32) ?[]u8 {
    return std.fmt.allocPrint(allocator, "{s} in {d} second{s}...", .{
        if (action == .minimize) "Minimizing" else "Closing",
        seconds_remaining,
        if (seconds_remaining == 1) "" else "s",
    }) catch null;
}

fn appendCountdownStatus(action: CloseCountdown.Action, seconds_remaining: i32) void {
    const line = makeCountdownStatusLine(action, seconds_remaining) orelse return;
    setLastOwnedStatusLine(line);
}

fn startCloseCountdown() void {
    g_close_countdown = .{
        .active = true,
        .action = .close,
        .remaining_seconds = 5,
        .elapsed = 0.0,
    };
    const line = makeCountdownStatusLine(g_close_countdown.action, g_close_countdown.remaining_seconds) orelse return;
    appendOwnedStatusLine(line);
}

fn startMinimizeCountdown() void {
    g_close_countdown = .{
        .active = true,
        .action = .minimize,
        .remaining_seconds = 5,
        .elapsed = 0.0,
    };
    const line = makeCountdownStatusLine(g_close_countdown.action, g_close_countdown.remaining_seconds) orelse return;
    appendOwnedStatusLine(line);
}

// Loader Worker
fn queueLoaderEvent(event: LoaderUiEvent) void {
    g_loader_events_mutex.lock();
    defer g_loader_events_mutex.unlock();
    g_loader_events.append(allocator, event) catch switch (event) {
        .status_line => |line| allocator.free(line),
        else => {},
    };
}

fn queueLoaderStatus(comptime fmt: []const u8, args: anytype) void {
    const line = std.fmt.allocPrint(allocator, fmt, args) catch return;
    queueLoaderEvent(.{ .status_line = line });
}

fn queueLoaderReplaceLastStatus(comptime fmt: []const u8, args: anytype) void {
    const line = std.fmt.allocPrint(allocator, fmt, args) catch return;
    queueLoaderEvent(.{ .replace_last_status_line = line });
}

fn drainLoaderEvents() void {
    var pending: std.ArrayListUnmanaged(LoaderUiEvent) = .{};
    g_loader_events_mutex.lock();
    std.mem.swap(std.ArrayListUnmanaged(LoaderUiEvent), &pending, &g_loader_events);
    g_loader_events_mutex.unlock();
    defer pending.deinit(allocator);

    for (pending.items) |event| {
        switch (event) {
            .clear_status => clearStatusLines(),
            .status_line => |line| appendOwnedStatusLine(line),
            .replace_last_status_line => |line| setLastOwnedStatusLine(line),
            .process_closed => maybeRestoreAfterExit(),
            .minimize_after_inject => {
                g_minimized_by_toggle = true;
                if (g_window_anim.typ == .none) startMinimizeCountdown();
            },
            .close_after_inject => {
                if (g_window_anim.typ == .none) startCloseCountdown();
            },
        }
    }
}

fn clearLoaderEvents() void {
    var pending: std.ArrayListUnmanaged(LoaderUiEvent) = .{};
    g_loader_events_mutex.lock();
    std.mem.swap(std.ArrayListUnmanaged(LoaderUiEvent), &pending, &g_loader_events);
    g_loader_events_mutex.unlock();
    defer pending.deinit(allocator);

    for (pending.items) |event| {
        switch (event) {
            .status_line => |line| allocator.free(line),
            .replace_last_status_line => |line| allocator.free(line),
            else => {},
        }
    }
}

fn setLoaderMinimizeOnLaunch(enabled: bool) void {
    g_minimize_on_launch = enabled;
    g_loader_control_mutex.lock();
    g_loader_minimize_on_launch = enabled;
    g_loader_control_mutex.unlock();
}

fn loaderMinimizeOnLaunch() bool {
    g_loader_control_mutex.lock();
    defer g_loader_control_mutex.unlock();
    return g_loader_minimize_on_launch;
}

fn ensureWorkerTempDll(state: *LoaderWorkerState) ![:0]u16 {
    if (state.temp_dll_path) |path| return path;
    const path = try loader.writeEmbeddedDllToTemp(allocator, embedded_dll);
    state.temp_dll_path = path;
    return path;
}

fn loaderWorkerTick(state: *LoaderWorkerState) void {
    if (state.tracked_pid != 0) {
        if (!loader.isProcessAlive(state.tracked_pid)) {
            queueLoaderStatus("Game process closed. Ready again.", .{});
            state.tracked_pid = 0;
            state.last_failed_pid = 0;
            queueLoaderEvent(.{ .process_closed = {} });
        }
        return;
    }

    const pid = loader.findTargetProcess();
    if (pid == 0) {
        state.last_failed_pid = 0;
        return;
    }
    if (pid == state.last_failed_pid) return;

    queueLoaderEvent(.{ .clear_status = {} });
    queueLoaderStatus("Process found (PID: {d})", .{pid});
    queueLoaderStatus("Extracting mod to temp...", .{});
    const temp_path = ensureWorkerTempDll(state) catch {
        queueLoaderStatus("Failed to create temp DLL.", .{});
        state.last_failed_pid = pid;
        return;
    };

    queueLoaderStatus("Injecting mod...", .{});
    if (loader.injectDll(pid, temp_path)) {
        queueLoaderReplaceLastStatus("Injected successfully!", .{});
        state.tracked_pid = pid;
        state.last_failed_pid = 0;
        if (loaderMinimizeOnLaunch()) {
            queueLoaderEvent(.{ .minimize_after_inject = {} });
        } else {
            queueLoaderEvent(.{ .close_after_inject = {} });
        }
    } else {
        queueLoaderReplaceLastStatus("Injection failed.", .{});
        queueLoaderStatus("Maybe you didn't run as admin?", .{});
        state.last_failed_pid = pid;
    }
}

fn loaderWorkerMain() void {
    var state = LoaderWorkerState{};
    defer state.deinit();

    while (true) {
        g_loader_control_mutex.lock();
        const should_stop = g_loader_should_stop;
        g_loader_control_mutex.unlock();
        if (should_stop) break;

        loaderWorkerTick(&state);
        c.Sleep(@intCast(PROCESS_POLL_MS));
    }
}

fn startLoaderWorker() bool {
    g_loader_control_mutex.lock();
    g_loader_should_stop = false;
    g_loader_minimize_on_launch = g_minimize_on_launch;
    g_loader_control_mutex.unlock();

    g_loader_thread = std.Thread.spawn(.{}, loaderWorkerMain, .{}) catch return false;
    return true;
}

fn stopLoaderWorker() void {
    if (g_loader_thread) |thread| {
        g_loader_control_mutex.lock();
        g_loader_should_stop = true;
        g_loader_control_mutex.unlock();
        thread.join();
        g_loader_thread = null;
    }
}

// Render Resources
fn cleanupLogoTexture() void {
    Ui.CleanupTexture(&g_logo_texture);
    g_logo_origin_px = .{};
    g_logo_size_px = .{};
}

fn cleanupButtonLabelTextures() void {
    Ui.CleanupTextTexture(&g_launch_label_texture);
    Ui.CleanupTextTexture(&g_toggle_label_texture);
}

fn rebuildButtonLabelTextures() bool {
    const launch_ok = Ui.BuildTextTexture(&g_launch_label_texture, LABEL_LAUNCH, SEGOE_UI, c.FontStyleBold, 24.0, BUTTON_LABEL_SUPERSAMPLE, 0.9, 1.0);
    const toggle_ok = Ui.BuildTextTexture(&g_toggle_label_texture, LABEL_MINIMIZE, SEGOE_UI, c.FontStyleRegular, 20.0, BUTTON_LABEL_SUPERSAMPLE, 0.45, 1.0);
    return launch_ok and toggle_ok;
}

fn rebuildLogoTexture() bool {
    cleanupLogoTexture();
    return Ui.BuildSvgTexture(&g_logo_texture, &g_logo_origin_px, &g_logo_size_px, .{
        .svg_path = LOGO_SVG_PATH,
        .canvas_pos = .{ .x = LOGO_CANVAS_X, .y = LOGO_CANVAS_Y },
        .canvas_size = .{ .x = LOGO_CANVAS_W, .y = LOGO_CANVAS_H },
        .supersample = LOGO_SUPERSAMPLE,
        .fill_argb = 0xFF000000,
        .text = std.unicode.utf8ToUtf16LeStringLiteral("UNCENSORED"),
        .text_family = IMPACT,
        .text_style = c.FontStyleBold,
        .text_em_size = 36.0,
        .logo_scale = .{ .x = 2.211, .y = 2.211 },
        .logo_translate = .{ .x = 75.0 / 2.211, .y = 55.0 / 2.211 },
        .text_scale = .{ .x = 0.8405, .y = 0.20 },
        .text_translate = .{ .x = 68.75 / 0.8405, .y = 136.0 / 0.20 },
    });
}

fn cleanupDeviceD3D() void {
    cleanupLogoTexture();
    cleanupButtonLabelTextures();
    bytegui.ByteGui_ImplDX11_ShutdownComposition();
}

fn applyBaseStyle() void {
    const style = ByteGui.GetStyle();
    style.* = ByteGuiStyle{};
    style.WindowPadding = .{};
    style.FramePadding = .{};
    style.ItemSpacing = .{};
    style.ItemInnerSpacing = .{};
    style.WindowBorderSize = 0.0;
    style.ChildBorderSize = 0.0;
    style.FrameBorderSize = 0.0;
    style.PopupBorderSize = 0.0;
    style.WindowRounding = 0.0;
    style.ChildRounding = 0.0;
    style.FrameRounding = 0.0;
    style.ScrollbarRounding = scaleF(8.0);
    style.ScrollbarSize = scaleF(8.0);
    style.AntiAliasedFill = true;
    style.AntiAliasedLines = true;
    style.CurveTessellationTol = 0.8;
    style.CircleTessellationMaxError = 0.10;

    style.Colors[bytegui.ByteGuiCol_WindowBg] = .{};
    style.Colors[bytegui.ByteGuiCol_ChildBg] = .{};
    style.Colors[bytegui.ByteGuiCol_Text] = .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 };
    style.Colors[bytegui.ByteGuiCol_Border] = .{};
    style.Colors[bytegui.ByteGuiCol_ScrollbarBg] = .{};
    style.Colors[bytegui.ByteGuiCol_ScrollbarGrab] = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.35 };
    style.Colors[bytegui.ByteGuiCol_ScrollbarGrabHovered] = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.55 };
    style.Colors[bytegui.ByteGuiCol_ScrollbarGrabActive] = .{ .x = 0.2, .y = 0.2, .z = 0.2, .w = 0.75 };
}

fn loadFonts() void {
    const io = ByteGui.GetIO();
    io.Fonts.?.Clear();

    const segoe = "C:\\Windows\\Fonts\\segoeui.ttf";
    const segoe_bold = "C:\\Windows\\Fonts\\segoeuib.ttf";
    const consola = "C:\\Windows\\Fonts\\consola.ttf";
    const impact = "C:\\Windows\\Fonts\\impact.ttf";

    var cfg = ByteFontConfig{};
    cfg.PixelSnapH = true;
    cfg.OversampleH = 2;
    cfg.OversampleV = 1;

    g_font_ui = io.Fonts.?.AddFontFromFileTTF(segoe, scaleF(16.0), &cfg);
    g_font_ui_bold = io.Fonts.?.AddFontFromFileTTF(segoe_bold, scaleF(16.0), &cfg);
    g_font_console = io.Fonts.?.AddFontFromFileTTF(consola, scaleF(13.0), &cfg);
    g_font_version = io.Fonts.?.AddFontFromFileTTF(consola, scaleF(12.0), &cfg);
    g_font_launch = io.Fonts.?.AddFontFromFileTTF(segoe_bold, scaleF(20.0), &cfg);
    g_font_launch_hover = io.Fonts.?.AddFontFromFileTTF(segoe_bold, scaleF(22.0), &cfg);
    g_font_launch_peak = io.Fonts.?.AddFontFromFileTTF(segoe_bold, scaleF(24.0), &cfg);
    g_font_toggle = io.Fonts.?.AddFontFromFileTTF(segoe, scaleF(16.0), &cfg);
    g_font_toggle_hover = io.Fonts.?.AddFontFromFileTTF(segoe, scaleF(17.0), &cfg);
    g_font_toggle_peak = io.Fonts.?.AddFontFromFileTTF(segoe, scaleF(18.0), &cfg);
    g_font_impact = io.Fonts.?.AddFontFromFileTTF(impact, scaleF(36.0), &cfg);

    if (g_font_ui == null) g_font_ui = io.Fonts.?.AddFontDefault();
    if (g_font_ui_bold == null) g_font_ui_bold = g_font_ui;
    if (g_font_console == null) g_font_console = g_font_ui;
    if (g_font_version == null) g_font_version = g_font_console;
    if (g_font_launch == null) g_font_launch = g_font_ui_bold;
    if (g_font_launch_hover == null) g_font_launch_hover = g_font_launch;
    if (g_font_launch_peak == null) g_font_launch_peak = g_font_launch_hover;
    if (g_font_toggle == null) g_font_toggle = g_font_ui;
    if (g_font_toggle_hover == null) g_font_toggle_hover = g_font_toggle;
    if (g_font_toggle_peak == null) g_font_toggle_peak = g_font_toggle_hover;
    if (g_font_impact == null) g_font_impact = g_font_ui_bold;
}

fn refreshUiScaleResources() void {
    if (ByteGui.GetCurrentContext() == null) return;
    applyBaseStyle();
    loadFonts();
    if (bytegui.ByteGui_ImplDX11_GetDevice() != null) {
        _ = rebuildLogoTexture();
        _ = rebuildButtonLabelTextures();
    }
}

// Interaction And Rendering
fn startScalarAnim(anim: *ScalarAnim, target: f32, duration: f32) void {
    if (@abs(anim.value - target) < 0.0001 and !anim.animating) return;
    anim.start = anim.value;
    anim.target = target;
    anim.elapsed = 0.0;
    anim.duration = duration;
    anim.animating = true;
}

fn startButtonColorAnim(id: i32, target: ByteVec4) void {
    if (id < 1 or id > 4) return;
    const anim = &g_button_colors[@intCast(id)];
    anim.start = anim.current;
    anim.target = target;
    anim.elapsed = 0.0;
    anim.duration = 0.12;
    anim.animating = true;
}

fn commitWindowOpacityNow() void {
    const dcomp_device = bytegui.ByteGui_ImplDX11_GetCompositionDevice() orelse return;
    if (bytegui.ByteGui_ImplDX11_GetCompositionVisual3()) |visual| {
        _ = visual.lpVtbl.*.SetOpacity.?(visual, g_window_opacity);
    }
    _ = dcomp_device.lpVtbl.*.Commit.?(dcomp_device);
}

fn startWindowAnimation(typ: WindowAnimType) void {
    const hwnd = g_hwnd orelse return;
    var rc = std.mem.zeroes(c.RECT);
    _ = c.GetWindowRect(hwnd, &rc);

    cancelCloseCountdown();
    g_window_anim = .{ .typ = typ };
    switch (typ) {
        .slide_in => {
            g_window_anim.duration = WINDOW_SLIDE_IN_DURATION;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top + scaleIF(WINDOW_SLIDE_IN_OFFSET) };
            g_window_anim.end_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.start_opacity = 0.0;
            g_window_anim.end_opacity = 1.0;
            _ = c.SetWindowPos(hwnd, null, g_window_anim.start_pos.x, g_window_anim.start_pos.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
            g_window_opacity = 0.0;
            commitWindowOpacityNow();
        },
        .slide_out_close => {
            g_window_anim.duration = WINDOW_SLIDE_OUT_DURATION;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.end_pos = .{ .x = rc.left, .y = rc.top + scaleIF(WINDOW_SLIDE_OUT_OFFSET) };
            g_window_anim.start_opacity = 1.0;
            g_window_anim.end_opacity = 0.0;
        },
        .fade_out_minimize => {
            g_window_anim.duration = 0.200;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.end_pos = g_window_anim.start_pos;
        },
        .fade_in_restore => {
            g_window_anim.duration = 0.300;
            g_window_anim.start_pos = .{ .x = rc.left, .y = rc.top };
            g_window_anim.end_pos = g_window_anim.start_pos;
            g_window_opacity = 0.0;
            commitWindowOpacityNow();
        },
        .none => {},
    }
}

fn updateAnimations(dt: f32) void {
    var i: usize = 1;
    while (i <= 4) : (i += 1) {
        const anim = &g_button_colors[i];
        if (!anim.animating) continue;
        anim.elapsed += dt;
        const t = if (anim.duration > 0.0) anim.elapsed / anim.duration else 1.0;
        if (t >= 1.0) {
            anim.current = anim.target;
            anim.animating = false;
        } else {
            anim.current = lerpColor(anim.start, anim.target, easeOutQuad(t));
        }
    }

    for (&[_]*ScalarAnim{ &g_launch_anim, &g_toggle_anim }) |anim| {
        if (!anim.animating) continue;
        anim.elapsed += dt;
        const t = if (anim.duration > 0.0) anim.elapsed / anim.duration else 1.0;
        if (t >= 1.0) {
            anim.value = anim.target;
            anim.animating = false;
        } else {
            anim.value = anim.start + (anim.target - anim.start) * easeOutQuad(t);
        }
    }

    const toggle_target = if (g_minimize_on_launch)
        ByteVec4{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }
    else
        ByteVec4{ .x = 220.0 / 255.0, .y = 220.0 / 255.0, .z = 220.0 / 255.0, .w = 1.0 };
    g_toggle_current_color = lerpColor(g_toggle_current_color, toggle_target, clamp01(dt * 12.0));

    if (g_close_countdown.active and g_window_anim.typ == .none) {
        g_close_countdown.elapsed += dt;
        while (g_close_countdown.active and g_close_countdown.elapsed >= 1.0) {
            g_close_countdown.elapsed -= 1.0;
            g_close_countdown.remaining_seconds -= 1;
            if (g_close_countdown.remaining_seconds > 0) {
                appendCountdownStatus(g_close_countdown.action, g_close_countdown.remaining_seconds);
            } else {
                const action = g_close_countdown.action;
                cancelCloseCountdown();
                if (g_window_anim.typ == .none) {
                    switch (action) {
                        .close => startWindowAnimation(.slide_out_close),
                        .minimize => startWindowAnimation(.fade_out_minimize),
                    }
                }
            }
        }
    }

    const hwnd = g_hwnd orelse return;
    switch (g_window_anim.typ) {
        .none => {},
        .slide_in => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                g_window_opacity = 1.0;
                _ = c.SetWindowPos(hwnd, null, g_window_anim.end_pos.x, g_window_anim.end_pos.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
                g_window_anim.typ = .none;
            } else {
                const move_t = easeInOutCubic(t);
                const y = @as(i32, @intFromFloat(@round(@as(f32, @floatFromInt(g_window_anim.start_pos.y)) + @as(f32, @floatFromInt(g_window_anim.end_pos.y - g_window_anim.start_pos.y)) * move_t)));
                g_window_opacity = easeOutQuad(t);
                _ = c.SetWindowPos(hwnd, null, g_window_anim.start_pos.x, y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
            }
        },
        .slide_out_close => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                g_window_opacity = 0.0;
                _ = c.SetWindowPos(hwnd, null, g_window_anim.end_pos.x, g_window_anim.end_pos.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
                _ = c.DestroyWindow(hwnd);
                g_window_anim.typ = .none;
            } else {
                const move_t = easeInOutCubic(t);
                const fade_t = easeOutQuad(t);
                const y = @as(i32, @intFromFloat(@round(@as(f32, @floatFromInt(g_window_anim.start_pos.y)) + @as(f32, @floatFromInt(g_window_anim.end_pos.y - g_window_anim.start_pos.y)) * move_t)));
                g_window_opacity = 1.0 - fade_t;
                _ = c.SetWindowPos(hwnd, null, g_window_anim.start_pos.x, y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
            }
        },
        .fade_out_minimize => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                g_window_opacity = 0.0;
                g_window_anim.typ = .none;
                if (g_minimized_by_toggle) {
                    const line = allocator.dupe(u8, "Minimized.") catch null;
                    if (line) |owned_line| setLastOwnedStatusLine(owned_line);
                }
                _ = c.ShowWindow(hwnd, c.SW_MINIMIZE);
            } else {
                g_window_opacity = 1.0 - t;
            }
        },
        .fade_in_restore => {
            g_window_anim.elapsed += dt;
            const t = if (g_window_anim.duration > 0.0) g_window_anim.elapsed / g_window_anim.duration else 1.0;
            if (t >= 1.0) {
                g_window_opacity = 1.0;
                g_window_anim.typ = .none;
            } else {
                g_window_opacity = t;
            }
        },
    }
}

fn pointInRoundedRectClient(pt: c.POINT) bool {
    return Ui.PointInCornerOnlyRoundedRect(
        .{ .x = pt.x, .y = pt.y },
        .{},
        .{
            .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()),
            .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()),
        },
        @floatFromInt(scaleI(CORNER_RADIUS)),
    );
}

fn getVersionRect() bgc.RECT {
    const font = if (g_font_version != null) g_font_version else g_font_console;
    const pos = snapPixelVec2(scaleVec2(VERSION_X, VERSION_Y));
    return ByteGui.CalcTextHitRect(font, scaleF(12.0), pos, g_version_display, scaleF(3.0), null, 0.0);
}

fn getInfoRect() c.RECT {
    const hit_padding = scaleF(4.0);
    var rect = makeRectL(scaleF(INFO_X) - hit_padding, scaleF(INFO_Y) - hit_padding, scaleF(INFO_W) + hit_padding * 2.0, scaleF(INFO_H) + hit_padding * 2.0);
    rect.left = 0;
    rect.top = 0;
    return rect;
}

fn getLaunchRect(expanded_hit: bool) c.RECT {
    const anim = g_launch_anim.value;
    const expand_w = (if (expanded_hit) scaleF(24.0) else scaleF(12.0)) * anim;
    const expand_h = (if (expanded_hit) scaleF(8.0) else scaleF(4.0)) * anim;
    const w = scaleF(LAUNCH_W) + expand_w;
    const h = scaleF(LAUNCH_H) + expand_h;
    const cx = scaleF(LAUNCH_X + LAUNCH_W * 0.5);
    const cy = scaleF(LAUNCH_Y + LAUNCH_H * 0.5);
    return makeRectL(cx - w * 0.5, cy - h * 0.5, w, h);
}

fn getToggleRect(expanded_hit: bool) c.RECT {
    _ = expanded_hit;
    const anim = g_toggle_anim.value;
    const expand_w = scaleF(12.0) * anim;
    const expand_h = scaleF(3.0) * anim;
    const w = scaleF(TOGGLE_W) + expand_w;
    const h = scaleF(TOGGLE_H) + expand_h;
    const cx = scaleF(TOGGLE_X + TOGGLE_W * 0.5);
    const cy = scaleF(TOGGLE_Y + TOGGLE_H * 0.5 + TOGGLE_Y_OFFSET);
    return makeRectL(cx - w * 0.5, cy - h * 0.5, w, h);
}

fn getWindowControlHitRects(min_hit: *bgc.RECT, close_hit: *bgc.RECT) void {
    ByteGui.CalcHorizontalNeighborHitRects(
        scaleVec2(MIN_X, MIN_Y + MIN_Y_OFFSET),
        scaleVec2(MIN_W, MIN_H),
        scaleVec2(CLOSE_X, CLOSE_Y + CLOSE_Y_OFFSET),
        scaleVec2(CLOSE_W, CLOSE_H),
        .{ .x = scaleF(4.0), .y = 0.0, .z = 0.0, .w = 0.0 },
        min_hit,
        close_hit,
    );

    const min_visual_left = scaleF(MIN_X);
    const min_visual_right = scaleF(MIN_X + MIN_W);
    const min_right_extra = @as(f32, @floatFromInt(min_hit.right)) - min_visual_right;
    min_hit.left = @intFromFloat(@floor(min_visual_left - min_right_extra));
    min_hit.top = 0;

    close_hit.top = 0;
    close_hit.right = bytegui.ByteGui_ImplWin32_GetWindowWidth();
}

fn hitTestButton(pt: c.POINT) i32 {
    var close_hit = std.mem.zeroes(bgc.RECT);
    var min_hit = std.mem.zeroes(bgc.RECT);
    getWindowControlHitRects(&min_hit, &close_hit);

    const info_hit = getInfoRect();
    const version_hit = getVersionRect();
    const launch_hit = getLaunchRect(true);
    const toggle_hit = getToggleRect(true);

    if (pointInRect(toggle_hit, pt)) return 6;
    if (pointInRect(close_hit, pt)) return 1;
    if (pointInRect(min_hit, pt)) return 2;
    if (pointInRect(info_hit, pt)) return 3;
    if (pointInRect(version_hit, pt)) return 4;
    if (pointInRect(launch_hit, pt) and g_launch_btn_enabled) return 5;
    return 0;
}

fn updateHoverStates(dt: f32) void {
    _ = dt;
    const hwnd = g_hwnd orelse return;
    var pt = std.mem.zeroes(c.POINT);
    _ = c.GetCursorPos(&pt);
    _ = c.ScreenToClient(hwnd, &pt);

    const prev_hover = g_hovered_button;
    g_hovered_button = if (!pointInRoundedRectClient(pt)) 0 else hitTestButton(pt);
    if (g_hovered_button != prev_hover) {
        if (prev_hover >= 1 and prev_hover <= 4) startButtonColorAnim(prev_hover, kControlIdleColor);
        if (g_hovered_button == 1) {
            startButtonColorAnim(1, .{ .x = 1.0, .y = 127.0 / 255.0, .z = 80.0 / 255.0, .w = 1.0 });
        } else if (g_hovered_button == 2) {
            startButtonColorAnim(2, .{ .x = 218.0 / 255.0, .y = 165.0 / 255.0, .z = 32.0 / 255.0, .w = 1.0 });
        } else if (g_hovered_button == 3 or g_hovered_button == 4) {
            startButtonColorAnim(g_hovered_button, kControlHoverBlue);
        }

        startScalarAnim(&g_launch_anim, if (g_hovered_button == 5) 1.0 else 0.0, 0.18);
        startScalarAnim(&g_toggle_anim, if (g_hovered_button == 6) 1.0 else 0.0, 0.18);
    }

    _ = c.SetCursor(loadCursorResource(if (g_hovered_button == 5 or g_hovered_button == 6) IDC_HAND_ID else IDC_ARROW_ID));
}

fn drawYellowRotatedRect(draw: ?*ByteDrawList, opacity: f32) void {
    const rect_left = scaleF(-95.0);
    const rect_top = scaleF(1.0);
    const rect_width = scaleF(403.0);
    const rect_height = scaleF(194.0);
    const pivot_x = rect_left + rect_width * 0.3;
    const pivot_y = rect_top + rect_height * 0.5;
    const color = toU32(applyOpacity(.{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, opacity));
    Ui.DrawRotatedRectClippedToCornerOnlyRoundedRect(
        draw,
        .{ .x = rect_left, .y = rect_top },
        .{ .x = rect_width, .y = rect_height },
        .{ .x = pivot_x, .y = pivot_y },
        -45.0 * std.math.pi / 180.0,
        .{ .x = 0.0, .y = 0.0 },
        .{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) },
        snapPixel(scaleF(CORNER_RADIUS)),
        color,
        std.math.clamp(scaleIF(6.0), 6, 20),
    );
}

fn selectAnimatedButtonFont(is_launch: bool, anim: f32) ?*ByteFont {
    if (is_launch) {
        if (anim >= 0.67) return if (g_font_launch_peak != null) g_font_launch_peak else g_font_launch;
        if (anim >= 0.34) return if (g_font_launch_hover != null) g_font_launch_hover else g_font_launch;
        return if (g_font_launch != null) g_font_launch else g_font_ui_bold;
    }

    if (anim >= 0.67) return if (g_font_toggle_peak != null) g_font_toggle_peak else g_font_toggle;
    if (anim >= 0.34) return if (g_font_toggle_hover != null) g_font_toggle_hover else g_font_toggle;
    return if (g_font_toggle != null) g_font_toggle else g_font_ui;
}

fn getButtonLabelTexture(is_launch: bool) *const TextTexture {
    return if (is_launch) &g_launch_label_texture else &g_toggle_label_texture;
}

fn drawAnimatedButtonLabelTexture(draw: ?*ByteDrawList, is_launch: bool, pos: ByteVec2, size: ByteVec2, anim: f32, opacity: f32) bool {
    const text_texture = getButtonLabelTexture(is_launch);
    return Ui.DrawAnimatedTextureCentered(
        draw,
        text_texture,
        pos,
        size,
        .{ .x = scaleF(if (is_launch) 6.0 else 1.0), .y = scaleF(if (is_launch) 4.0 else 0.25) },
        if (is_launch) 0.94 else 0.92,
        if (is_launch) 0.98 else 0.94,
        anim,
        opacity,
    );
}

fn drawAnimatedBoxButtonVisual(id: []const u8, label: []const u8, base_pos: ByteVec2, base_size: ByteVec2, anim: f32, enabled: bool, base_color: ByteVec4, opacity: f32) void {
    const is_launch = std.mem.eql(u8, id, "launch_btn");
    const center = ByteVec2{ .x = base_pos.x + base_size.x * 0.5, .y = base_pos.y + base_size.y * 0.5 };
    const size = ByteVec2{ .x = base_size.x + scaleF(12.0) * anim, .y = base_size.y + (if (is_launch) scaleF(4.0) else scaleF(3.0)) * anim };
    const pos = ByteVec2{ .x = center.x - size.x * 0.5, .y = center.y - size.y * 0.5 };
    const color = if (enabled) base_color else ByteVec4{ .x = 180.0 / 255.0, .y = 180.0 / 255.0, .z = 180.0 / 255.0, .w = 1.0 };
    const rounding = if (is_launch) scaleF(8.0) + scaleF(4.0) * anim else scaleF(5.0) + scaleF(2.0) * anim;

    const draw = ByteGui.GetWindowDrawList() orelse return;
    const saved_flags = draw.Flags;
    draw.Flags |= bytegui.ByteDrawListFlags_AntiAliasedFill;
    draw.AddRectFilled(pos, .{ .x = pos.x + size.x, .y = pos.y + size.y }, toU32(applyOpacity(color, opacity)), rounding);
    draw.Flags = saved_flags;
    if (!drawAnimatedButtonLabelTexture(draw, is_launch, pos, size, anim, opacity)) {
        const font = selectAnimatedButtonFont(is_launch, anim);
        const font_size = if (font) |f| f.LegacySize else scaleF(if (is_launch) 20.0 else 16.0);
        ByteGui.DrawTextCentered(draw, font, font_size, pos, size, toU32(applyOpacity(.{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 }, opacity)), label, true);
    }
}

fn drawLogoVisual(draw: ?*ByteDrawList, opacity: f32) void {
    const active_draw = draw orelse return;
    if (g_logo_texture) |texture| {
        active_draw.AddImage(@ptrCast(texture), g_logo_origin_px, .{ .x = g_logo_origin_px.x + g_logo_size_px.x, .y = g_logo_origin_px.y + g_logo_size_px.y }, .{}, .{ .x = 1.0, .y = 1.0 }, toU32(applyOpacity(.{ .x = 1.0, .y = 1.0, .z = 1.0, .w = 1.0 }, opacity)));
        return;
    }

    active_draw.AddText(g_font_ui_bold, scaleF(16.0), snapPixelVec2(scaleVec2(64.0, 66.0)), toU32(applyOpacity(.{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 }, opacity)), "ENDFIELD", null);
    active_draw.AddText(if (g_font_impact != null) g_font_impact else g_font_ui_bold, scaleF(36.0), snapPixelVec2(scaleVec2(67.0, 128.0)), toU32(applyOpacity(.{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 }, opacity)), "UNCENSORED", null);
}

fn drawUI() void {
    const render_opacity: f32 = if (bytegui.ByteGui_ImplDX11_GetCompositionVisual3() != null) 1.0 else g_window_opacity;
    ByteGui.SetNextWindowPos(.{});
    ByteGui.SetNextWindowSize(.{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) });

    const flags: u32 = ByteGuiWindowFlags_NoDecoration | ByteGuiWindowFlags_NoMove | ByteGuiWindowFlags_NoResize | ByteGuiWindowFlags_NoSavedSettings | ByteGuiWindowFlags_NoNav | ByteGuiWindowFlags_NoBackground;
    _ = ByteGui.Begin("##root", null, flags);

    const draw = ByteGui.GetWindowDrawList() orelse return;
    ByteGui.DrawCornerOnlyRoundedRectFilled(draw, .{}, .{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) }, snapPixel(scaleF(CORNER_RADIUS)), toU32(applyOpacity(.{ .x = 1.0, .y = 1.0, .z = 1.0, .w = 1.0 }, render_opacity)), std.math.clamp(scaleIF(6.0), 6, 20));
    drawYellowRotatedRect(draw, render_opacity);

    ByteGui.DrawInfoGlyph(draw, scaleVec2(INFO_X, INFO_Y), scaleVec2(INFO_W, INFO_H), toU32(applyOpacity(g_button_colors[3].current, render_opacity)), toU32(applyOpacity(.{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, render_opacity)), std.math.clamp(scaleIF(72.0), 72, 160));
    ByteGui.DrawWindowControlGlyph(draw, scaleVec2(MIN_X, MIN_Y + MIN_Y_OFFSET), scaleVec2(MIN_W, MIN_H), toU32(applyOpacity(g_button_colors[2].current, render_opacity)), false);
    ByteGui.DrawWindowControlGlyph(draw, scaleVec2(CLOSE_X, CLOSE_Y + CLOSE_Y_OFFSET), scaleVec2(CLOSE_W, CLOSE_H), toU32(applyOpacity(g_button_colors[1].current, render_opacity)), true);
    drawLogoVisual(draw, render_opacity);

    const output_inset = scaleF(1.0);
    const output_pos = scaleVec2(OUTPUT_X, OUTPUT_Y);
    const output_size = scaleVec2(OUTPUT_W, OUTPUT_H);
    ByteGui.SetCursorScreenPos(.{ .x = output_pos.x + output_inset, .y = output_pos.y + output_inset });
    _ = ByteGui.BeginChild("##output", .{
        .x = @max(1.0, output_size.x - output_inset * 2.0),
        .y = @max(1.0, output_size.y - output_inset * 2.0),
    }, false, ByteGuiWindowFlags_NoBackground | ByteGuiWindowFlags_NoScrollbar | ByteGuiWindowFlags_NoScrollWithMouse);
    ByteGui.PushStyleVar(ByteGuiStyleVar_Alpha, render_opacity);
    ByteGui.PushFont(g_font_console);
    for (g_output_lines.items) |line| ByteGui.TextWrapped("{s}", .{line});
    ByteGui.PopFont();
    ByteGui.PopStyleVar(1);
    ByteGui.EndChild();

    draw.AddText(if (g_font_version != null) g_font_version else g_font_console, scaleF(12.0), snapPixelVec2(scaleVec2(VERSION_X, VERSION_Y)), toU32(applyOpacity(g_button_colors[4].current, render_opacity)), g_version_display, null);
    drawAnimatedBoxButtonVisual("toggle_btn", "Minimize on Launch", scaleVec2(TOGGLE_X, TOGGLE_Y + TOGGLE_Y_OFFSET), scaleVec2(TOGGLE_W, TOGGLE_H), g_toggle_anim.value, true, g_toggle_current_color, render_opacity);
    drawAnimatedBoxButtonVisual("launch_btn", "Launch Game", scaleVec2(LAUNCH_X, LAUNCH_Y), scaleVec2(LAUNCH_W, LAUNCH_H), g_launch_anim.value, g_launch_btn_enabled, .{ .x = 1.0, .y = 250.0 / 255.0, .z = 0.0, .w = 1.0 }, render_opacity);

    ByteGui.End();
}

fn refreshGamePathStatus() void {
    if (g_game_exe_path) |path| allocator.free(path);
    g_game_exe_path = loader.detectGameExe(allocator) catch null;
    g_launch_btn_enabled = g_game_exe_path != null;
}

fn maybeRestoreAfterExit() void {
    if (!g_minimized_by_toggle or g_hwnd == null) return;
    if (c.IsIconic(g_hwnd.?) == 0) return;
    cancelCloseCountdown();
    clearStatusLines();
    _ = c.ShowWindow(g_hwnd.?, c.SW_RESTORE);
    appendStatus("Ready for injection again.", .{});
    appendWaitingForTargetExeStatus();
    g_minimized_by_toggle = false;
}

fn launchGameAction() void {
    cancelCloseCountdown();
    if (!g_launch_btn_enabled or g_game_exe_path == null) {
        appendStatus("Launch requested, but the game path is unavailable.", .{});
        return;
    }
    loader.launchGame(g_game_exe_path.?) catch {
        appendStatus("Failed to launch game.", .{});
        return;
    };
    appendStatus("Launching game...", .{});
}

fn openReadme() void {
    _ = ShellExecuteW(null, std.unicode.utf8ToUtf16LeStringLiteral("open"), README_URL, null, null, c.SW_SHOWNORMAL);
}

fn openReleaseTag() void {
    const normalized = if (VERSION_STR.len > 0 and (VERSION_STR[0] == 'v' or VERSION_STR[0] == 'V')) VERSION_STR else "v" ++ VERSION_STR;
    const url_utf8 = std.fmt.allocPrint(allocator, "https://github.com/DynamiByte/Endfield-Uncensored/releases/tag/{s}", .{normalized}) catch return;
    defer allocator.free(url_utf8);
    const url_utf16 = std.unicode.utf8ToUtf16LeAllocZ(allocator, url_utf8) catch return;
    defer allocator.free(url_utf16);
    _ = ShellExecuteW(null, std.unicode.utf8ToUtf16LeStringLiteral("open"), url_utf16.ptr, null, null, c.SW_SHOWNORMAL);
}

// App Lifetime
fn onButtonActivated(id: i32) void {
    switch (id) {
        1 => if (g_window_anim.typ == .none) startWindowAnimation(.slide_out_close),
        2 => if (g_window_anim.typ == .none) startWindowAnimation(.fade_out_minimize),
        3 => openReadme(),
        4 => openReleaseTag(),
        5 => launchGameAction(),
        6 => setLoaderMinimizeOnLaunch(!g_minimize_on_launch),
        else => {},
    }
}

fn handleLButtonDown(hwnd: c.HWND, l_param: c.LPARAM) c.LRESULT {
    const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    if (!pointInRoundedRectClient(pt)) return 0;

    const hit_id = hitTestButton(pt);
    if (hit_id != 0) {
        g_pressed_button = hit_id;
        g_press_captured = true;
        g_press_canceled = false;
        _ = c.GetCursorPos(&g_press_screen);

        var close_hit = std.mem.zeroes(bgc.RECT);
        var min_hit = std.mem.zeroes(bgc.RECT);
        getWindowControlHitRects(&min_hit, &close_hit);

        g_press_rect = switch (hit_id) {
            1 => fromByteGuiRect(close_hit),
            2 => fromByteGuiRect(min_hit),
            3 => getInfoRect(),
            4 => fromByteGuiRect(getVersionRect()),
            5 => getLaunchRect(true),
            6 => getToggleRect(true),
            else => std.mem.zeroes(c.RECT),
        };

        _ = c.SetCapture(hwnd);
        return 0;
    }

    g_dragging = true;
    g_drag_offset = .{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
    _ = c.SetCapture(hwnd);
    return 0;
}

fn handleMouseMove(hwnd: c.HWND) c.LRESULT {
    if (g_dragging) {
        var cur = std.mem.zeroes(c.POINT);
        _ = c.GetCursorPos(&cur);
        _ = c.SetWindowPos(hwnd, null, cur.x - g_drag_offset.x, cur.y - g_drag_offset.y, 0, 0, c.SWP_NOSIZE | c.SWP_NOZORDER | c.SWP_NOACTIVATE);
        return 0;
    }

    if (g_press_captured) {
        var cur = std.mem.zeroes(c.POINT);
        _ = c.GetCursorPos(&cur);
        const dx = @abs(cur.x - g_press_screen.x);
        const dy = @abs(cur.y - g_press_screen.y);
        if (dx >= scaleI(DRAG_THRESHOLD) or dy >= scaleI(DRAG_THRESHOLD)) g_press_canceled = true;
        return 0;
    }
    return -1;
}

fn handleLButtonUp(l_param: c.LPARAM) c.LRESULT {
    if (g_dragging) {
        g_dragging = false;
        _ = c.ReleaseCapture();
        return 0;
    }

    if (g_press_captured) {
        _ = c.ReleaseCapture();
        const pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
        if (!g_press_canceled and c.PtInRect(&g_press_rect, pt) != 0) onButtonActivated(g_pressed_button);
        g_pressed_button = 0;
        g_press_captured = false;
        g_press_canceled = false;
        return 0;
    }
    return -1;
}

fn wndProc(hwnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.winapi) c.LRESULT {
    const active_hwnd = hwnd;

    if (msg == c.WM_NCHITTEST) {
        var pt = c.POINT{ .x = lowWordSigned(l_param), .y = highWordSigned(l_param) };
        _ = c.ScreenToClient(active_hwnd, &pt);
        if (!pointInRoundedRectClient(pt)) return c.HTTRANSPARENT;
        return c.HTCLIENT;
    }

    switch (msg) {
        c.WM_LBUTTONDOWN => return handleLButtonDown(active_hwnd, l_param),
        c.WM_MOUSEMOVE => {
            const result = handleMouseMove(active_hwnd);
            if (result != -1) return result;
        },
        c.WM_LBUTTONUP => {
            const result = handleLButtonUp(l_param);
            if (result != -1) return result;
        },
        c.WM_SIZE => {
            if (w_param == c.SIZE_MINIMIZED) {
                g_was_minimized = true;
            } else {
                const width = lowWordU(l_param);
                const height = highWordU(l_param);
                if (width > 0 and height > 0) bytegui.ByteGui_ImplDX11_ResizeComposition(width, height);
                if (w_param == c.SIZE_RESTORED and g_was_minimized) {
                    g_was_minimized = false;
                    g_window_opacity = 0.0;
                    startWindowAnimation(.fade_in_restore);
                }
            }
            return 0;
        },
        c.WM_DPICHANGED => {
            const old_scale = bytegui.ByteGui_ImplWin32_GetDpiScale();
            if (bytegui.ByteGui_ImplWin32_HandleDpiChanged(w_param, l_param, true)) {
                refreshUiScaleResources();
                if (g_dragging) {
                    const new_scale = bytegui.ByteGui_ImplWin32_GetDpiScale();
                    g_drag_offset.x = @intFromFloat(@ceil(@as(f32, @floatFromInt(g_drag_offset.x)) * (new_scale / old_scale)));
                    g_drag_offset.y = @intFromFloat(@ceil(@as(f32, @floatFromInt(g_drag_offset.y)) * (new_scale / old_scale)));
                }
            }
            return 0;
        },
        c.WM_ERASEBKGND => return 1,
        c.WM_DESTROY => {
            if (g_hwnd != null and g_hwnd.? == active_hwnd) g_hwnd = null;
            g_running = false;
            c.PostQuitMessage(0);
            return 0;
        },
        else => {},
    }

    _ = bytegui.ByteGui_ImplWin32_WndProcHandler(toByteGuiHwnd(active_hwnd), msg, w_param, l_param);
    return c.DefWindowProcW(active_hwnd, msg, w_param, l_param);
}

fn wndProcBridge(hwnd: bgc.HWND, msg: bgc.UINT, w_param: bgc.WPARAM, l_param: bgc.LPARAM) callconv(.winapi) bgc.LRESULT {
    return wndProc(@ptrCast(hwnd), msg, w_param, l_param);
}

noinline fn initGuiApp(instance: c.HINSTANCE) bool {
    bytegui.BYTEGUI_CHECKVERSION();
    _ = ByteGui.CreateContext() orelse {
        return false;
    };

    var window_config = ByteGuiPlatformWindowConfig{};
    window_config.Instance = @ptrCast(instance);
    window_config.WndProc = wndProcBridge;
    window_config.ClassName = WINDOW_CLASS;
    window_config.Title = APP_TITLE;
    window_config.IconResourceId = APP_ICON_RESOURCE_ID;
    window_config.LogicalWidth = WINDOW_WIDTH;
    window_config.LogicalHeight = WINDOW_HEIGHT;
    std.mem.doNotOptimizeAway(window_config);

    if (!bytegui.ByteGui_ImplWin32_CreatePlatformWindow(&window_config)) return false;
    const platform_hwnd = bytegui.ByteGui_ImplWin32_GetPlatformHwnd();
    g_hwnd = fromByteGuiHwnd(platform_hwnd);
    if (!bytegui.ByteGui_ImplDX11_InitComposition(platform_hwnd, @intCast(bytegui.ByteGui_ImplWin32_GetWindowWidth()), @intCast(bytegui.ByteGui_ImplWin32_GetWindowHeight()))) return false;

    const io = ByteGui.GetIO();
    io.IniFilename = null;
    io.LogFilename = null;
    io.DisplaySize = .{ .x = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowWidth()), .y = @floatFromInt(bytegui.ByteGui_ImplWin32_GetWindowHeight()) };

    applyBaseStyle();
    loadFonts();
    _ = bytegui.ByteGui_ImplWin32_Init(platform_hwnd);
    _ = rebuildLogoTexture();
    _ = rebuildButtonLabelTextures();
    refreshGamePathStatus();

    if (g_launch_btn_enabled) {
        appendStatus("Game found!", .{});
        appendStatus("You can now launch the game here or externally.", .{});
        appendWaitingForTargetExeStatus();
    } else {
        appendStatus("Game not found.", .{});
        appendStatus("Please launch the game externally.", .{});
    }
    if (!startLoaderWorker()) {
        appendStatus("Background game monitor failed to start.", .{});
    }

    for (g_button_colors[1..5]) |*color_anim| {
        color_anim.current = kControlIdleColor;
        color_anim.start = kControlIdleColor;
        color_anim.target = kControlIdleColor;
    }

    _ = c.ShowWindow(g_hwnd.?, c.SW_SHOW);
    _ = c.UpdateWindow(g_hwnd.?);
    startWindowAnimation(.slide_in);
    return true;
}

fn shutdownGuiApp() void {
    stopLoaderWorker();
    clearLoaderEvents();
    bytegui.ByteGui_ImplDX11_Shutdown();
    bytegui.ByteGui_ImplWin32_Shutdown();
    cleanupDeviceD3D();
    if (g_hwnd != null) bytegui.ByteGui_ImplWin32_DestroyPlatformWindow();
    if (ByteGui.GetCurrentContext() != null) ByteGui.DestroyContext(null);
    if (g_game_exe_path) |path| allocator.free(path);
    clearStatusLines();
}

fn runGui() !u8 {
    g_version_display = try computeVersionDisplay();
    defer allocator.free(g_version_display);
    if (!initGuiApp(c.GetModuleHandleW(null))) {
        shutdownGuiApp();
        return 1;
    }
    defer shutdownGuiApp();

    var msg = std.mem.zeroes(c.MSG);
    while (g_running) {
        while (c.PeekMessageW(&msg, null, 0, 0, c.PM_REMOVE) != 0) {
            _ = c.TranslateMessage(&msg);
            _ = c.DispatchMessageW(&msg);
            if (msg.message == c.WM_QUIT) g_running = false;
        }
        if (!g_running) break;

        const io = ByteGui.GetIO();
        const dt = if (io.DeltaTime > 0.0) io.DeltaTime else 1.0 / 60.0;
        drainLoaderEvents();
        updateHoverStates(dt);
        updateAnimations(dt);
        if (!g_running or g_hwnd == null) break;

        bytegui.ByteGui_ImplDX11_NewFrame();
        bytegui.ByteGui_ImplWin32_NewFrame();
        ByteGui.NewFrame();
        drawUI();
        ByteGui.Render();

        const clear_color = [4]f32{ 0, 0, 0, 0 };
        _ = bytegui.ByteGui_ImplDX11_BeginCompositionFrame(&clear_color);
        bytegui.ByteGui_ImplDX11_RenderDrawData(ByteGui.GetDrawData());
        _ = bytegui.ByteGui_ImplDX11_PresentComposition(g_window_opacity, 1, 0);
        c.Sleep(1);
    }
    return 0;
}

pub fn main(init: std.process.Init.Minimal) void {
    const code = if (shouldRunCli(init.args))
        runCli() catch 1
    else
        runGui() catch 1;
    std.process.exit(code);
}
