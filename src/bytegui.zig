// ByteGui - A minimal immediate mode GUI library for Endfield Uncensored, built on DirectX 11 and GDI+.

const builtin = @import("builtin");
const std = @import("std");

// Platform Imports
pub const c = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", {});
    @cDefine("NOMINMAX", {});
    @cDefine("CINTERFACE", {});
    @cDefine("COBJMACROS", {});
    @cInclude("windows.h");
    @cInclude("d3d11.h");
    @cInclude("d3dcompiler.h");
    @cInclude("dxgi1_3.h");
    @cInclude("gdiplus.h");
});

// DirectComposition Definitions
const dcomp = struct {
    pub const IID_IDCompositionDevice: c.IID = .{
        .Data1 = 0xC37EA93A,
        .Data2 = 0xE7AA,
        .Data3 = 0x450D,
        .Data4 = .{ 0xB1, 0x6F, 0x97, 0x46, 0xCB, 0x04, 0x07, 0xF3 },
    };

    pub const IID_IDCompositionDesktopDevice: c.IID = .{
        .Data1 = 0x5F4633FE,
        .Data2 = 0x1E08,
        .Data3 = 0x4CB8,
        .Data4 = .{ 0x8C, 0x75, 0xCE, 0x24, 0x33, 0x3F, 0x56, 0x02 },
    };

    pub const IID_IDCompositionVisual3: c.IID = .{
        .Data1 = 0x2775F462,
        .Data2 = 0xB6C1,
        .Data3 = 0x4015,
        .Data4 = .{ 0xB0, 0xBE, 0xB3, 0xE7, 0xD6, 0xA4, 0x97, 0x6D },
    };

    pub const IDCompositionTarget = extern struct {
        lpVtbl: *const IDCompositionTargetVtbl,
    };

    pub const IDCompositionTargetVtbl = extern struct {
        QueryInterface: ?*const fn (*IDCompositionTarget, *const c.IID, *?*anyopaque) callconv(.winapi) c.HRESULT,
        AddRef: ?*const fn (*IDCompositionTarget) callconv(.winapi) c.ULONG,
        Release: ?*const fn (*IDCompositionTarget) callconv(.winapi) c.ULONG,
        SetRoot: ?*const fn (*IDCompositionTarget, ?*anyopaque) callconv(.winapi) c.HRESULT,
    };

    pub const IDCompositionVisual = extern struct {
        lpVtbl: *const IDCompositionVisualVtbl,
    };

    pub const IDCompositionVisualVtbl = extern struct {
        QueryInterface: ?*const fn (*IDCompositionVisual, *const c.IID, *?*anyopaque) callconv(.winapi) c.HRESULT,
        AddRef: ?*const fn (*IDCompositionVisual) callconv(.winapi) c.ULONG,
        Release: ?*const fn (*IDCompositionVisual) callconv(.winapi) c.ULONG,
        SetOffsetXAnimation: ?*const anyopaque,
        SetOffsetX: ?*const anyopaque,
        SetOffsetYAnimation: ?*const anyopaque,
        SetOffsetY: ?*const anyopaque,
        SetTransformObject: ?*const anyopaque,
        SetTransformMatrix: ?*const anyopaque,
        SetTransformParent: ?*const anyopaque,
        SetEffect: ?*const anyopaque,
        SetBitmapInterpolationMode: ?*const anyopaque,
        SetBorderMode: ?*const anyopaque,
        SetClipObject: ?*const anyopaque,
        SetClipRect: ?*const anyopaque,
        SetContent: ?*const fn (*IDCompositionVisual, ?*anyopaque) callconv(.winapi) c.HRESULT,
        AddVisual: ?*const anyopaque,
        RemoveVisual: ?*const anyopaque,
        RemoveAllVisuals: ?*const anyopaque,
        SetCompositeMode: ?*const anyopaque,
    };

    pub const IDCompositionVisual2 = extern struct {
        lpVtbl: *const IDCompositionVisual2Vtbl,
    };

    pub const IDCompositionVisual2Vtbl = extern struct {
        QueryInterface: ?*const fn (*IDCompositionVisual2, *const c.IID, *?*anyopaque) callconv(.winapi) c.HRESULT,
        AddRef: ?*const fn (*IDCompositionVisual2) callconv(.winapi) c.ULONG,
        Release: ?*const fn (*IDCompositionVisual2) callconv(.winapi) c.ULONG,
        SetOffsetXAnimation: ?*const anyopaque,
        SetOffsetX: ?*const anyopaque,
        SetOffsetYAnimation: ?*const anyopaque,
        SetOffsetY: ?*const anyopaque,
        SetTransformObject: ?*const anyopaque,
        SetTransformMatrix: ?*const anyopaque,
        SetTransformParent: ?*const anyopaque,
        SetEffect: ?*const anyopaque,
        SetBitmapInterpolationMode: ?*const anyopaque,
        SetBorderMode: ?*const anyopaque,
        SetClipObject: ?*const anyopaque,
        SetClipRect: ?*const anyopaque,
        SetContent: ?*const fn (*IDCompositionVisual2, ?*anyopaque) callconv(.winapi) c.HRESULT,
        AddVisual: ?*const anyopaque,
        RemoveVisual: ?*const anyopaque,
        RemoveAllVisuals: ?*const anyopaque,
        SetCompositeMode: ?*const anyopaque,
        SetOpacityMode: ?*const anyopaque,
        SetBackFaceVisibility: ?*const anyopaque,
    };

    pub const IDCompositionVisual3 = extern struct {
        lpVtbl: *const IDCompositionVisual3Vtbl,
    };

    pub const IDCompositionVisual3Vtbl = extern struct {
        QueryInterface: ?*const fn (*IDCompositionVisual3, *const c.IID, *?*anyopaque) callconv(.winapi) c.HRESULT,
        AddRef: ?*const fn (*IDCompositionVisual3) callconv(.winapi) c.ULONG,
        Release: ?*const fn (*IDCompositionVisual3) callconv(.winapi) c.ULONG,
        SetOffsetXAnimation: ?*const anyopaque,
        SetOffsetX: ?*const anyopaque,
        SetOffsetYAnimation: ?*const anyopaque,
        SetOffsetY: ?*const anyopaque,
        SetTransformObject2D: ?*const anyopaque,
        SetTransformMatrix2D: ?*const anyopaque,
        SetTransformParent: ?*const anyopaque,
        SetEffect: ?*const anyopaque,
        SetBitmapInterpolationMode: ?*const anyopaque,
        SetBorderMode: ?*const anyopaque,
        SetClipObject: ?*const anyopaque,
        SetClipRect: ?*const anyopaque,
        SetContent: ?*const anyopaque,
        AddVisual: ?*const anyopaque,
        RemoveVisual: ?*const anyopaque,
        RemoveAllVisuals: ?*const anyopaque,
        SetCompositeMode: ?*const anyopaque,
        SetOpacityMode: ?*const anyopaque,
        SetBackFaceVisibility: ?*const anyopaque,
        EnableHeatMap: ?*const anyopaque,
        DisableHeatMap: ?*const anyopaque,
        EnableRedrawRegions: ?*const anyopaque,
        DisableRedrawRegions: ?*const anyopaque,
        SetDepthMode: ?*const anyopaque,
        SetOffsetZAnimation: ?*const anyopaque,
        SetOffsetZ: ?*const anyopaque,
        SetOpacityAnimation: ?*const anyopaque,
        SetOpacity: ?*const fn (*IDCompositionVisual3, f32) callconv(.winapi) c.HRESULT,
        SetTransformObject3D: ?*const anyopaque,
        SetTransformMatrix3D: ?*const anyopaque,
        SetVisible: ?*const anyopaque,
    };

    pub const IDCompositionDesktopDevice = extern struct {
        lpVtbl: *const IDCompositionDesktopDeviceVtbl,
    };

    pub const IDCompositionDevice = extern struct {
        lpVtbl: *const IDCompositionDeviceVtbl,
    };

    pub const IDCompositionDeviceVtbl = extern struct {
        QueryInterface: ?*const fn (*IDCompositionDevice, *const c.IID, *?*anyopaque) callconv(.winapi) c.HRESULT,
        AddRef: ?*const fn (*IDCompositionDevice) callconv(.winapi) c.ULONG,
        Release: ?*const fn (*IDCompositionDevice) callconv(.winapi) c.ULONG,
        Commit: ?*const fn (*IDCompositionDevice) callconv(.winapi) c.HRESULT,
        WaitForCommitCompletion: ?*const anyopaque,
        GetFrameStatistics: ?*const anyopaque,
        CreateTargetForHwnd: ?*const fn (*IDCompositionDevice, c.HWND, c.BOOL, *?*IDCompositionTarget) callconv(.winapi) c.HRESULT,
        CreateVisual: ?*const fn (*IDCompositionDevice, *?*IDCompositionVisual) callconv(.winapi) c.HRESULT,
    };

    pub const IDCompositionDesktopDeviceVtbl = extern struct {
        QueryInterface: ?*const fn (*IDCompositionDesktopDevice, *const c.IID, *?*anyopaque) callconv(.winapi) c.HRESULT,
        AddRef: ?*const fn (*IDCompositionDesktopDevice) callconv(.winapi) c.ULONG,
        Release: ?*const fn (*IDCompositionDesktopDevice) callconv(.winapi) c.ULONG,
        Commit: ?*const fn (*IDCompositionDesktopDevice) callconv(.winapi) c.HRESULT,
        WaitForCommitCompletion: ?*const anyopaque,
        GetFrameStatistics: ?*const anyopaque,
        CreateVisual: ?*const fn (*IDCompositionDesktopDevice, *?*IDCompositionVisual2) callconv(.winapi) c.HRESULT,
        CreateSurfaceFactory: ?*const anyopaque,
        CreateSurface: ?*const anyopaque,
        CreateVirtualSurface: ?*const anyopaque,
        CreateTranslateTransform: ?*const anyopaque,
        CreateScaleTransform: ?*const anyopaque,
        CreateRotateTransform: ?*const anyopaque,
        CreateSkewTransform: ?*const anyopaque,
        CreateMatrixTransform: ?*const anyopaque,
        CreateTransformGroup: ?*const anyopaque,
        CreateTranslateTransform3D: ?*const anyopaque,
        CreateScaleTransform3D: ?*const anyopaque,
        CreateRotateTransform3D: ?*const anyopaque,
        CreateMatrixTransform3D: ?*const anyopaque,
        CreateTransform3DGroup: ?*const anyopaque,
        CreateEffectGroup: ?*const anyopaque,
        CreateRectangleClip: ?*const anyopaque,
        CreateAnimation: ?*const anyopaque,
        CreateTargetForHwnd: ?*const fn (*IDCompositionDesktopDevice, c.HWND, c.BOOL, *?*IDCompositionTarget) callconv(.winapi) c.HRESULT,
        CreateSurfaceFromHandle: ?*const anyopaque,
        CreateSurfaceFromHwnd: ?*const anyopaque,
    };

    extern "dcomp" fn DCompositionCreateDevice(dxgi_device: ?*c.IDXGIDevice, iid: *const c.IID, dcomposition_device: *?*anyopaque) callconv(.winapi) c.HRESULT;
    extern "dcomp" fn DCompositionCreateDevice3(rendering_device: ?*anyopaque, iid: *const c.IID, dcomposition_device: *?*anyopaque) callconv(.winapi) c.HRESULT;
};

const dxids = struct {
    pub const IID_ID3D11Texture2D: c.IID = .{
        .Data1 = 0x6F15AAF2,
        .Data2 = 0xD208,
        .Data3 = 0x4E89,
        .Data4 = .{ 0x9A, 0xB4, 0x48, 0x95, 0x35, 0xD3, 0x4F, 0x9C },
    };

    pub const IID_IDXGIDevice: c.IID = .{
        .Data1 = 0x54EC77FA,
        .Data2 = 0x1377,
        .Data3 = 0x44E6,
        .Data4 = .{ 0x8C, 0x32, 0x88, 0xFD, 0x5F, 0x44, 0xC8, 0x4C },
    };

    pub const IID_IDXGIFactory2: c.IID = .{
        .Data1 = 0x50C83A1C,
        .Data2 = 0xE072,
        .Data3 = 0x4C48,
        .Data4 = .{ 0x87, 0xB0, 0x36, 0x30, 0xFA, 0x36, 0xA6, 0xD0 },
    };
};

const allocator = std.heap.c_allocator;
pub const BYTEGUI_VERSION = "efu-mini";

pub fn BYTEGUI_CHECKVERSION() void {}

pub const ByteU32 = u32;
pub const ByteDrawIdx = u32;
pub const ByteTextureID = ?*anyopaque;

pub const BYTEGUI_COL32_A_MASK: ByteU32 = 0xFF000000;

const kPi: f32 = 3.14159265358979323846;
const kTextSupersample: f32 = 2.0;
const kTextSupersampleI: i32 = 2;
const default_class_name = std.unicode.utf8ToUtf16LeStringLiteral("ByteGuiPlatformWindow");
const default_title = std.unicode.utf8ToUtf16LeStringLiteral("ByteGui");
const idc_arrow_id: u16 = 32512;
const image_icon_type: c.UINT = 1;
const load_image_shared: c.UINT = 0x8000;
const wm_seticon: c.UINT = 0x0080;
const icon_small_slot: c.WPARAM = 0;
const icon_big_slot: c.WPARAM = 1;

extern "user32" fn LoadCursorW(h_instance: c.HINSTANCE, cursor_name: ?*anyopaque) callconv(.winapi) c.HCURSOR;
extern "user32" fn LoadImageW(h_instance: c.HINSTANCE, name: ?*anyopaque, image_type: c.UINT, width: c.INT, height: c.INT, flags: c.UINT) callconv(.winapi) ?*anyopaque;
extern "user32" fn SendMessageW(hwnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.winapi) c.LRESULT;

fn loadCursorResource(id: u16) c.HCURSOR {
    return LoadCursorW(null, @ptrFromInt(@as(usize, id)));
}

fn loadIconResource(instance: c.HINSTANCE, id: u16, width: c.INT, height: c.INT) c.HICON {
    const handle = LoadImageW(instance, @ptrFromInt(@as(usize, id)), image_icon_type, width, height, load_image_shared) orelse return null;
    return @ptrCast(@alignCast(handle));
}

fn iconHandleToLParam(icon: c.HICON) c.LPARAM {
    const value: usize = if (icon) |handle| @intFromPtr(handle) else 0;
    return @bitCast(value);
}

fn applyWindowIcons(hwnd: c.HWND, big_icon: c.HICON, small_icon: c.HICON) void {
    _ = SendMessageW(hwnd, wm_seticon, icon_big_slot, iconHandleToLParam(big_icon));
    _ = SendMessageW(hwnd, wm_seticon, icon_small_slot, iconHandleToLParam(small_icon));
}

pub const FontStyleRegular: i32 = 0;
pub const FontStyleBold: i32 = 1;
pub const FontStyleItalic: i32 = 2;
pub const FontStyleBoldItalic: i32 = 3;

pub const ByteGuiCol_Text: usize = 0;
pub const ByteGuiCol_WindowBg: usize = 1;
pub const ByteGuiCol_ChildBg: usize = 2;
pub const ByteGuiCol_Border: usize = 3;
pub const ByteGuiCol_ScrollbarBg: usize = 4;
pub const ByteGuiCol_ScrollbarGrab: usize = 5;
pub const ByteGuiCol_ScrollbarGrabHovered: usize = 6;
pub const ByteGuiCol_ScrollbarGrabActive: usize = 7;
pub const ByteGuiCol_COUNT: usize = 8;
pub const ByteGuiCol = i32;

pub const ByteGuiStyleVar_Alpha: i32 = 0;
pub const ByteGuiStyleVar = i32;

pub const ByteGuiWindowFlags_None: u32 = 0;
pub const ByteGuiWindowFlags_NoDecoration: u32 = 1 << 0;
pub const ByteGuiWindowFlags_NoMove: u32 = 1 << 1;
pub const ByteGuiWindowFlags_NoResize: u32 = 1 << 2;
pub const ByteGuiWindowFlags_NoSavedSettings: u32 = 1 << 3;
pub const ByteGuiWindowFlags_NoNav: u32 = 1 << 4;
pub const ByteGuiWindowFlags_NoBackground: u32 = 1 << 5;
pub const ByteGuiWindowFlags_NoScrollbar: u32 = 1 << 6;
pub const ByteGuiWindowFlags_NoScrollWithMouse: u32 = 1 << 7;
pub const ByteGuiWindowFlags = u32;

pub const ByteDrawListFlags_None: u32 = 0;
pub const ByteDrawListFlags_AntiAliasedFill: u32 = 1 << 0;
pub const ByteDrawListFlags_AntiAliasedLines: u32 = 1 << 1;
pub const ByteDrawListFlags = u32;

pub const ByteVec2 = extern struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
};

pub const ByteVec4 = extern struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,
    w: f32 = 0.0,
};

pub const ByteFontConfig = struct {
    PixelSnapH: bool = false,
    OversampleH: i32 = 3,
    OversampleV: i32 = 1,
};

pub const ByteDrawVert = extern struct {
    pos: ByteVec2 = .{},
    uv: ByteVec2 = .{},
    col: ByteU32 = 0,
};

pub const ByteDrawCmd = struct {
    ElemCount: u32 = 0,
    IdxOffset: u32 = 0,
    VtxOffset: u32 = 0,
    ClipRect: ByteVec4 = .{},
    TextureId: ByteTextureID = null,
};

pub const ByteVec2List = std.ArrayListUnmanaged(ByteVec2);

pub const ByteDrawData = struct {
    Valid: bool = false,
    CmdListsCount: i32 = 0,
    TotalIdxCount: i32 = 0,
    TotalVtxCount: i32 = 0,
    DisplayPos: ByteVec2 = .{},
    DisplaySize: ByteVec2 = .{},
    FramebufferScale: ByteVec2 = .{ .x = 1.0, .y = 1.0 },
    CmdLists: std.ArrayListUnmanaged(*ByteDrawList) = .{},

    fn deinit(self: *ByteDrawData) void {
        self.CmdLists.deinit(allocator);
        self.* = .{};
    }
};

pub const ByteGuiIO = struct {
    Fonts: ?*ByteFontAtlas = null,
    IniFilename: ?[*:0]const u8 = null,
    LogFilename: ?[*:0]const u8 = null,
    DisplaySize: ByteVec2 = .{},
    DeltaTime: f32 = 1.0 / 60.0,
    BackendRendererUserData: ?*anyopaque = null,
    BackendPlatformUserData: ?*anyopaque = null,
    BackendRendererName: ?[*:0]const u8 = null,
    BackendPlatformName: ?[*:0]const u8 = null,
};

pub const ByteGuiStyle = struct {
    Alpha: f32 = 1.0,
    WindowPadding: ByteVec2 = .{ .x = 8.0, .y = 8.0 },
    FramePadding: ByteVec2 = .{ .x = 4.0, .y = 3.0 },
    ItemSpacing: ByteVec2 = .{ .x = 8.0, .y = 4.0 },
    ItemInnerSpacing: ByteVec2 = .{ .x = 4.0, .y = 4.0 },
    WindowBorderSize: f32 = 1.0,
    ChildBorderSize: f32 = 1.0,
    FrameBorderSize: f32 = 0.0,
    PopupBorderSize: f32 = 1.0,
    WindowRounding: f32 = 7.0,
    ChildRounding: f32 = 0.0,
    FrameRounding: f32 = 0.0,
    ScrollbarRounding: f32 = 9.0,
    ScrollbarSize: f32 = 14.0,
    AntiAliasedFill: bool = true,
    AntiAliasedLines: bool = true,
    CurveTessellationTol: f32 = 1.25,
    CircleTessellationMaxError: f32 = 0.30,
    Colors: [ByteGuiCol_COUNT]ByteVec4 = .{
        .{ .x = 1.0, .y = 1.0, .z = 1.0, .w = 1.0 },
        .{ .x = 0.06, .y = 0.06, .z = 0.06, .w = 0.94 },
        .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 0.0 },
        .{ .x = 0.43, .y = 0.43, .z = 0.50, .w = 0.50 },
        .{ .x = 0.02, .y = 0.02, .z = 0.02, .w = 0.53 },
        .{ .x = 0.31, .y = 0.31, .z = 0.31, .w = 1.0 },
        .{ .x = 0.41, .y = 0.41, .z = 0.41, .w = 1.0 },
        .{ .x = 0.51, .y = 0.51, .z = 0.51, .w = 1.0 },
    },
};

pub const ByteFont = struct {
    LegacySize: f32 = 0.0,
    FamilyName: []u8 = &.{},
    FilePath: []u8 = &.{},
    FontStyle: i32 = FontStyleRegular,
    FontCollection: ?*c.GpFontCollection = null,
    FamilyNameWide: ?[:0]u16 = null,
    PixelSnapH: bool = false,

    pub fn CalcTextSizeA(
        self: *const ByteFont,
        size: f32,
        max_width: f32,
        wrap_width: f32,
        text_begin: []const u8,
        text_end: ?usize,
    ) ByteVec2 {
        const slice = sliceFromOptionalEnd(text_begin, text_end);
        const effective_max_width = if (max_width > 0.0 and max_width < std.math.floatMax(f32)) max_width else 0.0;
        const effective_wrap = if (wrap_width > 0.0) wrap_width else effective_max_width;
        return measureTextWithGdiPlus(self, size, slice, effective_wrap);
    }

    fn deinit(self: *ByteFont) void {
        if (self.FontCollection) |collection| {
            var private_collection: ?*c.GpFontCollection = collection;
            _ = c.GdipDeletePrivateFontCollection(@ptrCast(&private_collection));
        }
        if (self.FamilyNameWide) |family_name_wide| allocator.free(family_name_wide);
        if (self.FamilyName.len > 0) allocator.free(self.FamilyName);
        if (self.FilePath.len > 0) allocator.free(self.FilePath);
        self.* = undefined;
    }
};

// Font Loading And Text Rasterization
pub const ByteFontAtlas = struct {
    Fonts: std.ArrayListUnmanaged(*ByteFont) = .{},

    pub fn AddFontFromFileTTF(self: *ByteFontAtlas, filename: []const u8, size_pixels: f32, font_cfg: ?*const ByteFontConfig) ?*ByteFont {
        if (filename.len == 0 or size_pixels <= 0.0) return null;
        return addFontFromFile(self, filename, size_pixels, font_cfg);
    }

    pub fn AddFontDefault(self: *ByteFontAtlas) ?*ByteFont {
        const path = systemFontPath("segoeui.ttf") orelse return null;
        defer allocator.free(path);
        return self.AddFontFromFileTTF(path, 13.0, null);
    }

    pub fn Clear(self: *ByteFontAtlas) void {
        for (self.Fonts.items) |font| {
            font.deinit();
            allocator.destroy(font);
        }
        self.Fonts.clearRetainingCapacity();
        clearTextCache();
    }

    fn deinit(self: *ByteFontAtlas) void {
        self.Clear();
        self.Fonts.deinit(allocator);
        self.* = .{};
    }
};

