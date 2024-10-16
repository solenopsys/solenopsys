const std = @import("std");
const BlockDeviceInterface = @import("./device/interface.zig").BlockDeviceInterface;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello, Zig!\n", .{});
}
