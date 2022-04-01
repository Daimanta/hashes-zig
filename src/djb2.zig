const std = @import("std");
const testing = std.testing;

pub const Djb2 = struct {
    hash: u64,
    const Self = @This();
    
    
    pub fn init() Self {
                return Self {.hash = 5381};
    }
    
    pub fn update(self: *Self, input:[]const u8) void {
        for (input) |byte| {
            self.hash = self.hash *% 33 +% byte;
        }
    }
    
    pub fn final(self: *Self) u64 {
        return self.hash;
    }
};

test "example string 1" {
    var djb2 = Djb2.init();
    djb2.update("Hello");
    const result = djb2.final();
    
    const expected: u64 = 210676686969;
    try testing.expectEqual(result, expected);
}

test "example string 2" {
    var djb2 = Djb2.init();
    djb2.update("Hello!");
    const result = djb2.final();
    
    const expected: u64 = 6952330670010;
    try testing.expectEqual(result, expected);
}