pub const ByteDrawList = struct {
    Flags: ByteDrawListFlags = ByteDrawListFlags_AntiAliasedFill | ByteDrawListFlags_AntiAliasedLines,
    VtxBuffer: std.ArrayListUnmanaged(ByteDrawVert) = .{},
    IdxBuffer: std.ArrayListUnmanaged(ByteDrawIdx) = .{},
    CmdBuffer: std.ArrayListUnmanaged(ByteDrawCmd) = .{},
    Path: ByteVec2List = .{},

    CurrentClipRect: ByteVec4 = .{},
    WhiteTexture: ByteTextureID = null,

    pub fn ResetForNewFrame(self: *ByteDrawList, clip_rect: ByteVec4, white_texture: ByteTextureID, aa_fill: bool, aa_lines: bool) void {
        self.VtxBuffer.clearRetainingCapacity();
        self.IdxBuffer.clearRetainingCapacity();
        self.CmdBuffer.clearRetainingCapacity();
        self.Path.clearRetainingCapacity();
        self.CurrentClipRect = clip_rect;
        self.WhiteTexture = white_texture;
        self.Flags = ByteDrawListFlags_None;
        if (aa_fill) self.Flags |= ByteDrawListFlags_AntiAliasedFill;
        if (aa_lines) self.Flags |= ByteDrawListFlags_AntiAliasedLines;
    }

    pub fn SetClipRect(self: *ByteDrawList, clip_rect: ByteVec4) void {
        self.CurrentClipRect = clip_rect;
    }

    pub fn AddConvexPolyFilled(self: *ByteDrawList, points: []const ByteVec2, col: ByteU32) void {
        if (points.len < 3 or (col & BYTEGUI_COL32_A_MASK) == 0) return;

        const uv = ByteVec2{ .x = 0.5, .y = 0.5 };
        const idx_start = self.IdxBuffer.items.len;

        if ((self.Flags & ByteDrawListFlags_AntiAliasedFill) != 0) {
            var normals = allocator.alloc(ByteVec2, points.len) catch return;
            defer allocator.free(normals);

            var prev_idx: usize = points.len - 1;
            var cur_idx: usize = 0;
            while (cur_idx < points.len) : ({
                prev_idx = cur_idx;
                cur_idx += 1;
            }) {
                var delta = subVec2(points[cur_idx], points[prev_idx]);
                const len = @sqrt(byteLengthSqr(delta));
                if (len > 0.0) {
                    delta.x /= len;
                    delta.y /= len;
                }
                normals[prev_idx] = .{ .x = delta.y, .y = -delta.x };
            }

            const transparent = col & ~BYTEGUI_COL32_A_MASK;
            const base_idx: ByteDrawIdx = @intCast(self.VtxBuffer.items.len);
            for (points, 0..) |point, i| {
                const n0 = normals[(i + points.len - 1) % points.len];
                const n1 = normals[i];
                var avg = ByteVec2{ .x = (n0.x + n1.x) * 0.5, .y = (n0.y + n1.y) * 0.5 };
                const len = @sqrt(byteLengthSqr(avg));
                if (len > 0.0) {
                    avg.x /= len;
                    avg.y /= len;
                }
                avg.x *= 0.5;
                avg.y *= 0.5;

                self.addVertex(.{ .x = point.x - avg.x, .y = point.y - avg.y }, uv, col) catch return;
                self.addVertex(.{ .x = point.x + avg.x, .y = point.y + avg.y }, uv, transparent) catch return;
            }

            var i: usize = 2;
            while (i < points.len) : (i += 1) {
                self.addTriangleIndices(base_idx, base_idx + @as(ByteDrawIdx, @intCast((i - 1) * 2)), base_idx + @as(ByteDrawIdx, @intCast(i * 2))) catch return;
            }

            prev_idx = points.len - 1;
            cur_idx = 0;
            while (cur_idx < points.len) : ({
                prev_idx = cur_idx;
                cur_idx += 1;
            }) {
                const inner0 = base_idx + @as(ByteDrawIdx, @intCast(prev_idx * 2));
                const outer0 = inner0 + 1;
                const inner1 = base_idx + @as(ByteDrawIdx, @intCast(cur_idx * 2));
                const outer1 = inner1 + 1;
                self.addTriangleIndices(inner1, inner0, outer0) catch return;
                self.addTriangleIndices(outer0, outer1, inner1) catch return;
            }
        } else {
            const base_idx: ByteDrawIdx = @intCast(self.VtxBuffer.items.len);
            for (points) |point| {
                self.addVertex(point, uv, col) catch return;
            }
            var i: usize = 2;
            while (i < points.len) : (i += 1) {
                self.addTriangleIndices(base_idx, base_idx + @as(ByteDrawIdx, @intCast(i - 1)), base_idx + @as(ByteDrawIdx, @intCast(i))) catch return;
            }
        }

        self.addPrimitive(self.WhiteTexture, @intCast(self.IdxBuffer.items.len - idx_start)) catch return;
    }

    pub fn PathLineTo(self: *ByteDrawList, pos: ByteVec2) void {
        self.Path.append(allocator, pos) catch return;
    }

    pub fn PathArcTo(self: *ByteDrawList, center: ByteVec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) void {
        appendArc(&self.Path, center, radius, a_min, a_max, num_segments);
    }

    pub fn PathFillConvex(self: *ByteDrawList, col: ByteU32) void {
        if (self.Path.items.len > 0) self.AddConvexPolyFilled(self.Path.items, col);
        self.Path.clearRetainingCapacity();
    }

    pub fn AddRectFilled(self: *ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, col: ByteU32, rounding: f32) void {
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

        var clamped_rounding = @max(0.0, rounding);
        const max_rounding = @min((p_max.x - p_min.x) * 0.5, (p_max.y - p_min.y) * 0.5);
        clamped_rounding = @min(clamped_rounding, max_rounding);

        if (clamped_rounding <= 0.0) {
            const points = [_]ByteVec2{
                .{ .x = p_min.x, .y = p_min.y },
                .{ .x = p_max.x, .y = p_min.y },
                .{ .x = p_max.x, .y = p_max.y },
                .{ .x = p_min.x, .y = p_max.y },
            };
            self.AddConvexPolyFilled(&points, col);
            return;
        }

        var points = ByteVec2List{};
        defer points.deinit(allocator);

        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(clamped_rounding), 4));
        appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi, kPi * 1.5, segments);
        appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi * 1.5, kPi * 2.0, segments);
        appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, 0.0, kPi * 0.5, segments);
        appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, kPi * 0.5, kPi, segments);
        self.AddConvexPolyFilled(points.items, col);
    }

    fn AddPolylineInternal(self: *ByteDrawList, points: []const ByteVec2, col: ByteU32, closed: bool, thickness: f32) void {
        if (points.len < 2 or thickness <= 0.0 or (col & BYTEGUI_COL32_A_MASK) == 0) return;

        const count: usize = if (closed) points.len else points.len - 1;
        for (0..count) |i| {
            const p0 = points[i];
            const p1 = points[(i + 1) % points.len];
            var dir = subVec2(p1, p0);
            const len = @sqrt(byteLengthSqr(dir));
            if (len <= 0.0) continue;
            dir.x /= len;
            dir.y /= len;
            const normal = ByteVec2{ .x = dir.y * (thickness * 0.5), .y = -dir.x * (thickness * 0.5) };
            const quad = [_]ByteVec2{
                .{ .x = p0.x + normal.x, .y = p0.y + normal.y },
                .{ .x = p0.x - normal.x, .y = p0.y - normal.y },
                .{ .x = p1.x - normal.x, .y = p1.y - normal.y },
                .{ .x = p1.x + normal.x, .y = p1.y + normal.y },
            };
            self.AddConvexPolyFilled(&quad, col);
        }
    }

    pub fn AddCircle(self: *ByteDrawList, center: ByteVec2, radius: f32, col: ByteU32, num_segments: i32, thickness: f32) void {
        if (radius <= 0.0) return;
        const segments = if (num_segments > 0) num_segments else calcCircleSegmentCount(radius);
        var points = ByteVec2List{};
        defer points.deinit(allocator);
        points.ensureTotalCapacity(allocator, @intCast(segments)) catch return;
        var i: i32 = 0;
        while (i < segments) : (i += 1) {
            const a = (@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments))) * (2.0 * kPi);
            points.appendAssumeCapacity(.{ .x = center.x + @cos(a) * radius, .y = center.y + @sin(a) * radius });
        }
        self.AddPolylineInternal(points.items, col, true, thickness);
    }

    pub fn AddCircleFilled(self: *ByteDrawList, center: ByteVec2, radius: f32, col: ByteU32, num_segments: i32) void {
        if (radius <= 0.0) return;
        const segments = if (num_segments > 0) num_segments else calcCircleSegmentCount(radius);
        var points = ByteVec2List{};
        defer points.deinit(allocator);
        points.ensureTotalCapacity(allocator, @intCast(segments)) catch return;
        var i: i32 = 0;
        while (i < segments) : (i += 1) {
            const a = (@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments))) * (2.0 * kPi);
            points.appendAssumeCapacity(.{ .x = center.x + @cos(a) * radius, .y = center.y + @sin(a) * radius });
        }
        self.AddConvexPolyFilled(points.items, col);
    }

    pub fn AddText(self: *ByteDrawList, font: ?*ByteFont, font_size: f32, pos: ByteVec2, col: ByteU32, text_begin: []const u8, text_end: ?usize) void {
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

        const slice = sliceFromOptionalEnd(text_begin, text_end);
        const entry = getOrCreateTextTexture(font, font_size, 0.0, slice) orelse return;
        const texture = entry.Texture orelse return;
        const snapped_pos = ByteVec2{ .x = @floor(pos.x + 0.5), .y = @floor(pos.y + 0.5) };
        self.AddImage(@ptrCast(texture), snapped_pos, .{ .x = snapped_pos.x + entry.DisplaySize.x, .y = snapped_pos.y + entry.DisplaySize.y }, .{}, .{ .x = 1.0, .y = 1.0 }, col);
    }

    pub fn AddImage(self: *ByteDrawList, user_texture_id: ByteTextureID, p_min: ByteVec2, p_max: ByteVec2, uv_min: ByteVec2, uv_max: ByteVec2, col: ByteU32) void {
        if ((col & BYTEGUI_COL32_A_MASK) == 0 or user_texture_id == null) return;

        const idx_start = self.IdxBuffer.items.len;
        const base_idx: ByteDrawIdx = @intCast(self.VtxBuffer.items.len);
        self.addVertex(.{ .x = p_min.x, .y = p_min.y }, .{ .x = uv_min.x, .y = uv_min.y }, col) catch return;
        self.addVertex(.{ .x = p_max.x, .y = p_min.y }, .{ .x = uv_max.x, .y = uv_min.y }, col) catch return;
        self.addVertex(.{ .x = p_max.x, .y = p_max.y }, .{ .x = uv_max.x, .y = uv_max.y }, col) catch return;
        self.addVertex(.{ .x = p_min.x, .y = p_max.y }, .{ .x = uv_min.x, .y = uv_max.y }, col) catch return;
        self.addTriangleIndices(base_idx, base_idx + 1, base_idx + 2) catch return;
        self.addTriangleIndices(base_idx, base_idx + 2, base_idx + 3) catch return;
        self.addPrimitive(user_texture_id, @intCast(self.IdxBuffer.items.len - idx_start)) catch return;
    }

    fn addTriangleIndices(self: *ByteDrawList, a: ByteDrawIdx, b: ByteDrawIdx, cidx: ByteDrawIdx) !void {
        try self.IdxBuffer.append(allocator, a);
        try self.IdxBuffer.append(allocator, b);
        try self.IdxBuffer.append(allocator, cidx);
    }

    fn addVertex(self: *ByteDrawList, pos: ByteVec2, uv: ByteVec2, col: ByteU32) !void {
        try self.VtxBuffer.append(allocator, .{ .pos = pos, .uv = uv, .col = col });
    }

    fn addPrimitive(self: *ByteDrawList, texture_id: ByteTextureID, index_count: u32) !void {
        if (index_count == 0) return;

        const index_start: u32 = @intCast(self.IdxBuffer.items.len - index_count);
        if (self.CmdBuffer.items.len > 0) {
            const last = &self.CmdBuffer.items[self.CmdBuffer.items.len - 1];
            if (last.TextureId == texture_id and equalClipRect(last.ClipRect, self.CurrentClipRect) and last.IdxOffset + last.ElemCount == index_start) {
                last.ElemCount += index_count;
                return;
            }
        }

        try self.CmdBuffer.append(allocator, .{
            .TextureId = texture_id,
            .ClipRect = self.CurrentClipRect,
            .IdxOffset = index_start,
            .ElemCount = index_count,
        });
    }

    fn deinit(self: *ByteDrawList) void {
        self.VtxBuffer.deinit(allocator);
        self.IdxBuffer.deinit(allocator);
        self.CmdBuffer.deinit(allocator);
        self.Path.deinit(allocator);
        self.* = .{};
    }
};

pub const ByteGuiPlatformWindowConfig = struct {
    Instance: c.HINSTANCE = null,
    WndProc: c.WNDPROC = null,
    ClassName: [*:0]const u16 = default_class_name,
    Title: [*:0]const u16 = default_title,
    IconResourceId: u16 = 0,
    LogicalWidth: i32 = 0,
    LogicalHeight: i32 = 0,
    Style: c.DWORD = c.WS_POPUP,
    ExStyle: c.DWORD = c.WS_EX_APPWINDOW | c.WS_EX_NOREDIRECTIONBITMAP,
    CenterOnPrimaryMonitor: bool = true,
};

const TextCacheEntry = struct {
    Font: *ByteFont,
    PixelSize100: i32,
    WrapWidth100: i32,
    Text: []u8,
    Texture: ?*c.ID3D11ShaderResourceView = null,
    DisplaySize: ByteVec2 = .{},

    fn deinit(self: *TextCacheEntry) void {
        releaseShaderResourceView(self.Texture);
        allocator.free(self.Text);
        self.* = undefined;
    }
};

const ChildState = struct {
    PreviousClipRect: ByteVec4 = .{},
    PreviousCursorPos: ByteVec2 = .{},
    Origin: ByteVec2 = .{},
    Size: ByteVec2 = .{},
};

pub const ByteGuiContext = struct {
    IO: ByteGuiIO = .{},
    Style: ByteGuiStyle = .{},
    FontAtlas: ByteFontAtlas = .{},
    DrawList: ByteDrawList = .{},
    DrawData: ByteDrawData = .{},

    CurrentFont: ?*ByteFont = null,
    FontStack: std.ArrayListUnmanaged(*ByteFont) = .{},
    AlphaStack: std.ArrayListUnmanaged(f32) = .{},
    ChildStack: std.ArrayListUnmanaged(ChildState) = .{},

    NextWindowPos: ByteVec2 = .{},
    NextWindowSize: ByteVec2 = .{},
    HasNextWindowPos: bool = false,
    HasNextWindowSize: bool = false,
    FrameBegun: bool = false,

    WindowPos: ByteVec2 = .{},
    WindowSize: ByteVec2 = .{},
    CursorScreenPos: ByteVec2 = .{},
    CurrentClipRect: ByteVec4 = .{},
    WhiteTexture: ByteTextureID = null,

    TextCache: std.ArrayListUnmanaged(TextCacheEntry) = .{},

    fn init(self: *ByteGuiContext) void {
        self.* = .{};
        self.IO.Fonts = &self.FontAtlas;
    }

    fn deinit(self: *ByteGuiContext) void {
        clearTextCache();
        self.FontAtlas.deinit();
        self.DrawList.deinit();
        self.DrawData.deinit();
        self.FontStack.deinit(allocator);
        self.AlphaStack.deinit(allocator);
        self.ChildStack.deinit(allocator);
        self.TextCache.deinit(allocator);
        self.* = undefined;
    }
};

const MiniWin32BackendData = struct {
    Hwnd: ?c.HWND = null,
    Time: i64 = 0,
    TicksPerSecond: i64 = 0,
};

const MiniDx11BackendData = struct {
    Device: ?*c.ID3D11Device = null,
    Context: ?*c.ID3D11DeviceContext = null,
    SwapChain: ?*c.IDXGISwapChain1 = null,
    MainRTV: ?*c.ID3D11RenderTargetView = null,
    DcompDevice: ?*dcomp.IDCompositionDesktopDevice = null,
    DcompTarget: ?*dcomp.IDCompositionTarget = null,
    DcompVisual: ?*dcomp.IDCompositionVisual2 = null,
    DcompVisual3: ?*dcomp.IDCompositionVisual3 = null,
    VertexBuffer: ?*c.ID3D11Buffer = null,
    IndexBuffer: ?*c.ID3D11Buffer = null,
    VertexShader: ?*c.ID3D11VertexShader = null,
    InputLayout: ?*c.ID3D11InputLayout = null,
    VertexConstantBuffer: ?*c.ID3D11Buffer = null,
    PixelShader: ?*c.ID3D11PixelShader = null,
    LinearSampler: ?*c.ID3D11SamplerState = null,
    RasterizerState: ?*c.ID3D11RasterizerState = null,
    BlendState: ?*c.ID3D11BlendState = null,
    DepthStencilState: ?*c.ID3D11DepthStencilState = null,
    WhiteTextureView: ?*c.ID3D11ShaderResourceView = null,
    VertexBufferSize: i32 = 5000,
    IndexBufferSize: i32 = 10000,
};

const VertexConstantBufferDx11 = extern struct {
    mvp: [4][4]f32 = std.mem.zeroes([4][4]f32),
};

const HostWindowData = struct {
    Instance: c.HINSTANCE = null,
    ClassName: ?[:0]u16 = null,
    Hwnd: ?c.HWND = null,
    DpiScale: f32 = 1.0,
    LogicalWidth: i32 = 0,
    LogicalHeight: i32 = 0,
    WindowWidthPx: i32 = 0,
    WindowHeightPx: i32 = 0,
    ClassRegistered: bool = false,
};

var GByteGui: ?*ByteGuiContext = null;
var GByteGuiGdiPlusToken: c.ULONG_PTR = 0;
var GHostWindow: HostWindowData = .{};

fn ensureByteGuiGdiPlus() bool {
    if (GByteGuiGdiPlusToken != 0) return true;

    var startup_input = std.mem.zeroes(c.GdiplusStartupInput);
    startup_input.GdiplusVersion = 1;
    return c.GdiplusStartup(&GByteGuiGdiPlusToken, &startup_input, null) == c.Ok;
}

fn shutdownByteGuiGdiPlus() void {
    if (GByteGuiGdiPlusToken != 0) {
        c.GdiplusShutdown(GByteGuiGdiPlusToken);
        GByteGuiGdiPlusToken = 0;
    }
}

