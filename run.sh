#!/bin/bash
set -xue

QEMU=qemu-system-riscv32

if (( $# == 0 )); then
    echo Running normally
    $QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel zig-out/bin/minios.elf
else
    if [[ $1 =~ ^(-l|--lldb) ]]; then
        echo Running with lldb
        $QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot -s -S -kernel zig-out/bin/minios.elf
    fi
fi
