OUTPUT_FORMAT(binary)

SECTIONS
{
    . = 0x7C00;
    .text : SUBALIGN(0)
    {
        *(.boot)
        *(.text)
    }

    . = 0x7D00;
    .data : SUBALIGN(0)
    {
        *(.data)
    }
    
    .sig : AT(0x7DFE)
    {
        SHORT(0xaa55)
    }
}