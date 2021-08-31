module example.ex05;

// Generic Vec2 variant
struct Vec2(T)
{
    T x;
    T y;

    Vec2!T opBinary(string op)(const Vec2!T rhs) const
        if (op == "+" || op == "-")
    {
        Vec2!T res;
        res.x = mixin("x " ~ op ~ " rhs.x");
        res.y = mixin("y " ~ op ~ " rhs.y");
        return res;
    }
}

// Eponymous template
template Value(alias T)
{
    enum Value = T;
}

alias Secret = Value!42;

void fun()
{
    enum ctval = Secret;
    int val = Secret;
}
