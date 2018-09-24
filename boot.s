.section .boot
.code16

# setup data segment pointer
mov $0x7D0, %ax
mov %ax, %ds

# set source index to point to hello string
mov $(hello-.data), %si
mov $0, %di
call write_to_screen

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

write_to_screen:
    mov $0, %ah
    int $0x16 # wait keypress
    
    cmp 0x08, %al
    je enter_pressed
    
    mov $0x0E, %ah
    int $0x10 # output keypress
    jmp write_to_screen

enter_pressed:
    mov $0x0E,%ah
    mov $0x0D,%al
    int $0x10
    mov $0x0A,%al
    int $0x10
    jmp write_to_screen

# vga print
vga_print:
    mov $15, %ah
    movb %ds:(%si), %al
    inc %si
    sub $0, %al
    jz return
    push ycoord
    push xcoord
    call terminal_putcharat
    add $4,%sp
    incw xcoord
    mov xcoord, %ax
    sub $VGA_WIDTH, %ax
    jnz vga_print
    movw $0, xcoord
    incw ycoord
    jmp vga_print


terminal_putcharat:
    push %bp
    mov %sp, %bp

    push %di
    
    mov 4(%bp), %di
    shlw $1, %di
    
    movw %ax,%es:(%di)

    pop %di
    pop %bp
    ret

return:
    ret

.section .data
hello:
    .ascii "Hello World!\0"