pub const ByteGui = struct {
    pub fn CreateContext() ?*ByteGuiContext {
        DestroyContext(null);
        if (!ensureByteGuiGdiPlus()) return null;
        const ctx = allocator.create(ByteGuiContext) catch return null;
        ctx.init();
        GByteGui = ctx;
        return ctx;
    }

    pub fn DestroyContext(ctx: ?*ByteGuiContext) void {
        var actual = ctx;
        if (actual == null) actual = GByteGui;
        if (actual == null) return;

        if (actual == GByteGui) clearTextCache();
        actual.?.deinit();
        allocator.destroy(actual.?);
        if (actual == GByteGui) {
            GByteGui = null;
            shutdownByteGuiGdiPlus();
        }
    }

    pub fn GetCurrentContext() ?*ByteGuiContext {
        return GByteGui;
    }

    pub fn GetIO() *ByteGuiIO {
        return &GByteGui.?.IO;
    }

    pub fn GetStyle() *ByteGuiStyle {
        return &GByteGui.?.Style;
    }

    pub fn GetDrawData() ?*ByteDrawData {
        if (GByteGui) |ctx| return &ctx.DrawData;
        return null;
    }

    pub fn GetWindowDrawList() ?*ByteDrawList {
        if (GByteGui) |ctx| return &ctx.DrawList;
        return null;
    }

    pub fn ColorConvertFloat4ToU32(input: ByteVec4) ByteU32 {
        const out_r: ByteU32 = @intFromFloat(clamp01(input.x) * 255.0 + 0.5);
        const out_g: ByteU32 = @intFromFloat(clamp01(input.y) * 255.0 + 0.5);
        const out_b: ByteU32 = @intFromFloat(clamp01(input.z) * 255.0 + 0.5);
        const out_a: ByteU32 = @intFromFloat(clamp01(input.w) * 255.0 + 0.5);
        return out_r | (out_g << 8) | (out_b << 16) | (out_a << 24);
    }

    pub fn NewFrame() void {
        const ctx = GByteGui orelse return;

        ctx.FrameBegun = true;
        ctx.HasNextWindowPos = false;
        ctx.HasNextWindowSize = false;
        ctx.ChildStack.clearRetainingCapacity();
        ctx.CursorScreenPos = .{};
        ctx.CurrentClipRect = .{ .x = 0.0, .y = 0.0, .z = ctx.IO.DisplaySize.x, .w = ctx.IO.DisplaySize.y };
        ctx.DrawList.ResetForNewFrame(ctx.CurrentClipRect, ctx.WhiteTexture, ctx.Style.AntiAliasedFill, ctx.Style.AntiAliasedLines);
        ctx.DrawData.Valid = false;
        ctx.DrawData.CmdLists.clearRetainingCapacity();
        ctx.DrawData.CmdListsCount = 0;
        ctx.DrawData.TotalVtxCount = 0;
        ctx.DrawData.TotalIdxCount = 0;

        if (ctx.FontStack.items.len > 0) {
            ctx.CurrentFont = ctx.FontStack.items[ctx.FontStack.items.len - 1];
        } else if (ctx.IO.Fonts) |fonts| {
            ctx.CurrentFont = if (fonts.Fonts.items.len > 0) fonts.Fonts.items[0] else null;
        } else {
            ctx.CurrentFont = null;
        }
    }

    pub fn Render() void {
        const ctx = GByteGui orelse return;

        ctx.DrawData.Valid = true;
        ctx.DrawData.DisplayPos = .{};
        ctx.DrawData.DisplaySize = ctx.IO.DisplaySize;
        ctx.DrawData.FramebufferScale = .{ .x = 1.0, .y = 1.0 };
        ctx.DrawData.CmdLists.clearRetainingCapacity();
        ctx.DrawData.CmdLists.append(allocator, &ctx.DrawList) catch return;
        ctx.DrawData.CmdListsCount = 1;
        ctx.DrawData.TotalVtxCount = @intCast(ctx.DrawList.VtxBuffer.items.len);
        ctx.DrawData.TotalIdxCount = @intCast(ctx.DrawList.IdxBuffer.items.len);
        ctx.FrameBegun = false;
    }

    pub fn Begin(name: []const u8, p_open: ?*bool, flags: ByteGuiWindowFlags) bool {
        _ = name;
        _ = p_open;
        _ = flags;

        const ctx = GByteGui orelse return false;
        ctx.WindowPos = if (ctx.HasNextWindowPos) ctx.NextWindowPos else .{};
        ctx.WindowSize = if (ctx.HasNextWindowSize) ctx.NextWindowSize else ctx.IO.DisplaySize;
        ctx.HasNextWindowPos = false;
        ctx.HasNextWindowSize = false;
        ctx.CursorScreenPos = ctx.WindowPos;
        ctx.CurrentClipRect = .{
            .x = ctx.WindowPos.x,
            .y = ctx.WindowPos.y,
            .z = ctx.WindowPos.x + ctx.WindowSize.x,
            .w = ctx.WindowPos.y + ctx.WindowSize.y,
        };
        ctx.DrawList.SetClipRect(ctx.CurrentClipRect);
        return true;
    }

    pub fn End() void {}

    pub fn BeginChild(str_id: []const u8, size: ByteVec2, border: bool, flags: ByteGuiWindowFlags) bool {
        _ = str_id;
        _ = border;
        _ = flags;

        const ctx = GByteGui orelse return false;
        const child = ChildState{
            .PreviousClipRect = ctx.CurrentClipRect,
            .PreviousCursorPos = ctx.CursorScreenPos,
            .Origin = ctx.CursorScreenPos,
            .Size = size,
        };
        ctx.ChildStack.append(allocator, child) catch return false;

        ctx.CurrentClipRect = .{
            .x = child.Origin.x,
            .y = child.Origin.y,
            .z = child.Origin.x + size.x,
            .w = child.Origin.y + size.y,
        };
        ctx.DrawList.SetClipRect(ctx.CurrentClipRect);
        ctx.CursorScreenPos = child.Origin;
        return true;
    }

    pub fn EndChild() void {
        const ctx = GByteGui orelse return;
        if (ctx.ChildStack.items.len == 0) return;

        const child = ctx.ChildStack.pop().?;
        ctx.CurrentClipRect = child.PreviousClipRect;
        ctx.DrawList.SetClipRect(ctx.CurrentClipRect);
        ctx.CursorScreenPos = child.PreviousCursorPos;
    }

    pub fn SetNextWindowPos(pos: ByteVec2) void {
        const ctx = GByteGui orelse return;
        ctx.NextWindowPos = pos;
        ctx.HasNextWindowPos = true;
    }

    pub fn SetNextWindowSize(size: ByteVec2) void {
        const ctx = GByteGui orelse return;
        ctx.NextWindowSize = size;
        ctx.HasNextWindowSize = true;
    }

    pub fn SetCursorScreenPos(pos: ByteVec2) void {
        const ctx = GByteGui orelse return;
        ctx.CursorScreenPos = pos;
    }

    pub fn TextWrapped(comptime fmt: []const u8, args: anytype) void {
        const ctx = GByteGui orelse return;
        const text = std.fmt.allocPrint(allocator, fmt, args) catch return;
        defer allocator.free(text);

        var font = ctx.CurrentFont;
        if (font == null) {
            if (ctx.IO.Fonts) |fonts| {
                if (fonts.Fonts.items.len > 0) font = fonts.Fonts.items[0];
            }
        }
        const active_font = font orelse return;

        const wrap_width = @max(0.0, ctx.CurrentClipRect.z - ctx.CursorScreenPos.x);
        const entry = getOrCreateTextTexture(active_font, active_font.LegacySize, wrap_width, text) orelse return;
        const texture = entry.Texture orelse return;

        var color = ctx.Style.Colors[ByteGuiCol_Text];
        color.w *= ctx.Style.Alpha;
        const col_u32 = ColorConvertFloat4ToU32(color);
        const pos = ByteVec2{ .x = @floor(ctx.CursorScreenPos.x + 0.5), .y = @floor(ctx.CursorScreenPos.y + 0.5) };
        ctx.DrawList.AddImage(@ptrCast(texture), pos, .{ .x = pos.x + entry.DisplaySize.x, .y = pos.y + entry.DisplaySize.y }, .{}, .{ .x = 1.0, .y = 1.0 }, col_u32);
        ctx.CursorScreenPos.y += entry.DisplaySize.y;
    }

    pub fn CalcTextSize(font: ?*ByteFont, font_size: f32, text: []const u8, text_end: ?usize, wrap_width: f32) ByteVec2 {
        const active_font = font orelse return .{};
        if (text.len == 0) return .{};
        return active_font.CalcTextSizeA(font_size, std.math.floatMax(f32), wrap_width, text, text_end);
    }

    pub fn CalcTextHitRect(font: ?*ByteFont, font_size: f32, pos: ByteVec2, text: []const u8, padding: f32, text_end: ?usize, wrap_width: f32) c.RECT {
        const active_font = font orelse return makeHitRectFromBounds(pos.x - padding, pos.y - padding, pos.x + padding, pos.y + padding);
        const slice = sliceFromOptionalEnd(text, text_end);
        const size = CalcTextSize(active_font, font_size, slice, null, wrap_width);
        const inset = textRenderInsetPx(font_size);
        return makeHitRectFromBounds(pos.x + inset - padding, pos.y + inset - padding, pos.x + inset + size.x + padding, pos.y + inset + size.y + padding);
    }

    pub fn CalcHorizontalNeighborHitRects(left_pos: ByteVec2, left_size: ByteVec2, right_pos: ByteVec2, right_size: ByteVec2, padding: ByteVec4, left_hit: ?*c.RECT, right_hit: ?*c.RECT) void {
        const band = makeHitRectFromBounds(
            left_pos.x - padding.x,
            @min(left_pos.y, right_pos.y) - padding.y,
            right_pos.x + right_size.x + padding.z,
            @max(left_pos.y + left_size.y, right_pos.y + right_size.y) + padding.w,
        );
        const boundary = band.left + @divTrunc(band.right - band.left, 2);

        if (left_hit) |rect| {
            rect.left = band.left;
            rect.top = band.top;
            rect.right = boundary;
            rect.bottom = band.bottom;
        }
        if (right_hit) |rect| {
            rect.left = boundary;
            rect.top = band.top;
            rect.right = band.right;
            rect.bottom = band.bottom;
        }
    }

    pub fn PointInRoundedRect(pt: c.POINT, rect: c.RECT, radius: f32) bool {
        const width = rect.right - rect.left;
        const height = rect.bottom - rect.top;
        const rounded_radius: i32 = @intFromFloat(@round(radius));
        const local_x = pt.x - rect.left;
        const local_y = pt.y - rect.top;

        if (local_x < 0 or local_y < 0 or local_x >= width or local_y >= height) return false;
        if ((local_x >= rounded_radius and local_x < width - rounded_radius) or (local_y >= rounded_radius and local_y < height - rounded_radius)) return true;

        const inside_corner = struct {
            fn call(px: i32, py: i32, cx: i32, cy: i32, rr: i32) bool {
                const dx = @as(f32, @floatFromInt(px)) + 0.5 - @as(f32, @floatFromInt(cx));
                const dy = @as(f32, @floatFromInt(py)) + 0.5 - @as(f32, @floatFromInt(cy));
                return (dx * dx + dy * dy) <= @as(f32, @floatFromInt(rr * rr));
            }
        }.call;

        if (local_x < rounded_radius and local_y < rounded_radius) return inside_corner(local_x, local_y, rounded_radius, rounded_radius, rounded_radius);
        if (local_x >= width - rounded_radius and local_y < rounded_radius) return inside_corner(local_x, local_y, width - rounded_radius - 1, rounded_radius, rounded_radius);
        if (local_x < rounded_radius and local_y >= height - rounded_radius) return inside_corner(local_x, local_y, rounded_radius, height - rounded_radius - 1, rounded_radius);
        if (local_x >= width - rounded_radius and local_y >= height - rounded_radius) return inside_corner(local_x, local_y, width - rounded_radius - 1, height - rounded_radius - 1, rounded_radius);

        return true;
    }

    pub fn BuildRoundedRectPolygon(size: ByteVec2, radius: f32, inset: f32, arc_segments: i32) ByteVec2List {
        const clamped_radius = @max(0.0, radius - inset);
        const left = inset;
        const top = inset;
        const right = size.x - inset;
        const bottom = size.y - inset;
        const segments: i32 = if (arc_segments > 0) arc_segments else 8;
        const step = (0.5 * kPi) / @as(f32, @floatFromInt(segments));

        var points = ByteVec2List{};
        points.ensureTotalCapacity(allocator, @intCast((segments + 1) * 4)) catch return .{};

        const add_arc = struct {
            fn call(list: *ByteVec2List, cx: f32, cy: f32, start_angle: f32, step_angle: f32, rad: f32, segments_local: i32) void {
                var i: i32 = 0;
                while (i <= segments_local) : (i += 1) {
                    const angle = start_angle + step_angle * @as(f32, @floatFromInt(i));
                    list.appendAssumeCapacity(.{ .x = cx + @cos(angle) * rad, .y = cy + @sin(angle) * rad });
                }
            }
        }.call;

        add_arc(&points, left + clamped_radius, top + clamped_radius, kPi, step, clamped_radius, segments);
        add_arc(&points, right - clamped_radius, top + clamped_radius, -0.5 * kPi, step, clamped_radius, segments);
        add_arc(&points, right - clamped_radius, bottom - clamped_radius, 0.0, step, clamped_radius, segments);
        add_arc(&points, left + clamped_radius, bottom - clamped_radius, 0.5 * kPi, step, clamped_radius, segments);
        return points;
    }

    pub fn BuildRectPolygon(left: f32, top: f32, right: f32, bottom: f32) ByteVec2List {
        var points = ByteVec2List{};
        points.ensureTotalCapacity(allocator, 4) catch return .{};
        points.appendAssumeCapacity(.{ .x = left, .y = top });
        points.appendAssumeCapacity(.{ .x = right, .y = top });
        points.appendAssumeCapacity(.{ .x = right, .y = bottom });
        points.appendAssumeCapacity(.{ .x = left, .y = bottom });
        return points;
    }

    pub fn BuildCornerSectorPolygon(center: ByteVec2, radius: f32, start_angle: f32, end_angle: f32, arc_segments: i32) ByteVec2List {
        const segments: i32 = if (arc_segments > 0) arc_segments else 8;
        var points = ByteVec2List{};
        points.ensureTotalCapacity(allocator, @intCast(segments + 3)) catch return .{};
        points.appendAssumeCapacity(center);

        var i: i32 = 0;
        while (i <= segments) : (i += 1) {
            const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments));
            const angle = start_angle + (end_angle - start_angle) * t;
            points.appendAssumeCapacity(.{ .x = center.x + @cos(angle) * radius, .y = center.y + @sin(angle) * radius });
        }
        return points;
    }

    pub fn ClipPolygonAgainstConvexPolygon(subject: []const ByteVec2, clip: []const ByteVec2) ByteVec2List {
        if (subject.len == 0 or clip.len < 3) return .{};

        var output = ByteVec2List{};
        output.ensureTotalCapacity(allocator, @intCast(subject.len)) catch return .{};
        for (subject) |point| output.appendAssumeCapacity(point);

        const clip_is_ccw = signedArea(clip) > 0.0;
        for (clip, 0..) |clip_a, i| {
            const clip_b = clip[(i + 1) % clip.len];
            if (output.items.len == 0) break;

            var input = output;
            output = .{};
            defer input.deinit(allocator);

            var prev = input.items[input.items.len - 1];
            var prev_inside = isInsideClipEdge(clip_is_ccw, clip_a, clip_b, prev);
            for (input.items) |cur| {
                const cur_inside = isInsideClipEdge(clip_is_ccw, clip_a, clip_b, cur);
                if (cur_inside != prev_inside) addUniquePoint(&output, lineIntersection(prev, cur, clip_a, clip_b));
                if (cur_inside) addUniquePoint(&output, cur);
                prev = cur;
                prev_inside = cur_inside;
            }
        }

        if (output.items.len > 1) {
            const first = output.items[0];
            const last = output.items[output.items.len - 1];
            if (approxEqual(first.x, last.x, 0.01) and approxEqual(first.y, last.y, 0.01)) _ = output.pop();
        }
        return output;
    }

    pub fn DrawCornerOnlyRoundedRectFilled(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, radius: f32, col: ByteU32, arc_segments: i32) void {
        const active_draw = draw orelse return;
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

        const corner_span = @max(0.0, radius);
        if (corner_span <= 0.0) {
            active_draw.AddRectFilled(pos, .{ .x = pos.x + size.x, .y = pos.y + size.y }, col, 0.0);
            return;
        }

        const inner_left = pos.x + corner_span;
        const inner_top = pos.y + corner_span;
        const inner_right = pos.x + size.x - corner_span;
        const inner_bottom = pos.y + size.y - corner_span;

        active_draw.AddRectFilled(.{ .x = inner_left, .y = pos.y }, .{ .x = inner_right, .y = pos.y + size.y }, col, 0.0);
        active_draw.AddRectFilled(.{ .x = pos.x, .y = inner_top }, .{ .x = inner_left, .y = inner_bottom }, col, 0.0);
        active_draw.AddRectFilled(.{ .x = inner_right, .y = inner_top }, .{ .x = pos.x + size.x, .y = inner_bottom }, col, 0.0);

        drawCornerWedgeInternal(active_draw, .{ .x = inner_left, .y = inner_top }, corner_span, kPi, kPi * 1.5, col, arc_segments);
        drawCornerWedgeInternal(active_draw, .{ .x = inner_right, .y = inner_top }, corner_span, kPi * 1.5, kPi * 2.0, col, arc_segments);
        drawCornerWedgeInternal(active_draw, .{ .x = inner_right, .y = inner_bottom }, corner_span, 0.0, kPi * 0.5, col, arc_segments);
        drawCornerWedgeInternal(active_draw, .{ .x = inner_left, .y = inner_bottom }, corner_span, kPi * 0.5, kPi, col, arc_segments);
    }

    pub fn DrawConvexPolyFilledClippedToCornerOnlyRoundedRect(draw: ?*ByteDrawList, subject: []const ByteVec2, pos: ByteVec2, size: ByteVec2, radius: f32, col: ByteU32, arc_segments: i32) void {
        const active_draw = draw orelse return;
        if (subject.len < 3 or (col & BYTEGUI_COL32_A_MASK) == 0) return;

        const corner_span = @max(0.0, radius);
        if (corner_span <= 0.0) {
            active_draw.AddConvexPolyFilled(subject, col);
            return;
        }

        const inner_left = pos.x + corner_span;
        const inner_top = pos.y + corner_span;
        const inner_right = pos.x + size.x - corner_span;
        const inner_bottom = pos.y + size.y - corner_span;
        const segments = if (arc_segments > 0) arc_segments else @max(@as(i32, 6), @divTrunc(calcCircleSegmentCount(corner_span), 4));

        var crisp_region_a = BuildRectPolygon(inner_left, pos.y, inner_right, pos.y + size.y);
        defer crisp_region_a.deinit(allocator);
        var crisp_region_b = BuildRectPolygon(pos.x, inner_top, inner_left, inner_bottom);
        defer crisp_region_b.deinit(allocator);
        var crisp_region_c = BuildRectPolygon(inner_right, inner_top, pos.x + size.x, inner_bottom);
        defer crisp_region_c.deinit(allocator);

        var aa_region_a = BuildCornerSectorPolygon(.{ .x = inner_left, .y = inner_top }, corner_span, kPi, kPi * 1.5, segments);
        defer aa_region_a.deinit(allocator);
        var aa_region_b = BuildCornerSectorPolygon(.{ .x = inner_right, .y = inner_top }, corner_span, kPi * 1.5, kPi * 2.0, segments);
        defer aa_region_b.deinit(allocator);
        var aa_region_c = BuildCornerSectorPolygon(.{ .x = inner_right, .y = inner_bottom }, corner_span, 0.0, kPi * 0.5, segments);
        defer aa_region_c.deinit(allocator);
        var aa_region_d = BuildCornerSectorPolygon(.{ .x = inner_left, .y = inner_bottom }, corner_span, kPi * 0.5, kPi, segments);
        defer aa_region_d.deinit(allocator);

        const old_flags = active_draw.Flags;
        active_draw.Flags &= ~ByteDrawListFlags_AntiAliasedFill;
        const crisp_regions = [_][]const ByteVec2{ crisp_region_a.items, crisp_region_b.items, crisp_region_c.items };
        for (crisp_regions) |region| {
            var clipped = ClipPolygonAgainstConvexPolygon(subject, region);
            defer clipped.deinit(allocator);
            if (clipped.items.len >= 3) active_draw.AddConvexPolyFilled(clipped.items, col);
        }
        active_draw.Flags = old_flags;

        const aa_regions = [_][]const ByteVec2{ aa_region_a.items, aa_region_b.items, aa_region_c.items, aa_region_d.items };
        for (aa_regions) |region| {
            var clipped = ClipPolygonAgainstConvexPolygon(subject, region);
            defer clipped.deinit(allocator);
            if (clipped.items.len >= 3) active_draw.AddConvexPolyFilled(clipped.items, col);
        }
    }

    pub fn DrawFlatSegment(draw: ?*ByteDrawList, from: ByteVec2, to: ByteVec2, thickness: f32, col: ByteU32) void {
        const active_draw = draw orelse return;
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

        const dx = to.x - from.x;
        const dy = to.y - from.y;
        const len = @sqrt(dx * dx + dy * dy);
        if (len <= 0.0) return;

        const half = thickness * 0.5;
        const nx = -dy / len * half;
        const ny = dx / len * half;
        const quad = [_]ByteVec2{
            .{ .x = from.x + nx, .y = from.y + ny },
            .{ .x = from.x - nx, .y = from.y - ny },
            .{ .x = to.x - nx, .y = to.y - ny },
            .{ .x = to.x + nx, .y = to.y + ny },
        };
        active_draw.AddConvexPolyFilled(&quad, col);
    }

    pub fn DrawWindowControlGlyph(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, col: ByteU32, is_close: bool) void {
        const active_draw = draw orelse return;
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

        if (is_close) {
            const cx = pos.x + size.x * 0.5;
            const cy = pos.y + size.y * 0.5;
            const pad = @min(size.x, size.y) * 0.24;
            const stroke = @max(1.0, @min(size.x, size.y) * 0.07);
            DrawFlatSegment(active_draw, .{ .x = cx - pad, .y = cy - pad }, .{ .x = cx + pad, .y = cy + pad }, stroke, col);
            DrawFlatSegment(active_draw, .{ .x = cx - pad, .y = cy + pad }, .{ .x = cx + pad, .y = cy - pad }, stroke, col);
            return;
        }

        const stroke = @max(1.0, size.y * 0.08);
        const bar_len = size.x * 0.95;
        const x_start = @floor(pos.x + (size.x - bar_len) * 0.5 + 0.5);
        const y_top = @floor(pos.y + size.y * 0.57 - stroke * 0.5 + 0.5);
        const width = @floor(bar_len + 0.5);
        const height: f32 = @floatFromInt(@max(@as(i32, 1), @as(i32, @intFromFloat(@round(stroke)))));
        active_draw.AddRectFilled(.{ .x = x_start, .y = y_top }, .{ .x = x_start + width, .y = y_top + height }, col, 0.0);
    }

    pub fn DrawInfoGlyph(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, ring_col: ByteU32, background_col: ByteU32, arc_segments: i32) void {
        const active_draw = draw orelse return;
        if ((ring_col & BYTEGUI_COL32_A_MASK) == 0) return;

        const icon_size = @min(size.x, size.y);
        const padding = @max(1.0, icon_size * 0.12);
        const circle_size = icon_size - padding * 2.0;
        const circle_left = pos.x + (size.x - icon_size) * 0.5;
        const circle_top = pos.y + (size.y - icon_size) * 0.5;
        const center = ByteVec2{
            .x = @floor(circle_left + padding + circle_size * 0.5 + 0.5),
            .y = @floor(circle_top + padding + circle_size * 0.5 + 0.5),
        };
        const stroke = @max(1.0, circle_size * 0.07);
        const outer_radius = @floor(circle_size * 0.5 + 0.5);
        const inner_radius = @max(0.0, outer_radius - stroke);
        const segments = if (arc_segments > 0) arc_segments else std.math.clamp(calcCircleSegmentCount(outer_radius) * 2, 72, 160);

        active_draw.AddCircleFilled(center, outer_radius, ring_col, segments);
        if (inner_radius > 0.0 and (background_col & BYTEGUI_COL32_A_MASK) != 0) active_draw.AddCircleFilled(center, inner_radius, background_col, segments);

        const stem_width = circle_size * 0.095;
        const stem_height = circle_size * 0.42;
        const stem_x = center.x - stem_width * 0.5;
        const stem_y = circle_top + padding + circle_size * 0.40;
        active_draw.AddRectFilled(.{ .x = stem_x, .y = stem_y }, .{ .x = stem_x + stem_width, .y = stem_y + stem_height }, ring_col, 0.0);

        const dot_diameter = circle_size * 0.115;
        active_draw.AddCircleFilled(
            .{ .x = center.x, .y = circle_top + padding + circle_size * 0.20 + dot_diameter * 0.5 },
            dot_diameter * 0.5,
            ring_col,
            std.math.clamp(@divTrunc(segments, 3), 24, 64),
        );
    }

    pub fn DrawTextCentered(draw: ?*ByteDrawList, font: ?*ByteFont, font_size: f32, pos: ByteVec2, size: ByteVec2, col: ByteU32, text: []const u8, snap_to_pixel: bool) void {
        const active_draw = draw orelse return;
        if (text.len == 0 or (col & BYTEGUI_COL32_A_MASK) == 0) return;

        const text_size = CalcTextSize(font, font_size, text, null, 0.0);
        var text_pos = ByteVec2{ .x = pos.x + (size.x - text_size.x) * 0.5, .y = pos.y + (size.y - text_size.y) * 0.5 };
        if (snap_to_pixel) text_pos = .{ .x = @floor(text_pos.x + 0.5), .y = @floor(text_pos.y + 0.5) };
        active_draw.AddText(font, font_size, text_pos, col, text, null);
    }

    pub fn PushFont(font: ?*ByteFont) void {
        const ctx = GByteGui orelse return;
        const active = font orelse return;
        ctx.FontStack.append(allocator, active) catch return;
        ctx.CurrentFont = active;
    }

    pub fn PopFont() void {
        const ctx = GByteGui orelse return;
        if (ctx.FontStack.items.len == 0) return;
        _ = ctx.FontStack.pop();
        if (ctx.FontStack.items.len > 0) {
            ctx.CurrentFont = ctx.FontStack.items[ctx.FontStack.items.len - 1];
        } else if (ctx.IO.Fonts) |fonts| {
            ctx.CurrentFont = if (fonts.Fonts.items.len > 0) fonts.Fonts.items[0] else null;
        } else {
            ctx.CurrentFont = null;
        }
    }

    pub fn PushStyleVar(idx: ByteGuiStyleVar, val: f32) void {
        const ctx = GByteGui orelse return;
        if (idx != ByteGuiStyleVar_Alpha) return;
        ctx.AlphaStack.append(allocator, ctx.Style.Alpha) catch return;
        ctx.Style.Alpha = val;
    }

    pub fn PopStyleVar(count: i32) void {
        const ctx = GByteGui orelse return;
        var remaining = count;
        while (remaining > 0 and ctx.AlphaStack.items.len > 0) : (remaining -= 1) {
            ctx.Style.Alpha = ctx.AlphaStack.pop().?;
        }
    }
};

