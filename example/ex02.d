/// Basic example on StructDeclaration and ClassDeclaration
/// including variables and inheritance
module example.ex02;

struct Vec2
{
    float x;
    float y;
}

abstract class Shape
{
    float area();
}

class Rectangle : Shape
{
    protected float w;
    protected float h;
    protected Vec2 loc = Vec2(0,0);

    this(float w, float h) 
    { 
        this.w = w; 
        this.h = h;
    }

    override float area()
    {
        return w*h;
    }
}

class Square : Rectangle
{
    this(float side)
    {
        super(side, side);
    }
}
