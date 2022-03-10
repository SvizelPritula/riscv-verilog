#include <stdint.h>
#include <lib/print.hpp>
#include <art/random.hpp>

int seed = 0x5bf05398;

const int multiplier = 69069;
const int increment = 1;

int getRandomInt()
{
    seed *= multiplier;
    seed += increment;

    return seed;
}
