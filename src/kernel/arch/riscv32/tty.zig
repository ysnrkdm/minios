const TtyError = error{
    /// If the printing tries to print outside the video buffer.
    OutOfBounds,
};

pub fn writeString(str: []const u8) TtyError!void {
    for (str) |char| {
        putChar(char);
    }
}

const sbiRet = struct { err: u32, value: u32 };

pub fn sbiCall(arg0: u32, arg1: u32, arg2: u32, arg3: u32, arg4: u32, arg5: u32, fid: u32, eid: u32) sbiRet {
    const a0 = arg0;
    const a1 = arg1;
    const a2 = arg2;
    const a3 = arg3;
    const a4 = arg4;
    const a5 = arg5;
    const a6 = fid;
    const a7 = eid;

    const err = asm volatile (
        \\ ecall
        \\ mv s1, a0
        : [s1] "=&r" (-> u32),
        : [a0] "{a0}" (a0),
          [a1] "{a1}" (a1),
          [a2] "{a2}" (a2),
          [a3] "{a3}" (a3),
          [a4] "{a4}" (a4),
          [a5] "{a5}" (a5),
          [a6] "{a6}" (a6),
          [a7] "{a7}" (a7),
        : "memory"
    );

    const value = asm volatile (""
        : [a1] "=r" (-> u32),
    );

    return sbiRet{ .err = err, .value = value };
}

pub fn putChar(ch: u8) void {
    _ = sbiCall(ch, 0, 0, 0, 0, 0, 0, 1);
}
