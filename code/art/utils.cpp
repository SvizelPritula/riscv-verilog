#include <utils.hpp>

int stringLength(const char *string)
{
    int length = 0;

    for (const char *p = string; *p; p++)
    {
        length++;
    }

    return length;
}