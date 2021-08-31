module example.ex02_codegen;

Module makeAST_ex02()
{
    import dmd.attrib;
    import dmd.astenums;
    import dmd.arraytypes;
    import dmd.declaration;
    import dmd.dimport;
    import dmd.dmodule;
    import dmd.dsymbol;
    import dmd.dstruct;
    import dmd.dclass;
    import dmd.globals;
    import dmd.identifier;
    import dmd.init;
    import dmd.expression;
    import dmd.statement;
    import dmd.mtype;
    import dmd.func;
    import std.algorithm;


    // module node and members
    Module m = new Module(Loc.initial, "ex02.d", Identifier.idPool("ex02"), 0, 0);
    m.members = new Dsymbols();

    // module example.ex02;
    ModuleDeclaration* md = new ModuleDeclaration(Loc.initial, [Identifier.idPool("example")], Identifier.idPool("ex02"), null, false);
    m.md = md;

    // set parent package
    Package example = new Package(Loc.initial, Identifier.idPool("example"));
    m.parent = example;

    // struct Vec2 { float x, y; }
    StructDeclaration vec2Decl = new StructDeclaration(Loc.initial, Identifier.idPool("Vec2"), false);
    VarDeclaration xfield = new VarDeclaration(Loc.initial, Type.tfloat32, Identifier.idPool("x"), null);
    VarDeclaration yfield = new VarDeclaration(Loc.initial, Type.tfloat32, Identifier.idPool("y"), null);
    vec2Decl.members = new Dsymbols();
    vec2Decl.members.push(xfield);
    vec2Decl.members.push(yfield);
    m.members.push(vec2Decl);

    // class Shape
    ClassDeclaration shapeDecl = new ClassDeclaration(Loc.initial, Identifier.idPool("Shape"), null, new Dsymbols(), false);
    // float area()
    TypeFunction areaType = new TypeFunction(ParameterList(), Type.tfloat32, LINK.default_);
    FuncDeclaration areaDecl = new FuncDeclaration(Loc.initial, Loc.initial, Identifier.idPool("area"), STC.undefined_, areaType);
    shapeDecl.members.push(areaDecl);
    // abstract class Shape
    auto shapeSyms = new Dsymbols();
    shapeSyms.push(shapeDecl);
    StorageClassDeclaration shapeSC = new StorageClassDeclaration(STC.abstract_, shapeSyms);
    m.members.push(shapeSC);

    // class Rectangle : Shape
    ClassDeclaration rectDecl = new ClassDeclaration(Loc.initial, Identifier.idPool("Rectangle"), null, new Dsymbols(), false);
    
    // protected float w
    VarDeclaration wDecl = new VarDeclaration(Loc.initial, Type.tfloat32, Identifier.idPool("w"), null);
    auto dsymVisW = new Dsymbols();
    dsymVisW.push(wDecl);
    VisibilityDeclaration visDeclW = new VisibilityDeclaration(Loc.initial, Visibility(Visibility.Kind.protected_), dsymVisW);
    rectDecl.members.push(visDeclW);

    // protected float h
    VarDeclaration hDecl = new VarDeclaration(Loc.initial, Type.tfloat32, Identifier.idPool("h"), null);
    auto dsymVisH = new Dsymbols();
    dsymVisH.push(hDecl);
    VisibilityDeclaration visDeclH = new VisibilityDeclaration(Loc.initial, Visibility(Visibility.Kind.protected_), dsymVisH);
    rectDecl.members.push(visDeclH);

    // protected Vec2 loc
    TypeStruct locType = new TypeStruct(vec2Decl);
    VarDeclaration locDecl = new VarDeclaration(Loc.initial, locType, Identifier.idPool("loc"), null);
    auto dsymVisLoc = new Dsymbols();
    dsymVisLoc.push(locDecl);
    VisibilityDeclaration visDeclLoc = new VisibilityDeclaration(Loc.initial, Visibility(Visibility.Kind.protected_), dsymVisLoc);
    rectDecl.members.push(visDeclLoc);

    // this(float w, float h)
    {
        auto params = new Parameters();
        Parameter p1 = new Parameter(STC.undefined_, Type.tfloat32, Identifier.idPool("w"), null, null);
        params.push(p1);
        Parameter p2 = new Parameter(STC.undefined_, Type.tfloat32, Identifier.idPool("h"), null, null);
        params.push(p2);
        TypeFunction ctorType = new TypeFunction(ParameterList(params), Type.tvoid, LINK.default_);
        CtorDeclaration ctorDecl = new CtorDeclaration(Loc.initial, Loc.initial, STC.undefined_, ctorType);

        auto ctorBody_ = new CompoundStatement(Loc.initial);
        // this.w = w
        DotIdExp dieW = new DotIdExp(Loc.initial, new ThisExp(Loc.initial), Identifier.idPool("w"));
        IdentifierExp parmW = new IdentifierExp(Loc.initial, Identifier.lookup("w"));
        auto assignExpW = new AssignExp(Loc.initial, dieW, parmW);
        auto expW = new ExpStatement(Loc.initial, assignExpW);

        // this.h = h
        DotIdExp dieH = new DotIdExp(Loc.initial, new ThisExp(Loc.initial), Identifier.idPool("h"));
        IdentifierExp parmH = new IdentifierExp(Loc.initial, Identifier.lookup("h"));
        auto assignExpH = new AssignExp(Loc.initial, dieH, parmH);
        auto expH = new ExpStatement(Loc.initial, assignExpH);


        ctorBody_.statements.push(expW);
        ctorBody_.statements.push(expH);
        ctorDecl.fbody = ctorBody_;

        rectDecl.members.push(ctorDecl);
    }

    // override float area()
    {
        TypeFunction funType = new TypeFunction(ParameterList(), Type.tfloat32, LINK.default_);
        FuncDeclaration funDecl = new FuncDeclaration(Loc.initial, Loc.initial, Identifier.idPool("area"), STC.override_, funType);
        auto funBody = new CompoundStatement(Loc.initial);
        // return w * h
        IdentifierExp parmW = new IdentifierExp(Loc.initial, Identifier.lookup("w"));
        IdentifierExp parmH = new IdentifierExp(Loc.initial, Identifier.lookup("h"));
        auto mulExp = new MulExp(Loc.initial, parmW, parmH);
        auto ret = new ReturnStatement(Loc.initial, mulExp);
        funBody.statements.push(ret);
        funDecl.fbody = funBody;

        rectDecl.members.push(funDecl);
    }

    m.members.push(rectDecl);

    // class Square : Rectangle
    ClassDeclaration squareDecl = new ClassDeclaration(Loc.initial, Identifier.idPool("Square"), null, new Dsymbols(), false);
    {
        auto params = new Parameters();
        Parameter p1 = new Parameter(STC.undefined_, Type.tfloat32, Identifier.idPool("side"), null, null);
        params.push(p1);
        TypeFunction ctorType = new TypeFunction(ParameterList(params), Type.tvoid, LINK.default_);
        CtorDeclaration ctorDecl = new CtorDeclaration(Loc.initial, Loc.initial, STC.undefined_, ctorType);

        auto ctorBody_ = new CompoundStatement(Loc.initial);
        // super(side,side);
        IdentifierExp parmSide = new IdentifierExp(Loc.initial, Identifier.lookup("side"));
        SuperExp se = new SuperExp(Loc.initial);
        auto callExpr = new CallExp(Loc.initial, se, parmSide, parmSide);
        auto callStmt = new ExpStatement(Loc.initial, callExpr);
        ctorBody_.statements.push(callStmt);
        ctorDecl.fbody = ctorBody_;
        squareDecl.members.push(ctorDecl);

    }
    m.members.push(squareDecl);
    
    return m;
}
