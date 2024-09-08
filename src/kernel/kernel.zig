const std = @import("std");
const log = std.log.scoped(.kernel);
const tty = @import("tty.zig");
const panic = @import("panic.zig").panic;

pub export fn memset(buf: [*]u32, c: u32, n: usize) void {
    var p: [*]u32 = buf;
    var count: usize = 0;

    while (count < n) {
        count += 1;
        p[count] = c;
    }
}

pub export fn kernelMain() void {
    // Register exception handler
    registerExceptionHandler();
    tty.init();
    tty.printk("\n\n%s\n", .{"Hello World!"});
    tty.printk("10 + 20 = %d\n", .{10 + 20});
    tty.printk("10 - 20 = %d\n", .{10 - 20});
    tty.printk("%s: %d %x\n", .{ "printk test, negative integer and hex", -22, 0xdeadbeef });
    log.info("%s", .{"kernel logging to tty!"});
    // panic(@src(), "booted!", .{});
    log.info("%s", .{"cannot reach this line"});

    // invalid opcode to trigger exception
    asm volatile (
        \\ unimp
    );
    while (true) {}
}

fn registerExceptionHandler() void {
    asm volatile (
        \\ csrw stvec, %[handle_address]
        :
        : [handle_address] "r" (kernelEntry),
    );
}

pub export fn kernelEntry() align(4) callconv(.Naked) void {
    // Store all registers (except FP) to memory,
    // and call handle_trap,
    // then load all registers back from memory
    asm volatile (
        \\ csrw sscratch, sp
        \\ addi sp, sp, -4 * 31
        \\ sw ra,  4 * 0(sp)
        \\ sw gp,  4 * 1(sp)
        \\ sw tp,  4 * 2(sp)
        \\ sw t0,  4 * 3(sp)
        \\ sw t1,  4 * 4(sp)
        \\ sw t2,  4 * 5(sp)
        \\ sw t3,  4 * 6(sp)
        \\ sw t4,  4 * 7(sp)
        \\ sw t5,  4 * 8(sp)
        \\ sw t6,  4 * 9(sp)
        \\ sw a0,  4 * 10(sp)
        \\ sw a1,  4 * 11(sp)
        \\ sw a2,  4 * 12(sp)
        \\ sw a3,  4 * 13(sp)
        \\ sw a4,  4 * 14(sp)
        \\ sw a5,  4 * 15(sp)
        \\ sw a6,  4 * 16(sp)
        \\ sw a7,  4 * 17(sp)
        \\ sw s0,  4 * 18(sp)
        \\ sw s1,  4 * 19(sp)
        \\ sw s2,  4 * 20(sp)
        \\ sw s3,  4 * 21(sp)
        \\ sw s4,  4 * 22(sp)
        \\ sw s5,  4 * 23(sp)
        \\ sw s6,  4 * 24(sp)
        \\ sw s7,  4 * 25(sp)
        \\ sw s8,  4 * 26(sp)
        \\ sw s9,  4 * 27(sp)
        \\ sw s10, 4 * 28(sp)
        \\ sw s11, 4 * 29(sp)
        \\ csrr a0, sscratch
        \\ sw a0, 4 * 30(sp)
        \\ mv a0, sp
        \\ call handleTrap
        \\ lw ra,  4 * 0(sp)
        \\ lw gp,  4 * 1(sp)
        \\ lw tp,  4 * 2(sp)
        \\ lw t0,  4 * 3(sp)
        \\ lw t1,  4 * 4(sp)
        \\ lw t2,  4 * 5(sp)
        \\ lw t3,  4 * 6(sp)
        \\ lw t4,  4 * 7(sp)
        \\ lw t5,  4 * 8(sp)
        \\ lw t6,  4 * 9(sp)
        \\ lw a0,  4 * 10(sp)
        \\ lw a1,  4 * 11(sp)
        \\ lw a2,  4 * 12(sp)
        \\ lw a3,  4 * 13(sp)
        \\ lw a4,  4 * 14(sp)
        \\ lw a5,  4 * 15(sp)
        \\ lw a6,  4 * 16(sp)
        \\ lw a7,  4 * 17(sp)
        \\ lw s0,  4 * 18(sp)
        \\ lw s1,  4 * 19(sp)
        \\ lw s2,  4 * 20(sp)
        \\ lw s3,  4 * 21(sp)
        \\ lw s4,  4 * 22(sp)
        \\ lw s5,  4 * 23(sp)
        \\ lw s6,  4 * 24(sp)
        \\ lw s7,  4 * 25(sp)
        \\ lw s8,  4 * 26(sp)
        \\ lw s9,  4 * 27(sp)
        \\ lw s10, 4 * 28(sp)
        \\ lw s11, 4 * 29(sp)
        \\ lw sp,  4 * 30(sp)
        \\ sret
    );
}

export fn handleTrap(trap_frame: TrapFrame) void {
    // Not used for now
    _ = trap_frame;

    const scause = asm volatile (
        \\ csrr %[ret], scause
        : [ret] "=r" (-> u32),
    );
    const stval = asm volatile (
        \\ csrr %[ret], stval
        : [ret] "=r" (-> u32),
    );
    const user_pc = asm volatile (
        \\ csrr %[ret], sepc
        : [ret] "=r" (-> u32),
    );

    // panic(@src(), "unexpected trap scause={d}\n", .{scause});
    panic(@src(), "unexpected trap scause=%x, stval=%x, sepc=%x\n", .{ scause, stval, user_pc });
}

pub const TrapFrame = extern struct {
    ra: u32,
    gp: u32,
    tp: u32,
    t0: u32,
    t1: u32,
    t2: u32,
    t3: u32,
    t4: u32,
    t5: u32,
    t6: u32,
    a0: u32,
    a1: u32,
    a2: u32,
    a3: u32,
    a4: u32,
    a5: u32,
    a6: u32,
    a7: u32,
    s0: u32,
    s1: u32,
    s2: u32,
    s3: u32,
    s4: u32,
    s5: u32,
    s6: u32,
    s7: u32,
    s8: u32,
    s9: u32,
    s10: u32,
    s11: u32,
    sp: u32,
};

test "memset can zeros the meomry region" {
    var message = [_]u32{ 'h', 'e', 'l', 'l', 'o' };
    memset(&message, 0, 5);
    try std.testing.expect(0 == message[0]);
    try std.testing.expect(0 == message[1]);
    try std.testing.expect(0 == message[2]);
    try std.testing.expect(0 == message[3]);
    try std.testing.expect(0 == message[4]);
}
