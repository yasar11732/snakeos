.set VGA_WIDTH, 80
.set VGA_HEIGHT, 25

.code16
.text
.global _second_stage_start
_second_stage_start:

    call write_to_screen

    hang:
        hlt
        jmp hang

    # print all characters
    bios_print:
        lodsb
        sub $0, %al
        jz return
        mov $0x0E, %ah
        int $0x10
        jmp bios_print

.global write_to_screen
.type write_to_screen, @function
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

    # put seconds to sleep in %al and call
    sleep:
        push %bx
        mov $18,%bx
        mul %bx
        pop %bx

        sub $0,%ax
        jnz sleep_loop
        ret
    sleep_loop:
        hlt
        jmp sleep
    # vga print
    .global vga_print
    .type vga_print,@function
    vga_print:
        mov $1,%al
        call sleep
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

.section .rodata
.global hello
hello:
    .ascii "Helloowww World!!!\0"

.section .data
.align 2
xcoord:
    .2byte 0

.align 2
ycoord:
    .2byte 0
