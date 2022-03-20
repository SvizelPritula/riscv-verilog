.section .text.start
.global _start
.weak main

.set _power, 0xffff0004

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

zero_loop:
    bgeu t0, t1, zero_done
    sw zero, (t0)
    addi t0, t0, 4
    j zero_loop

zero_done:
    la sp, stack_end - 4
    la s0, _init_array_start
    la s1, _init_array_end
    li s3, 0xffffffff

init_loop:
    bgeu s0, s1, init_done
    lw s2, (s0)
    beqz s2, init_continue
    beq s2, s3, init_continue
    jalr ra, (s2)
    
init_continue:
    addi s0, s0, 4
    j init_loop

init_done:
    jal ra, main

    lui t0, %hi(_power)
    sw a0, %lo(_power)(t0)

.section .bss.stack
stack_start:
    .skip 1024
stack_end:
