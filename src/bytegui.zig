// ByteGUI - A minimal immediate mode GUI library for Endfield Uncensored, built on OpenGL.

const builtin = @import("builtin");
const std = @import("std");
const w32 = @import("win32.zig");
const bt = @import("bytetype.zig");

pub const c = @import("bytegui_c");

const gl = struct {
    pub const GLenum = c_uint;
    pub const GLbitfield = c_uint;
    pub const GLint = c_int;
    pub const GLsizei = c_int;
    pub const GLuint = c_uint;
    pub const GLfloat = f32;
    pub const GLclampf = f32;
    pub const GLdouble = f64;
    pub const GLboolean = u8;

    pub const FALSE: GLboolean = 0;
    pub const TRUE: GLboolean = 1;

    pub const COLOR_BUFFER_BIT: GLbitfield = 0x00004000;

    pub const UNSIGNED_BYTE: GLenum = 0x1401;
    pub const UNSIGNED_INT: GLenum = 0x1405;
    pub const FLOAT: GLenum = 0x1406;

    pub const TRIANGLES: GLenum = 0x0004;
    pub const TRIANGLE_STRIP: GLenum = 0x0005;
    pub const TRIANGLE_FAN: GLenum = 0x0006;

    pub const TEXTURE_2D: GLenum = 0x0DE1;
    pub const TEXTURE_WRAP_S: GLenum = 0x2802;
    pub const TEXTURE_WRAP_T: GLenum = 0x2803;
    pub const TEXTURE_MIN_FILTER: GLenum = 0x2801;
    pub const TEXTURE_MAG_FILTER: GLenum = 0x2800;
    pub const TEXTURE_ENV: GLenum = 0x2300;
    pub const TEXTURE_ENV_MODE: GLenum = 0x2200;
    pub const MODULATE: GLint = 0x2100;
    pub const CLAMP_TO_EDGE: GLint = 0x812F;
    pub const LINEAR: GLint = 0x2601;
    pub const NEAREST: GLint = 0x2600;
    pub const RGBA: GLenum = 0x1908;
    pub const ALPHA: GLenum = 0x1906;

    pub const BLEND: GLenum = 0x0BE2;
    pub const ONE: GLenum = 0x0001;
    pub const SRC_ALPHA: GLenum = 0x0302;
    pub const ONE_MINUS_SRC_ALPHA: GLenum = 0x0303;
    pub const DST_ALPHA: GLenum = 0x0304;
    pub const ONE_MINUS_DST_ALPHA: GLenum = 0x0305;
    pub const SCISSOR_TEST: GLenum = 0x0C11;
    pub const CULL_FACE: GLenum = 0x0B44;
    pub const DEPTH_TEST: GLenum = 0x0B71;
    pub const LIGHTING: GLenum = 0x0B50;
    pub const SMOOTH: GLenum = 0x1D01;
    pub const UNPACK_ALIGNMENT: GLenum = 0x0CF5;

    pub const PROJECTION: GLenum = 0x1701;
    pub const MODELVIEW: GLenum = 0x1700;

    pub const VERTEX_ARRAY: GLenum = 0x8074;
    pub const COLOR_ARRAY: GLenum = 0x8076;
    pub const TEXTURE_COORD_ARRAY: GLenum = 0x8078;

    pub const STENCIL_BUFFER_BIT: GLbitfield = 0x00000400;
    pub const STENCIL_TEST: GLenum = 0x0B90;
    pub const ALWAYS: GLenum = 0x0207;
    pub const NOTEQUAL: GLenum = 0x0205;
    pub const KEEP: GLenum = 0x1E00;
    pub const INVERT: GLenum = 0x150A;
    pub const QUADS: GLenum = 0x0007;

    pub extern "opengl32" fn glClearColor(red: GLclampf, green: GLclampf, blue: GLclampf, alpha: GLclampf) callconv(.winapi) void;
    pub extern "opengl32" fn glClear(mask: GLbitfield) callconv(.winapi) void;
    pub extern "opengl32" fn glEnable(cap: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glDisable(cap: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glBlendFunc(sfactor: GLenum, dfactor: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.winapi) void;
    pub extern "opengl32" fn glScissor(x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.winapi) void;
    pub extern "opengl32" fn glShadeModel(mode: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glPixelStorei(pname: GLenum, param: GLint) callconv(.winapi) void;

    pub extern "opengl32" fn glMatrixMode(mode: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glLoadIdentity() callconv(.winapi) void;
    pub extern "opengl32" fn glOrtho(left: GLdouble, right: GLdouble, bottom: GLdouble, top: GLdouble, near_val: GLdouble, far_val: GLdouble) callconv(.winapi) void;

    pub extern "opengl32" fn glTexEnvi(target: GLenum, pname: GLenum, param: GLint) callconv(.winapi) void;
    pub extern "opengl32" fn glGenTextures(n: GLsizei, textures: [*]GLuint) callconv(.winapi) void;
    pub extern "opengl32" fn glDeleteTextures(n: GLsizei, textures: [*]const GLuint) callconv(.winapi) void;
    pub extern "opengl32" fn glBindTexture(target: GLenum, texture: GLuint) callconv(.winapi) void;
    pub extern "opengl32" fn glTexParameteri(target: GLenum, pname: GLenum, param: GLint) callconv(.winapi) void;
    pub extern "opengl32" fn glTexImage2D(
        target: GLenum,
        level: GLint,
        internal_format: GLint,
        width: GLsizei,
        height: GLsizei,
        border: GLint,
        format: GLenum,
        typ: GLenum,
        pixels: ?*const anyopaque,
    ) callconv(.winapi) void;

    pub extern "opengl32" fn glEnableClientState(array: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glDisableClientState(array: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glVertexPointer(size: GLint, typ: GLenum, stride: GLsizei, pointer: ?*const anyopaque) callconv(.winapi) void;
    pub extern "opengl32" fn glTexCoordPointer(size: GLint, typ: GLenum, stride: GLsizei, pointer: ?*const anyopaque) callconv(.winapi) void;
    pub extern "opengl32" fn glColorPointer(size: GLint, typ: GLenum, stride: GLsizei, pointer: ?*const anyopaque) callconv(.winapi) void;
    pub extern "opengl32" fn glDrawElements(mode: GLenum, count: GLsizei, typ: GLenum, indices: ?*const anyopaque) callconv(.winapi) void;

    pub extern "opengl32" fn glBegin(mode: GLenum) callconv(.winapi) void;
    pub extern "opengl32" fn glEnd() callconv(.winapi) void;
    pub extern "opengl32" fn glVertex2f(x: GLfloat, y: GLfloat) callconv(.winapi) void;
    pub extern "opengl32" fn glColor4ub(r: u8, g: u8, b: u8, a: u8) callconv(.winapi) void;
    pub extern "opengl32" fn glColorMask(r: GLboolean, g: GLboolean, b: GLboolean, a2: GLboolean) callconv(.winapi) void;
    pub extern "opengl32" fn glClearStencil(s: GLint) callconv(.winapi) void;
    pub extern "opengl32" fn glStencilMask(mask: GLuint) callconv(.winapi) void;
    pub extern "opengl32" fn glStencilFunc(func: GLenum, ref: GLint, mask: GLuint) callconv(.winapi) void;
    pub extern "opengl32" fn glStencilOp(sfail: GLenum, dpfail: GLenum, dppass: GLenum) callconv(.winapi) void;
};

const glu = struct {
    pub const GLUtesselator = opaque {};
    pub const TESS_WINDING_ODD: gl.GLdouble = 100130.0;
    pub const TESS_BEGIN_DATA: gl.GLenum = 100106;
    pub const TESS_VERTEX_DATA: gl.GLenum = 100107;
    pub const TESS_END_DATA: gl.GLenum = 100108;
    pub const TESS_ERROR_DATA: gl.GLenum = 100109;
    pub const TESS_COMBINE_DATA: gl.GLenum = 100111;
    pub const TESS_WINDING_RULE: gl.GLenum = 100140;

    pub extern "glu32" fn gluNewTess() callconv(.winapi) ?*GLUtesselator;
    pub extern "glu32" fn gluDeleteTess(tess: ?*GLUtesselator) callconv(.winapi) void;
    pub extern "glu32" fn gluTessBeginPolygon(tess: ?*GLUtesselator, polygon_data: ?*anyopaque) callconv(.winapi) void;
    pub extern "glu32" fn gluTessEndPolygon(tess: ?*GLUtesselator) callconv(.winapi) void;
    pub extern "glu32" fn gluTessBeginContour(tess: ?*GLUtesselator) callconv(.winapi) void;
    pub extern "glu32" fn gluTessEndContour(tess: ?*GLUtesselator) callconv(.winapi) void;
    pub extern "glu32" fn gluTessVertex(tess: ?*GLUtesselator, coords: [*]const gl.GLdouble, data: ?*anyopaque) callconv(.winapi) void;
    pub extern "glu32" fn gluTessProperty(tess: ?*GLUtesselator, which: gl.GLenum, value: gl.GLdouble) callconv(.winapi) void;
    pub extern "glu32" fn gluTessCallback(tess: ?*GLUtesselator, which: gl.GLenum, callback_fn: ?*const anyopaque) callconv(.winapi) void;
};

const GlBlendFuncSeparateFn = *const fn (gl.GLenum, gl.GLenum, gl.GLenum, gl.GLenum) callconv(.winapi) void;
var g_glBlendFuncSeparate: ?GlBlendFuncSeparateFn = null;

const allocator = std.heap.c_allocator;
pub const BYTEGUI_VERSION = "efu-mini";

pub fn BYTEGUI_CHECKVERSION() void {}

// Public drawing and font types
pub const ByteU32 = u32;
pub const ByteDrawIdx = u32;
pub const ByteTextureID = ?*anyopaque;

pub const BYTEGUI_COL32_A_MASK: ByteU32 = 0xFF000000;

const kPi: f32 = 3.14159265358979323846;
const default_class_name = std.unicode.utf8ToUtf16LeStringLiteral("ByteGUIPlatformWindow");
const default_title = std.unicode.utf8ToUtf16LeStringLiteral("ByteGUI");
const idc_arrow_id: u16 = 32512;
const image_icon_type: c.UINT = 1;
const load_image_shared: c.UINT = 0x8000;
const wm_seticon: c.UINT = 0x0080;
const icon_small_slot: c.WPARAM = 0;
const icon_big_slot: c.WPARAM = 1;

fn setByteGUITrace(_: []const u8) void {}

fn setByteGUITraceFmt(comptime fmt: []const u8, args: anytype) void {
    _ = fmt;
    _ = args;
}

extern "user32" fn LoadImageW(h_instance: c.HINSTANCE, name: ?*anyopaque, image_type: c.UINT, width: c.INT, height: c.INT, flags: c.UINT) callconv(.winapi) ?*anyopaque;
extern "user32" fn SendMessageW(hwnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.winapi) c.LRESULT;

fn loadIconResource(instance: c.HINSTANCE, id: u16, width: c.INT, height: c.INT) c.HICON {
    @setRuntimeSafety(false);
    const handle = LoadImageW(instance, @ptrFromInt(@as(usize, id)), image_icon_type, width, height, load_image_shared) orelse return null;
    return @ptrFromInt(@intFromPtr(handle));
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

pub const ByteGUICol_Text: usize = 0;
pub const ByteGUICol_WindowBg: usize = 1;
pub const ByteGUICol_ChildBg: usize = 2;
pub const ByteGUICol_Border: usize = 3;
pub const ByteGUICol_ScrollbarBg: usize = 4;
pub const ByteGUICol_ScrollbarGrab: usize = 5;
pub const ByteGUICol_ScrollbarGrabHovered: usize = 6;
pub const ByteGUICol_ScrollbarGrabActive: usize = 7;
pub const ByteGUICol_COUNT: usize = 8;
pub const ByteGUICol = i32;

pub const ByteGUIStyleVar_Alpha: i32 = 0;
pub const ByteGUIStyleVar = i32;

pub const ByteGUIWindowFlags_None: u32 = 0;
pub const ByteGUIWindowFlags_NoDecoration: u32 = 1 << 0;
pub const ByteGUIWindowFlags_NoMove: u32 = 1 << 1;
pub const ByteGUIWindowFlags_NoResize: u32 = 1 << 2;
pub const ByteGUIWindowFlags_NoSavedSettings: u32 = 1 << 3;
pub const ByteGUIWindowFlags_NoNav: u32 = 1 << 4;
pub const ByteGUIWindowFlags_NoBackground: u32 = 1 << 5;
pub const ByteGUIWindowFlags_NoScrollbar: u32 = 1 << 6;
pub const ByteGUIWindowFlags_NoScrollWithMouse: u32 = 1 << 7;
pub const ByteGUIWindowFlags = u32;

pub const ByteDrawListFlags_None: u32 = 0;
pub const ByteDrawListFlags_AntiAliasedFill: u32 = 1 << 0;
pub const ByteDrawListFlags_AntiAliasedLines: u32 = 1 << 1;
pub const ByteDrawListFlags = u32;

pub const ByteDrawCornerFlags_TopLeft: u8 = 1 << 0;
pub const ByteDrawCornerFlags_TopRight: u8 = 1 << 1;
pub const ByteDrawCornerFlags_BottomRight: u8 = 1 << 2;
pub const ByteDrawCornerFlags_BottomLeft: u8 = 1 << 3;
pub const ByteDrawCornerFlags_All: u8 = ByteDrawCornerFlags_TopLeft | ByteDrawCornerFlags_TopRight | ByteDrawCornerFlags_BottomRight | ByteDrawCornerFlags_BottomLeft;

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

pub const ByteDrawCallback = *const fn (*const ByteDrawList, *const ByteDrawCmd) callconv(.c) void;

pub const ByteDrawCmd = struct {
    ElemCount: u32 = 0,
    IdxOffset: u32 = 0,
    VtxOffset: u32 = 0,
    ClipRect: ByteVec4 = .{},
    TextureId: ByteTextureID = null,
    UserCallback: ?ByteDrawCallback = null,
    UserCallbackData: ?*anyopaque = null,
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
    CmdLists: std.ArrayListUnmanaged(*ByteDrawList) = .empty,

    fn deinit(self: *ByteDrawData) void {
        self.CmdLists.deinit(allocator);
        self.* = .{};
    }
};

pub const ByteGUIIO = struct {
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

pub const ByteGUIStyle = struct {
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
    Colors: [ByteGUICol_COUNT]ByteVec4 = .{
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
    FilePath: []u8 = &.{},
    FontStyle: i32 = FontStyleRegular,
    PixelSnapH: bool = false,
    OversampleH: u32 = 1,
    OversampleV: u32 = 1,
    FontData: []u8 = &.{},
    ByteTypeFace: bt.FontFace = .{},

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
        return measureTextWithRasterizer(self, size, slice, effective_wrap);
    }

    fn deinit(self: *ByteFont) void {
        self.ByteTypeFace.deinit();
        if (self.FilePath.len > 0) allocator.free(self.FilePath);
        if (self.FontData.len > 0) allocator.free(self.FontData);
        self.* = undefined;
    }
};

pub const ByteFontAtlas = struct {
    Fonts: std.ArrayListUnmanaged(*ByteFont) = .empty,

    pub fn AddFontFromFileTTF(self: *ByteFontAtlas, filename: []const u8, size_pixels: f32, font_cfg: ?*const ByteFontConfig) ?*ByteFont {
        if (filename.len == 0 or size_pixels <= 0.0) return null;
        return addFontFromFile(self, filename, size_pixels, font_cfg);
    }

    pub fn AddFontFromMemoryTTF(self: *ByteFontAtlas, font_data: []const u8, debug_name: []const u8, size_pixels: f32, font_cfg: ?*const ByteFontConfig) ?*ByteFont {
        if (font_data.len == 0 or size_pixels <= 0.0) return null;
        return addFontFromMemory(self, font_data, debug_name, size_pixels, font_cfg);
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
    VtxBuffer: std.ArrayListUnmanaged(ByteDrawVert) = .empty,
    IdxBuffer: std.ArrayListUnmanaged(ByteDrawIdx) = .empty,
    CmdBuffer: std.ArrayListUnmanaged(ByteDrawCmd) = .empty,
    Path: ByteVec2List = .empty,

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
                const avg = computeAAMiterOffset(n0, n1, 0.5);

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

        var points: ByteVec2List = .empty;
        defer points.deinit(allocator);

        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(clamped_rounding), 4));
        appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi, kPi * 1.5, segments);
        appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi * 1.5, kPi * 2.0, segments);
        appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, 0.0, kPi * 0.5, segments);
        appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, kPi * 0.5, kPi, segments);
        self.AddConvexPolyFilled(points.items, col);
    }

    pub fn AddRectFilledCornerFlags(self: *ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, col: ByteU32, rounding: f32, corner_flags: u8) void {
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;
        if (p_max.x <= p_min.x or p_max.y <= p_min.y) return;
        if ((corner_flags & ByteDrawCornerFlags_All) == ByteDrawCornerFlags_All) {
            self.AddRectFilled(p_min, p_max, col, rounding);
            return;
        }

        var clamped_rounding = @max(0.0, rounding);
        const max_rounding = @min((p_max.x - p_min.x) * 0.5, (p_max.y - p_min.y) * 0.5);
        clamped_rounding = @min(clamped_rounding, max_rounding);
        if (clamped_rounding <= 0.0 or (corner_flags & ByteDrawCornerFlags_All) == 0) {
            self.AddRectFilled(p_min, p_max, col, 0.0);
            return;
        }

        var points: ByteVec2List = .empty;
        defer points.deinit(allocator);

        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(clamped_rounding), 4));
        if ((corner_flags & ByteDrawCornerFlags_TopLeft) != 0) {
            appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi, kPi * 1.5, segments);
        } else points.append(allocator, p_min) catch return;

        if ((corner_flags & ByteDrawCornerFlags_TopRight) != 0) {
            appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi * 1.5, kPi * 2.0, segments);
        } else points.append(allocator, .{ .x = p_max.x, .y = p_min.y }) catch return;

        if ((corner_flags & ByteDrawCornerFlags_BottomRight) != 0) {
            appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, 0.0, kPi * 0.5, segments);
        } else points.append(allocator, p_max) catch return;

        if ((corner_flags & ByteDrawCornerFlags_BottomLeft) != 0) {
            appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, kPi * 0.5, kPi, segments);
        } else points.append(allocator, .{ .x = p_min.x, .y = p_max.y }) catch return;

        self.AddConvexPolyFilled(points.items, col);
    }

    pub fn AddConvexPolyFilledHorizontalGradient(self: *ByteDrawList, points: []const ByteVec2, col_left: ByteU32, col_right: ByteU32, gradient_left: f32, gradient_right: f32, gradient_center: f32) void {
        if (points.len < 3 or ((col_left | col_right) & BYTEGUI_COL32_A_MASK) == 0) return;

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

            const base_idx: ByteDrawIdx = @intCast(self.VtxBuffer.items.len);
            for (points, 0..) |point, i| {
                const n0 = normals[(i + points.len - 1) % points.len];
                const n1 = normals[i];
                const avg = computeAAMiterOffset(n0, n1, 0.5);
                const col = horizontalGradientColor(point.x, gradient_left, gradient_right, gradient_center, col_left, col_right);

                self.addVertex(.{ .x = point.x - avg.x, .y = point.y - avg.y }, uv, col) catch return;
                self.addVertex(.{ .x = point.x + avg.x, .y = point.y + avg.y }, uv, col & ~BYTEGUI_COL32_A_MASK) catch return;
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
                self.addVertex(point, uv, horizontalGradientColor(point.x, gradient_left, gradient_right, gradient_center, col_left, col_right)) catch return;
            }
            var i: usize = 2;
            while (i < points.len) : (i += 1) {
                self.addTriangleIndices(base_idx, base_idx + @as(ByteDrawIdx, @intCast(i - 1)), base_idx + @as(ByteDrawIdx, @intCast(i))) catch return;
            }
        }

        self.addPrimitive(self.WhiteTexture, @intCast(self.IdxBuffer.items.len - idx_start)) catch return;
    }

    pub fn AddRectFilledHorizontalGradient(self: *ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, col_left: ByteU32, col_right: ByteU32, rounding: f32) void {
        self.AddRectFilledHorizontalGradientBiased(p_min, p_max, col_left, col_right, rounding, 0.5);
    }

    pub fn AddRectFilledHorizontalGradientBiased(self: *ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, col_left: ByteU32, col_right: ByteU32, rounding: f32, gradient_center: f32) void {
        if (((col_left | col_right) & BYTEGUI_COL32_A_MASK) == 0) return;

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
            self.AddConvexPolyFilledHorizontalGradient(&points, col_left, col_right, p_min.x, p_max.x, gradient_center);
            return;
        }

        var points: ByteVec2List = .empty;
        defer points.deinit(allocator);

        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(clamped_rounding), 4));
        appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi, kPi * 1.5, segments);
        appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_min.y + clamped_rounding }, clamped_rounding, kPi * 1.5, kPi * 2.0, segments);
        appendArc(&points, .{ .x = p_max.x - clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, 0.0, kPi * 0.5, segments);
        appendArc(&points, .{ .x = p_min.x + clamped_rounding, .y = p_max.y - clamped_rounding }, clamped_rounding, kPi * 0.5, kPi, segments);
        self.AddConvexPolyFilledHorizontalGradient(points.items, col_left, col_right, p_min.x, p_max.x, gradient_center);
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
        var points: ByteVec2List = .empty;
        defer points.deinit(allocator);
        points.ensureTotalCapacity(allocator, @intCast(segments)) catch return;
        var i: i32 = 0;
        while (i < segments) : (i += 1) {
            const a = (@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments))) * (2.0 * kPi);
            points.appendAssumeCapacity(.{ .x = center.x + @cos(a) * radius, .y = center.y + @sin(a) * radius });
        }
        self.AddPolylineInternal(points.items, col, true, thickness);
    }

    pub fn AddCircleRing(self: *ByteDrawList, center: ByteVec2, inner_radius: f32, outer_radius: f32, col: ByteU32, num_segments: i32) void {
        if ((col & BYTEGUI_COL32_A_MASK) == 0 or outer_radius <= 0.0) return;

        const inner = @max(0.0, @min(inner_radius, outer_radius));
        const outer = @max(inner, outer_radius);
        if (outer <= inner) return;

        const stroke = outer - inner;
        const aa_radius: f32 = if ((self.Flags & ByteDrawListFlags_AntiAliasedFill) != 0) @min(0.5, stroke * 0.5) else 0.0;
        const radii = [_]f32{
            @max(0.0, inner - aa_radius),
            inner + aa_radius,
            outer - aa_radius,
            outer + aa_radius,
        };
        const colors = [_]ByteU32{
            col & ~BYTEGUI_COL32_A_MASK,
            col,
            col,
            col & ~BYTEGUI_COL32_A_MASK,
        };

        const segments = @max(@as(i32, 12), if (num_segments > 0) num_segments else calcCircleSegmentCount(outer));
        const idx_start = self.IdxBuffer.items.len;
        const base_idx: ByteDrawIdx = @intCast(self.VtxBuffer.items.len);
        const uv = ByteVec2{ .x = 0.5, .y = 0.5 };

        var i: i32 = 0;
        while (i < segments) : (i += 1) {
            const a = (@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments))) * (2.0 * kPi);
            const dir = ByteVec2{ .x = @cos(a), .y = @sin(a) };
            for (radii, colors) |radius, color| {
                self.addVertex(.{ .x = center.x + dir.x * radius, .y = center.y + dir.y * radius }, uv, color) catch return;
            }
        }

        i = 0;
        while (i < segments) : (i += 1) {
            const next_i: i32 = if (i + 1 < segments) i + 1 else 0;
            const current: ByteDrawIdx = base_idx + @as(ByteDrawIdx, @intCast(i * 4));
            const next: ByteDrawIdx = base_idx + @as(ByteDrawIdx, @intCast(next_i * 4));
            var band: ByteDrawIdx = 0;
            while (band < 3) : (band += 1) {
                const inner0 = current + band;
                const outer0 = inner0 + 1;
                const inner1 = next + band;
                const outer1 = inner1 + 1;
                self.addTriangleIndices(inner0, outer0, outer1) catch return;
                self.addTriangleIndices(inner0, outer1, inner1) catch return;
            }
        }

        self.addPrimitive(self.WhiteTexture, @intCast(self.IdxBuffer.items.len - idx_start)) catch return;
    }

    pub fn AddCircleFilled(self: *ByteDrawList, center: ByteVec2, radius: f32, col: ByteU32, num_segments: i32) void {
        if (radius <= 0.0) return;
        const segments = if (num_segments > 0) num_segments else calcCircleSegmentCount(radius);
        var points: ByteVec2List = .empty;
        defer points.deinit(allocator);
        points.ensureTotalCapacity(allocator, @intCast(segments)) catch return;
        var i: i32 = 0;
        while (i < segments) : (i += 1) {
            const a = (@as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments))) * (2.0 * kPi);
            points.appendAssumeCapacity(.{ .x = center.x + @cos(a) * radius, .y = center.y + @sin(a) * radius });
        }
        self.AddConvexPolyFilled(points.items, col);
    }

    fn AddTextInternal(self: *ByteDrawList, font: ?*ByteFont, font_size: f32, pos: ByteVec2, col: ByteU32, text_begin: []const u8, text_end: ?usize, filter: TextureFilter, snap_to_pixel: bool) void {
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

        const slice = sliceFromOptionalEnd(text_begin, text_end);
        const entry = getOrCreateTextTextureWithFilter(font, font_size, 0.0, slice, filter) orelse return;
        const texture = entry.Texture;
        if (texture == null) return;
        const draw_pos = if (snap_to_pixel) ByteVec2{ .x = @floor(pos.x + 0.5), .y = @floor(pos.y + 0.5) } else pos;
        const image_pos = ByteVec2{ .x = draw_pos.x + entry.DrawOffset.x, .y = draw_pos.y + entry.DrawOffset.y };
        const image_size = if (entry.ImageSize.x > 0.0 and entry.ImageSize.y > 0.0) entry.ImageSize else entry.DisplaySize;
        self.AddImage(texture, image_pos, .{ .x = image_pos.x + image_size.x, .y = image_pos.y + image_size.y }, entry.UvMin, entry.UvMax, col);
    }

    pub fn AddText(self: *ByteDrawList, font: ?*ByteFont, font_size: f32, pos: ByteVec2, col: ByteU32, text_begin: []const u8, text_end: ?usize) void {
        self.AddTextInternal(font, font_size, pos, col, text_begin, text_end, .nearest, true);
    }

    pub fn AddTextSubpixel(self: *ByteDrawList, font: ?*ByteFont, font_size: f32, pos: ByteVec2, col: ByteU32, text_begin: []const u8, text_end: ?usize) void {
        self.AddTextInternal(font, font_size, pos, col, text_begin, text_end, .linear, false);
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
            if (last.UserCallback == null and last.TextureId == texture_id and equalClipRect(last.ClipRect, self.CurrentClipRect) and last.IdxOffset + last.ElemCount == index_start) {
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

pub const ByteGUIPlatformWindowConfig = struct {
    Instance: c.HINSTANCE = null,
    WndProc: c.WNDPROC = null,
    ClassName: [*:0]const u16 = default_class_name,
    Title: [*:0]const u16 = default_title,
    IconResourceId: u16 = 0,
    LogicalWidth: i32 = 0,
    LogicalHeight: i32 = 0,
    Style: c.DWORD = c.WS_POPUP,
    ExStyle: c.DWORD = c.WS_EX_APPWINDOW,
    CenterOnPrimaryMonitor: bool = true,
};

const TextCacheEntry = struct {
    Font: *ByteFont,
    PixelSize100: i32,
    WrapWidth100: i32,
    Filter: TextureFilter,
    Text: []u8,
    Texture: ByteTextureID = null,
    DisplaySize: ByteVec2 = .{},
    ImageSize: ByteVec2 = .{},
    DrawOffset: ByteVec2 = .{},
    UvMin: ByteVec2 = .{},
    UvMax: ByteVec2 = .{ .x = 1.0, .y = 1.0 },

    fn deinit(self: *TextCacheEntry) void {
        releaseTexture(self.Texture);
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

pub const ByteGUIContext = struct {
    IO: ByteGUIIO = .{},
    Style: ByteGUIStyle = .{},
    FontAtlas: ByteFontAtlas = .{},
    DrawList: ByteDrawList = .{},
    DrawData: ByteDrawData = .{},

    CurrentFont: ?*ByteFont = null,
    FontStack: std.ArrayListUnmanaged(*ByteFont) = .empty,
    AlphaStack: std.ArrayListUnmanaged(f32) = .empty,
    ChildStack: std.ArrayListUnmanaged(ChildState) = .empty,

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

    TextCache: std.ArrayListUnmanaged(TextCacheEntry) = .empty,

    fn init(self: *ByteGUIContext) void {
        self.* = .{};
        self.IO.Fonts = &self.FontAtlas;
    }

    fn deinit(self: *ByteGUIContext) void {
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

const MiniOpenGLBackendData = struct {
    WindowHwnd: ?w32.HWND = null,
    WindowDc: ?w32.HDC = null,
    RenderContext: ?w32.HGLRC = null,
    WhiteTexture: ByteTextureID = null,
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

var GByteGUI: ?*ByteGUIContext = null;
var GHostWindow: HostWindowData = .{};

// Immediate-mode context and front end
pub const ByteGUI = struct {
    pub fn CreateContext() ?*ByteGUIContext {
        DestroyContext(null);
        const ctx = allocator.create(ByteGUIContext) catch return null;
        ctx.init();
        GByteGUI = ctx;
        return ctx;
    }

    pub fn DestroyContext(ctx: ?*ByteGUIContext) void {
        var actual = ctx;
        if (actual == null) actual = GByteGUI;
        if (actual == null) return;

        if (actual == GByteGUI) clearTextCache();
        actual.?.deinit();
        allocator.destroy(actual.?);
        if (actual == GByteGUI) GByteGUI = null;
        if (GByteGUI == null) bt.shutdown();
    }

    pub fn GetCurrentContext() ?*ByteGUIContext {
        return GByteGUI;
    }

    pub fn GetIO() *ByteGUIIO {
        return &GByteGUI.?.IO;
    }

    pub fn GetStyle() *ByteGUIStyle {
        return &GByteGUI.?.Style;
    }

    pub fn GetDrawData() ?*ByteDrawData {
        if (GByteGUI) |ctx| return &ctx.DrawData;
        return null;
    }

    pub fn GetWindowDrawList() ?*ByteDrawList {
        if (GByteGUI) |ctx| return &ctx.DrawList;
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
        const ctx = GByteGUI orelse return;

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
        const ctx = GByteGUI orelse return;

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

    pub fn Begin(name: []const u8, p_open: ?*bool, flags: ByteGUIWindowFlags) bool {
        _ = name;
        _ = p_open;
        _ = flags;

        const ctx = GByteGUI orelse return false;
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

    pub fn BeginChild(str_id: []const u8, size: ByteVec2, border: bool, flags: ByteGUIWindowFlags) bool {
        _ = str_id;
        _ = border;
        _ = flags;

        const ctx = GByteGUI orelse return false;
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
        const ctx = GByteGUI orelse return;
        if (ctx.ChildStack.items.len == 0) return;

        const child = ctx.ChildStack.pop().?;
        ctx.CurrentClipRect = child.PreviousClipRect;
        ctx.DrawList.SetClipRect(ctx.CurrentClipRect);
        ctx.CursorScreenPos = child.PreviousCursorPos;
    }

    pub fn SetNextWindowPos(pos: ByteVec2) void {
        const ctx = GByteGUI orelse return;
        ctx.NextWindowPos = pos;
        ctx.HasNextWindowPos = true;
    }

    pub fn SetNextWindowSize(size: ByteVec2) void {
        const ctx = GByteGUI orelse return;
        ctx.NextWindowSize = size;
        ctx.HasNextWindowSize = true;
    }

    pub fn SetCursorScreenPos(pos: ByteVec2) void {
        const ctx = GByteGUI orelse return;
        ctx.CursorScreenPos = pos;
    }

    pub fn TextWrapped(comptime fmt: []const u8, args: anytype) void {
        const ctx = GByteGUI orelse return;
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
        const texture = entry.Texture;
        if (texture == null) return;

        var color = ctx.Style.Colors[ByteGUICol_Text];
        color.w *= ctx.Style.Alpha;
        const col_u32 = ColorConvertFloat4ToU32(color);
        const pos = ByteVec2{ .x = @floor(ctx.CursorScreenPos.x + 0.5), .y = @floor(ctx.CursorScreenPos.y + 0.5) };
        const image_pos = ByteVec2{ .x = pos.x + entry.DrawOffset.x, .y = pos.y + entry.DrawOffset.y };
        const image_size = if (entry.ImageSize.x > 0.0 and entry.ImageSize.y > 0.0) entry.ImageSize else entry.DisplaySize;
        ctx.DrawList.AddImage(texture, image_pos, .{ .x = image_pos.x + image_size.x, .y = image_pos.y + image_size.y }, entry.UvMin, entry.UvMax, col_u32);
        ctx.CursorScreenPos.y += entry.DisplaySize.y;
    }

    pub fn PrewarmTextTexture(font: ?*ByteFont, font_size: f32, wrap_width: f32, text: []const u8) bool {
        return getOrCreateTextTexture(font, font_size, wrap_width, text) != null;
    }

    pub fn CalcTextSize(font: ?*ByteFont, font_size: f32, text: []const u8, text_end: ?usize, wrap_width: f32) ByteVec2 {
        const active_font = font orelse return .{};
        if (text.len == 0) return .{};
        return active_font.CalcTextSizeA(font_size, std.math.floatMax(f32), wrap_width, text, text_end);
    }

    pub fn CalcTextWidth(font: ?*ByteFont, font_size: f32, text: []const u8) f32 {
        const active_font = font orelse return 0.0;
        if (text.len == 0) return 0.0;
        return @max(0.0, computeTextBounds(active_font, font_size, text).Width);
    }

    pub fn LayoutText(font: ?*ByteFont, font_size: f32, text: []const u8, wrap_width: f32) ?TextLayoutResult {
        const active_font = font orelse return null;
        return layoutText(active_font, font_size, text, wrap_width);
    }

    pub fn LayoutScrollableText(params: ScrollableTextLayoutParams) ?ScrollableTextLayoutResult {
        return layoutScrollableText(params);
    }

    pub fn CalcTextScrollMax(content_height: f32, viewport_height: f32) f32 {
        return calcTextScrollMax(content_height, viewport_height);
    }

    pub fn CalcTextLineVisualMid(layout: *const TextLayoutResult, line_index: usize) f32 {
        return calcTextLineVisualMid(layout, line_index);
    }

    pub fn SnapTextScrollYToLine(value: f32, max_scroll: f32, layout: *const TextLayoutResult) f32 {
        return snapTextScrollYToLine(value, max_scroll, layout);
    }

    pub fn SnapTextScrollYToLineHeight(value: f32, max_scroll: f32, line_height: f32) f32 {
        return snapTextScrollYToLineHeight(value, max_scroll, line_height);
    }

    pub fn TextIndexFromPoint(params: TextIndexFromPointParams) usize {
        return textIndexFromPoint(params);
    }

    pub fn TextIndexFromDragPoint(params: TextIndexFromPointParams) usize {
        return textIndexFromDragPoint(params);
    }

    pub fn DrawTextLayoutClipped(draw: ?*ByteDrawList, params: TextLayoutDrawParams) void {
        drawTextLayoutClipped(draw, params);
    }

    pub fn DrawTextSelectionHighlight(draw: ?*ByteDrawList, state: *TextSelectionHighlightState, params: TextSelectionHighlightParams) void {
        drawTextSelectionHighlight(draw, state, params);
    }

    pub fn DrawTextSelectionHighlightClipped(draw: ?*ByteDrawList, state: *TextSelectionHighlightState, params: TextSelectionHighlightParams, clip_rect: w32.RECT) void {
        drawTextSelectionHighlightClipped(draw, state, params, clip_rect);
    }

    pub fn CalcVerticalScrollbarMetrics(params: VerticalScrollbarParams) ?ScrollbarMetrics {
        return calcVerticalScrollbarMetrics(params);
    }

    pub fn CalcVerticalScrollbarTrack(params: VerticalScrollbarTrackParams) VerticalScrollbarTrack {
        return calcVerticalScrollbarTrack(params);
    }

    pub fn CalcVerticalScrollbarMetricsForTrack(track: VerticalScrollbarTrack, content_height: f32, viewport_height: f32, scroll_y: f32, min_thumb_height: f32) ?ScrollbarMetrics {
        return calcVerticalScrollbarMetrics(.{
            .track_pos = track.pos,
            .track_size = track.size,
            .content_height = content_height,
            .viewport_height = viewport_height,
            .scroll_y = scroll_y,
            .min_thumb_height = min_thumb_height,
        });
    }

    pub fn VerticalScrollbarInactiveMetrics(track: VerticalScrollbarTrack) ScrollbarMetrics {
        return .{
            .track_pos = track.pos,
            .track_size = track.size,
            .thumb_pos = track.pos,
            .thumb_size = track.size,
            .max_scroll = 0.0,
        };
    }

    pub fn ScrollbarScrollForThumbTop(metrics: ScrollbarMetrics, thumb_top: f32) f32 {
        return scrollbarScrollForThumbTop(metrics, thumb_top);
    }

    pub fn ScrollbarDragScrollFromThumbOffset(metrics: ScrollbarMetrics, point_y: f32, thumb_offset_y: f32) f32 {
        return scrollbarScrollForThumbTop(metrics, point_y - thumb_offset_y);
    }

    pub fn PointInScrollbarThumb(metrics: ScrollbarMetrics, point: ByteVec2, hit_pad: f32) bool {
        return pointInScrollbarThumb(metrics, point, hit_pad);
    }

    pub fn ScrollbarDragScroll(metrics: ScrollbarMetrics, start_scroll: f32, drag_delta: f32) f32 {
        return scrollbarDragScroll(metrics, start_scroll, drag_delta);
    }

    pub fn DrawVerticalScrollbar(draw: ?*ByteDrawList, state: *ScrollbarVisualState, params: ScrollbarDrawParams) void {
        drawVerticalScrollbar(draw, state, params);
    }

    pub fn CalcTextHitRect(font: ?*ByteFont, font_size: f32, pos: ByteVec2, text: []const u8, padding: f32, text_end: ?usize, wrap_width: f32) c.RECT {
        const active_font = font orelse return makeHitRectFromBounds(pos.x - padding, pos.y - padding, pos.x + padding, pos.y + padding);
        const slice = sliceFromOptionalEnd(text, text_end);
        const size = CalcTextSize(active_font, font_size, slice, null, wrap_width);
        const inset = textRenderInsetPx(active_font, font_size);
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

        var points: ByteVec2List = .empty;
        points.ensureTotalCapacity(allocator, @intCast((segments + 1) * 4)) catch return .empty;

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
        var points: ByteVec2List = .empty;
        points.ensureTotalCapacity(allocator, 4) catch return .empty;
        points.appendAssumeCapacity(.{ .x = left, .y = top });
        points.appendAssumeCapacity(.{ .x = right, .y = top });
        points.appendAssumeCapacity(.{ .x = right, .y = bottom });
        points.appendAssumeCapacity(.{ .x = left, .y = bottom });
        return points;
    }

    pub fn BuildCornerSectorPolygon(center: ByteVec2, radius: f32, start_angle: f32, end_angle: f32, arc_segments: i32) ByteVec2List {
        const segments: i32 = if (arc_segments > 0) arc_segments else 8;
        var points: ByteVec2List = .empty;
        points.ensureTotalCapacity(allocator, @intCast(segments + 3)) catch return .empty;
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
        if (subject.len == 0 or clip.len < 3) return .empty;

        var output: ByteVec2List = .empty;
        output.ensureTotalCapacity(allocator, @intCast(subject.len)) catch return .empty;
        for (subject) |point| output.appendAssumeCapacity(point);

        const clip_is_ccw = signedArea(clip) > 0.0;
        for (clip, 0..) |clip_a, i| {
            const clip_b = clip[(i + 1) % clip.len];
            if (output.items.len == 0) break;

            var input = output;
            output = .empty;
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

    pub fn DrawWindowControlGlyph(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, col: ByteU32, is_close: bool, style: anytype) void {
        const active_draw = draw orelse return;
        if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

        if (is_close) {
            const cx = pos.x + size.x * 0.5;
            const cy = pos.y + size.y * 0.5;
            const min_size = @min(size.x, size.y);
            const pad = min_size * style.close_padding_ratio;
            const stroke = @max(1.0, min_size * style.close_stroke_ratio);
            DrawFlatSegment(active_draw, .{ .x = cx - pad, .y = cy - pad }, .{ .x = cx + pad, .y = cy + pad }, stroke, col);
            DrawFlatSegment(active_draw, .{ .x = cx - pad, .y = cy + pad }, .{ .x = cx + pad, .y = cy - pad }, stroke, col);
            return;
        }

        const stroke = @max(1.0, size.y * style.minimize_stroke_ratio);
        const bar_len = size.x * style.minimize_bar_width_ratio;
        const x_start = @floor(pos.x + (size.x - bar_len) * 0.5 + 0.5);
        const y_top = @floor(pos.y + size.y * style.minimize_y_ratio - stroke * 0.5 + 0.5);
        const width = @floor(bar_len + 0.5);
        const height: f32 = @floatFromInt(@max(@as(i32, 1), @as(i32, @intFromFloat(@round(stroke)))));
        active_draw.AddRectFilled(.{ .x = x_start, .y = y_top }, .{ .x = x_start + width, .y = y_top + height }, col, 0.0);
    }

    pub fn DrawInfoGlyph(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, ring_col: ByteU32, style: anytype, arc_segments: i32) void {
        const active_draw = draw orelse return;
        if ((ring_col & BYTEGUI_COL32_A_MASK) == 0) return;

        const icon_size = @min(size.x, size.y);
        const padding = icon_size * style.padding_ratio;
        const circle_size = icon_size - padding * 2.0;
        if (circle_size <= 0.0) return;

        const circle_left = pos.x + (size.x - icon_size) * 0.5;
        const circle_top = pos.y + (size.y - icon_size) * 0.5;
        const center = ByteVec2{
            .x = @floor(circle_left + padding + circle_size * 0.5 + 0.5),
            .y = @floor(circle_top + padding + circle_size * 0.5 + 0.5),
        };
        const stroke = @max(0.0, @min(style.ring_thickness, circle_size * 0.5));
        const outer_radius = @floor(circle_size * 0.5 + 0.5);
        const inner_radius = @max(0.0, outer_radius - stroke);
        const segments = if (arc_segments > 0) arc_segments else std.math.clamp(calcCircleSegmentCount(outer_radius) * 2, 72, 160);

        active_draw.AddCircleRing(center, inner_radius, outer_radius, ring_col, segments);

        const stem_width = circle_size * style.stem_width_ratio;
        const stem_height = circle_size * style.stem_height_ratio;
        const stem_x = center.x - stem_width * 0.5;
        const stem_y = circle_top + padding + circle_size * style.stem_y_ratio;
        active_draw.AddRectFilled(.{ .x = stem_x, .y = stem_y }, .{ .x = stem_x + stem_width, .y = stem_y + stem_height }, ring_col, 0.0);

        const dot_diameter = circle_size * style.dot_diameter_ratio;
        active_draw.AddCircleFilled(
            .{ .x = center.x, .y = circle_top + padding + circle_size * style.dot_y_ratio + dot_diameter * 0.5 },
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
        const ctx = GByteGUI orelse return;
        const active = font orelse return;
        ctx.FontStack.append(allocator, active) catch return;
        ctx.CurrentFont = active;
    }

    pub fn PopFont() void {
        const ctx = GByteGUI orelse return;
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

    pub fn PushStyleVar(idx: ByteGUIStyleVar, val: f32) void {
        const ctx = GByteGUI orelse return;
        if (idx != ByteGUIStyleVar_Alpha) return;
        ctx.AlphaStack.append(allocator, ctx.Style.Alpha) catch return;
        ctx.Style.Alpha = val;
    }

    pub fn PopStyleVar(count: i32) void {
        const ctx = GByteGUI orelse return;
        var remaining = count;
        while (remaining > 0 and ctx.AlphaStack.items.len > 0) : (remaining -= 1) {
            ctx.Style.Alpha = ctx.AlphaStack.pop().?;
        }
    }
};

// Higher-level UI helpers
pub const Ui = struct {
    pub const TextTexture = struct {
        texture: ByteTextureID = null,
        display_size_px: ByteVec2 = .{},
        image_size_px: ByteVec2 = .{},
        draw_offset_px: ByteVec2 = .{},
        uv_min: ByteVec2 = .{},
        uv_max: ByteVec2 = .{ .x = 1.0, .y = 1.0 },
    };

    pub const RasterizedTexture = struct {
        rgba: []u8 = &[_]u8{},
        pixel_w: u32 = 0,
        pixel_h: u32 = 0,
        display_size_px: ByteVec2 = .{},
        image_size_px: ByteVec2 = .{},
        draw_offset_px: ByteVec2 = .{},
        uv_min: ByteVec2 = .{},
        uv_max: ByteVec2 = .{ .x = 1.0, .y = 1.0 },
    };

    pub fn CleanupTexture(texture: *ByteTextureID) void {
        releaseTexture(texture.*);
        texture.* = null;
    }

    pub fn CleanupTextTexture(texture: *TextTexture) void {
        CleanupTexture(&texture.texture);
        texture.display_size_px = .{};
        texture.image_size_px = .{};
        texture.draw_offset_px = .{};
        texture.uv_min = .{};
        texture.uv_max = .{ .x = 1.0, .y = 1.0 };
    }

    pub fn CleanupRasterizedTexture(texture: *RasterizedTexture) void {
        if (texture.rgba.len > 0) allocator.free(texture.rgba);
        texture.* = .{};
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
        return ByteGUI.ColorConvertFloat4ToU32(color);
    }

    pub fn ScaleF(value: f32) f32 {
        return ByteGUI_ImplWin32_ScaleF(value);
    }

    pub fn ScaleI(value: i32) i32 {
        return ByteGUI_ImplWin32_ScaleI(value);
    }

    pub fn ScaleIF(value: f32) i32 {
        return ByteGUI_ImplWin32_ScaleI_F(value);
    }

    pub fn ScaleVec2(x: f32, y: f32) ByteVec2 {
        return ByteGUI_ImplWin32_ScaleVec2(x, y);
    }

    pub fn SnapPixel(value: f32) f32 {
        return ByteGUI_ImplWin32_SnapPixel(value);
    }

    pub fn SnapPixelVec2(value: ByteVec2) ByteVec2 {
        return ByteGUI_ImplWin32_SnapPixel(value);
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
        const left = SnapPixel(pos.x);
        const top = SnapPixel(pos.y);
        const right = SnapPixel(pos.x + size.x);
        const bottom = SnapPixel(pos.y + size.y);
        const width = @max(0.0, right - left);
        const height = @max(0.0, bottom - top);
        const px: f32 = @floatFromInt(pt.x);
        const py: f32 = @floatFromInt(pt.y);
        if (px < left or px >= right or py < top or py >= bottom) return false;

        const r = @min(SnapPixel(radius), @min(width, height) * 0.5);
        if (r <= 0.0) return true;

        if (px >= left + r and px < right - r) return true;
        if (py >= top + r and py < bottom - r) return true;

        const ss: i32 = 4;
        const sample_scale = 1.0 / @as(f32, @floatFromInt(ss));
        var sy: i32 = 0;
        while (sy < ss) : (sy += 1) {
            var sx: i32 = 0;
            while (sx < ss) : (sx += 1) {
                const sample = ByteVec2{
                    .x = px + (@as(f32, @floatFromInt(sx)) + 0.5) * sample_scale,
                    .y = py + (@as(f32, @floatFromInt(sy)) + 0.5) * sample_scale,
                };
                if (roundedRectSignedDistance(.{ .x = left, .y = top }, .{ .x = width, .y = height }, r, sample) <= 0.0) return true;
            }
        }

        return false;
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
        ByteGUI.DrawConvexPolyFilledClippedToCornerOnlyRoundedRect(active_draw, &subject, clip_pos, clip_size, clip_radius, col, arc_segments);
    }

    pub fn DrawDiagonalBandClippedToCornerOnlyRoundedRect(
        draw: ?*ByteDrawList,
        window_size: ByteVec2,
        contact: ByteVec2,
        corner_radius: f32,
        color: ByteVec4,
        opacity: f32,
        arc_segments: i32,
    ) void {
        const active_draw = draw orelse return;
        const edge_axis = ByteVec2{ .x = 0.70710677, .y = -0.70710677 };
        const fill_axis = ByteVec2{ .x = 0.70710677, .y = 0.70710677 };
        const span = @sqrt(window_size.x * window_size.x + window_size.y * window_size.y);
        const thickness = @max(1.0, window_size.y - corner_radius * 0.4);
        const contact_start = ByteVec2{ .x = contact.x - edge_axis.x * span, .y = contact.y - edge_axis.y * span };
        const contact_end = ByteVec2{ .x = contact.x + edge_axis.x * span, .y = contact.y + edge_axis.y * span };
        const edge_start = ByteVec2{ .x = contact_start.x - fill_axis.x * thickness, .y = contact_start.y - fill_axis.y * thickness };
        const edge_end = ByteVec2{ .x = contact_end.x - fill_axis.x * thickness, .y = contact_end.y - fill_axis.y * thickness };
        const subject = [_]ByteVec2{
            edge_start,
            edge_end,
            contact_end,
            contact_start,
        };
        ByteGUI.DrawConvexPolyFilledClippedToCornerOnlyRoundedRect(
            active_draw,
            subject[0..],
            .{ .x = 0.0, .y = 0.0 },
            window_size,
            corner_radius,
            ColorToU32(ApplyOpacity(color, opacity)),
            arc_segments,
        );
    }

    pub fn DrawTextTextureCentered(draw: ?*ByteDrawList, texture: *const TextTexture, center: ByteVec2, scale: f32, color: ByteVec4, opacity: f32) bool {
        const active_draw = draw orelse return false;
        if (texture.texture == null or texture.display_size_px.x <= 0.0 or texture.display_size_px.y <= 0.0) return false;

        const texture_size = if (texture.image_size_px.x > 0.0 and texture.image_size_px.y > 0.0) texture.image_size_px else texture.display_size_px;
        const content_size = ByteVec2{
            .x = texture.display_size_px.x * scale,
            .y = texture.display_size_px.y * scale,
        };
        const image_size = ByteVec2{
            .x = texture_size.x * scale,
            .y = texture_size.y * scale,
        };
        const content_pos = ByteVec2{
            .x = center.x - content_size.x * 0.5,
            .y = center.y - content_size.y * 0.5,
        };
        const image_pos = ByteVec2{
            .x = content_pos.x + texture.draw_offset_px.x * scale,
            .y = content_pos.y + texture.draw_offset_px.y * scale,
        };

        active_draw.AddImage(
            @ptrCast(texture.texture),
            image_pos,
            .{ .x = image_pos.x + image_size.x, .y = image_pos.y + image_size.y },
            texture.uv_min,
            texture.uv_max,
            ColorToU32(ApplyOpacity(color, opacity)),
        );
        return true;
    }

    pub fn DrawStackedTextTexturesCentered(
        draw: ?*ByteDrawList,
        top_texture: *const TextTexture,
        bottom_texture: *const TextTexture,
        center: ByteVec2,
        scale: f32,
        center_gap: f32,
        color: ByteVec4,
        opacity: f32,
    ) bool {
        const top_ok = DrawTextTextureCentered(draw, top_texture, .{ .x = center.x, .y = center.y - center_gap * 0.5 }, scale, color, opacity);
        const bottom_ok = DrawTextTextureCentered(draw, bottom_texture, .{ .x = center.x, .y = center.y + center_gap * 0.5 }, scale, color, opacity);
        return top_ok and bottom_ok;
    }

    pub fn DrawDebugOutlineBounds(draw: ?*ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, color: ByteVec4, opacity: f32, thickness: f32) void {
        const active_draw = draw orelse return;
        const left = @floor(@min(p_min.x, p_max.x));
        const top = @floor(@min(p_min.y, p_max.y));
        const right = @ceil(@max(p_min.x, p_max.x));
        const bottom = @ceil(@max(p_min.y, p_max.y));
        if (right <= left or bottom <= top) return;

        const line_thickness = @max(1.0, thickness);
        const col = ColorToU32(ApplyOpacity(color, opacity));
        active_draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = right, .y = @min(bottom, top + line_thickness) }, col, 0.0);
        active_draw.AddRectFilled(.{ .x = left, .y = @max(top, bottom - line_thickness) }, .{ .x = right, .y = bottom }, col, 0.0);
        active_draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = @min(right, left + line_thickness), .y = bottom }, col, 0.0);
        active_draw.AddRectFilled(.{ .x = @max(left, right - line_thickness), .y = top }, .{ .x = right, .y = bottom }, col, 0.0);
    }

    pub fn DrawDebugRectOutline(draw: ?*ByteDrawList, rect: anytype, color: ByteVec4, opacity: f32, thickness: f32) void {
        DrawDebugOutlineBounds(
            draw,
            .{ .x = @as(f32, @floatFromInt(rect.left)), .y = @as(f32, @floatFromInt(rect.top)) },
            .{ .x = @as(f32, @floatFromInt(rect.right)), .y = @as(f32, @floatFromInt(rect.bottom)) },
            color,
            opacity,
            thickness,
        );
    }

    pub fn DrawDebugBoxOutline(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, color: ByteVec4, opacity: f32, thickness: f32) void {
        DrawDebugOutlineBounds(draw, pos, .{ .x = pos.x + size.x, .y = pos.y + size.y }, color, opacity, thickness);
    }

    pub fn DrawDebugGUIdeVertical(draw: ?*ByteDrawList, x: f32, y_min: f32, y_max: f32, color: ByteVec4, opacity: f32, thickness: f32) void {
        const active_draw = draw orelse return;
        const top = @floor(@min(y_min, y_max));
        const bottom = @ceil(@max(y_min, y_max));
        if (bottom <= top) return;
        const line_thickness = @max(1.0, thickness);
        const left = @floor(x - line_thickness * 0.5);
        const col = ColorToU32(ApplyOpacity(color, opacity));
        active_draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = left + line_thickness, .y = bottom }, col, 0.0);
    }

    pub fn DrawDebugGUIdeHorizontal(draw: ?*ByteDrawList, y: f32, x_min: f32, x_max: f32, color: ByteVec4, opacity: f32, thickness: f32) void {
        const active_draw = draw orelse return;
        const left = @floor(@min(x_min, x_max));
        const right = @ceil(@max(x_min, x_max));
        if (right <= left) return;
        const line_thickness = @max(1.0, thickness);
        const top = @floor(y - line_thickness * 0.5);
        const col = ColorToU32(ApplyOpacity(color, opacity));
        active_draw.AddRectFilled(.{ .x = left, .y = top }, .{ .x = right, .y = top + line_thickness }, col, 0.0);
    }

    pub fn DrawDebugCrosshair(draw: ?*ByteDrawList, center: ByteVec2, radius: f32, color: ByteVec4, opacity: f32, thickness: f32) void {
        DrawDebugGUIdeHorizontal(draw, center.y, center.x - radius, center.x + radius, color, opacity, thickness);
        DrawDebugGUIdeVertical(draw, center.x, center.y - radius, center.y + radius, color, opacity, thickness);
    }

    pub fn DrawDebugLineSegment(draw: ?*ByteDrawList, center: ByteVec2, axis: ByteVec2, length: f32, thickness: f32, color: ByteVec4, opacity: f32) void {
        const active_draw = draw orelse return;
        const axis_len = @sqrt(axis.x * axis.x + axis.y * axis.y);
        if (axis_len <= 0.0 or length <= 0.0 or thickness <= 0.0) return;

        const dir = ByteVec2{ .x = axis.x / axis_len, .y = axis.y / axis_len };
        const normal = ByteVec2{ .x = -dir.y, .y = dir.x };
        const half_len = length * 0.5;
        const half_thick = thickness * 0.5;
        const p0 = ByteVec2{ .x = center.x - dir.x * half_len, .y = center.y - dir.y * half_len };
        const p1 = ByteVec2{ .x = center.x + dir.x * half_len, .y = center.y + dir.y * half_len };
        const points = [_]ByteVec2{
            .{ .x = p0.x + normal.x * half_thick, .y = p0.y + normal.y * half_thick },
            .{ .x = p1.x + normal.x * half_thick, .y = p1.y + normal.y * half_thick },
            .{ .x = p1.x - normal.x * half_thick, .y = p1.y - normal.y * half_thick },
            .{ .x = p0.x - normal.x * half_thick, .y = p0.y - normal.y * half_thick },
        };
        active_draw.AddConvexPolyFilled(&points, ColorToU32(ApplyOpacity(color, opacity)));
    }

    pub fn DrawHorizontalGradientRectFilled(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, radius: f32, left_color: ByteVec4, right_color: ByteVec4, opacity: f32) void {
        DrawHorizontalGradientRectFilledBiased(draw, pos, size, radius, left_color, right_color, opacity, 0.5);
    }

    pub fn DrawHorizontalGradientRectFilledBiased(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, radius: f32, left_color: ByteVec4, right_color: ByteVec4, opacity: f32, gradient_center: f32) void {
        const active_draw = draw orelse return;
        active_draw.AddRectFilledHorizontalGradientBiased(
            pos,
            .{ .x = pos.x + size.x, .y = pos.y + size.y },
            ColorToU32(ApplyOpacity(left_color, opacity)),
            ColorToU32(ApplyOpacity(right_color, opacity)),
            radius,
            gradient_center,
        );
    }

    const HorizontalRange = struct {
        left: f32,
        right: f32,
    };

    fn clampedRoundedRadius(size: ByteVec2, radius: f32) f32 {
        return @min(@max(0.0, radius), @min(size.x * 0.5, size.y * 0.5));
    }

    fn roundedRectHorizontalRangeAtY(pos: ByteVec2, size: ByteVec2, radius: f32, y: f32) ?HorizontalRange {
        const bottom = pos.y + size.y;
        if (y < pos.y or y > bottom) return null;

        const right = pos.x + size.x;
        var left_x = pos.x;
        var right_x = right;
        const r = clampedRoundedRadius(size, radius);
        if (r > 0.0) {
            if (y < pos.y + r) {
                const dy = (pos.y + r) - y;
                const dx = @sqrt(@max(0.0, r * r - dy * dy));
                left_x = pos.x + r - dx;
                right_x = right - r + dx;
            } else if (y > bottom - r) {
                const dy = y - (bottom - r);
                const dx = @sqrt(@max(0.0, r * r - dy * dy));
                left_x = pos.x + r - dx;
                right_x = right - r + dx;
            }
        }

        return .{ .left = left_x, .right = right_x };
    }

    fn roundedRectLeftEdgeAtY(pos: ByteVec2, size: ByteVec2, radius: f32, y: f32) ?f32 {
        const bottom = pos.y + size.y;
        if (y < pos.y or y > bottom) return null;

        const r = clampedRoundedRadius(size, radius);
        if (r <= 0.0) return pos.x;

        if (y < pos.y + r) {
            const dy = (pos.y + r) - y;
            const dx = @sqrt(@max(0.0, r * r - dy * dy));
            return pos.x + r - dx;
        }
        if (y > bottom - r) {
            const dy = y - (bottom - r);
            const dx = @sqrt(@max(0.0, r * r - dy * dy));
            return pos.x + r - dx;
        }
        return pos.x;
    }

    pub fn DrawRoundedLeftEdgeShadowedRectFilled(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, radius: f32, base_color: ByteVec4, shadow_color: ByteVec4, opacity: f32, caster_pos: ByteVec2, caster_size: ByteVec2, caster_radius: f32, shadow_width: f32, shadow_strength: f32) void {
        const active_draw = draw orelse return;
        const p_max = ByteVec2{ .x = pos.x + size.x, .y = pos.y + size.y };
        active_draw.AddRectFilled(pos, p_max, ColorToU32(ApplyOpacity(base_color, opacity)), radius);

        const strength = Clamp01(shadow_strength);
        if (shadow_width <= 0.0 or strength <= 0.0 or size.y <= 0.0) return;

        var clear_shadow = shadow_color;
        clear_shadow.w = 0.0;
        var full_shadow = shadow_color;
        full_shadow.w *= strength;

        const clear_col = ColorToU32(ApplyOpacity(clear_shadow, opacity));
        const full_col = ColorToU32(ApplyOpacity(full_shadow, opacity));

        const slice_count: i32 = @intFromFloat(@min(96.0, @max(18.0, @ceil(size.y * 1.5))));
        const slice_h = size.y / @as(f32, @floatFromInt(slice_count));
        const old_flags = active_draw.Flags;
        active_draw.Flags &= ~ByteDrawListFlags_AntiAliasedFill;
        defer active_draw.Flags = old_flags;

        var i: i32 = 0;
        while (i < slice_count) : (i += 1) {
            const y0 = pos.y + @as(f32, @floatFromInt(i)) * slice_h;
            const y1 = if (i + 1 == slice_count) p_max.y else y0 + slice_h;
            const ym = (y0 + y1) * 0.5;

            const target_range = roundedRectHorizontalRangeAtY(pos, size, radius, ym) orelse continue;
            const caster_edge = roundedRectLeftEdgeAtY(caster_pos, caster_size, caster_radius, ym) orelse continue;

            const shadow_left = @max(target_range.left, caster_edge - shadow_width);
            const shadow_right = @min(target_range.right, caster_edge);
            if (shadow_right <= shadow_left) continue;

            active_draw.AddRectFilledHorizontalGradient(
                .{ .x = shadow_left, .y = y0 },
                .{ .x = shadow_right, .y = y1 },
                clear_col,
                full_col,
                0.0,
            );
        }
    }

    pub fn DrawRightEdgeShadowedRectFilled(draw: ?*ByteDrawList, pos: ByteVec2, size: ByteVec2, radius: f32, base_color: ByteVec4, shadow_color: ByteVec4, opacity: f32, shadow_edge_x: f32, shadow_width: f32, shadow_strength: f32) void {
        const active_draw = draw orelse return;
        const p_max = ByteVec2{ .x = pos.x + size.x, .y = pos.y + size.y };
        active_draw.AddRectFilled(pos, p_max, ColorToU32(ApplyOpacity(base_color, opacity)), radius);

        const strength = Clamp01(shadow_strength);
        if (shadow_width <= 0.0 or strength <= 0.0) return;

        const shadow_left = @max(pos.x, shadow_edge_x - shadow_width);
        const shadow_right = @min(p_max.x, shadow_edge_x);
        if (shadow_right <= shadow_left) return;

        var clear_shadow = shadow_color;
        clear_shadow.w = 0.0;
        var full_shadow = shadow_color;
        full_shadow.w *= strength;

        active_draw.AddRectFilledHorizontalGradient(
            .{ .x = shadow_left, .y = pos.y },
            .{ .x = shadow_right, .y = p_max.y },
            ColorToU32(ApplyOpacity(clear_shadow, opacity)),
            ColorToU32(ApplyOpacity(full_shadow, opacity)),
            0.0,
        );
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
        color: ByteVec4,
        opacity: f32,
    ) bool {
        const active_draw = draw orelse return false;
        if (texture.texture == null or texture.display_size_px.x <= 0.0 or texture.display_size_px.y <= 0.0) return false;

        const max_w = size.x - fit_padding.x;
        const max_h = size.y - fit_padding.y;
        const fit_scale = @min(1.0, @min(max_w / texture.display_size_px.x, max_h / texture.display_size_px.y));
        const final_scale = fit_scale * (base_factor + (peak_factor - base_factor) * Clamp01(anim));
        const content_size = ByteVec2{
            .x = texture.display_size_px.x * final_scale,
            .y = texture.display_size_px.y * final_scale,
        };
        const texture_size = if (texture.image_size_px.x > 0.0 and texture.image_size_px.y > 0.0) texture.image_size_px else texture.display_size_px;
        const image_size = ByteVec2{
            .x = texture_size.x * final_scale,
            .y = texture_size.y * final_scale,
        };
        const content_pos = ByteVec2{
            .x = pos.x + (size.x - content_size.x) * 0.5,
            .y = pos.y + (size.y - content_size.y) * 0.5,
        };
        const image_pos = ByteVec2{
            .x = content_pos.x + texture.draw_offset_px.x * final_scale,
            .y = content_pos.y + texture.draw_offset_px.y * final_scale,
        };

        active_draw.AddImage(
            @ptrCast(texture.texture),
            image_pos,
            .{ .x = image_pos.x + image_size.x, .y = image_pos.y + image_size.y },
            texture.uv_min,
            texture.uv_max,
            ColorToU32(ApplyOpacity(color, opacity)),
        );
        return true;
    }

    pub fn RasterizeTextTexture(font: ?*ByteFont, logical_font_size: f32, text: []const u8, supersample: f32, pad_scale: f32, layout_scale: f32) ?RasterizedTexture {
        const active_font = font orelse return null;
        const raster = rasterizeTextImageFromFont(active_font, logical_font_size * ByteGUI_ImplWin32_GetDpiScale(), text, supersample, pad_scale, 0.0, layout_scale, 255) orelse return null;
        return .{
            .rgba = raster.rgba,
            .pixel_w = raster.pixel_w,
            .pixel_h = raster.pixel_h,
            .display_size_px = raster.content_size_px,
            .image_size_px = raster.display_size_px,
            .draw_offset_px = raster.draw_offset_px,
            .uv_min = raster.uv_min,
            .uv_max = raster.uv_max,
        };
    }

    pub fn BuildTextTexture(out_texture: *TextTexture, font: ?*ByteFont, logical_font_size: f32, text: []const u8, supersample: f32, pad_scale: f32, layout_scale: f32) bool {
        CleanupTextTexture(out_texture);
        var raster = RasterizeTextTexture(font, logical_font_size, text, supersample, pad_scale, layout_scale) orelse return false;
        defer CleanupRasterizedTexture(&raster);
        return uploadRasterizedMaskTextureWithFilter(out_texture, &raster, .linear);
    }

    pub const SvgTransform = struct {
        a: f32 = 1.0,
        b: f32 = 0.0,
        c: f32 = 0.0,
        d: f32 = 1.0,
        e: f32 = 0.0,
        f: f32 = 0.0,
    };

    pub const SvgPathLayer = struct {
        path: []const u8,
        transform: SvgTransform = .{},
    };

    pub const SvgDisplayMode = enum {
        canvas,
        tight_content,
    };

    pub const SvgTextureBuildParams = struct {
        paths: []const SvgPathLayer,
        canvas_pos: ByteVec2,
        canvas_size: ByteVec2,
        supersample: f32,
        sample_grid: u32 = 5,
        fill_argb: ByteU32 = 0xFF000000,
        display_mode: SvgDisplayMode = .canvas,
    };

    fn rasterizeSvgTextureImage(params: SvgTextureBuildParams) ?RasterizedTexture {
        if (params.paths.len == 0) return null;
        const ss = @max(1, @as(i32, @intFromFloat(@round(params.supersample))));
        const raster_scale = ByteGUI_ImplWin32_GetDpiScale() * params.supersample;
        const pad_px = alignUpInt(@max(2, @as(i32, @intFromFloat(@ceil(raster_scale * 2.0)))), ss);
        const pixel_w: u32 = @intCast(alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(params.canvas_size.x * raster_scale))) + pad_px * 2), ss));
        const pixel_h: u32 = @intCast(alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(params.canvas_size.y * raster_scale))) + pad_px * 2), ss));

        const rgba = allocator.alloc(u8, @as(usize, pixel_w) * @as(usize, pixel_h) * 4) catch return null;
        @memset(rgba, 0);

        for (params.paths) |layer| {
            var shape = VectorShape{};
            defer shape.deinit();
            if (!parseSvgPathToShape(layer.path, &shape, estimateSvgTransformScale(layer.transform, raster_scale))) {
                allocator.free(rgba);
                return null;
            }

            transformVectorShapeInPlace(&shape, .{
                .a = layer.transform.a * raster_scale,
                .b = layer.transform.b * raster_scale,
                .c = layer.transform.c * raster_scale,
                .d = layer.transform.d * raster_scale,
                .e = layer.transform.e * raster_scale + @as(f32, @floatFromInt(pad_px)) - params.canvas_pos.x * raster_scale,
                .f = layer.transform.f * raster_scale + @as(f32, @floatFromInt(pad_px)) - params.canvas_pos.y * raster_scale,
            });

            const layer_rgba = rasterizeVectorShapeToRgba(&shape, pixel_w, pixel_h, params.fill_argb, @max(params.sample_grid, 1)) orelse {
                allocator.free(rgba);
                return null;
            };
            defer allocator.free(layer_rgba);
            blendScaledRgbaIntoRgba(rgba, pixel_w, pixel_h, layer_rgba, pixel_w, pixel_h, .{}, .{ .x = 1.0, .y = 1.0 });
        }

        const canvas_min_x = @as(f32, @floatFromInt(pad_px));
        const canvas_min_y = @as(f32, @floatFromInt(pad_px));
        const canvas_max_x = canvas_min_x + params.canvas_size.x * raster_scale;
        const canvas_max_y = canvas_min_y + params.canvas_size.y * raster_scale;

        var result = RasterizedTexture{
            .rgba = rgba,
            .pixel_w = pixel_w,
            .pixel_h = pixel_h,
            .display_size_px = ScaleVec2(params.canvas_size.x, params.canvas_size.y),
            .uv_min = .{
                .x = std.math.clamp(canvas_min_x / @as(f32, @floatFromInt(pixel_w)), 0.0, 1.0),
                .y = std.math.clamp(canvas_min_y / @as(f32, @floatFromInt(pixel_h)), 0.0, 1.0),
            },
            .uv_max = .{
                .x = std.math.clamp(canvas_max_x / @as(f32, @floatFromInt(pixel_w)), 0.0, 1.0),
                .y = std.math.clamp(canvas_max_y / @as(f32, @floatFromInt(pixel_h)), 0.0, 1.0),
            },
        };

        if (params.display_mode == .tight_content) {
            if (computeRgbaAlphaBounds(rgba, pixel_w, pixel_h)) |bounds| {
                const min_x = std.math.clamp(@as(f32, @floatFromInt(bounds.min_x)), 0.0, @as(f32, @floatFromInt(pixel_w)));
                const min_y = std.math.clamp(@as(f32, @floatFromInt(bounds.min_y)), 0.0, @as(f32, @floatFromInt(pixel_h)));
                const max_x = std.math.clamp(@as(f32, @floatFromInt(bounds.max_x)), min_x, @as(f32, @floatFromInt(pixel_w)));
                const max_y = std.math.clamp(@as(f32, @floatFromInt(bounds.max_y)), min_y, @as(f32, @floatFromInt(pixel_h)));
                if (max_x > min_x and max_y > min_y) {
                    result.display_size_px = .{
                        .x = (max_x - min_x) / params.supersample,
                        .y = (max_y - min_y) / params.supersample,
                    };
                    result.uv_min = .{
                        .x = min_x / @as(f32, @floatFromInt(pixel_w)),
                        .y = min_y / @as(f32, @floatFromInt(pixel_h)),
                    };
                    result.uv_max = .{
                        .x = max_x / @as(f32, @floatFromInt(pixel_w)),
                        .y = max_y / @as(f32, @floatFromInt(pixel_h)),
                    };
                }
            }
        }
        return result;
    }

    pub fn RasterizeSvgTexture(params: SvgTextureBuildParams) ?RasterizedTexture {
        return rasterizeSvgTextureImage(params);
    }

    pub fn UploadRasterizedTexture(out_texture: *TextTexture, raster: *const RasterizedTexture) bool {
        CleanupTextTexture(out_texture);
        if (!ByteGUI_ImplOpenGL_HasContext() or raster.rgba.len == 0 or raster.pixel_w == 0 or raster.pixel_h == 0) return false;

        out_texture.texture = createTextureFromRGBA(raster.rgba, raster.pixel_w, raster.pixel_h, .linear) orelse return false;
        out_texture.display_size_px = raster.display_size_px;
        out_texture.image_size_px = if (raster.image_size_px.x > 0.0 and raster.image_size_px.y > 0.0) raster.image_size_px else raster.display_size_px;
        out_texture.draw_offset_px = raster.draw_offset_px;
        out_texture.uv_min = raster.uv_min;
        out_texture.uv_max = raster.uv_max;
        return true;
    }

    pub fn UploadRasterizedMaskTexture(out_texture: *TextTexture, raster: *const RasterizedTexture) bool {
        return uploadRasterizedMaskTextureWithFilter(out_texture, raster, .linear);
    }

    pub fn BuildAlphaMaskTexture(out_texture: *TextTexture, alpha: []const u8, pixel_w: u32, pixel_h: u32, display_size_px: ByteVec2) bool {
        CleanupTextTexture(out_texture);
        if (!ByteGUI_ImplOpenGL_HasContext() or pixel_w == 0 or pixel_h == 0 or alpha.len < @as(usize, pixel_w) * @as(usize, pixel_h)) return false;

        out_texture.texture = createTextureFromAlpha(alpha, pixel_w, pixel_h, .linear) orelse return false;
        out_texture.display_size_px = display_size_px;
        out_texture.image_size_px = display_size_px;
        out_texture.draw_offset_px = .{};
        out_texture.uv_min = .{};
        out_texture.uv_max = .{ .x = 1.0, .y = 1.0 };
        return true;
    }

    pub fn BuildSvgTexture(out_texture: *TextTexture, params: SvgTextureBuildParams) bool {
        var raster = RasterizeSvgTexture(params) orelse return false;
        defer CleanupRasterizedTexture(&raster);
        return UploadRasterizedMaskTexture(out_texture, &raster);
    }

    pub const ParsedSvgMeshVertex = struct {
        pos: ByteVec2 = .{},
        coverage: u8 = 0xFF,
    };

    pub const ParsedSvgLayer = struct {
        fill_vertices: []ParsedSvgMeshVertex = &.{},
        fill_indices: []u32 = &.{},
        fringe_vertices: []ParsedSvgMeshVertex = &.{},
        fringe_indices: []u32 = &.{},
        bounds_min: ByteVec2 = .{},
        bounds_max: ByteVec2 = .{},

        pub fn deinit(self: *ParsedSvgLayer) void {
            if (self.fill_vertices.len > 0) allocator.free(self.fill_vertices);
            if (self.fill_indices.len > 0) allocator.free(self.fill_indices);
            if (self.fringe_vertices.len > 0) allocator.free(self.fringe_vertices);
            if (self.fringe_indices.len > 0) allocator.free(self.fringe_indices);
            self.* = .{};
        }
    };

    pub fn BuildParsedSvgLayer(layer: SvgPathLayer, dpi_scale: f32) ?ParsedSvgLayer {
        var shape = VectorShape{};
        defer shape.deinit();
        if (!parseSvgPathToShape(layer.path, &shape, estimateSvgTransformScale(layer.transform, dpi_scale))) return null;
        transformVectorShapeInPlace(&shape, layer.transform);
        return buildParsedSvgLayerMeshes(&shape, dpi_scale);
    }

    pub fn DrawParsedSvgLayers(draw: ?*ByteDrawList, layers: []const ParsedSvgLayer, col: ByteU32, dpi_scale: f32) void {
        const dl = draw orelse return;
        if ((col & BYTEGUI_COL32_A_MASK) == 0 or layers.len == 0) return;

        var min_x = std.math.floatMax(f32);
        var min_y = std.math.floatMax(f32);
        var max_x = -std.math.floatMax(f32);
        var max_y = -std.math.floatMax(f32);
        for (layers) |layer| {
            min_x = @min(min_x, layer.bounds_min.x * dpi_scale);
            min_y = @min(min_y, layer.bounds_min.y * dpi_scale);
            max_x = @max(max_x, layer.bounds_max.x * dpi_scale);
            max_y = @max(max_y, layer.bounds_max.y * dpi_scale);
        }
        if (min_x >= max_x or min_y >= max_y) return;

        const layers_copy = allocator.dupe(ParsedSvgLayer, layers) catch return;
        const data = allocator.create(SvgCoverageCallbackData) catch {
            allocator.free(layers_copy);
            return;
        };
        data.* = .{
            .layers_ptr = layers_copy.ptr,
            .layers_len = layers_copy.len,
            .col = col,
            .dpi_scale = dpi_scale,
            .bounds_min = .{ .x = min_x, .y = min_y },
            .bounds_max = .{ .x = max_x, .y = max_y },
        };
        dl.CmdBuffer.append(allocator, .{
            .ElemCount = 0,
            .IdxOffset = @intCast(dl.IdxBuffer.items.len),
            .ClipRect = dl.CurrentClipRect,
            .UserCallback = svgCoverageCompositeCallback,
            .UserCallbackData = data,
        }) catch {
            allocator.free(layers_copy);
            allocator.destroy(data);
        };
    }

    pub const SvgCoverageCallbackData = struct {
        layers_ptr: [*]const ParsedSvgLayer,
        layers_len: usize,
        col: ByteU32,
        dpi_scale: f32,
        bounds_min: ByteVec2,
        bounds_max: ByteVec2,
    };
};

