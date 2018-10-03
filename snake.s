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

    # initialize segments
    xor %ax, %ax
    mov %ax, %ss
    mov %ax, %ds

    sti

init_random_value:
    mov 0x46C,%dx
    mov %dx,random
   
   
init_game:
    # copy initial state of snake into 0x7E00
    mov $0x7E00,%bx
    mov $0x876,%ax
    mov $4,%cx
    
init_snake:
    mov %ax,(%bx)
    dec %ax
    dec %ax
    inc %bx
    inc %bx
    loop init_snake
    movw $0xFFFF,(%bx)
    /* set callback for loop snake */
    mov $draw_snake,%bx
    mov $2,%dx # current direction

game_loop:
    # wait 18 ints
    mov $18,%cx
sleep:
    hlt
    loop sleep
    
    # handle a keypress
    mov $1,%ah
    int $0x16
    jz keypress_done # keypress is not available
    mov $0,%ah # get keypress
    int $0x16
    test $0xF,%dx # this is 0 if we are moving vertically
    jz moving_vert1
moving_horiz1:
    cmp $'w',%al
    jne moving_horiz2
    mov $-0xA0,%dx
moving_horiz2:
    cmp $'s',%al
    jne keypress_done
    mov $0xA0,%dx
moving_vert1:
    cmp $'d',%al
    jne moving_vert2
    mov $2,%dx
moving_vert2:
    cmp $'a',%al
    jne keypress_done
    mov $-2,%dx

keypress_done:
    # cx is zero here because of sleep loop
    call loop_snake
    call mov_snake
    mov $0x0f09,%cx
    call loop_snake
    jmp game_loop

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
    
    # update current direction


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
    
    # at this point, %ax contains head
    # update direction
    # ! important ! fix ds for these references to work
    # ! important ! don't fix es yet, for stos to work
    pop %ds
    add %dx,%ax
    stosw
    cld
    pop %es
    popa
    ret


/* Returns 16bit pseudo-random number in ax */
.global get_random
.type get_random,@function
get_random:
    push %bx
    mov random,%ax
    mov 0x46C,%bx
    xor %bx,%ax
    mov %ax,random
    pop %bx
    ret

.align 2
random:
    .2byte 0x0