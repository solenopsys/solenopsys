const std = @import("std");
const BlockDeviceInterface = @import("device_interface.zig").BlockDeviceInterface;
const BlockBufferedInterface = @import("buffer_interface.zig").BlockBufferedInterface;
const MockBlockDevice = @import("device_mock.zig").MockBlockDevice;

const BlockDeviceBuffered = struct {
    device: *anyopaque,
    block_size: u64,
    cache: std.AutoHashMap(u64, *[]u8),
    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        blockDevice: *anyopaque,
    ) !BlockDeviceBuffered {
        return BlockDeviceBuffered{
            .device = blockDevice,
            .block_size = blockDevice.getBlockSize(),
            .cache = std.AutoHashMap(u64, []u8).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *BlockDeviceBuffered, allocator: *std.mem.Allocator) void {
        self.device.close();
        var it = self.cache.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.value);
        }
        self.cache.deinit();
    }

    fn load(self: *BlockDeviceBuffered, block_number: u64) !*[]u8 {
        const buffer = try self.allocator.alloc(u8, self.block_size);
        const offset = block_number * self.block_size;
        const bytes_read = try self.device.read(offset, buffer);

        if (bytes_read != self.block_size) {
            self.allocator.free(buffer);
            return error.IncompleteBlockRead;
        }

        self.cache.put(block_number, &buffer) catch |e| {
            self.allocator.free(buffer);
            return e;
        };

        return &buffer;
    }

    pub fn write(self: *BlockDeviceBuffered, block_number: u64, data: *[]u8) !void {
        self.cache.put(block_number, data) catch |e| {
            self.allocator.free(data);
            return e;
        };
    }

    pub fn read(self: *BlockDeviceBuffered, block_number: u64) !*[]u8 {
        if (self.cache.get(block_number)) |cached_block| {
            return cached_block;
        } else {
            return try self.loadBlock(self.allocator, block_number);
        }
    }

    pub fn remove(self: *BlockDeviceBuffered, block_number: u64) !void {
        if (self.cache.remove(block_number)) |cached_block| {
            self.allocator.free(cached_block);
        }
    }
};

const testing = @import("std").testing;

test "BlockBufferedInterface" {
    const allocator = std.testing.allocator;
    const block_size: usize = 16;
    const count_of_blocks: usize = 8;

    // Инициализируем устройство, ловим ошибку, если инициализация не удалась
    var device = try MockBlockDevice.init(allocator, block_size, count_of_blocks);
    defer device.deinit(allocator); // Гарантируем освобождение памяти устройства

    const devWrap = BlockDeviceInterface(device);

    // Выделяем буфер памяти, ловим ошибку при выделении
    var buffer = try allocator.alloc(u8, 16);
    defer allocator.free(buffer); // Гарантируем освобождение памяти буфера

    // Проверяем результат копирования
    @memcpy(buffer[0..5], "Hello");

    // Пишем в устройство, обрабатываем возможную ошибку
    const written = try device.write(buffer[0..], 0);
    try testing.expectEqual(@as(usize, 16), written);

    var buffered = try BlockDeviceBuffered.init(allocator, devWrap);
    defer buffered.deinit(allocator);
    const readed_block = try buffered.read(0);

    try testing.expectEqualStrings(buffer, *readed_block);
}
