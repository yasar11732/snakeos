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
    mov $0x7E0,%ax
    mov %ax,%es
    mov %ax,%ds
    mov $4,%ax
    xor %di,%di
    stosw
    
    mov %ax,%cx
    mov $0x876,%ax

init_snake:
    stosw
    dec %ax
    dec %ax
    loop init_snake

    mov $2,%dx # current direction

game_loop:
    # wait 18 ints
    mov $18,%cx
sleep:
    hlt
    loop sleep
    
handle_keypress:
    mov $1,%ah       # check if keypress is availabe
    int $0x16
    jz keypress_done # keypress is not available
    mov $0,%ah       # get keypress
    int $0x16
    test $0xF,%dx    # this is 0 if we are moving vertically
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

mov_snake:
    xor %si,%si
    lodsw       # ax = length of snake
    std         # we will loop backwards
    mov %ax,%si
    shl $1,%si  # x2 because we are using words
    mov %si,%di
    lodsw       # ax = tail of snake in screen
    push %ax    # save tail in stack
mov_snake_loop:
    lodsw
    stosw
    or %si,%si
    jnz mov_snake_loop
    
    # at this point ax is the old head
    add %dx,%ax # calculate new head
    stosw       # put new head
    
    pop %di
    push %es
    mov $0xB800,%bx
    mov %bx,%es
    movw $0x0000,%es:(%di)
    mov %ax,%di            
    movw $0x0F09,%es:(%di)
    
    pop %es

    jmp game_loop

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