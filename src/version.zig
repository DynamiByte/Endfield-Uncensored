const std = @import("std");

// Shared Version Metadata
pub const version_str = "v4.1.0.2";

pub const parsed_version = parseVersion(version_str);
pub const file_version_rc = std.fmt.comptimePrint("{d},{d},{d},{d}", .{
    parsed_version[0],
    parsed_version[1],
    parsed_version[2],
    parsed_version[3],
});

pub fn hasVersionPrefix(version: []const u8) bool {
    return version.len > 0 and (version[0] == 'v' or version[0] == 'V');
}

pub fn trimVersionPrefix(version: []const u8) []const u8 {
    return if (hasVersionPrefix(version)) version[1..] else version;
}

pub fn normalizedTag(out_buf: []u8, version: []const u8) ![]const u8 {
    if (hasVersionPrefix(version)) return version;
    return std.fmt.bufPrint(out_buf, "v{s}", .{version});
}

fn parseVersion(comptime raw_version: []const u8) [4]u32 {
    const trimmed = trimVersionPrefix(raw_version);

    var values = [_]u32{ 0, 0, 0, 0 };
    var parts = std.mem.splitScalar(u8, trimmed, '.');
    var count: usize = 0;
    while (parts.next()) |part| : (count += 1) {
        if (count >= values.len) {
            @compileError("version_str must have at most four dot-separated numeric parts.");
        }
        values[count] = parseUnsigned(part);
    }

    if (count < 3) {
        @compileError("version_str must have at least three dot-separated numeric parts.");
    }

    return values;
}

fn parseUnsigned(comptime text: []const u8) u32 {
    if (text.len == 0) {
        @compileError("version_str contains an empty numeric part.");
    }

    var value: u32 = 0;
    for (text) |ch| {
        if (ch < '0' or ch > '9') {
            @compileError("version_str may only contain digits and dots after the optional leading 'v'.");
        }
        value = value * 10 + (ch - '0');
    }
    return value;
}
