.section .text
.global print

_out = 0xffff0000

print:
    la t0, _out
    sw a0, (t0)
    ret
