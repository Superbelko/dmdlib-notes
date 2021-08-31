# DMD (as a library) cheatsheet

## Contents

* <a href="#introduction">Introduction</a>
  - <a href="#initproject">Initialize project</a>
  - <a href="#startingcode">Starting code</a>
  - <a href="#aboutsema">About semantic pass</a>
* <a href="#tipsandrecipes">Tips and recipes</a>
  - <a href="#asttostring">AST to string</a>
  - <a href="#searchbyid">Searching symbol by name (identifier)</a>
  - <a href="#castbase">Casting base types to subclasses</a>
  - <a href="#searchinimports">Searching up with imports</a>
  - <a href="#iteratemembers">Iterate module members</a>
  - <a href="#createnewdecl">Creating new declarations</a>
  - <a href="#getcppnamespace">Getting list of C++ namespaces</a>
  - <a href="#symbolcomments">Reading comments</a>

<a id="introduction"></a>
## Introduction

<a id="initproject"></a>
### Initialize project
Setting up a dub project and adding dmd dependency is pretty trivial and not be covered here, here is the basic terminal command list to achieve this without any details.

```sh
mkdir myproject
cd myproject
dub init
dub add dmd
dub run
```

<a id="startingcode"></a>
### Starting code
Assuming reader has working project this document builds up on that starting point, and uses the following code as a base minimal, every snippet in cheatsheet section continues on this code unless stated otherwise.

Any input code assumed to be passed as path to source file using first command line argument.

__app.d__:
```d
import std.stdio;
import std.algorithm;
import std.file : readText;

import dmd.frontend;
import dmd.globals;
import dmd.dmodule;
import dmd.dsymbol;
import dmd.identifier;
import dmd.declaration;
import dmd.dstruct;
import dmd.aggregate; 
import dmd.attrib; // CPPNamespaceDeclaration
import dmd.dversion;

// App entry point
void main(string[] args)
{
    // Initializes compiler internals, this is where you add version identifiers
    initDMD();

    // Shutdowns compiler instance, you can call initDMD() again to get fresh compiler instance after that
    // Using scope(exit) will automatically runs the code when leaving the scope (main function)
    scope(exit) 
      deinitializeDMD();

    // Run addImport(path) to register default search paths, you can add your own paths using that function
    findImportPaths.each!addImport();

    // Now let's parse some code, after that depending on our needs we can run semantic analysis or try to modify AST or add/remove declarations
    const sourcePath = args[1];
    const sourceText = readText(sourcePath);
    auto t = parseModule(sourcePath, sourceText);

    // (Optional) Check for any warnings/errors, for example if you have version(none) code 
    // that you'd like to parse anyway adding "none" as version will yield an error
    assert(!t.diagnostics.hasErrors);
    assert(!t.diagnostics.hasWarnings);

    // Define a shorthand for convenience
    Module m = t.module_;

    // Does a semantic pass, if you write some sort of complex code analyzer you'd probably want to run after semantic analysis
    // WARNING: Read note below for more details
    //m.fullSemantic(); 

    // >>> RECIPES AND TIPS CODE GOES HERE <<<
}
```

<a id="aboutsema"></a>
### About semantic pass

Running semantic pass expands some language constructs and inject template instantiations, for example UFCS calls got replaced with regular calls - `42.writeln` becomes `writeln(42)`, it also inserts implicit imports like `import object` on top of each module and more. Keep it in mind, you probably don't want to mess up user code with your DMD based tool so any code formatters/style tools wiil likely operate without semantic pass.

Running semantic pass on this code and then prettyPrint it yields over 1k lines of code output.

__hello.d__:
```d
import std.stdio;

void main()
{
    string s = "Hello World";
    writeln(s);
}
```

<br/>

<a id="tipsandrecipes"></a>
## Tips and recipes

<hr/><br/>

<a id="asttostring"></a>
### AST to string

One of the most important features is ability to format code as text from compiler representation, it is helpful for debugging purposes to observe how resulting code will look like after modifications, or writing it back to disk.

Things to be aware of:
- doesn't preserve any formatting
- ouput differs before and after semantic pass

```d
    // Let's print our AST back to text again
    string source = prettyPrint(m);
    writeln(source);
```

<hr/>

<a id="searchbyid"></a>
### Searching symbol by name (identifier)

One of the most important operations is looking up symbols by name, Module class (and most Dsymbol subclasses) have search() method that takes Location and identifier as well as optional operation flags.

```d
    // Try to find identifier by name
    auto id = Identifier.idPool("MyClass");
    Dsymbol myClass = m.search(Loc.initial, id);
```

<hr/>

<a id="castbase"></a>
### Casting base types to subclasses

From search example we have seen that search method returns common base class - in this case Dsymbol.

Regular cast won't work because of design decisions that favors performance, and because it was ported from C++ codebase.

Instead each base class (`Dsymbol`, `Statement`, `Expression`) provides convenience methods that does such conversions.


```d
    // continues on search example ...

    // See myClass is indeed a class declaration type
    assert(myClass.isClassDeclaration);

    // It is actually does type casts, not just yes or no
    if (ClassDeclaration decl = myClass.isClassDeclaration)
    {
        writefln("class '%s', derived from '%s'", decl, decl.baseClass);
    }
    
    // Print it
    writeln(myClass);
```

