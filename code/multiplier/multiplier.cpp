#include <multiplier/multiplier.hpp>
#include <multiplier/types.hpp>

namespace
{
    const uint8_t opcode_opp_im = 0b0010011;
    const uint8_t opcode_opp = 0b0110011;
    const uint8_t opcode_jalr = 0b1100111;
    const uint8_t funct3_sll = 0b001;
    const uint8_t funct3_add = 0b000;

    const uint8_t reg_zero = 0;
    const uint8_t reg_ra = 1;
    const uint8_t reg_a0 = 10;
    const uint8_t reg_t0 = 5;
    const uint8_t reg_t1 = 6;

    constexpr uint32_t build_opp_im(uint8_t dest, uint8_t src, uint8_t funct3, uint16_t imm)
    {
        return opcode_opp_im | (dest << 7) | (funct3 << 12) | (src << 15) | (imm << 20);
    }

    constexpr uint32_t build_opp(uint8_t dest, uint8_t src1, uint8_t src2, uint8_t funct3, uint8_t funct7)
    {
        return opcode_opp | (dest << 7) | (funct3 << 12) | (src1 << 15) | (src2 << 20) | (funct7 << 15);
    }

    constexpr uint32_t build_jalr(uint8_t dest, uint8_t base, uint16_t imm)
    {
        return opcode_jalr | (dest << 7) | (base << 15) | (imm << 20);
    }

    constexpr uint32_t build_slli(uint8_t dest, uint8_t src, uint8_t shamt)
    {
        return build_opp_im(dest, src, funct3_sll, shamt);
    }

    constexpr uint32_t build_add(uint8_t dest, uint8_t src1, uint8_t src2)
    {
        return build_opp(dest, src1, src2, funct3_add, 0);
    }

    constexpr uint32_t build_mov(uint8_t dest, uint8_t src)
    {
        return build_add(dest, src, reg_zero);
    }

    constexpr uint32_t build_ret()
    {
        return build_jalr(reg_zero, reg_ra, 0);
    }
}

Multiplier::Multiplier(unsigned int number)
{
    uint32_t *ip = code;

    *(ip++) = build_mov(reg_t0, reg_a0);

    if ((number & 1) == 0)
    {
        *(ip++) = build_mov(reg_a0, reg_zero);
    }

    for (int i = 1; i < 32; i++)
    {
        if ((number >> i) & 1)
        {
            *(ip++) = build_slli(reg_t1, reg_t0, i);
            *(ip++) = build_add(reg_a0, reg_a0, reg_t1);
        }
    }

    *(ip++) = build_ret();
}
