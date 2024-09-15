const std = @import("std");
const log = std.log.scoped(.kernel);
const tty = @import("tty.zig");
const kernel = @import("kernel.zig");
const panic = @import("panic.zig").panic;

pub const PROCS_MAX = 8; // max num process

pub const STACK_LENGTH = 8192;

var tasks = [_]Task{
    .{
        .pid = 0,
        .state = .TASK_UNUSED,
        .stack_pointer = undefined,
        .kernel_stack = [_]usize{0} ** 8192,
    },
} ** PROCS_MAX;

pub const TaskState = enum {
    TASK_RUNNABLE,
    TASK_UNUSED,
};

pub const Task = struct {
    pid: usize,
    state: TaskState,
    stack_pointer: *u32,
    kernel_stack: [8192]u32,

    pub fn create(pc: usize) *Task {
        var task: *Task = undefined;
        var pid: usize = 0;
        for (0..PROCS_MAX) |i| {
            if (tasks[i].state == .TASK_UNUSED) {
                task = &tasks[i];
                pid = i;
                break;
            }
            if (i == PROCS_MAX - 1) {
                panic(@src(), "No available process slot!", .{});
            }
        }

        task.init(pid, pc);

        return task;
    }

    pub fn init(self: *Task, pid: usize, pc: usize) void {
        self.pid = pid;

        // initialize stack
        const stack_bottom = self.kernel_stack.len - 14;
        const sp = &self.kernel_stack;
        sp.*[stack_bottom + 12] = 0; // s11
        sp.*[stack_bottom + 11] = 0; // s10
        sp.*[stack_bottom + 10] = 0; // s9
        sp.*[stack_bottom + 9] = 0; // s8
        sp.*[stack_bottom + 8] = 0; // s7
        sp.*[stack_bottom + 7] = 0; // s6
        sp.*[stack_bottom + 6] = 0; // s5
        sp.*[stack_bottom + 5] = 0; // s4
        sp.*[stack_bottom + 4] = 0; // s3
        sp.*[stack_bottom + 3] = 0; // s2
        sp.*[stack_bottom + 2] = 0; // s1
        sp.*[stack_bottom + 1] = 0; // s0
        sp.*[stack_bottom] = pc; // ra

        self.stack_pointer = &sp.*[stack_bottom];
        self.state = .TASK_RUNNABLE;

        log.info("pc to set is %x, sp is %x", .{ pc, @intFromPtr(self.stack_pointer) });
    }
};

pub fn switchContext(prev_task: *Task, next_task: *Task) void {
    asm volatile (
        \\ lw sp, (%[prev_sp])
        \\ addi sp, sp, -13 * 4
        \\ sw ra,  0  * 4(sp)
        \\ sw s0,  1  * 4(sp)
        \\ sw s1,  2  * 4(sp)
        \\ sw s2,  3  * 4(sp)
        \\ sw s3,  4  * 4(sp)
        \\ sw s4,  5  * 4(sp)
        \\ sw s5,  6  * 4(sp)
        \\ sw s6,  7  * 4(sp)
        \\ sw s7,  8  * 4(sp)
        \\ sw s8,  9  * 4(sp)
        \\ sw s9,  10 * 4(sp)
        \\ sw s10, 11 * 4(sp)
        \\ sw s11, 12 * 4(sp)
        \\ sw sp, (%[prev_sp])
        \\ lw sp, (%[next_sp])
        \\ lw ra,  0  * 4(sp)
        \\ lw s0,  1  * 4(sp)
        \\ lw s1,  2  * 4(sp)
        \\ lw s2,  3  * 4(sp)
        \\ lw s3,  4  * 4(sp)
        \\ lw s4,  5  * 4(sp)
        \\ lw s5,  6  * 4(sp)
        \\ lw s6,  7  * 4(sp)
        \\ lw s7,  8  * 4(sp)
        \\ lw s8,  9  * 4(sp)
        \\ lw s9,  10 * 4(sp)
        \\ lw s10, 11 * 4(sp)
        \\ lw s11, 12 * 4(sp)
        \\ addi sp, sp, 13 * 4
        \\ ret
        :
        : [prev_sp] "r" (&prev_task.stack_pointer),
          [next_sp] "r" (&next_task.stack_pointer),
    );

    // Actually doesn't reach here - ret is called in the asm above
    return;
}
