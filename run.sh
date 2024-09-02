#!/bin/bash
set -xue

QEMU=qemu-system-riscv32

$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
    -kernel zig-out/bin/minios.elf
