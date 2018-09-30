.code16
.text

# calling convention: pass arguments and return values using registers
# all registers except %ax is calee saved, %ax is caller saved
start:
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
    mov %ax, %es

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
    mov $0,%di
busy_loop:
    /*
    mov timer_ticks,%ax
    add $1,%ax
_wait:
    mov timer_ticks,%cx
    cmp %ax,%cx
    jge stop_waiting
    hlt
    jmp _wait
stop_waiting:
*/
    movb direction,%al
    xor %ah,%ah
    mov %ax,%di
    mov $direction_symbols,%bx
    mov (%bx,%di),%al
    mov $0x15,%ah
    mov %ax,%es:2
    jmp busy_loop

irq_return:
    mov $0x20,%al
    out %al,$0x20
    popa
    iret

timer_handler:
    pusha
    incw timer_ticks
    jmp irq_return

keyboard_handler:
    pusha
    in $0x60,%al

    mov direction,%bx
    test $1,%bl
    jz vert
horiz:
    cmp $0x11,%al
    jne horiz2
    movb $0,direction
    jmp irq_return
horiz2:
    cmp $0x1F,%al
    jne irq_return
    movb $0x2,direction
    jmp irq_return
vert:
    cmp $0x20,%al
    jne vert2
    movb $0x1,direction
    jmp irq_return
vert2:
    cmp $0x1E,%al
    jne irq_return
    movb $0x3,direction
    jmp irq_return



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
LOC0:
    mov $0,%dx
    div %bx
    push %dx
    or %ax,%ax
    jnz LOC0
LOC1:
    pop %ax
    cmp $10,%ax
    je LOC2
    mov $0x0E,%ah
    add $48,%al
    int $0x10
    jmp LOC1
LOC2:
    pop %dx
    pop %bx
    ret

# print hex representation of a %ax
.global printh
.type printh,@function
printh:
    push %bx
    push %dx
    mov $0x10,%bx
    push %bx
LOC3:
    mov $0,%dx
    div %bx
    push %dx
    or %ax,%ax
    jnz LOC3
LOC4:
    pop %ax
    cmp %bx,%ax
    je LOC5
    mov $0x0E,%ah
    cmp $10,%al
    jl LOC6
    add $7,%al
LOC6:
    add $48,%al
    int $0x10
    jmp LOC4
LOC5:
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

.align 16
direction_symbols:
    .byte 24
    .byte 26
    .byte 25
    .byte 27
direction:
    .byte 0x1