// UI Helper Layer
// These helpers keep application-facing window code focused on state and flow,
// while ByteGui owns the reusable math, drawing, and GDI texture work.
pub const Ui = struct {
    pub const TextTexture = struct {
        texture: ?*c.ID3D11ShaderResourceView = null,
        display_size_px: ByteVec2 = .{},
    };

    pub fn CleanupTexture(texture: *?*c.ID3D11ShaderResourceView) void {
        releaseShaderResourceView(texture.*);
        texture.* = null;
    }

    pub fn CleanupTextTexture(texture: *TextTexture) void {
        CleanupTexture(&texture.texture);
        texture.display_size_px = .{};
    }

    pub fn Clamp01(v: f32) f32 {
        return clamp01(v);
    }

    pub fn EaseOutQuad(t_in: f32) f32 {
        const t = Clamp01(t_in);
        return 1.0 - (1.0 - t) * (1.0 - t);
    }

    pub fn EaseInOutCubic(t_in: f32) f32 {
        const t = Clamp01(t_in);
        return if (t < 0.5) 4.0 * t * t * t else 1.0 - std.math.pow(f32, -2.0 * t + 2.0, 3.0) * 0.5;
    }

    pub fn LerpColor(a: ByteVec4, b: ByteVec4, t_in: f32) ByteVec4 {
        const t = Clamp01(t_in);
        return .{
            .x = a.x + (b.x - a.x) * t,
            .y = a.y + (b.y - a.y) * t,
            .z = a.z + (b.z - a.z) * t,
            .w = a.w + (b.w - a.w) * t,
        };
    }

    pub fn ApplyOpacity(color: ByteVec4, opacity: f32) ByteVec4 {
        var out = color;
        out.w *= Clamp01(opacity);
        return out;
    }

    pub fn ColorToU32(color: ByteVec4) ByteU32 {
        return ByteGui.ColorConvertFloat4ToU32(color);
    }

    pub fn ScaleF(value: f32) f32 {
        return ByteGui_ImplWin32_ScaleF(value);
    }

    pub fn ScaleI(value: i32) i32 {
        return ByteGui_ImplWin32_ScaleI(value);
    }

    pub fn ScaleIF(value: f32) i32 {
        return ByteGui_ImplWin32_ScaleI_F(value);
    }

    pub fn ScaleVec2(x: f32, y: f32) ByteVec2 {
        return ByteGui_ImplWin32_ScaleVec2(x, y);
    }

    pub fn SnapPixel(value: f32) f32 {
        return ByteGui_ImplWin32_SnapPixel(value);
    }

    pub fn SnapPixelVec2(value: ByteVec2) ByteVec2 {
        return ByteGui_ImplWin32_SnapPixel(value);
    }

    pub fn MakeRectL(x: f32, y: f32, w: f32, h: f32) c.RECT {
        return .{
            .left = @intFromFloat(@floor(x)),
            .top = @intFromFloat(@floor(y)),
            .right = @intFromFloat(@ceil(x + w)),
            .bottom = @intFromFloat(@ceil(y + h)),
        };
    }

    pub fn PointInRect(rect: anytype, pt: c.POINT) bool {
        return pt.x >= rect.left and pt.x < rect.right and pt.y >= rect.top and pt.y < rect.bottom;
    }

    pub fn RotatePoint(x: f32, y: f32, pivot_x: f32, pivot_y: f32, ccos: f32, ssin: f32) ByteVec2 {
        const dx = x - pivot_x;
        const dy = y - pivot_y;
        return .{
            .x = pivot_x + dx * ccos - dy * ssin,
            .y = pivot_y + dx * ssin + dy * ccos,
        };
    }

    pub fn PointInCornerOnlyRoundedRect(pt: c.POINT, pos: ByteVec2, size: ByteVec2, radius: f32) bool {
        const left = pos.x;
        const top = pos.y;
        const right = pos.x + size.x;
        const bottom = pos.y + size.y;
        const px: f32 = @floatFromInt(pt.x);
        const py: f32 = @floatFromInt(pt.y);
        if (px < left or px >= right or py < top or py >= bottom) return false;

        const r = SnapPixel(radius);
        if (r <= 0.0) return true;
        if (px >= left + r and px < right - r) return true;
        if (py >= top + r and py < bottom - r) return true;

        const cx = if (px < left + r) left + r else right - r;
        const cy = if (py < top + r) top + r else bottom - r;
        const dx = px - cx;
        const dy = py - cy;
        return dx * dx + dy * dy <= r * r;
    }

    pub fn DrawRotatedRectClippedToCornerOnlyRoundedRect(
        draw: ?*ByteDrawList,
        rect_pos: ByteVec2,
        rect_size: ByteVec2,
        pivot: ByteVec2,
        angle_radians: f32,
        clip_pos: ByteVec2,
        clip_size: ByteVec2,
        clip_radius: f32,
        col: ByteU32,
        arc_segments: i32,
    ) void {
        const active_draw = draw orelse return;
        const ccos = @cos(angle_radians);
        const ssin = @sin(angle_radians);
        const subject = [_]ByteVec2{
            RotatePoint(rect_pos.x, rect_pos.y, pivot.x, pivot.y, ccos, ssin),
            RotatePoint(rect_pos.x + rect_size.x, rect_pos.y, pivot.x, pivot.y, ccos, ssin),
            RotatePoint(rect_pos.x + rect_size.x, rect_pos.y + rect_size.y, pivot.x, pivot.y, ccos, ssin),
            RotatePoint(rect_pos.x, rect_pos.y + rect_size.y, pivot.x, pivot.y, ccos, ssin),
        };
        ByteGui.DrawConvexPolyFilledClippedToCornerOnlyRoundedRect(active_draw, &subject, clip_pos, clip_size, clip_radius, col, arc_segments);
    }

    pub fn DrawAnimatedTextureCentered(
        draw: ?*ByteDrawList,
        texture: *const TextTexture,
        pos: ByteVec2,
        size: ByteVec2,
        fit_padding: ByteVec2,
        base_factor: f32,
        peak_factor: f32,
        anim: f32,
        opacity: f32,
    ) bool {
        const active_draw = draw orelse return false;
        if (texture.texture == null or texture.display_size_px.x <= 0.0 or texture.display_size_px.y <= 0.0) return false;

        const max_w = size.x - fit_padding.x;
        const max_h = size.y - fit_padding.y;
        const fit_scale = @min(1.0, @min(max_w / texture.display_size_px.x, max_h / texture.display_size_px.y));
        const final_scale = fit_scale * (base_factor + (peak_factor - base_factor) * Clamp01(anim));
        const image_size = ByteVec2{
            .x = texture.display_size_px.x * final_scale,
            .y = texture.display_size_px.y * final_scale,
        };
        const image_pos = ByteVec2{
            .x = pos.x + (size.x - image_size.x) * 0.5,
            .y = pos.y + (size.y - image_size.y) * 0.5,
        };

        active_draw.AddImage(
            @ptrCast(texture.texture),
            image_pos,
            .{ .x = image_pos.x + image_size.x, .y = image_pos.y + image_size.y },
            .{},
            .{ .x = 1.0, .y = 1.0 },
            ColorToU32(ApplyOpacity(.{ .x = 1.0, .y = 1.0, .z = 1.0, .w = 1.0 }, opacity)),
        );
        return true;
    }

    pub fn BuildTextTexture(out_texture: *TextTexture, text: [*:0]const u16, family_name: [*:0]const u16, font_style: i32, logical_font_size: f32, supersample: f32, pad_scale: f32, layout_scale: f32) bool {
        CleanupTextTexture(out_texture);
        if (ByteGui_ImplDX11_GetDevice() == null or !ensureByteGuiGdiPlus()) return false;

        var family: ?*c.GpFontFamily = null;
        if (!gdipOk(c.GdipCreateFontFamilyFromName(family_name, null, &family)) or family == null) return false;
        defer _ = c.GdipDeleteFontFamily(family);

        const ss: i32 = @intFromFloat(supersample);
        const raster_scale = ByteGui_ImplWin32_GetDpiScale() * supersample;
        const raster_font_size = logical_font_size * raster_scale;

        var font: ?*c.GpFont = null;
        if (!gdipOk(c.GdipCreateFont(family, raster_font_size, font_style, c.UnitPixel, &font)) or font == null) return false;
        defer _ = c.GdipDeleteFont(font);

        var format: ?*c.GpStringFormat = null;
        if (!gdipOk(c.GdipCreateStringFormat(0, 0, &format)) or format == null) return false;
        defer _ = c.GdipDeleteStringFormat(format);
        _ = c.GdipSetStringFormatFlags(format, c.StringFormatFlagsNoClip | c.StringFormatFlagsNoFitBlackBox);
        _ = c.GdipSetStringFormatAlign(format, c.StringAlignmentNear);
        _ = c.GdipSetStringFormatLineAlign(format, c.StringAlignmentNear);

        const measure_bitmap = createGdipBitmap(1, 1) orelse return false;
        defer _ = c.GdipDisposeImage(@ptrCast(measure_bitmap));
        const measure_graphics = createGdipGraphicsForImage(@ptrCast(measure_bitmap)) orelse return false;
        defer _ = c.GdipDeleteGraphics(measure_graphics);
        _ = c.GdipSetTextRenderingHint(measure_graphics, c.TextRenderingHintAntiAliasGridFit);

        var measure_bounds = std.mem.zeroes(c.RectF);
        var layout_rect = c.RectF{ .X = 0.0, .Y = 0.0, .Width = 4096.0, .Height = 4096.0 };
        if (!gdipOk(c.GdipMeasureString(measure_graphics, text, -1, font, &layout_rect, format, &measure_bounds, null, null))) return false;
        if (measure_bounds.Width <= 0.0 or measure_bounds.Height <= 0.0) return false;

        const pad_px = alignUpInt(@max(2, @as(i32, @intFromFloat(@ceil(raster_scale * pad_scale)))), ss);
        const pixel_w: u32 = @intCast(alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(measure_bounds.Width))) + pad_px * 2), ss));
        const pixel_h: u32 = @intCast(alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(measure_bounds.Height))) + pad_px * 2), ss));

        const bitmap = createGdipBitmap(@intCast(pixel_w), @intCast(pixel_h)) orelse return false;
        defer _ = c.GdipDisposeImage(@ptrCast(bitmap));
        const graphics = createGdipGraphicsForImage(@ptrCast(bitmap)) orelse return false;
        defer _ = c.GdipDeleteGraphics(graphics);

        _ = c.GdipSetSmoothingMode(graphics, c.SmoothingModeHighQuality);
        _ = c.GdipSetPixelOffsetMode(graphics, c.PixelOffsetModeHighQuality);
        _ = c.GdipSetInterpolationMode(graphics, c.InterpolationModeHighQualityBicubic);
        _ = c.GdipSetCompositingQuality(graphics, c.CompositingQualityHighQuality);
        _ = c.GdipSetTextRenderingHint(graphics, c.TextRenderingHintAntiAliasGridFit);
        _ = c.GdipGraphicsClear(graphics, 0);

        var brush: ?*c.GpSolidFill = null;
        if (!gdipOk(c.GdipCreateSolidFill(0xFF000000, &brush)) or brush == null) return false;
        defer _ = c.GdipDeleteBrush(@ptrCast(brush));

        var draw_rect = c.RectF{
            .X = @as(f32, @floatFromInt(pad_px)) - measure_bounds.X,
            .Y = @as(f32, @floatFromInt(pad_px)) - measure_bounds.Y,
            .Width = 4096.0,
            .Height = 4096.0,
        };
        if (!gdipOk(c.GdipDrawString(graphics, text, -1, font, &draw_rect, format, @ptrCast(brush)))) return false;

        out_texture.texture = createTextureFromGdipBitmap(bitmap) orelse return false;
        out_texture.display_size_px = .{
            .x = (@as(f32, @floatFromInt(pixel_w)) / supersample) * layout_scale,
            .y = (@as(f32, @floatFromInt(pixel_h)) / supersample) * layout_scale,
        };
        return true;
    }

    pub const SvgTextureBuildParams = struct {
        svg_path: []const u8,
        canvas_pos: ByteVec2,
        canvas_size: ByteVec2,
        supersample: f32,
        fill_argb: c.ARGB,
        text: [*:0]const u16,
        text_family: [*:0]const u16,
        text_style: i32,
        text_em_size: f32,
        logo_scale: ByteVec2,
        logo_translate: ByteVec2,
        text_scale: ByteVec2,
        text_translate: ByteVec2,
    };

    pub fn BuildSvgTexture(out_texture: *?*c.ID3D11ShaderResourceView, out_origin: *ByteVec2, out_size: *ByteVec2, params: SvgTextureBuildParams) bool {
        CleanupTexture(out_texture);
        out_origin.* = .{};
        out_size.* = .{};
        if (ByteGui_ImplDX11_GetDevice() == null or !ensureByteGuiGdiPlus()) return false;

        const logo_path = createGdipPath() orelse return false;
        defer _ = c.GdipDeletePath(logo_path);
        gdiSvgParsePath(params.svg_path, logo_path);

        const logo_matrix = createGdipMatrix() orelse return false;
        defer _ = c.GdipDeleteMatrix(logo_matrix);
        _ = c.GdipScaleMatrix(logo_matrix, params.logo_scale.x, params.logo_scale.y, c.MatrixOrderPrepend);
        _ = c.GdipTranslateMatrix(logo_matrix, params.logo_translate.x, params.logo_translate.y, c.MatrixOrderPrepend);
        _ = c.GdipTransformPath(logo_path, logo_matrix);

        const text_path = createGdipPath() orelse return false;
        defer _ = c.GdipDeletePath(text_path);

        var font_family: ?*c.GpFontFamily = null;
        if (!gdipOk(c.GdipCreateFontFamilyFromName(params.text_family, null, &font_family)) or font_family == null) return false;
        defer _ = c.GdipDeleteFontFamily(font_family);

        var text_rect = c.RectF{ .X = 0.0, .Y = 0.0, .Width = 4096.0, .Height = 4096.0 };
        if (!gdipOk(c.GdipAddPathString(text_path, params.text, -1, font_family, params.text_style, params.text_em_size, &text_rect, null))) return false;

        const text_matrix = createGdipMatrix() orelse return false;
        defer _ = c.GdipDeleteMatrix(text_matrix);
        _ = c.GdipScaleMatrix(text_matrix, params.text_scale.x, params.text_scale.y, c.MatrixOrderPrepend);
        _ = c.GdipTranslateMatrix(text_matrix, params.text_translate.x, params.text_translate.y, c.MatrixOrderPrepend);
        _ = c.GdipTransformPath(text_path, text_matrix);

        const pixel_path = createGdipPath() orelse return false;
        defer _ = c.GdipDeletePath(pixel_path);
        _ = c.GdipAddPathPath(pixel_path, logo_path, c.FALSE);
        _ = c.GdipAddPathPath(pixel_path, text_path, c.FALSE);

        const ss: i32 = @intFromFloat(params.supersample);
        const raster_scale = ByteGui_ImplWin32_GetDpiScale() * params.supersample;

        const dpi_matrix = createGdipMatrix() orelse return false;
        defer _ = c.GdipDeleteMatrix(dpi_matrix);
        _ = c.GdipScaleMatrix(dpi_matrix, raster_scale, raster_scale, c.MatrixOrderPrepend);
        _ = c.GdipTransformPath(pixel_path, dpi_matrix);

        const pad_px = alignUpInt(@max(2, @as(i32, @intFromFloat(@ceil(raster_scale * 2.0)))), ss);
        const pixel_w: u32 = @intCast(alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(params.canvas_size.x * raster_scale))) + pad_px * 2), ss));
        const pixel_h: u32 = @intCast(alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(params.canvas_size.y * raster_scale))) + pad_px * 2), ss));

        const shift_matrix = createGdipMatrix() orelse return false;
        defer _ = c.GdipDeleteMatrix(shift_matrix);
        _ = c.GdipTranslateMatrix(
            shift_matrix,
            @as(f32, @floatFromInt(pad_px)) - params.canvas_pos.x * raster_scale,
            @as(f32, @floatFromInt(pad_px)) - params.canvas_pos.y * raster_scale,
            c.MatrixOrderPrepend,
        );
        _ = c.GdipTransformPath(pixel_path, shift_matrix);

        const bitmap = createGdipBitmap(@intCast(pixel_w), @intCast(pixel_h)) orelse return false;
        defer _ = c.GdipDisposeImage(@ptrCast(bitmap));
        const graphics = createGdipGraphicsForImage(@ptrCast(bitmap)) orelse return false;
        defer _ = c.GdipDeleteGraphics(graphics);

        _ = c.GdipSetSmoothingMode(graphics, c.SmoothingModeHighQuality);
        _ = c.GdipSetPixelOffsetMode(graphics, c.PixelOffsetModeHighQuality);
        _ = c.GdipSetInterpolationMode(graphics, c.InterpolationModeHighQualityBicubic);
        _ = c.GdipSetCompositingQuality(graphics, c.CompositingQualityHighQuality);
        _ = c.GdipGraphicsClear(graphics, gdiArgb(0, 0, 0, 0));

        var brush: ?*c.GpSolidFill = null;
        if (!gdipOk(c.GdipCreateSolidFill(params.fill_argb, &brush)) or brush == null) return false;
        defer _ = c.GdipDeleteBrush(@ptrCast(brush));

        if (!gdipOk(c.GdipFillPath(graphics, @ptrCast(brush), pixel_path))) return false;

        out_texture.* = createTextureFromGdipBitmap(bitmap) orelse return false;
        const display_pad_px = @as(f32, @floatFromInt(pad_px)) / params.supersample;
        out_origin.* = SnapPixelVec2(.{
            .x = ScaleF(params.canvas_pos.x) - display_pad_px,
            .y = ScaleF(params.canvas_pos.y) - display_pad_px,
        });
        out_size.* = .{
            .x = @as(f32, @floatFromInt(pixel_w)) / params.supersample,
            .y = @as(f32, @floatFromInt(pixel_h)) / params.supersample,
        };
        return true;
    }
};

fn clamp01(v: f32) f32 {
    return if (v < 0.0) 0.0 else if (v > 1.0) 1.0 else v;
}

fn byteLengthSqr(v: ByteVec2) f32 {
    return v.x * v.x + v.y * v.y;
}

fn equalClipRect(a: ByteVec4, b: ByteVec4) bool {
    return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w;
}

fn makeHitRectFromBounds(left: f32, top: f32, right: f32, bottom: f32) c.RECT {
    return .{
        .left = @intFromFloat(@floor(left)),
        .top = @intFromFloat(@floor(top)),
        .right = @intFromFloat(@ceil(right)),
        .bottom = @intFromFloat(@ceil(bottom)),
    };
}

fn alignUpInt(value: i32, alignment: i32) i32 {
    if (alignment <= 1) return value;
    return @divTrunc(value + alignment - 1, alignment) * alignment;
}

fn subVec2(a: ByteVec2, b: ByteVec2) ByteVec2 {
    return .{ .x = a.x - b.x, .y = a.y - b.y };
}

fn sliceFromOptionalEnd(text_begin: []const u8, text_end: ?usize) []const u8 {
    if (text_end) |idx| return text_begin[0..@min(idx, text_begin.len)];
    return text_begin;
}

fn approxEqual(a: f32, b: f32, eps: f32) bool {
    return @abs(a - b) < eps;
}

fn addUniquePoint(polygon: *ByteVec2List, point: ByteVec2) void {
    if (polygon.items.len > 0) {
        const prev = polygon.items[polygon.items.len - 1];
        if (approxEqual(prev.x, point.x, 0.01) and approxEqual(prev.y, point.y, 0.01)) return;
    }
    polygon.append(allocator, point) catch return;
}

fn signedArea(polygon: []const ByteVec2) f32 {
    var area: f32 = 0.0;
    for (polygon, 0..) |a, i| {
        const b = polygon[(i + 1) % polygon.len];
        area += a.x * b.y - b.x * a.y;
    }
    return area * 0.5;
}

fn isInsideClipEdge(clip_is_ccw: bool, a: ByteVec2, b: ByteVec2, p: ByteVec2) bool {
    const cross = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
    return if (clip_is_ccw) cross >= -0.001 else cross <= 0.001;
}

fn lineIntersection(p0: ByteVec2, p1: ByteVec2, q0: ByteVec2, q1: ByteVec2) ByteVec2 {
    const a1 = p1.y - p0.y;
    const b1 = p0.x - p1.x;
    const c1 = a1 * p0.x + b1 * p0.y;

    const a2 = q1.y - q0.y;
    const b2 = q0.x - q1.x;
    const c2 = a2 * q0.x + b2 * q0.y;

    const det = a1 * b2 - a2 * b1;
    if (@abs(det) < 0.0001) return p1;
    return .{
        .x = (b2 * c1 - b1 * c2) / det,
        .y = (a1 * c2 - a2 * c1) / det,
    };
}

fn drawCornerWedgeInternal(draw: *ByteDrawList, center: ByteVec2, radius: f32, a_min: f32, a_max: f32, col: ByteU32, arc_segments: i32) void {
    if (radius <= 0.0) return;
    const segments = if (arc_segments > 0) arc_segments else @max(@as(i32, 6), @divTrunc(calcCircleSegmentCount(radius), 4));
    draw.PathLineTo(center);
    draw.PathArcTo(center, radius, a_min, a_max, segments);
    draw.PathFillConvex(col);
}

fn appendArc(points: *ByteVec2List, center: ByteVec2, radius: f32, a_min: f32, a_max: f32, num_segments: i32) void {
    if (radius <= 0.0) {
        points.append(allocator, center) catch return;
        return;
    }

    var segments = num_segments;
    if (segments <= 0) {
        const span = @abs(a_max - a_min);
        segments = @intFromFloat(@ceil((span / (2.0 * kPi)) * @as(f32, @floatFromInt(calcCircleSegmentCount(radius)))));
        segments = @max(3, segments);
    }

    var i: i32 = 0;
    while (i <= segments) : (i += 1) {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments));
        const a = a_min + (a_max - a_min) * t;
        points.append(allocator, .{ .x = center.x + @cos(a) * radius, .y = center.y + @sin(a) * radius }) catch return;
    }
}

fn calcCircleSegmentCount(radius: f32) i32 {
    const tessellation_error = if (GByteGui) |ctx| @max(0.05, ctx.Style.CircleTessellationMaxError) else 0.10;
    if (radius <= 0.0) return 12;
    const max_error = @min(tessellation_error, radius);
    const angle = std.math.acos(@max(0.0, 1.0 - max_error / radius));
    if (angle <= 0.0) return 12;
    const segments: i32 = @intFromFloat(@ceil((2.0 * kPi) / (2.0 * angle)));
    return std.math.clamp(segments, 12, 96);
}

