module example.ex04_codegen;

Module makeAST_ex04()
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
    import dmd.globals;
    import dmd.identifier;
    import dmd.init;
    import dmd.expression;
    import dmd.statement;
    import dmd.mtype;
    import dmd.func;
    import std.algorithm;


    // module node and members
    Module m = new Module(Loc.initial, "ex04.d", Identifier.idPool("ex04"), 0, 0);
    m.members = new Dsymbols();

    // module example.ex04;
    ModuleDeclaration* md = new ModuleDeclaration(Loc.initial, [Identifier.idPool("example")], Identifier.idPool("ex04"), null, false);
    m.md = md;

    // set parent package
    Package example = new Package(Loc.initial, Identifier.idPool("example"));
    m.parent = example;

    // enum { RED, GREEN, BLUE }
    EnumDeclaration enum1Decl = new EnumDeclaration(Loc.initial, null, null);
    {
        enum1Decl.members = new Dsymbols();

        auto red = new EnumMember(Loc.initial, Identifier.idPool("RED"), null, null, STC.undefined_, null, null);
        enum1Decl.members.push(red);

        auto green = new EnumMember(Loc.initial, Identifier.idPool("GREEN"), null, null, STC.undefined_, null, null);
        enum1Decl.members.push(green);

        auto blue = new EnumMember(Loc.initial, Identifier.idPool("BLUE"), null, null, STC.undefined_, null, null);
        enum1Decl.members.push(blue);
    }
    m.members.push(enum1Decl);

    // enum Flag : int
    EnumDeclaration enumFlagDecl = new EnumDeclaration(Loc.initial, Identifier.idPool("Flag"), Type.tint32);
    {
        enumFlagDecl.members = new Dsymbols();

        // withA = 1
        auto withA = new EnumMember(Loc.initial, Identifier.idPool("withA"), new IntegerExp(Loc.initial, 1, Type.tint32), null, STC.undefined_, null, null);
        enumFlagDecl.members.push(withA);

        // 1 << 1
        auto withBInitExp = new ShlExp(Loc.initial, new IntegerExp(Loc.initial, 1, Type.tint32), new IntegerExp(Loc.initial, 1, Type.tint32));
        // withB = 1 << 1
        auto withB = new EnumMember(Loc.initial, Identifier.idPool("withB"), withBInitExp, null, STC.undefined_, null, null);
        enumFlagDecl.members.push(withB);

        // 1 << 2
        auto withCInitExp = new ShlExp(Loc.initial, new IntegerExp(Loc.initial, 1, Type.tint32), new IntegerExp(Loc.initial, 2, Type.tint32));
        // withC = 1 << 1
        auto withC = new EnumMember(Loc.initial, Identifier.idPool("withC"), withCInitExp, null, STC.undefined_, null, null);
        enumFlagDecl.members.push(withC);
    }
    m.members.push(enumFlagDecl);

    EnumDeclaration enumOptionDecl = new EnumDeclaration(Loc.initial, Identifier.idPool("Option"), null);
    {
        enumOptionDecl.members = new Dsymbols();

        auto optA = new EnumMember(Loc.initial, Identifier.idPool("optA"), null, null, STC.undefined_, null, null);
        enumOptionDecl.members.push(optA);

        auto optB = new EnumMember(Loc.initial, Identifier.idPool("optB"), null, null, STC.undefined_, null, null);
        enumOptionDecl.members.push(optB);
    }
    m.members.push(enumOptionDecl);

    TypeIdentifier tyA = new TypeIdentifier(Loc.initial, Identifier.idPool("Option"));
    tyA.idents.push(Identifier.idPool("optA"));
    AliasDeclaration optAAlias = new AliasDeclaration(Loc.initial, Identifier.idPool("optA"), tyA);
    m.members.push(optAAlias);

    TypeIdentifier tyB = new TypeIdentifier(Loc.initial, Identifier.idPool("Option"));
    tyB.idents.push(Identifier.idPool("optB"));
    AliasDeclaration optBAlias = new AliasDeclaration(Loc.initial, Identifier.idPool("optB"), tyB);
    m.members.push(optBAlias);
    
    return m;
}