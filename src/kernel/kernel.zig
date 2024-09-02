const tty = @import("tty.zig");

pub export fn memset(buf: [*]u32, c: u32, n: usize) void {
    var p: [*]u32 = buf;
    var count: usize = 0;

    while (count < n) {
        count += 1;
        p[count] = c;
    }
}

pub export fn kernelMain() void {
    tty.init();
    tty.printf("\n\n{s}\n", .{"Hello World!"});
    tty.printf("1 + 2 = {}\n", .{1 + 2});
    while (true) {}
}

test "memset can zeros the meomry region" {
    const std = @import("std");
    var message = [_]u32{ 'h', 'e', 'l', 'l', 'o' };
    memset(&message, 0, 5);
    try std.testing.expect(0 == message[0]);
    try std.testing.expect(0 == message[1]);
    try std.testing.expect(0 == message[2]);
    try std.testing.expect(0 == message[3]);
    try std.testing.expect(0 == message[4]);
}
