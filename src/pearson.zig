pub const Pearson = struct {
    table: [256]u8,
    hash: u8,
    const Self = @This();

    pub fn init(table: [256]u8) Self {
        return Self{ .table = table, .hash = 0 };
    }

    pub fn update(self: *Self, input: []u8) void {
        for (input) |byte| {
            self.hash = self.table[self.hash ^ byte];
        }
    }

    pub fn final(self: *Self) u8 {
        return self.hash;
    }
};