// SVG mesh compositor
fn drawSolidQuad(min: ByteVec2, max: ByteVec2) void {
    gl.glBegin(gl.QUADS);
    gl.glVertex2f(min.x, min.y);
    gl.glVertex2f(max.x, min.y);
    gl.glVertex2f(max.x, max.y);
    gl.glVertex2f(min.x, max.y);
    gl.glEnd();
}

fn restoreDefaultGUIBlendFunc() void {
    if (g_glBlendFuncSeparate) |blendSeparate| {
        blendSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
    } else {
        gl.glBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    }
}

fn svgCoverageCompositeCallback(_: *const ByteDrawList, cmd: *const ByteDrawCmd) callconv(.c) void {
    const data: *Ui.SvgCoverageCallbackData = @ptrCast(@alignCast(cmd.UserCallbackData orelse return));
    defer {
        allocator.free(data.layers_ptr[0..data.layers_len]);
        allocator.destroy(data);
    }

    const layers = data.layers_ptr[0..data.layers_len];
    const col = data.col;
    const ds = data.dpi_scale;
    const r: u8 = @truncate(col & 0xFF);
    const g: u8 = @truncate((col >> 8) & 0xFF);
    const b: u8 = @truncate((col >> 16) & 0xFF);

    gl.glDisable(gl.SCISSOR_TEST);
    gl.glDisable(gl.TEXTURE_2D);
    gl.glShadeModel(gl.SMOOTH);

    gl.glColorMask(gl.FALSE, gl.FALSE, gl.FALSE, gl.TRUE);
    gl.glDisable(gl.BLEND);
    gl.glColor4ub(0, 0, 0, 0);
    drawSolidQuad(data.bounds_min, data.bounds_max);

    const sample_offsets = [_]ByteVec2{
        .{ .x = -0.375, .y = -0.375 },
        .{ .x = -0.125, .y = -0.375 },
        .{ .x = 0.125, .y = -0.375 },
        .{ .x = 0.375, .y = -0.375 },
        .{ .x = -0.375, .y = -0.125 },
        .{ .x = -0.125, .y = -0.125 },
        .{ .x = 0.125, .y = -0.125 },
        .{ .x = 0.375, .y = -0.125 },
        .{ .x = -0.375, .y = 0.125 },
        .{ .x = -0.125, .y = 0.125 },
        .{ .x = 0.125, .y = 0.125 },
        .{ .x = 0.375, .y = 0.125 },
        .{ .x = -0.375, .y = 0.375 },
        .{ .x = -0.125, .y = 0.375 },
        .{ .x = 0.125, .y = 0.375 },
        .{ .x = 0.375, .y = 0.375 },
    };
    const sample_count: u32 = sample_offsets.len;
    const sample_alpha_base: u32 = 255 / sample_count;
    const sample_alpha_remainder: u32 = 255 % sample_count;

    gl.glEnable(gl.BLEND);
    gl.glBlendFunc(gl.ONE, gl.ONE);

    for (sample_offsets, 0..) |sample, sample_index| {
        const sample_alpha_bonus: u32 = if (sample_index < sample_alpha_remainder) 1 else 0;
        const sample_alpha: u8 = @intCast(sample_alpha_base + sample_alpha_bonus);
        gl.glColor4ub(0, 0, 0, sample_alpha);
        for (layers) |layer| {
            if (layer.fill_vertices.len == 0 or layer.fill_indices.len == 0) continue;
            gl.glBegin(gl.TRIANGLES);
            for (layer.fill_indices) |idx| {
                const vertex = layer.fill_vertices[idx];
                gl.glVertex2f(vertex.pos.x * ds + sample.x, vertex.pos.y * ds + sample.y);
            }
            gl.glEnd();
        }
    }

    gl.glColorMask(gl.TRUE, gl.TRUE, gl.TRUE, gl.FALSE);
    gl.glBlendFunc(gl.DST_ALPHA, gl.ONE_MINUS_DST_ALPHA);
    gl.glColor4ub(r, g, b, 0xFF);
    drawSolidQuad(data.bounds_min, data.bounds_max);

    gl.glColorMask(gl.FALSE, gl.FALSE, gl.FALSE, gl.TRUE);
    gl.glDisable(gl.BLEND);
    gl.glColor4ub(0, 0, 0, 0xFF);
    drawSolidQuad(data.bounds_min, data.bounds_max);

    gl.glColorMask(gl.TRUE, gl.TRUE, gl.TRUE, gl.TRUE);
    gl.glEnable(gl.BLEND);
    restoreDefaultGUIBlendFunc();
    gl.glEnable(gl.TEXTURE_2D);
    gl.glColor4ub(0xFF, 0xFF, 0xFF, 0xFF);
}

