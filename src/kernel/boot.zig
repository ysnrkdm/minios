const std = @import("std");
const log_root = @import("log.zig");
const kernel = @import("kernel.zig");

extern var __bss: [*]u32;
extern var __bss_end: [*]u32;

export fn _start() align(32) linksection(".text.boot") callconv(.Naked) noreturn {
    // set __stack_top to sp
    asm volatile (
        \\ .extern __stack_top
        \\ la a1, __stack_top
        \\ mv sp, a1
    );

    asm volatile ("j boot");

    while (true) {}
}

export fn boot() void {
    kernel.memset(__bss, 0, @intFromPtr(__bss_end) - @intFromPtr(__bss));
    kernel.kernelMain();
    while (true) {}
}

// Define root.log to override the std implementation
pub const std_options = .{
    .log_level = .info,
    .logFn = log,
};

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    log_root.log(level, "(" ++ @tagName(scope) ++ "): " ++ format, args);
}
