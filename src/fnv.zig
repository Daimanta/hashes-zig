const std = @import("std");
const testing = std.testing;

const initial_value: u64 = 14695981039346656037;
const prime: u64 = 1099511628211;

pub const Fnv1 = struct {
    hash: u64,
    const Self = @This();

    pub fn init() Self {
        return Self{ .hash = initial_value };
    }

    pub fn update(self: *Self, input: []const u8) void {
        for (input) |byte| {
            self.hash = self.hash *% prime;
            self.hash ^= byte;
        }
    }

    pub fn final(self: *Self) u64 {
        return self.hash;
    }
};

pub const Fnv1a = struct {
    hash: u64,
    const Self = @This();

    pub fn init() Self {
        return Self{ .hash = initial_value };
    }

    pub fn update(self: *Self, input: []const u8) void {
        for (input) |byte| {
            self.hash ^= byte;
            self.hash = self.hash *% prime;
        }
    }

    pub fn final(self: *Self) u64 {
        return self.hash;
    }
};

pub const Fnv0 = struct {
    hash: u64,
    const Self = @This();

    pub fn init() Self {
        return Self{ .hash = 0 };
    }

    pub fn update(self: *Self, input: []const u8) void {
        for (input) |byte| {
            self.hash = self.hash *% prime;
            self.hash ^= byte;
        }
    }

    pub fn final(self: *Self) u64 {
        return self.hash;
    }
};
