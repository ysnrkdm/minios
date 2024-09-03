const std = @import("std");
const fmt = std.fmt;
const arch = @import("arch.zig").internals;
const log = std.log.scoped(.tty);

const Writer = std.io.Writer(void, anyerror, printCallback);

pub const TTY = struct {
    print: *const fn ([]const u8) anyerror!void,
};

var tty: TTY = undefined;

pub fn init() void {
    tty = arch.initTTY();
}

fn printCallback(ctx: void, str: []const u8) !usize {
    // Suppress unused var warning
    _ = ctx;
    tty.print(str) catch {
        // want to panic the error...
        // panic(@errorReturnTrace(), "Failed to print to tty: {}\n", .{e})
    };
    return str.len;
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    // Printing can't error because of the scrolling, if it does, we have a big problem
    fmt.format(Writer{ .context = {} }, format, args) catch |e| {
        // want to log the error...
        log.err("Error printing. Error: {}\n", .{e});
    };
}

pub fn print(str: []const u8) void {
    tty.print(str) catch {};
}

pub fn println(str: []const u8) void {
    tty.print(str + "\n") catch {};
}