fn systemFontPath(comptime file_name: []const u8) ?[]u8 {
    var windir_utf16: [260]u16 = undefined;
    const windir_len = c.GetEnvironmentVariableW(std.unicode.utf8ToUtf16LeStringLiteral("WINDIR"), &windir_utf16, windir_utf16.len);
    if (windir_len == 0 or windir_len >= windir_utf16.len) return null;
    const windir = std.unicode.utf16LeToUtf8Alloc(allocator, windir_utf16[0..windir_len]) catch return null;
    defer allocator.free(windir);
    return std.fs.path.join(allocator, &.{ windir, "Fonts", file_name }) catch null;
}

fn detectFontStyleFromPath(path: []const u8) i32 {
    const lower = std.ascii.allocLowerString(allocator, path) catch return FontStyleRegular;
    defer allocator.free(lower);

    if (std.mem.indexOf(u8, lower, "bold") != null or std.mem.indexOf(u8, lower, "euib") != null or std.mem.indexOf(u8, lower, "bd") != null) return FontStyleBold;
    return FontStyleRegular;
}

// GDI+ Font And Text Rendering
const TextLine = struct {
    start: usize,
    end: usize,
    width: f32 = 0.0,
    bounds: c.RectF = std.mem.zeroes(c.RectF),
};

const KnownInstalledFamily = struct {
    utf8: []const u8,
    utf16: [*:0]const u16,
};

fn knownInstalledFamilyName(path: []const u8) ?KnownInstalledFamily {
    const lower = std.ascii.allocLowerString(allocator, path) catch return null;
    defer allocator.free(lower);

    if (std.mem.indexOf(u8, lower, "segoeui") != null or std.mem.indexOf(u8, lower, "segui") != null) {
        return .{ .utf8 = "Segoe UI", .utf16 = std.unicode.utf8ToUtf16LeStringLiteral("Segoe UI") };
    }
    if (std.mem.indexOf(u8, lower, "consola") != null) {
        return .{ .utf8 = "Consolas", .utf16 = std.unicode.utf8ToUtf16LeStringLiteral("Consolas") };
    }
    if (std.mem.indexOf(u8, lower, "impact") != null) {
        return .{ .utf8 = "Impact", .utf16 = std.unicode.utf8ToUtf16LeStringLiteral("Impact") };
    }
    return null;
}

fn dupeUtf16Z(text: [*:0]const u16) ![:0]u16 {
    const len = std.mem.len(text);
    const copy = try allocator.allocSentinel(u16, len, 0);
    @memcpy(copy[0..len], text[0..len]);
    return copy;
}

const TextMeasureSession = struct {
    bitmap: ?*c.GpBitmap = null,
    graphics: ?*c.GpGraphics = null,
    family: ?*c.GpFontFamily = null,
    font: ?*c.GpFont = null,
    format: ?*c.GpStringFormat = null,

    fn init(byte_font: *const ByteFont, size_pixels: f32) ?TextMeasureSession {
        if (size_pixels <= 0.0 or byte_font.FamilyNameWide == null) return null;
        if (!ensureByteGuiGdiPlus()) return null;

        var session = TextMeasureSession{};
        errdefer session.deinit();

        if (!gdipOk(c.GdipCreateFontFamilyFromName(byte_font.FamilyNameWide.?.ptr, byte_font.FontCollection, &session.family)) or session.family == null) {
            if (!gdipOk(c.GdipCreateFontFamilyFromName(byte_font.FamilyNameWide.?.ptr, null, &session.family)) or session.family == null) return null;
        }

        var resolved_style = byte_font.FontStyle;
        var style_available: c.BOOL = c.FALSE;
        if (!gdipOk(c.GdipIsStyleAvailable(session.family, resolved_style, &style_available)) or style_available == c.FALSE) {
            resolved_style = c.FontStyleRegular;
        }

        if (!gdipOk(c.GdipCreateFont(session.family, size_pixels, resolved_style, c.UnitPixel, &session.font)) or session.font == null) return null;
        if (!gdipOk(c.GdipCreateStringFormat(0, 0, &session.format)) or session.format == null) return null;

        const format_flags = c.StringFormatFlagsNoClip | c.StringFormatFlagsNoFitBlackBox | c.StringFormatFlagsMeasureTrailingSpaces | c.StringFormatFlagsNoWrap;
        _ = c.GdipSetStringFormatFlags(session.format, format_flags);
        _ = c.GdipSetStringFormatAlign(session.format, c.StringAlignmentNear);
        _ = c.GdipSetStringFormatLineAlign(session.format, c.StringAlignmentNear);

        session.bitmap = createGdipBitmap(1, 1) orelse return null;
        session.graphics = createGdipGraphicsForImage(@ptrCast(session.bitmap)) orelse return null;
        _ = c.GdipSetTextRenderingHint(session.graphics, c.TextRenderingHintAntiAliasGridFit);
        return session;
    }

    fn deinit(self: *TextMeasureSession) void {
        if (self.graphics != null) _ = c.GdipDeleteGraphics(self.graphics);
        if (self.bitmap != null) _ = c.GdipDisposeImage(@ptrCast(self.bitmap));
        if (self.format != null) _ = c.GdipDeleteStringFormat(self.format);
        if (self.font != null) _ = c.GdipDeleteFont(self.font);
        if (self.family != null) _ = c.GdipDeleteFontFamily(self.family);
        self.* = .{};
    }

    fn measureBounds(self: *TextMeasureSession, text: []const u8) ?c.RectF {
        if (text.len == 0) return std.mem.zeroes(c.RectF);

        const wide_text = std.unicode.utf8ToUtf16LeAllocZ(allocator, text) catch return null;
        defer allocator.free(wide_text);

        var bounds = std.mem.zeroes(c.RectF);
        var layout_rect = c.RectF{ .X = 0.0, .Y = 0.0, .Width = 32768.0, .Height = 32768.0 };
        if (!gdipOk(c.GdipMeasureString(self.graphics, wide_text.ptr, -1, self.font, &layout_rect, self.format, &bounds, null, null))) return null;
        return bounds;
    }

    fn measureWidth(self: *TextMeasureSession, text: []const u8) f32 {
        const bounds = self.measureBounds(text) orelse return 0.0;
        return @max(0.0, bounds.Width);
    }

    fn lineHeight(self: *TextMeasureSession) f32 {
        var line_height: f32 = 0.0;
        if (!gdipOk(c.GdipGetFontHeight(self.font, self.graphics, &line_height)) or line_height <= 0.0) return 1.0;
        return line_height;
    }
};

const TextLayoutResult = struct {
    lines: std.ArrayListUnmanaged(TextLine) = .{},
    width: f32 = 0.0,
    height: f32 = 0.0,
    line_height: f32 = 0.0,

    fn deinit(self: *TextLayoutResult) void {
        self.lines.deinit(allocator);
        self.* = .{};
    }
};

fn gdipOk(status: c.GpStatus) bool {
    return status == c.Ok;
}

fn createGdipBitmap(width: i32, height: i32) ?*c.GpBitmap {
    var bitmap: ?*c.GpBitmap = null;
    if (!gdipOk(c.GdipCreateBitmapFromScan0(width, height, 0, c.PixelFormat32bppARGB, null, &bitmap)) or bitmap == null) return null;
    return bitmap;
}

fn createGdipGraphicsForImage(image: ?*c.GpImage) ?*c.GpGraphics {
    var graphics: ?*c.GpGraphics = null;
    if (!gdipOk(c.GdipGetImageGraphicsContext(image, &graphics)) or graphics == null) return null;
    return graphics;
}

fn createGdipPath() ?*c.GpPath {
    var path: ?*c.GpPath = null;
    if (!gdipOk(c.GdipCreatePath(c.FillModeAlternate, &path)) or path == null) return null;
    return path;
}

fn createGdipMatrix() ?*c.GpMatrix {
    var matrix: ?*c.GpMatrix = null;
    if (!gdipOk(c.GdipCreateMatrix(&matrix)) or matrix == null) return null;
    return matrix;
}

fn gdiArgb(a: u8, r: u8, g: u8, b: u8) c.ARGB {
    return (@as(c.ARGB, a) << 24) | (@as(c.ARGB, r) << 16) | (@as(c.ARGB, g) << 8) | @as(c.ARGB, b);
}

const GdiSvgParser = struct {
    input: []const u8,
    index: usize = 0,
    current_x: f32 = 0.0,
    current_y: f32 = 0.0,
    start_x: f32 = 0.0,
    start_y: f32 = 0.0,
    last_control_x: f32 = 0.0,
    last_control_y: f32 = 0.0,
    last_cmd: u8 = 0,

    fn eof(self: *const GdiSvgParser) bool {
        return self.index >= self.input.len;
    }

    fn peek(self: *const GdiSvgParser) u8 {
        return if (self.index < self.input.len) self.input[self.index] else 0;
    }

    fn skipWhitespace(self: *GdiSvgParser) void {
        while (self.index < self.input.len) : (self.index += 1) {
            const ch = self.input[self.index];
            if (ch != ' ' and ch != ',' and ch != '\t' and ch != '\n' and ch != '\r') break;
        }
    }

    fn hasMoreNumbers(self: *GdiSvgParser) bool {
        self.skipWhitespace();
        if (self.eof()) return false;
        const ch = self.peek();
        return ch == '-' or ch == '+' or ch == '.' or (ch >= '0' and ch <= '9');
    }

    fn parseNumber(self: *GdiSvgParser) f32 {
        self.skipWhitespace();
        if (self.eof()) return 0.0;

        var negative = false;
        if (self.peek() == '-') {
            negative = true;
            self.index += 1;
        } else if (self.peek() == '+') {
            self.index += 1;
        }

        var result: f32 = 0.0;
        while (!self.eof()) {
            const ch = self.peek();
            if (ch < '0' or ch > '9') break;
            result = result * 10.0 + @as(f32, @floatFromInt(ch - '0'));
            self.index += 1;
        }

        if (!self.eof() and self.peek() == '.') {
            self.index += 1;
            var divisor: f32 = 10.0;
            while (!self.eof()) {
                const ch = self.peek();
                if (ch < '0' or ch > '9') break;
                result += @as(f32, @floatFromInt(ch - '0')) / divisor;
                divisor *= 10.0;
                self.index += 1;
            }
        }

        if (!self.eof()) {
            const ch = self.peek();
            if (ch == 'e' or ch == 'E') {
                self.index += 1;
                var exp_negative = false;
                if (!self.eof() and self.peek() == '-') {
                    exp_negative = true;
                    self.index += 1;
                } else if (!self.eof() and self.peek() == '+') {
                    self.index += 1;
                }

                var exponent: i32 = 0;
                while (!self.eof()) {
                    const digit = self.peek();
                    if (digit < '0' or digit > '9') break;
                    exponent = exponent * 10 + @as(i32, digit - '0');
                    self.index += 1;
                }
                if (exp_negative) exponent = -exponent;
                result *= std.math.pow(f32, 10.0, @as(f32, @floatFromInt(exponent)));
            }
        }

        return if (negative) -result else result;
    }
};

fn gdiSvgAngleBetween(ux: f32, uy: f32, vx: f32, vy: f32) f32 {
    const dot = ux * vx + uy * vy;
    const len = @sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
    if (len <= 0.0) return 0.0;
    const arg = std.math.clamp(dot / len, -1.0, 1.0);
    var ang = std.math.acos(arg);
    if (ux * vy - uy * vx < 0.0) ang = -ang;
    return ang;
}

