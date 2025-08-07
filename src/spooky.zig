const std = @import("std");

const SPOOKYHASH_VARIABLES = 12;
const SPOOKYHASH_BLOCK_SIZE = SPOOKYHASH_VARIABLES * 8;
const SPOOKYHASH_BUFFER_SIZE = 2 * SPOOKYHASH_BLOCK_SIZE;
const SPOOKYHASH_CONSTANT = 0xdeadbeefdeadbeef;

// pub const Spooky = struct {
//     m_data: [2 * SPOOKYHASH_VARIABLES]u64,
//     m_state: [SPOOKYHASH_VARIABLES]u64,
//     m_length: usize,
//     m_remained: u8
// };


pub const Spooky128Result = struct {
    hash1: u64,
    hash2: u64
};

pub fn spookyhash_32(data: []const u8, seed: u32) u32 {
    const result = spookyhash_128(data, seed, seed);
    return @truncate(result.hash1);
}

pub fn spookyhash_64(data: []const u8, seed: u64) u64 {
    const result = spookyhash_128(data, seed, seed);
    return result.hash1;
}

fn spookyhash_short(data: []const u8, seed1: u64, seed2: u64) Spooky128Result {
    var remainder = data.len % 32;

    var a = seed1;
    var b = seed2;
    var c: u64 = SPOOKYHASH_CONSTANT;
    var d: u64 = SPOOKYHASH_CONSTANT;

    var i: usize = 0;
    if (data.len > 15) {
        const cast:[] align(1) const u64 = @ptrCast(data[0..((data.len/8)*8)]);
        const end = (data.len / 32) * 4;

        while (i < end): (i += 4) {
            c +%= cast[i];
            d +%= cast[i + 1];
            spookyhash_short_mix(&a, &b, &c, &d);
            a +%= cast[i + 2];
            b +%= cast[i + 3];
        }

        if (remainder >= 16) {
            c +%= cast[i];
            d +%= cast[i + 1];
            spookyhash_short_mix(&a, &b, &c, &d);
            i += 2;
            remainder -= 16;
        }
    }

    const start_index = i * 8;
    const remaining_data8 = data[start_index..];
    const remaining_data32: [] align(1) const u32 = @ptrCast(remaining_data8[0..((remaining_data8.len/4)*4)]);
    const remaining_data64: [] align(1) const u64 = @ptrCast(remaining_data8[0..((remaining_data8.len/8)*8)]);

    d +%= data.len << 56;
    if (remainder == 15) {
        d +%= @as(u64, remaining_data8[14]) << 48;
        d +%= @as(u64, remaining_data8[13]) << 40;
        d +%= @as(u64, remaining_data8[12]) << 32;
        d +%= remaining_data32[2];
        c +%= remaining_data64[0];
    } else if (remainder == 14) {
        d +%= @as(u64, remaining_data8[13]) << 40;
        d +%= @as(u64, remaining_data8[12]) << 32;
        d +%= remaining_data32[2];
        c +%= remaining_data64[0];
    } else if (remainder == 13) {
        d +%= @as(u64, remaining_data8[12]) << 32;
        d +%= remaining_data32[2];
        c +%= remaining_data64[0];
    } else if (remainder == 12) {
        d +%= remaining_data32[2];
        c +%= remaining_data64[0];
    } else if (remainder == 11) {
        d +%= @as(u64, remaining_data8[10]) << 16;
        d +%= @as(u64, remaining_data8[9]) << 8;
        d +%= @as(u64, remaining_data8[8]);
        c +%= remaining_data64[0];
    } else if (remainder == 10) {
        d +%= @as(u64, remaining_data8[9]) << 8;
        d +%= @as(u64, remaining_data8[8]);
        c +%= remaining_data64[0];
    } else if (remainder == 9) {
        d +%= @as(u64, remaining_data8[8]);
        c +%= remaining_data64[0];
    } else if (remainder == 8) {
        c +%= remaining_data64[0];
    } else if (remainder == 7) {
        c +%= @as(u64, remaining_data8[6]) << 48;
        c +%= @as(u64, remaining_data8[5]) << 40;
        c +%= @as(u64, remaining_data8[4]) << 32;
        c +%= remaining_data32[0];
    } else if (remainder == 6) {
        c +%= @as(u64, remaining_data8[5]) << 40;
        c +%= @as(u64, remaining_data8[4]) << 32;
        c +%= remaining_data32[0];
    } else if (remainder == 5) {
        c +%= @as(u64, remaining_data8[4]) << 32;
        c +%= remaining_data32[0];
    } else if (remainder == 4) {
        c +%= remaining_data32[0];
    } else if (remainder == 3) {
        c +%= @as(u64, remaining_data8[2]) << 16;
        c +%= @as(u64, remaining_data8[1]) << 8;
        c +%= @as(u64, remaining_data8[0]);
    } else if (remainder == 2) {
        c +%= @as(u64, remaining_data8[1]) << 8;
        c +%= @as(u64, remaining_data8[0]);
    } else if (remainder == 1) {
        c +%= @as(u64, remaining_data8[0]);
    } else if (remainder == 0) {
        c +%= SPOOKYHASH_CONSTANT;
        d +%= SPOOKYHASH_CONSTANT;
    } else {
        unreachable;
    }

    spookyhash_short_end(&a, &b, &c, &d);

    return Spooky128Result{.hash1 = a, .hash2 = b};

}

