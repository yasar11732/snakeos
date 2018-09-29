.code16
.text

# calling convention: pass arguments and return values using registers
# all registers except %ax is calee saved, %ax is caller saved

setup:
    cli
    # setup stack segment
    xor %ax, %ax
    mov %ax, %ss
    mov %ax, %ds

    mov $0x7C00, %ax
    mov %ax, %sp

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

/*
busy_loop:
    mov timer_ticks,%ax
    add $1,%ax
_wait:
    mov timer_ticks,%bx
    cmp %ax,%bx
    jge stop_waiting
    hlt
    jmp _wait
stop_waiting:
    call get_random
    call printd

    mov $0x0E,%ah
    mov $0xD,%al
    int $0x10
    mov $0xA,%al
    int $0x10
    jmp busy_loop
*/

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
    mov $0,%ah
    call printd
    call printnewline
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

# print decimal representation of a %ax
.global printd
.type printd,@function
printd:
    push %bx
    push %dx
    push $10 # end of digits in stack
    mov $10,%bx
divide_loop:
    mov $0,%dx
    div %bx
    push %dx
    or %ax,%ax
    jnz divide_loop
print_loop:
    pop %ax
    cmp $10,%ax
    je printd_quit
    mov $0x0E,%ah
    add $48,%al
    int $0x10
    jmp print_loop
printd_quit:
    pop %dx
    pop %bx
    ret

printnewline:
    mov $0x0E,%ah
    mov $0xD,%al
    int $0x10
    mov $0xA,%al
    int $0x10
    ret
    
random:
    .2byte 0x0
timer_ticks:
    .2byte 0x0
scancode:
    .2byte 0x0
cursorx:
    .byte 0x0
cursory:
    .byte 0x0
terminalcolor:
    .2byte 0x15