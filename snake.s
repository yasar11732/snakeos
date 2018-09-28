.code16
.text

setup:
    cli
    # setup stack segment
    xor %ax, %ax
    mov %ax, %ss
    mov $0x7C00, %ax
    mov %ax, %sp

    # setup data segment
    xor %ax,%ax
    mov %ax, %ds

    # setup video memory
    mov $0xB800, %ax
    mov %ax, %gs
    sti

init_random_value:
    mov $0,%ah
    int $0x1a
    mov %dx,random

register_interrupt_handlers:
    cli
    movw $timer_handler,(32)
    movw $0,(34)
    movw $keyboard_handler,(36)
    movw $0,(38)
    sti

busy_loop:
    mov timer_ticks,%ax
    add $18,%ax
_wait:
    mov timer_ticks,%bx
    cmp %ax,%bx
    jg stop_waiting
    hlt
    jmp _wait
stop_waiting:
    call get_random
    mov $0x0E, %ah
    int $0x10 # output random value
    jmp busy_loop

timer_handler:
    pusha
    incw timer_ticks

    mov $0x20,%al
    out %al,$0x20
    popa
    iret

keyboard_handler:
    pusha
    in $0x60,%al
    mov %al,scancode
    
    mov $0x20,%al
    out %al,$0x20
    popa
    iret

/* Returns 16bit pseudo-random number in ax, other registers are preserved */
.global get_random
.type get_random,@function
get_random:
    push %bx
    mov random,%ax
    mov $5,%bx
    mul %bx
    inc %ax
    mov %ax,random
    pop %bx
    ret

.data
.align 2
random:
    .2byte 0

timer_ticks:
    .2byte 0

scancode:
    .2byte 0