pub fn spookyhash_128(data: []const u8, seed1: u64, seed2: u64) Spooky128Result {
    if (data.len < SPOOKYHASH_BUFFER_SIZE) {
        return spookyhash_short(data, seed1, seed2);
    }
    var h0: u64 = seed1;
    var h1: u64 = seed2;
    var h2: u64 = SPOOKYHASH_CONSTANT;
    var h3: u64 = seed1;
    var h4: u64 = seed2;
    var h5: u64 = SPOOKYHASH_CONSTANT;
    var h6: u64 = seed1;
    var h7: u64 = seed2;
    var h8: u64 = SPOOKYHASH_CONSTANT;
    var h9: u64 = seed1;
    var h10: u64 = seed2;
    var h11: u64 = SPOOKYHASH_CONSTANT;

    const data_64: []align(1) const u64 = @ptrCast(data[0..((data.len/8)*8)]);
    var i: usize = 0;
    const limit = data.len / SPOOKYHASH_BLOCK_SIZE;
    while (i < limit): (i += 1) {
        const j = i * 12;
        spookyhash_mix(data_64[j..j+12], &h0, &h1, &h2, &h3, &h4, &h5, &h6, &h7, &h8, &h9, &h10, &h11);
    }

    const remainder = data.len - (i * SPOOKYHASH_BLOCK_SIZE);
    const start_index = data.len - remainder;
    var buf: [SPOOKYHASH_VARIABLES]u64 = [1]u64{0} ** SPOOKYHASH_VARIABLES;
    var buf8: []u8 = @ptrCast(buf[0..]);
    @memcpy(buf8[0..remainder], data[start_index..]);
    buf8[buf8.len - 1] = @intCast(remainder);
    _ = &buf8; _ = &buf;

    spookyhash_end(buf, &h0, &h1, &h2, &h3, &h4, &h5, &h6, &h7, &h8, &h9, &h10, &h11);
    return Spooky128Result{.hash1 = h0, .hash2 = h1};
}

fn spookyhash_end(data: [SPOOKYHASH_VARIABLES]u64, h0: *u64, h1: *u64, h2: *u64, h3: *u64, h4: *u64, h5: *u64, h6: *u64, h7: *u64, h8: *u64, h9: *u64, h10: *u64, h11: *u64) void {
    h0.* +%= data[0];
    h1.* +%= data[1];
    h2.* +%= data[2];
    h3.* +%= data[3];
    h4.* +%= data[4];
    h5.* +%= data[5];
    h6.* +%= data[6];
    h7.* +%= data[7];
    h8.* +%= data[8];
    h9.* +%= data[9];
    h10.* +%= data[10];
    h11.* +%= data[11];
    spookyhash_end_partial(h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11);
    spookyhash_end_partial(h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11);
    spookyhash_end_partial(h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11);
}

fn spookyhash_end_partial( h0: *u64, h1: *u64, h2: *u64, h3: *u64, h4: *u64, h5: *u64, h6: *u64, h7: *u64, h8: *u64, h9: *u64, h10: *u64, h11: *u64) void {
    h11.* +%= h1.*;
    h2.* ^= h11.*;
    SPOOKYHASH_ROTATE(h1, 44);
    h0.* +%= h2.*;
    h3.* ^= h0.*;
    SPOOKYHASH_ROTATE(h2, 15);
    h1.* +%= h3.*;
    h4.* ^= h1.*;
    SPOOKYHASH_ROTATE(h3, 34);
    h2.* +%= h4.*;
    h5.* ^= h2.*;
    SPOOKYHASH_ROTATE(h4, 21);
    h3.* +%= h5.*;
    h6.* ^= h3.*;
    SPOOKYHASH_ROTATE(h5, 38);
    h4.* +%= h6.*;
    h7.* ^= h4.*;
    SPOOKYHASH_ROTATE(h6, 33);
    h5.* +%= h7.*;
    h8.* ^= h5.*;
    SPOOKYHASH_ROTATE(h7, 10);
    h6.* +%= h8.*;
    h9.* ^= h6.*;
    SPOOKYHASH_ROTATE(h8, 13);
    h7.* +%= h9.*;
    h10.* ^= h7.*;
    SPOOKYHASH_ROTATE(h9, 38);
    h8.* +%= h10.*;
    h11.* ^= h8.*;
    SPOOKYHASH_ROTATE(h10, 53);
    h9.* +%= h11.*;
    h0.* ^= h9.*;
    SPOOKYHASH_ROTATE(h11, 42);
    h10.* +%= h0.*;
    h1.* ^= h10.*;
    SPOOKYHASH_ROTATE(h0, 54);
}