fn gdiSvgAddArcToPath(path: ?*c.GpPath, x0: f32, y0: f32, rx_in: f32, ry_in: f32, angle: f32, large_arc_flag: i32, sweep_flag: i32, x1: f32, y1: f32) void {
    const active_path = path orelse return;
    var rx = @abs(rx_in);
    var ry = @abs(ry_in);
    if (rx == 0.0 or ry == 0.0) {
        _ = c.GdipAddPathLine(active_path, x0, y0, x1, y1);
        return;
    }

    const sin_phi = @sin(angle * std.math.pi / 180.0);
    const cos_phi = @cos(angle * std.math.pi / 180.0);
    const dx2 = (x0 - x1) / 2.0;
    const dy2 = (y0 - y1) / 2.0;
    const x1p = cos_phi * dx2 + sin_phi * dy2;
    const y1p = -sin_phi * dx2 + cos_phi * dy2;

    var rx_sq = rx * rx;
    var ry_sq = ry * ry;
    const x1p_sq = x1p * x1p;
    const y1p_sq = y1p * y1p;
    const lambda = x1p_sq / rx_sq + y1p_sq / ry_sq;
    if (lambda > 1.0) {
        const scale = @sqrt(lambda);
        rx *= scale;
        ry *= scale;
        rx_sq = rx * rx;
        ry_sq = ry * ry;
    }

    var radicant = rx_sq * ry_sq - rx_sq * y1p_sq - ry_sq * x1p_sq;
    var denom = rx_sq * y1p_sq + ry_sq * x1p_sq;
    if (denom == 0.0) denom = 1.0;
    radicant = @max(0.0, radicant / denom);

    const coef = (if (large_arc_flag != sweep_flag) @as(f32, 1.0) else @as(f32, -1.0)) * @sqrt(radicant);
    const cxp = coef * (rx * y1p) / ry;
    const cyp = coef * (-ry * x1p) / rx;
    const cx = cos_phi * cxp - sin_phi * cyp + (x0 + x1) / 2.0;
    const cy = sin_phi * cxp + cos_phi * cyp + (y0 + y1) / 2.0;
    const theta1 = gdiSvgAngleBetween(1.0, 0.0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    var delta_theta = gdiSvgAngleBetween((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry);

    if (sweep_flag == 0 and delta_theta > 0.0) {
        delta_theta -= 2.0 * std.math.pi;
    } else if (sweep_flag != 0 and delta_theta < 0.0) {
        delta_theta += 2.0 * std.math.pi;
    }

    const segments: i32 = @intFromFloat(@ceil(@abs(delta_theta / (std.math.pi / 2.0))));
    const delta = delta_theta / @as(f32, @floatFromInt(@max(segments, 1)));
    var t = theta1;
    var i: i32 = 0;
    while (i < segments) : (i += 1) {
        const t1 = t;
        const t2 = t + delta;
        const sin_t1 = @sin(t1);
        const cos_t1 = @cos(t1);
        const sin_t2 = @sin(t2);
        const cos_t2 = @cos(t2);
        const e = @tan(delta / 4.0) * 4.0 / 3.0;
        const x_a = rx * cos_t1;
        const y_a = ry * sin_t1;
        const x_b = rx * cos_t2;
        const y_b = ry * sin_t2;
        const cp1x = x_a - e * ry * sin_t1;
        const cp1y = y_a + e * rx * cos_t1;
        const cp2x = x_b + e * ry * sin_t2;
        const cp2y = y_b - e * rx * cos_t2;
        const from_x = cos_phi * x_a - sin_phi * y_a + cx;
        const from_y = sin_phi * x_a + cos_phi * y_a + cy;
        const c1x = cos_phi * cp1x - sin_phi * cp1y + cx;
        const c1y = sin_phi * cp1x + cos_phi * cp1y + cy;
        const c2x = cos_phi * cp2x - sin_phi * cp2y + cx;
        const c2y = sin_phi * cp2x + cos_phi * cp2y + cy;
        const to_x = cos_phi * x_b - sin_phi * y_b + cx;
        const to_y = sin_phi * x_b + cos_phi * y_b + cy;
        _ = c.GdipAddPathBezier(active_path, from_x, from_y, c1x, c1y, c2x, c2y, to_x, to_y);
        t += delta;
    }
}

fn gdiSvgParsePath(svg_path: []const u8, path: ?*c.GpPath) void {
    const active_path = path orelse return;
    var parser = GdiSvgParser{ .input = svg_path };

    while (!parser.eof()) {
        parser.skipWhitespace();
        if (parser.eof()) break;

        var cmd: u8 = 0;
        const ch = parser.peek();
        if ((ch >= 'A' and ch <= 'Z') or (ch >= 'a' and ch <= 'z')) {
            cmd = ch;
            parser.index += 1;
            parser.last_cmd = cmd;
        } else {
            cmd = parser.last_cmd;
            if (cmd == 'M') cmd = 'L' else if (cmd == 'm') cmd = 'l';
        }

        switch (cmd) {
            'M' => {
                parser.current_x = parser.parseNumber();
                parser.start_x = parser.current_x;
                parser.current_y = parser.parseNumber();
                parser.start_y = parser.current_y;
                _ = c.GdipStartPathFigure(active_path);
                while (parser.hasMoreNumbers()) {
                    parser.current_x = parser.parseNumber();
                    parser.current_y = parser.parseNumber();
                    _ = c.GdipAddPathLine(active_path, parser.current_x - 0.01, parser.current_y - 0.01, parser.current_x, parser.current_y);
                }
            },
            'm' => {
                var dx = parser.parseNumber();
                var dy = parser.parseNumber();
                parser.current_x += dx;
                parser.start_x = parser.current_x;
                parser.current_y += dy;
                parser.start_y = parser.current_y;
                _ = c.GdipStartPathFigure(active_path);
                while (parser.hasMoreNumbers()) {
                    dx = parser.parseNumber();
                    dy = parser.parseNumber();
                    const new_x = parser.current_x + dx;
                    const new_y = parser.current_y + dy;
                    _ = c.GdipAddPathLine(active_path, parser.current_x, parser.current_y, new_x, new_y);
                    parser.current_x = new_x;
                    parser.current_y = new_y;
                }
            },
            'L' => {
                while (true) {
                    const x = parser.parseNumber();
                    const y = parser.parseNumber();
                    _ = c.GdipAddPathLine(active_path, parser.current_x, parser.current_y, x, y);
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'l' => {
                while (true) {
                    const dx = parser.parseNumber();
                    const dy = parser.parseNumber();
                    const new_x = parser.current_x + dx;
                    const new_y = parser.current_y + dy;
                    _ = c.GdipAddPathLine(active_path, parser.current_x, parser.current_y, new_x, new_y);
                    parser.current_x = new_x;
                    parser.current_y = new_y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'H' => {
                while (true) {
                    const x = parser.parseNumber();
                    _ = c.GdipAddPathLine(active_path, parser.current_x, parser.current_y, x, parser.current_y);
                    parser.current_x = x;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'h' => {
                while (true) {
                    const dx = parser.parseNumber();
                    const new_x = parser.current_x + dx;
                    _ = c.GdipAddPathLine(active_path, parser.current_x, parser.current_y, new_x, parser.current_y);
                    parser.current_x = new_x;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'V' => {
                while (true) {
                    const y = parser.parseNumber();
                    _ = c.GdipAddPathLine(active_path, parser.current_x, parser.current_y, parser.current_x, y);
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'v' => {
                while (true) {
                    const dy = parser.parseNumber();
                    const new_y = parser.current_y + dy;
                    _ = c.GdipAddPathLine(active_path, parser.current_x, parser.current_y, parser.current_x, new_y);
                    parser.current_y = new_y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'C' => {
                while (true) {
                    const x1 = parser.parseNumber();
                    const y1 = parser.parseNumber();
                    const x2 = parser.parseNumber();
                    const y2 = parser.parseNumber();
                    const x = parser.parseNumber();
                    const y = parser.parseNumber();
                    _ = c.GdipAddPathBezier(active_path, parser.current_x, parser.current_y, x1, y1, x2, y2, x, y);
                    parser.last_control_x = x2;
                    parser.last_control_y = y2;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'c' => {
                while (true) {
                    const dx1 = parser.parseNumber();
                    const dy1 = parser.parseNumber();
                    const dx2 = parser.parseNumber();
                    const dy2 = parser.parseNumber();
                    const dx = parser.parseNumber();
                    const dy = parser.parseNumber();
                    const x1 = parser.current_x + dx1;
                    const y1 = parser.current_y + dy1;
                    const x2 = parser.current_x + dx2;
                    const y2 = parser.current_y + dy2;
                    const x = parser.current_x + dx;
                    const y = parser.current_y + dy;
                    _ = c.GdipAddPathBezier(active_path, parser.current_x, parser.current_y, x1, y1, x2, y2, x, y);
                    parser.last_control_x = x2;
                    parser.last_control_y = y2;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'S' => {
                while (true) {
                    const x2 = parser.parseNumber();
                    const y2 = parser.parseNumber();
                    const x = parser.parseNumber();
                    const y = parser.parseNumber();
                    const x1 = 2.0 * parser.current_x - parser.last_control_x;
                    const y1 = 2.0 * parser.current_y - parser.last_control_y;
                    _ = c.GdipAddPathBezier(active_path, parser.current_x, parser.current_y, x1, y1, x2, y2, x, y);
                    parser.last_control_x = x2;
                    parser.last_control_y = y2;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            's' => {
                while (true) {
                    const dx2 = parser.parseNumber();
                    const dy2 = parser.parseNumber();
                    const dx = parser.parseNumber();
                    const dy = parser.parseNumber();
                    const x2 = parser.current_x + dx2;
                    const y2 = parser.current_y + dy2;
                    const x = parser.current_x + dx;
                    const y = parser.current_y + dy;
                    const x1 = 2.0 * parser.current_x - parser.last_control_x;
                    const y1 = 2.0 * parser.current_y - parser.last_control_y;
                    _ = c.GdipAddPathBezier(active_path, parser.current_x, parser.current_y, x1, y1, x2, y2, x, y);
                    parser.last_control_x = x2;
                    parser.last_control_y = y2;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'Q' => {
                while (true) {
                    const x1 = parser.parseNumber();
                    const y1 = parser.parseNumber();
                    const x = parser.parseNumber();
                    const y = parser.parseNumber();
                    const cx1 = parser.current_x + (2.0 / 3.0) * (x1 - parser.current_x);
                    const cy1 = parser.current_y + (2.0 / 3.0) * (y1 - parser.current_y);
                    const cx2 = x + (2.0 / 3.0) * (x1 - x);
                    const cy2 = y + (2.0 / 3.0) * (y1 - y);
                    _ = c.GdipAddPathBezier(active_path, parser.current_x, parser.current_y, cx1, cy1, cx2, cy2, x, y);
                    parser.last_control_x = x1;
                    parser.last_control_y = y1;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'q' => {
                while (true) {
                    const dx1 = parser.parseNumber();
                    const dy1 = parser.parseNumber();
                    const dx = parser.parseNumber();
                    const dy = parser.parseNumber();
                    const x1 = parser.current_x + dx1;
                    const y1 = parser.current_y + dy1;
                    const x = parser.current_x + dx;
                    const y = parser.current_y + dy;
                    const cx1 = parser.current_x + (2.0 / 3.0) * (x1 - parser.current_x);
                    const cy1 = parser.current_y + (2.0 / 3.0) * (y1 - parser.current_y);
                    const cx2 = x + (2.0 / 3.0) * (x1 - x);
                    const cy2 = y + (2.0 / 3.0) * (y1 - y);
                    _ = c.GdipAddPathBezier(active_path, parser.current_x, parser.current_y, cx1, cy1, cx2, cy2, x, y);
                    parser.last_control_x = x1;
                    parser.last_control_y = y1;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'A', 'a' => {
                while (true) {
                    const rx = parser.parseNumber();
                    const ry = parser.parseNumber();
                    const angle = parser.parseNumber();
                    const large_arc = @as(i32, @intFromFloat(parser.parseNumber()));
                    const sweep = @as(i32, @intFromFloat(parser.parseNumber()));
                    const x = parser.parseNumber();
                    const y = parser.parseNumber();
                    const x1 = if (cmd == 'a') parser.current_x + x else x;
                    const y1 = if (cmd == 'a') parser.current_y + y else y;
                    gdiSvgAddArcToPath(active_path, parser.current_x, parser.current_y, rx, ry, angle, large_arc, sweep, x1, y1);
                    parser.current_x = x1;
                    parser.current_y = y1;
                    if (!parser.hasMoreNumbers()) break;
                }
            },
            'Z', 'z' => {
                _ = c.GdipClosePathFigure(active_path);
                parser.current_x = parser.start_x;
                parser.current_y = parser.start_y;
            },
            else => {},
        }
    }
}

fn extractFamilyNameFromCollection(collection: *c.GpFontCollection, out_utf8: *[]u8, out_utf16: *[:0]u16) bool {
    var family_count: c.INT = 0;
    if (!gdipOk(c.GdipGetFontCollectionFamilyCount(collection, &family_count)) or family_count <= 0) return false;

    const families = allocator.alloc(?*c.GpFontFamily, @intCast(family_count)) catch return false;
    defer allocator.free(families);

    var found_count: c.INT = 0;
    if (!gdipOk(c.GdipGetFontCollectionFamilyList(collection, family_count, @ptrCast(families.ptr), &found_count)) or found_count <= 0) return false;
    defer {
        const count: usize = @intCast(found_count);
        for (families[0..count]) |family| {
            if (family != null) _ = c.GdipDeleteFontFamily(family);
        }
    }

    const family = families[0] orelse return false;
    var family_name_wide: [c.LF_FACESIZE]u16 = [_]u16{0} ** c.LF_FACESIZE;
    if (!gdipOk(c.GdipGetFamilyName(family, &family_name_wide, 0))) return false;

    const family_len = std.mem.indexOfScalar(u16, family_name_wide[0..], 0) orelse family_name_wide.len;
    if (family_len == 0) return false;

    out_utf8.* = std.unicode.utf16LeToUtf8Alloc(allocator, family_name_wide[0..family_len]) catch return false;
    errdefer allocator.free(out_utf8.*);

    out_utf16.* = allocator.allocSentinel(u16, family_len, 0) catch return false;
    @memcpy(out_utf16.*[0..family_len], family_name_wide[0..family_len]);
    return true;
}

fn addFontFromFile(self: *ByteFontAtlas, file_path: []const u8, size_pixels: f32, font_cfg: ?*const ByteFontConfig) ?*ByteFont {
    const font = allocator.create(ByteFont) catch {
        return null;
    };
    errdefer allocator.destroy(font);

    var family_name_utf8: []u8 = undefined;
    var family_name_utf16: [:0]u16 = undefined;
    var collection: ?*c.GpFontCollection = null;

    if (knownInstalledFamilyName(file_path)) |known_family| {
        family_name_utf8 = allocator.dupe(u8, known_family.utf8) catch return null;
        errdefer allocator.free(family_name_utf8);
        family_name_utf16 = dupeUtf16Z(known_family.utf16) catch return null;
        errdefer allocator.free(family_name_utf16);
    } else {
        const wide_path = std.unicode.utf8ToUtf16LeAllocZ(allocator, file_path) catch return null;
        defer allocator.free(wide_path);

        if (!gdipOk(c.GdipNewPrivateFontCollection(&collection)) or collection == null) return null;
        errdefer {
            if (collection != null) {
                var cleanup_collection = collection;
                _ = c.GdipDeletePrivateFontCollection(@ptrCast(&cleanup_collection));
            }
        }

        if (!gdipOk(c.GdipPrivateAddFontFile(collection, wide_path.ptr))) return null;
        if (!extractFamilyNameFromCollection(collection.?, &family_name_utf8, &family_name_utf16)) return null;
        errdefer allocator.free(family_name_utf8);
        errdefer allocator.free(family_name_utf16);
    }

    font.* = .{
        .LegacySize = size_pixels,
        .FamilyName = family_name_utf8,
        .FilePath = allocator.dupe(u8, file_path) catch return null,
        .FontStyle = detectFontStyleFromPath(file_path),
        .FontCollection = collection,
        .FamilyNameWide = family_name_utf16,
        .PixelSnapH = if (font_cfg) |cfg| cfg.PixelSnapH else false,
    };
    errdefer allocator.free(font.FilePath);

    self.Fonts.append(allocator, font) catch return null;
    clearTextCache();
    return font;
}

fn isWrapWhitespaceByte(ch: u8) bool {
    return ch == ' ' or ch == '\t';
}

fn nextCodepointEnd(text: []const u8, start: usize) usize {
    if (start >= text.len) return text.len;
    const cp_len = std.unicode.utf8ByteSequenceLength(text[start]) catch 1;
    return @min(text.len, start + cp_len);
}

fn appendTextLine(result: *TextLayoutResult, session: *TextMeasureSession, text: []const u8, start: usize, end: usize, line_width: f32) !void {
    const line_text = text[start..end];
    const bounds = if (line_text.len > 0) session.measureBounds(line_text) orelse return error.MeasureFailed else std.mem.zeroes(c.RectF);

    try result.lines.append(allocator, .{
        .start = start,
        .end = end,
        .width = line_width,
        .bounds = bounds,
    });

    const line_index = result.lines.items.len - 1;
    const line_y = @as(f32, @floatFromInt(line_index)) * result.line_height;
    result.width = @max(result.width, bounds.Width);
    result.height = @max(result.height, line_y + @max(result.line_height, bounds.Height));
}

fn fitTextChunk(session: *TextMeasureSession, text: []const u8, start: usize, end: usize, max_width: f32) usize {
    var chunk_end = start;
    while (chunk_end < end) {
        const next_end = nextCodepointEnd(text, chunk_end);
        const width = session.measureWidth(text[start..next_end]);
        if (chunk_end > start and width > max_width) break;
        chunk_end = next_end;
        if (width >= max_width) break;
    }
    return if (chunk_end > start) chunk_end else nextCodepointEnd(text, start);
}

fn layoutText(font: *const ByteFont, size_pixels: f32, text: []const u8, wrap_width: f32) ?TextLayoutResult {
    if (text.len == 0) return TextLayoutResult{};

    var session = TextMeasureSession.init(font, size_pixels) orelse return null;
    defer session.deinit();

    var result = TextLayoutResult{};
    result.line_height = @max(1.0, session.lineHeight());

    var line_start: usize = 0;
    var line_end: usize = 0;
    var line_width: f32 = 0.0;
    var have_line = false;
    var i: usize = 0;
    while (i < text.len) {
        const ch = text[i];
        if (ch == '\r') {
            i += 1;
            continue;
        }
        if (ch == '\n') {
            appendTextLine(&result, &session, text, if (have_line) line_start else i, if (have_line) line_end else i, if (have_line) line_width else 0.0) catch return null;
            have_line = false;
            line_width = 0.0;
            i += 1;
            continue;
        }

        if (!have_line and isWrapWhitespaceByte(ch)) {
            while (i < text.len and isWrapWhitespaceByte(text[i])) : (i += 1) {}
            continue;
        }

        const token_start = i;
        while (i < text.len and text[i] != '\r' and text[i] != '\n' and !isWrapWhitespaceByte(text[i])) : (i += 1) {}
        const token_end = i;
        const token_width = session.measureWidth(text[token_start..token_end]);

        if (wrap_width > 0.0 and have_line and line_width + token_width > wrap_width) {
            appendTextLine(&result, &session, text, line_start, line_end, line_width) catch return null;
            have_line = false;
            line_width = 0.0;
        }

        if (wrap_width > 0.0 and token_width > wrap_width) {
            var chunk_start = token_start;
            while (chunk_start < token_end) {
                if (have_line and line_width > 0.0) {
                    appendTextLine(&result, &session, text, line_start, line_end, line_width) catch return null;
                    have_line = false;
                    line_width = 0.0;
                }

                const chunk_end = fitTextChunk(&session, text, chunk_start, token_end, wrap_width);
                const chunk_width = session.measureWidth(text[chunk_start..chunk_end]);
                appendTextLine(&result, &session, text, chunk_start, chunk_end, chunk_width) catch return null;
                chunk_start = chunk_end;
            }
        } else {
            if (!have_line) {
                line_start = token_start;
                line_width = token_width;
                have_line = true;
            } else {
                line_width += token_width;
            }
            line_end = token_end;
        }

        const whitespace_start = i;
        while (i < text.len and isWrapWhitespaceByte(text[i])) : (i += 1) {}
        if (i > whitespace_start and have_line) {
            const whitespace_width = session.measureWidth(text[whitespace_start..i]);
            if (wrap_width > 0.0 and line_width + whitespace_width > wrap_width) {
                appendTextLine(&result, &session, text, line_start, line_end, line_width) catch return null;
                have_line = false;
                line_width = 0.0;
            } else {
                line_end = i;
                line_width += whitespace_width;
            }
        }
    }

    if (have_line) {
        appendTextLine(&result, &session, text, line_start, line_end, line_width) catch return null;
    } else if (text.len > 0 and (result.lines.items.len == 0 or text[text.len - 1] == '\n')) {
        appendTextLine(&result, &session, text, text.len, text.len, 0.0) catch return null;
    }

    if (result.lines.items.len > 0 and result.height <= 0.0) {
        result.height = result.line_height * @as(f32, @floatFromInt(result.lines.items.len));
    }
    return result;
}

fn measureTextWithGdiPlus(font: *const ByteFont, size_pixels: f32, text: []const u8, wrap_width: f32) ByteVec2 {
    var layout = layoutText(font, size_pixels * kTextSupersample, text, if (wrap_width > 0.0) wrap_width * kTextSupersample else 0.0) orelse return .{};
    defer layout.deinit();
    return .{ .x = layout.width / kTextSupersample, .y = layout.height / kTextSupersample };
}

fn textRenderInsetPx(size_pixels: f32) f32 {
    const pad_px = alignUpInt(@max(2, @as(i32, @intFromFloat(@ceil(size_pixels * 0.12 * kTextSupersample)))), kTextSupersampleI);
    return @as(f32, @floatFromInt(pad_px)) / kTextSupersample;
}

fn succeeded(hr: c.HRESULT) bool {
    return hr >= 0;
}

fn failed(hr: c.HRESULT) bool {
    return hr < 0;
}

fn releaseUnknown(obj: anytype) void {
    if (obj) |ptr| {
        _ = ptr.lpVtbl.*.Release.?(@ptrCast(ptr));
    }
}

fn addRefUnknown(obj: anytype) void {
    if (obj) |ptr| {
        _ = ptr.lpVtbl.*.AddRef.?(@ptrCast(ptr));
    }
}

fn queryInterface(obj: anytype, iid: *const c.IID, out: *?*anyopaque) c.HRESULT {
    const ptr = obj orelse return -1;
    return ptr.lpVtbl.*.QueryInterface.?(@ptrCast(ptr), iid, @ptrCast(out));
}

fn releaseShaderResourceView(view: ?*c.ID3D11ShaderResourceView) void {
    releaseUnknown(view);
}

fn createTextureFromGdipBitmap(bitmap: ?*c.GpBitmap) ?*c.ID3D11ShaderResourceView {
    const device = ByteGui_ImplDX11_GetDevice() orelse return null;
    const context = ByteGui_ImplDX11_GetDeviceContext();
    if (bitmap == null) return null;

    var width: c.UINT = 0;
    var height: c.UINT = 0;
    _ = c.GdipGetImageWidth(@ptrCast(bitmap), &width);
    _ = c.GdipGetImageHeight(@ptrCast(bitmap), &height);
    if (width == 0 or height == 0) return null;

    var rect = c.Rect{
        .X = 0,
        .Y = 0,
        .Width = @intCast(width),
        .Height = @intCast(height),
    };
    var bitmap_data = std.mem.zeroes(c.BitmapData);
    if (!gdipOk(c.GdipBitmapLockBits(bitmap, &rect, c.ImageLockModeRead, c.PixelFormat32bppARGB, &bitmap_data))) return null;
    defer _ = c.GdipBitmapUnlockBits(bitmap, &bitmap_data);

    if (context != null) {
        var mip_desc = std.mem.zeroes(c.D3D11_TEXTURE2D_DESC);
        mip_desc.Width = width;
        mip_desc.Height = height;
        mip_desc.MipLevels = 0;
        mip_desc.ArraySize = 1;
        mip_desc.Format = c.DXGI_FORMAT_B8G8R8A8_UNORM;
        mip_desc.SampleDesc.Count = 1;
        mip_desc.Usage = c.D3D11_USAGE_DEFAULT;
        mip_desc.BindFlags = c.D3D11_BIND_SHADER_RESOURCE | c.D3D11_BIND_RENDER_TARGET;
        mip_desc.MiscFlags = c.D3D11_RESOURCE_MISC_GENERATE_MIPS;

        var mip_texture: ?*c.ID3D11Texture2D = null;
        if (!failed(device.lpVtbl.*.CreateTexture2D.?(device, &mip_desc, null, &mip_texture)) and mip_texture != null) {
            defer releaseUnknown(mip_texture);

            context.?.lpVtbl.*.UpdateSubresource.?(context.?, @ptrCast(mip_texture), 0, null, bitmap_data.Scan0, @intCast(bitmap_data.Stride), 0);

            var mip_srv_desc = std.mem.zeroes(c.D3D11_SHADER_RESOURCE_VIEW_DESC);
            mip_srv_desc.Format = mip_desc.Format;
            mip_srv_desc.ViewDimension = c.D3D11_SRV_DIMENSION_TEXTURE2D;
            mip_srv_desc.unnamed_0.Texture2D.MostDetailedMip = 0;
            mip_srv_desc.unnamed_0.Texture2D.MipLevels = std.math.maxInt(c.UINT);

            var mip_srv: ?*c.ID3D11ShaderResourceView = null;
            if (!failed(device.lpVtbl.*.CreateShaderResourceView.?(device, @ptrCast(mip_texture), &mip_srv_desc, &mip_srv)) and mip_srv != null) {
                context.?.lpVtbl.*.GenerateMips.?(context.?, mip_srv);
                return mip_srv;
            }
        }
    }

    var desc = std.mem.zeroes(c.D3D11_TEXTURE2D_DESC);
    desc.Width = width;
    desc.Height = height;
    desc.MipLevels = 1;
    desc.ArraySize = 1;
    desc.Format = c.DXGI_FORMAT_B8G8R8A8_UNORM;
    desc.SampleDesc.Count = 1;
    desc.Usage = c.D3D11_USAGE_DEFAULT;
    desc.BindFlags = c.D3D11_BIND_SHADER_RESOURCE;

    var init_data = std.mem.zeroes(c.D3D11_SUBRESOURCE_DATA);
    init_data.pSysMem = bitmap_data.Scan0;
    init_data.SysMemPitch = @intCast(bitmap_data.Stride);

    var texture: ?*c.ID3D11Texture2D = null;
    if (failed(device.lpVtbl.*.CreateTexture2D.?(device, &desc, &init_data, &texture)) or texture == null) return null;
    defer releaseUnknown(texture);

    var srv_desc = std.mem.zeroes(c.D3D11_SHADER_RESOURCE_VIEW_DESC);
    srv_desc.Format = desc.Format;
    srv_desc.ViewDimension = c.D3D11_SRV_DIMENSION_TEXTURE2D;
    srv_desc.unnamed_0.Texture2D.MostDetailedMip = 0;
    srv_desc.unnamed_0.Texture2D.MipLevels = 1;

    var srv: ?*c.ID3D11ShaderResourceView = null;
    if (failed(device.lpVtbl.*.CreateShaderResourceView.?(device, @ptrCast(texture), &srv_desc, &srv)) or srv == null) return null;
    return srv;
}

fn createTextureFromBGRA(pixels: []const u8, width: u32, height: u32) ?*c.ID3D11ShaderResourceView {
    const device = ByteGui_ImplDX11_GetDevice() orelse return null;
    const context = ByteGui_ImplDX11_GetDeviceContext();
    if (width == 0 or height == 0) return null;

    if (context != null) {
        var mip_desc = std.mem.zeroes(c.D3D11_TEXTURE2D_DESC);
        mip_desc.Width = width;
        mip_desc.Height = height;
        mip_desc.MipLevels = 0;
        mip_desc.ArraySize = 1;
        mip_desc.Format = c.DXGI_FORMAT_B8G8R8A8_UNORM;
        mip_desc.SampleDesc.Count = 1;
        mip_desc.Usage = c.D3D11_USAGE_DEFAULT;
        mip_desc.BindFlags = c.D3D11_BIND_SHADER_RESOURCE | c.D3D11_BIND_RENDER_TARGET;
        mip_desc.MiscFlags = c.D3D11_RESOURCE_MISC_GENERATE_MIPS;

        var mip_texture: ?*c.ID3D11Texture2D = null;
        if (!failed(device.lpVtbl.*.CreateTexture2D.?(device, &mip_desc, null, &mip_texture)) and mip_texture != null) {
            defer releaseUnknown(mip_texture);

            context.?.lpVtbl.*.UpdateSubresource.?(context.?, @ptrCast(mip_texture), 0, null, pixels.ptr, width * 4, 0);

            var mip_srv_desc = std.mem.zeroes(c.D3D11_SHADER_RESOURCE_VIEW_DESC);
            mip_srv_desc.Format = mip_desc.Format;
            mip_srv_desc.ViewDimension = c.D3D11_SRV_DIMENSION_TEXTURE2D;
            mip_srv_desc.unnamed_0.Texture2D.MostDetailedMip = 0;
            mip_srv_desc.unnamed_0.Texture2D.MipLevels = std.math.maxInt(c.UINT);

            var mip_srv: ?*c.ID3D11ShaderResourceView = null;
            if (!failed(device.lpVtbl.*.CreateShaderResourceView.?(device, @ptrCast(mip_texture), &mip_srv_desc, &mip_srv)) and mip_srv != null) {
                context.?.lpVtbl.*.GenerateMips.?(context.?, mip_srv);
                return mip_srv;
            }
        }
    }

    var desc = std.mem.zeroes(c.D3D11_TEXTURE2D_DESC);
    desc.Width = width;
    desc.Height = height;
    desc.MipLevels = 1;
    desc.ArraySize = 1;
    desc.Format = c.DXGI_FORMAT_B8G8R8A8_UNORM;
    desc.SampleDesc.Count = 1;
    desc.Usage = c.D3D11_USAGE_DEFAULT;
    desc.BindFlags = c.D3D11_BIND_SHADER_RESOURCE;

    var init_data = std.mem.zeroes(c.D3D11_SUBRESOURCE_DATA);
    init_data.pSysMem = pixels.ptr;
    init_data.SysMemPitch = width * 4;

    var texture: ?*c.ID3D11Texture2D = null;
    if (failed(device.lpVtbl.*.CreateTexture2D.?(device, &desc, &init_data, &texture)) or texture == null) return null;
    defer releaseUnknown(texture);

    var srv_desc = std.mem.zeroes(c.D3D11_SHADER_RESOURCE_VIEW_DESC);
    srv_desc.Format = desc.Format;
    srv_desc.ViewDimension = c.D3D11_SRV_DIMENSION_TEXTURE2D;
    srv_desc.unnamed_0.Texture2D.MostDetailedMip = 0;
    srv_desc.unnamed_0.Texture2D.MipLevels = 1;

    var srv: ?*c.ID3D11ShaderResourceView = null;
    if (failed(device.lpVtbl.*.CreateShaderResourceView.?(device, @ptrCast(texture), &srv_desc, &srv)) or srv == null) return null;
    return srv;
}

fn clearTextCache() void {
    const ctx = GByteGui orelse return;
    for (ctx.TextCache.items) |*entry| entry.deinit();
    ctx.TextCache.clearRetainingCapacity();
}

fn getOrCreateTextTexture(font_opt: ?*ByteFont, size_pixels: f32, wrap_width: f32, text: []const u8) ?*TextCacheEntry {
    const ctx = GByteGui orelse return null;
    const font = font_opt orelse return null;
    if (ByteGui_ImplDX11_GetDevice() == null or text.len == 0) return null;

    const pixel_size100: i32 = @intFromFloat(@round(size_pixels * 100.0));
    const wrap_width100: i32 = @intFromFloat(@round(wrap_width * 100.0));
    for (ctx.TextCache.items) |*entry| {
        if (entry.Font == font and entry.PixelSize100 == pixel_size100 and entry.WrapWidth100 == wrap_width100 and std.mem.eql(u8, entry.Text, text)) {
            return entry;
        }
    }

    var layout = layoutText(font, size_pixels * kTextSupersample, text, if (wrap_width > 0.0) wrap_width * kTextSupersample else 0.0) orelse return null;
    defer layout.deinit();

    const pad_px = alignUpInt(@max(2, @as(i32, @intFromFloat(@ceil(size_pixels * 0.12 * kTextSupersample)))), kTextSupersampleI);
    const content_w = alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(layout.width)))), kTextSupersampleI);
    const content_h = alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(layout.height)))), kTextSupersampleI);
    const pixel_w: u32 = @intCast(alignUpInt(@max(1, content_w + pad_px * 2), kTextSupersampleI));
    const pixel_h: u32 = @intCast(alignUpInt(@max(1, content_h + pad_px * 2), kTextSupersampleI));

    var session = TextMeasureSession.init(font, size_pixels * kTextSupersample) orelse return null;
    defer session.deinit();

    const bitmap = createGdipBitmap(@intCast(pixel_w), @intCast(pixel_h)) orelse return null;
    defer _ = c.GdipDisposeImage(@ptrCast(bitmap));

    const graphics = createGdipGraphicsForImage(@ptrCast(bitmap)) orelse return null;
    defer _ = c.GdipDeleteGraphics(graphics);

    _ = c.GdipSetSmoothingMode(graphics, c.SmoothingModeHighQuality);
    _ = c.GdipSetPixelOffsetMode(graphics, c.PixelOffsetModeHighQuality);
    _ = c.GdipSetInterpolationMode(graphics, c.InterpolationModeHighQualityBicubic);
    _ = c.GdipSetCompositingQuality(graphics, c.CompositingQualityHighQuality);
    _ = c.GdipSetTextRenderingHint(graphics, c.TextRenderingHintAntiAliasGridFit);
    _ = c.GdipGraphicsClear(graphics, 0);

    var brush: ?*c.GpSolidFill = null;
    if (!gdipOk(c.GdipCreateSolidFill(0xFFFFFFFF, &brush)) or brush == null) return null;
    defer _ = c.GdipDeleteBrush(@ptrCast(brush));

    for (layout.lines.items, 0..) |line, line_index| {
        const line_text = text[line.start..line.end];
        if (line_text.len == 0) continue;

        const wide_text = std.unicode.utf8ToUtf16LeAllocZ(allocator, line_text) catch return null;
        defer allocator.free(wide_text);

        var draw_rect = c.RectF{
            .X = @round(@as(f32, @floatFromInt(pad_px)) - line.bounds.X),
            .Y = @round(@as(f32, @floatFromInt(pad_px)) + @as(f32, @floatFromInt(line_index)) * layout.line_height - line.bounds.Y),
            .Width = @as(f32, @floatFromInt(pixel_w)),
            .Height = @as(f32, @floatFromInt(pixel_h)),
        };
        if (!gdipOk(c.GdipDrawString(graphics, wide_text.ptr, -1, session.font, &draw_rect, session.format, @ptrCast(brush)))) return null;
    }

    var bgra = allocator.alloc(u8, @as(usize, pixel_w) * @as(usize, pixel_h) * 4) catch return null;
    defer allocator.free(bgra);

    var bitmap_data = std.mem.zeroes(c.BitmapData);
    var lock_rect = c.Rect{ .X = 0, .Y = 0, .Width = @intCast(pixel_w), .Height = @intCast(pixel_h) };
    if (!gdipOk(c.GdipBitmapLockBits(bitmap, &lock_rect, c.ImageLockModeRead, c.PixelFormat32bppARGB, &bitmap_data))) return null;
    defer _ = c.GdipBitmapUnlockBits(bitmap, &bitmap_data);

    const src_stride: usize = @intCast(@abs(bitmap_data.Stride));
    const src_base: [*]const u8 = @ptrCast(@alignCast(bitmap_data.Scan0.?));
    for (0..pixel_h) |row| {
        const src_offset = if (bitmap_data.Stride >= 0)
            row * src_stride
        else
            (@as(usize, pixel_h - 1 - @as(u32, @intCast(row))) * src_stride);
        const dst_row = bgra[row * @as(usize, pixel_w) * 4 ..][0 .. @as(usize, pixel_w) * 4];
        const src_row = src_base[src_offset..][0 .. @as(usize, pixel_w) * 4];
        @memcpy(dst_row, src_row);
    }

    const texture = createTextureFromBGRA(bgra, pixel_w, pixel_h) orelse return null;
    const text_copy = allocator.dupe(u8, text) catch {
        releaseShaderResourceView(texture);
        return null;
    };

    ctx.TextCache.append(allocator, .{
        .Font = font,
        .PixelSize100 = pixel_size100,
        .WrapWidth100 = wrap_width100,
        .Text = text_copy,
        .Texture = texture,
        .DisplaySize = .{
            .x = @as(f32, @floatFromInt(pixel_w)) / kTextSupersample,
            .y = @as(f32, @floatFromInt(pixel_h)) / kTextSupersample,
        },
    }) catch {
        allocator.free(text_copy);
        releaseShaderResourceView(texture);
        return null;
    };

    return &ctx.TextCache.items[ctx.TextCache.items.len - 1];
}

fn getSystemDpiScale() f32 {
    const hdc = c.GetDC(null);
    const dpi_x = if (hdc != null) c.GetDeviceCaps(hdc, c.LOGPIXELSX) else 96;
    if (hdc != null) _ = c.ReleaseDC(null, hdc);
    return if (dpi_x > 0) @as(f32, @floatFromInt(dpi_x)) / 96.0 else 1.0;
}

fn lowWord(value: usize) u16 {
    return @truncate(value & 0xFFFF);
}

fn updateHostWindowSizeState(width: i32, height: i32) void {
    if (width <= 0 or height <= 0) return;
    GHostWindow.WindowWidthPx = width;
    GHostWindow.WindowHeightPx = height;
    if (GByteGui) |ctx| ctx.IO.DisplaySize = .{ .x = @floatFromInt(width), .y = @floatFromInt(height) };
}

fn getWin32BackendData() ?*MiniWin32BackendData {
    const ctx = GByteGui orelse return null;
    return if (ctx.IO.BackendPlatformUserData) |ptr| @ptrCast(@alignCast(ptr)) else null;
}

fn getDx11BackendData() ?*MiniDx11BackendData {
    const ctx = GByteGui orelse return null;
    return if (ctx.IO.BackendRendererUserData) |ptr| @ptrCast(@alignCast(ptr)) else null;
}

fn ensureWin32BackendData() bool {
    const ctx = GByteGui orelse return false;
    if (getWin32BackendData() != null) return true;

    const bd = allocator.create(MiniWin32BackendData) catch return false;
    bd.* = .{};
    _ = c.QueryPerformanceFrequency(@ptrCast(&bd.TicksPerSecond));
    _ = c.QueryPerformanceCounter(@ptrCast(&bd.Time));
    ctx.IO.BackendPlatformUserData = bd;
    ctx.IO.BackendPlatformName = "bytegui_impl_win32_mini";
    return true;
}

fn ensureDx11BackendData() bool {
    const ctx = GByteGui orelse return false;
    if (getDx11BackendData() != null) return true;

    const bd = allocator.create(MiniDx11BackendData) catch return false;
    bd.* = .{};
    ctx.IO.BackendRendererUserData = bd;
    ctx.IO.BackendRendererName = "bytegui_impl_dx11_mini";
    return true;
}

fn cleanupCompositionRenderTarget(bd: *MiniDx11BackendData) void {
    releaseUnknown(bd.MainRTV);
    bd.MainRTV = null;
}

fn createCompositionRenderTarget(bd: *MiniDx11BackendData) bool {
    const swap_chain = bd.SwapChain orelse return false;
    const device = bd.Device orelse return false;

    cleanupCompositionRenderTarget(bd);

    var back_buffer: ?*c.ID3D11Texture2D = null;
    const hr = swap_chain.lpVtbl.*.GetBuffer.?(swap_chain, 0, &dxids.IID_ID3D11Texture2D, @ptrCast(&back_buffer));
    if (failed(hr) or back_buffer == null) return false;
    defer releaseUnknown(back_buffer);

    return succeeded(device.lpVtbl.*.CreateRenderTargetView.?(device, @ptrCast(back_buffer), null, &bd.MainRTV));
}

fn createWhiteTexture(bd: *MiniDx11BackendData) void {
    const device = bd.Device orelse return;
    if (bd.WhiteTextureView != null) return;

    const pixel: u32 = 0xFFFFFFFF;
    var desc = std.mem.zeroes(c.D3D11_TEXTURE2D_DESC);
    desc.Width = 1;
    desc.Height = 1;
    desc.MipLevels = 1;
    desc.ArraySize = 1;
    desc.Format = c.DXGI_FORMAT_R8G8B8A8_UNORM;
    desc.SampleDesc.Count = 1;
    desc.Usage = c.D3D11_USAGE_DEFAULT;
    desc.BindFlags = c.D3D11_BIND_SHADER_RESOURCE;

    var init_data = std.mem.zeroes(c.D3D11_SUBRESOURCE_DATA);
    init_data.pSysMem = &pixel;
    init_data.SysMemPitch = @sizeOf(u32);

    var texture: ?*c.ID3D11Texture2D = null;
    if (succeeded(device.lpVtbl.*.CreateTexture2D.?(device, &desc, &init_data, &texture)) and texture != null) {
        _ = device.lpVtbl.*.CreateShaderResourceView.?(device, @ptrCast(texture), null, &bd.WhiteTextureView);
        releaseUnknown(texture);
    }
}

fn destroyDeviceObjects(bd: *MiniDx11BackendData) void {
    releaseUnknown(bd.WhiteTextureView);
    bd.WhiteTextureView = null;
    releaseUnknown(bd.LinearSampler);
    bd.LinearSampler = null;
    releaseUnknown(bd.IndexBuffer);
    bd.IndexBuffer = null;
    releaseUnknown(bd.VertexBuffer);
    bd.VertexBuffer = null;
    releaseUnknown(bd.BlendState);
    bd.BlendState = null;
    releaseUnknown(bd.DepthStencilState);
    bd.DepthStencilState = null;
    releaseUnknown(bd.RasterizerState);
    bd.RasterizerState = null;
    releaseUnknown(bd.PixelShader);
    bd.PixelShader = null;
    releaseUnknown(bd.VertexConstantBuffer);
    bd.VertexConstantBuffer = null;
    releaseUnknown(bd.InputLayout);
    bd.InputLayout = null;
    releaseUnknown(bd.VertexShader);
    bd.VertexShader = null;
}

fn createDeviceObjects(bd: *MiniDx11BackendData) bool {
    const device = bd.Device orelse return false;
    destroyDeviceObjects(bd);

    const vertex_shader_src =
        \\cbuffer vertexBuffer : register(b0) {
        \\float4x4 ProjectionMatrix;
        \\};
        \\struct VS_INPUT { float2 pos : POSITION; float4 col : COLOR0; float2 uv : TEXCOORD0; };
        \\struct PS_INPUT { float4 pos : SV_POSITION; float4 col : COLOR0; float2 uv : TEXCOORD0; };
        \\PS_INPUT main(VS_INPUT input) {
        \\PS_INPUT output;
        \\output.pos = mul(ProjectionMatrix, float4(input.pos.xy, 0.f, 1.f));
        \\output.col = input.col;
        \\output.uv = input.uv;
        \\return output;
        \\}
    ;

    var vertex_blob: ?*c.ID3DBlob = null;
    if (failed(c.D3DCompile(vertex_shader_src.ptr, vertex_shader_src.len, null, null, null, "main", "vs_4_0", 0, 0, &vertex_blob, null)) or vertex_blob == null) return false;
    defer releaseUnknown(vertex_blob);

    const vertex_bytes = vertex_blob.?.lpVtbl.*.GetBufferPointer.?(vertex_blob);
    const vertex_size = vertex_blob.?.lpVtbl.*.GetBufferSize.?(vertex_blob);
    if (failed(device.lpVtbl.*.CreateVertexShader.?(device, vertex_bytes, vertex_size, null, &bd.VertexShader)) or bd.VertexShader == null) return false;

    const input_layout = [_]c.D3D11_INPUT_ELEMENT_DESC{
        .{ .SemanticName = "POSITION", .SemanticIndex = 0, .Format = c.DXGI_FORMAT_R32G32_FLOAT, .InputSlot = 0, .AlignedByteOffset = @offsetOf(ByteDrawVert, "pos"), .InputSlotClass = c.D3D11_INPUT_PER_VERTEX_DATA, .InstanceDataStepRate = 0 },
        .{ .SemanticName = "TEXCOORD", .SemanticIndex = 0, .Format = c.DXGI_FORMAT_R32G32_FLOAT, .InputSlot = 0, .AlignedByteOffset = @offsetOf(ByteDrawVert, "uv"), .InputSlotClass = c.D3D11_INPUT_PER_VERTEX_DATA, .InstanceDataStepRate = 0 },
        .{ .SemanticName = "COLOR", .SemanticIndex = 0, .Format = c.DXGI_FORMAT_R8G8B8A8_UNORM, .InputSlot = 0, .AlignedByteOffset = @offsetOf(ByteDrawVert, "col"), .InputSlotClass = c.D3D11_INPUT_PER_VERTEX_DATA, .InstanceDataStepRate = 0 },
    };
    if (failed(device.lpVtbl.*.CreateInputLayout.?(device, &input_layout, input_layout.len, vertex_bytes, vertex_size, &bd.InputLayout)) or bd.InputLayout == null) return false;

    var cb_desc = std.mem.zeroes(c.D3D11_BUFFER_DESC);
    cb_desc.ByteWidth = @sizeOf(VertexConstantBufferDx11);
    cb_desc.Usage = c.D3D11_USAGE_DYNAMIC;
    cb_desc.BindFlags = c.D3D11_BIND_CONSTANT_BUFFER;
    cb_desc.CPUAccessFlags = c.D3D11_CPU_ACCESS_WRITE;
    if (failed(device.lpVtbl.*.CreateBuffer.?(device, &cb_desc, null, &bd.VertexConstantBuffer)) or bd.VertexConstantBuffer == null) return false;

    const pixel_shader_src =
        \\struct PS_INPUT { float4 pos : SV_POSITION; float4 col : COLOR0; float2 uv : TEXCOORD0; };
        \\sampler sampler0;
        \\Texture2D texture0;
        \\float4 main(PS_INPUT input) : SV_Target {
        \\return input.col * texture0.Sample(sampler0, input.uv);
        \\}
    ;

    var pixel_blob: ?*c.ID3DBlob = null;
    if (failed(c.D3DCompile(pixel_shader_src.ptr, pixel_shader_src.len, null, null, null, "main", "ps_4_0", 0, 0, &pixel_blob, null)) or pixel_blob == null) return false;
    defer releaseUnknown(pixel_blob);

    const pixel_bytes = pixel_blob.?.lpVtbl.*.GetBufferPointer.?(pixel_blob);
    const pixel_size = pixel_blob.?.lpVtbl.*.GetBufferSize.?(pixel_blob);
    if (failed(device.lpVtbl.*.CreatePixelShader.?(device, pixel_bytes, pixel_size, null, &bd.PixelShader)) or bd.PixelShader == null) return false;

    var blend_desc = std.mem.zeroes(c.D3D11_BLEND_DESC);
    blend_desc.RenderTarget[0].BlendEnable = c.TRUE;
    blend_desc.RenderTarget[0].SrcBlend = c.D3D11_BLEND_SRC_ALPHA;
    blend_desc.RenderTarget[0].DestBlend = c.D3D11_BLEND_INV_SRC_ALPHA;
    blend_desc.RenderTarget[0].BlendOp = c.D3D11_BLEND_OP_ADD;
    blend_desc.RenderTarget[0].SrcBlendAlpha = c.D3D11_BLEND_ONE;
    blend_desc.RenderTarget[0].DestBlendAlpha = c.D3D11_BLEND_INV_SRC_ALPHA;
    blend_desc.RenderTarget[0].BlendOpAlpha = c.D3D11_BLEND_OP_ADD;
    blend_desc.RenderTarget[0].RenderTargetWriteMask = c.D3D11_COLOR_WRITE_ENABLE_ALL;
    if (failed(device.lpVtbl.*.CreateBlendState.?(device, &blend_desc, &bd.BlendState)) or bd.BlendState == null) return false;

    var raster_desc = std.mem.zeroes(c.D3D11_RASTERIZER_DESC);
    raster_desc.FillMode = c.D3D11_FILL_SOLID;
    raster_desc.CullMode = c.D3D11_CULL_NONE;
    raster_desc.ScissorEnable = c.TRUE;
    raster_desc.DepthClipEnable = c.TRUE;
    if (failed(device.lpVtbl.*.CreateRasterizerState.?(device, &raster_desc, &bd.RasterizerState)) or bd.RasterizerState == null) return false;

    var depth_desc = std.mem.zeroes(c.D3D11_DEPTH_STENCIL_DESC);
    depth_desc.DepthEnable = c.FALSE;
    depth_desc.DepthWriteMask = c.D3D11_DEPTH_WRITE_MASK_ALL;
    depth_desc.DepthFunc = c.D3D11_COMPARISON_ALWAYS;
    depth_desc.StencilEnable = c.FALSE;
    depth_desc.FrontFace.StencilFailOp = c.D3D11_STENCIL_OP_KEEP;
    depth_desc.FrontFace.StencilDepthFailOp = c.D3D11_STENCIL_OP_KEEP;
    depth_desc.FrontFace.StencilPassOp = c.D3D11_STENCIL_OP_KEEP;
    depth_desc.FrontFace.StencilFunc = c.D3D11_COMPARISON_ALWAYS;
    depth_desc.BackFace = depth_desc.FrontFace;
    if (failed(device.lpVtbl.*.CreateDepthStencilState.?(device, &depth_desc, &bd.DepthStencilState)) or bd.DepthStencilState == null) return false;

    var sampler_desc = std.mem.zeroes(c.D3D11_SAMPLER_DESC);
    sampler_desc.Filter = c.D3D11_FILTER_MIN_MAG_LINEAR_MIP_POINT;
    sampler_desc.AddressU = c.D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler_desc.AddressV = c.D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler_desc.AddressW = c.D3D11_TEXTURE_ADDRESS_CLAMP;
    sampler_desc.MipLODBias = -0.75;
    sampler_desc.ComparisonFunc = c.D3D11_COMPARISON_ALWAYS;
    sampler_desc.MinLOD = 0.0;
    sampler_desc.MaxLOD = c.D3D11_FLOAT32_MAX;
    if (failed(device.lpVtbl.*.CreateSamplerState.?(device, &sampler_desc, &bd.LinearSampler)) or bd.LinearSampler == null) return false;

    createWhiteTexture(bd);
    if (bd.WhiteTextureView == null) {
        destroyDeviceObjects(bd);
        return false;
    }
    return true;
}

fn setupRenderState(draw_data: *const ByteDrawData, bd: *MiniDx11BackendData) void {
    const ctx = bd.Context.?;

    var vp = std.mem.zeroes(c.D3D11_VIEWPORT);
    vp.Width = draw_data.DisplaySize.x * draw_data.FramebufferScale.x;
    vp.Height = draw_data.DisplaySize.y * draw_data.FramebufferScale.y;
    vp.MinDepth = 0.0;
    vp.MaxDepth = 1.0;
    ctx.lpVtbl.*.RSSetViewports.?(ctx, 1, &vp);

    var mapped_resource = std.mem.zeroes(c.D3D11_MAPPED_SUBRESOURCE);
    if (ctx.lpVtbl.*.Map.?(ctx, @ptrCast(bd.VertexConstantBuffer), 0, c.D3D11_MAP_WRITE_DISCARD, 0, &mapped_resource) == c.S_OK) {
        const constant_buffer: *VertexConstantBufferDx11 = @ptrCast(@alignCast(mapped_resource.pData.?));
        const L = draw_data.DisplayPos.x;
        const R = draw_data.DisplayPos.x + draw_data.DisplaySize.x;
        const T = draw_data.DisplayPos.y;
        const B = draw_data.DisplayPos.y + draw_data.DisplaySize.y;
        constant_buffer.mvp = .{
            .{ 2.0 / (R - L), 0.0, 0.0, 0.0 },
            .{ 0.0, 2.0 / (T - B), 0.0, 0.0 },
            .{ 0.0, 0.0, 0.5, 0.0 },
            .{ (R + L) / (L - R), (T + B) / (B - T), 0.5, 1.0 },
        };
        ctx.lpVtbl.*.Unmap.?(ctx, @ptrCast(bd.VertexConstantBuffer), 0);
    }

    const stride: c.UINT = @sizeOf(ByteDrawVert);
    const offset: c.UINT = 0;
    var vb = bd.VertexBuffer;
    ctx.lpVtbl.*.IASetInputLayout.?(ctx, bd.InputLayout);
    ctx.lpVtbl.*.IASetVertexBuffers.?(ctx, 0, 1, &vb, &stride, &offset);
    ctx.lpVtbl.*.IASetIndexBuffer.?(ctx, bd.IndexBuffer, c.DXGI_FORMAT_R32_UINT, 0);
    ctx.lpVtbl.*.IASetPrimitiveTopology.?(ctx, c.D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    ctx.lpVtbl.*.VSSetShader.?(ctx, bd.VertexShader, null, 0);
    var cb = bd.VertexConstantBuffer;
    ctx.lpVtbl.*.VSSetConstantBuffers.?(ctx, 0, 1, &cb);
    ctx.lpVtbl.*.PSSetShader.?(ctx, bd.PixelShader, null, 0);
    var sampler = bd.LinearSampler;
    ctx.lpVtbl.*.PSSetSamplers.?(ctx, 0, 1, &sampler);
    ctx.lpVtbl.*.GSSetShader.?(ctx, null, null, 0);
    ctx.lpVtbl.*.HSSetShader.?(ctx, null, null, 0);
    ctx.lpVtbl.*.DSSetShader.?(ctx, null, null, 0);
    ctx.lpVtbl.*.CSSetShader.?(ctx, null, null, 0);

    const blend_factor = [_]f32{ 0.0, 0.0, 0.0, 0.0 };
    ctx.lpVtbl.*.OMSetBlendState.?(ctx, bd.BlendState, &blend_factor, 0xFFFFFFFF);
    ctx.lpVtbl.*.OMSetDepthStencilState.?(ctx, bd.DepthStencilState, 0);
    ctx.lpVtbl.*.RSSetState.?(ctx, bd.RasterizerState);
}

pub fn ByteGui_ImplWin32_EnableDpiAwareness() void {
    const user32 = c.GetModuleHandleW(std.unicode.utf8ToUtf16LeStringLiteral("user32.dll"));
    if (user32 == null) return;

    const SetProcessDpiAwarenessContextFn = *const fn (c.HANDLE) callconv(.winapi) c.BOOL;
    const proc = c.GetProcAddress(user32, "SetProcessDpiAwarenessContext");
    if (proc != null) {
        const set_context: SetProcessDpiAwarenessContextFn = @ptrCast(proc);
        _ = set_context(c.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
        return;
    }

    const SetProcessDpiAwareFn = *const fn () callconv(.winapi) c.BOOL;
    const proc_old = c.GetProcAddress(user32, "SetProcessDPIAware");
    if (proc_old != null) {
        const set_process_dpi_aware: SetProcessDpiAwareFn = @ptrCast(proc_old);
        _ = set_process_dpi_aware();
    }
}

pub noinline fn ByteGui_ImplWin32_CreatePlatformWindow(config: ?*const ByteGuiPlatformWindowConfig) bool {
    const cfg_ptr = config orelse return false;
    const cfg = cfg_ptr.*;
    std.mem.doNotOptimizeAway(cfg);
    if (cfg.Instance == null or cfg.WndProc == null or cfg.LogicalWidth <= 0 or cfg.LogicalHeight <= 0) return false;

    ByteGui_ImplWin32_EnableDpiAwareness();
    if (GHostWindow.Hwnd != null) ByteGui_ImplWin32_DestroyPlatformWindow();

    GHostWindow = .{};
    GHostWindow.Instance = cfg.Instance;
    GHostWindow.LogicalWidth = cfg.LogicalWidth;
    GHostWindow.LogicalHeight = cfg.LogicalHeight;
    GHostWindow.DpiScale = getSystemDpiScale();
    GHostWindow.WindowWidthPx = ByteGui_ImplWin32_ScaleI(cfg.LogicalWidth);
    GHostWindow.WindowHeightPx = ByteGui_ImplWin32_ScaleI(cfg.LogicalHeight);
    GHostWindow.ClassName = allocator.dupeZ(u16, std.mem.span(cfg.ClassName)) catch return false;
    const big_icon = if (cfg.IconResourceId != 0) loadIconResource(cfg.Instance, cfg.IconResourceId, c.GetSystemMetrics(c.SM_CXICON), c.GetSystemMetrics(c.SM_CYICON)) else null;
    const small_icon = if (cfg.IconResourceId != 0) loadIconResource(cfg.Instance, cfg.IconResourceId, c.GetSystemMetrics(c.SM_CXSMICON), c.GetSystemMetrics(c.SM_CYSMICON)) else null;

    var wc = std.mem.zeroes(c.WNDCLASSEXW);
    wc.cbSize = @sizeOf(c.WNDCLASSEXW);
    wc.style = c.CS_CLASSDC;
    wc.lpfnWndProc = cfg.WndProc;
    wc.hInstance = cfg.Instance;
    wc.hIcon = big_icon;
    wc.hIconSm = small_icon;
    wc.hCursor = loadCursorResource(idc_arrow_id);
    wc.lpszClassName = GHostWindow.ClassName.?.ptr;
    if (c.RegisterClassExW(&wc) == 0) return false;
    GHostWindow.ClassRegistered = true;

    var pos_x: i32 = c.CW_USEDEFAULT;
    var pos_y: i32 = c.CW_USEDEFAULT;
    if (cfg.CenterOnPrimaryMonitor) {
        const screen_w = c.GetSystemMetrics(c.SM_CXSCREEN);
        const screen_h = c.GetSystemMetrics(c.SM_CYSCREEN);
        pos_x = @divTrunc(screen_w - GHostWindow.WindowWidthPx, 2);
        pos_y = @divTrunc(screen_h - GHostWindow.WindowHeightPx, 2);
    }

    GHostWindow.Hwnd = c.CreateWindowExW(cfg.ExStyle, GHostWindow.ClassName.?.ptr, cfg.Title, cfg.Style, pos_x, pos_y, GHostWindow.WindowWidthPx, GHostWindow.WindowHeightPx, null, null, cfg.Instance, null);
    if (GHostWindow.Hwnd != null and (big_icon != null or small_icon != null)) applyWindowIcons(GHostWindow.Hwnd.?, big_icon, small_icon);
    return GHostWindow.Hwnd != null;
}

pub fn ByteGui_ImplWin32_DestroyPlatformWindow() void {
    const hwnd = GHostWindow.Hwnd;
    const instance = GHostWindow.Instance;
    const class_name = GHostWindow.ClassName;
    const class_registered = GHostWindow.ClassRegistered;
    GHostWindow = .{};

    if (hwnd) |active_hwnd| {
        if (c.IsWindow(active_hwnd) != 0) _ = c.DestroyWindow(active_hwnd);
    }
    if (class_registered and instance != null and class_name != null and class_name.?.len > 0) _ = c.UnregisterClassW(class_name.?.ptr, instance);
    if (class_name) |name| allocator.free(name);
}

pub fn ByteGui_ImplWin32_GetPlatformHwnd() ?c.HWND {
    return GHostWindow.Hwnd;
}

pub fn ByteGui_ImplWin32_GetDpiScale() f32 {
    return if (GHostWindow.DpiScale > 0.0) GHostWindow.DpiScale else 1.0;
}

pub fn ByteGui_ImplWin32_ScaleF(value: f32) f32 {
    return value * ByteGui_ImplWin32_GetDpiScale();
}

pub fn ByteGui_ImplWin32_ScaleI(value: i32) i32 {
    return @intFromFloat(@round(@as(f32, @floatFromInt(value)) * ByteGui_ImplWin32_GetDpiScale()));
}

pub fn ByteGui_ImplWin32_ScaleI_F(value: f32) i32 {
    return @intFromFloat(@round(value * ByteGui_ImplWin32_GetDpiScale()));
}

pub fn ByteGui_ImplWin32_ScaleVec2(x: f32, y: f32) ByteVec2 {
    return .{ .x = ByteGui_ImplWin32_ScaleF(x), .y = ByteGui_ImplWin32_ScaleF(y) };
}

pub fn ByteGui_ImplWin32_SnapPixel(value: anytype) @TypeOf(value) {
    return switch (@TypeOf(value)) {
        f32 => @floor(value + 0.5),
        ByteVec2 => .{
            .x = ByteGui_ImplWin32_SnapPixel(value.x),
            .y = ByteGui_ImplWin32_SnapPixel(value.y),
        },
        else => @compileError("ByteGui_ImplWin32_SnapPixel only supports f32 and ByteVec2."),
    };
}

pub fn ByteGui_ImplWin32_GetWindowWidth() i32 {
    return GHostWindow.WindowWidthPx;
}

pub fn ByteGui_ImplWin32_GetWindowHeight() i32 {
    return GHostWindow.WindowHeightPx;
}

pub fn ByteGui_ImplWin32_HandleDpiChanged(w_param: c.WPARAM, l_param: c.LPARAM, apply_suggested_rect: bool) bool {
    const new_scale = @as(f32, @floatFromInt(lowWord(@as(usize, @intCast(w_param))))) / 96.0;
    const changed = @abs(new_scale - GHostWindow.DpiScale) > 0.001;
    GHostWindow.DpiScale = new_scale;
    GHostWindow.WindowWidthPx = ByteGui_ImplWin32_ScaleI(GHostWindow.LogicalWidth);
    GHostWindow.WindowHeightPx = ByteGui_ImplWin32_ScaleI(GHostWindow.LogicalHeight);

    if (apply_suggested_rect and GHostWindow.Hwnd != null) {
        const ptr_value: usize = @bitCast(l_param);
        if (ptr_value != 0) {
            const prc: *c.RECT = @ptrFromInt(ptr_value);
            _ = c.SetWindowPos(GHostWindow.Hwnd.?, null, prc.left, prc.top, prc.right - prc.left, prc.bottom - prc.top, c.SWP_NOZORDER | c.SWP_NOACTIVATE);
        } else {
            var rect = std.mem.zeroes(c.RECT);
            _ = c.GetWindowRect(GHostWindow.Hwnd.?, &rect);
            _ = c.SetWindowPos(GHostWindow.Hwnd.?, null, rect.left, rect.top, GHostWindow.WindowWidthPx, GHostWindow.WindowHeightPx, c.SWP_NOZORDER | c.SWP_NOACTIVATE);
        }
    }

    return changed;
}

pub fn ByteGui_ImplWin32_Init(hwnd: ?c.HWND) bool {
    if (!ensureWin32BackendData()) return false;

    const bd = getWin32BackendData().?;
    bd.Hwnd = if (hwnd != null) hwnd else GHostWindow.Hwnd;
    if (bd.Hwnd != null) {
        GHostWindow.Hwnd = bd.Hwnd;
        var rect = std.mem.zeroes(c.RECT);
        if (c.GetClientRect(bd.Hwnd.?, &rect) != 0) updateHostWindowSizeState(rect.right - rect.left, rect.bottom - rect.top);
    }
    return true;
}

pub fn ByteGui_ImplWin32_Shutdown() void {
    const ctx = GByteGui orelse return;
    if (getWin32BackendData()) |bd| allocator.destroy(bd);
    ctx.IO.BackendPlatformUserData = null;
    ctx.IO.BackendPlatformName = null;
}

pub fn ByteGui_ImplWin32_NewFrame() void {
    const ctx = GByteGui orelse return;
    const bd = getWin32BackendData() orelse return;

    var current_time: i64 = 0;
    _ = c.QueryPerformanceCounter(@ptrCast(&current_time));
    if (bd.Time > 0 and bd.TicksPerSecond > 0) {
        ctx.IO.DeltaTime = @as(f32, @floatFromInt(current_time - bd.Time)) / @as(f32, @floatFromInt(bd.TicksPerSecond));
    } else {
        ctx.IO.DeltaTime = 1.0 / 60.0;
    }
    if (ctx.IO.DeltaTime <= 0.0) ctx.IO.DeltaTime = 1.0 / 60.0;
    bd.Time = current_time;

    if (bd.Hwnd != null and (ctx.IO.DisplaySize.x <= 0.0 or ctx.IO.DisplaySize.y <= 0.0)) {
        var rect = std.mem.zeroes(c.RECT);
        if (c.GetClientRect(bd.Hwnd.?, &rect) != 0) updateHostWindowSizeState(rect.right - rect.left, rect.bottom - rect.top);
    }
}

pub fn ByteGui_ImplWin32_WndProcHandler(hwnd: ?c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) c.LRESULT {
    _ = hwnd;
    _ = msg;
    _ = w_param;
    _ = l_param;
    return 0;
}

pub fn ByteGui_ImplDX11_InitComposition(hwnd: ?c.HWND, width: c.UINT, height: c.UINT) bool {
    if (!ensureDx11BackendData() or hwnd == null or width == 0 or height == 0) return false;

    ByteGui_ImplDX11_ShutdownComposition();
    const bd = getDx11BackendData().?;
    const levels = [_]c.D3D_FEATURE_LEVEL{ c.D3D_FEATURE_LEVEL_11_0, c.D3D_FEATURE_LEVEL_10_0 };
    var feature_level: c.D3D_FEATURE_LEVEL = c.D3D_FEATURE_LEVEL_11_0;

    const hr_device = c.D3D11CreateDevice(null, c.D3D_DRIVER_TYPE_HARDWARE, null, c.D3D11_CREATE_DEVICE_BGRA_SUPPORT, &levels, levels.len, c.D3D11_SDK_VERSION, &bd.Device, &feature_level, &bd.Context);
    if (failed(hr_device)) {
        return false;
    }

    var dxgi_device: ?*c.IDXGIDevice = null;
    if (queryInterface(bd.Device, &dxids.IID_IDXGIDevice, @ptrCast(&dxgi_device)) != 0 or dxgi_device == null) {
        return false;
    }
    defer releaseUnknown(dxgi_device);

    var dxgi_adapter: ?*c.IDXGIAdapter = null;
    if (failed(dxgi_device.?.lpVtbl.*.GetAdapter.?(dxgi_device, &dxgi_adapter)) or dxgi_adapter == null) {
        return false;
    }
    defer releaseUnknown(dxgi_adapter);

    var dxgi_factory: ?*c.IDXGIFactory2 = null;
    if (failed(dxgi_adapter.?.lpVtbl.*.GetParent.?(dxgi_adapter, &dxids.IID_IDXGIFactory2, @ptrCast(&dxgi_factory))) or dxgi_factory == null) {
        return false;
    }
    defer releaseUnknown(dxgi_factory);

    var desc = std.mem.zeroes(c.DXGI_SWAP_CHAIN_DESC1);
    desc.Width = width;
    desc.Height = height;
    desc.Format = c.DXGI_FORMAT_B8G8R8A8_UNORM;
    desc.SampleDesc.Count = 1;
    desc.BufferUsage = c.DXGI_USAGE_RENDER_TARGET_OUTPUT;
    desc.BufferCount = 2;
    desc.Scaling = c.DXGI_SCALING_STRETCH;
    desc.SwapEffect = c.DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL;
    desc.AlphaMode = c.DXGI_ALPHA_MODE_PREMULTIPLIED;

    if (failed(dxgi_factory.?.lpVtbl.*.CreateSwapChainForComposition.?(dxgi_factory, @ptrCast(bd.Device), &desc, null, &bd.SwapChain)) or bd.SwapChain == null) {
        return false;
    }
    if (failed(dcomp.DCompositionCreateDevice3(@ptrCast(dxgi_device), &dcomp.IID_IDCompositionDesktopDevice, @ptrCast(&bd.DcompDevice))) or bd.DcompDevice == null) {
        return false;
    }
    if (failed(bd.DcompDevice.?.lpVtbl.*.CreateTargetForHwnd.?(bd.DcompDevice.?, hwnd.?, c.TRUE, &bd.DcompTarget)) or bd.DcompTarget == null) {
        return false;
    }
    if (failed(bd.DcompDevice.?.lpVtbl.*.CreateVisual.?(bd.DcompDevice.?, &bd.DcompVisual)) or bd.DcompVisual == null) {
        return false;
    }
    bd.DcompVisual3 = null;
    _ = queryInterface(bd.DcompVisual, &dcomp.IID_IDCompositionVisual3, @ptrCast(&bd.DcompVisual3));
    if (failed(bd.DcompVisual.?.lpVtbl.*.SetContent.?(bd.DcompVisual.?, @ptrCast(bd.SwapChain)))) {
        return false;
    }
    if (failed(bd.DcompTarget.?.lpVtbl.*.SetRoot.?(bd.DcompTarget.?, @ptrCast(bd.DcompVisual)))) {
        return false;
    }
    if (failed(bd.DcompDevice.?.lpVtbl.*.Commit.?(bd.DcompDevice.?))) {
        return false;
    }

    updateHostWindowSizeState(@intCast(width), @intCast(height));
    return createCompositionRenderTarget(bd);
}

pub fn ByteGui_ImplDX11_ShutdownComposition() void {
    const bd = getDx11BackendData() orelse return;
    clearTextCache();
    destroyDeviceObjects(bd);
    cleanupCompositionRenderTarget(bd);
    releaseUnknown(bd.DcompVisual3);
    bd.DcompVisual3 = null;
    releaseUnknown(bd.DcompVisual);
    bd.DcompVisual = null;
    releaseUnknown(bd.DcompTarget);
    bd.DcompTarget = null;
    releaseUnknown(bd.DcompDevice);
    bd.DcompDevice = null;
    releaseUnknown(bd.SwapChain);
    bd.SwapChain = null;
    releaseUnknown(bd.Context);
    bd.Context = null;
    releaseUnknown(bd.Device);
    bd.Device = null;
}

pub fn ByteGui_ImplDX11_ResizeComposition(width: c.UINT, height: c.UINT) void {
    const bd = getDx11BackendData() orelse return;
    const swap_chain = bd.SwapChain orelse return;
    if (width == 0 or height == 0) return;

    cleanupCompositionRenderTarget(bd);
    if (succeeded(swap_chain.lpVtbl.*.ResizeBuffers.?(swap_chain, 0, width, height, c.DXGI_FORMAT_UNKNOWN, 0))) {
        _ = createCompositionRenderTarget(bd);
        updateHostWindowSizeState(@intCast(width), @intCast(height));
        if (bd.DcompDevice) |device| _ = device.lpVtbl.*.Commit.?(device);
    }
}

pub fn ByteGui_ImplDX11_BeginCompositionFrame(clear_color: *const [4]f32) bool {
    const bd = getDx11BackendData() orelse return false;
    const context = bd.Context orelse return false;
    const rtv = bd.MainRTV orelse return false;

    var rtv_ptr = rtv;
    context.lpVtbl.*.OMSetRenderTargets.?(context, 1, &rtv_ptr, null);
    context.lpVtbl.*.ClearRenderTargetView.?(context, rtv, clear_color);
    return true;
}

pub fn ByteGui_ImplDX11_PresentComposition(opacity: f32, sync_interval: c.UINT, flags: c.UINT) bool {
    const bd = getDx11BackendData() orelse return false;
    const swap_chain = bd.SwapChain orelse return false;

    if (bd.DcompVisual3) |visual| _ = visual.lpVtbl.*.SetOpacity.?(visual, opacity);
    if (bd.DcompDevice) |device| _ = device.lpVtbl.*.Commit.?(device);
    return succeeded(swap_chain.lpVtbl.*.Present.?(swap_chain, sync_interval, flags));
}

pub fn ByteGui_ImplDX11_GetDevice() ?*c.ID3D11Device {
    return if (getDx11BackendData()) |bd| bd.Device else null;
}

pub fn ByteGui_ImplDX11_GetDeviceContext() ?*c.ID3D11DeviceContext {
    return if (getDx11BackendData()) |bd| bd.Context else null;
}

pub fn ByteGui_ImplDX11_GetCompositionDevice() ?*dcomp.IDCompositionDesktopDevice {
    return if (getDx11BackendData()) |bd| bd.DcompDevice else null;
}

pub fn ByteGui_ImplDX11_GetCompositionVisual3() ?*dcomp.IDCompositionVisual3 {
    return if (getDx11BackendData()) |bd| bd.DcompVisual3 else null;
}

pub fn ByteGui_ImplDX11_Init(device: ?*c.ID3D11Device, device_context: ?*c.ID3D11DeviceContext) bool {
    if (!ensureDx11BackendData() or device == null or device_context == null) return false;

    const bd = getDx11BackendData().?;
    if (bd.Device != null or bd.Context != null) ByteGui_ImplDX11_ShutdownComposition();

    bd.Device = device;
    bd.Context = device_context;
    addRefUnknown(bd.Device);
    addRefUnknown(bd.Context);
    return true;
}

pub fn ByteGui_ImplDX11_Shutdown() void {
    const ctx = GByteGui orelse return;
    const bd = getDx11BackendData() orelse return;

    clearTextCache();
    destroyDeviceObjects(bd);
    cleanupCompositionRenderTarget(bd);
    releaseUnknown(bd.DcompVisual3);
    releaseUnknown(bd.DcompVisual);
    releaseUnknown(bd.DcompTarget);
    releaseUnknown(bd.DcompDevice);
    releaseUnknown(bd.SwapChain);
    releaseUnknown(bd.Context);
    releaseUnknown(bd.Device);

    allocator.destroy(bd);
    ctx.IO.BackendRendererUserData = null;
    ctx.IO.BackendRendererName = null;
    ctx.WhiteTexture = null;
}

pub fn ByteGui_ImplDX11_NewFrame() void {
    const ctx = GByteGui orelse return;
    const bd = getDx11BackendData() orelse return;

    if (bd.VertexShader == null) _ = createDeviceObjects(bd);
    ctx.WhiteTexture = @ptrCast(bd.WhiteTextureView);
}

pub fn ByteGui_ImplDX11_RenderDrawData(draw_data: ?*ByteDrawData) void {
    const dd = draw_data orelse return;
    if (!dd.Valid or dd.DisplaySize.x <= 0.0 or dd.DisplaySize.y <= 0.0) return;

    const bd = getDx11BackendData() orelse return;
    const context = bd.Context orelse return;
    const device = bd.Device orelse return;

    if (bd.VertexShader == null and !createDeviceObjects(bd)) return;

    if (bd.VertexBuffer == null or bd.VertexBufferSize < dd.TotalVtxCount) {
        releaseUnknown(bd.VertexBuffer);
        bd.VertexBuffer = null;
        bd.VertexBufferSize = dd.TotalVtxCount + 5000;

        var desc = std.mem.zeroes(c.D3D11_BUFFER_DESC);
        desc.Usage = c.D3D11_USAGE_DYNAMIC;
        desc.ByteWidth = @intCast(bd.VertexBufferSize * @as(i32, @sizeOf(ByteDrawVert)));
        desc.BindFlags = c.D3D11_BIND_VERTEX_BUFFER;
        desc.CPUAccessFlags = c.D3D11_CPU_ACCESS_WRITE;
        if (failed(device.lpVtbl.*.CreateBuffer.?(device, &desc, null, &bd.VertexBuffer))) return;
    }

    if (bd.IndexBuffer == null or bd.IndexBufferSize < dd.TotalIdxCount) {
        releaseUnknown(bd.IndexBuffer);
        bd.IndexBuffer = null;
        bd.IndexBufferSize = dd.TotalIdxCount + 10000;

        var desc = std.mem.zeroes(c.D3D11_BUFFER_DESC);
        desc.Usage = c.D3D11_USAGE_DYNAMIC;
        desc.ByteWidth = @intCast(bd.IndexBufferSize * @as(i32, @sizeOf(ByteDrawIdx)));
        desc.BindFlags = c.D3D11_BIND_INDEX_BUFFER;
        desc.CPUAccessFlags = c.D3D11_CPU_ACCESS_WRITE;
        if (failed(device.lpVtbl.*.CreateBuffer.?(device, &desc, null, &bd.IndexBuffer))) return;
    }

    var vtx_resource = std.mem.zeroes(c.D3D11_MAPPED_SUBRESOURCE);
    var idx_resource = std.mem.zeroes(c.D3D11_MAPPED_SUBRESOURCE);
    if (context.lpVtbl.*.Map.?(context, @ptrCast(bd.VertexBuffer), 0, c.D3D11_MAP_WRITE_DISCARD, 0, &vtx_resource) != c.S_OK) return;
    if (context.lpVtbl.*.Map.?(context, @ptrCast(bd.IndexBuffer), 0, c.D3D11_MAP_WRITE_DISCARD, 0, &idx_resource) != c.S_OK) {
        context.lpVtbl.*.Unmap.?(context, @ptrCast(bd.VertexBuffer), 0);
        return;
    }

    var vtx_dst: [*]ByteDrawVert = @ptrCast(@alignCast(vtx_resource.pData.?));
    var idx_dst: [*]ByteDrawIdx = @ptrCast(@alignCast(idx_resource.pData.?));
    for (dd.CmdLists.items) |draw_list| {
        if (draw_list.VtxBuffer.items.len > 0) {
            @memcpy(vtx_dst[0..draw_list.VtxBuffer.items.len], draw_list.VtxBuffer.items);
            vtx_dst += draw_list.VtxBuffer.items.len;
        }
        if (draw_list.IdxBuffer.items.len > 0) {
            @memcpy(idx_dst[0..draw_list.IdxBuffer.items.len], draw_list.IdxBuffer.items);
            idx_dst += draw_list.IdxBuffer.items.len;
        }
    }

    context.lpVtbl.*.Unmap.?(context, @ptrCast(bd.VertexBuffer), 0);
    context.lpVtbl.*.Unmap.?(context, @ptrCast(bd.IndexBuffer), 0);
    setupRenderState(dd, bd);

    var global_idx_offset: i32 = 0;
    var global_vtx_offset: i32 = 0;
    for (dd.CmdLists.items) |draw_list| {
        for (draw_list.CmdBuffer.items) |cmd| {
            if (cmd.ElemCount == 0) continue;

            var clip_rect = c.RECT{
                .left = @intFromFloat(cmd.ClipRect.x),
                .top = @intFromFloat(cmd.ClipRect.y),
                .right = @intFromFloat(cmd.ClipRect.z),
                .bottom = @intFromFloat(cmd.ClipRect.w),
            };
            if (clip_rect.right <= clip_rect.left or clip_rect.bottom <= clip_rect.top) continue;

            var texture_srv: ?*c.ID3D11ShaderResourceView = if (cmd.TextureId) |tex| @ptrCast(@alignCast(tex)) else null;
            context.lpVtbl.*.RSSetScissorRects.?(context, 1, @ptrCast(&clip_rect));
            context.lpVtbl.*.PSSetShaderResources.?(context, 0, 1, &texture_srv);
            context.lpVtbl.*.DrawIndexed.?(context, cmd.ElemCount, @intCast(@as(i32, @intCast(cmd.IdxOffset)) + global_idx_offset), @intCast(@as(i32, @intCast(cmd.VtxOffset)) + global_vtx_offset));
        }

        global_idx_offset += @intCast(draw_list.IdxBuffer.items.len);
        global_vtx_offset += @intCast(draw_list.VtxBuffer.items.len);
    }
}
