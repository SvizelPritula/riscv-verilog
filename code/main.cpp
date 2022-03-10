#include <canvas.hpp>
#include <random.hpp>

Canvas<64, 16> canvas;

const char palette[] = {'.', ':', '-', '=', '*', '#', '%', '@'};

const int maxRectSize = 8;

void drawRandomRects()
{
    for (int i = 0; i < 32; i++)
    {
        int x = getRandomInt() % (canvas.width() - maxRectSize);
        int y = getRandomInt() % (canvas.height() - maxRectSize);
        int width = getRandomInt() % maxRectSize;
        int height = getRandomInt() % maxRectSize;
        char color = palette[getRandomInt() % (sizeof(palette) / sizeof(palette[0]))];

        canvas.drawRect(x, y, x + width, y + height, color);
    }
}

void drawFrame()
{
    for (int x = 1; x < canvas.width() - 1; x++)
    {
        canvas(x, 0) = '-';
        canvas(x, -1) = '-';
    }

    for (int y = 1; y < canvas.height() - 1; y++)
    {
        canvas(0, y) = '|';
        canvas(-1, y) = '|';
    }

    canvas(0, 0) = '+';
    canvas(0, -1) = '+';
    canvas(-1, 0) = '+';
    canvas(-1, -1) = '+';
}

void sign()
{
    canvas.write(-3, -2, "RISC-V cpu", right);
}

int main()
{
    drawRandomRects();

    drawFrame();
    sign();

    canvas.print();

    return 0;
}