const std = @import("std");
const builtin = std.builtin;
const log = std.log.scoped(.panic);

pub fn panic(src: builtin.SourceLocation, comptime format: []const u8, args: anytype) noreturn {
    @setCold(true);
    log.err("Kernel panic: " ++ format, args);
    log.err("File: {s}, in {s}, line: {d}", .{ src.file, src.fn_name, src.line });
    while (true) {}
}
