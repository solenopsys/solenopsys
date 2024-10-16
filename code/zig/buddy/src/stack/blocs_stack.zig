const std = @import("std");

const BlockSize = 4096; // Размер блока в байтах

const Block = struct {
    data: *[]byte, // адрес блока в памяти
    next: ?*Block = null, // адрес следующего блока
    address: u64 = 0, //последний адрес
    currentDataIndex: usize = 0,

    fn getNextBlock(self: *Block) ?*Block; // первый адрес
    fn getDriveAddress(self: *Block) u64; // последний адрес
    fn writeNextBlock(self: *Block, nextBlock: *Block) !void;
    fn writeDriveAddress(self: *Block, address: u64) !void;
    fn writeData(self: *Block, data: []u64) !void;
};

const Stack = struct {
    allocator: *std.mem.Allocator,
    immutable_block: *Block, // Неизменный блок
    current_block: *Block, // Текущий блок
    index: usize, // Индекс следующего свободного места

    // Инициализация стека
    pub fn init(allocator: *std.mem.Allocator) !Stack {
        var imm_block = try Block.init(allocator);
        return Stack{
            .allocator = allocator,
            .immutable_block = imm_block,
            .current_block = imm_block,
            .index = 0,
        };
    }

    // Освобождение стека
    pub fn deinit(self: *Stack) void {
        var block = self.current_block;
        while (block) |b| {
            var next_block = b.next;
            b.deinit(self.allocator);
            block = next_block;
        }
    }

    // Добавление элемента в стек
    pub fn push(self: *Stack, value: u64) !void {
        if (self.index >= self.current_block.data.len) {
            // Создаем новый блок
            var new_block = try Block.init(self.allocator);
            new_block.next = self.current_block;
            self.current_block = new_block;
            self.index = 0;
        }
        self.current_block.data[self.index] = value;
        self.index += 1;
    }

    // Извлечение элемента из стека
    pub fn pop(self: *Stack) !u64 {
        if (self.index == 0) {
            if (self.current_block.next) |next_block| {
                // Удаляем текущий блок и переходим к предыдущему
                var old_block = self.current_block;
                self.current_block = next_block;
                self.index = self.current_block.data.len;
                old_block.deinit(self.allocator);
            } else {
                return error.StackUnderflow;
            }
        }
        self.index -= 1;
        return self.current_block.data[self.index];
    }
};
