// ByteType - A minimal TrueType parser and rasterizer used by ByteGui
const std = @import("std");

const allocator = std.heap.c_allocator;

pub const SizeMetrics = struct {
    ascender: f32 = 0.0,
    descender: f32 = 0.0,
    height: f32 = 0.0,
};

pub const GlyphBounds = struct {
    x_min: f32 = 0.0,
    y_min: f32 = 0.0,
    x_max: f32 = 0.0,
    y_max: f32 = 0.0,
    advance_x: f32 = 0.0,
};

pub const RenderedGlyph = struct {
    pixels: []u8 = &.{},
    width: usize = 0,
    height: usize = 0,
    left: i32 = 0,
    top: i32 = 0,

    pub fn deinit(self: *RenderedGlyph, gpa: std.mem.Allocator) void {
        if (self.pixels.len > 0) gpa.free(self.pixels);
        self.* = .{};
    }
};

pub fn shutdown() void {}

const GlyphHeader = struct {
    num_contours: i16 = 0,
    x_min: i16 = 0,
    y_min: i16 = 0,
    x_max: i16 = 0,
    y_max: i16 = 0,
};

const CurvePoint = struct {
    x: f32,
    y: f32,
    on_curve: bool,
};

const Vec2 = struct {
    x: f32,
    y: f32,
};

const TableInfo = struct {
    offset: usize,
    len: usize,
};

const GlyphRange = struct {
    offset: usize,
    len: usize,
};

const CmapFormat = enum {
    format4,
    format12,
};

const Affine = struct {
    xx: f32 = 1.0,
    xy: f32 = 0.0,
    yx: f32 = 0.0,
    yy: f32 = 1.0,
    dx: f32 = 0.0,
    dy: f32 = 0.0,

    fn compose(parent: Affine, child: Affine) Affine {
        return .{
            .xx = parent.xx * child.xx + parent.xy * child.yx,
            .xy = parent.xx * child.xy + parent.xy * child.yy,
            .yx = parent.yx * child.xx + parent.yy * child.yx,
            .yy = parent.yx * child.xy + parent.yy * child.yy,
            .dx = parent.xx * child.dx + parent.xy * child.dy + parent.dx,
            .dy = parent.yx * child.dx + parent.yy * child.dy + parent.dy,
        };
    }
};

const RenderContour = struct {
    points: std.ArrayListUnmanaged(Vec2) = .empty,

    fn deinit(self: *RenderContour) void {
        self.points.deinit(allocator);
        self.* = .{};
    }

    fn addPoint(self: *RenderContour, point: Vec2) !void {
        if (self.points.items.len > 0) {
            const prev = self.points.items[self.points.items.len - 1];
            if (approxEqual(prev.x, point.x, 0.01) and approxEqual(prev.y, point.y, 0.01)) return;
        }
        try self.points.append(allocator, point);
    }
};

const RenderShape = struct {
    contours: std.ArrayListUnmanaged(RenderContour) = .empty,

    fn deinit(self: *RenderShape) void {
        for (self.contours.items) |*contour| contour.deinit();
        self.contours.deinit(allocator);
        self.* = .{};
    }
};

const SelectedCmap = struct {
    offset: usize,
    format: CmapFormat,
};

const PairAdjustSide = enum {
    first,
    second,
};

const ShapeBounds = struct {
    min_x: f32,
    min_y: f32,
    max_x: f32,
    max_y: f32,
};

const flag_on_curve = 0x01;
const flag_x_short_vector = 0x02;
const flag_y_short_vector = 0x04;
const flag_repeat = 0x08;
const flag_x_is_same_or_positive = 0x10;
const flag_y_is_same_or_positive = 0x20;

const comp_args_are_words = 0x0001;
const comp_args_are_xy_values = 0x0002;
const comp_have_scale = 0x0008;
const comp_more_components = 0x0020;
const comp_have_xy_scale = 0x0040;
const comp_have_2x2 = 0x0080;
const comp_scaled_component_offset = 0x0800;
const comp_unscaled_component_offset = 0x1000;

const raster_grid: usize = 4;

