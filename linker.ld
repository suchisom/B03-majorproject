OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS
{
    /* Tell the linker to start placing code at address 0x00000000 */
    . = 0x00000000;

    .text : {
        /* Put the crt0.s _start code first */
        crt0.o(.text)
        /* Then put the rest of the C code */
        *(.text)
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}