// SVG tessellation
const SvgContourInfo = struct {
    points: []const ByteVec2 = &.{},
    clockwise: bool = false,
    fill_inside: bool = true,
    fill_points: []ByteVec2 = &.{},
    outer_points: []ByteVec2 = &.{},

    fn deinit(self: *SvgContourInfo) void {
        if (self.fill_points.len > 0) allocator.free(self.fill_points);
        if (self.outer_points.len > 0) allocator.free(self.outer_points);
        self.* = .{};
    }
};

const SvgTessVertex = struct {
    coords: [3]gl.GLdouble = .{ 0.0, 0.0, 0.0 },
    index: u32 = 0,
};

const SvgMeshBuilder = struct {
    vertices: std.ArrayListUnmanaged(Ui.ParsedSvgMeshVertex) = .empty,
    indices: std.ArrayListUnmanaged(u32) = .empty,
    owned_tess_vertices: std.ArrayListUnmanaged(*SvgTessVertex) = .empty,
    primitive_mode: gl.GLenum = 0,
    primitive_count: usize = 0,
    primitive_first: u32 = 0,
    primitive_prev: u32 = 0,
    triangle_cache: [2]u32 = .{ 0, 0 },
    failed: bool = false,

    fn deinit(self: *SvgMeshBuilder) void {
        for (self.owned_tess_vertices.items) |vertex| allocator.destroy(vertex);
        self.owned_tess_vertices.deinit(allocator);
        self.vertices.deinit(allocator);
        self.indices.deinit(allocator);
        self.* = .{};
    }

    fn appendMeshVertex(self: *SvgMeshBuilder, pos: ByteVec2, coverage: u8) ?u32 {
        const index: u32 = @intCast(self.vertices.items.len);
        self.vertices.append(allocator, .{ .pos = pos, .coverage = coverage }) catch {
            self.failed = true;
            return null;
        };
        return index;
    }

    fn appendTriangle(self: *SvgMeshBuilder, a: u32, b: u32, cidx: u32) void {
        if (a == b or b == cidx or cidx == a) return;
        self.indices.append(allocator, a) catch {
            self.failed = true;
            return;
        };
        self.indices.append(allocator, b) catch {
            self.failed = true;
            return;
        };
        self.indices.append(allocator, cidx) catch {
            self.failed = true;
            return;
        };
    }

    fn allocTessVertex(self: *SvgMeshBuilder, pos: ByteVec2) ?*SvgTessVertex {
        const index = self.appendMeshVertex(pos, 0xFF) orelse return null;
        const tess_vertex = allocator.create(SvgTessVertex) catch {
            self.vertices.items.len -= 1;
            self.failed = true;
            return null;
        };
        tess_vertex.* = .{
            .coords = .{ pos.x, pos.y, 0.0 },
            .index = index,
        };
        self.owned_tess_vertices.append(allocator, tess_vertex) catch {
            allocator.destroy(tess_vertex);
            self.vertices.items.len -= 1;
            self.failed = true;
            return null;
        };
        return tess_vertex;
    }

    fn beginPrimitive(self: *SvgMeshBuilder, mode: gl.GLenum) void {
        self.primitive_mode = mode;
        self.primitive_count = 0;
    }

    fn pushPrimitiveVertex(self: *SvgMeshBuilder, idx: u32) void {
        switch (self.primitive_mode) {
            gl.TRIANGLES => switch (self.primitive_count % 3) {
                0 => self.triangle_cache[0] = idx,
                1 => self.triangle_cache[1] = idx,
                else => self.appendTriangle(self.triangle_cache[0], self.triangle_cache[1], idx),
            },
            gl.TRIANGLE_FAN => switch (self.primitive_count) {
                0 => self.primitive_first = idx,
                1 => self.primitive_prev = idx,
                else => {
                    self.appendTriangle(self.primitive_first, self.primitive_prev, idx);
                    self.primitive_prev = idx;
                },
            },
            gl.TRIANGLE_STRIP => switch (self.primitive_count) {
                0 => self.primitive_first = idx,
                1 => self.primitive_prev = idx,
                else => {
                    if ((self.primitive_count & 1) == 0) {
                        self.appendTriangle(self.primitive_first, self.primitive_prev, idx);
                    } else {
                        self.appendTriangle(self.primitive_prev, self.primitive_first, idx);
                    }
                    self.primitive_first = self.primitive_prev;
                    self.primitive_prev = idx;
                },
            },
            else => self.failed = true,
        }
        self.primitive_count += 1;
    }
};

fn buildParsedSvgLayerMeshes(shape: *const VectorShape, dpi_scale: f32) ?Ui.ParsedSvgLayer {
    var valid_count: usize = 0;
    for (shape.contours.items) |contour| {
        if (contour.points.items.len >= 3) valid_count += 1;
    }
    if (valid_count == 0) return Ui.ParsedSvgLayer{};

    const coverage_pad = 1.0 / @max(dpi_scale, 1.0);
    var contours = allocator.alloc(SvgContourInfo, valid_count) catch return null;
    defer {
        for (contours) |*contour| contour.deinit();
        allocator.free(contours);
    }

    var built: usize = 0;
    for (shape.contours.items) |contour| {
        if (contour.points.items.len < 3) continue;
        contours[built] = .{
            .points = contour.points.items,
            .clockwise = contourSignedArea(contour.points.items) > 0.0,
        };
        built += 1;
    }

    var fill_builder = SvgMeshBuilder{};
    defer fill_builder.deinit();
    if (!tessellateSvgContours(contours, &fill_builder, false)) return null;
    if (fill_builder.failed) return null;

    const fill_vertices = allocator.dupe(Ui.ParsedSvgMeshVertex, fill_builder.vertices.items) catch return null;
    errdefer allocator.free(fill_vertices);
    const fill_indices = allocator.dupe(u32, fill_builder.indices.items) catch return null;
    errdefer allocator.free(fill_indices);

    var bounds_min = ByteVec2{ .x = std.math.floatMax(f32), .y = std.math.floatMax(f32) };
    var bounds_max = ByteVec2{ .x = -std.math.floatMax(f32), .y = -std.math.floatMax(f32) };
    for (contours) |contour| {
        for (contour.points) |point| {
            bounds_min.x = @min(bounds_min.x, point.x);
            bounds_min.y = @min(bounds_min.y, point.y);
            bounds_max.x = @max(bounds_max.x, point.x);
            bounds_max.y = @max(bounds_max.y, point.y);
        }
    }
    bounds_min.x -= coverage_pad;
    bounds_min.y -= coverage_pad;
    bounds_max.x += coverage_pad;
    bounds_max.y += coverage_pad;

    return .{
        .fill_vertices = fill_vertices,
        .fill_indices = fill_indices,
        .bounds_min = bounds_min,
        .bounds_max = bounds_max,
    };
}

fn tessellateSvgContours(contours: []const SvgContourInfo, builder: *SvgMeshBuilder, use_fill_points: bool) bool {
    const tess = glu.gluNewTess() orelse return false;
    defer glu.gluDeleteTess(tess);

    glu.gluTessProperty(tess, glu.TESS_WINDING_RULE, glu.TESS_WINDING_ODD);
    glu.gluTessCallback(tess, glu.TESS_BEGIN_DATA, @ptrCast(&svgTessBeginData));
    glu.gluTessCallback(tess, glu.TESS_VERTEX_DATA, @ptrCast(&svgTessVertexData));
    glu.gluTessCallback(tess, glu.TESS_END_DATA, @ptrCast(&svgTessEndData));
    glu.gluTessCallback(tess, glu.TESS_COMBINE_DATA, @ptrCast(&svgTessCombineData));
    glu.gluTessCallback(tess, glu.TESS_ERROR_DATA, @ptrCast(&svgTessErrorData));

    glu.gluTessBeginPolygon(tess, @ptrCast(builder));

    for (contours) |contour| {
        const points = if (use_fill_points) contour.fill_points else contour.points;
        if (points.len < 3) continue;
        glu.gluTessBeginContour(tess);
        for (points) |point| {
            const tess_vertex = builder.allocTessVertex(point) orelse {
                builder.failed = true;
                break;
            };
            glu.gluTessVertex(tess, &tess_vertex.coords, @ptrCast(tess_vertex));
        }
        glu.gluTessEndContour(tess);
        if (builder.failed) break;
    }
    glu.gluTessEndPolygon(tess);
    return !builder.failed;
}

fn svgTessBeginData(mode: gl.GLenum, polygon_data: ?*anyopaque) callconv(.winapi) void {
    const builder: *SvgMeshBuilder = @ptrCast(@alignCast(polygon_data orelse return));
    builder.beginPrimitive(mode);
}

fn svgTessVertexData(vertex_data: ?*anyopaque, polygon_data: ?*anyopaque) callconv(.winapi) void {
    const builder: *SvgMeshBuilder = @ptrCast(@alignCast(polygon_data orelse return));
    const tess_vertex: *SvgTessVertex = @ptrCast(@alignCast(vertex_data orelse return));
    builder.pushPrimitiveVertex(tess_vertex.index);
}

fn svgTessEndData(_: ?*anyopaque) callconv(.winapi) void {}

fn svgTessCombineData(
    coords: [*]const gl.GLdouble,
    _: [*]?*anyopaque,
    _: [*]const gl.GLfloat,
    out_data: *?*anyopaque,
    polygon_data: ?*anyopaque,
) callconv(.winapi) void {
    const builder: *SvgMeshBuilder = @ptrCast(@alignCast(polygon_data orelse {
        out_data.* = null;
        return;
    }));
    const tess_vertex = builder.allocTessVertex(.{
        .x = @floatCast(coords[0]),
        .y = @floatCast(coords[1]),
    }) orelse {
        out_data.* = null;
        return;
    };
    out_data.* = tess_vertex;
}

fn svgTessErrorData(_: gl.GLenum, polygon_data: ?*anyopaque) callconv(.winapi) void {
    const builder: *SvgMeshBuilder = @ptrCast(@alignCast(polygon_data orelse return));
    builder.failed = true;
}

const SvgContourOffsetSide = enum {
    toward_fill,
    away_from_fill,
};

