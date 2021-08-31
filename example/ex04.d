// Enums and alias example
module example.ex04;

enum {
    RED,
    GREEN,
    BLUE,
}

enum Flag : int
{
    withA = 1,
    withB = 1 << 1,
    withC = 1 << 2
}

// emulate C++ enum scope with alias after enum
enum Option
{
    optA,
    optB
}
alias optA = Option.optA;
alias optB = Option.optB;
