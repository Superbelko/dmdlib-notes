module example.ex05_codegen;

Module makeAST_ex05()
{
    import dmd.attrib;
    import dmd.astenums;
    import dmd.arraytypes;
    import dmd.declaration;
    import dmd.dimport;
    import dmd.denum;
    import dmd.dmodule;
    import dmd.dsymbol;
    import dmd.dstruct;
    import dmd.dclass;
    import dmd.dtemplate;
    import dmd.tokens;
    import dmd.globals;
    import dmd.identifier;
    import dmd.init;
    import dmd.expression;
    import dmd.statement;
    import dmd.mtype;
    import dmd.func;
    import std.algorithm;


    // module node and members
    Module m = new Module(Loc.initial, "ex05.d", Identifier.idPool("ex05"), 0, 0);
    m.members = new Dsymbols();

    // module example.ex04;
    ModuleDeclaration* md = new ModuleDeclaration(Loc.initial, [Identifier.idPool("example")], Identifier.idPool("ex05"), null, false);
    m.md = md;

    // set parent package
    Package example = new Package(Loc.initial, Identifier.idPool("example"));
    m.parent = example;

    // struct Vec2(T)
    TemplateParameters* vec2Params = new TemplateParameters();
    vec2Params.push(new TemplateTypeParameter(Loc.initial, Identifier.idPool("T"), null, null));
    TemplateDeclaration vec2Decl = new TemplateDeclaration(Loc.initial, Identifier.idPool("Vec2"), vec2Params, null, null);
    vec2Decl.members = new Dsymbols();
    StructDeclaration vec2Struct = new StructDeclaration(Loc.initial, Identifier.idPool("Vec2"), false);
    {
        vec2Struct.members = new Dsymbols();

        // T x;
        VarDeclaration vx = new VarDeclaration(
            Loc.initial, new TypeIdentifier(Loc.initial, Identifier.idPool("T")), Identifier.idPool("x"), null);
        vec2Struct.members.push(vx);

        // T y;
        VarDeclaration vy = new VarDeclaration(
            Loc.initial, new TypeIdentifier(Loc.initial, Identifier.idPool("T")), Identifier.idPool("y"), null);
        vec2Struct.members.push(vy);

        // Vec2!T opBinary(string op) (const Vec2!T rhs)
        //        ^^^^^^^^^^^^^^^^^^^
        Objects* tParams = new Objects();
        tParams.push(Type.tstring);
        TemplateParameters* opBinTParams = new TemplateParameters();
        opBinTParams.push(new TemplateTypeParameter(Loc.initial, Identifier.idPool("op"), Type.tstring, null));

        // Vec2!T opBinary(string op) (const Vec2!T rhs)  if(op == "+" || op == "-")
        //                                                ^^^^^^^^^^^^^^^^^^^^^^^^^^
        EqualExp plusExp = new EqualExp(TOK.equal, Loc.initial, new IdentifierExp(Loc.initial, Identifier.idPool("op")), new StringExp(Loc.initial, "+"));
        EqualExp minusExp = new EqualExp(TOK.equal, Loc.initial, new IdentifierExp(Loc.initial, Identifier.idPool("op")), new StringExp(Loc.initial, "-"));
        LogicalExp opBinConstraint = new LogicalExp(Loc.initial, TOK.orOr, plusExp, minusExp);
        TemplateDeclaration opBinTemp = new TemplateDeclaration(
            Loc.initial, Identifier.idPool("opBinary"), opBinTParams, opBinConstraint, null);
        opBinTemp.members = new Dsymbols();
        vec2Struct.members.push(opBinTemp);

        // Vec2!T opBinary(string op) (const Vec2!T rhs)
        // ^^^^^^                     ^^^^^^^^^^^^^^^^^^
        Objects* tVec2Params = new Objects();
        tVec2Params.push(new TypeIdentifier(Loc.initial, Identifier.idPool("T")));

        TemplateInstance tinst = new TemplateInstance(Loc.initial, Identifier.idPool("Vec2"), tVec2Params);
        Parameters* fparams = new Parameters();
        fparams.push(new Parameter(STC.const_, new TypeInstance(Loc.initial, tinst), Identifier.idPool("rhs"), null, null));

        TypeFunction ftype = new TypeFunction(ParameterList(fparams), new TypeInstance(Loc.initial, tinst), LINK.default_,); // <- reusing tinst here, probably a bad idea
        ftype.mod = MODFlags.const_; // <- this is what actually prints const on function
        FuncDeclaration opBin = new FuncDeclaration(Loc.initial, Loc.initial, Identifier.idPool("opBinary"), STC.undefined_, ftype); 
        opBinTemp.members.push(opBin);
        {
            // Vec2!T res;
            VarDeclaration resDecl = new VarDeclaration(Loc.initial, new TypeInstance(Loc.initial, tinst), Identifier.idPool("res"), null);
            ExpStatement st1 = new ExpStatement(Loc.initial, resDecl);
            
            // res.x = mixin("x " ~ op ~ " rhs.x");
            // notice the whitespaces in mixin strings
            CatExp xlhs4 = new CatExp(Loc.initial, new StringExp(Loc.initial, "x "), new IdentifierExp(Loc.initial, Identifier.idPool("op")));
            CatExp xlhs3 = new CatExp(Loc.initial, xlhs4, new StringExp(Loc.initial, " rhs.x"));
            Expressions* xmix2Exprs = new Expressions();
            xmix2Exprs.push(xlhs3);
            MixinExp xmix2 = new MixinExp(Loc.initial, xmix2Exprs);
            AssignExp xas1 = new AssignExp(Loc.initial, new DotIdExp(Loc.initial, new IdentifierExp(Loc.initial, Identifier.idPool("res")), Identifier.idPool("x")), xmix2);
            ExpStatement st2 = new ExpStatement(Loc.initial, xas1);

            // res.y = mixin("y " ~ op ~ " rhs.y");
            // notice the whitespaces in mixin strings
            CatExp ylhs4 = new CatExp(Loc.initial, new StringExp(Loc.initial, "y "), new IdentifierExp(Loc.initial, Identifier.idPool("op")));
            CatExp ylhs3 = new CatExp(Loc.initial, ylhs4, new StringExp(Loc.initial, " rhs.y"));
            Expressions* ymix2Exprs = new Expressions();
            ymix2Exprs.push(ylhs3);
            MixinExp ymix2 = new MixinExp(Loc.initial, ymix2Exprs);
            AssignExp yas1 = new AssignExp(Loc.initial, new DotIdExp(Loc.initial, new IdentifierExp(Loc.initial, Identifier.idPool("res")), Identifier.idPool("y")), ymix2);
            ExpStatement st3 = new ExpStatement(Loc.initial, yas1);

            // return res;
            ReturnStatement st4 = new ReturnStatement(Loc.initial, new IdentifierExp(Loc.initial, Identifier.idPool("res")));

            opBin.fbody = new CompoundStatement(Loc.initial, [st1, st2, st3, st4]);
        }
    }
    vec2Decl.members.push(vec2Struct);
    m.members.push(vec2Decl);

    // template Value(alias T)
    TemplateParameters* valueParams = new TemplateParameters();
    valueParams.push(new TemplateAliasParameter(Loc.initial, Identifier.idPool("T"), null, null, null));
    TemplateDeclaration valueDecl = new TemplateDeclaration(Loc.initial, Identifier.idPool("Value"), valueParams, null, null);
    valueDecl.members = new Dsymbols();
    VarDeclaration valueEnum = new VarDeclaration(Loc.initial, null, Identifier.idPool("Value"), new ExpInitializer(Loc.initial, new IdentifierExp(Loc.initial, Identifier.idPool("T"))), STC.manifest);
    valueDecl.members.push(valueEnum);
    m.members.push(valueDecl);

    // alias Secret = Value!42
    Objects* alparams = new Objects();
    alparams.push(new IntegerExp(42));
    TemplateInstance atinst = new TemplateInstance(Loc.initial, Identifier.idPool("Value"), alparams);
    TypeInstance aliasType = new TypeInstance(Loc.initial, atinst);
    AliasDeclaration aliasDecl = new AliasDeclaration(Loc.initial, Identifier.idPool("Secret"), aliasType);
    m.members.push(aliasDecl);

    Parameters* funParams = new Parameters();
    TypeFunction funType = new TypeFunction(ParameterList(funParams), Type.tvoid, LINK.default_);
    FuncDeclaration funDecl = new FuncDeclaration(Loc.initial, Loc.initial, Identifier.idPool("fun"), STC.undefined_, funType);
    m.members.push(funDecl);
    {
        ExpInitializer valInit = new ExpInitializer(Loc.initial, new IdentifierExp(Loc.initial, Identifier.idPool("Secret")));

        VarDeclaration ctvalDecl = new VarDeclaration(Loc.initial, null, Identifier.idPool("ctval"), valInit, STC.manifest);
        ExpStatement st1 = new ExpStatement(Loc.initial, ctvalDecl);

        VarDeclaration valDecl = new VarDeclaration(Loc.initial, Type.tint32, Identifier.idPool("val"), valInit);
        ExpStatement st2 = new ExpStatement(Loc.initial, valDecl);

        funDecl.fbody = new CompoundStatement(Loc.initial, [st1, st2]);
    }
    
    return m;
}