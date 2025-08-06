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
    return Spooky128Result{.hash1 = 0, .hash2 = 0};
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