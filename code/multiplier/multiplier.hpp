namespace
{
    typedef unsigned int built_code(unsigned int);
}

class Multiplier
{
private:
    unsigned int code[31 * 2 + 3];

public:
    Multiplier(unsigned int number);
    inline unsigned int operator()(unsigned int number)
    {
        return ((built_code *)code)(number);
    }
};