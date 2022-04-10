const std = @import("std");
const testing = std.testing;

pub const Sdbm = struct {
    hash: u32,
    const Self = @This();

    pub fn init() Self {
        return Self{ .hash = 0 };
    }

    pub fn update(self: *Self, input: []const u8) void {
        for (input) |byte| {
            self.hash = byte +% (self.hash << 6) +% (self.hash << 16) -% self.hash;
        }
    }

    pub fn final(self: *Self) u64 {
        return self.hash;
    }
};
