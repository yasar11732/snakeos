.code16
.text
.set snake_pointer,0x7E00
.set snake_segment,0x7E0

# calling convention: pass arguments and return values using registers
# all registers except %ax is calee saved, %ax is caller saved
start:
setup:
    cli
    # initialize stack
    mov $0x7C00, %ax
    mov %ax, %sp

    # pointer to video memory
    mov $0xB800, %ax
    mov %ax, %es

    # setup timer freq (once per milliseconds)
    mov $1193,%bx
    mov $0x36,%al
    out %al,$0x43
    mov %bl,%al
    out %al,$0x40
    mov %bh,%al
    out %al,$0x40

    # initialize segments
    xor %ax, %ax
    mov %ax, %ss
    mov %ax, %ds
    mov %ax, %di
    mov %ax, %si

    # timer and keyboard handlers
    movw $timer_handler,(32)
    mov %ax,(34)
    movw $keyboard_handler,(36)
    mov %ax,(38)

    sti

init_random_value:
    # ax is assumed to be 0 at this point
    int $0x1a
    mov %dx,random
   
   
copy_snake_prepare:
    # copy initial state of snake into 0x7E00
    push %es
    mov $0x7E0,%ax
    mov %ax,%es
    mov $initial_snake,%si
    xor %di,%di
    
copy_snake:

    lodsw
    stosw
    cmp $0xffff,%ax
    jne copy_snake
    pop %es

    /* set callback for loop snake */
    mov $draw_snake,%bx

busy_loop:

    mov $500,%ax
    call sleep

    mov $0x0,%cx
    call loop_snake
    
    call mov_snake

    mov $0x0f09,%cx
    call loop_snake

    jmp busy_loop

/*  foreach part of the snake, call bx with position in ax
    cx and dx is preserved before calling bx, so they can
    be used to pass extra parameters
*/
loop_snake:
    push %ds
    push $snake_segment
    pop %ds
    xor %si,%si
loop_snake0:
    lodsw
    cmp $0xffff,%ax
    je loop_snake1
    call %bx
    jmp loop_snake0
loop_snake1:
    pop %ds
    ret

draw_snake:    
    call snake_to_screen
    mov %ax,%di
    mov %cx,%es:(%di)
    ret

len_snake:
    inc %cx
    ret

mov_snake:
    pusha
    push %es
    push %ds

    mov $snake_segment,%ax
    mov %ax,%ds
    mov %ax,%es

    mov $len_snake,%bx
    xor %cx,%cx
    call loop_snake
    dec %cx
    shl $1,%cx
    mov %cx,%di
    sub $2,%cx
    mov %cx,%si
    std
mov_snake0:
    lodsw
    stosw
    or %di,%di
    jz mov_snake1
    jmp mov_snake0
mov_snake1:
    cld
    # at this point, %ax contains head, lets increment x coord
    inc %al
    stosw

    pop %ds
    pop %es
    popa
    ret

/* put milliseconds to sleep in %ax, %ax trashed */
sleep:
    push %bx
    mov timer_ticks,%bx
    add %bx,%ax
sleep0:
    mov timer_ticks,%bx
    cmp %bx,%ax
    jle sleep1
    hlt
    jmp sleep0
sleep1:
    pop %bx
    ret

/* Convert snake coordinates into video memory index
    in: al -> snake x
    in: ah -> snake y
    out: ax -> index in video memory
*/
snake_to_screen:
    push %bx
    push %cx

    mov $80,%cx
    xor %bx,%bx
    
    mov %al,%bl
    shr $8,%ax
    mul %cx
    add %bx,%ax
    shl $1,%ax

    pop %cx
    pop %bx
    ret

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
    xor timer_ticks,%ax
    mov %ax,random
    pop %bx
    ret

.align 4
random:
    .2byte 0x0
timer_ticks:
    .2byte 0x0

initial_snake:
    .byte 39,13,40,13,41,13,42,13,0xff,0xff

direction:
    .byte 0x1