<hr/>

<a id="searchinimports"></a>
### Searching up with imports

Previous method has IgnoreImports default flag, so even if your module does import `std.stdio` it will return null for `writeln`, to tell `search()` look for imported modules pass another flag, for example `IgnoreNone`

```d
    // Note that using qualified name std.stdio.writeln won't work
    auto writelnId = Identifier.idPool("writeln"); 

    // Search using IgnoreNone flag to look decls bottom up
    Dsymbol writelnSym = m.search(Loc.initial, writelnId, IgnoreNone);

    assert(writelnSym.isTemplateDeclaration);
```

<hr/>

<a id="iteratemembers"></a>
### Iterate module members

Sometimes we just want to loop over all members in a loop, for this we can use `members` property of `Module` class.

```d
    // Prints all members
    foreach (s; *m.members)
    {
        write(s.toString()); 
    }
```

<hr/>

<a id="createnewdecl"></a>
### Creating new declarations

There are times when we want to add generated declarations, perhaps you implementing a code generator for glueing up some parts and want to automate the process, we can do this by simply creating regular class instance and adding it to the module(or another scope decl) members.

Suppose we have a module **test.d** where we want to add new struct named MyStruct:
```d
    import dmd.arraytypes; // Dsymbols

    // Define a location used in diagnostic messages
    // NOTE: DMD internally uses "Loc.initial" for generated entries to exclude them from code coverate reports
    auto newLoc = Loc("test.d",0,0); 

    // Create struct declaration named 'MyStruct'
    auto myStructDecl = new StructDeclaration(newLoc, Identifier.idPool("MyStruct"), false);

    // Add empty members list, otherwise it will be printed as forward decl
    myStructDecl.members = new Dsymbols();

    // Add to the module
    m.members.push(myStructDecl);

    // Just to see it is there
    printPretty(m);

```

<hr/>

<a id="getcppnamespace"></a>
### Getting list of C++ namespaces

It's a bit complicated so let's start from code, imagine we would like to dump a list of extern(C++) classes along with their namespace.

```d
    // Example class in foo::bar namespace
    extern(C++, "foo", "bar")
    class Foo
    {
        // ...
    }
```

If we have ran semantic pass we can then obtain namespace from most `Dsymbol`'s by accessing its `Dsymbol.cppnamespace`, searching for Foo class will also work for that module.

```d
    import dmd.attrib; // CPPNamespaceDeclaration

    Dsymbol fooSym = m.search(Loc.initial, Identifier.idPool("Foo"));

    CPPNamespaceDeclaration nsDecl = fooSym.cppnamespace;
    if (nsDecl)
    {
        // prints namespace on recursion up
        void printNs (CPPNamespaceDeclaration ns) { 
            if (ns.cppnamespace)
                printNs(ns.cppnamespace);
            if (ns.cppnamespace)
                write("::");
            if (auto strExp = n.exp.isStringExp)
                write(cast(char[]) strExp.peekData());
        }
        printNs(nsDecl); // prints "foo::bar"
        writeln(); // newline
    }
```

Unfortunatelly this will not work without semantic pass so we have to deal with it in a different manner. `search` will not work in this case, so we have to look for `CPPNamespaceDeclaration` instead, and its `cppnamespace` will be null as well, so we have to look for its member decls instead.

```d
    import std.array;
    import dmd.attrib; // CPPNamespaceDeclaration

    // find all namespace decls in module m
    auto nsdecls = (*m.members)[]
        .filter!(s => s.isCPPNamespaceDeclaration)
        .array;

    // for example purposes we assume there is only one namespace decl
    if (CPPNamespaceDeclaration ns = (nsdecls[0]).isCPPNamespaceDeclaration)
    {
        static bool hasNestedNsDecl(CPPNamespaceDeclaration n)
        {
            return n.cppnamespace || (n.decl && (*n.decl)[0].isCPPNamespaceDeclaration);
        }
        
        // same as above but accounts for no semantic pass
        void printNs (CPPNamespaceDeclaration n) { 
            if (n.cppnamespace) 
                printNs(n.cppnamespace);
            else if (hasNestedNsDecl(n))
                printNs((*n.decl)[0].isCPPNamespaceDeclaration);
            if (hasNestedNsDecl(n))
                write("::");
            if (auto strExp = n.exp.isStringExp)
                write(cast(char[]) strExp.peekData());
        }
        printNs(ns);  // prints "foo::bar"
        writeln();
    }
```

<hr/>

<a id="symbolcomments"></a>
### Reading comments

Not at this moment, there is no way to control whether to read comments or not using standard `parseModule()` function.

If you are going to copy-paste `parseModule()` and turn on comment parsing you will be suprised as it only reads documentation comments starting with `///` or `/+`

Currently there is no way to achieve that without patching dmd, `parseModule()` simply creates `Module` instance and calls `parse()` on it, inside it spawns a `Parser` (that extends a `Lexer`), have to do some tinkering in `Lexer`, but as with any lexer it is hard to track what's going on and how to achieve parsing comments, it seems though that the design was created with this possibility in mind.