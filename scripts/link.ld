OUTPUT_ARCH("riscv")

ENTRY(_start)

MEMORY 
{
  rom (rx): ORIGIN = 0x0, LENGTH = 1M
  ram (!r): ORIGIN = 0x80000000, LENGTH = 4K
}

SECTIONS
{
.text 0x0:
    ALIGN (4)
    {
        _text_start = .;
        *(.text.start) *(.text) *(.text.*)
        _text_end = .;
        
        _init_array_start = .;
        *(.init_array) *(.init_array.*)
        _init_array_end = .;

        _rodata_start = .;
        *(.rodata) *(.rodata.*) *(.srodata) *(.srodata.*)
        _rodata_end = .;

        _eh_frame_start = .;
        *(.eh_frame) *(.eh_frame.*)
        _eh_frame_end = .;
    } > rom
.bss 0x80000000:
    ALIGN (4)
    {
        _bss_start = .;
        *(.bss.stack) *(.bss) *(.bss.*) *(.sbss) *(.sbss.*) *(COMMON)
        _bss_end = .;
    } > ram
.data :
    AT (ADDR(.text) + SIZEOF (.text))
    ALIGN (4)
    {
        _data_start = .;
        *(.data) *(.data.*) *(.sdata) *(.sdata.*)
        _data_end = .;
    } > ram
}

_data_init_start = ADDR(.text) + SIZEOF (.text);
_data_init_end = ADDR(.text) + SIZEOF (.text) + SIZEOF (.data);
