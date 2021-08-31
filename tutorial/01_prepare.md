# DMD as a library

## Introduction

This simple tutorial has introductory purpose, it doesn't teach you each and every dark corner of D compiler but rather shows quick tips on how to achieve something in a series of snippets.

Let's begin by creating the project, assuming you have already installed D compiler and dub tool (usually shipped with compiled) run the following command in terminal to create and initialize the project.
  
\
*you can leave everything at default settings, so just hit enter until it is done*
```
dub init (project_name)
```

Now go to the project directory and add dmd as dependency
```
cd (project_name)
dub add dmd
```

\
Without further ado let's start with following D file, it's purpose is to ensure that you have working compiler as a library.

__app.d__:
```d


// lexer
unittest
{
    import dmd.lexer;
    import dmd.tokens;
	import dmd.globals;
	import dmd.errors;

    immutable expected = [
        TOK.void_,
        TOK.identifier,
        TOK.leftParentheses,
        TOK.rightParentheses,
        TOK.leftCurly,
        TOK.rightCurly
    ];
    immutable sourceCode = "void test() {} // foobar";
	scope diagnosticReporter = new StderrDiagnosticReporter(global.params.useDeprecated);
    scope lexer = new Lexer("test", sourceCode.ptr, 0, sourceCode.length, 0, 0, diagnosticReporter);
    lexer.nextToken();

    TOK[] result;

    do
    {
        result ~= lexer.token.value;
    } while (lexer.nextToken() != TOK.endOfFile);

    assert(result == expected);
}

// parser
unittest
{
    import dmd.astbase;
    import dmd.parse;
	import dmd.globals;
	import dmd.errors;

	scope diagnosticReporter = new StderrDiagnosticReporter(global.params.useDeprecated);
    scope parser = new Parser!ASTBase(null, null, false, diagnosticReporter);
    assert(parser !is null);
}

```

Now using the termial run unit tests with dub to ensure it works

```
dub test
```