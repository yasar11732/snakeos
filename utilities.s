.code16
.text


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


# print decimal representation of a %ax
.global printd
.type printd,@function
printd:
    push %bx
    push %dx
    mov $10,%bx
    push %bx
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