fn spookyhash_mix(data: []const align(1) u64, s0: *u64, s1: *u64, s2: *u64, s3: *u64, s4: *u64, s5: *u64, s6: *u64, s7: *u64, s8: *u64, s9: *u64, s10: *u64, s11: *u64) void {
    s0.* +%= data[0];
    s2.* ^= s10.*;
    s11.* ^= s0.*;
    SPOOKYHASH_ROTATE(s0, 11);
    s11.* +%= s1.*;
    s1.* +%= data[1];
    s3.* ^= s11.*;
    s0.* ^= s1.*;
    SPOOKYHASH_ROTATE(s1, 32);
    s0.* +%= s2.*;
    s2.* +%= data[2];
    s4.* ^= s0.*;
    s1.* ^= s2.*;
    SPOOKYHASH_ROTATE(s2, 43);
    s1.* +%= s3.*;
    s3.* +%= data[3];
    s5.* ^= s1.*;
    s2.* ^= s3.*;
    SPOOKYHASH_ROTATE(s3, 31);
    s2.* +%= s4.*;
    s4.* +%= data[4];
    s6.* ^= s2.*;
    s3.* ^= s4.*;
    SPOOKYHASH_ROTATE(s4, 17);
    s3.* +%= s5.*;
    s5.* +%= data[5];
    s7.* ^= s3.*;
    s4.* ^= s5.*;
    SPOOKYHASH_ROTATE(s5, 28);
    s4.* +%= s6.*;
    s6.* +%= data[6];
    s8.* ^= s4.*;
    s5.* ^= s6.*;
    SPOOKYHASH_ROTATE(s6, 39);
    s5.* +%= s7.*;
    s7.* +%= data[7];
    s9.* ^= s5.*;
    s6.* ^= s7.*;
    SPOOKYHASH_ROTATE(s7, 57);
    s6.* +%= s8.*;
    s8.* +%= data[8];
    s10.* ^= s6.*;
    s7.* ^= s8.*;
    SPOOKYHASH_ROTATE(s8, 55);
    s7.* +%= s9.*;
    s9.* +%= data[9];
    s11.* ^= s7.*;
    s8.* ^= s9.*;
    SPOOKYHASH_ROTATE(s9, 54);
    s8.* +%= s10.*;
    s10.* +%= data[10];
    s0.* ^= s8.*;
    s9.* ^= s10.*;
    SPOOKYHASH_ROTATE(s10, 22);
    s9.* +%= s11.*;
    s11.* +%= data[11];
    s1.* ^= s9.*;
    s10.* ^= s11.*;
    SPOOKYHASH_ROTATE(s11, 46);
    s10.* += s0.*;
}

fn spookyhash_short_mix(h0: *u64, h1: *u64, h2: *u64, h3: *u64) void {
    SPOOKYHASH_ROTATE(h2, 50);
    h2.* +%= h3.*;
    h0.* ^= h2.*;
    SPOOKYHASH_ROTATE(h3, 52);
    h3.* +%= h0.*;
    h1.* ^= h3.*;
    SPOOKYHASH_ROTATE(h0, 30);
    h0.* +%= h1.*;
    h2.* ^= h0.*;
    SPOOKYHASH_ROTATE(h1, 41);
    h1.* +%= h2.*;
    h3.* ^= h1.*;
    SPOOKYHASH_ROTATE(h2, 54);
    h2.* +%= h3.*;
    h0.* ^= h2.*;
    SPOOKYHASH_ROTATE(h3, 48);
    h3.* +%= h0.*;
    h1.* ^= h3.*;
    SPOOKYHASH_ROTATE(h0, 38);
    h0.* +%= h1.*;
    h2.* ^= h0.*;
    SPOOKYHASH_ROTATE(h1, 37);
    h1.* +%= h2.*;
    h3.* ^= h1.*;
    SPOOKYHASH_ROTATE(h2, 62);
    h2.* +%= h3.*;
    h0.* ^= h2.*;
    SPOOKYHASH_ROTATE(h3, 34);
    h3.* +%= h0.*;
    h1.* ^= h3.*;
    SPOOKYHASH_ROTATE(h0, 5);
    h0.* +%= h1.*;
    h2.* ^= h0.*;
    SPOOKYHASH_ROTATE(h1, 36);
    h1.* +%= h2.*;
    h3.* ^= h1.*;
}

