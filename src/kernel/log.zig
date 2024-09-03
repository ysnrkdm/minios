const std = @import("std");
const fmt = std.fmt;
const tty = @import("tty.zig");

const LoggingError = error{};
const Writer = std.io.Writer(void, LoggingError, logCallback);
pub const log_level: std.log.Level = .debug;
fn logCallback(context: void, str: []const u8) LoggingError!usize {
    // Suppress unused var warning
    _ = context;
    tty.print(str);
    return str.len;
}

pub fn log(comptime level: std.log.Level, comptime format: []const u8, args: anytype) void {
    fmt.format(Writer{ .context = {} }, "[" ++ @tagName(level) ++ "] " ++ format ++ "\n", args) catch unreachable;
}
