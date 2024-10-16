const std = @import("std");
const testing = std.testing;

pub const MockBlockDevice = struct {
    pub fn init(allocator: std.mem.Allocator, block_size: usize, count_of_blocks: usize) !MockBlockDevice {
        const data_size = block_size * count_of_blocks;
        const data = try allocator.alloc(u8, data_size);

        return MockBlockDevice{
            .block_size = block_size,
            .count_of_blocks = count_of_blocks,
            .data = data,
        };
    }

    pub fn deinit(self: *MockBlockDevice, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn read(self: *MockBlockDevice, buffer: []u8, offset: usize) !usize {
        @memcpy(buffer, self.data[offset .. offset + buffer.len]);
        return buffer.len;
    }

    pub fn write(self: *MockBlockDevice, buffer: []u8, offset: usize) !usize {
        @memcpy(self.data[offset .. offset + buffer.len], buffer);
        return buffer.len;
    }

    pub fn blockSize(self: *MockBlockDevice) usize {
        return self.block_size;
    }

    pub fn deviceSize(self: *MockBlockDevice) usize {
        return self.block_size * self.count_of_blocks;
    }

    block_size: usize,
    count_of_blocks: usize,
    data: []u8,
};

// test

test "MockBlockDevice - initialization and deinitialization" {
    const allocator = std.testing.allocator;
    const block_size: usize = 512;
    const count_of_blocks: usize = 8;

    var device = try MockBlockDevice.init(allocator, block_size, count_of_blocks);
    defer device.deinit(allocator);

    try testing.expectEqual(block_size, device.block_size);
    try testing.expectEqual(count_of_blocks, device.count_of_blocks);
    try testing.expectEqual(block_size * count_of_blocks, device.data.len);
}

test "MockBlockDevice - read and write" {
    const allocator = std.testing.allocator;
    const block_size: usize = 16;
    const count_of_blocks: usize = 8;

    var device = try MockBlockDevice.init(allocator, block_size, count_of_blocks);
    defer device.deinit(allocator);

    const buffer = try allocator.alloc(u8, 16);

    @memcpy(buffer[0..5], "Hello");
    const written = try device.write(buffer[0..], 16);
    try testing.expectEqual(@as(usize, 16), written);
    const read_buffer = try allocator.alloc(u8, 16);
    const read = try device.read(read_buffer, 16);
    try testing.expectEqual(@as(usize, 16), read);
    try testing.expectEqualStrings(buffer, read_buffer);
    allocator.free(buffer);
    allocator.free(read_buffer);
}

test "MockBlockDevice - check block size" {
    const allocator = std.testing.allocator;
    const block_size: usize = 512;
    const count_of_blocks: usize = 8;

    var device = try MockBlockDevice.init(allocator, block_size, count_of_blocks);
    defer device.deinit(allocator);

    try testing.expectEqual(@as(usize, 512), device.blockSize());
    try testing.expectEqual(@as(usize, 512 * 8), device.deviceSize());
}
