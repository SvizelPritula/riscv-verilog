int stringLength(const char *string);

inline int modulo(int n, int d)
{
    return (n % d + d) % d;
}

template <typename T>
inline void swap(T &a, T &b)
{
    T aValue = a;
    T bValue = b;
    b = aValue;
    a = bValue;
}