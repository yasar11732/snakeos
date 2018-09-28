OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x7C00;
    __start = .;

    .first_stage : 
    {
        build/first_stage.o
    }

    .sig : AT(0X7DFE)
    {
        SHORT(0XAA55);
    }

    . = ALIGN(512);
    __second_stage_start = .;
    .second_stage : 
    {
        build/second_stage.o
    }

    .rodata : ALIGN(512)
    {
        *(.rodata)
    }
    
    .data : ALIGN(512)
    {
        *(.data)
    }

    .end : ALIGN(512)
    {
        __BINARY_SIZE = ABSOLUTE(. - __start);
    }

}