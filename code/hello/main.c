#include <print.h>

const char message[] = "Hello world!\n";

int main()
{
    for (char *p = message; *p; p++)
    {
        print(*p);
    }

    return 0;
}