fn buildSvgContourOffset(points: []const ByteVec2, clockwise: bool, fill_inside: bool, aa_radius: f32, side: SvgContourOffsetSide) ?[]ByteVec2 {
    if (points.len < 3) return allocator.dupe(ByteVec2, points) catch null;

    var edge_normals = allocator.alloc(ByteVec2, points.len) catch return null;
    defer allocator.free(edge_normals);

    var prev_idx = points.len - 1;
    for (points, 0..) |point, i| {
        var delta = subVec2(point, points[prev_idx]);
        const len = @sqrt(byteLengthSqr(delta));
        if (len > 0.0) {
            delta.x /= len;
            delta.y /= len;
        }
        var away = ByteVec2{ .x = delta.y, .y = -delta.x };
        if (!clockwise) {
            away.x = -away.x;
            away.y = -away.y;
        }
        if (!fill_inside) {
            away.x = -away.x;
            away.y = -away.y;
        }
        if (side == .toward_fill) {
            away.x = -away.x;
            away.y = -away.y;
        }
        edge_normals[prev_idx] = away;
        prev_idx = i;
    }

    const offset_points = allocator.alloc(ByteVec2, points.len) catch return null;
    for (points, 0..) |point, i| {
        const n0 = edge_normals[(i + points.len - 1) % points.len];
        const n1 = edge_normals[i];
        const avg = computeAAMiterOffsetLimited(n0, n1, aa_radius, 2.0);
        offset_points[i] = .{
            .x = point.x + avg.x,
            .y = point.y + avg.y,
        };
    }
    return offset_points;
}

fn appendSvgContourFringe(builder: *SvgMeshBuilder, points: []const ByteVec2, outer_points: []const ByteVec2) bool {
    if (points.len < 3 or points.len != outer_points.len) return true;

    const base_idx: u32 = @intCast(builder.vertices.items.len);
    for (points, outer_points) |point, outer_point| {
        _ = builder.appendMeshVertex(point, 0xFF) orelse return false;
        _ = builder.appendMeshVertex(outer_point, 0x00) orelse return false;
    }

    for (0..points.len) |i| {
        const next = (i + 1) % points.len;
        const inner0 = base_idx + @as(u32, @intCast(i * 2));
        const outer0 = inner0 + 1;
        const inner1 = base_idx + @as(u32, @intCast(next * 2));
        const outer1 = inner1 + 1;
        builder.appendTriangle(inner1, inner0, outer0);
        builder.appendTriangle(outer0, outer1, inner1);
    }
    return !builder.failed;
}

fn applyCoverageToColor(col: ByteU32, coverage: u8) ByteU32 {
    const base_alpha: u32 = (col >> 24) & 0xFF;
    const scaled_alpha: u32 = @intCast((base_alpha * @as(u32, coverage) + 127) / 255);
    return (col & 0x00FF_FFFF) | (scaled_alpha << 24);
}

fn contourSignedArea(contour: []const ByteVec2) f64 {
    var area: f64 = 0.0;
    for (0..contour.len) |i| {
        const j = (i + 1) % contour.len;
        area += @as(f64, contour[i].x) * @as(f64, contour[j].y);
        area -= @as(f64, contour[j].x) * @as(f64, contour[i].y);
    }
    return area * 0.5;
}

fn contourInteriorSample(contour: []const ByteVec2, clockwise: bool, inset: f32) ByteVec2 {
    if (contour.len == 0) return .{};

    const sample_inset = @max(inset * 2.0, 0.01);
    for (0..contour.len) |i| {
        const next = (i + 1) % contour.len;
        var edge = subVec2(contour[next], contour[i]);
        const len = @sqrt(byteLengthSqr(edge));
        if (len <= 0.0) continue;

        edge.x /= len;
        edge.y /= len;
        var inside = ByteVec2{ .x = -edge.y, .y = edge.x };
        if (!clockwise) {
            inside.x = -inside.x;
            inside.y = -inside.y;
        }

        return .{
            .x = (contour[i].x + contour[next].x) * 0.5 + inside.x * sample_inset,
            .y = (contour[i].y + contour[next].y) * 0.5 + inside.y * sample_inset,
        };
    }
    return contour[0];
}

fn estimateSvgTransformScale(transform: Ui.SvgTransform, extra_scale: f32) f32 {
    const basis_x = @sqrt(transform.a * transform.a + transform.b * transform.b);
    const basis_y = @sqrt(transform.c * transform.c + transform.d * transform.d);
    return @max(1.0, @max(basis_x, basis_y) * @max(extra_scale, 1.0));
}

fn computeAAMiterOffset(n0: ByteVec2, n1: ByteVec2, aa_radius: f32) ByteVec2 {
    return computeAAMiterOffsetLimited(n0, n1, aa_radius, 100.0);
}

fn computeAAMiterOffsetLimited(n0: ByteVec2, n1: ByteVec2, aa_radius: f32, miter_limit: f32) ByteVec2 {
    var dm = ByteVec2{ .x = (n0.x + n1.x) * 0.5, .y = (n0.y + n1.y) * 0.5 };
    const len2 = byteLengthSqr(dm);
    if (len2 > 0.000001) {
        var inv_len2 = 1.0 / len2;
        if (inv_len2 > miter_limit) inv_len2 = miter_limit;
        dm.x *= inv_len2;
        dm.y *= inv_len2;
    }
    dm.x *= aa_radius;
    dm.y *= aa_radius;
    return dm;
}

fn clamp01(v: f32) f32 {
    return if (v < 0.0) 0.0 else if (v > 1.0) 1.0 else v;
}

fn lerpPackedColorChannel(a: ByteU32, b: ByteU32, shift: u5, t: f32) ByteU32 {
    const av: f32 = @floatFromInt((a >> shift) & 0xFF);
    const bv: f32 = @floatFromInt((b >> shift) & 0xFF);
    return @intFromFloat(av + (bv - av) * t + 0.5);
}

fn lerpPackedColor(a: ByteU32, b: ByteU32, t_in: f32) ByteU32 {
    const t = clamp01(t_in);
    const r = lerpPackedColorChannel(a, b, 0, t);
    const g = lerpPackedColorChannel(a, b, 8, t);
    const bl = lerpPackedColorChannel(a, b, 16, t);
    const al = lerpPackedColorChannel(a, b, 24, t);
    return r | (g << 8) | (bl << 16) | (al << 24);
}

fn biasedHorizontalGradientT(u_in: f32, gradient_center_in: f32) f32 {
    const u = clamp01(u_in);
    const gradient_center = @min(@max(gradient_center_in, 0.001), 0.999);
    if (u <= gradient_center) return 0.5 * (u / gradient_center);
    return 0.5 + 0.5 * ((u - gradient_center) / (1.0 - gradient_center));
}

fn horizontalGradientColor(x: f32, gradient_left: f32, gradient_right: f32, gradient_center: f32, col_left: ByteU32, col_right: ByteU32) ByteU32 {
    const width = gradient_right - gradient_left;
    if (@abs(width) <= 0.0001) return col_left;
    return lerpPackedColor(col_left, col_right, biasedHorizontalGradientT((x - gradient_left) / width, gradient_center));
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

// Polygon fill helpers
fn pointInTriangle2D(a: ByteVec2, b: ByteVec2, cc: ByteVec2, p: ByteVec2) bool {
    const d1 = (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y);
    const d2 = (p.x - cc.x) * (b.y - cc.y) - (b.x - cc.x) * (p.y - cc.y);
    const d3 = (p.x - a.x) * (cc.y - a.y) - (cc.x - a.x) * (p.y - a.y);
    const has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0);
    const has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0);
    return !(has_neg and has_pos);
}

fn earClipFill(draw: *ByteDrawList, pts: []const ByteVec2, col: ByteU32) void {
    const n = pts.len;
    if (n < 3 or (col & BYTEGUI_COL32_A_MASK) == 0) return;
    if (n == 3) {
        draw.AddConvexPolyFilled(pts, col);
        return;
    }

    var area: f64 = 0;
    for (0..n) |i| {
        const j = (i + 1) % n;
        area += @as(f64, pts[i].x) * @as(f64, pts[j].y);
        area -= @as(f64, pts[j].x) * @as(f64, pts[i].y);
    }
    const clockwise = area > 0;

    const has_aa = (draw.Flags & ByteDrawListFlags_AntiAliasedFill) != 0;
    const transparent = col & ~BYTEGUI_COL32_A_MASK;
    const uv = ByteVec2{ .x = 0.5, .y = 0.5 };

    var stk_idx: [512]u32 = undefined;
    const heap_idx: ?[]u32 = if (n > stk_idx.len) (allocator.alloc(u32, n) catch return) else null;
    defer if (heap_idx) |h| allocator.free(h);
    const rem_idx: []u32 = if (heap_idx) |h| h else stk_idx[0..n];
    for (0..n) |i| rem_idx[i] = @intCast(i);
    var rem: usize = n;

    if (has_aa) {
        var stk_nrm: [512]ByteVec2 = undefined;
        const heap_nrm: ?[]ByteVec2 = if (n > stk_nrm.len) (allocator.alloc(ByteVec2, n) catch return) else null;
        defer if (heap_nrm) |h| allocator.free(h);
        const edge_nrm: []ByteVec2 = if (heap_nrm) |h| h else stk_nrm[0..n];

        var stk_avg: [512]ByteVec2 = undefined;
        const heap_avg: ?[]ByteVec2 = if (n > stk_avg.len) (allocator.alloc(ByteVec2, n) catch return) else null;
        defer if (heap_avg) |h| allocator.free(h);
        const avg_nrm: []ByteVec2 = if (heap_avg) |h| h else stk_avg[0..n];

        {
            var prev_i = n - 1;
            for (0..n) |i| {
                var d = subVec2(pts[i], pts[prev_i]);
                const l = @sqrt(byteLengthSqr(d));
                if (l > 0) {
                    d.x /= l;
                    d.y /= l;
                }
                edge_nrm[prev_i] = .{ .x = d.y, .y = -d.x };
                prev_i = i;
            }
        }
        for (0..n) |i| {
            const n0 = edge_nrm[if (i == 0) n - 1 else i - 1];
            const n1 = edge_nrm[i];
            avg_nrm[i] = computeAAMiterOffset(n0, n1, 0.5);
        }

        const base: ByteDrawIdx = @intCast(draw.VtxBuffer.items.len);
        for (pts, 0..) |pt, i| {
            const a = avg_nrm[i];
            draw.addVertex(.{ .x = pt.x - a.x, .y = pt.y - a.y }, uv, col) catch return;
            draw.addVertex(.{ .x = pt.x + a.x, .y = pt.y + a.y }, uv, transparent) catch return;
        }

        const fringe_start = draw.IdxBuffer.items.len;
        for (0..n) |fi| {
            const fr0: ByteDrawIdx = base + @as(ByteDrawIdx, @intCast(fi * 2));
            const fr1: ByteDrawIdx = base + @as(ByteDrawIdx, @intCast(((fi + 1) % n) * 2));
            draw.addTriangleIndices(fr1, fr0, fr0 + 1) catch return;
            draw.addTriangleIndices(fr0 + 1, fr1 + 1, fr1) catch return;
        }
        draw.addPrimitive(draw.WhiteTexture, @intCast(draw.IdxBuffer.items.len - fringe_start)) catch return;

        const fill_start = draw.IdxBuffer.items.len;
        var fail: usize = 0;
        var ci: usize = 0;
        while (rem > 3 and fail < rem) {
            const pi = rem_idx[(ci + rem - 1) % rem];
            const ci_ = rem_idx[ci];
            const ni = rem_idx[(ci + 1) % rem];
            const cross = (pts[ci_].x - pts[pi].x) * (pts[ni].y - pts[pi].y) -
                (pts[ci_].y - pts[pi].y) * (pts[ni].x - pts[pi].x);
            const is_convex = if (clockwise) cross >= 0 else cross <= 0;
            if (is_convex) {
                var blocked = false;
                for (rem_idx[0..rem]) |v| {
                    if (v == pi or v == ci_ or v == ni) continue;
                    if (pointInTriangle2D(pts[pi], pts[ci_], pts[ni], pts[v])) {
                        blocked = true;
                        break;
                    }
                }
                if (!blocked) {
                    draw.addTriangleIndices(
                        base + @as(ByteDrawIdx, pi) * 2,
                        base + @as(ByteDrawIdx, ci_) * 2,
                        base + @as(ByteDrawIdx, ni) * 2,
                    ) catch return;
                    var k: usize = ci;
                    while (k < rem - 1) : (k += 1) rem_idx[k] = rem_idx[k + 1];
                    rem -= 1;
                    if (rem > 0 and ci >= rem) ci = 0;
                    fail = 0;
                    continue;
                }
            }
            fail += 1;
            ci = (ci + 1) % rem;
        }
        if (rem >= 3) {
            draw.addTriangleIndices(
                base + @as(ByteDrawIdx, rem_idx[0]) * 2,
                base + @as(ByteDrawIdx, rem_idx[1]) * 2,
                base + @as(ByteDrawIdx, rem_idx[2]) * 2,
            ) catch return;
        }
        const fill_count = draw.IdxBuffer.items.len - fill_start;
        if (fill_count > 0) draw.addPrimitive(draw.WhiteTexture, @intCast(fill_count)) catch return;
    } else {
        const base: ByteDrawIdx = @intCast(draw.VtxBuffer.items.len);
        for (pts) |pt| draw.addVertex(pt, uv, col) catch return;
        const fill_start = draw.IdxBuffer.items.len;
        var fail: usize = 0;
        var ci: usize = 0;
        while (rem > 3 and fail < rem) {
            const pi = rem_idx[(ci + rem - 1) % rem];
            const ci_ = rem_idx[ci];
            const ni = rem_idx[(ci + 1) % rem];
            const cross = (pts[ci_].x - pts[pi].x) * (pts[ni].y - pts[pi].y) -
                (pts[ci_].y - pts[pi].y) * (pts[ni].x - pts[pi].x);
            const is_convex = if (clockwise) cross >= 0 else cross <= 0;
            if (is_convex) {
                var blocked = false;
                for (rem_idx[0..rem]) |v| {
                    if (v == pi or v == ci_ or v == ni) continue;
                    if (pointInTriangle2D(pts[pi], pts[ci_], pts[ni], pts[v])) {
                        blocked = true;
                        break;
                    }
                }
                if (!blocked) {
                    draw.addTriangleIndices(
                        base + @as(ByteDrawIdx, pi),
                        base + @as(ByteDrawIdx, ci_),
                        base + @as(ByteDrawIdx, ni),
                    ) catch return;
                    var k: usize = ci;
                    while (k < rem - 1) : (k += 1) rem_idx[k] = rem_idx[k + 1];
                    rem -= 1;
                    if (rem > 0 and ci >= rem) ci = 0;
                    fail = 0;
                    continue;
                }
            }
            fail += 1;
            ci = (ci + 1) % rem;
        }
        if (rem >= 3) {
            draw.addTriangleIndices(
                base + @as(ByteDrawIdx, rem_idx[0]),
                base + @as(ByteDrawIdx, rem_idx[1]),
                base + @as(ByteDrawIdx, rem_idx[2]),
            ) catch return;
        }
        const fill_count = draw.IdxBuffer.items.len - fill_start;
        if (fill_count > 0) draw.addPrimitive(draw.WhiteTexture, @intCast(fill_count)) catch return;
    }
}

fn sliceFromOptionalEnd(text_begin: []const u8, text_end: ?usize) []const u8 {
    if (text_end) |idx| return text_begin[0..@min(idx, text_begin.len)];
    return text_begin;
}

fn approxEqual(a: f32, b: f32, eps: f32) bool {
    return @abs(a - b) < eps;
}

// SVG path parsing
const VectorContour = struct {
    points: ByteVec2List = .empty,

    fn deinit(self: *VectorContour) void {
        self.points.deinit(allocator);
        self.* = .{};
    }
};

const VectorShape = struct {
    contours: std.ArrayListUnmanaged(VectorContour) = .empty,
    current_contour: ?usize = null,

    fn deinit(self: *VectorShape) void {
        for (self.contours.items) |*contour| contour.deinit();
        self.contours.deinit(allocator);
        self.* = .{};
    }

    fn startContour(self: *VectorShape, point: ByteVec2) bool {
        self.current_contour = null;
        self.contours.append(allocator, .{}) catch return false;
        self.current_contour = self.contours.items.len - 1;
        self.lineTo(point);
        return true;
    }

    fn lineTo(self: *VectorShape, point: ByteVec2) void {
        if (self.current_contour == null) {
            _ = self.startContour(point);
            return;
        }
        addUniquePoint(&self.contours.items[self.current_contour.?].points, point);
    }

    fn closeContour(self: *VectorShape) void {
        self.current_contour = null;
    }
};

const SvgPathParser = struct {
    input: []const u8,
    index: usize = 0,
    current_x: f32 = 0.0,
    current_y: f32 = 0.0,
    start_x: f32 = 0.0,
    start_y: f32 = 0.0,
    last_control_x: f32 = 0.0,
    last_control_y: f32 = 0.0,
    last_cmd: u8 = 0,

    fn eof(self: *const SvgPathParser) bool {
        return self.index >= self.input.len;
    }

    fn peek(self: *const SvgPathParser) u8 {
        return if (self.index < self.input.len) self.input[self.index] else 0;
    }

    fn skipWhitespace(self: *SvgPathParser) void {
        while (self.index < self.input.len) : (self.index += 1) {
            const ch = self.input[self.index];
            if (ch != ' ' and ch != ',' and ch != '\t' and ch != '\n' and ch != '\r') break;
        }
    }

    fn hasMoreNumbers(self: *SvgPathParser) bool {
        self.skipWhitespace();
        if (self.eof()) return false;
        const ch = self.peek();
        return ch == '-' or ch == '+' or ch == '.' or (ch >= '0' and ch <= '9');
    }

    fn parseNumber(self: *SvgPathParser) f32 {
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

fn cubicBezierPoint(p0: ByteVec2, p1: ByteVec2, p2: ByteVec2, p3: ByteVec2, t: f32) ByteVec2 {
    const omt = 1.0 - t;
    const omt2 = omt * omt;
    const omt3 = omt2 * omt;
    const t2 = t * t;
    const t3 = t2 * t;
    return .{
        .x = omt3 * p0.x + 3.0 * omt2 * t * p1.x + 3.0 * omt * t2 * p2.x + t3 * p3.x,
        .y = omt3 * p0.y + 3.0 * omt2 * t * p1.y + 3.0 * omt * t2 * p2.y + t3 * p3.y,
    };
}

fn quadraticBezierPoint(p0: ByteVec2, p1: ByteVec2, p2: ByteVec2, t: f32) ByteVec2 {
    const omt = 1.0 - t;
    const omt2 = omt * omt;
    const t2 = t * t;
    return .{
        .x = omt2 * p0.x + 2.0 * omt * t * p1.x + t2 * p2.x,
        .y = omt2 * p0.y + 2.0 * omt * t * p1.y + t2 * p2.y,
    };
}

fn bezierSegmentCount(points: []const ByteVec2, min_segments: i32, max_segments: i32, curve_scale: f32) i32 {
    var poly_len: f32 = 0.0;
    for (points[0 .. points.len - 1], 0..) |point, i| {
        const next = points[i + 1];
        poly_len += @sqrt(byteLengthSqr(subVec2(next, point)));
    }
    const chord = @sqrt(byteLengthSqr(subVec2(points[points.len - 1], points[0])));
    const curvature = @max(0.0, poly_len - chord);
    const scaled_curve = @max(curve_scale, 1.0);
    const estimate = @ceil((chord * 0.12 + curvature * 0.35) * scaled_curve);
    const scaled_max = @min(2048, @max(max_segments, @as(i32, @intFromFloat(@ceil(@as(f32, @floatFromInt(max_segments)) * scaled_curve)))));
    return std.math.clamp(@as(i32, @intFromFloat(estimate)), min_segments, scaled_max);
}

fn appendQuadraticCurve(shape: *VectorShape, p0: ByteVec2, p1: ByteVec2, p2: ByteVec2, curve_scale: f32) void {
    const segments = bezierSegmentCount(&.{ p0, p1, p2 }, 8, 96, curve_scale);
    var i: i32 = 1;
    while (i <= segments) : (i += 1) {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments));
        shape.lineTo(quadraticBezierPoint(p0, p1, p2, t));
    }
}

fn appendCubicCurve(shape: *VectorShape, p0: ByteVec2, p1: ByteVec2, p2: ByteVec2, p3: ByteVec2, curve_scale: f32) void {
    const segments = bezierSegmentCount(&.{ p0, p1, p2, p3 }, 12, 128, curve_scale);
    var i: i32 = 1;
    while (i <= segments) : (i += 1) {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments));
        shape.lineTo(cubicBezierPoint(p0, p1, p2, p3, t));
    }
}

fn svgAngleBetween(ux: f32, uy: f32, vx: f32, vy: f32) f32 {
    const dot = ux * vx + uy * vy;
    const len = @sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
    if (len <= 0.0) return 0.0;
    const arg = std.math.clamp(dot / len, -1.0, 1.0);
    var ang = std.math.acos(arg);
    if (ux * vy - uy * vx < 0.0) ang = -ang;
    return ang;
}

