.section .text
.global print

.set _out, 0xffff0000

print:
    lui t0, %hi(_out)
    sw a0, %lo(_out)(t0)
    ret
