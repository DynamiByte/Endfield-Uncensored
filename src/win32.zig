const std = @import("std");
const windows = std.os.windows;

pub const ATOM = windows.ATOM;
pub const BOOL = windows.BOOL;
pub const DWORD = windows.DWORD;
pub const HANDLE = windows.HANDLE;
pub const HBRUSH = windows.HBRUSH;
pub const HCURSOR = windows.HCURSOR;
pub const HICON = windows.HICON;
pub const HINSTANCE = windows.HINSTANCE;
pub const HMODULE = windows.HMODULE;
pub const HMENU = windows.HMENU;
pub const HWND = windows.HWND;
pub const INT = windows.INT;
pub const INVALID_HANDLE_VALUE = windows.INVALID_HANDLE_VALUE;
pub const LONG = windows.LONG;
pub const LPCWSTR = windows.LPCWSTR;
pub const LPWSTR = windows.LPWSTR;
pub const MAX_PATH = windows.MAX_PATH;
pub const SECURITY_ATTRIBUTES = windows.SECURITY_ATTRIBUTES;
pub const STARTUPINFOW = windows.STARTUPINFOW;
pub const ULONG_PTR = windows.ULONG_PTR;
pub const UINT = windows.UINT;
pub const WCHAR = windows.WCHAR;
pub const WORD = windows.WORD;
pub const LPARAM = windows.LPARAM;
pub const PROCESS = windows.PROCESS;
pub const PROCESS_INFORMATION = windows.PROCESS.INFORMATION;

pub const WPARAM = usize;
pub const LRESULT = isize;
pub const WNDPROC = *const fn (hwnd: HWND, msg: UINT, w_param: WPARAM, l_param: LPARAM) callconv(.winapi) LRESULT;

pub const POINT = extern struct {
    x: LONG,
    y: LONG,
};

pub const RECT = extern struct {
    left: LONG,
    top: LONG,
    right: LONG,
    bottom: LONG,
};

pub const MSG = extern struct {
    hwnd: ?HWND,
    message: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
    time: DWORD,
    pt: POINT,
    lPrivate: DWORD,
};

pub const WNDCLASSEXW = extern struct {
    cbSize: UINT,
    style: UINT,
    lpfnWndProc: ?WNDPROC,
    cbClsExtra: INT,
    cbWndExtra: INT,
    hInstance: ?HINSTANCE,
    hIcon: ?HICON,
    hCursor: ?HCURSOR,
    hbrBackground: ?HBRUSH,
    lpszMenuName: ?LPCWSTR,
    lpszClassName: LPCWSTR,
    hIconSm: ?HICON,
};

pub const PROCESSENTRY32W = extern struct {
    dwSize: DWORD,
    cntUsage: DWORD,
    th32ProcessID: DWORD,
    th32DefaultHeapID: ULONG_PTR,
    th32ModuleID: DWORD,
    cntThreads: DWORD,
    th32ParentProcessID: DWORD,
    pcPriClassBase: LONG,
    dwFlags: DWORD,
    szExeFile: [MAX_PATH]WCHAR,
};

pub const FALSE = BOOL.FALSE;
pub const TRUE = BOOL.TRUE;

pub const PROCESS_CREATE_THREAD: DWORD = 0x0002;
pub const PROCESS_VM_OPERATION: DWORD = 0x0008;
pub const PROCESS_VM_READ: DWORD = 0x0010;
pub const PROCESS_VM_WRITE: DWORD = 0x0020;
pub const PROCESS_QUERY_INFORMATION: DWORD = 0x0400;
pub const PROCESS_QUERY_LIMITED_INFORMATION: DWORD = 0x1000;
pub const SYNCHRONIZE: DWORD = 0x00100000;

pub const TH32CS_SNAPPROCESS: DWORD = 0x00000002;
pub const WAIT_OBJECT_0: DWORD = 0x00000000;
pub const WAIT_TIMEOUT: DWORD = 0x00000102;
pub const WAIT_FAILED: DWORD = 0xFFFFFFFF;
pub const STILL_ACTIVE: DWORD = 0x00000103;
pub const MEM_COMMIT: DWORD = 0x00001000;
pub const MEM_RESERVE: DWORD = 0x00002000;
pub const MEM_RELEASE: DWORD = 0x00008000;
pub const PAGE_READWRITE: DWORD = 0x00000004;

pub const ERROR_FILE_NOT_FOUND: DWORD = 2;
pub const ERROR_PATH_NOT_FOUND: DWORD = 3;
pub const ERROR_ACCESS_DENIED: DWORD = 5;
pub const ERROR_INVALID_PARAMETER: DWORD = 87;
pub const ERROR_INVALID_NAME: DWORD = 123;

pub const WM_DESTROY: UINT = 0x0002;
pub const WM_SIZE: UINT = 0x0005;
pub const WM_ERASEBKGND: UINT = 0x0014;
pub const WM_QUIT: UINT = 0x0012;
pub const WM_SETICON: UINT = 0x0080;
pub const WM_NCHITTEST: UINT = 0x0084;
pub const WM_MOUSEMOVE: UINT = 0x0200;
pub const WM_LBUTTONDOWN: UINT = 0x0201;
pub const WM_LBUTTONUP: UINT = 0x0202;
pub const WM_DPICHANGED: UINT = 0x02E0;

pub const HTTRANSPARENT: LRESULT = -1;
pub const HTCLIENT: LRESULT = 1;

pub const SIZE_RESTORED: WPARAM = 0;
pub const SIZE_MINIMIZED: WPARAM = 1;

pub const PM_REMOVE: UINT = 0x0001;

pub const SW_SHOWNORMAL: INT = 1;
pub const SW_SHOW: INT = 5;
pub const SW_MINIMIZE: INT = 6;
pub const SW_RESTORE: INT = 9;

pub const SWP_NOSIZE: UINT = 0x0001;
pub const SWP_NOZORDER: UINT = 0x0004;
pub const SWP_NOACTIVATE: UINT = 0x0010;

pub const CS_CLASSDC: UINT = 0x0040;
pub const WS_POPUP: DWORD = 0x80000000;
pub const WS_EX_APPWINDOW: DWORD = 0x00040000;
pub const WS_EX_NOREDIRECTIONBITMAP: DWORD = 0x00200000;
pub const CW_USEDEFAULT: INT = @as(INT, @bitCast(@as(u32, 0x80000000)));

pub const SM_CXSCREEN: INT = 0;
pub const SM_CYSCREEN: INT = 1;
pub const SM_CXICON: INT = 11;
pub const SM_CYICON: INT = 12;
pub const SM_CXSMICON: INT = 49;
pub const SM_CYSMICON: INT = 50;

pub extern "kernel32" fn CreateToolhelp32Snapshot(dw_flags: DWORD, th32_process_id: DWORD) callconv(.winapi) HANDLE;
pub extern "kernel32" fn Process32FirstW(h_snapshot: HANDLE, lppe: *PROCESSENTRY32W) callconv(.winapi) BOOL;
pub extern "kernel32" fn Process32NextW(h_snapshot: HANDLE, lppe: *PROCESSENTRY32W) callconv(.winapi) BOOL;
pub extern "kernel32" fn OpenProcess(dw_desired_access: DWORD, b_inherit_handle: BOOL, dw_process_id: DWORD) callconv(.winapi) ?HANDLE;
pub extern "kernel32" fn CloseHandle(h_object: HANDLE) callconv(.winapi) BOOL;
pub extern "kernel32" fn GetLastError() callconv(.winapi) DWORD;
pub extern "kernel32" fn GetCurrentProcessId() callconv(.winapi) DWORD;
pub extern "kernel32" fn GetTickCount64() callconv(.winapi) u64;
pub extern "kernel32" fn WaitForSingleObject(h_handle: HANDLE, dw_milliseconds: DWORD) callconv(.winapi) DWORD;
pub extern "kernel32" fn GetTempPathW(n_buffer_length: DWORD, lp_buffer: [*]WCHAR) callconv(.winapi) DWORD;
pub extern "kernel32" fn VirtualAllocEx(h_process: HANDLE, lp_address: ?*anyopaque, dw_size: usize, fl_allocation_type: DWORD, fl_protect: DWORD) callconv(.winapi) ?*anyopaque;
pub extern "kernel32" fn VirtualFreeEx(h_process: HANDLE, lp_address: *anyopaque, dw_size: usize, dw_free_type: DWORD) callconv(.winapi) BOOL;
pub extern "kernel32" fn WriteProcessMemory(h_process: HANDLE, lp_base_address: *anyopaque, lp_buffer: *const anyopaque, n_size: usize, lp_number_of_bytes_written: ?*usize) callconv(.winapi) BOOL;
pub extern "kernel32" fn GetModuleHandleW(lp_module_name: ?LPCWSTR) callconv(.winapi) ?HMODULE;
pub extern "kernel32" fn GetProcAddress(h_module: HMODULE, lp_proc_name: [*:0]const u8) callconv(.winapi) ?*anyopaque;
pub extern "kernel32" fn CreateRemoteThread(h_process: HANDLE, lp_thread_attributes: ?*SECURITY_ATTRIBUTES, dw_stack_size: usize, lp_start_address: *const fn (?*anyopaque) callconv(.winapi) DWORD, lp_parameter: ?*anyopaque, dw_creation_flags: DWORD, lp_thread_id: ?*DWORD) callconv(.winapi) ?HANDLE;
pub extern "kernel32" fn GetExitCodeThread(h_thread: HANDLE, lp_exit_code: *DWORD) callconv(.winapi) BOOL;
pub extern "kernel32" fn QueryFullProcessImageNameW(h_process: HANDLE, dw_flags: DWORD, lp_exe_name: [*]WCHAR, lpdw_size: *DWORD) callconv(.winapi) BOOL;
pub extern "kernel32" fn Sleep(dw_milliseconds: DWORD) callconv(.winapi) void;
pub extern "kernel32" fn FreeConsole() callconv(.winapi) BOOL;
pub extern "kernel32" fn AllocConsole() callconv(.winapi) BOOL;
pub extern "kernel32" fn SetConsoleTitleW(lp_console_title: LPCWSTR) callconv(.winapi) BOOL;