fn appendSvgArc(shape: *VectorShape, x0: f32, y0: f32, rx_in: f32, ry_in: f32, angle: f32, large_arc_flag: i32, sweep_flag: i32, x1: f32, y1: f32, curve_scale: f32) void {
    var rx = @abs(rx_in);
    var ry = @abs(ry_in);
    if (rx == 0.0 or ry == 0.0) {
        shape.lineTo(.{ .x = x1, .y = y1 });
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
    const theta1 = svgAngleBetween(1.0, 0.0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    var delta_theta = svgAngleBetween((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry);

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
        appendCubicCurve(shape, .{
            .x = cos_phi * x_a - sin_phi * y_a + cx,
            .y = sin_phi * x_a + cos_phi * y_a + cy,
        }, .{
            .x = cos_phi * cp1x - sin_phi * cp1y + cx,
            .y = sin_phi * cp1x + cos_phi * cp1y + cy,
        }, .{
            .x = cos_phi * cp2x - sin_phi * cp2y + cx,
            .y = sin_phi * cp2x + cos_phi * cp2y + cy,
        }, .{
            .x = cos_phi * x_b - sin_phi * y_b + cx,
            .y = sin_phi * x_b + cos_phi * y_b + cy,
        }, curve_scale);
        t += delta;
    }
}

fn parseSvgPathToShape(svg_path: []const u8, shape: *VectorShape, curve_scale: f32) bool {
    var parser = SvgPathParser{ .input = svg_path };

    while (!parser.eof()) {
        parser.skipWhitespace();
        if (parser.eof()) break;

        const prev_cmd = parser.last_cmd;
        var cmd: u8 = 0;
        const ch = parser.peek();
        if ((ch >= 'A' and ch <= 'Z') or (ch >= 'a' and ch <= 'z')) {
            cmd = ch;
            parser.index += 1;
        } else {
            cmd = parser.last_cmd;
            if (cmd == 'M') cmd = 'L' else if (cmd == 'm') cmd = 'l';
        }
        parser.last_cmd = cmd;

        switch (cmd) {
            'M' => {
                parser.current_x = parser.parseNumber();
                parser.current_y = parser.parseNumber();
                parser.start_x = parser.current_x;
                parser.start_y = parser.current_y;
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                if (!shape.startContour(.{ .x = parser.current_x, .y = parser.current_y })) return false;
                while (parser.hasMoreNumbers()) {
                    parser.current_x = parser.parseNumber();
                    parser.current_y = parser.parseNumber();
                    shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                }
            },
            'm' => {
                parser.current_x += parser.parseNumber();
                parser.current_y += parser.parseNumber();
                parser.start_x = parser.current_x;
                parser.start_y = parser.current_y;
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                if (!shape.startContour(.{ .x = parser.current_x, .y = parser.current_y })) return false;
                while (parser.hasMoreNumbers()) {
                    parser.current_x += parser.parseNumber();
                    parser.current_y += parser.parseNumber();
                    shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                }
            },
            'L' => while (true) {
                parser.current_x = parser.parseNumber();
                parser.current_y = parser.parseNumber();
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                if (!parser.hasMoreNumbers()) break;
            },
            'l' => while (true) {
                parser.current_x += parser.parseNumber();
                parser.current_y += parser.parseNumber();
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                if (!parser.hasMoreNumbers()) break;
            },
            'H' => while (true) {
                parser.current_x = parser.parseNumber();
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                if (!parser.hasMoreNumbers()) break;
            },
            'h' => while (true) {
                parser.current_x += parser.parseNumber();
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                if (!parser.hasMoreNumbers()) break;
            },
            'V' => while (true) {
                parser.current_y = parser.parseNumber();
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                if (!parser.hasMoreNumbers()) break;
            },
            'v' => while (true) {
                parser.current_y += parser.parseNumber();
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                shape.lineTo(.{ .x = parser.current_x, .y = parser.current_y });
                if (!parser.hasMoreNumbers()) break;
            },
            'C' => while (true) {
                const x1 = parser.parseNumber();
                const y1 = parser.parseNumber();
                const x2 = parser.parseNumber();
                const y2 = parser.parseNumber();
                const x = parser.parseNumber();
                const y = parser.parseNumber();
                appendCubicCurve(shape, .{ .x = parser.current_x, .y = parser.current_y }, .{ .x = x1, .y = y1 }, .{ .x = x2, .y = y2 }, .{ .x = x, .y = y }, curve_scale);
                parser.last_control_x = x2;
                parser.last_control_y = y2;
                parser.current_x = x;
                parser.current_y = y;
                if (!parser.hasMoreNumbers()) break;
            },
            'c' => while (true) {
                const x1 = parser.current_x + parser.parseNumber();
                const y1 = parser.current_y + parser.parseNumber();
                const x2 = parser.current_x + parser.parseNumber();
                const y2 = parser.current_y + parser.parseNumber();
                const x = parser.current_x + parser.parseNumber();
                const y = parser.current_y + parser.parseNumber();
                appendCubicCurve(shape, .{ .x = parser.current_x, .y = parser.current_y }, .{ .x = x1, .y = y1 }, .{ .x = x2, .y = y2 }, .{ .x = x, .y = y }, curve_scale);
                parser.last_control_x = x2;
                parser.last_control_y = y2;
                parser.current_x = x;
                parser.current_y = y;
                if (!parser.hasMoreNumbers()) break;
            },
            'S' => {
                var smooth = prev_cmd == 'C' or prev_cmd == 'c' or prev_cmd == 'S' or prev_cmd == 's';
                while (true) {
                    const x2 = parser.parseNumber();
                    const y2 = parser.parseNumber();
                    const x = parser.parseNumber();
                    const y = parser.parseNumber();
                    const x1 = if (smooth) 2.0 * parser.current_x - parser.last_control_x else parser.current_x;
                    const y1 = if (smooth) 2.0 * parser.current_y - parser.last_control_y else parser.current_y;
                    appendCubicCurve(shape, .{ .x = parser.current_x, .y = parser.current_y }, .{ .x = x1, .y = y1 }, .{ .x = x2, .y = y2 }, .{ .x = x, .y = y }, curve_scale);
                    parser.last_control_x = x2;
                    parser.last_control_y = y2;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                    smooth = true;
                }
            },
            's' => {
                var smooth = prev_cmd == 'C' or prev_cmd == 'c' or prev_cmd == 'S' or prev_cmd == 's';
                while (true) {
                    const x2 = parser.current_x + parser.parseNumber();
                    const y2 = parser.current_y + parser.parseNumber();
                    const x = parser.current_x + parser.parseNumber();
                    const y = parser.current_y + parser.parseNumber();
                    const x1 = if (smooth) 2.0 * parser.current_x - parser.last_control_x else parser.current_x;
                    const y1 = if (smooth) 2.0 * parser.current_y - parser.last_control_y else parser.current_y;
                    appendCubicCurve(shape, .{ .x = parser.current_x, .y = parser.current_y }, .{ .x = x1, .y = y1 }, .{ .x = x2, .y = y2 }, .{ .x = x, .y = y }, curve_scale);
                    parser.last_control_x = x2;
                    parser.last_control_y = y2;
                    parser.current_x = x;
                    parser.current_y = y;
                    if (!parser.hasMoreNumbers()) break;
                    smooth = true;
                }
            },
            'Q' => while (true) {
                const x1 = parser.parseNumber();
                const y1 = parser.parseNumber();
                const x = parser.parseNumber();
                const y = parser.parseNumber();
                appendQuadraticCurve(shape, .{ .x = parser.current_x, .y = parser.current_y }, .{ .x = x1, .y = y1 }, .{ .x = x, .y = y }, curve_scale);
                parser.last_control_x = x1;
                parser.last_control_y = y1;
                parser.current_x = x;
                parser.current_y = y;
                if (!parser.hasMoreNumbers()) break;
            },
            'q' => while (true) {
                const x1 = parser.current_x + parser.parseNumber();
                const y1 = parser.current_y + parser.parseNumber();
                const x = parser.current_x + parser.parseNumber();
                const y = parser.current_y + parser.parseNumber();
                appendQuadraticCurve(shape, .{ .x = parser.current_x, .y = parser.current_y }, .{ .x = x1, .y = y1 }, .{ .x = x, .y = y }, curve_scale);
                parser.last_control_x = x1;
                parser.last_control_y = y1;
                parser.current_x = x;
                parser.current_y = y;
                if (!parser.hasMoreNumbers()) break;
            },
            'A', 'a' => while (true) {
                const rx = parser.parseNumber();
                const ry = parser.parseNumber();
                const angle = parser.parseNumber();
                const large_arc = @as(i32, @intFromFloat(parser.parseNumber()));
                const sweep = @as(i32, @intFromFloat(parser.parseNumber()));
                const x = parser.parseNumber();
                const y = parser.parseNumber();
                const end_x = if (cmd == 'a') parser.current_x + x else x;
                const end_y = if (cmd == 'a') parser.current_y + y else y;
                appendSvgArc(shape, parser.current_x, parser.current_y, rx, ry, angle, large_arc, sweep, end_x, end_y, curve_scale);
                parser.current_x = end_x;
                parser.current_y = end_y;
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
                if (!parser.hasMoreNumbers()) break;
            },
            'Z', 'z' => {
                shape.closeContour();
                parser.current_x = parser.start_x;
                parser.current_y = parser.start_y;
                parser.last_control_x = parser.current_x;
                parser.last_control_y = parser.current_y;
            },
            else => {},
        }
    }

    return true;
}

fn transformVectorShapeInPlace(shape: *VectorShape, transform: Ui.SvgTransform) void {
    for (shape.contours.items) |*contour| {
        for (contour.points.items) |*point| {
            const src_x = point.x;
            const src_y = point.y;
            point.x = src_x * transform.a + src_y * transform.c + transform.e;
            point.y = src_x * transform.b + src_y * transform.d + transform.f;
        }
    }
}

fn pointInContourEvenOdd(contour: []const ByteVec2, sample: ByteVec2) bool {
    if (contour.len < 3) return false;

    var inside = false;
    var j = contour.len - 1;
    for (contour, 0..) |point, i| {
        const prev = contour[j];
        const intersects = ((point.y > sample.y) != (prev.y > sample.y)) and
            (sample.x < (prev.x - point.x) * (sample.y - point.y) / ((prev.y - point.y) + 0.000001) + point.x);
        if (intersects) inside = !inside;
        j = i;
    }
    return inside;
}

fn pointInShapeEvenOdd(shape: *const VectorShape, sample: ByteVec2) bool {
    var inside = false;
    for (shape.contours.items) |contour| {
        if (pointInContourEvenOdd(contour.points.items, sample)) inside = !inside;
    }
    return inside;
}

fn argbGrayValue(argb: ByteU32) u8 {
    const r: u32 = (argb >> 16) & 0xFF;
    const g: u32 = (argb >> 8) & 0xFF;
    const b: u32 = argb & 0xFF;
    return @intCast(@divTrunc(r + g + b, 3));
}

fn rasterizeVectorShapeToRgba(shape: *const VectorShape, width: u32, height: u32, fill_argb: ByteU32, sample_grid: u32) ?[]u8 {
    const rgba = allocator.alloc(u8, @as(usize, width) * @as(usize, height) * 4) catch return null;
    @memset(rgba, 0);
    const rgb_value = argbGrayValue(fill_argb);

    const grid = @max(@as(u32, 1), sample_grid);
    const inv_grid = 1.0 / @as(f32, @floatFromInt(grid));
    const sample_count = grid * grid;

    for (0..height) |row| {
        for (0..width) |col| {
            var covered: u32 = 0;
            var sy: u32 = 0;
            while (sy < grid) : (sy += 1) {
                var sx: u32 = 0;
                while (sx < grid) : (sx += 1) {
                    const sample = ByteVec2{
                        .x = @as(f32, @floatFromInt(col)) + (@as(f32, @floatFromInt(sx)) + 0.5) * inv_grid,
                        .y = @as(f32, @floatFromInt(row)) + (@as(f32, @floatFromInt(sy)) + 0.5) * inv_grid,
                    };
                    if (pointInShapeEvenOdd(shape, sample)) covered += 1;
                }
            }
            if (covered == 0) continue;

            const alpha: u8 = @intCast(@divTrunc(covered * 255, sample_count));
            const dst_index = (row * @as(usize, width) + col) * 4;
            rgba[dst_index + 0] = rgb_value;
            rgba[dst_index + 1] = rgb_value;
            rgba[dst_index + 2] = rgb_value;
            rgba[dst_index + 3] = alpha;
        }
    }

    return rgba;
}

fn sampleRgbaBilinear(pixels: []const u8, width: u32, height: u32, x: f32, y: f32) [4]f32 {
    if (width == 0 or height == 0) return .{ 0.0, 0.0, 0.0, 0.0 };

    const max_x = @as(f32, @floatFromInt(width - 1));
    const max_y = @as(f32, @floatFromInt(height - 1));
    const clamped_x = std.math.clamp(x, 0.0, max_x);
    const clamped_y = std.math.clamp(y, 0.0, max_y);

    const x0: u32 = @intFromFloat(@floor(clamped_x));
    const y0: u32 = @intFromFloat(@floor(clamped_y));
    const x1: u32 = @min(width - 1, x0 + 1);
    const y1: u32 = @min(height - 1, y0 + 1);
    const tx = clamped_x - @as(f32, @floatFromInt(x0));
    const ty = clamped_y - @as(f32, @floatFromInt(y0));

    const idx00 = (@as(usize, y0) * @as(usize, width) + @as(usize, x0)) * 4;
    const idx10 = (@as(usize, y0) * @as(usize, width) + @as(usize, x1)) * 4;
    const idx01 = (@as(usize, y1) * @as(usize, width) + @as(usize, x0)) * 4;
    const idx11 = (@as(usize, y1) * @as(usize, width) + @as(usize, x1)) * 4;

    var result = [4]f32{ 0.0, 0.0, 0.0, 0.0 };
    for (0..4) |channel| {
        const top = std.math.lerp(@as(f32, @floatFromInt(pixels[idx00 + channel])), @as(f32, @floatFromInt(pixels[idx10 + channel])), tx);
        const bottom = std.math.lerp(@as(f32, @floatFromInt(pixels[idx01 + channel])), @as(f32, @floatFromInt(pixels[idx11 + channel])), tx);
        result[channel] = std.math.lerp(top, bottom, ty) / 255.0;
    }
    return result;
}

fn blendScaledRgbaIntoRgba(dst: []u8, dst_w: u32, dst_h: u32, src: []const u8, src_w: u32, src_h: u32, dest_pos: ByteVec2, scale: ByteVec2) void {
    if (src_w == 0 or src_h == 0 or scale.x <= 0.0 or scale.y <= 0.0) return;

    const scaled_w = @max(1, @as(i32, @intFromFloat(@ceil(@as(f32, @floatFromInt(src_w)) * scale.x))));
    const scaled_h = @max(1, @as(i32, @intFromFloat(@ceil(@as(f32, @floatFromInt(src_h)) * scale.y))));
    const start_x = std.math.clamp(@as(i32, @intFromFloat(@floor(dest_pos.x))), 0, @as(i32, @intCast(dst_w)));
    const start_y = std.math.clamp(@as(i32, @intFromFloat(@floor(dest_pos.y))), 0, @as(i32, @intCast(dst_h)));
    const end_x = std.math.clamp(@as(i32, @intFromFloat(@ceil(dest_pos.x + @as(f32, @floatFromInt(scaled_w))))), 0, @as(i32, @intCast(dst_w)));
    const end_y = std.math.clamp(@as(i32, @intFromFloat(@ceil(dest_pos.y + @as(f32, @floatFromInt(scaled_h))))), 0, @as(i32, @intCast(dst_h)));

    var y = start_y;
    while (y < end_y) : (y += 1) {
        const src_y = ((@as(f32, @floatFromInt(y)) + 0.5) - dest_pos.y) / scale.y - 0.5;
        if (src_y < -0.5 or src_y > @as(f32, @floatFromInt(src_h)) - 0.5) continue;

        var x = start_x;
        while (x < end_x) : (x += 1) {
            const src_x = ((@as(f32, @floatFromInt(x)) + 0.5) - dest_pos.x) / scale.x - 0.5;
            if (src_x < -0.5 or src_x > @as(f32, @floatFromInt(src_w)) - 0.5) continue;

            const sample = sampleRgbaBilinear(src, src_w, src_h, src_x, src_y);
            const src_a = clamp01(sample[3]);
            if (src_a <= 0.0) continue;

            const dst_index = (@as(usize, @intCast(y)) * @as(usize, dst_w) + @as(usize, @intCast(x))) * 4;
            const dst_r = @as(f32, @floatFromInt(dst[dst_index + 0])) / 255.0;
            const dst_g = @as(f32, @floatFromInt(dst[dst_index + 1])) / 255.0;
            const dst_b = @as(f32, @floatFromInt(dst[dst_index + 2])) / 255.0;
            const dst_a = @as(f32, @floatFromInt(dst[dst_index + 3])) / 255.0;

            const out_a = src_a + dst_a * (1.0 - src_a);
            if (out_a <= 0.0) continue;

            const out_r = (sample[0] * src_a + dst_r * dst_a * (1.0 - src_a)) / out_a;
            const out_g = (sample[1] * src_a + dst_g * dst_a * (1.0 - src_a)) / out_a;
            const out_b = (sample[2] * src_a + dst_b * dst_a * (1.0 - src_a)) / out_a;

            dst[dst_index + 0] = @intFromFloat(clamp01(out_r) * 255.0);
            dst[dst_index + 1] = @intFromFloat(clamp01(out_g) * 255.0);
            dst[dst_index + 2] = @intFromFloat(clamp01(out_b) * 255.0);
            dst[dst_index + 3] = @intFromFloat(clamp01(out_a) * 255.0);
        }
    }
}

const RgbaAlphaBounds = struct {
    min_x: u32,
    min_y: u32,
    max_x: u32,
    max_y: u32,
};

fn computeRgbaAlphaBounds(rgba: []const u8, width: u32, height: u32) ?RgbaAlphaBounds {
    if (width == 0 or height == 0) return null;

    var found = false;
    var min_x: u32 = width;
    var min_y: u32 = height;
    var max_x: u32 = 0;
    var max_y: u32 = 0;

    for (0..height) |row| {
        for (0..width) |col| {
            const alpha = rgba[(row * @as(usize, width) + col) * 4 + 3];
            if (alpha == 0) continue;
            found = true;
            min_x = @min(min_x, @as(u32, @intCast(col)));
            min_y = @min(min_y, @as(u32, @intCast(row)));
            max_x = @max(max_x, @as(u32, @intCast(col)) + 1);
            max_y = @max(max_y, @as(u32, @intCast(row)) + 1);
        }
    }

    if (!found) return null;
    return .{
        .min_x = min_x,
        .min_y = min_y,
        .max_x = max_x,
        .max_y = max_y,
    };
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
    const tessellation_error = if (GByteGUI) |ctx| @max(0.05, ctx.Style.CircleTessellationMaxError) else 0.10;
    if (radius <= 0.0) return 12;
    const max_error = @min(tessellation_error, radius);
    const angle = std.math.acos(@max(0.0, 1.0 - max_error / radius));
    if (angle <= 0.0) return 12;
    const segments: i32 = @intFromFloat(@ceil((2.0 * kPi) / (2.0 * angle)));
    return std.math.clamp(segments, 12, 96);
}

fn systemFontPath(comptime file_name: []const u8) ?[]u8 {
    return windowsFontPath(allocator, file_name);
}

fn detectFontStyleFromPath(path: []const u8) i32 {
    const lower = std.ascii.allocLowerString(allocator, path) catch return FontStyleRegular;
    defer allocator.free(lower);

    if (std.mem.indexOf(u8, lower, "bold") != null or std.mem.indexOf(u8, lower, "euib") != null or std.mem.indexOf(u8, lower, "bd") != null) return FontStyleBold;
    return FontStyleRegular;
}

fn calcTextScrollMax(content_height: f32, viewport_height: f32) f32 {
    return @max(0.0, content_height - viewport_height);
}

fn calcTextLayoutScrollHeight(layout: *const TextLayoutResult) f32 {
    const line_height = @max(1.0, layout.line_height);
    var bottom: f32 = 0.0;
    for (layout.lines.items, 0..) |line, line_index| {
        const line_top = @as(f32, @floatFromInt(line_index)) * line_height;
        const line_bottom = if (line.bounds.Height > 0.5)
            line_top + layout.ascender + line.bounds.Y + line.bounds.Height
        else
            line_top + line_height;
        bottom = @max(bottom, line_bottom);
    }
    return @max(0.0, bottom);
}

fn layoutScrollableText(params: ScrollableTextLayoutParams) ?ScrollableTextLayoutResult {
    const font = params.font orelse return null;
    var wrap_width = @max(1.0, params.viewport.x);
    var layout = layoutText(font, params.font_size, params.text, wrap_width) orelse return null;
    var content_height = calcTextLayoutScrollHeight(&layout);
    var overflow = content_height > params.viewport.y + 0.5;

    if (overflow and params.scrollbar_reserved_width > 0.0) {
        const reduced_wrap_width = @max(1.0, params.viewport.x - params.scrollbar_reserved_width);
        if (reduced_wrap_width < wrap_width) {
            layout.deinit();
            wrap_width = reduced_wrap_width;
            layout = layoutText(font, params.font_size, params.text, wrap_width) orelse return null;
            content_height = calcTextLayoutScrollHeight(&layout);
            overflow = content_height > params.viewport.y + 0.5;
        }
    }

    return .{
        .layout = layout,
        .viewport = params.viewport,
        .content_height = content_height,
        .overflow = overflow,
    };
}

fn calcTextLineVisualMid(layout: *const TextLayoutResult, line_index: usize) f32 {
    const line_height = @max(1.0, layout.line_height);
    const line_top = @as(f32, @floatFromInt(line_index)) * line_height;
    if (line_index >= layout.lines.items.len) return line_top + line_height * 0.5;

    const line = layout.lines.items[line_index];
    if (line.bounds.Height <= 0.5) return line_top + line_height * 0.5;

    const glyph_top = line_top + layout.ascender + line.bounds.Y;
    const glyph_bottom = glyph_top + line.bounds.Height;
    return (std.math.clamp(glyph_top, line_top, line_top + line_height) +
        std.math.clamp(glyph_bottom, line_top, line_top + line_height)) * 0.5;
}

fn snapTextScrollYToLine(value: f32, max_scroll: f32, layout: *const TextLayoutResult) f32 {
    const line_height = @max(1.0, layout.line_height);
    if (line_height <= 0.0) return std.math.clamp(value, 0.0, max_scroll);
    if (value >= max_scroll - 0.05) return max_scroll;
    if (layout.lines.items.len == 0) return std.math.clamp(value, 0.0, max_scroll);

    const clamped = std.math.clamp(value, 0.0, max_scroll);
    var snap_index: usize = 0;
    for (layout.lines.items, 0..) |_, line_index| {
        if (clamped < calcTextLineVisualMid(layout, line_index)) break;
        snap_index = @min(line_index + 1, layout.lines.items.len - 1);
    }

    return std.math.clamp(@as(f32, @floatFromInt(snap_index)) * line_height, 0.0, max_scroll);
}

fn snapTextScrollYToLineHeight(value: f32, max_scroll: f32, line_height_in: f32) f32 {
    const line_height = @max(1.0, line_height_in);
    if (line_height <= 0.0) return std.math.clamp(value, 0.0, max_scroll);
    if (value >= max_scroll - 0.05) return max_scroll;
    return std.math.clamp(@round(value / line_height) * line_height, 0.0, max_scroll);
}

fn nextUtf8Index(text: []const u8, index: usize, end: usize) usize {
    if (index >= end) return end;
    const cp_len = std.unicode.utf8ByteSequenceLength(text[index]) catch 1;
    return @min(end, index + cp_len);
}

fn textWidthRange(font: ?*ByteFont, font_size: f32, text: []const u8, start: usize, end: usize) f32 {
    if (end <= start) return 0.0;
    return ByteGUI.CalcTextWidth(font, font_size, text[start..end]);
}

fn textLineIndexAtX(font: ?*ByteFont, font_size: f32, text: []const u8, line: TextLine, x: f32) usize {
    if (x <= 0.0 or line.end <= line.start) return line.start;
    if (x >= line.width) return line.end;

    var index = line.start;
    while (index < line.end) {
        const next = nextUtf8Index(text, index, line.end);
        const left_w = textWidthRange(font, font_size, text, line.start, index);
        const right_w = textWidthRange(font, font_size, text, line.start, next);
        if (x < (left_w + right_w) * 0.5) return index;
        index = next;
    }
    return line.end;
}

fn textIndexFromPoint(params: TextIndexFromPointParams) usize {
    if (params.text.len == 0 or params.layout.lines.items.len == 0) return 0;

    const x = params.point.x - params.base_pos.x;
    const y = params.point.y - params.base_pos.y + params.scroll_y;
    if (y <= 0.0) return textLineIndexAtX(params.font, params.font_size, params.text, params.layout.lines.items[0], x);

    const line_height = @max(1.0, params.layout.line_height);
    const line_index_f = @floor(y / line_height);
    if (line_index_f >= @as(f32, @floatFromInt(params.layout.lines.items.len))) return params.text.len;

    const line_index: usize = @intFromFloat(@max(0.0, line_index_f));
    return textLineIndexAtX(params.font, params.font_size, params.text, params.layout.lines.items[line_index], x);
}

fn textIndexFromDragPoint(params: TextIndexFromPointParams) usize {
    if (params.text.len == 0 or params.layout.lines.items.len == 0) return 0;

    if (params.point.y >= params.base_pos.y and params.point.y < params.base_pos.y + params.viewport_height) return textIndexFromPoint(params);

    const x = params.point.x - params.base_pos.x;
    const viewport_top = params.scroll_y;
    const viewport_bottom = viewport_top + @max(1.0, params.viewport_height);

    if (params.point.y < params.base_pos.y) {
        for (params.layout.lines.items, 0..) |line, line_index| {
            if (calcTextLineVisualMid(params.layout, line_index) >= viewport_top) {
                return textLineIndexAtX(params.font, params.font_size, params.text, line, x);
            }
        }
        return textLineIndexAtX(params.font, params.font_size, params.text, params.layout.lines.items[params.layout.lines.items.len - 1], x);
    }

    var best_index: usize = 0;
    for (params.layout.lines.items, 0..) |_, line_index| {
        if (calcTextLineVisualMid(params.layout, line_index) > viewport_bottom) break;
        best_index = line_index;
    }
    return textLineIndexAtX(params.font, params.font_size, params.text, params.layout.lines.items[best_index], x);
}

fn setClipRectFromRect(draw: *ByteDrawList, rect: w32.RECT) ByteVec4 {
    const saved_clip = draw.CurrentClipRect;
    draw.SetClipRect(.{
        .x = @as(f32, @floatFromInt(rect.left)),
        .y = @as(f32, @floatFromInt(rect.top)),
        .z = @as(f32, @floatFromInt(rect.right)),
        .w = @as(f32, @floatFromInt(rect.bottom)),
    });
    return saved_clip;
}

fn drawTextSelectionHighlightClipped(draw: ?*ByteDrawList, state: *TextSelectionHighlightState, params: TextSelectionHighlightParams, clip_rect: w32.RECT) void {
    const active_draw = draw orelse return;
    const saved_clip = setClipRectFromRect(active_draw, clip_rect);
    defer active_draw.SetClipRect(saved_clip);
    drawTextSelectionHighlight(active_draw, state, params);
}

fn drawTextLayoutClipped(draw: ?*ByteDrawList, params: TextLayoutDrawParams) void {
    const active_draw = draw orelse return;
    const font = params.font orelse return;
    if ((params.color & BYTEGUI_COL32_A_MASK) == 0) return;

    const saved_clip = setClipRectFromRect(active_draw, params.clip_rect);
    defer active_draw.SetClipRect(saved_clip);

    const line_height = @max(1.0, params.layout.line_height);
    const bottom = @as(f32, @floatFromInt(params.clip_rect.bottom));
    for (params.layout.lines.items, 0..) |line, line_index| {
        const y = params.base_pos.y + @as(f32, @floatFromInt(line_index)) * line_height - params.scroll_y;
        if (y + line_height < params.base_pos.y or y > bottom) continue;
        active_draw.AddTextSubpixel(font, params.font_size, .{ .x = params.base_pos.x, .y = y }, params.color, params.text[line.start..line.end], null);
    }
}

fn calcVerticalScrollbarTrack(params: VerticalScrollbarTrackParams) VerticalScrollbarTrack {
    return .{
        .pos = .{
            .x = @as(f32, @floatFromInt(params.viewport_rect.right)) - params.pad - params.width,
            .y = @as(f32, @floatFromInt(params.viewport_rect.top)) + params.pad,
        },
        .size = .{ .x = params.width, .y = @max(1.0, params.viewport_height - params.pad * 2.0) },
    };
}

fn scrollbarScrollForThumbTop(metrics: ScrollbarMetrics, thumb_top: f32) f32 {
    const drag_range = @max(1.0, metrics.track_size.y - metrics.thumb_size.y);
    const t = std.math.clamp((thumb_top - metrics.track_pos.y) / drag_range, 0.0, 1.0);
    return t * metrics.max_scroll;
}

// Text layout and cache
pub const TextBounds = struct {
    X: f32 = 0.0,
    Y: f32 = 0.0,
    Width: f32 = 0.0,
    Height: f32 = 0.0,
};

pub const TextLine = struct {
    start: usize,
    end: usize,
    width: f32 = 0.0,
    bounds: TextBounds = .{},
};

const TextMeasureSession = struct {
    font: *const ByteFont,
    size_pixels: f32,
    ascender_px: f32,
    descender_px: f32,
    line_height_px: f32,

    fn init(byte_font: *const ByteFont, size_pixels: f32) ?TextMeasureSession {
        if (size_pixels <= 0.0 or byte_font.FontData.len == 0) return null;

        const metrics = @constCast(&byte_font.ByteTypeFace).getSizeMetrics(size_pixels) orelse return null;
        return .{
            .font = byte_font,
            .size_pixels = size_pixels,
            .ascender_px = metrics.ascender,
            .descender_px = metrics.descender,
            .line_height_px = @max(1.0, metrics.ascender - metrics.descender),
        };
    }

    fn deinit(self: *TextMeasureSession) void {
        _ = self;
    }

    fn measureBounds(self: *const TextMeasureSession, text: []const u8) TextBounds {
        return computeTextBounds(self.font, self.size_pixels, text);
    }

    fn measureWidth(self: *const TextMeasureSession, text: []const u8) f32 {
        return @max(0.0, self.measureBounds(text).Width);
    }

    fn lineHeight(self: *const TextMeasureSession) f32 {
        return @max(1.0, self.line_height_px);
    }
};

pub const TextLayoutResult = struct {
    lines: std.ArrayListUnmanaged(TextLine) = .empty,
    width: f32 = 0.0,
    height: f32 = 0.0,
    line_height: f32 = 0.0,
    ascender: f32 = 0.0,

    pub fn deinit(self: *TextLayoutResult) void {
        self.lines.deinit(allocator);
        self.* = .{};
    }
};

pub const ScrollableTextLayoutParams = struct {
    font: ?*ByteFont,
    font_size: f32,
    text: []const u8,
    viewport: ByteVec2,
    scrollbar_reserved_width: f32 = 0.0,
};

pub const ScrollableTextLayoutResult = struct {
    layout: TextLayoutResult,
    viewport: ByteVec2,
    content_height: f32 = 0.0,
    overflow: bool = false,

    pub fn deinit(self: *ScrollableTextLayoutResult) void {
        self.layout.deinit();
        self.* = .{ .layout = .{}, .viewport = .{} };
    }
};

pub const TextIndexFromPointParams = struct {
    font: ?*ByteFont,
    font_size: f32,
    text: []const u8,
    layout: *const TextLayoutResult,
    base_pos: ByteVec2,
    viewport_height: f32,
    scroll_y: f32,
    point: ByteVec2,
};

pub const TextLayoutDrawParams = struct {
    font: ?*ByteFont,
    font_size: f32,
    text: []const u8,
    layout: *const TextLayoutResult,
    clip_rect: w32.RECT,
    base_pos: ByteVec2,
    scroll_y: f32,
    color: ByteU32,
};

pub const VerticalScrollbarTrackParams = struct {
    viewport_rect: w32.RECT,
    viewport_height: f32,
    width: f32,
    pad: f32,
};

pub const VerticalScrollbarTrack = struct {
    pos: ByteVec2,
    size: ByteVec2,
};

pub const TextSelectionRange = struct {
    start: usize,
    end: usize,
};

pub const VerticalScrollbarParams = struct {
    track_pos: ByteVec2,
    track_size: ByteVec2,
    content_height: f32,
    viewport_height: f32,
    scroll_y: f32,
    min_thumb_height: f32,
};

pub const ScrollbarMetrics = struct {
    track_pos: ByteVec2,
    track_size: ByteVec2,
    thumb_pos: ByteVec2,
    thumb_size: ByteVec2,
    max_scroll: f32,
};

pub const ScrollbarVisualState = struct {
    visual_t: f32 = 0.0,
    visibility_t: f32 = 0.0,
    thumb_pos: ByteVec2 = .{},
    thumb_size: ByteVec2 = .{},
    has_geometry: bool = false,
};

pub const ScrollbarDrawParams = struct {
    metrics: ScrollbarMetrics,
    idle_color: ByteVec4,
    hover_color: ByteVec4,
    active_color: ByteVec4,
    hover_t: f32,
    fade_seconds: f32,
    geometry_rate: f32,
    active_geometry_rate: f32,
    hovered: bool = false,
    active: bool = false,
    visible: bool = true,
    opacity: f32 = 1.0,
    dt: f32 = 1.0 / 60.0,
};

pub const TextSelectionHighlightParams = struct {
    font: ?*ByteFont,
    font_size: f32,
    text: []const u8,
    layout: *const TextLayoutResult,
    selection: ?TextSelectionRange,
    base_pos: ByteVec2,
    viewport_height: f32,
    scroll_y: f32,
    color: ByteVec4,
    opacity: f32 = 1.0,
    radius: f32 = 2.0,
    dt: f32 = 1.0 / 60.0,
};

const TextSelectionHighlightRect = struct {
    line_index: usize = 0,
    current_min: ByteVec2 = .{},
    current_max: ByteVec2 = .{},
    target_min: ByteVec2 = .{},
    target_max: ByteVec2 = .{},
    alpha: f32 = 0.0,
    target_alpha: f32 = 0.0,
    scale_y: f32 = 0.65,
    target_scale_y: f32 = 1.0,
    corner_round: [4]f32 = [_]f32{ 1.0, 1.0, 1.0, 1.0 },
    target_corner_round: [4]f32 = [_]f32{ 1.0, 1.0, 1.0, 1.0 },
    grow_anchor_current: ByteVec2 = .{},
    grow_anchor_target: ByteVec2 = .{},
    matched: bool = false,
};

const TextSelectionHighlightTarget = struct {
    line_index: usize,
    min: ByteVec2,
    max: ByteVec2,
};

pub const TextSelectionHighlightState = struct {
    rects: std.ArrayListUnmanaged(TextSelectionHighlightRect) = .empty,
    last_selection_start: usize = 0,
    last_selection_end: usize = 0,
    last_selection_valid: bool = false,

    pub fn deinit(self: *TextSelectionHighlightState) void {
        self.rects.deinit(allocator);
        self.* = .{};
    }
};

fn normalizedTextSelectionRange(selection: ?TextSelectionRange, text_len: usize) ?TextSelectionRange {
    const range = selection orelse return null;
    const start = @min(@min(range.start, range.end), text_len);
    const end = @min(@max(range.start, range.end), text_len);
    if (start == end) return null;
    return .{ .start = start, .end = end };
}

fn textSelectionWidth(font: ?*ByteFont, font_size: f32, text: []const u8, start: usize, end: usize) f32 {
    if (end <= start) return 0.0;
    return ByteGUI.CalcTextWidth(font, font_size, text[start..end]);
}

fn appendTextSelectionTargets(targets: *std.ArrayListUnmanaged(TextSelectionHighlightTarget), params: TextSelectionHighlightParams) bool {
    const selection = normalizedTextSelectionRange(params.selection, params.text.len) orelse return true;
    const line_height = @max(1.0, params.layout.line_height);
    const bottom = params.base_pos.y + params.viewport_height;

    for (params.layout.lines.items, 0..) |line, line_index| {
        const sel_start = @max(selection.start, line.start);
        const sel_end = @min(selection.end, line.end);
        if (sel_end <= sel_start) continue;

        const y = params.base_pos.y + @as(f32, @floatFromInt(line_index)) * line_height - params.scroll_y;
        if (y + line_height < params.base_pos.y or y > bottom) continue;

        const x0 = params.base_pos.x + textSelectionWidth(params.font, params.font_size, params.text, line.start, sel_start);
        const x1 = params.base_pos.x + textSelectionWidth(params.font, params.font_size, params.text, line.start, sel_end);
        if (x1 <= x0) continue;
        targets.append(allocator, .{
            .line_index = line_index,
            .min = .{ .x = x0, .y = y },
            .max = .{ .x = x1, .y = y + line_height },
        }) catch return false;
    }
    return true;
}

fn findTextSelectionRect(rects: []const TextSelectionHighlightRect, line_index: usize) ?usize {
    for (rects, 0..) |rect, i| {
        if (rect.line_index == line_index) return i;
    }
    return null;
}

fn textSelectionSmoothFactor(dt: f32, rate: f32) f32 {
    return std.math.clamp(1.0 - @exp(-@max(0.0, dt) * rate), 0.0, 1.0);
}

fn textSelectionApproach(current: f32, target: f32, t: f32) f32 {
    return current + (target - current) * t;
}

fn textSelectionStateHasSameRange(state: *const TextSelectionHighlightState, selection: ?TextSelectionRange) bool {
    const range = selection orelse return !state.last_selection_valid;
    return state.last_selection_valid and state.last_selection_start == range.start and state.last_selection_end == range.end;
}

fn storeTextSelectionStateRange(state: *TextSelectionHighlightState, selection: ?TextSelectionRange) void {
    if (selection) |range| {
        state.last_selection_start = range.start;
        state.last_selection_end = range.end;
        state.last_selection_valid = true;
    } else {
        state.last_selection_start = 0;
        state.last_selection_end = 0;
        state.last_selection_valid = false;
    }
}

fn textSelectionCornerRoundTargets(flags: u8) [4]f32 {
    return [_]f32{
        if ((flags & ByteDrawCornerFlags_TopLeft) != 0) 1.0 else 0.0,
        if ((flags & ByteDrawCornerFlags_TopRight) != 0) 1.0 else 0.0,
        if ((flags & ByteDrawCornerFlags_BottomRight) != 0) 1.0 else 0.0,
        if ((flags & ByteDrawCornerFlags_BottomLeft) != 0) 1.0 else 0.0,
    };
}

fn textSelectionRectCenter(min: ByteVec2, max: ByteVec2) ByteVec2 {
    return .{
        .x = (min.x + max.x) * 0.5,
        .y = (min.y + max.y) * 0.5,
    };
}

fn textSelectionEdgeRectFromAnchor(target_min: ByteVec2, target_max: ByteVec2, anchor: ByteVec2, out_min: *ByteVec2, out_max: *ByteVec2) void {
    const center_x = (target_min.x + target_max.x) * 0.5;
    const edge_x = if (anchor.x >= center_x) target_max.x else target_min.x;
    out_min.* = .{ .x = edge_x, .y = target_min.y };
    out_max.* = .{ .x = edge_x, .y = target_max.y };
}

fn textSelectionGrowthAnchorFromNeighbors(target: TextSelectionHighlightTarget, rects: []const TextSelectionHighlightRect) ByteVec2 {
    if (rects.len == 0) return target.min;

    var closest_index: ?usize = null;
    var closest_line_delta: usize = std.math.maxInt(usize);
    for (rects, 0..) |rect, i| {
        if (@max(rect.alpha, rect.target_alpha) <= 0.01) continue;
        const line_delta = if (target.line_index > rect.line_index) target.line_index - rect.line_index else rect.line_index - target.line_index;
        if (line_delta < closest_line_delta) {
            closest_line_delta = line_delta;
            closest_index = i;
        }
    }

    const closest = if (closest_index) |i| rects[i] else return target.min;

    if (target.line_index > closest.line_index) return target.min;
    if (target.line_index < closest.line_index) return target.max;

    return target.min;
}

fn textSelectionCollapseAnchorFromTargets(rect: TextSelectionHighlightRect, targets: []const TextSelectionHighlightTarget) ByteVec2 {
    if (targets.len == 0) return rect.grow_anchor_target;

    var closest = targets[0];
    var closest_line_delta: usize = if (rect.line_index > closest.line_index) rect.line_index - closest.line_index else closest.line_index - rect.line_index;
    for (targets[1..]) |target| {
        const line_delta = if (rect.line_index > target.line_index) rect.line_index - target.line_index else target.line_index - rect.line_index;
        if (line_delta < closest_line_delta) {
            closest_line_delta = line_delta;
            closest = target;
        }
    }

    if (rect.line_index > closest.line_index) return rect.target_min;
    if (rect.line_index < closest.line_index) return rect.target_max;

    return rect.grow_anchor_target;
}

fn textSelectionEdgeCoverageFromStart(edge: f32, other_min: f32, other_max: f32, span: f32, epsilon: f32) f32 {
    if (other_min > edge + epsilon or other_max < edge - epsilon) return 0.0;
    return @max(0.0, @min(other_max, edge + span) - edge);
}

fn textSelectionEdgeCoverageFromEnd(edge: f32, other_min: f32, other_max: f32, span: f32, epsilon: f32) f32 {
    if (other_max < edge - epsilon or other_min > edge + epsilon) return 0.0;
    return @max(0.0, edge - @max(other_min, edge - span));
}

fn textSelectionApplyCornerMorph(rounding: *[4]f32, corner_index: usize, coverage: f32, span: f32) void {
    if (coverage <= 0.0) return;
    const t = std.math.clamp(coverage / @max(span, 0.001), 0.0, 1.0);
    rounding[corner_index] = @min(rounding[corner_index], 1.0 - t);
}

fn textSelectionCornerRoundFromCurrentGeometry(rects: []const TextSelectionHighlightRect, index: usize, radius: f32) [4]f32 {
    var rounding = [_]f32{ 1.0, 1.0, 1.0, 1.0 };
    const rect = rects[index];
    if (@max(rect.alpha, rect.target_alpha) <= 0.01) return rounding;

    const epsilon: f32 = 0.75;
    const span = @max(radius, 1.0);
    for (rects, 0..) |other, other_index| {
        if (other_index == index or @max(other.alpha, other.target_alpha) <= 0.01) continue;
        if (other.current_max.x <= other.current_min.x or other.current_max.y <= other.current_min.y) continue;

        if (@abs(other.current_max.y - rect.current_min.y) <= epsilon) {
            textSelectionApplyCornerMorph(&rounding, 0, textSelectionEdgeCoverageFromStart(rect.current_min.x, other.current_min.x, other.current_max.x, span, epsilon), span);
            textSelectionApplyCornerMorph(&rounding, 1, textSelectionEdgeCoverageFromEnd(rect.current_max.x, other.current_min.x, other.current_max.x, span, epsilon), span);
        }

        if (@abs(other.current_min.y - rect.current_max.y) <= epsilon) {
            textSelectionApplyCornerMorph(&rounding, 3, textSelectionEdgeCoverageFromStart(rect.current_min.x, other.current_min.x, other.current_max.x, span, epsilon), span);
            textSelectionApplyCornerMorph(&rounding, 2, textSelectionEdgeCoverageFromEnd(rect.current_max.x, other.current_min.x, other.current_max.x, span, epsilon), span);
        }

        if (@abs(other.current_max.x - rect.current_min.x) <= epsilon) {
            textSelectionApplyCornerMorph(&rounding, 0, textSelectionEdgeCoverageFromStart(rect.current_min.y, other.current_min.y, other.current_max.y, span, epsilon), span);
            textSelectionApplyCornerMorph(&rounding, 3, textSelectionEdgeCoverageFromEnd(rect.current_max.y, other.current_min.y, other.current_max.y, span, epsilon), span);
        }

        if (@abs(other.current_min.x - rect.current_max.x) <= epsilon) {
            textSelectionApplyCornerMorph(&rounding, 1, textSelectionEdgeCoverageFromStart(rect.current_min.y, other.current_min.y, other.current_max.y, span, epsilon), span);
            textSelectionApplyCornerMorph(&rounding, 2, textSelectionEdgeCoverageFromEnd(rect.current_max.y, other.current_min.y, other.current_max.y, span, epsilon), span);
        }
    }
    return rounding;
}

fn syncTextSelectionStableRangeTargets(state: *TextSelectionHighlightState, targets: []const TextSelectionHighlightTarget) void {
    for (state.rects.items) |*rect| rect.matched = false;

    for (targets) |target| {
        if (findTextSelectionRect(state.rects.items, target.line_index)) |index| {
            var rect = &state.rects.items[index];
            const anchor = textSelectionRectCenter(target.min, target.max);
            rect.current_min.y += target.min.y - rect.target_min.y;
            rect.current_max.y += target.max.y - rect.target_max.y;
            rect.grow_anchor_current.y += anchor.y - rect.grow_anchor_target.y;
            rect.target_min = target.min;
            rect.target_max = target.max;
            rect.target_alpha = 1.0;
            rect.target_scale_y = 1.0;
            rect.grow_anchor_target = anchor;
            rect.matched = true;
        } else {
            state.rects.append(allocator, .{
                .line_index = target.line_index,
                .current_min = target.min,
                .current_max = target.max,
                .target_min = target.min,
                .target_max = target.max,
                .alpha = 1.0,
                .target_alpha = 1.0,
                .scale_y = 1.0,
                .target_scale_y = 1.0,
                .corner_round = [_]f32{ 1.0, 1.0, 1.0, 1.0 },
                .target_corner_round = [_]f32{ 1.0, 1.0, 1.0, 1.0 },
                .grow_anchor_current = textSelectionRectCenter(target.min, target.max),
                .grow_anchor_target = textSelectionRectCenter(target.min, target.max),
                .matched = true,
            }) catch {};
        }
    }

    var i: usize = 0;
    while (i < state.rects.items.len) {
        if (!state.rects.items[i].matched) {
            _ = state.rects.orderedRemove(i);
            continue;
        }
        i += 1;
    }
}

fn syncTextSelectionHighlightState(state: *TextSelectionHighlightState, selection: ?TextSelectionRange, targets: []const TextSelectionHighlightTarget, dt: f32, corner_radius: f32) void {
    const same_selection = textSelectionStateHasSameRange(state, selection);
    if (same_selection) {
        syncTextSelectionStableRangeTargets(state, targets);
    } else {
        for (state.rects.items) |*rect| rect.matched = false;

        for (targets) |target| {
            if (findTextSelectionRect(state.rects.items, target.line_index)) |index| {
                var rect = &state.rects.items[index];
                rect.target_min = target.min;
                rect.target_max = target.max;
                rect.target_alpha = 1.0;
                rect.target_scale_y = 1.0;
                rect.grow_anchor_target = textSelectionRectCenter(target.min, target.max);
                rect.matched = true;
            } else {
                const anchor = textSelectionGrowthAnchorFromNeighbors(target, state.rects.items);
                var start_min: ByteVec2 = .{};
                var start_max: ByteVec2 = .{};
                textSelectionEdgeRectFromAnchor(target.min, target.max, anchor, &start_min, &start_max);
                state.rects.append(allocator, .{
                    .line_index = target.line_index,
                    .current_min = start_min,
                    .current_max = start_max,
                    .target_min = target.min,
                    .target_max = target.max,
                    .alpha = 0.0,
                    .target_alpha = 1.0,
                    .scale_y = 1.0,
                    .target_scale_y = 1.0,
                    .corner_round = [_]f32{ 1.0, 1.0, 1.0, 1.0 },
                    .target_corner_round = [_]f32{ 1.0, 1.0, 1.0, 1.0 },
                    .grow_anchor_current = textSelectionRectCenter(start_min, start_max),
                    .grow_anchor_target = textSelectionRectCenter(start_min, start_max),
                    .matched = true,
                }) catch {};
            }
        }

        for (state.rects.items) |*rect| {
            if (!rect.matched) {
                const collapse_point = textSelectionCollapseAnchorFromTargets(rect.*, targets);
                var collapse_min: ByteVec2 = .{};
                var collapse_max: ByteVec2 = .{};
                textSelectionEdgeRectFromAnchor(rect.target_min, rect.target_max, collapse_point, &collapse_min, &collapse_max);
                rect.target_min = collapse_min;
                rect.target_max = collapse_max;
                rect.target_alpha = 0.0;
                rect.target_scale_y = 1.0;
                rect.target_corner_round = [_]f32{ 1.0, 1.0, 1.0, 1.0 };
                rect.grow_anchor_target = textSelectionRectCenter(rect.target_min, rect.target_max);
            }
        }
    }

    const move_t = textSelectionSmoothFactor(dt, 24.0);
    const alpha_t = textSelectionSmoothFactor(dt, 14.0);
    const stretch_t = textSelectionSmoothFactor(dt, 18.0);
    const corner_t = textSelectionSmoothFactor(dt, 28.0);

    var i: usize = 0;
    while (i < state.rects.items.len) : (i += 1) {
        var rect = &state.rects.items[i];
        rect.current_min.x = textSelectionApproach(rect.current_min.x, rect.target_min.x, move_t);
        rect.current_min.y = textSelectionApproach(rect.current_min.y, rect.target_min.y, move_t);
        rect.current_max.x = textSelectionApproach(rect.current_max.x, rect.target_max.x, move_t);
        rect.current_max.y = textSelectionApproach(rect.current_max.y, rect.target_max.y, move_t);
        rect.grow_anchor_current.x = textSelectionApproach(rect.grow_anchor_current.x, rect.grow_anchor_target.x, move_t);
        rect.grow_anchor_current.y = textSelectionApproach(rect.grow_anchor_current.y, rect.grow_anchor_target.y, move_t);
        rect.alpha = textSelectionApproach(rect.alpha, rect.target_alpha, alpha_t);
        rect.scale_y = textSelectionApproach(rect.scale_y, rect.target_scale_y, stretch_t);
    }

    i = 0;
    while (i < state.rects.items.len) : (i += 1) {
        const corner_target = textSelectionCornerRoundFromCurrentGeometry(state.rects.items, i, corner_radius);
        var rect = &state.rects.items[i];
        rect.target_corner_round = corner_target;
        for (0..4) |corner_index| {
            rect.corner_round[corner_index] = textSelectionApproach(rect.corner_round[corner_index], rect.target_corner_round[corner_index], corner_t);
        }
    }

    i = 0;
    while (i < state.rects.items.len) {
        const rect = state.rects.items[i];
        if (rect.target_alpha <= 0.0 and rect.alpha < 0.015) {
            _ = state.rects.orderedRemove(i);
            continue;
        }
        i += 1;
    }

    storeTextSelectionStateRange(state, selection);
}

fn selectionIntervalsTouchOrOverlap(a0: f32, a1: f32, b0: f32, b1: f32, epsilon: f32) bool {
    return @min(a1, b1) >= @max(a0, b0) - epsilon;
}

fn selectionIntervalContainsPoint(a0: f32, a1: f32, point: f32, epsilon: f32) bool {
    return point >= a0 - epsilon and point <= a1 + epsilon;
}

fn clearSelectionCornerFlags(flags: *u8, mask: u8) void {
    flags.* &= ByteDrawCornerFlags_All ^ mask;
}

fn textSelectionCornerFlags(rects: []const TextSelectionHighlightRect, index: usize) u8 {
    var flags = ByteDrawCornerFlags_All;
    const rect = rects[index];
    if (@max(rect.alpha, rect.target_alpha) <= 0.01) return flags;

    const epsilon: f32 = 0.75;
    for (rects, 0..) |other, other_index| {
        if (other_index == index or @max(other.alpha, other.target_alpha) <= 0.01) continue;

        if (@abs(other.target_max.y - rect.target_min.y) <= epsilon and
            selectionIntervalsTouchOrOverlap(rect.target_min.x, rect.target_max.x, other.target_min.x, other.target_max.x, epsilon))
        {
            if (selectionIntervalContainsPoint(other.target_min.x, other.target_max.x, rect.target_min.x, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_TopLeft);
            }
            if (selectionIntervalContainsPoint(other.target_min.x, other.target_max.x, rect.target_max.x, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_TopRight);
            }
        }

        if (@abs(other.target_min.y - rect.target_max.y) <= epsilon and
            selectionIntervalsTouchOrOverlap(rect.target_min.x, rect.target_max.x, other.target_min.x, other.target_max.x, epsilon))
        {
            if (selectionIntervalContainsPoint(other.target_min.x, other.target_max.x, rect.target_min.x, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_BottomLeft);
            }
            if (selectionIntervalContainsPoint(other.target_min.x, other.target_max.x, rect.target_max.x, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_BottomRight);
            }
        }

        if (@abs(other.target_max.x - rect.target_min.x) <= epsilon and
            selectionIntervalsTouchOrOverlap(rect.target_min.y, rect.target_max.y, other.target_min.y, other.target_max.y, epsilon))
        {
            if (selectionIntervalContainsPoint(other.target_min.y, other.target_max.y, rect.target_min.y, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_TopLeft);
            }
            if (selectionIntervalContainsPoint(other.target_min.y, other.target_max.y, rect.target_max.y, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_BottomLeft);
            }
        }

        if (@abs(other.target_min.x - rect.target_max.x) <= epsilon and
            selectionIntervalsTouchOrOverlap(rect.target_min.y, rect.target_max.y, other.target_min.y, other.target_max.y, epsilon))
        {
            if (selectionIntervalContainsPoint(other.target_min.y, other.target_max.y, rect.target_min.y, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_TopRight);
            }
            if (selectionIntervalContainsPoint(other.target_min.y, other.target_max.y, rect.target_max.y, epsilon)) {
                clearSelectionCornerFlags(&flags, ByteDrawCornerFlags_BottomRight);
            }
        }
    }
    return flags;
}

const TextSelectionClipRect = struct {
    min: ByteVec2,
    max: ByteVec2,
};

fn appendTextSelectionClipRect(rects: *std.ArrayListUnmanaged(TextSelectionClipRect), min: ByteVec2, max: ByteVec2) void {
    if (max.x <= min.x + 0.01 or max.y <= min.y + 0.01) return;
    rects.append(allocator, .{ .min = min, .max = max }) catch {};
}

fn subtractTextSelectionClipRect(pieces: *std.ArrayListUnmanaged(TextSelectionClipRect), cover: TextSelectionClipRect) void {
    var i: usize = 0;
    while (i < pieces.items.len) {
        const piece = pieces.items[i];
        const ix0 = @max(piece.min.x, cover.min.x);
        const iy0 = @max(piece.min.y, cover.min.y);
        const ix1 = @min(piece.max.x, cover.max.x);
        const iy1 = @min(piece.max.y, cover.max.y);

        if (ix1 <= ix0 + 0.01 or iy1 <= iy0 + 0.01) {
            i += 1;
            continue;
        }

        _ = pieces.orderedRemove(i);

        appendTextSelectionClipRect(pieces, piece.min, .{ .x = piece.max.x, .y = iy0 });
        appendTextSelectionClipRect(pieces, .{ .x = piece.min.x, .y = iy1 }, piece.max);
        appendTextSelectionClipRect(pieces, .{ .x = piece.min.x, .y = iy0 }, .{ .x = ix0, .y = iy1 });
        appendTextSelectionClipRect(pieces, .{ .x = ix1, .y = iy0 }, .{ .x = piece.max.x, .y = iy1 });
    }
}

fn buildTextSelectionRoundedRectPolygonRadii(p_min: ByteVec2, p_max: ByteVec2, rounding_tl: f32, rounding_tr: f32, rounding_br: f32, rounding_bl: f32) ByteVec2List {
    var points: ByteVec2List = .empty;
    if (p_max.x <= p_min.x or p_max.y <= p_min.y) return points;

    const max_rounding = @min((p_max.x - p_min.x) * 0.5, (p_max.y - p_min.y) * 0.5);
    const radius_tl = std.math.clamp(rounding_tl, 0.0, max_rounding);
    const radius_tr = std.math.clamp(rounding_tr, 0.0, max_rounding);
    const radius_br = std.math.clamp(rounding_br, 0.0, max_rounding);
    const radius_bl = std.math.clamp(rounding_bl, 0.0, max_rounding);

    if (radius_tl <= 0.05 and radius_tr <= 0.05 and radius_br <= 0.05 and radius_bl <= 0.05) {
        points.ensureTotalCapacity(allocator, 4) catch return .empty;
        points.appendAssumeCapacity(p_min);
        points.appendAssumeCapacity(.{ .x = p_max.x, .y = p_min.y });
        points.appendAssumeCapacity(p_max);
        points.appendAssumeCapacity(.{ .x = p_min.x, .y = p_max.y });
        return points;
    }

    if (radius_tl > 0.05) {
        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(radius_tl), 4));
        appendArc(&points, .{ .x = p_min.x + radius_tl, .y = p_min.y + radius_tl }, radius_tl, kPi, kPi * 1.5, segments);
    } else points.append(allocator, p_min) catch return points;

    if (radius_tr > 0.05) {
        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(radius_tr), 4));
        appendArc(&points, .{ .x = p_max.x - radius_tr, .y = p_min.y + radius_tr }, radius_tr, kPi * 1.5, kPi * 2.0, segments);
    } else points.append(allocator, .{ .x = p_max.x, .y = p_min.y }) catch return points;

    if (radius_br > 0.05) {
        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(radius_br), 4));
        appendArc(&points, .{ .x = p_max.x - radius_br, .y = p_max.y - radius_br }, radius_br, 0.0, kPi * 0.5, segments);
    } else points.append(allocator, p_max) catch return points;

    if (radius_bl > 0.05) {
        const segments = @max(@as(i32, 3), @divTrunc(calcCircleSegmentCount(radius_bl), 4));
        appendArc(&points, .{ .x = p_min.x + radius_bl, .y = p_max.y - radius_bl }, radius_bl, kPi * 0.5, kPi, segments);
    } else points.append(allocator, .{ .x = p_min.x, .y = p_max.y }) catch return points;

    return points;
}

