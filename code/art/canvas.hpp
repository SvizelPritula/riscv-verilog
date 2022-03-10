#include <utils.hpp>
#include <print.hpp>

enum TextAlignment
{
    left,
    right,
    center
};

template <int W, int H>
class Canvas
{
private:
    char array[W][H];

public:
    Canvas()
    {
        for (int x = 0; x < W; x++)
        {
            for (int y = 0; y < H; y++)
            {
                (*this)(x, y) = ' ';
            }
        }
    }

    inline char &operator()(int x, int y) { return array[modulo(x, W)][modulo(y, H)]; }
    inline const char &operator()(int x, int y) const { return array[modulo(x, W)][modulo(y, H)]; }

    inline int height() { return H; }
    inline int width() { return W; }

    void print()
    {
        for (int y = 0; y < H; y++)
        {
            for (int x = 0; x < W; x++)
            {
                ::print((*this)(x, y));
            }
            ::print('\n');
        }
    }

    void write(int x, int y, const char *text, TextAlignment alignment = left)
    {
        if (alignment == right)
            x -= stringLength(text) - 1;
        if (alignment == center)
            x -= stringLength(text) / 2;

        for (const char *p = text; *p; p++)
        {
            (*this)(x++, y) = *p;
        }
    }

    void drawRect(int x1, int y1, int x2, int y2, char c)
    {
        if (x2 < x1)
            swap(x1, x2);
        if (y2 < y1)
            swap(y1, y2);

        for (int x = x1; x <= x2; x++)
        {
            for (int y = y1; y <= y2; y++)
            {
                (*this)(x, y) = c;
            }
        }
    }
};