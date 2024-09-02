const tty = @import("tty.zig");
const TTY = @import("../../tty.zig").TTY;

pub fn initTTY() TTY {
    return .{
        .print = tty.writeString,
    };
}
