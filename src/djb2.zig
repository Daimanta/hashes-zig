

pub const Djb2 = struct {
    hash: u8,
    const Self = @This();
    
    
    pub fn init() Self {
                return Self {.hash = 5381};
    }
    
    pub fn update(self: *Self, input:[]u8) void {
        for (input) |byte| {
            self.hash = self.hash *% 33 + byte;
        }
    }
    
    pub fn final(self: *Self) u8 {
        return self.hash;
    }
};
