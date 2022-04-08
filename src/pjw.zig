const std = @import("std");
const testing = std.testing;

pub const Pjw32 = struct {
    hash: u32,
    const Self = @This();

    pub fn init() Self {
        return Self{ .hash = 0 };
    }

    pub fn update(self: *Self, input: []const u8) void {
        for (input) |byte| {
            self.hash = (self.hash << 4) +% byte;
            const top = 0xF0000000;
            if (self.hash & top != 0) {
                self.hash ^= (self.hash >> 24);
                self.hash &= ~top;
            }
        }
    }

    pub fn final(self: *Self) u64 {
        return self.hash;
    }
};
