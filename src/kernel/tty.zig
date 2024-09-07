const arch = @import("arch.zig").internals;

pub const TTY = struct {
    print: *const fn ([]const u8) anyerror!void,
    putChar: *const fn (u8) void,
};

var tty: TTY = undefined;

pub fn init() void {
    tty = arch.initTTY();
}

pub const ArgSetType = u32;
const max_format_args = @typeInfo(ArgSetType).Int.bits;

pub fn printk(comptime format: []const u8, args: anytype) void {
    const ArgsType = @TypeOf(args);
    const args_type_info = @typeInfo(ArgsType);
    if (args_type_info != .Struct) {
        @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
    }

    const fields_info = args_type_info.Struct.fields;
    if (fields_info.len > max_format_args) {
        @compileError("32 arguments max are supported per format call");
    }

    //
    comptime var va_pos = 0;
    comptime var i = 0;
    inline while (i < format.len) : (i += 1) {
        if (format[i] == '%') {
            i += 1;
            switch (format[i]) {
                '%' => tty.print("%"),
                's' => {
                    const s = @as([]const u8, @field(args, fields_info[va_pos].name));
                    va_pos += 1;
                    tty.print(s) catch {};
                },
                'd' => {
                    const uvalue: i32 = @intCast(@field(args, fields_info[va_pos].name));
                    if (uvalue < 0) {
                        tty.print("-") catch {};
                    }
                    var value: u32 = @intCast(uvalue);
                    var divisor: u32 = 1;
                    while (value / divisor > 9) : (divisor *= 10) {}
                    while (divisor > 0) : (divisor /= 10) {
                        const digit = value / divisor;
                        tty.putChar("0123456789"[digit]);
                        value %= divisor;
                    }
                },
                'x' => {
                    const value: u32 = @intCast(@field(args, fields_info[va_pos].name));
                    tty.print("0x") catch {};
                    for (0..7) |ith| {
                        const shif: u5 = @intCast((7 - ith));
                        const nibble = (value >> (shif * 4)) & 0x000f;
                        tty.putChar("0123456789abcdef"[nibble]);
                    }
                },
                else => {},
            }
        } else {
            tty.putChar(format[i]);
        }
    }
}

pub fn print(str: []const u8) void {
    tty.print(str) catch {};
}

pub fn println(str: []const u8) void {
    tty.print(str + "\n") catch {};
}
