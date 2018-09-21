.section .boot
.code16

# setup data segment pointer
mov $0x7D0, %ax
mov %ax, %ds

# set source index to point to hello string
mov $(hello-.data), %si
call bios_print

hang:
    hlt
    jmp hang

# print all characters
bios_print:
    lodsb
    or %al, %al
    jz return
    mov $0x0E, %ah
    int $0x10
    jmp bios_print
return:
    ret

.section .data
hello:
    .ascii "Hello World!\0"