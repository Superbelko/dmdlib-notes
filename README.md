# DMD (as a library) notes

DMD D Compiler internals tips and notes I made for myself, primarily about AST and code manipulation using D compiler frontend.

Compared to clang DMD lacks debugging utilities and has poor output which complicates its use, so I took my time and did some exporation.  
This notes should help anyone who looks into using D compiler front-end to build tools on top of it or just getting familiar with its AST.

__example__ folder contains source code examples.

__tutorial__ folder contains documentation, tips, notes, and diagrams.

For getting started see [tutorial](tutorial/01_prepare.md), then proceed on [recipes](tutorial/recipes.md)

Some examples has related diagrams in tutorial folder in SVG format.