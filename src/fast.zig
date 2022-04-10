const std = @import("std");
const mem = std.mem;

pub const Fast = struct {
    
    const m: u64 = 0x880355f21e6d1965;
    
    pub fn calculate(bytes: []const u8, seed: u64) u64 {
        var result: u64 = seed ^ (bytes.len * m);
        if (bytes.len == 0) return 0;
        var remainder = bytes % 8;
        const take = (bytes/8)*8;
        const units = mem.bytesAsSlice(u64, bytes[0..take]);
        for (units) |unit| {
            result ^= mix(unit);
            result *%= m;
        }
        const remaining_bytes = bytes[take..];
        var v: u64 = 0;
        if (remainder > 0) {
            while (remainder > 0): (remainder -= 1) {
                v ^= remaining_bytes[remainder - 1] << (remainder - 1) * 8;
            }
            result ^= mix(v);
            result *%= m;
        }
        
        
        result = mix(result);
        return result;
    }
    
    fn mix(input: u64) u64 {
        var result = input;
        result ^= result >> 23;
        result *%= 0x2127599bf4325c37;
        result ^= result >> 47;
        return result;
    }
    
    
};
