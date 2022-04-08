const std = @import("std");
const testing = std.testing;

pub const Jenkins = struct {
    hash: u32,
    const Self = @This();

    pub fn init() Self {
        return Self{ .hash = 0 };
    }

    pub fn update(self: *Self, input: []const u8) void {
        for (input) |byte| {
            self.hash +%= byte;
            self.hash +%= (self.hash << 10);
            self.hash ^= self.hash >> 6;
        }
    }

    pub fn final(self: *Self) u32 {
        self.hash +%= self.hash << 3;
        self.hash ^= self.hash >> 11;
        self.hash +%= self.hash << 15;
        return self.hash;
    }
};

test "example string 1" {
    var jenkins = Jenkins.init();
    jenkins.update("a");
    const result = jenkins.final();

    const expected: u32 = 0xca2e9442;
    try testing.expectEqual(result, expected);
}

test "example string 2" {
    var jenkins = Jenkins.init();
    jenkins.update("The quick brown fox jumps over the lazy dog");
    const result = jenkins.final();

    const expected: u32 = 0x519e91f5;
    try testing.expectEqual(result, expected);
}
