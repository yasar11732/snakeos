.extern .rodata
.extern hello
.extern vga_print
.extern _second_stage_start


.code16

.text
mov %dl, drive_ref
cli
# setup stack segment
xor %ax, %ax
mov %ax, %ss
mov $0x7bf, %ax
mov %ax, %sp

# setup data segment
xor %ax,%ax
mov %ax, %ds

# setup video memory
mov $0xB800, %ax
mov %ax, %gs
sti

jmp _second_stage_start

drive_ref:
    .2byte 0
