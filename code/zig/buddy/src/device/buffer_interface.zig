const BlockDeviceInterface = @import("device_interface.zig").BlockDeviceInterface;
const std = @import("std");

pub fn BlockBufferedInterface(
    comptime T: type,
) type {
    return struct {
        fn init(allocator: *std.mem.Allocator, blockDevice: BlockDeviceInterface) !void {
            return T.init(blockDevice, allocator);
        }
        fn read(self: *void, block_number: u64) !*[]u8 {
            return T.read(self, block_number);
        }
        fn write(self: *void, block_number: u64, data: *[]u8) !void {
            return T.write(self, block_number, data);
        }
        fn remove(self: *void, block_number: u64) !void {
            return T.remove(self, block_number);
        }
    };
}