pub extern "user32" fn GetWindowRect(hwnd: HWND, lp_rect: *RECT) callconv(.winapi) BOOL;
pub extern "user32" fn LoadCursorW(h_instance: ?HINSTANCE, cursor_name: ?*anyopaque) callconv(.winapi) ?HCURSOR;
pub extern "user32" fn SetWindowPos(hwnd: HWND, hwnd_insert_after: ?HWND, x: INT, y: INT, cx: INT, cy: INT, flags: UINT) callconv(.winapi) BOOL;
pub extern "user32" fn DestroyWindow(hwnd: HWND) callconv(.winapi) BOOL;
pub extern "user32" fn ShowWindow(hwnd: HWND, n_cmd_show: INT) callconv(.winapi) BOOL;
pub extern "user32" fn IsIconic(hwnd: HWND) callconv(.winapi) BOOL;
pub extern "user32" fn GetCursorPos(lp_point: *POINT) callconv(.winapi) BOOL;
pub extern "user32" fn ScreenToClient(hwnd: HWND, lp_point: *POINT) callconv(.winapi) BOOL;
pub extern "user32" fn SetCursor(h_cursor: ?HCURSOR) callconv(.winapi) ?HCURSOR;
pub extern "user32" fn SetCapture(hwnd: HWND) callconv(.winapi) ?HWND;
pub extern "user32" fn ReleaseCapture() callconv(.winapi) BOOL;
pub extern "user32" fn PtInRect(lprc: *const RECT, pt: POINT) callconv(.winapi) BOOL;
pub extern "user32" fn DefWindowProcW(hwnd: HWND, msg: UINT, w_param: WPARAM, l_param: LPARAM) callconv(.winapi) LRESULT;
pub extern "user32" fn CreateWindowExW(ex_style: DWORD, class_name: LPCWSTR, window_name: LPCWSTR, style: DWORD, x: INT, y: INT, width: INT, height: INT, parent: ?HWND, menu: ?HMENU, instance: ?HINSTANCE, param: ?*anyopaque) callconv(.winapi) ?HWND;
pub extern "user32" fn RegisterClassExW(wnd_class: *const WNDCLASSEXW) callconv(.winapi) ATOM;
pub extern "user32" fn UnregisterClassW(class_name: LPCWSTR, instance: ?HINSTANCE) callconv(.winapi) BOOL;
pub extern "user32" fn GetSystemMetrics(index: INT) callconv(.winapi) INT;
pub extern "user32" fn IsWindow(hwnd: HWND) callconv(.winapi) BOOL;
pub extern "user32" fn GetClientRect(hwnd: HWND, rect: *RECT) callconv(.winapi) BOOL;
pub extern "user32" fn PeekMessageW(lp_msg: *MSG, hwnd: ?HWND, msg_filter_min: UINT, msg_filter_max: UINT, remove_msg: UINT) callconv(.winapi) BOOL;
pub extern "user32" fn TranslateMessage(lp_msg: *const MSG) callconv(.winapi) BOOL;
pub extern "user32" fn DispatchMessageW(lp_msg: *const MSG) callconv(.winapi) LRESULT;
pub extern "user32" fn PostQuitMessage(exit_code: INT) callconv(.winapi) void;
pub extern "user32" fn UpdateWindow(hwnd: HWND) callconv(.winapi) BOOL;

pub extern "shell32" fn ShellExecuteW(hwnd: ?HWND, operation: LPCWSTR, file: LPCWSTR, parameters: ?LPCWSTR, directory: ?LPCWSTR, show_cmd: INT) callconv(.winapi) HINSTANCE;

pub extern "kernel32" fn CreateProcessW(
    lp_application_name: ?LPCWSTR,
    lp_command_line: ?LPWSTR,
    lp_process_attributes: ?*SECURITY_ATTRIBUTES,
    lp_thread_attributes: ?*SECURITY_ATTRIBUTES,
    b_inherit_handles: BOOL,
    dw_creation_flags: DWORD,
    lp_environment: ?[*:0]const WCHAR,
    lp_current_directory: ?LPCWSTR,
    lp_startup_info: *STARTUPINFOW,
    lp_process_information: *PROCESS.INFORMATION,
) callconv(.winapi) BOOL;
