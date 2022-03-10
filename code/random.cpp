#include <random.hpp>
#include <stdint.h>
#include <print.hpp>

uint64_t seed = 0x8ea9a6311ee39b8bUL;

const uint64_t multiplier = 0x5851f42d4c957f2dUL;
const uint64_t increment = 1;

int getRandomInt()
{
    seed *= multiplier;
    seed += increment;

    return seed >> (64 - sizeof(int) * 8);
}