const std = @import("std");
const builtin = @import("builtin");
const is_test = builtin.is_test;

pub const internals = if (is_test) @import("../../test/mock/kernel/arch_mock.zig") else switch (builtin.cpu.arch) {
    // .i386 => @import("arch/x86/arch.zig"),
    .riscv32 => @import("arch/riscv32/arch.zig"),
    else => unreachable,
};

test "test" {
    _ = @import("arch/riscv32/arch.zig");
}
