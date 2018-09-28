.code16
.text

setup:
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

init_random_value:
    mov $0,%ah
    int $0x1a
    mov %dx,random

register_interrupt_handlers:
    cli
    # timer (int $0x08)
    push %es
    push $0
    pop %es

    # IRQ0->INT 8 (4*8 = 32)
    mov $32,%bx

    movw $timer_handler,%es:(%bx)
    inc %bx
    inc %bx
    movw $0,%es:(%bx)
    inc %bx
    inc %bx
    movw $keyboard_handler,%es:(%bx)
    inc %bx
    inc %bx
    movw $0,%es:(%bx)

    pop %es
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

/* Returns 16bit pseudo-random number in ax */
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