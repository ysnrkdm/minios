const std = @import("std");
const tty = @import("tty.zig");

pub const log_level: std.log.Level = .debug;

pub fn log(comptime level: std.log.Level, comptime format: []const u8, args: anytype) void {
    const levelstr = switch (level) {
        .err => "error",
        .warn => "warning",
        .info => "info",
        .debug => "debug",
    };
    tty.printk("[", .{});
    tty.printk(levelstr, .{});
    tty.printk("]", .{});
    tty.printk(format, args);
    tty.printk("\n", .{});
}
