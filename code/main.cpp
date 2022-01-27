#include <print.hpp>

typedef int graphFunction(int x);

int max(int a, int b)
{
    return a > b ? a : b;
}

int abs(int n)
{
    return n < 0 ? -n : n;
}

int countDigits(int n)
{
    int digits = n < 0 ? 1 : 0;

    do
    {
        digits++;
        n /= 10;
    } while (n != 0);

    return digits;
}

char getDigit(int n, int digit)
{
    bool negative = n < 0;

    int i;
    for (i = 0; i < digit && n != 0; i++)
    {
        n /= 10;
    }

    if (n != 0)
    {
        return '0' + abs(n % 10);
    }

    if (digit == 0)
        return '0';

    if (negative && i == digit)
        return '-';

    return ' ';
}

void printGraph(graphFunction callback, int xStart, int xEnd, int yStart, int yEnd)
{
    int xDigits = max(countDigits(xStart), countDigits(xEnd));
    int yDigits = max(countDigits(yStart), countDigits(yEnd));

    for (int y = yEnd; y >= yStart; y--)
    {
        for (int d = 0; d < yDigits; d++)
        {
            print(getDigit(y, yDigits - d - 1));
        }

        print(' ');

        for (int x = xStart; x <= xEnd; x++)
        {
            if (callback(x) == y)
            {
                print('#');
            }
            else
            {
                if (x == 0 && y == 0)
                    print('+');
                else if (y == 0)
                    print('-');
                else if (x == 0)
                    print('|');
                else
                    print(' ');
            }
        }

        print('\n');
    }

    for (int x = 0; x <= xDigits + 1 + xEnd - xStart; x++)
    {
        print(' ');
    }
    print('\n');

    for (int d = 0; d < xDigits; d++)
    {
        for (int yd = 0; yd < yDigits + 1; yd++)
        {
            print(' ');
        }

        for (int x = xStart; x <= xEnd; x++)
        {
            print(getDigit(x, xDigits - d - 1));
        }

        print('\n');
    }
}

int func(int x)
{
    return 2 + x / 2;
}

int main()
{
    printGraph(func, -10, 10, -10, 10);
}