#include <print.h>
#include <stdbool.h>

void printNumber(unsigned int n) {
    char digits[10];
    int i = 0;

    while (n > 0) {
        digits[i++] = '0' + (n % 10);
        n /= 10;
    }

    if (i == 0) print('0');

    while (i > 0) {
        print(digits[--i]);
    }
}

void printString(char *string) {
    while (*string != 0) {
        print(*string++);
    }
}

int primes[100] = {2};
int primeCount = 1;

bool isPrime(int n)
{
    for (int i = 0; i < primeCount; i++)
    {
        if (n % primes[i] == 0)
        {
            return false;
        }
    }

    return true;
}

void main()
{
    printString("The first 50 primes are:\n");
    printString("2\n");

    for (int i = 3; primeCount < 50; i += 2)
    {
        if (isPrime(i))
        {
            printNumber(i);
            print('\n');

            primes[primeCount++] = i;
        }
    }
}