#include <lib/print.h>

const char message[] = "Hello world!\n";

int main()
{
    for (const char *p = message; *p; p++)
    {
        print(*p);
    }

    return 0;
}
