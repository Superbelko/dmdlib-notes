module example.ex01_codegen;

// Re-creates ex01 example code using AST nodes
Module makeAST_ex01()
{
    import dmd.astenums;
    import dmd.arraytypes;
    import dmd.declaration;
    import dmd.dimport;
    import dmd.dmodule;
    import dmd.dsymbol;
    import dmd.globals;
    import dmd.identifier;
    import dmd.init;
    import dmd.expression;
    import dmd.statement;
    import dmd.mtype;
    import dmd.func;
    import std.algorithm;


    // module node and members
    Module m = new Module(Loc.initial, "ex01.d", Identifier.idPool("ex01"), 0, 0);
    m.members = new Dsymbols();

    // module example.ex01;
    ModuleDeclaration* md = new ModuleDeclaration(Loc.initial, [Identifier.idPool("example")], Identifier.idPool("ex01"), null, false);
    m.md = md;

    // set parent package
    Package example = new Package(Loc.initial, Identifier.idPool("example"));
    m.parent = example;

    // import std.stdio;
    Import imp = new Import(Loc.initial, [Identifier.idPool("std")], Identifier.idPool("stdio"), null, 0);
    m.members.push(imp);

    // function type and decl:
    // void main ()
    TypeFunction funType = new TypeFunction(ParameterList(null), Type.tvoid, LINK.default_);
    FuncDeclaration mainFun = new FuncDeclaration(Loc.initial, Loc.initial, Identifier.idPool("main"), STC.undefined_, funType);

    // function body
    auto body_ = new CompoundStatement(Loc.initial);

    // string s = "Hello World";
    enum str = "Hello World";
    auto initVal = new StringExp(Loc.initial, str);
      auto initExpr = new ExpInitializer(Loc.initial, initVal);
        auto varDecl = new VarDeclaration(Loc.initial, Type.tstring, Identifier.idPool("s"), initExpr);
        auto declExp = new DeclarationExp(Loc.initial, varDecl);
      auto expStmt = new ExpStatement(Loc.initial, declExp);
    auto stmt = new CompoundStatement(Loc.initial, expStmt);

    // writeln(s);
    IdentifierExp parm0 = new IdentifierExp(Loc.initial, Identifier.lookup("s"));
    IdentifierExp callId = new IdentifierExp(Loc.initial, Identifier.lookup("writeln"));
    auto callExpr = new CallExp(Loc.initial, callId, parm0);
    auto callStmt = new ExpStatement(Loc.initial, callExpr);

    stmt.statements.push(callStmt);

    body_.statements.push(stmt);

    mainFun.fbody = body_;
    m.members.push(mainFun);
    
    return m;
}