fn spookyhash_short_end(h0: *u64, h1: *u64, h2: *u64, h3: *u64) void {
    h3.* ^= h2.*;
    SPOOKYHASH_ROTATE(h2, 15);
    h3.* +%= h2.*;
    h0.* ^= h3.*;
    SPOOKYHASH_ROTATE(h3, 52);
    h0.* +%= h3.*;
    h1.* ^= h0.*;
    SPOOKYHASH_ROTATE(h0, 26);
    h1.* +%= h0.*;
    h2.* ^= h1.*;
    SPOOKYHASH_ROTATE(h1, 51);
    h2.* +%= h1.*;
    h3.* ^= h2.*;
    SPOOKYHASH_ROTATE(h2, 28);
    h3.* +%= h2.*;
    h0.* ^= h3.*;
    SPOOKYHASH_ROTATE(h3, 9);
    h0.* +%= h3.*;
    h1.* ^= h0.*;
    SPOOKYHASH_ROTATE(h0, 47);
    h1.* +%= h0.*;
    h2.* ^= h1.*;
    SPOOKYHASH_ROTATE(h1, 54);
    h2.* +%= h1.*;
    h3.* ^= h2.*;
    SPOOKYHASH_ROTATE(h2, 32);
    h3.* +%= h2.*;
    h0.* ^= h3.*;
    SPOOKYHASH_ROTATE(h3, 25);
    h0.* +%= h3.*;
    h1.* ^= h0.*;
    SPOOKYHASH_ROTATE(h0, 63);
    h1.* +%= h0.*;
}

fn SPOOKYHASH_ROTATE(x: *u64, k: u6) void {
    const inv: u7 = 64 - @as(u7, k);
    x.* = x.* << k | (x.* >> (@as(u6, @intCast(inv))));
}

test "hello world" {
    const val32 = spookyhash_32("hello world", 0);
    const expected32 = 2617184861;
    try std.testing.expectEqual(expected32, val32);

    const val64 = spookyhash_64("hello world", 0);
    const expected64 = 14865987102431973981;
    try std.testing.expectEqual(expected64, val64);
}

test "empty" {
    const val32 = spookyhash_32("", 0);
    const expected32 = 1811220761;
    try std.testing.expectEqual(expected32, val32);

    const val64 = spookyhash_64("", 0);
    const expected64 = 2533000996631939353;
    try std.testing.expectEqual(expected64, val64);
}

test "a x 64" {
    const str: []const u8 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    const val32 = spookyhash_32(str, 0);
    const expected32 = 32675606;
    try std.testing.expectEqual(expected32, val32);

    const val64 = spookyhash_64(str, 0);
    const expected64 = 15954390391712814870;
    try std.testing.expectEqual(expected64, val64);
}

test "a x 65" {
    const str: []const u8 = "a" ** 65;
    const val32 = spookyhash_32(str, 0);
    const expected32 = 741746999;
    try std.testing.expectEqual(expected32, val32);

    const val64 = spookyhash_64(str, 0);
    const expected64 = 9069218905359526199;
    try std.testing.expectEqual(expected64, val64);
}

test "a x 63" {
    const str: []const u8 = "a" ** 63;
    const val32 = spookyhash_32(str, 0);
    const expected32 = 4253920923;
    try std.testing.expectEqual(expected32, val32);

    const val64 = spookyhash_64(str, 0);
    const expected64 = 11195677643985759899;
    try std.testing.expectEqual(expected64, val64);
}

test "abcdefhijk x 10" {
    const str: []const u8 = "abcdefhijk" ** 10;
    const val32 = spookyhash_32(str, 0);
    const expected32 = 2546498040;
    try std.testing.expectEqual(expected32, val32);

    const val64 = spookyhash_64(str, 0);
    const expected64 = 14605693340986407416;
    try std.testing.expectEqual(expected64, val64);
}

test "a x 187" {
    const str: []const u8 = "a" ** 202;
    const val32 = spookyhash_32(str, 0);
    const expected32 = 3263301973;
    try std.testing.expectEqual(expected32, val32);

    const val64 = spookyhash_64(str, 0);
    const expected64 = 16263805632858163541;
    try std.testing.expectEqual(expected64, val64);
}