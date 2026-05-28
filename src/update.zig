// DNS TXT update checker
const std = @import("std");

const app_version = @import("version");
const c = @import("win32.zig");

const UPDATE_DNS_RELEASE = "_getver-efu.dynamibyte.com";
const UPDATE_DNS_PREVIEW = "_getver-efup.dynamibyte.com";
const UPDATE_DNS_SERVERS = [_][4]u8{
    .{ 1, 1, 1, 1 },
    .{ 1, 0, 0, 1 },
};
const DNS_TYPE_TXT: u16 = 16;
const DNS_CLASS_IN: u16 = 1;

// Version parsing and comparison
const VersionTextKind = enum {
    release,
    preview_feed,

    fn accepts(self: VersionTextKind, part_count: u8) bool {
        return switch (self) {
            .release => part_count == 3,
            .preview_feed => part_count == 3 or part_count == 4,
        };
    }
};

pub const VersionNumber = struct {
    parts: [4]u32 = .{ 0, 0, 0, 0 },
    part_count: u8 = 0,
    text: [32]u8 = [_]u8{0} ** 32,
    text_len: usize = 0,

    pub fn slice(self: *const VersionNumber) []const u8 {
        return self.text[0..self.text_len];
    }
};

fn parseVersionText(raw: []const u8, kind: VersionTextKind) ?VersionNumber {
    var text = std.mem.trim(u8, raw, " \t\r\n");
    text = app_version.trimVersionPrefix(text);
    if (text.len == 0 or text.len > 32) return null;

    var version = VersionNumber{};
    var start: usize = 0;
    var count: u8 = 0;
    while (true) {
        if (count >= 4) return null;
        const end = std.mem.indexOfScalarPos(u8, text, start, '.') orelse text.len;
        const part = text[start..end];
        if (part.len == 0) return null;

        var value: u32 = 0;
        for (part) |ch| {
            if (ch < '0' or ch > '9') return null;
            value = std.math.mul(u32, value, 10) catch return null;
            value = std.math.add(u32, value, ch - '0') catch return null;
        }

        version.parts[count] = value;
        count += 1;
        if (end == text.len) break;
        start = end + 1;
    }

    if (!kind.accepts(count)) return null;
    if (count == 4 and version.parts[2] != 0) return null;
    version.part_count = count;
    @memcpy(version.text[0..text.len], text);
    version.text_len = text.len;
    return version;
}

fn currentBuildIsPreview() bool {
    return app_version.parsed_version[3] != 0;
}

fn currentVersionPartCount() u8 {
    return if (currentBuildIsPreview()) 4 else 3;
}

fn currentVersionTextKind() VersionTextKind {
    return if (currentBuildIsPreview()) .preview_feed else .release;
}

pub fn current() VersionNumber {
    var version = VersionNumber{
        .parts = app_version.parsed_version,
        .part_count = currentVersionPartCount(),
    };
    const text = if (version.part_count == 4)
        std.fmt.bufPrint(&version.text, "{d}.{d}.{d}.{d}", .{ version.parts[0], version.parts[1], version.parts[2], version.parts[3] }) catch unreachable
    else
        std.fmt.bufPrint(&version.text, "{d}.{d}.{d}", .{ version.parts[0], version.parts[1], version.parts[2] }) catch unreachable;
    version.text_len = text.len;
    return version;
}

fn versionIsGreater(a: VersionNumber, b: VersionNumber) bool {
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        if (a.parts[i] > b.parts[i]) return true;
        if (a.parts[i] < b.parts[i]) return false;
    }

    if (a.part_count == 3 and b.part_count == 4) return true;
    if (a.part_count == 4 and b.part_count == 3) return false;
    if (a.part_count == 4 and b.part_count == 4) {
        if (a.parts[3] > b.parts[3]) return true;
        if (a.parts[3] < b.parts[3]) return false;
    }

    return false;
}

// Minimal DNS packet helpers
fn ip4AddressValue(server_ip: [4]u8) c.DWORD {
    return @as(c.DWORD, server_ip[0]) |
        (@as(c.DWORD, server_ip[1]) << 8) |
        (@as(c.DWORD, server_ip[2]) << 16) |
        (@as(c.DWORD, server_ip[3]) << 24);
}

fn dnsBe16(value: u16) u16 {
    return (value << 8) | (value >> 8);
}

fn writeDnsU16(buf: []u8, offset: usize, value: u16) void {
    buf[offset] = @truncate(value >> 8);
    buf[offset + 1] = @truncate(value);
}

fn readDnsU16(buf: []const u8, offset: usize) ?u16 {
    if (offset + 2 > buf.len) return null;
    return (@as(u16, buf[offset]) << 8) | buf[offset + 1];
}

fn appendDnsName(packet: []u8, offset: *usize, name: []const u8) bool {
    var start: usize = 0;
    while (start <= name.len) {
        const end = std.mem.indexOfScalarPos(u8, name, start, '.') orelse name.len;
        const label = name[start..end];
        if (label.len == 0 or label.len > 63 or offset.* + 1 + label.len >= packet.len) return false;
        packet[offset.*] = @intCast(label.len);
        offset.* += 1;
        @memcpy(packet[offset.* .. offset.* + label.len], label);
        offset.* += label.len;
        if (end == name.len) break;
        start = end + 1;
    }

    if (offset.* >= packet.len) return false;
    packet[offset.*] = 0;
    offset.* += 1;
    return true;
}