fn textSelectionClipForPiece(draw: *const ByteDrawList, p_min: ByteVec2, p_max: ByteVec2) ?ByteVec4 {
    const current = draw.CurrentClipRect;
    const clip = ByteVec4{
        .x = @max(current.x, p_min.x),
        .y = @max(current.y, p_min.y),
        .z = @min(current.z, p_max.x),
        .w = @min(current.w, p_max.y),
    };
    if (clip.z <= clip.x or clip.w <= clip.y) return null;
    return clip;
}

fn textSelectionEffectiveRadius(radius: f32) f32 {
    return @max(radius * 1.75, radius + 1.5);
}

fn textSelectionColorWithAlphaScale(col: ByteU32, scale: f32) ByteU32 {
    const alpha: ByteU32 = (col >> 24) & 0xFF;
    const scaled_alpha: ByteU32 = @intFromFloat(@as(f32, @floatFromInt(alpha)) * std.math.clamp(scale, 0.0, 1.0) + 0.5);
    return (col & ~BYTEGUI_COL32_A_MASK) | (@as(ByteU32, @min(scaled_alpha, @as(ByteU32, 0xFF))) << @as(u5, 24));
}

fn drawTextSelectionCornerAAFringe(draw: *ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, clip_min: ByteVec2, clip_max: ByteVec2, corner_index: usize, radius: f32, col: ByteU32) void {
    if ((col & BYTEGUI_COL32_A_MASK) == 0 or radius <= 0.05) return;

    const old_clip = draw.CurrentClipRect;
    const clip = textSelectionClipForPiece(draw, clip_min, clip_max) orelse return;
    draw.SetClipRect(clip);
    defer draw.SetClipRect(old_clip);

    const aa_width: f32 = 1.15;
    const inner_radius = radius + 0.02;
    const outer_radius = radius + aa_width;
    const segments = @max(@as(i32, 6), @divTrunc(calcCircleSegmentCount(radius), 4));

    var center: ByteVec2 = .{};
    var a_min: f32 = 0.0;
    var a_max: f32 = 0.0;

    switch (corner_index) {
        0 => {
            center = .{ .x = p_min.x + radius, .y = p_min.y + radius };
            a_min = kPi;
            a_max = kPi * 1.5;
        },
        1 => {
            center = .{ .x = p_max.x - radius, .y = p_min.y + radius };
            a_min = kPi * 1.5;
            a_max = kPi * 2.0;
        },
        2 => {
            center = .{ .x = p_max.x - radius, .y = p_max.y - radius };
            a_min = 0.0;
            a_max = kPi * 0.5;
        },
        3 => {
            center = .{ .x = p_min.x + radius, .y = p_max.y - radius };
            a_min = kPi * 0.5;
            a_max = kPi;
        },
        else => return,
    }

    const inner_col = textSelectionColorWithAlphaScale(col, 0.58);
    const outer_col = col & ~BYTEGUI_COL32_A_MASK;
    const uv = ByteVec2{ .x = 0.5, .y = 0.5 };
    const base_idx: ByteDrawIdx = @intCast(draw.VtxBuffer.items.len);
    const idx_start = draw.IdxBuffer.items.len;

    var i: i32 = 0;
    while (i <= segments) : (i += 1) {
        const t = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments));
        const a = a_min + (a_max - a_min) * t;
        const dir = ByteVec2{ .x = @cos(a), .y = @sin(a) };
        draw.addVertex(.{ .x = center.x + dir.x * inner_radius, .y = center.y + dir.y * inner_radius }, uv, inner_col) catch return;
        draw.addVertex(.{ .x = center.x + dir.x * outer_radius, .y = center.y + dir.y * outer_radius }, uv, outer_col) catch return;
    }

    i = 0;
    while (i < segments) : (i += 1) {
        const inner0 = base_idx + @as(ByteDrawIdx, @intCast(i * 2));
        const outer0 = inner0 + 1;
        const inner1 = base_idx + @as(ByteDrawIdx, @intCast((i + 1) * 2));
        const outer1 = inner1 + 1;
        draw.addTriangleIndices(inner0, inner1, outer0) catch return;
        draw.addTriangleIndices(outer0, inner1, outer1) catch return;
    }

    draw.addPrimitive(draw.WhiteTexture, @intCast(draw.IdxBuffer.items.len - idx_start)) catch return;
}

fn drawTextSelectionCornerAAFringes(draw: *ByteDrawList, p_min: ByteVec2, p_max: ByteVec2, clip_min: ByteVec2, clip_max: ByteVec2, col: ByteU32, rounding_tl: f32, rounding_tr: f32, rounding_br: f32, rounding_bl: f32) void {
    drawTextSelectionCornerAAFringe(draw, p_min, p_max, clip_min, clip_max, 0, rounding_tl, col);
    drawTextSelectionCornerAAFringe(draw, p_min, p_max, clip_min, clip_max, 1, rounding_tr, col);
    drawTextSelectionCornerAAFringe(draw, p_min, p_max, clip_min, clip_max, 2, rounding_br, col);
    drawTextSelectionCornerAAFringe(draw, p_min, p_max, clip_min, clip_max, 3, rounding_bl, col);
}

fn drawTextSelectionRectWithoutAlphaOverlap(draw: *ByteDrawList, covered: *std.ArrayListUnmanaged(TextSelectionClipRect), p_min: ByteVec2, p_max: ByteVec2, col: ByteU32, rounding_tl: f32, rounding_tr: f32, rounding_br: f32, rounding_bl: f32) void {
    if ((col & BYTEGUI_COL32_A_MASK) == 0 or p_max.x <= p_min.x or p_max.y <= p_min.y) return;

    var pieces: std.ArrayListUnmanaged(TextSelectionClipRect) = .empty;
    defer pieces.deinit(allocator);
    appendTextSelectionClipRect(&pieces, p_min, p_max);

    for (covered.items) |cover| {
        subtractTextSelectionClipRect(&pieces, cover);
        if (pieces.items.len == 0) return;
    }

    const core_rounding_tl = rounding_tl;
    const core_rounding_tr = rounding_tr;
    const core_rounding_br = rounding_br;
    const core_rounding_bl = rounding_bl;

    var core_shape = buildTextSelectionRoundedRectPolygonRadii(p_min, p_max, core_rounding_tl, core_rounding_tr, core_rounding_br, core_rounding_bl);
    defer core_shape.deinit(allocator);
    if (core_shape.items.len < 3) return;

    for (pieces.items) |piece| {
        var clip = ByteGUI.BuildRectPolygon(piece.min.x, piece.min.y, piece.max.x, piece.max.y);
        defer clip.deinit(allocator);
        var clipped = ByteGUI.ClipPolygonAgainstConvexPolygon(core_shape.items, clip.items);
        defer clipped.deinit(allocator);
        if (clipped.items.len >= 3) draw.AddConvexPolyFilled(clipped.items, col);
        drawTextSelectionCornerAAFringes(draw, p_min, p_max, piece.min, piece.max, col, rounding_tl, rounding_tr, rounding_br, rounding_bl);
        appendTextSelectionClipRect(covered, piece.min, piece.max);
    }
}

fn drawOneAnimatedTextSelectionRect(draw: *ByteDrawList, covered: *std.ArrayListUnmanaged(TextSelectionClipRect), params: TextSelectionHighlightParams, rect: TextSelectionHighlightRect) void {
    if (rect.alpha <= 0.01) return;

    var p_min = rect.current_min;
    var p_max = rect.current_max;
    if (p_max.x <= p_min.x or p_max.y <= p_min.y) return;

    p_min.x = roundToNearestPixel(p_min.x);
    p_min.y = roundToNearestPixel(p_min.y);
    p_max.x = roundToNearestPixel(p_max.x);
    p_max.y = roundToNearestPixel(p_max.y);
    if (p_max.x <= p_min.x or p_max.y <= p_min.y) return;

    const color = Ui.ColorToU32(Ui.ApplyOpacity(params.color, params.opacity * rect.alpha));
    const radius = textSelectionEffectiveRadius(params.radius);
    drawTextSelectionRectWithoutAlphaOverlap(
        draw,
        covered,
        p_min,
        p_max,
        color,
        radius * std.math.clamp(rect.corner_round[0], 0.0, 1.0),
        radius * std.math.clamp(rect.corner_round[1], 0.0, 1.0),
        radius * std.math.clamp(rect.corner_round[2], 0.0, 1.0),
        radius * std.math.clamp(rect.corner_round[3], 0.0, 1.0),
    );
}

fn drawAnimatedTextSelectionRects(draw: *ByteDrawList, state: *const TextSelectionHighlightState, params: TextSelectionHighlightParams) void {
    const old_flags = draw.Flags;
    draw.Flags &= ~ByteDrawListFlags_AntiAliasedFill;
    defer draw.Flags = old_flags;

    var covered: std.ArrayListUnmanaged(TextSelectionClipRect) = .empty;
    defer covered.deinit(allocator);

    for (state.rects.items) |rect| {
        if (!rect.matched) continue;
        drawOneAnimatedTextSelectionRect(draw, &covered, params, rect);
    }
    for (state.rects.items) |rect| {
        if (rect.matched) continue;
        drawOneAnimatedTextSelectionRect(draw, &covered, params, rect);
    }
}

fn drawTextSelectionHighlight(draw: ?*ByteDrawList, state: *TextSelectionHighlightState, params: TextSelectionHighlightParams) void {
    const active_draw = draw orelse return;
    const selection = normalizedTextSelectionRange(params.selection, params.text.len);
    var targets: std.ArrayListUnmanaged(TextSelectionHighlightTarget) = .empty;
    defer targets.deinit(allocator);
    if (!appendTextSelectionTargets(&targets, params)) return;
    syncTextSelectionHighlightState(state, selection, targets.items, params.dt, textSelectionEffectiveRadius(params.radius));
    drawAnimatedTextSelectionRects(active_draw, state, params);
}

fn calcVerticalScrollbarMetrics(params: VerticalScrollbarParams) ?ScrollbarMetrics {
    const max_scroll = @max(0.0, params.content_height - params.viewport_height);
    if (max_scroll <= 0.5 or params.track_size.x <= 0.0 or params.track_size.y <= 0.0) return null;

    const track_h = @max(1.0, params.track_size.y);
    const min_thumb_h = @min(track_h, @max(1.0, params.min_thumb_height));
    const thumb_h = std.math.clamp(track_h * (params.viewport_height / @max(params.viewport_height, params.content_height)), min_thumb_h, track_h);
    const range = @max(0.0, track_h - thumb_h);
    const thumb_y = params.track_pos.y + if (range > 0.0) (std.math.clamp(params.scroll_y, 0.0, max_scroll) / max_scroll) * range else 0.0;

    return .{
        .track_pos = params.track_pos,
        .track_size = .{ .x = params.track_size.x, .y = track_h },
        .thumb_pos = .{ .x = params.track_pos.x, .y = thumb_y },
        .thumb_size = .{ .x = params.track_size.x, .y = thumb_h },
        .max_scroll = max_scroll,
    };
}

fn pointInScrollbarThumb(metrics: ScrollbarMetrics, point: ByteVec2, hit_pad: f32) bool {
    return point.x >= metrics.thumb_pos.x - hit_pad and
        point.x < metrics.thumb_pos.x + metrics.thumb_size.x + hit_pad and
        point.y >= metrics.thumb_pos.y - hit_pad and
        point.y < metrics.thumb_pos.y + metrics.thumb_size.y + hit_pad;
}

fn scrollbarDragScroll(metrics: ScrollbarMetrics, start_scroll: f32, drag_delta: f32) f32 {
    const drag_range = @max(1.0, metrics.track_size.y - metrics.thumb_size.y);
    return start_scroll + (drag_delta / drag_range) * metrics.max_scroll;
}

fn updateScrollbarVisualState(state: *ScrollbarVisualState, hovered: bool, active: bool, dt: f32, fade_seconds: f32, hover_t: f32) void {
    const target: f32 = if (active) 1.0 else if (hovered) hover_t else 0.0;
    const step = if (fade_seconds > 0.0) @min(1.0, @max(0.0, dt) / fade_seconds) else 1.0;
    if (state.visual_t < target) {
        state.visual_t = @min(target, state.visual_t + step);
    } else {
        state.visual_t = @max(target, state.visual_t - step);
    }
}

fn updateScrollbarVisibilityState(state: *ScrollbarVisualState, visible: bool, dt: f32, fade_seconds: f32) void {
    const target: f32 = if (visible) 1.0 else 0.0;
    const step = if (fade_seconds > 0.0) @min(1.0, @max(0.0, dt) / fade_seconds) else 1.0;
    if (state.visibility_t < target) {
        state.visibility_t = @min(target, state.visibility_t + step);
    } else {
        state.visibility_t = @max(target, state.visibility_t - step);
    }
}

fn scrollbarSmoothFactor(dt: f32, rate: f32) f32 {
    return std.math.clamp(1.0 - @exp(-@max(0.0, dt) * rate), 0.0, 1.0);
}

fn scrollbarApproach(current: f32, target: f32, t: f32) f32 {
    return current + (target - current) * t;
}

