.section .text.start
.global _start
.weak main

_halt = 0xffff0004

_start:
    la t0, _data_init_start
    la t1, _data_start
    la t2, _data_init_end

load_loop:
    bgeu t0, t2, load_done
    lw t3, (t0)
    sw t3, (t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j load_loop

load_done:
    la t0, _bss_start
    la t1, _bss_end
    li t2, 0

zero_loop:
    bgeu t0, t1, zero_done
    sw t2, (t0)
    addi t0, t0, 4
    j zero_loop

zero_done:
    la sp, stack_end - 4
    jal ra, main

    la t0, _halt
    sw t0, (t0)

.section .bss.stack
stack_start:
    .skip 1024
stack_end: