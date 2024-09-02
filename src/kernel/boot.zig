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
