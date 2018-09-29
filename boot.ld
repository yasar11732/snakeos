OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x7C00;
    __start = .;

    .text : 
    {
        *(.text);
    }

    .sig : AT(0X7DFE)
    {
        SHORT(0XAA55);
    }

}