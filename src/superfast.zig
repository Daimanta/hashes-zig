const std = @import("std");
const mem = std.mem;

pub const SuperFast = struct {

    pub fn calculate(bytes: []const u8) u32 {
        if (bytes.len == 0) return 0;
        var result: u32 = bytes.len;
        var temp: u32 = 0;
        const remainder: u32 = bytes.len % 4;
        const take = (bytes.len/4)*4;
        
        const cast = mem.bytesAsSlice(u16, bytes[0..take]);
        
        var i = 0;
        while (i < cast.len): (i += 2) {
            result +%= cast[i];
            temp = (cast[i+1] << 11) ^ result;
            result = (result << 16) ^ temp;
            result +%= (result >> 11);
        }
        
        if (remainder == 3) {
            result +%= littleEndianBytesToU16(bytes[bytes.len - 3], bytes[bytes.len - 2]);
            result ^= (result << 16);
            result ^= bytes[bytes.len - 1] << 18;
            result +%= (result >> 11);
        } else if (remainder == 2) {
            result +%= littleEndianBytesToU16(bytes[bytes.len - 2], bytes[bytes.len - 1]);
            result ^= (result << 11);
            result +%= (result >> 17);
        } else if (remainder == 1) {
            result +%= bytes[bytes.len - 1];
            result ^= (result << 10);
            result +%= (result >> 1);
        }
        
        result ^= (result << 3);
        result += (result >> 5);
        result ^= (result << 4);
        result += (result >> 17);
        result ^= (result << 25);
        result += (result >> 6);
        
        return result;
    }
    
    fn littleEndianBytesToU16(first: u8, second: u8) u16 {
        return second << 8 + first;
    }
};
