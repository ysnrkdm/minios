const std = @import("std");
const builtin = std.builtin;
// const log = std.log.scoped(.panic);
const tty = @import("tty.zig");

pub fn panic(src: builtin.SourceLocation, comptime format: []const u8, args: anytype) noreturn {
    @setCold(true);
    tty.printk("Kernel panic: " ++ format, args);
    tty.printk("File: %s, in function: %s, line: [%d]\n", .{ src.file, src.fn_name, src.line });
    while (true) {}
}