fn updateScrollbarGeometryState(state: *ScrollbarVisualState, metrics: ScrollbarMetrics, visible: bool, active: bool, dt: f32, rate: f32, active_rate: f32) void {
    if (!visible and !state.has_geometry) return;

    if (!state.has_geometry or (visible and state.visibility_t <= 0.001)) {
        state.thumb_pos = metrics.thumb_pos;
        state.thumb_size = metrics.thumb_size;
        state.has_geometry = true;
        return;
    }

    if (!visible) return;

    const t = scrollbarSmoothFactor(dt, rate);
    if (active) {
        const active_t = scrollbarSmoothFactor(dt, active_rate);
        state.thumb_pos = .{
            .x = scrollbarApproach(state.thumb_pos.x, metrics.thumb_pos.x, active_t),
            .y = scrollbarApproach(state.thumb_pos.y, metrics.thumb_pos.y, active_t),
        };
        state.thumb_size = .{
            .x = scrollbarApproach(state.thumb_size.x, metrics.thumb_size.x, active_t),
            .y = scrollbarApproach(state.thumb_size.y, metrics.thumb_size.y, active_t),
        };
        return;
    }

    state.thumb_pos = .{
        .x = scrollbarApproach(state.thumb_pos.x, metrics.thumb_pos.x, t),
        .y = scrollbarApproach(state.thumb_pos.y, metrics.thumb_pos.y, t),
    };
    state.thumb_size = .{
        .x = scrollbarApproach(state.thumb_size.x, metrics.thumb_size.x, t),
        .y = scrollbarApproach(state.thumb_size.y, metrics.thumb_size.y, t),
    };
}

fn drawVerticalScrollbar(draw: ?*ByteDrawList, state: *ScrollbarVisualState, params: ScrollbarDrawParams) void {
    const active_draw = draw orelse return;
    const visible = params.visible or params.active;
    updateScrollbarVisualState(state, if (visible) params.hovered else false, params.active, params.dt, params.fade_seconds, params.hover_t);
    updateScrollbarVisibilityState(state, visible, params.dt, params.fade_seconds);
    updateScrollbarGeometryState(state, params.metrics, visible, params.active, params.dt, params.geometry_rate, params.active_geometry_rate);

    if (!state.has_geometry) return;
    if (!visible and state.visibility_t <= 0.001) {
        state.visibility_t = 0.0;
        state.has_geometry = false;
        return;
    }

    const hover_t = std.math.clamp(params.hover_t, 0.001, 0.999);
    const color = if (state.visual_t <= hover_t)
        Ui.LerpColor(params.idle_color, params.hover_color, state.visual_t / hover_t)
    else
        Ui.LerpColor(params.hover_color, params.active_color, (state.visual_t - hover_t) / (1.0 - hover_t));
    const col = Ui.ColorToU32(Ui.ApplyOpacity(color, params.opacity * state.visibility_t));
    if ((col & BYTEGUI_COL32_A_MASK) == 0) return;

    const p_min = ByteVec2{
        .x = roundToNearestPixel(state.thumb_pos.x),
        .y = roundToNearestPixel(state.thumb_pos.y),
    };
    const p_max = ByteVec2{
        .x = roundToNearestPixel(state.thumb_pos.x + state.thumb_size.x),
        .y = roundToNearestPixel(state.thumb_pos.y + state.thumb_size.y),
    };
    const size = ByteVec2{
        .x = @max(1.0, p_max.x - p_min.x),
        .y = @max(1.0, p_max.y - p_min.y),
    };
    const radius = @min(size.x, size.y) * 0.5;

    drawPixelRoundedRect(active_draw, p_min, size, radius, col);
}

fn roundedRectSignedDistance(pos: ByteVec2, size: ByteVec2, radius: f32, point: ByteVec2) f32 {
    const center = ByteVec2{ .x = pos.x + size.x * 0.5, .y = pos.y + size.y * 0.5 };
    const half = ByteVec2{ .x = size.x * 0.5, .y = size.y * 0.5 };
    const inner = ByteVec2{ .x = half.x - radius, .y = half.y - radius };
    const q = ByteVec2{
        .x = @abs(point.x - center.x) - inner.x,
        .y = @abs(point.y - center.y) - inner.y,
    };
    const outside = ByteVec2{ .x = @max(q.x, 0.0), .y = @max(q.y, 0.0) };
    return @sqrt(outside.x * outside.x + outside.y * outside.y) + @min(@max(q.x, q.y), 0.0) - radius;
}

fn drawPixelRoundedRect(draw: *ByteDrawList, pos: ByteVec2, size: ByteVec2, radius: f32, col: ByteU32) void {
    const corner_span = @min(@max(0.0, radius), @min(size.x, size.y) * 0.5);
    if (corner_span <= 0.0) {
        draw.AddRectFilled(pos, .{ .x = pos.x + size.x, .y = pos.y + size.y }, col, 0.0);
        return;
    }

    const width: i32 = @intFromFloat(@max(1.0, @round(size.x)));
    const height: i32 = @intFromFloat(@max(1.0, @round(size.y)));
    const ss: i32 = 4;
    const sample_count: i32 = ss * ss;
    const sample_scale = 1.0 / @as(f32, @floatFromInt(ss));
    const old_flags = draw.Flags;
    draw.Flags &= ~ByteDrawListFlags_AntiAliasedFill;
    defer draw.Flags = old_flags;

    var row: i32 = 0;
    while (row < height) : (row += 1) {
        var col_index: i32 = 0;
        while (col_index < width) : (col_index += 1) {
            var covered: i32 = 0;
            var sy: i32 = 0;
            while (sy < ss) : (sy += 1) {
                var sx: i32 = 0;
                while (sx < ss) : (sx += 1) {
                    const sample = ByteVec2{
                        .x = pos.x + @as(f32, @floatFromInt(col_index)) + (@as(f32, @floatFromInt(sx)) + 0.5) * sample_scale,
                        .y = pos.y + @as(f32, @floatFromInt(row)) + (@as(f32, @floatFromInt(sy)) + 0.5) * sample_scale,
                    };
                    if (roundedRectSignedDistance(pos, size, corner_span, sample) <= 0.0) covered += 1;
                }
            }
            if (covered == 0) continue;

            const coverage: u8 = @intCast(@divTrunc(covered * 255, sample_count));
            const pixel_col = applyCoverageToColor(col, coverage);
            draw.AddRectFilled(
                .{ .x = pos.x + @as(f32, @floatFromInt(col_index)), .y = pos.y + @as(f32, @floatFromInt(row)) },
                .{ .x = pos.x + @as(f32, @floatFromInt(col_index + 1)), .y = pos.y + @as(f32, @floatFromInt(row + 1)) },
                pixel_col,
                0.0,
            );
        }
    }
}

const BuiltTextTexture = struct {
    texture: ByteTextureID,
    display_size_px: ByteVec2,
    content_size_px: ByteVec2,
    draw_offset_px: ByteVec2,
    uv_min: ByteVec2,
    uv_max: ByteVec2,
};

const TextureFilter = enum {
    nearest,
    linear,
};

const RasterizedTextImage = struct {
    rgba: []u8,
    pixel_w: u32,
    pixel_h: u32,
    display_size_px: ByteVec2,
    content_size_px: ByteVec2,
    content_origin_px: ByteVec2,
    draw_offset_px: ByteVec2,
    uv_min: ByteVec2,
    uv_max: ByteVec2,

    fn deinit(self: *RasterizedTextImage) void {
        if (self.rgba.len > 0) allocator.free(self.rgba);
        self.* = undefined;
    }
};

fn roundToNearestPixel(value: f32) f32 {
    return @floor(value + 0.5);
}

fn textSupersampleForFont(font: *const ByteFont) f32 {
    return @floatFromInt(textSupersampleForFontI(font));
}

fn textSupersampleForFontI(font: *const ByteFont) i32 {
    return @intCast(@max(@as(u32, 1), @max(font.OversampleH, font.OversampleV)));
}

fn snapTextPenX(font: *const ByteFont, pen_x: f32) f32 {
    return if (font.PixelSnapH) roundToNearestPixel(pen_x) else pen_x;
}

const TextGlyphPlacement = struct {
    origin_x: f32,
    shift_x: f32,
};

fn resolveTextGlyphPlacement(font: *const ByteFont, pen_x: f32) TextGlyphPlacement {
    if (font.PixelSnapH) {
        return .{
            .origin_x = roundToNearestPixel(pen_x),
            .shift_x = 0.0,
        };
    }

    const origin_x = @floor(pen_x);
    return .{
        .origin_x = origin_x,
        .shift_x = pen_x - origin_x,
    };
}

fn fontConfigOversample(value: i32) u32 {
    return @intCast(std.math.clamp(value, 1, 8));
}

fn nextCodepointValue(text: []const u8, index: *usize) u32 {
    const start = index.*;
    if (start >= text.len) return 0;

    const cp_len = std.unicode.utf8ByteSequenceLength(text[start]) catch 1;
    const end = @min(text.len, start + cp_len);
    index.* = end;
    return std.unicode.utf8Decode(text[start..end]) catch 0xFFFD;
}

fn readFileAllocAbsoluteOrRelative(path: []const u8, max_bytes: usize) ![]u8 {
    var threaded: std.Io.Threaded = .init(allocator, .{});
    defer threaded.deinit();

    const io = threaded.io();
    return try std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(max_bytes));
}

fn computeTextBounds(font: *const ByteFont, size_pixels: f32, text: []const u8) TextBounds {
    if (text.len == 0) return .{};

    const face = @constCast(&font.ByteTypeFace);
    var pen_x: f32 = 0.0;
    var min_x: f32 = 0.0;
    var min_y: f32 = 0.0;
    var max_x: f32 = 0.0;
    var max_y: f32 = 0.0;
    var have_bounds = false;
    var prev_glyph: ?u32 = null;
    var i: usize = 0;
    while (i < text.len) {
        const cp = nextCodepointValue(text, &i);
        if (cp == '\r' or cp == '\n') continue;

        const glyph_index = face.getGlyphIndex(cp);

        if (prev_glyph) |prev| {
            pen_x += face.getKerningPx(prev, glyph_index, size_pixels);
        }

        const placement = resolveTextGlyphPlacement(font, pen_x);
        const glyph_bounds = face.loadGlyphBounds(glyph_index, size_pixels, placement.shift_x, 0.0) orelse bt.GlyphBounds{};
        if (glyph_bounds.x_max > glyph_bounds.x_min and glyph_bounds.y_max > glyph_bounds.y_min) {
            const gx0 = placement.origin_x + glyph_bounds.x_min;
            const gy0 = -glyph_bounds.y_max;
            const gx1 = placement.origin_x + glyph_bounds.x_max;
            const gy1 = -glyph_bounds.y_min;
            if (!have_bounds) {
                min_x = gx0;
                min_y = gy0;
                max_x = gx1;
                max_y = gy1;
                have_bounds = true;
            } else {
                min_x = @min(min_x, gx0);
                min_y = @min(min_y, gy0);
                max_x = @max(max_x, gx1);
                max_y = @max(max_y, gy1);
            }
        }

        pen_x += glyph_bounds.advance_x;
        prev_glyph = glyph_index;
    }

    if (!have_bounds) {
        return .{ .Width = pen_x };
    }

    return .{
        .X = min_x,
        .Y = min_y,
        .Width = @max(max_x, pen_x) - min_x,
        .Height = max_y - min_y,
    };
}

fn addFontFromFile(self: *ByteFontAtlas, file_path: []const u8, size_pixels: f32, font_cfg: ?*const ByteFontConfig) ?*ByteFont {
    const font_data = readFileAllocAbsoluteOrRelative(file_path, 64 * 1024 * 1024) catch return null;
    errdefer allocator.free(font_data);

    return initOwnedFont(self, font_data, file_path, size_pixels, font_cfg);
}

fn addFontFromMemory(self: *ByteFontAtlas, font_data: []const u8, debug_name: []const u8, size_pixels: f32, font_cfg: ?*const ByteFontConfig) ?*ByteFont {
    const owned_font_data = allocator.dupe(u8, font_data) catch return null;
    errdefer allocator.free(owned_font_data);

    return initOwnedFont(self, owned_font_data, debug_name, size_pixels, font_cfg);
}

fn initOwnedFont(self: *ByteFontAtlas, owned_font_data: []u8, debug_name: []const u8, size_pixels: f32, font_cfg: ?*const ByteFontConfig) ?*ByteFont {
    errdefer allocator.free(owned_font_data);

    const debug_name_copy = allocator.dupe(u8, debug_name) catch return null;
    errdefer allocator.free(debug_name_copy);

    const font = allocator.create(ByteFont) catch return null;
    errdefer allocator.destroy(font);

    font.* = .{
        .LegacySize = size_pixels,
        .FilePath = debug_name_copy,
        .FontStyle = detectFontStyleFromPath(debug_name),
        .PixelSnapH = if (font_cfg) |cfg| cfg.PixelSnapH else false,
        .OversampleH = if (font_cfg) |cfg| fontConfigOversample(cfg.OversampleH) else 1,
        .OversampleV = if (font_cfg) |cfg| fontConfigOversample(cfg.OversampleV) else 1,
        .FontData = owned_font_data,
    };

    font.ByteTypeFace = bt.FontFace.init(font.FontData, 0) orelse return null;

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
    const bounds = if (line_text.len > 0) session.measureBounds(line_text) else TextBounds{};

    try result.lines.append(allocator, .{
        .start = start,
        .end = end,
        .width = line_width,
        .bounds = bounds,
    });

    const line_index = result.lines.items.len - 1;
    const line_y = @as(f32, @floatFromInt(line_index)) * result.line_height;
    result.width = @max(result.width, bounds.Width);
    result.height = @max(result.height, line_y + result.line_height);
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
    result.ascender = session.ascender_px;

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

fn measureTextWithRasterizer(font: *const ByteFont, size_pixels: f32, text: []const u8, wrap_width: f32) ByteVec2 {
    const supersample = textSupersampleForFont(font);
    var layout = layoutText(font, size_pixels * supersample, text, if (wrap_width > 0.0) wrap_width * supersample else 0.0) orelse return .{};
    defer layout.deinit();
    return .{ .x = layout.width / supersample, .y = layout.height / supersample };
}

fn textRenderInsetPx(font: *const ByteFont, size_pixels: f32) f32 {
    _ = font;
    _ = size_pixels;
    return 0.0;
}

const TextRasterRegion = struct {
    draw_offset_px: ByteVec2,
    draw_size_px: ByteVec2,
    uv_min: ByteVec2,
    uv_max: ByteVec2,
};

fn textRasterGuardPixels(display_scale: f32) i32 {
    return @max(1, @as(i32, @intFromFloat(@ceil(2.0 / @max(display_scale, 0.001)))));
}

fn computeTextRasterRegion(rgba: []const u8, pixel_w: u32, pixel_h: u32, content_origin_px: ByteVec2, content_size_tex_px: ByteVec2, display_scale: f32) TextRasterRegion {
    const pixel_w_i: i32 = @intCast(pixel_w);
    const pixel_h_i: i32 = @intCast(pixel_h);
    const pixel_w_f = @as(f32, @floatFromInt(pixel_w));
    const pixel_h_f = @as(f32, @floatFromInt(pixel_h));

    var min_x = std.math.clamp(@as(i32, @intFromFloat(@floor(content_origin_px.x))), 0, pixel_w_i);
    var min_y = std.math.clamp(@as(i32, @intFromFloat(@floor(content_origin_px.y))), 0, pixel_h_i);
    var max_x = std.math.clamp(@as(i32, @intFromFloat(@ceil(content_origin_px.x + content_size_tex_px.x))), min_x, pixel_w_i);
    var max_y = std.math.clamp(@as(i32, @intFromFloat(@ceil(content_origin_px.y + content_size_tex_px.y))), min_y, pixel_h_i);

    if (computeRgbaAlphaBounds(rgba, pixel_w, pixel_h)) |bounds| {
        min_x = @min(min_x, @as(i32, @intCast(bounds.min_x)));
        min_y = @min(min_y, @as(i32, @intCast(bounds.min_y)));
        max_x = @max(max_x, @as(i32, @intCast(bounds.max_x)));
        max_y = @max(max_y, @as(i32, @intCast(bounds.max_y)));
    }

    const guard = textRasterGuardPixels(display_scale);
    min_x = std.math.clamp(min_x - guard, 0, pixel_w_i);
    min_y = std.math.clamp(min_y - guard, 0, pixel_h_i);
    max_x = std.math.clamp(max_x + guard, min_x, pixel_w_i);
    max_y = std.math.clamp(max_y + guard, min_y, pixel_h_i);
    if (max_x <= min_x) max_x = @min(pixel_w_i, min_x + 1);
    if (max_y <= min_y) max_y = @min(pixel_h_i, min_y + 1);

    const min_x_f = @as(f32, @floatFromInt(min_x));
    const min_y_f = @as(f32, @floatFromInt(min_y));
    const max_x_f = @as(f32, @floatFromInt(max_x));
    const max_y_f = @as(f32, @floatFromInt(max_y));
    return .{
        .draw_offset_px = .{
            .x = (min_x_f - content_origin_px.x) * display_scale,
            .y = (min_y_f - content_origin_px.y) * display_scale,
        },
        .draw_size_px = .{
            .x = (max_x_f - min_x_f) * display_scale,
            .y = (max_y_f - min_y_f) * display_scale,
        },
        .uv_min = .{
            .x = std.math.clamp(min_x_f / pixel_w_f, 0.0, 1.0),
            .y = std.math.clamp(min_y_f / pixel_h_f, 0.0, 1.0),
        },
        .uv_max = .{
            .x = std.math.clamp(max_x_f / pixel_w_f, 0.0, 1.0),
            .y = std.math.clamp(max_y_f / pixel_h_f, 0.0, 1.0),
        },
    };
}

fn blendGlyphCoverageIntoRgba(rgba: []u8, buffer_width: u32, buffer_height: u32, glyph: []const u8, glyph_w: usize, glyph_h: usize, dst_x: i32, dst_y: i32, rgb_value: u8) void {
    for (0..glyph_h) |row| {
        const y = dst_y + @as(i32, @intCast(row));
        if (y < 0 or y >= @as(i32, @intCast(buffer_height))) continue;

        for (0..glyph_w) |col| {
            const x = dst_x + @as(i32, @intCast(col));
            if (x < 0 or x >= @as(i32, @intCast(buffer_width))) continue;

            const src_a: u32 = glyph[row * glyph_w + col];
            if (src_a == 0) continue;

            const dst_index = (@as(usize, @intCast(y)) * @as(usize, buffer_width) + @as(usize, @intCast(x))) * 4;
            const dst_a: u32 = rgba[dst_index + 3];
            const out_a = src_a + @divTrunc(dst_a * (255 - src_a), 255);
            rgba[dst_index + 0] = rgb_value;
            rgba[dst_index + 1] = rgb_value;
            rgba[dst_index + 2] = rgb_value;
            rgba[dst_index + 3] = @intCast(@min(out_a, 255));
        }
    }
}

fn rasterizeTextLineIntoRgba(rgba: []u8, pixel_w: u32, pixel_h: u32, session: *const TextMeasureSession, line_text: []const u8, line_bounds: TextBounds, line_y: f32, pad_px: i32, rgb_value: u8) bool {
    const face = @constCast(&session.font.ByteTypeFace);
    var pen_x = @as(f32, @floatFromInt(pad_px)) - line_bounds.X;
    const baseline_y = @as(f32, @floatFromInt(pad_px)) + line_y + session.ascender_px;
    const baseline_y_floor = @floor(baseline_y);
    const baseline_y_px: i32 = @intFromFloat(baseline_y_floor);
    const shift_y = baseline_y - baseline_y_floor;

    var prev_glyph: ?u32 = null;
    var i: usize = 0;
    while (i < line_text.len) {
        const cp = nextCodepointValue(line_text, &i);
        if (cp == '\r' or cp == '\n') continue;

        const glyph_index = face.getGlyphIndex(cp);

        if (prev_glyph) |prev| {
            pen_x += face.getKerningPx(prev, glyph_index, session.size_pixels);
        }

        const placement = resolveTextGlyphPlacement(session.font, pen_x);
        const pen_x_px: i32 = @intFromFloat(placement.origin_x);
        var rendered = face.renderGlyph(allocator, glyph_index, session.size_pixels, placement.shift_x, shift_y) orelse return false;
        defer rendered.deinit(allocator);
        if (rendered.width > 0 and rendered.height > 0) {
            const dst_x = pen_x_px + rendered.left;
            const dst_y = baseline_y_px - rendered.top;
            blendGlyphCoverageIntoRgba(rgba, pixel_w, pixel_h, rendered.pixels, rendered.width, rendered.height, dst_x, dst_y, rgb_value);
        }

        const advance_bounds = face.loadGlyphBounds(glyph_index, session.size_pixels, placement.shift_x, shift_y) orelse bt.GlyphBounds{};
        pen_x += advance_bounds.advance_x;
        prev_glyph = glyph_index;
    }

    return true;
}

fn rasterizeTextImageFromFont(font: *const ByteFont, size_pixels: f32, text: []const u8, supersample: f32, pad_scale: f32, wrap_width: f32, layout_scale: f32, rgb_value: u8) ?RasterizedTextImage {
    if (size_pixels <= 0.0 or text.len == 0) return null;
    const raster_size = size_pixels * supersample;
    const effective_wrap = if (wrap_width > 0.0) wrap_width * supersample else 0.0;
    var layout = layoutText(font, raster_size, text, effective_wrap) orelse return null;
    defer layout.deinit();

    const align_to = @max(1, @as(i32, @intFromFloat(@round(supersample))));
    const raster_scale = ByteGUI_ImplWin32_GetDpiScale() * supersample;
    const pad_px = alignUpInt(@max(2, @as(i32, @intFromFloat(@ceil(raster_scale * pad_scale)))), align_to);
    const content_w = alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(layout.width)))), align_to);
    const tight_h: f32 = layout.height;
    const content_h = alignUpInt(@max(1, @as(i32, @intFromFloat(@ceil(tight_h)))), align_to);
    const pixel_w: u32 = @intCast(alignUpInt(@max(1, content_w + pad_px * 2), align_to));
    const pixel_h: u32 = @intCast(alignUpInt(@max(1, content_h + pad_px * 2), align_to));

    var session = TextMeasureSession.init(font, raster_size) orelse return null;
    defer session.deinit();

    const pixel_count = @as(usize, pixel_w) * @as(usize, pixel_h);
    const rgba = allocator.alloc(u8, pixel_count * 4) catch return null;
    for (0..pixel_count) |pixel_index| {
        const base = pixel_index * 4;
        rgba[base + 0] = rgb_value;
        rgba[base + 1] = rgb_value;
        rgba[base + 2] = rgb_value;
        rgba[base + 3] = 0;
    }

    for (layout.lines.items, 0..) |line, line_index| {
        const line_text = text[line.start..line.end];
        const line_y = @as(f32, @floatFromInt(line_index)) * layout.line_height;
        if (!rasterizeTextLineIntoRgba(rgba, pixel_w, pixel_h, &session, line_text, line.bounds, line_y, pad_px, rgb_value)) {
            allocator.free(rgba);
            return null;
        }
    }

    const pad_f = @as(f32, @floatFromInt(pad_px));

    const ss = @as(u32, @intFromFloat(@round(supersample)));
    if (ss > 1 and pixel_w >= ss and pixel_h >= ss) {
        const ds_w = pixel_w / ss;
        const ds_h = pixel_h / ss;
        const ds_count = @as(usize, ds_w) * @as(usize, ds_h);
        const ds_rgba = allocator.alloc(u8, ds_count * 4) catch {
            allocator.free(rgba);
            return null;
        };
        const src_stride = @as(usize, pixel_w) * 4;
        const dst_stride = @as(usize, ds_w) * 4;
        const ss_usize: usize = @intCast(ss);
        const divisor = ss_usize * ss_usize;
        for (0..@as(usize, ds_h)) |dy| {
            for (0..@as(usize, ds_w)) |dx| {
                var sum_r: u32 = 0;
                var sum_g: u32 = 0;
                var sum_b: u32 = 0;
                var sum_a: u32 = 0;
                for (0..ss_usize) |sy| {
                    for (0..ss_usize) |sx| {
                        const si = (dy * ss_usize + sy) * src_stride + (dx * ss_usize + sx) * 4;
                        sum_r += rgba[si + 0];
                        sum_g += rgba[si + 1];
                        sum_b += rgba[si + 2];
                        sum_a += rgba[si + 3];
                    }
                }
                const di = dy * dst_stride + dx * 4;
                ds_rgba[di + 0] = @intCast(sum_r / divisor);
                ds_rgba[di + 1] = @intCast(sum_g / divisor);
                ds_rgba[di + 2] = @intCast(sum_b / divisor);
                ds_rgba[di + 3] = @intCast(sum_a / divisor);
            }
        }
        allocator.free(rgba);

        const ds_pad_f = pad_f / @as(f32, @floatFromInt(ss));
        const ds_content_origin = ByteVec2{ .x = ds_pad_f, .y = ds_pad_f };
        const ds_layout_w = layout.width / supersample;
        const ds_tight_h = tight_h / supersample;
        const ds_region = computeTextRasterRegion(
            ds_rgba,
            ds_w,
            ds_h,
            ds_content_origin,
            .{ .x = ds_layout_w, .y = ds_tight_h },
            layout_scale,
        );

        return .{
            .rgba = ds_rgba,
            .pixel_w = ds_w,
            .pixel_h = ds_h,
            .display_size_px = ds_region.draw_size_px,
            .content_size_px = .{
                .x = ds_layout_w * layout_scale,
                .y = ds_tight_h * layout_scale,
            },
            .content_origin_px = ds_content_origin,
            .draw_offset_px = ds_region.draw_offset_px,
            .uv_min = ds_region.uv_min,
            .uv_max = ds_region.uv_max,
        };
    }

    const content_origin_px = ByteVec2{ .x = pad_f, .y = pad_f };
    const region = computeTextRasterRegion(
        rgba,
        pixel_w,
        pixel_h,
        content_origin_px,
        .{ .x = layout.width, .y = tight_h },
        layout_scale / supersample,
    );
    const content_size_px: ByteVec2 = .{
        .x = layout.width / supersample * layout_scale,
        .y = tight_h / supersample * layout_scale,
    };

    return .{
        .rgba = rgba,
        .pixel_w = pixel_w,
        .pixel_h = pixel_h,
        .display_size_px = region.draw_size_px,
        .content_size_px = content_size_px,
        .content_origin_px = content_origin_px,
        .draw_offset_px = region.draw_offset_px,
        .uv_min = region.uv_min,
        .uv_max = region.uv_max,
    };
}

fn buildTextTextureFromFont(font: *const ByteFont, size_pixels: f32, text: []const u8, supersample: f32, pad_scale: f32, wrap_width: f32, layout_scale: f32, rgb_value: u8, filter: TextureFilter) ?BuiltTextTexture {
    if (!ByteGUI_ImplOpenGL_HasContext()) return null;

    var raster = rasterizeTextImageFromFont(font, size_pixels, text, supersample, pad_scale, wrap_width, layout_scale, rgb_value) orelse return null;
    defer raster.deinit();

    const texture = createTextureFromRgbaAlphaMask(raster.rgba, raster.pixel_w, raster.pixel_h, filter) orelse return null;
    return .{
        .texture = texture,
        .display_size_px = raster.display_size_px,
        .content_size_px = raster.content_size_px,
        .draw_offset_px = raster.draw_offset_px,
        .uv_min = raster.uv_min,
        .uv_max = raster.uv_max,
    };
}

fn uploadRasterizedMaskTextureWithFilter(out_texture: *Ui.TextTexture, raster: *const Ui.RasterizedTexture, filter: TextureFilter) bool {
    Ui.CleanupTextTexture(out_texture);
    if (!ByteGUI_ImplOpenGL_HasContext() or raster.rgba.len == 0 or raster.pixel_w == 0 or raster.pixel_h == 0) return false;

    out_texture.texture = createTextureFromRgbaAlphaMask(raster.rgba, raster.pixel_w, raster.pixel_h, filter) orelse return false;
    out_texture.display_size_px = raster.display_size_px;
    out_texture.image_size_px = if (raster.image_size_px.x > 0.0 and raster.image_size_px.y > 0.0) raster.image_size_px else raster.display_size_px;
    out_texture.draw_offset_px = raster.draw_offset_px;
    out_texture.uv_min = raster.uv_min;
    out_texture.uv_max = raster.uv_max;
    return true;
}
fn textureIdFromHandle(handle: gl.GLuint) ByteTextureID {
    if (handle == 0) return null;
    return @ptrFromInt(handle);
}

fn textureHandleFromId(texture: ByteTextureID) gl.GLuint {
    return if (texture) |ptr| @intCast(@intFromPtr(ptr)) else 0;
}

fn releaseTexture(texture: ByteTextureID) void {
    const handle = textureHandleFromId(texture);
    if (handle == 0) return;
    const textures = [_]gl.GLuint{handle};
    gl.glDeleteTextures(1, &textures);
}

fn extractAlphaChannel(rgba: []const u8, width: u32, height: u32) ?[]u8 {
    if (width == 0 or height == 0) return null;
    const pixel_count = @as(usize, width) * @as(usize, height);
    if (rgba.len < pixel_count * 4) return null;

    const alpha = allocator.alloc(u8, pixel_count) catch return null;
    for (0..pixel_count) |pixel_index| alpha[pixel_index] = rgba[pixel_index * 4 + 3];
    return alpha;
}

fn createTextureFromRgbaAlphaMask(rgba: []const u8, width: u32, height: u32, filter: TextureFilter) ByteTextureID {
    const alpha = extractAlphaChannel(rgba, width, height) orelse return null;
    defer allocator.free(alpha);
    return createTextureFromAlpha(alpha, width, height, filter);
}

fn createTextureFromAlpha(alpha: []const u8, width: u32, height: u32, filter: TextureFilter) ByteTextureID {
    if (!ByteGUI_ImplOpenGL_HasContext() or width == 0 or height == 0 or alpha.len < @as(usize, width) * @as(usize, height)) return null;

    var textures = [_]gl.GLuint{0};
    gl.glGenTextures(1, &textures);
    const handle = textures[0];
    if (handle == 0) return null;

    gl.glBindTexture(gl.TEXTURE_2D, handle);
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    const gl_filter = switch (filter) {
        .nearest => gl.NEAREST,
        .linear => gl.LINEAR,
    };
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl_filter);
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl_filter);
    gl.glTexEnvi(gl.TEXTURE_ENV, gl.TEXTURE_ENV_MODE, gl.MODULATE);
    gl.glPixelStorei(gl.UNPACK_ALIGNMENT, 1);
    gl.glTexImage2D(gl.TEXTURE_2D, 0, @intCast(gl.ALPHA), @intCast(width), @intCast(height), 0, gl.ALPHA, gl.UNSIGNED_BYTE, alpha.ptr);
    return textureIdFromHandle(handle);
}

