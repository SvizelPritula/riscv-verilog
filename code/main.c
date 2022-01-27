#include <print.h>
#include <stdbool.h>

char getHexDigit(unsigned char d)
{
    if (d < 10)
        return '0' + d;
    else
        return 'a' - 10 + d;
}

void printNumberHex(unsigned int n)
{
    char digits[8];

    for (int i = 0; i < 8; i++)
    {
        int digit = n & 0xf;
        digits[i] = getHexDigit(digit);

        n >>= 4;
    }

    for (int i = 7; i >= 0; i--)
    {
        print(digits[i]);
    }

    print('\n');
}

void printArrayHex(unsigned char *array, int length)
{
    for (int i = 0; i < length; i++)
    {
        unsigned char b = *(array + i);

        print(getHexDigit(b >> 4));
        print(getHexDigit(b & 0xf));
    }

    print('\n');
}

void fillArray(unsigned char *array, int length, unsigned char value)
{
    for (int i = 0; i < length; i++)
    {
        *(array + i) = value;
    }
}

unsigned char read_data[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef};
unsigned char write_data[8];

void main()
{
    for (unsigned char *p = read_data; p <= read_data + sizeof(read_data) - sizeof(int); p++)
    {
        printNumberHex(*(int *)p);
    }

    fillArray(write_data, sizeof(write_data), 0);
    *(int*)(write_data + 2) = 0x12345678;

    printArrayHex(write_data, sizeof(write_data));
}