// Parsed face and metrics API
pub const FontFace = struct {
    data: []const u8 = &.{},
    font_offset: usize = 0,
    units_per_em: u16 = 0,
    num_glyphs: u16 = 0,
    index_to_loca_format: i16 = 0,
    num_h_metrics: u16 = 0,
    ascender_units: i16 = 0,
    descender_units: i16 = 0,
    line_gap_units: i16 = 0,
    cmap_offset: usize = 0,
    cmap_format: CmapFormat = .format4,
    hmtx_offset: usize = 0,
    loca_offset: usize = 0,
    glyf_offset: usize = 0,
    gpos_offset: ?usize = null,
    gpos_lookup_list_offset: ?usize = null,
    kern_lookup_indices: []u16 = &.{},

    pub fn init(data: []const u8, face_index: i32) ?FontFace {
        if (face_index < 0) return null;
        const font_offset = resolveFontOffset(data, @intCast(face_index)) orelse return null;

        const head = findTable(data, font_offset, "head") orelse return null;
        const hhea = findTable(data, font_offset, "hhea") orelse return null;
        const hmtx = findTable(data, font_offset, "hmtx") orelse return null;
        const maxp = findTable(data, font_offset, "maxp") orelse return null;
        const loca = findTable(data, font_offset, "loca") orelse return null;
        const glyf = findTable(data, font_offset, "glyf") orelse return null;
        const cmap_table = findTable(data, font_offset, "cmap") orelse return null;

        const units_per_em = readU16(data, head.offset + 18) orelse return null;
        const index_to_loca_format = readI16(data, head.offset + 50) orelse return null;
        const ascender_units = readI16(data, hhea.offset + 4) orelse return null;
        const descender_units = readI16(data, hhea.offset + 6) orelse return null;
        const line_gap_units = readI16(data, hhea.offset + 8) orelse return null;
        const num_h_metrics = readU16(data, hhea.offset + 34) orelse return null;
        const num_glyphs = readU16(data, maxp.offset + 4) orelse return null;
        const cmap_selected = selectUnicodeCmap(data, cmap_table) orelse return null;

        var face = FontFace{
            .data = data,
            .font_offset = font_offset,
            .units_per_em = units_per_em,
            .num_glyphs = num_glyphs,
            .index_to_loca_format = index_to_loca_format,
            .num_h_metrics = num_h_metrics,
            .ascender_units = ascender_units,
            .descender_units = descender_units,
            .line_gap_units = line_gap_units,
            .cmap_offset = cmap_selected.offset,
            .cmap_format = cmap_selected.format,
            .hmtx_offset = hmtx.offset,
            .loca_offset = loca.offset,
            .glyf_offset = glyf.offset,
        };

        if (findTable(data, font_offset, "GPOS")) |gpos| {
            face.gpos_offset = gpos.offset;
            face.gpos_lookup_list_offset = gposLookupListOffset(data, gpos.offset);
            face.kern_lookup_indices = collectKernLookups(data, gpos.offset) orelse &.{};
        }

        return face;
    }

    pub fn deinit(self: *FontFace) void {
        if (self.kern_lookup_indices.len > 0) allocator.free(self.kern_lookup_indices);
        self.* = .{};
    }

    pub fn getSizeMetrics(self: *FontFace, size_pixels: f32) ?SizeMetrics {
        if (self.units_per_em == 0 or size_pixels <= 0.0) return null;
        const scale = self.scaleForPixelHeight(size_pixels);
        const height_units = @max(
            @as(i32, self.ascender_units) - @as(i32, self.descender_units) + @as(i32, self.line_gap_units),
            1,
        );
        return .{
            .ascender = @as(f32, @floatFromInt(self.ascender_units)) * scale,
            .descender = @as(f32, @floatFromInt(self.descender_units)) * scale,
            .height = @as(f32, @floatFromInt(height_units)) * scale,
        };
    }

    pub fn getGlyphIndex(self: *const FontFace, codepoint: u32) u32 {
        return switch (self.cmap_format) {
            .format4 => self.getGlyphIndexFormat4(codepoint),
            .format12 => self.getGlyphIndexFormat12(codepoint),
        };
    }

    pub fn getKerningPx(self: *FontFace, left_glyph: u32, right_glyph: u32, size_pixels: f32) f32 {
        if (left_glyph == 0 or right_glyph == 0 or size_pixels <= 0.0) return 0.0;
        return @as(f32, @floatFromInt(self.getKerningUnits(left_glyph, right_glyph))) * self.scaleForPixelHeight(size_pixels);
    }

    pub fn loadGlyphBounds(self: *FontFace, glyph_index: u32, size_pixels: f32, shift_x: f32, shift_y: f32) ?GlyphBounds {
        if (size_pixels <= 0.0) return null;
        const scale = self.scaleForPixelHeight(size_pixels);
        const header = self.loadGlyphHeader(glyph_index) orelse GlyphHeader{};
        return .{
            .x_min = @as(f32, @floatFromInt(header.x_min)) * scale + shift_x,
            .y_min = @as(f32, @floatFromInt(header.y_min)) * scale - shift_y,
            .x_max = @as(f32, @floatFromInt(header.x_max)) * scale + shift_x,
            .y_max = @as(f32, @floatFromInt(header.y_max)) * scale - shift_y,
            .advance_x = @as(f32, @floatFromInt(self.getAdvanceWidthUnits(glyph_index))) * scale,
        };
    }

    pub fn renderGlyph(self: *FontFace, gpa: std.mem.Allocator, glyph_index: u32, size_pixels: f32, shift_x: f32, shift_y: f32) ?RenderedGlyph {
        if (size_pixels <= 0.0) return null;
        const scale = self.scaleForPixelHeight(size_pixels);

        var shape = RenderShape{};
        defer shape.deinit();

        if (!self.appendGlyphRenderShape(glyph_index, scale, shift_x, shift_y, .{}, &shape, 0)) return null;

        const bounds = computeShapeBounds(&shape) orelse return .{};
        const min_x_i: i32 = @intFromFloat(@floor(bounds.min_x));
        const min_y_i: i32 = @intFromFloat(@floor(bounds.min_y));
        const max_x_i: i32 = @intFromFloat(@ceil(bounds.max_x));
        const max_y_i: i32 = @intFromFloat(@ceil(bounds.max_y));
        const pixel_w_i = max_x_i - min_x_i;
        const pixel_h_i = max_y_i - min_y_i;
        if (pixel_w_i <= 0 or pixel_h_i <= 0) {
            return .{
                .left = min_x_i,
                .top = -min_y_i,
            };
        }

        for (shape.contours.items) |*contour| {
            for (contour.points.items) |*point| {
                point.x -= @as(f32, @floatFromInt(min_x_i));
                point.y -= @as(f32, @floatFromInt(min_y_i));
            }
        }

        const pixel_w: usize = @intCast(pixel_w_i);
        const pixel_h: usize = @intCast(pixel_h_i);
        const pixels = gpa.alloc(u8, pixel_w * pixel_h) catch return null;
        @memset(pixels, 0);
        rasterizeShapeIntoAlpha(pixels, pixel_w, pixel_h, &shape);

        return .{
            .pixels = pixels,
            .width = pixel_w,
            .height = pixel_h,
            .left = min_x_i,
            .top = -min_y_i,
        };
    }

    fn scaleForPixelHeight(self: *const FontFace, size_pixels: f32) f32 {
        return size_pixels / @as(f32, @floatFromInt(self.units_per_em));
    }

    fn getGlyphIndexFormat4(self: *const FontFace, codepoint: u32) u32 {
        if (codepoint > 0xFFFF) return 0;

        const seg_count_x2 = readU16(self.data, self.cmap_offset + 6) orelse return 0;
        const seg_count: usize = seg_count_x2 / 2;
        const end_codes = self.cmap_offset + 14;
        const start_codes = end_codes + seg_count * 2 + 2;
        const id_deltas = start_codes + seg_count * 2;
        const id_range_offsets = id_deltas + seg_count * 2;

        var lo: usize = 0;
        var hi: usize = seg_count;
        while (lo < hi) {
            const mid = lo + (hi - lo) / 2;
            const end_code = readU16(self.data, end_codes + mid * 2) orelse return 0;
            if (codepoint > end_code) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        if (lo >= seg_count) return 0;

        const start_code = readU16(self.data, start_codes + lo * 2) orelse return 0;
        const end_code = readU16(self.data, end_codes + lo * 2) orelse return 0;
        if (codepoint < start_code or codepoint > end_code) return 0;

        const id_delta = readI16(self.data, id_deltas + lo * 2) orelse return 0;
        const id_range_offset = readU16(self.data, id_range_offsets + lo * 2) orelse return 0;
        if (id_range_offset == 0) {
            return @intCast(@as(u32, @intCast((@as(i32, @intCast(codepoint)) + id_delta) & 0xFFFF)));
        }

        const range_base = id_range_offsets + lo * 2;
        const glyph_off = range_base + id_range_offset + (@as(usize, @intCast(codepoint - start_code)) * 2);
        const glyph_id = readU16(self.data, glyph_off) orelse return 0;
        if (glyph_id == 0) return 0;
        return @intCast(@as(u32, @intCast((@as(i32, glyph_id) + id_delta) & 0xFFFF)));
    }

    fn getGlyphIndexFormat12(self: *const FontFace, codepoint: u32) u32 {
        const group_count = readU32(self.data, self.cmap_offset + 12) orelse return 0;
        const groups_offset = self.cmap_offset + 16;

        var lo: usize = 0;
        var hi: usize = group_count;
        while (lo < hi) {
            const mid = lo + (hi - lo) / 2;
            const group_offset = groups_offset + mid * 12;
            const end_code = readU32(self.data, group_offset + 4) orelse return 0;
            if (codepoint > end_code) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        if (lo >= group_count) return 0;

        const group_offset = groups_offset + lo * 12;
        const start_code = readU32(self.data, group_offset) orelse return 0;
        const end_code = readU32(self.data, group_offset + 4) orelse return 0;
        if (codepoint < start_code or codepoint > end_code) return 0;
        const start_glyph = readU32(self.data, group_offset + 8) orelse return 0;
        return start_glyph + (codepoint - start_code);
    }

    fn getAdvanceWidthUnits(self: *const FontFace, glyph_index: u32) i32 {
        if (self.num_h_metrics == 0) return 0;
        const metrics_index = if (glyph_index < self.num_h_metrics) glyph_index else self.num_h_metrics - 1;
        const offset = self.hmtx_offset + @as(usize, @intCast(metrics_index)) * 4;
        return @as(i32, readU16(self.data, offset) orelse 0);
    }

    fn getKerningUnits(self: *const FontFace, left_glyph: u32, right_glyph: u32) i32 {
        if (self.kern_lookup_indices.len == 0) return 0;
        var adjust: i32 = 0;
        for (self.kern_lookup_indices) |lookup_index| {
            adjust += self.getLookupKerningUnits(lookup_index, left_glyph, right_glyph);
        }
        return adjust;
    }

    fn getLookupKerningUnits(self: *const FontFace, lookup_index: u16, left_glyph: u32, right_glyph: u32) i32 {
        const lookup_list = self.gpos_lookup_list_offset orelse return 0;
        const lookup_count = readU16(self.data, lookup_list) orelse return 0;
        if (lookup_index >= lookup_count) return 0;

        const lookup_offset = readU16(self.data, lookup_list + 2 + @as(usize, lookup_index) * 2) orelse return 0;
        const lookup = lookup_list + lookup_offset;
        const lookup_type = readU16(self.data, lookup) orelse return 0;
        const subtable_count = readU16(self.data, lookup + 4) orelse return 0;

        var adjust: i32 = 0;
        for (0..subtable_count) |subtable_index| {
            const subtable_offset = readU16(self.data, lookup + 6 + subtable_index * 2) orelse continue;
            const subtable = lookup + subtable_offset;
            switch (lookup_type) {
                2 => adjust += self.getPairAdjustmentUnits(subtable, left_glyph, right_glyph),
                9 => adjust += self.getExtensionPairAdjustmentUnits(subtable, left_glyph, right_glyph),
                else => {},
            }
        }
        return adjust;
    }

    fn getExtensionPairAdjustmentUnits(self: *const FontFace, extension_subtable: usize, left_glyph: u32, right_glyph: u32) i32 {
        const pos_format = readU16(self.data, extension_subtable) orelse return 0;
        if (pos_format != 1) return 0;
        const extension_lookup_type = readU16(self.data, extension_subtable + 2) orelse return 0;
        if (extension_lookup_type != 2) return 0;
        const extension_offset = readU32(self.data, extension_subtable + 4) orelse return 0;
        return self.getPairAdjustmentUnits(extension_subtable + extension_offset, left_glyph, right_glyph);
    }

    fn getPairAdjustmentUnits(self: *const FontFace, pair_subtable: usize, left_glyph: u32, right_glyph: u32) i32 {
        const pos_format = readU16(self.data, pair_subtable) orelse return 0;
        const coverage_offset = readU16(self.data, pair_subtable + 2) orelse return 0;
        const value_format_1 = readU16(self.data, pair_subtable + 4) orelse return 0;
        const value_format_2 = readU16(self.data, pair_subtable + 6) orelse return 0;

        return switch (pos_format) {
            1 => blk: {
                const coverage_index = coverageIndex(self.data, pair_subtable + coverage_offset, left_glyph) orelse break :blk 0;
                const pair_set_count = readU16(self.data, pair_subtable + 8) orelse break :blk 0;
                if (coverage_index >= pair_set_count) break :blk 0;
                const pair_set_offset = readU16(self.data, pair_subtable + 10 + @as(usize, coverage_index) * 2) orelse break :blk 0;
                const pair_set = pair_subtable + pair_set_offset;
                break :blk pairSetAdjustment(self.data, pair_set, value_format_1, value_format_2, right_glyph);
            },
            2 => blk: {
                _ = coverageIndex(self.data, pair_subtable + coverage_offset, left_glyph) orelse break :blk 0;
                const class_def_1 = pair_subtable + (readU16(self.data, pair_subtable + 8) orelse break :blk 0);
                const class_def_2 = pair_subtable + (readU16(self.data, pair_subtable + 10) orelse break :blk 0);
                const class_1_count = readU16(self.data, pair_subtable + 12) orelse break :blk 0;
                const class_2_count = readU16(self.data, pair_subtable + 14) orelse break :blk 0;
                const class_1 = classDefValue(self.data, class_def_1, left_glyph);
                const class_2 = classDefValue(self.data, class_def_2, right_glyph);
                if (class_1 >= class_1_count or class_2 >= class_2_count) break :blk 0;

                const value_size_1 = valueRecordSize(value_format_1);
                const value_size_2 = valueRecordSize(value_format_2);
                const record_size = value_size_1 + value_size_2;
                const record_offset = pair_subtable + 16 +
                    (@as(usize, class_1) * @as(usize, class_2_count) + @as(usize, class_2)) * record_size;
                const value_1_offset = record_offset;
                const value_2_offset = value_1_offset + value_size_1;
                break :blk valueRecordAdvanceAdjust(self.data, value_1_offset, value_format_1, .first) +
                    valueRecordAdvanceAdjust(self.data, value_2_offset, value_format_2, .second);
            },
            else => 0,
        };
    }

    fn loadGlyphHeader(self: *const FontFace, glyph_index: u32) ?GlyphHeader {
        const range = self.glyphRange(glyph_index) orelse return null;
        if (range.len < 10) return null;
        return .{
            .num_contours = readI16(self.data, range.offset) orelse return null,
            .x_min = readI16(self.data, range.offset + 2) orelse return null,
            .y_min = readI16(self.data, range.offset + 4) orelse return null,
            .x_max = readI16(self.data, range.offset + 6) orelse return null,
            .y_max = readI16(self.data, range.offset + 8) orelse return null,
        };
    }

    fn glyphRange(self: *const FontFace, glyph_index: u32) ?GlyphRange {
        if (glyph_index >= self.num_glyphs) return null;

        const loca_entry: usize = if (self.index_to_loca_format == 0) 2 else 4;
        const start_off = self.loca_offset + @as(usize, @intCast(glyph_index)) * loca_entry;
        const end_off = start_off + loca_entry;

        const start = if (self.index_to_loca_format == 0)
            @as(usize, (readU16(self.data, start_off) orelse return null) * 2)
        else
            @as(usize, readU32(self.data, start_off) orelse return null);
        const end = if (self.index_to_loca_format == 0)
            @as(usize, (readU16(self.data, end_off) orelse return null) * 2)
        else
            @as(usize, readU32(self.data, end_off) orelse return null);

        if (end < start) return null;
        return .{
            .offset = self.glyf_offset + start,
            .len = end - start,
        };
    }

    fn appendGlyphRenderShape(self: *const FontFace, glyph_index: u32, scale: f32, shift_x: f32, shift_y: f32, transform: Affine, shape: *RenderShape, depth: usize) bool {
        if (depth > 16) return false;
        const range = self.glyphRange(glyph_index) orelse return true;
        if (range.len == 0) return true;
        if (range.len < 10) return false;

        const num_contours = readI16(self.data, range.offset) orelse return false;
        return if (num_contours >= 0)
            self.appendSimpleGlyph(range.offset, @intCast(num_contours), scale, shift_x, shift_y, transform, shape)
        else
            self.appendCompositeGlyph(range.offset, scale, shift_x, shift_y, transform, shape, depth + 1);
    }

    fn appendSimpleGlyph(self: *const FontFace, glyph_offset: usize, contour_count: usize, scale: f32, shift_x: f32, shift_y: f32, transform: Affine, shape: *RenderShape) bool {
        if (contour_count == 0) return true;

        const end_points_offset = glyph_offset + 10;
        const end_points = allocator.alloc(u16, contour_count) catch return false;
        defer allocator.free(end_points);

        var point_count: usize = 0;
        for (0..contour_count) |contour_index| {
            const value = readU16(self.data, end_points_offset + contour_index * 2) orelse return false;
            end_points[contour_index] = value;
            point_count = @max(point_count, @as(usize, value) + 1);
        }
        if (point_count == 0) return true;

        const instruction_length_offset = end_points_offset + contour_count * 2;
        const instruction_length = readU16(self.data, instruction_length_offset) orelse return false;
        var cursor = instruction_length_offset + 2 + instruction_length;

        const flags = allocator.alloc(u8, point_count) catch return false;
        defer allocator.free(flags);

        var flag_index: usize = 0;
        while (flag_index < point_count) {
            if (cursor >= self.data.len) return false;
            const flag = self.data[cursor];
            cursor += 1;
            flags[flag_index] = flag;
            flag_index += 1;
            if ((flag & flag_repeat) != 0) {
                if (cursor >= self.data.len) return false;
                const repeat_count = self.data[cursor];
                cursor += 1;
                for (0..repeat_count) |_| {
                    if (flag_index >= point_count) return false;
                    flags[flag_index] = flag;
                    flag_index += 1;
                }
            }
        }

        const points = allocator.alloc(CurvePoint, point_count) catch return false;
        defer allocator.free(points);

        var x: i32 = 0;
        for (0..point_count) |point_index| {
            const flag = flags[point_index];
            if ((flag & flag_x_short_vector) != 0) {
                if (cursor >= self.data.len) return false;
                const dx = self.data[cursor];
                cursor += 1;
                x += if ((flag & flag_x_is_same_or_positive) != 0) @as(i32, dx) else -@as(i32, dx);
            } else if ((flag & flag_x_is_same_or_positive) == 0) {
                x += readI16(self.data, cursor) orelse return false;
                cursor += 2;
            }
            points[point_index].x = @floatFromInt(x);
            points[point_index].on_curve = (flag & flag_on_curve) != 0;
        }

        var y: i32 = 0;
        for (0..point_count) |point_index| {
            const flag = flags[point_index];
            if ((flag & flag_y_short_vector) != 0) {
                if (cursor >= self.data.len) return false;
                const dy = self.data[cursor];
                cursor += 1;
                y += if ((flag & flag_y_is_same_or_positive) != 0) @as(i32, dy) else -@as(i32, dy);
            } else if ((flag & flag_y_is_same_or_positive) == 0) {
                y += readI16(self.data, cursor) orelse return false;
                cursor += 2;
            }
            points[point_index].y = @floatFromInt(y);
        }

        var contour_start: usize = 0;
        for (end_points) |end_point| {
            const contour_end = @as(usize, end_point) + 1;
            if (contour_end > points.len or contour_end <= contour_start) return false;
            flattenContour(points[contour_start..contour_end], transform, scale, shift_x, shift_y, shape) catch return false;
            contour_start = contour_end;
        }

        return true;
    }

    fn appendCompositeGlyph(self: *const FontFace, glyph_offset: usize, scale: f32, shift_x: f32, shift_y: f32, transform: Affine, shape: *RenderShape, depth: usize) bool {
        var cursor = glyph_offset + 10;

        while (true) {
            const flags = readU16(self.data, cursor) orelse return false;
            const component_glyph = readU16(self.data, cursor + 2) orelse return false;
            cursor += 4;

            var arg1: i16 = 0;
            var arg2: i16 = 0;
            if ((flags & comp_args_are_words) != 0) {
                arg1 = readI16(self.data, cursor) orelse return false;
                arg2 = readI16(self.data, cursor + 2) orelse return false;
                cursor += 4;
            } else {
                arg1 = readI8(self.data, cursor) orelse return false;
                arg2 = readI8(self.data, cursor + 1) orelse return false;
                cursor += 2;
            }

            if ((flags & comp_args_are_xy_values) == 0) return false;

            var component = Affine{
                .dx = @floatFromInt(arg1),
                .dy = @floatFromInt(arg2),
            };

            if ((flags & comp_have_scale) != 0) {
                const s = f2dot14ToF32(readI16(self.data, cursor) orelse return false);
                component.xx = s;
                component.yy = s;
                cursor += 2;
            } else if ((flags & comp_have_xy_scale) != 0) {
                component.xx = f2dot14ToF32(readI16(self.data, cursor) orelse return false);
                component.yy = f2dot14ToF32(readI16(self.data, cursor + 2) orelse return false);
                cursor += 4;
            } else if ((flags & comp_have_2x2) != 0) {
                component.xx = f2dot14ToF32(readI16(self.data, cursor) orelse return false);
                component.yx = f2dot14ToF32(readI16(self.data, cursor + 2) orelse return false);
                component.xy = f2dot14ToF32(readI16(self.data, cursor + 4) orelse return false);
                component.yy = f2dot14ToF32(readI16(self.data, cursor + 6) orelse return false);
                cursor += 8;
            }

            if ((flags & comp_scaled_component_offset) != 0 and (flags & comp_unscaled_component_offset) == 0) {
                const scaled_dx = component.xx * component.dx + component.xy * component.dy;
                const scaled_dy = component.yx * component.dx + component.yy * component.dy;
                component.dx = scaled_dx;
                component.dy = scaled_dy;
            }

            const combined = Affine.compose(transform, component);
            if (!self.appendGlyphRenderShape(component_glyph, scale, shift_x, shift_y, combined, shape, depth)) return false;

            if ((flags & comp_more_components) == 0) break;
        }

        return true;
    }
};

// SFNT tables and GPOS lookup
fn resolveFontOffset(data: []const u8, face_index: u32) ?usize {
    if (data.len >= 12 and std.mem.eql(u8, data[0..4], "ttcf")) {
        const num_fonts = readU32(data, 8) orelse return null;
        if (face_index >= num_fonts) return null;
        return @as(usize, @intCast(readU32(data, 12 + @as(usize, @intCast(face_index)) * 4) orelse return null));
    }
    return if (face_index == 0) 0 else null;
}

fn findTable(data: []const u8, font_offset: usize, comptime tag: []const u8) ?TableInfo {
    if (tag.len != 4) @compileError("OpenType table tags must be 4 bytes.");
    const num_tables = readU16(data, font_offset + 4) orelse return null;
    const table_dir = font_offset + 12;

    for (0..num_tables) |table_index| {
        const record = table_dir + table_index * 16;
        if (!hasRange(data, record, 16)) return null;
        if (!std.mem.eql(u8, data[record .. record + 4], tag)) continue;
        const offset = readU32(data, record + 8) orelse return null;
        const len = readU32(data, record + 12) orelse return null;
        if (!hasRange(data, offset, len)) return null;
        return .{
            .offset = offset,
            .len = len,
        };
    }
    return null;
}

fn selectUnicodeCmap(data: []const u8, cmap_table: TableInfo) ?SelectedCmap {
    const table_count = readU16(data, cmap_table.offset + 2) orelse return null;
    var best_12: ?usize = null;
    var best_4: ?usize = null;

    for (0..table_count) |record_index| {
        const record = cmap_table.offset + 4 + record_index * 8;
        const platform_id = readU16(data, record) orelse return null;
        const encoding_id = readU16(data, record + 2) orelse return null;
        const subtable_offset = readU32(data, record + 4) orelse return null;
        const subtable = cmap_table.offset + subtable_offset;
        const format = readU16(data, subtable) orelse continue;

        const is_unicode = platform_id == 0 or (platform_id == 3 and (encoding_id == 1 or encoding_id == 10));
        if (!is_unicode) continue;

        if (format == 12 and best_12 == null) {
            best_12 = subtable;
        } else if (format == 4 and best_4 == null) {
            best_4 = subtable;
        }
    }

    if (best_12) |offset| return .{ .offset = offset, .format = .format12 };
    if (best_4) |offset| return .{ .offset = offset, .format = .format4 };
    return null;
}

fn gposLookupListOffset(data: []const u8, gpos_offset: usize) ?usize {
    const lookup_list_delta = readU16(data, gpos_offset + 8) orelse return null;
    return gpos_offset + lookup_list_delta;
}

fn collectKernLookups(data: []const u8, gpos_offset: usize) ?[]u16 {
    const feature_list_delta = readU16(data, gpos_offset + 6) orelse return null;
    const feature_list = gpos_offset + feature_list_delta;
    const feature_count = readU16(data, feature_list) orelse return null;

    var lookups: std.ArrayListUnmanaged(u16) = .empty;
    errdefer lookups.deinit(allocator);

    for (0..feature_count) |feature_index| {
        const record = feature_list + 2 + feature_index * 6;
        if (!hasRange(data, record, 6)) return null;
        if (!std.mem.eql(u8, data[record .. record + 4], "kern")) continue;

        const feature_delta = readU16(data, record + 4) orelse return null;
        const feature = feature_list + feature_delta;
        const lookup_count = readU16(data, feature + 2) orelse return null;
        for (0..lookup_count) |lookup_slot| {
            const lookup_index = readU16(data, feature + 4 + lookup_slot * 2) orelse return null;
            if (!containsU16(lookups.items, lookup_index)) {
                lookups.append(allocator, lookup_index) catch return null;
            }
        }
    }

    if (lookups.items.len == 0) return &.{};
    return lookups.toOwnedSlice(allocator) catch null;
}

fn containsU16(values: []const u16, needle: u16) bool {
    for (values) |value| {
        if (value == needle) return true;
    }
    return false;
}

fn hasRange(data: []const u8, offset: usize, len: usize) bool {
    return offset <= data.len and len <= data.len - offset;
}

fn readU16(data: []const u8, offset: usize) ?u16 {
    if (!hasRange(data, offset, 2)) return null;
    return (@as(u16, data[offset]) << 8) | data[offset + 1];
}

fn readI16(data: []const u8, offset: usize) ?i16 {
    return @bitCast(readU16(data, offset) orelse return null);
}

fn readI8(data: []const u8, offset: usize) ?i16 {
    if (!hasRange(data, offset, 1)) return null;
    return @as(i16, @as(i8, @bitCast(data[offset])));
}

fn readU32(data: []const u8, offset: usize) ?u32 {
    if (!hasRange(data, offset, 4)) return null;
    return (@as(u32, data[offset]) << 24) |
        (@as(u32, data[offset + 1]) << 16) |
        (@as(u32, data[offset + 2]) << 8) |
        data[offset + 3];
}

fn f2dot14ToF32(value: i16) f32 {
    return @as(f32, @floatFromInt(value)) / 16384.0;
}

fn valueRecordSize(format: u16) usize {
    var size: usize = 0;
    if ((format & 0x0001) != 0) size += 2;
    if ((format & 0x0002) != 0) size += 2;
    if ((format & 0x0004) != 0) size += 2;
    if ((format & 0x0008) != 0) size += 2;
    if ((format & 0x0010) != 0) size += 2;
    if ((format & 0x0020) != 0) size += 2;
    if ((format & 0x0040) != 0) size += 2;
    if ((format & 0x0080) != 0) size += 2;
    return size;
}

fn valueRecordAdvanceAdjust(data: []const u8, offset: usize, format: u16, side: PairAdjustSide) i32 {
    var cursor = offset;
    var x_placement: i16 = 0;
    var x_advance: i16 = 0;

    if ((format & 0x0001) != 0) {
        x_placement = readI16(data, cursor) orelse return 0;
        cursor += 2;
    }
    if ((format & 0x0002) != 0) cursor += 2;
    if ((format & 0x0004) != 0) {
        x_advance = readI16(data, cursor) orelse return 0;
        cursor += 2;
    }
    if ((format & 0x0008) != 0) cursor += 2;
    if ((format & 0x0010) != 0) cursor += 2;
    if ((format & 0x0020) != 0) cursor += 2;
    if ((format & 0x0040) != 0) cursor += 2;
    if ((format & 0x0080) != 0) cursor += 2;

    return switch (side) {
        .first => x_advance,
        .second => x_placement,
    };
}

fn pairSetAdjustment(data: []const u8, pair_set: usize, value_format_1: u16, value_format_2: u16, right_glyph: u32) i32 {
    const pair_value_count = readU16(data, pair_set) orelse return 0;
    const value_size_1 = valueRecordSize(value_format_1);
    const value_size_2 = valueRecordSize(value_format_2);
    const record_size = 2 + value_size_1 + value_size_2;

    var lo: usize = 0;
    var hi: usize = pair_value_count;
    while (lo < hi) {
        const mid = lo + (hi - lo) / 2;
        const record = pair_set + 2 + mid * record_size;
        const second_glyph = readU16(data, record) orelse return 0;
        if (right_glyph > second_glyph) {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }
    if (lo >= pair_value_count) return 0;

    const record = pair_set + 2 + lo * record_size;
    const second_glyph = readU16(data, record) orelse return 0;
    if (second_glyph != right_glyph) return 0;

    const value_1_offset = record + 2;
    const value_2_offset = value_1_offset + value_size_1;
    return valueRecordAdvanceAdjust(data, value_1_offset, value_format_1, .first) +
        valueRecordAdvanceAdjust(data, value_2_offset, value_format_2, .second);
}

fn coverageIndex(data: []const u8, coverage_offset: usize, glyph: u32) ?u16 {
    const format = readU16(data, coverage_offset) orelse return null;
    return switch (format) {
        1 => blk: {
            const glyph_count = readU16(data, coverage_offset + 2) orelse break :blk null;
            var lo: usize = 0;
            var hi: usize = glyph_count;
            while (lo < hi) {
                const mid = lo + (hi - lo) / 2;
                const glyph_id = readU16(data, coverage_offset + 4 + mid * 2) orelse break :blk null;
                if (glyph > glyph_id) {
                    lo = mid + 1;
                } else {
                    hi = mid;
                }
            }
            if (lo >= glyph_count) break :blk null;
            const glyph_id = readU16(data, coverage_offset + 4 + lo * 2) orelse break :blk null;
            if (glyph_id != glyph) break :blk null;
            break :blk @intCast(lo);
        },
        2 => blk: {
            const range_count = readU16(data, coverage_offset + 2) orelse break :blk null;
            var lo: usize = 0;
            var hi: usize = range_count;
            while (lo < hi) {
                const mid = lo + (hi - lo) / 2;
                const range = coverage_offset + 4 + mid * 6;
                const end = readU16(data, range + 2) orelse break :blk null;
                if (glyph > end) {
                    lo = mid + 1;
                } else {
                    hi = mid;
                }
            }
            if (lo >= range_count) break :blk null;
            const range = coverage_offset + 4 + lo * 6;
            const start = readU16(data, range) orelse break :blk null;
            const end = readU16(data, range + 2) orelse break :blk null;
            const start_index = readU16(data, range + 4) orelse break :blk null;
            if (glyph < start or glyph > end) break :blk null;
            break :blk start_index + @as(u16, @intCast(glyph - start));
        },
        else => null,
    };
}

fn classDefValue(data: []const u8, class_def_offset: usize, glyph: u32) u16 {
    const format = readU16(data, class_def_offset) orelse return 0;
    return switch (format) {
        1 => blk: {
            const start_glyph = readU16(data, class_def_offset + 2) orelse break :blk 0;
            const glyph_count = readU16(data, class_def_offset + 4) orelse break :blk 0;
            if (glyph < start_glyph or glyph >= start_glyph + glyph_count) break :blk 0;
            break :blk readU16(data, class_def_offset + 6 + @as(usize, @intCast(glyph - start_glyph)) * 2) orelse 0;
        },
        2 => blk: {
            const range_count = readU16(data, class_def_offset + 2) orelse break :blk 0;
            for (0..range_count) |range_index| {
                const range = class_def_offset + 4 + range_index * 6;
                const start = readU16(data, range) orelse break :blk 0;
                const end = readU16(data, range + 2) orelse break :blk 0;
                if (glyph < start or glyph > end) continue;
                break :blk readU16(data, range + 4) orelse 0;
            }
            break :blk 0;
        },
        else => 0,
    };
}

// Outline flattening
fn flattenContour(points: []const CurvePoint, transform: Affine, scale: f32, shift_x: f32, shift_y: f32, shape: *RenderShape) !void {
    if (points.len == 0) return;

    var contour = RenderContour{};
    errdefer contour.deinit();

    const first = points[0];
    const last = points[points.len - 1];

    const start = if (first.on_curve)
        first
    else if (last.on_curve)
        last
    else
        midpointPoint(last, first);

    var processed: usize = if (first.on_curve or last.on_curve) 1 else 0;
    var index: usize = if (first.on_curve) 1 else 0;
    var current = start;

    try contour.addPoint(renderPoint(start, transform, scale, shift_x, shift_y));

    while (processed < points.len) {
        const point = points[index % points.len];
        const next = points[(index + 1) % points.len];
        if (point.on_curve) {
            try contour.addPoint(renderPoint(point, transform, scale, shift_x, shift_y));
            current = point;
            index += 1;
            processed += 1;
            continue;
        }

        if (next.on_curve) {
            try appendQuadraticCurve(&contour, current, point, next, transform, scale, shift_x, shift_y);
            current = next;
            index += 2;
            processed += 2;
        } else {
            const mid = midpointPoint(point, next);
            try appendQuadraticCurve(&contour, current, point, mid, transform, scale, shift_x, shift_y);
            current = mid;
            index += 1;
            processed += 1;
        }
    }

    if (contour.points.items.len >= 2) {
        try shape.contours.append(allocator, contour);
    } else {
        contour.deinit();
    }
}

fn midpointPoint(a: CurvePoint, b: CurvePoint) CurvePoint {
    return .{
        .x = (a.x + b.x) * 0.5,
        .y = (a.y + b.y) * 0.5,
        .on_curve = true,
    };
}

fn renderPoint(point: CurvePoint, transform: Affine, scale: f32, shift_x: f32, shift_y: f32) Vec2 {
    const font_x = transform.xx * point.x + transform.xy * point.y + transform.dx;
    const font_y = transform.yx * point.x + transform.yy * point.y + transform.dy;
    return .{
        .x = font_x * scale + shift_x,
        .y = -font_y * scale + shift_y,
    };
}

fn quadraticBezierPoint(p0: Vec2, p1: Vec2, p2: Vec2, t: f32) Vec2 {
    const omt = 1.0 - t;
    const omt2 = omt * omt;
    const t2 = t * t;
    return .{
        .x = omt2 * p0.x + 2.0 * omt * t * p1.x + t2 * p2.x,
        .y = omt2 * p0.y + 2.0 * omt * t * p1.y + t2 * p2.y,
    };
}

fn appendQuadraticCurve(contour: *RenderContour, p0: CurvePoint, p1: CurvePoint, p2: CurvePoint, transform: Affine, scale: f32, shift_x: f32, shift_y: f32) !void {
    const rp0 = renderPoint(p0, transform, scale, shift_x, shift_y);
    const rp1 = renderPoint(p1, transform, scale, shift_x, shift_y);
    const rp2 = renderPoint(p2, transform, scale, shift_x, shift_y);
    const segments = bezierSegmentCount(&.{ rp0, rp1, rp2 }, 6, 64);
    var segment: i32 = 1;
    while (segment <= segments) : (segment += 1) {
        const t = @as(f32, @floatFromInt(segment)) / @as(f32, @floatFromInt(segments));
        try contour.addPoint(quadraticBezierPoint(rp0, rp1, rp2, t));
    }
}

fn bezierSegmentCount(points: []const Vec2, min_segments: i32, max_segments: i32) i32 {
    var poly_len: f32 = 0.0;
    for (points[0 .. points.len - 1], 0..) |point, index| {
        poly_len += @sqrt(lengthSqr(subVec2(points[index + 1], point)));
    }
    const chord = @sqrt(lengthSqr(subVec2(points[points.len - 1], points[0])));
    const curvature = @max(0.0, poly_len - chord);
    const estimate = @ceil(chord * 0.12 + curvature * 0.35);
    return std.math.clamp(@as(i32, @intFromFloat(estimate)), min_segments, max_segments);
}

fn subVec2(a: Vec2, b: Vec2) Vec2 {
    return .{
        .x = a.x - b.x,
        .y = a.y - b.y,
    };
}

fn lengthSqr(v: Vec2) f32 {
    return v.x * v.x + v.y * v.y;
}

fn approxEqual(a: f32, b: f32, eps: f32) bool {
    return @abs(a - b) < eps;
}

fn computeShapeBounds(shape: *const RenderShape) ?ShapeBounds {
    var found = false;
    var bounds = ShapeBounds{
        .min_x = 0.0,
        .min_y = 0.0,
        .max_x = 0.0,
        .max_y = 0.0,
    };

    for (shape.contours.items) |contour| {
        for (contour.points.items) |point| {
            if (!found) {
                found = true;
                bounds = .{
                    .min_x = point.x,
                    .min_y = point.y,
                    .max_x = point.x,
                    .max_y = point.y,
                };
            } else {
                bounds.min_x = @min(bounds.min_x, point.x);
                bounds.min_y = @min(bounds.min_y, point.y);
                bounds.max_x = @max(bounds.max_x, point.x);
                bounds.max_y = @max(bounds.max_y, point.y);
            }
        }
    }

    return if (found) bounds else null;
}

// Scan conversion
fn rasterizeShapeIntoAlpha(alpha: []u8, width: usize, height: usize, shape: *const RenderShape) void {
    @memset(alpha, 0);

    const sample_count = raster_grid * raster_grid;
    const inv_grid = 1.0 / @as(f32, @floatFromInt(raster_grid));

    for (0..height) |row| {
        for (0..width) |col| {
            var covered: usize = 0;
            for (0..raster_grid) |sy| {
                for (0..raster_grid) |sx| {
                    const sample = Vec2{
                        .x = @as(f32, @floatFromInt(col)) + (@as(f32, @floatFromInt(sx)) + 0.5) * inv_grid,
                        .y = @as(f32, @floatFromInt(row)) + (@as(f32, @floatFromInt(sy)) + 0.5) * inv_grid,
                    };
                    if (pointInShapeNonZero(shape, sample)) covered += 1;
                }
            }
            if (covered == 0) continue;
            alpha[row * width + col] = @intCast(@divTrunc(covered * 255, sample_count));
        }
    }
}

fn pointInShapeNonZero(shape: *const RenderShape, sample: Vec2) bool {
    var winding: i32 = 0;
    for (shape.contours.items) |contour| {
        winding += contourWindingNumber(contour.points.items, sample);
    }
    return winding != 0;
}

fn contourWindingNumber(contour: []const Vec2, sample: Vec2) i32 {
    if (contour.len < 3) return 0;

    var winding: i32 = 0;
    var previous_index = contour.len - 1;
    for (contour, 0..) |point, index| {
        const previous = contour[previous_index];
        if (previous.y <= sample.y) {
            if (point.y > sample.y) {
                if (edgeSide(previous, point, sample) > 0) winding += 1;
            }
        } else {
            if (point.y <= sample.y) {
                if (edgeSide(previous, point, sample) < 0) winding -= 1;
            }
        }
        previous_index = index;
    }
    return winding;
}

fn edgeSide(p0: Vec2, p1: Vec2, sample: Vec2) f32 {
    return (p1.x - p0.x) * (sample.y - p0.y) - (sample.x - p0.x) * (p1.y - p0.y);
}
