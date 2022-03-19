#include <multiplier/multiplier.hpp>
#include <multiplier/types.hpp>
#include <lib/print.hpp>

Multiplier mult(123);

void printInt(unsigned int n)
{
    for (int i = 31; i >= 0; i--)
    {
        print('0' + ((n >> i) & 1));
    }
}

int main()
{
    printInt(mult(456));
    print('\n');

    return 0;
}