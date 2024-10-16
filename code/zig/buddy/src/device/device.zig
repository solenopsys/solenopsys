const std = @import("std");
const testing = std.testing;

const BlockDevice = struct {
    path: []const u8,

    pub fn init(path: []const u8) !BlockDevice {
        return BlockDevice{
            .path = path,
        };
    }

    pub fn open(self: *BlockDevice) void {
        self.current = try std.fs.cwd().openFile(self.path, .{});
    }

    pub fn read(self: *BlockDevice, offset: u64, buffer: []u8) !usize {
        return try self.current.pread(buffer[0..], offset);
    }

    pub fn write(self: *BlockDevice, offset: u64, buffer: []u8) !usize {
        return try self.current.pwrite(buffer[0..], offset);
    }

    pub fn close(self: *BlockDevice) void {
        self.current.close();
    }

    pub fn blockSize(self: *BlockDevice) !usize {
        const BLKSSZGET = 0x1268;
        var block_size: usize = 0;
        const result = std.os.ioctl(self.current.handle, BLKSSZGET, &block_size);
        if (result != 0) {
            return error.IoError;
        }
        return block_size;
    }

    pub fn deviceSize(self: *BlockDevice) !usize {
        const BLKGETSIZE64 = 0x8004;
        var device_size: usize = 0;
        const result = std.os.ioctl(self.current.handle, BLKGETSIZE64, &device_size);
        if (result != 0) {
            return error.IoError;
        }
        return device_size;
    }
};

// test "BlockDevice - check block size" {
//     const bd = BlockDevice.init("/dev/sda");
//     try bd.open();
//     defer bd.close();

//     try testing.expectEqual(@as(usize, 512), bd.blockSize());
//     try testing.expectEqual(@as(usize, 512 * 8), bd.deviceSize());
// }