fn buildDnsTxtQuery(packet: []u8, query_id: u16, name: []const u8) ?usize {
    if (packet.len < 12) return null;
    @memset(packet[0..12], 0);
    writeDnsU16(packet, 0, query_id);
    writeDnsU16(packet, 2, 0x0100);
    writeDnsU16(packet, 4, 1);

    var offset: usize = 12;
    if (!appendDnsName(packet, &offset, name)) return null;
    if (offset + 4 > packet.len) return null;
    writeDnsU16(packet, offset, DNS_TYPE_TXT);
    writeDnsU16(packet, offset + 2, DNS_CLASS_IN);
    return offset + 4;
}

fn skipDnsName(packet: []const u8, start: usize) ?usize {
    var offset = start;
    while (true) {
        if (offset >= packet.len) return null;
        const len = packet[offset];
        if ((len & 0xC0) == 0xC0) {
            if (offset + 2 > packet.len) return null;
            return offset + 2;
        }
        if ((len & 0xC0) != 0) return null;
        offset += 1;
        if (len == 0) return offset;
        offset += len;
        if (offset > packet.len) return null;
    }
}

fn parseDnsTxtRdata(packet: []const u8, start: usize, end: usize, kind: VersionTextKind) ?VersionNumber {
    var offset = start;
    while (offset < end) {
        const len = packet[offset];
        offset += 1;
        const text_end = offset + len;
        if (text_end > end) return null;
        if (parseVersionText(packet[offset..text_end], kind)) |version| return version;
        offset = text_end;
    }
    return null;
}

fn parseDnsTxtResponse(packet: []const u8, query_id: u16, kind: VersionTextKind) ?VersionNumber {
    if (packet.len < 12) return null;
    if ((readDnsU16(packet, 0) orelse return null) != query_id) return null;
    const flags = readDnsU16(packet, 2) orelse return null;
    if ((flags & 0x8000) == 0 or (flags & 0x000F) != 0) return null;

    const question_count = readDnsU16(packet, 4) orelse return null;
    const answer_count = readDnsU16(packet, 6) orelse return null;
    var offset: usize = 12;

    var question_index: u16 = 0;
    while (question_index < question_count) : (question_index += 1) {
        offset = skipDnsName(packet, offset) orelse return null;
        if (offset + 4 > packet.len) return null;
        offset += 4;
    }

    var answer_index: u16 = 0;
    while (answer_index < answer_count) : (answer_index += 1) {
        offset = skipDnsName(packet, offset) orelse return null;
        if (offset + 10 > packet.len) return null;
        const record_type = readDnsU16(packet, offset) orelse return null;
        const record_class = readDnsU16(packet, offset + 2) orelse return null;
        const rdlength = readDnsU16(packet, offset + 8) orelse return null;
        const rdata_start = offset + 10;
        const rdata_end = rdata_start + rdlength;
        if (rdata_end > packet.len) return null;
        if (record_type == DNS_TYPE_TXT and record_class == DNS_CLASS_IN) {
            if (parseDnsTxtRdata(packet, rdata_start, rdata_end, kind)) |version| return version;
        }
        offset = rdata_end;
    }

    return null;
}

// DNS TXT lookup
fn queryLatestVersionFromDnsServer(name: []const u8, kind: VersionTextKind, server_ip: [4]u8) ?VersionNumber {
    var wsa_data: c.WSADATA = undefined;
    if (c.WSAStartup(0x0202, &wsa_data) != 0) return null;
    defer _ = c.WSACleanup();

    const sock = c.socket(c.AF_INET, c.SOCK_DGRAM, c.IPPROTO_UDP);
    if (sock == c.INVALID_SOCKET) return null;
    defer _ = c.closesocket(sock);

    var timeout_ms: c.DWORD = 1800;
    _ = c.setsockopt(sock, c.SOL_SOCKET, c.SO_RCVTIMEO, &timeout_ms, @intCast(@sizeOf(c.DWORD)));

    var server_addr = c.SOCKADDR_IN{
        .sin_family = @intCast(c.AF_INET),
        .sin_port = dnsBe16(53),
        .sin_addr = ip4AddressValue(server_ip),
        .sin_zero = [_]u8{0} ** 8,
    };

    var query_packet: [512]u8 = undefined;
    var response_packet: [512]u8 = undefined;
    var query_id: u16 = @truncate(c.GetTickCount64());
    query_id ^= (@as(u16, server_ip[0]) << 8) | server_ip[3];
    if (query_id == 0) query_id = 1;

    const query_len = buildDnsTxtQuery(&query_packet, query_id, name) orelse return null;
    const sent = c.sendto(sock, &query_packet, @intCast(query_len), 0, @ptrCast(&server_addr), @intCast(@sizeOf(c.SOCKADDR_IN)));
    if (sent != @as(c.INT, @intCast(query_len))) return null;

    const received = c.recvfrom(sock, &response_packet, response_packet.len, 0, null, null);
    if (received <= 0) return null;
    return parseDnsTxtResponse(response_packet[0..@intCast(received)], query_id, kind);
}

fn queryLatestVersionFromDns() ?VersionNumber {
    const name = if (currentBuildIsPreview()) UPDATE_DNS_PREVIEW else UPDATE_DNS_RELEASE;
    const kind = currentVersionTextKind();
    for (UPDATE_DNS_SERVERS) |server_ip| {
        if (queryLatestVersionFromDnsServer(name, kind, server_ip)) |version| return version;
    }

    return null;
}

pub fn latestAvailable() ?VersionNumber {
    const current_version = current();
    const latest = queryLatestVersionFromDns() orelse return null;
    return if (versionIsGreater(latest, current_version)) latest else null;
}
