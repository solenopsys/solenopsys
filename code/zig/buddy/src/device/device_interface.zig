pub fn BlockDeviceInterface(comptime T: type) type {
    return struct {
        fn open(self: *void) !void {
            return T.open(self);
        }

        fn close(self: *void) void {
            return T.close(self);
        }

        fn read(self: *void, offset: u64, buffer: []u8) !usize {
            return T.read(self, offset, buffer);
        }

        fn write(self: *void, offset: u64, buffer: []u8) !usize {
            return T.write(self, offset, buffer);
        }

        fn blockSize(self: *void) !usize {
            return T.blockSize(self);
        }

        fn deviceSize(self: *void) !usize {
            return T.deviceSize(self);
        }
    };
}

const std = @import("std");

// Мок-тип устройства, реализующий все функции интерфейса
const TestBlockDevice = struct {
    opened: bool,

    pub fn open(self: *TestBlockDevice) !void {
        self.opened = true;
        // Вернем `void` для успешного завершения
        return;
    }

    pub fn close(self: *MockBlockDevice) void {
        self.opened = false;
    }

    pub fn read(self: *MockBlockDevice, offset: u64, buffer: []u8) !usize {
        // Пример чтения данных: заполняем буфер 'A'
        for (buffer) |*byte| {
            byte.* = 'A';
        }
        return buffer.len;
    }

    pub fn write(self: *MockBlockDevice, offset: u64, buffer: []u8) !usize {
        // Пример записи данных: возвращаем длину буфера
        return buffer.len;
    }

    pub fn blockSize(self: *MockBlockDevice) !usize {
        return 512; // Пример размера блока
    }

    pub fn deviceSize(self: *MockBlockDevice) !usize {
        return 1024 * 1024; // Пример размера устройства (1MB)
    }
};

test "BlockDeviceInterface test" {
    var mock_device = MockBlockDevice{ .opened = false };

    // Создаем интерфейс для `MockBlockDevice`
    const DeviceInterface = BlockDeviceInterface(MockBlockDevice);

    // Используем интерфейс для работы с мок-устройством
    var device_interface = DeviceInterface{};

    // Открываем устройство и проверяем результат
    try device_interface.open(&mock_device);
    std.testing.expect(mock_device.opened == true);

    // Проверяем размер блока
    const block_size = try device_interface.blockSize(&mock_device);
    std.testing.expect(block_size == 512);

    // Проверяем размер устройства
    const device_size = try device_interface.deviceSize(&mock_device);
    std.testing.expect(device_size == 1024 * 1024);

    // Проверяем чтение
    var buffer: [16]u8 = undefined;
    const bytes_read = try device_interface.read(&mock_device, 0, &buffer);
    std.testing.expect(bytes_read == buffer.len);
    std.testing.expect(buffer[0] == 'A');

    // Проверяем запись
    const bytes_written = try device_interface.write(&mock_device, 0, &buffer);
    std.testing.expect(bytes_written == buffer.len);

    // Закрываем устройство и проверяем результат
    device_interface.close(&mock_device);
    std.testing.expect(mock_device.opened == false);
}