fn createTextureFromRGBA(pixels: []const u8, width: u32, height: u32, filter: TextureFilter) ByteTextureID {
    if (!ByteGUI_ImplOpenGL_HasContext() or width == 0 or height == 0) return null;

    var textures = [_]gl.GLuint{0};
    gl.glGenTextures(1, &textures);
    const handle = textures[0];
    if (handle == 0) return null;

    gl.glBindTexture(gl.TEXTURE_2D, handle);
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    const gl_filter = switch (filter) {
        .nearest => gl.NEAREST,
        .linear => gl.LINEAR,
    };
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl_filter);
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl_filter);
    gl.glTexEnvi(gl.TEXTURE_ENV, gl.TEXTURE_ENV_MODE, gl.MODULATE);
    gl.glPixelStorei(gl.UNPACK_ALIGNMENT, 1);
    gl.glTexImage2D(gl.TEXTURE_2D, 0, @intCast(gl.RGBA), @intCast(width), @intCast(height), 0, gl.RGBA, gl.UNSIGNED_BYTE, pixels.ptr);
    return textureIdFromHandle(handle);
}

fn clearTextCache() void {
    const ctx = GByteGUI orelse return;
    for (ctx.TextCache.items) |*entry| entry.deinit();
    ctx.TextCache.clearRetainingCapacity();
}

fn getOrCreateTextTexture(font_opt: ?*ByteFont, size_pixels: f32, wrap_width: f32, text: []const u8) ?*TextCacheEntry {
    return getOrCreateTextTextureWithFilter(font_opt, size_pixels, wrap_width, text, .nearest);
}

fn getOrCreateTextTextureWithFilter(font_opt: ?*ByteFont, size_pixels: f32, wrap_width: f32, text: []const u8, filter: TextureFilter) ?*TextCacheEntry {
    const ctx = GByteGUI orelse return null;
    const font = font_opt orelse return null;
    if (!ByteGUI_ImplOpenGL_HasContext() or text.len == 0) return null;

    const pixel_size100: i32 = @intFromFloat(@round(size_pixels * 100.0));
    const wrap_width100: i32 = @intFromFloat(@round(wrap_width * 100.0));
    for (ctx.TextCache.items) |*entry| {
        if (entry.Font == font and entry.PixelSize100 == pixel_size100 and entry.WrapWidth100 == wrap_width100 and entry.Filter == filter and std.mem.eql(u8, entry.Text, text)) {
            return entry;
        }
    }

    const built = buildTextTextureFromFont(font, size_pixels, text, textSupersampleForFont(font), 0.12, wrap_width, 1.0, 255, filter) orelse return null;
    const texture = built.texture;
    const text_copy = allocator.dupe(u8, text) catch {
        releaseTexture(texture);
        return null;
    };

    ctx.TextCache.append(allocator, .{
        .Font = font,
        .PixelSize100 = pixel_size100,
        .WrapWidth100 = wrap_width100,
        .Filter = filter,
        .Text = text_copy,
        .Texture = texture,
        .DisplaySize = built.content_size_px,
        .ImageSize = built.display_size_px,
        .DrawOffset = built.draw_offset_px,
        .UvMin = built.uv_min,
        .UvMax = built.uv_max,
    }) catch {
        allocator.free(text_copy);
        releaseTexture(texture);
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
    if (GByteGUI) |ctx| ctx.IO.DisplaySize = .{ .x = @floatFromInt(width), .y = @floatFromInt(height) };
}

fn getWin32BackendData() ?*MiniWin32BackendData {
    const ctx = GByteGUI orelse return null;
    return if (ctx.IO.BackendPlatformUserData) |ptr| @ptrCast(@alignCast(ptr)) else null;
}

fn getOpenGLBackendData() ?*MiniOpenGLBackendData {
    const ctx = GByteGUI orelse return null;
    return if (ctx.IO.BackendRendererUserData) |ptr| @ptrCast(@alignCast(ptr)) else null;
}

fn ensureWin32BackendData() bool {
    const ctx = GByteGUI orelse return false;
    if (getWin32BackendData() != null) return true;

    const bd = allocator.create(MiniWin32BackendData) catch return false;
    bd.* = .{};
    _ = c.QueryPerformanceFrequency(@ptrCast(&bd.TicksPerSecond));
    _ = c.QueryPerformanceCounter(@ptrCast(&bd.Time));
    ctx.IO.BackendPlatformUserData = bd;
    ctx.IO.BackendPlatformName = "bytegui_impl_win32_mini";
    return true;
}

fn ensureOpenGLBackendData() bool {
    const ctx = GByteGUI orelse return false;
    if (getOpenGLBackendData() != null) return true;

    const bd = allocator.create(MiniOpenGLBackendData) catch return false;
    bd.* = .{};
    ctx.IO.BackendRendererUserData = bd;
    ctx.IO.BackendRendererName = "bytegui_impl_opengl_legacy";
    return true;
}

fn createWhiteTexture() ByteTextureID {
    const pixel = [_]u8{ 255, 255, 255, 255 };
    return createTextureFromRGBA(pixel[0..], 1, 1, .nearest);
}

fn setupLegacyOpenGLState(draw_data: *const ByteDrawData) void {
    const viewport_w = @as(i32, @intFromFloat(draw_data.DisplaySize.x * draw_data.FramebufferScale.x));
    const viewport_h = @as(i32, @intFromFloat(draw_data.DisplaySize.y * draw_data.FramebufferScale.y));

    gl.glViewport(0, 0, viewport_w, viewport_h);
    gl.glDisable(gl.CULL_FACE);
    gl.glDisable(gl.DEPTH_TEST);
    gl.glDisable(gl.LIGHTING);
    gl.glEnable(gl.BLEND);
    if (g_glBlendFuncSeparate) |blendSeparate| {
        blendSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA, gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
    } else {
        gl.glBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    }
    gl.glEnable(gl.TEXTURE_2D);
    gl.glShadeModel(gl.SMOOTH);
    gl.glTexEnvi(gl.TEXTURE_ENV, gl.TEXTURE_ENV_MODE, gl.MODULATE);

    gl.glMatrixMode(gl.PROJECTION);
    gl.glLoadIdentity();
    gl.glOrtho(0.0, draw_data.DisplaySize.x, draw_data.DisplaySize.y, 0.0, -1.0, 1.0);
    gl.glMatrixMode(gl.MODELVIEW);
    gl.glLoadIdentity();
}

fn bindDrawListVertexArrays(draw_list: *const ByteDrawList) void {
    const base: [*]const u8 = @ptrCast(draw_list.VtxBuffer.items.ptr);
    const stride: gl.GLsizei = @sizeOf(ByteDrawVert);

    gl.glEnableClientState(gl.VERTEX_ARRAY);
    gl.glEnableClientState(gl.COLOR_ARRAY);
    gl.glEnableClientState(gl.TEXTURE_COORD_ARRAY);
    gl.glVertexPointer(2, gl.FLOAT, stride, @ptrCast(base + @offsetOf(ByteDrawVert, "pos")));
    gl.glTexCoordPointer(2, gl.FLOAT, stride, @ptrCast(base + @offsetOf(ByteDrawVert, "uv")));
    gl.glColorPointer(4, gl.UNSIGNED_BYTE, stride, @ptrCast(base + @offsetOf(ByteDrawVert, "col")));
}

fn unbindDrawListVertexArrays() void {
    gl.glDisableClientState(gl.TEXTURE_COORD_ARRAY);
    gl.glDisableClientState(gl.COLOR_ARRAY);
    gl.glDisableClientState(gl.VERTEX_ARRAY);
}

pub fn ByteGUI_ImplOpenGL_HasContext() bool {
    return if (getOpenGLBackendData()) |bd| bd.RenderContext != null else false;
}

pub fn ByteGUI_ImplOpenGL_Init(hwnd: ?c.HWND, width: c.UINT, height: c.UINT) bool {
    if (hwnd == null or width == 0 or height == 0) return false;

    setByteGUITrace("gl:init:start");
    if (getOpenGLBackendData() != null) ByteGUI_ImplOpenGL_Shutdown();
    if (!ensureOpenGLBackendData()) return false;
    const bd = getOpenGLBackendData().?;
    const native_hwnd: w32.HWND = @ptrFromInt(@intFromPtr(hwnd.?));
    const window_dc = w32.GetDC(native_hwnd) orelse return false;
    setByteGUITrace("gl:init:dc");

    var pfd = std.mem.zeroes(w32.PIXELFORMATDESCRIPTOR);
    pfd.nSize = @sizeOf(w32.PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = w32.PFD_DRAW_TO_WINDOW | w32.PFD_SUPPORT_OPENGL | w32.PFD_DOUBLEBUFFER;
    pfd.iPixelType = w32.PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    pfd.cAlphaBits = 8;
    pfd.cDepthBits = 24;
    pfd.cStencilBits = 8;
    pfd.iLayerType = w32.PFD_MAIN_PLANE;
    setByteGUITrace("gl:init:pfd");

    const pixel_format = w32.ChoosePixelFormat(window_dc, &pfd);
    if (pixel_format == 0 or w32.SetPixelFormat(window_dc, pixel_format, &pfd) == w32.FALSE) {
        _ = w32.ReleaseDC(native_hwnd, window_dc);
        return false;
    }
    setByteGUITrace("gl:init:pixel_format");

    const render_context = w32.wglCreateContext(window_dc) orelse {
        _ = w32.ReleaseDC(native_hwnd, window_dc);
        return false;
    };
    if (w32.wglMakeCurrent(window_dc, render_context) == w32.FALSE) {
        _ = w32.wglDeleteContext(render_context);
        _ = w32.ReleaseDC(native_hwnd, window_dc);
        return false;
    }
    g_glBlendFuncSeparate = @ptrCast(w32.wglGetProcAddress("glBlendFuncSeparate"));
    setByteGUITrace("gl:init:context");

    bd.WindowHwnd = native_hwnd;
    bd.WindowDc = window_dc;
    bd.RenderContext = render_context;
    bd.WhiteTexture = createWhiteTexture();
    setByteGUITrace("gl:init:white");
    if (bd.WhiteTexture == null) {
        ByteGUI_ImplOpenGL_Shutdown();
        return false;
    }

    updateHostWindowSizeState(@intCast(width), @intCast(height));
    setByteGUITrace("gl:init:done");
    return true;
}

pub fn ByteGUI_ImplOpenGL_Shutdown() void {
    const ctx = GByteGUI orelse return;
    const bd = getOpenGLBackendData() orelse return;

    clearTextCache();
    releaseTexture(bd.WhiteTexture);
    bd.WhiteTexture = null;

    if (bd.WindowDc != null and bd.RenderContext != null) _ = w32.wglMakeCurrent(null, null);
    if (bd.RenderContext) |render_context| {
        _ = w32.wglDeleteContext(render_context);
        bd.RenderContext = null;
    }
    if (bd.WindowDc) |window_dc| {
        if (bd.WindowHwnd) |window_hwnd| _ = w32.ReleaseDC(window_hwnd, window_dc);
        bd.WindowDc = null;
    }
    bd.WindowHwnd = null;

    allocator.destroy(bd);
    ctx.IO.BackendRendererUserData = null;
    ctx.IO.BackendRendererName = null;
    ctx.WhiteTexture = null;
}

fn clearOpenGLResizeSurface(width: c.UINT, height: c.UINT) void {
    const bd = getOpenGLBackendData() orelse return;
    const window_dc = bd.WindowDc orelse return;
    const render_context = bd.RenderContext orelse return;
    if (w32.wglMakeCurrent(window_dc, render_context) == w32.FALSE) return;

    gl.glViewport(0, 0, @intCast(width), @intCast(height));
    gl.glClearColor(0.0, 0.0, 0.0, 0.0);
    gl.glClear(gl.COLOR_BUFFER_BIT);
    _ = w32.SwapBuffers(window_dc);
    gl.glClear(gl.COLOR_BUFFER_BIT);
}

fn prepareOpenGLResizeSurface(width: i32, height: i32) void {
    if (width <= 0 or height <= 0) return;
    clearOpenGLResizeSurface(@intCast(width), @intCast(height));
}

pub fn ByteGUI_ImplOpenGL_Resize(width: c.UINT, height: c.UINT) void {
    if (width == 0 or height == 0) return;
    updateHostWindowSizeState(@intCast(width), @intCast(height));
    clearOpenGLResizeSurface(width, height);
}

pub fn ByteGUI_ImplOpenGL_BeginFrame(clear_color: *const [4]f32) bool {
    const bd = getOpenGLBackendData() orelse return false;
    if (bd.WindowDc == null or bd.RenderContext == null) return false;
    if (w32.wglMakeCurrent(bd.WindowDc, bd.RenderContext) == w32.FALSE) return false;

    gl.glClearColor(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);
    gl.glClear(gl.COLOR_BUFFER_BIT);
    return true;
}

pub fn ByteGUI_ImplOpenGL_Present() bool {
    const bd = getOpenGLBackendData() orelse return false;
    const window_dc = bd.WindowDc orelse return false;
    return w32.SwapBuffers(window_dc) != w32.FALSE;
}

pub fn ByteGUI_ImplOpenGL_NewFrame() void {
    const ctx = GByteGUI orelse return;
    const bd = getOpenGLBackendData() orelse return;
    ctx.WhiteTexture = bd.WhiteTexture;
}

pub fn ByteGUI_ImplOpenGL_RenderDrawData(draw_data: ?*ByteDrawData) void {
    const dd = draw_data orelse return;
    if (!dd.Valid or dd.DisplaySize.x <= 0.0 or dd.DisplaySize.y <= 0.0) return;

    const bd = getOpenGLBackendData() orelse return;
    if (bd.WindowDc == null or bd.RenderContext == null) return;

    setupLegacyOpenGLState(dd);

    const framebuffer_h = dd.DisplaySize.y * dd.FramebufferScale.y;
    for (dd.CmdLists.items) |draw_list| {
        if (draw_list.VtxBuffer.items.len == 0 or draw_list.IdxBuffer.items.len == 0) continue;
        bindDrawListVertexArrays(draw_list);
        defer unbindDrawListVertexArrays();

        for (draw_list.CmdBuffer.items) |cmd| {
            if (cmd.UserCallback) |cb| {
                cb(draw_list, &cmd);
                continue;
            }
            if (cmd.ElemCount == 0) continue;

            const clip_left = @max(cmd.ClipRect.x, 0.0);
            const clip_top = @max(cmd.ClipRect.y, 0.0);
            const clip_right = @max(cmd.ClipRect.z, clip_left);
            const clip_bottom = @max(cmd.ClipRect.w, clip_top);
            const clip_w = @as(i32, @intFromFloat(clip_right - clip_left));
            const clip_h = @as(i32, @intFromFloat(clip_bottom - clip_top));
            if (clip_w <= 0 or clip_h <= 0) continue;

            gl.glEnable(gl.SCISSOR_TEST);
            gl.glScissor(
                @intFromFloat(clip_left),
                @intFromFloat(framebuffer_h - clip_bottom),
                clip_w,
                clip_h,
            );

            gl.glBindTexture(gl.TEXTURE_2D, textureHandleFromId(cmd.TextureId));
            const idx_ptr: [*]const ByteDrawIdx = draw_list.IdxBuffer.items.ptr + @as(usize, cmd.IdxOffset);
            gl.glDrawElements(gl.TRIANGLES, @intCast(cmd.ElemCount), gl.UNSIGNED_INT, @ptrCast(idx_ptr));
        }
    }

    gl.glDisable(gl.SCISSOR_TEST);
}

pub fn ByteGUI_ImplWin32_EnableDpiAwareness() void {
    const user32 = c.GetModuleHandleA("user32.dll");
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

pub noinline fn ByteGUI_ImplWin32_CreatePlatformWindow(config: ?*const ByteGUIPlatformWindowConfig) bool {
    const cfg_ptr = config orelse return false;
    const cfg = cfg_ptr.*;
    std.mem.doNotOptimizeAway(cfg);
    if (cfg.Instance == null or cfg.WndProc == null or cfg.LogicalWidth <= 0 or cfg.LogicalHeight <= 0) return false;
    setByteGUITrace("win32:create:start");

    ByteGUI_ImplWin32_EnableDpiAwareness();
    if (GHostWindow.Hwnd != null) ByteGUI_ImplWin32_DestroyPlatformWindow();

    GHostWindow = .{};
    GHostWindow.Instance = cfg.Instance;
    GHostWindow.LogicalWidth = cfg.LogicalWidth;
    GHostWindow.LogicalHeight = cfg.LogicalHeight;
    GHostWindow.DpiScale = getSystemDpiScale();
    GHostWindow.WindowWidthPx = ByteGUI_ImplWin32_ScaleI(cfg.LogicalWidth);
    GHostWindow.WindowHeightPx = ByteGUI_ImplWin32_ScaleI(cfg.LogicalHeight);
    setByteGUITrace("win32:create:metrics");
    GHostWindow.ClassName = allocator.dupeZ(u16, std.mem.span(cfg.ClassName)) catch return false;
    setByteGUITrace("win32:create:classname");
    const big_icon = if (cfg.IconResourceId != 0) loadIconResource(cfg.Instance, cfg.IconResourceId, c.GetSystemMetrics(c.SM_CXICON), c.GetSystemMetrics(c.SM_CYICON)) else null;
    const small_icon = if (cfg.IconResourceId != 0) loadIconResource(cfg.Instance, cfg.IconResourceId, c.GetSystemMetrics(c.SM_CXSMICON), c.GetSystemMetrics(c.SM_CYSMICON)) else null;
    setByteGUITrace("win32:create:icons");

    var wc = std.mem.zeroes(c.WNDCLASSEXW);
    wc.cbSize = @sizeOf(c.WNDCLASSEXW);
    wc.style = c.CS_OWNDC;
    wc.lpfnWndProc = cfg.WndProc;
    wc.hInstance = cfg.Instance;
    wc.hIcon = big_icon;
    wc.hIconSm = small_icon;
    wc.hCursor = if (w32.loadCursorResource(idc_arrow_id)) |cursor| @ptrFromInt(@intFromPtr(cursor)) else null;
    wc.lpszClassName = GHostWindow.ClassName.?.ptr;
    if (c.RegisterClassExW(&wc) == 0) return false;
    setByteGUITrace("win32:create:registered");
    GHostWindow.ClassRegistered = true;

    var pos_x: i32 = c.CW_USEDEFAULT;
    var pos_y: i32 = c.CW_USEDEFAULT;
    if (cfg.CenterOnPrimaryMonitor) {
        const screen_w = c.GetSystemMetrics(c.SM_CXSCREEN);
        const screen_h = c.GetSystemMetrics(c.SM_CYSCREEN);
        pos_x = @divTrunc(screen_w - GHostWindow.WindowWidthPx, 2);
        pos_y = @divTrunc(screen_h - GHostWindow.WindowHeightPx, 2);
    }

    setByteGUITraceFmt("win32:create:before_window ex={x} style={x}", .{ cfg.ExStyle, cfg.Style });
    GHostWindow.Hwnd = c.CreateWindowExW(cfg.ExStyle, GHostWindow.ClassName.?.ptr, cfg.Title, cfg.Style, pos_x, pos_y, GHostWindow.WindowWidthPx, GHostWindow.WindowHeightPx, null, null, cfg.Instance, null);
    setByteGUITrace("win32:create:window");
    if (GHostWindow.Hwnd != null and (big_icon != null or small_icon != null)) applyWindowIcons(GHostWindow.Hwnd.?, big_icon, small_icon);
    setByteGUITrace("win32:create:done");
    return GHostWindow.Hwnd != null;
}

pub fn ByteGUI_ImplWin32_DestroyPlatformWindow() void {
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

pub fn ByteGUI_ImplWin32_GetPlatformHwnd() ?c.HWND {
    return GHostWindow.Hwnd;
}

pub fn ByteGUI_ImplWin32_GetDpiScale() f32 {
    return if (GHostWindow.DpiScale > 0.0) GHostWindow.DpiScale else 1.0;
}

pub fn ByteGUI_ImplWin32_ScaleF(value: f32) f32 {
    return value * ByteGUI_ImplWin32_GetDpiScale();
}

pub fn ByteGUI_ImplWin32_ScaleI(value: i32) i32 {
    return @intFromFloat(@round(@as(f32, @floatFromInt(value)) * ByteGUI_ImplWin32_GetDpiScale()));
}

pub fn ByteGUI_ImplWin32_ScaleI_F(value: f32) i32 {
    return @intFromFloat(@round(value * ByteGUI_ImplWin32_GetDpiScale()));
}

pub fn ByteGUI_ImplWin32_ScaleVec2(x: f32, y: f32) ByteVec2 {
    return .{ .x = ByteGUI_ImplWin32_ScaleF(x), .y = ByteGUI_ImplWin32_ScaleF(y) };
}

pub fn ByteGUI_ImplWin32_SnapPixel(value: anytype) @TypeOf(value) {
    return switch (@TypeOf(value)) {
        f32 => @floor(value + 0.5),
        ByteVec2 => .{
            .x = ByteGUI_ImplWin32_SnapPixel(value.x),
            .y = ByteGUI_ImplWin32_SnapPixel(value.y),
        },
        else => @compileError("ByteGUI_ImplWin32_SnapPixel only supports f32 and ByteVec2."),
    };
}

pub fn ByteGUI_ImplWin32_CornerRadiusPx(logical_radius: f32, enabled: bool) f32 {
    if (!enabled) return 0.0;
    return ByteGUI_ImplWin32_SnapPixel(ByteGUI_ImplWin32_ScaleF(logical_radius));
}

fn ByteGUI_ImplWin32_GetWindowSizeVec2() ByteVec2 {
    return .{
        .x = @floatFromInt(GHostWindow.WindowWidthPx),
        .y = @floatFromInt(GHostWindow.WindowHeightPx),
    };
}

pub fn ByteGUI_ImplWin32_PointInCornerOnlyRoundedClientArea(pt: anytype, radius: f32) bool {
    return Ui.PointInCornerOnlyRoundedRect(
        .{ .x = pt.x, .y = pt.y },
        .{},
        ByteGUI_ImplWin32_GetWindowSizeVec2(),
        radius,
    );
}

pub fn ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForSize(radius: f32, use_layered_frame: bool, width_px: i32, height_px: i32) void {
    const host_hwnd = GHostWindow.Hwnd orelse return;
    const hwnd: w32.HWND = @ptrFromInt(@intFromPtr(host_hwnd));
    const size = ByteVec2{ .x = @floatFromInt(@max(1, width_px)), .y = @floatFromInt(@max(1, height_px)) };
    const width: w32.INT = @intCast(@max(1, width_px));
    const height: w32.INT = @intCast(@max(1, height_px));

    if (radius <= 0.0) {
        _ = w32.SetWindowRgn(hwnd, null, w32.TRUE);
    } else {
        const aa_pad: w32.INT = 2;
        const radius_pad: f32 = @floatFromInt(aa_pad);
        const clamped_radius = @min(ByteGUI_ImplWin32_SnapPixel(radius), @min(size.x, size.y) * 0.5);
        const diameter: w32.INT = @intFromFloat(@ceil(@max(1.0, (clamped_radius + radius_pad) * 2.0)));
        if (w32.CreateRoundRectRgn(-aa_pad, -aa_pad, width + aa_pad + 1, height + aa_pad + 1, diameter, diameter)) |region| {
            if (w32.SetWindowRgn(hwnd, region, w32.TRUE) == 0) {
                _ = w32.DeleteObject(region);
            }
        }
    }

    if (use_layered_frame) {
        const margins = w32.MARGINS{ .cxLeftWidth = -1, .cxRightWidth = -1, .cyTopHeight = -1, .cyBottomHeight = -1 };
        _ = w32.DwmExtendFrameIntoClientArea(hwnd, &margins);
    }
}

pub fn ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShape(radius: f32, use_layered_frame: bool) void {
    ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForSize(radius, use_layered_frame, GHostWindow.WindowWidthPx, GHostWindow.WindowHeightPx);
}

fn cornerOnlyRoundedRadiusPx(logical_radius: f32, enabled: bool) f32 {
    return ByteGUI_ImplWin32_CornerRadiusPx(logical_radius, enabled);
}

pub fn ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeLogical(logical_radius: f32, use_layered_frame: bool) void {
    ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShape(cornerOnlyRoundedRadiusPx(logical_radius, use_layered_frame), use_layered_frame);
}

pub fn ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForSizeLogical(logical_radius: f32, use_layered_frame: bool, width_px: i32, height_px: i32) void {
    ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForSize(cornerOnlyRoundedRadiusPx(logical_radius, use_layered_frame), use_layered_frame, width_px, height_px);
}

pub fn ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForRectLogical(logical_radius: f32, use_layered_frame: bool, rect: *const w32.RECT) void {
    const width = rect.right - rect.left;
    const height = rect.bottom - rect.top;
    if (width > 0 and height > 0) ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForSizeLogical(logical_radius, use_layered_frame, width, height);
}

pub fn ByteGUI_ImplWin32_PrepareCornerOnlyRoundedWindowResize(logical_radius: f32, use_layered_frame: bool, msg: w32.UINT, l_param: w32.LPARAM) void {
    const ptr_value: usize = @bitCast(l_param);
    if (ptr_value == 0) return;

    switch (msg) {
        w32.WM_SIZING => {
            const rect: *const w32.RECT = @ptrFromInt(ptr_value);
            const width = rect.right - rect.left;
            const height = rect.bottom - rect.top;
            prepareOpenGLResizeSurface(width, height);
            ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForRectLogical(logical_radius, use_layered_frame, rect);
        },
        w32.WM_WINDOWPOSCHANGING => {
            const pos: *w32.WINDOWPOS = @ptrFromInt(ptr_value);
            if ((pos.flags & w32.SWP_NOSIZE) == 0 and pos.cx > 0 and pos.cy > 0) {
                pos.flags |= w32.SWP_NOCOPYBITS;
                prepareOpenGLResizeSurface(pos.cx, pos.cy);
                ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForSizeLogical(logical_radius, use_layered_frame, pos.cx, pos.cy);
            }
        },
        else => {},
    }
}

pub fn ByteGUI_ImplWin32_HandleCornerOnlyRoundedWindowSize(logical_radius: f32, use_layered_frame: bool, w_param: w32.WPARAM, l_param: w32.LPARAM) bool {
    if (w_param == w32.SIZE_MINIMIZED) return false;
    const size_bits: usize = @bitCast(l_param);
    const width: w32.UINT = @intCast(size_bits & 0xffff);
    const height: w32.UINT = @intCast((size_bits >> 16) & 0xffff);
    if (width == 0 or height == 0) return false;
    ByteGUI_ImplOpenGL_Resize(width, height);
    ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForSizeLogical(logical_radius, use_layered_frame, @intCast(width), @intCast(height));
    return true;
}

pub fn ByteGUI_ImplWin32_ApplyCornerOnlyRoundedDpiWindowPos(logical_radius: f32, use_layered_frame: bool, l_param: w32.LPARAM) void {
    const host_hwnd = GHostWindow.Hwnd orelse return;
    const hwnd: w32.HWND = @ptrFromInt(@intFromPtr(host_hwnd));
    const ptr_value: usize = @bitCast(l_param);

    if (ptr_value != 0) {
        const rect: *const w32.RECT = @ptrFromInt(ptr_value);
        const width = rect.right - rect.left;
        const height = rect.bottom - rect.top;
        if (width > 0 and height > 0) prepareOpenGLResizeSurface(width, height);
        ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeForRectLogical(logical_radius, use_layered_frame, rect);
        _ = w32.SetWindowPos(hwnd, null, rect.left, rect.top, width, height, w32.SWP_NOZORDER | w32.SWP_NOACTIVATE | w32.SWP_NOCOPYBITS);
        return;
    }

    ByteGUI_ImplWin32_ApplyCornerOnlyRoundedWindowShapeLogical(logical_radius, use_layered_frame);
    var rect = std.mem.zeroes(w32.RECT);
    _ = w32.GetWindowRect(hwnd, &rect);
    prepareOpenGLResizeSurface(GHostWindow.WindowWidthPx, GHostWindow.WindowHeightPx);
    _ = w32.SetWindowPos(hwnd, null, rect.left, rect.top, GHostWindow.WindowWidthPx, GHostWindow.WindowHeightPx, w32.SWP_NOZORDER | w32.SWP_NOACTIVATE | w32.SWP_NOCOPYBITS);
}

pub fn ByteGUI_ImplWin32_GetWindowWidth() i32 {
    return GHostWindow.WindowWidthPx;
}

pub fn ByteGUI_ImplWin32_GetWindowHeight() i32 {
    return GHostWindow.WindowHeightPx;
}

pub fn ByteGUI_ImplWin32_HandleDpiChanged(w_param: c.WPARAM, l_param: c.LPARAM, apply_suggested_rect: bool) bool {
    const new_scale = @as(f32, @floatFromInt(lowWord(@as(usize, @intCast(w_param))))) / 96.0;
    const changed = @abs(new_scale - GHostWindow.DpiScale) > 0.001;
    GHostWindow.DpiScale = new_scale;
    GHostWindow.WindowWidthPx = ByteGUI_ImplWin32_ScaleI(GHostWindow.LogicalWidth);
    GHostWindow.WindowHeightPx = ByteGUI_ImplWin32_ScaleI(GHostWindow.LogicalHeight);

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

pub fn ByteGUI_ImplWin32_Init(hwnd: ?c.HWND) bool {
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

pub fn ByteGUI_ImplWin32_Shutdown() void {
    const ctx = GByteGUI orelse return;
    if (getWin32BackendData()) |bd| allocator.destroy(bd);
    ctx.IO.BackendPlatformUserData = null;
    ctx.IO.BackendPlatformName = null;
}

pub fn ByteGUI_ImplWin32_NewFrame() void {
    const ctx = GByteGUI orelse return;
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

pub fn ByteGUI_ImplWin32_WndProcHandler(hwnd: ?c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) c.LRESULT {
    _ = hwnd;
    _ = msg;
    _ = w_param;
    _ = l_param;
    return 0;
}

pub fn windowsFontPath(gpa: std.mem.Allocator, comptime file_name: []const u8) ?[]u8 {
    if (builtin.os.tag != .windows) return null;

    const environ: std.process.Environ = .{ .block = .{ .use_global = true } };
    const windir_utf16 = std.process.Environ.getWindows(environ, std.unicode.wtf8ToWtf16LeStringLiteral("WINDIR")) orelse return null;
    const windir = std.unicode.wtf16LeToWtf8Alloc(gpa, windir_utf16) catch return null;
    defer gpa.free(windir);

    return std.fs.path.join(gpa, &.{ windir, "Fonts", file_name }) catch return null;
}
