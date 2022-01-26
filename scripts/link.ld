OUTPUT_ARCH("riscv")

ENTRY(_start)

MEMORY 
{
  rom (rx): ORIGIN = 0, LENGTH = 1M
  ram (!r): ORIGIN = 0x80000000, LENGTH = 4K
}

SECTIONS
{
.text :
    ALIGN (4)
    {
        _text_start = .;
        *(.text.start) *(.text) *(.text.*)
        _text_end = .;
    } > rom
.bss :
    ALIGN (4)
    {
        _bss_start = .;
        *(.bss.stack) *(.bss) *(.bss.*) *(COMMON)
        _bss_end = .;
    } > ram
.data :
    AT ( ADDR(.text) + SIZEOF ( .text ) )
    ALIGN (4)
    {
        _data_start = .;
        *(.data) *(.data.*) *(.sdata) *(.sdata.*) *(.rodata) *(.rodata.*)
        _data_end = .;
    } > ram
}

_data_init_start = _text_end;
_data_init_end = _text_end + SIZEOF ( .data );