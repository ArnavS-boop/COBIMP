# COBIMP — COBOL Source-to-Assembly Compiler

COBIMP is a small educational compiler written in COBOL using GnuCOBOL. It keeps the existing source loader and lexer design and adds the missing compiler phases using fixed-size tables and straightforward paragraphs/subprograms.

## Compiler pipeline

```text
.cbimp source
   |
   v
main.cob       Read source file and coordinate compilation
   |
   v
lexer.cob      Lexical analysis: characters -> tokens
   |
   v
parser.cob     Syntax analysis: tokens -> AST
   |
   +---------- ast.cob: display the AST node table
   |
   v
semantic.cob   Declaration and variable-use checks
   |              |
   |              +-- symbol.cob: shared symbol lookup
   v
tac.cob        AST -> three-address intermediate code
   |
   +---------- ir.cob: display the current IR
   |
   v
optimizer.cob  Constant folding and temporary propagation
   |
   v
codegen.cob    Optimized IR -> NASM x86-64 assembly
```

`error.cob` reports compiler diagnostics. `include/compiler-defs.cpy` holds token IDs, and `include/compiler-state.cpy` defines the shared tables passed between compiler stages.

## Build

Requirements: GnuCOBOL (`cobc`). The compiler source itself does not require NASM; NASM is only needed if you want to assemble the generated `.asm` file.

### Windows PowerShell

From the repository root:

```powershell
.\scripts\build.ps1
.\cobimp.exe examples\complex.cbimp
```

The compiler writes `examples\complex.asm` next to the source file.

To smoke-test the supplied valid and invalid programs:

```powershell
.\scripts\test.ps1
```

### Linux / WSL

```sh
./scripts/build
./cobimp examples/complex.cbimp
./scripts/test
```

The build script compiles the existing lexer and the new phase modules into one executable. Always rebuild after changing source files; the executable included in the original repository was an older build and has intentionally not been carried into this source archive.

## Assemble and run generated code (Linux x86-64)

Install NASM and a C toolchain, then:

```sh
nasm -f elf64 examples/complex.asm -o /tmp/complex.o
gcc -no-pie /tmp/complex.o -o /tmp/complex
/tmp/complex
```

The generated assembly uses the System V x86-64 calling convention and calls C's `printf` to implement `print`. Use Linux or WSL for this exact assembly target; the output is not Windows x64 MASM syntax.

## COBIMP language supported by this version

COBIMP currently uses signed integer arithmetic and the following statements:

```text
let name = expression;
name = expression;
print expression;

if (expression) {
    statements
} else {
    statements
}

while (expression) {
    statements
}
```

`else` is optional. Blocks can contain nested `if` and `while` statements.

Expressions support integer literals, variable names, parentheses, and these operators:

| Precedence | Operators |
|---|---|
| Highest | `*`, `/` |
| | `+`, `-` |
| | `<`, `>`, `<=`, `>=` |
| Lowest | `==`, `!=` |

Operators at the same precedence are evaluated left-to-right. Conditions are integer expressions; zero is false and nonzero is true. Comparisons produce `0` or `1`. Division is signed integer division.

For clarity and explainability, this version deliberately does not implement functions, strings, arrays, floating-point values, logical `&&`/`||`, unary operators, or user-defined types. Declarations use `let name = expression;`; a declaration must have an initializer. Variables are currently treated as program-wide names rather than block-scoped locals.

## Implemented phases

1. **Lexical analysis** — recognizes identifiers, decimal integer literals, keywords, arithmetic and comparison operators, braces, parentheses and semicolons.
2. **Syntax analysis** — checks statement structure and expression grammar, including operator precedence and balanced blocks.
3. **Semantic analysis** — rejects duplicate declarations, assignment to undeclared variables, and references to undeclared variables.
4. **Intermediate code generation** — emits three-address instructions such as `ADD`, `MOV`, `IFZ`, `JMP`, and `LABEL`.
5. **Code optimization** — folds constant arithmetic/comparisons and propagates known temporary constants.
6. **Code generation** — translates optimized IR into NASM Intel-syntax x86-64 assembly.

## Practical limits

The project uses fixed-size tables to keep the implementation approachable: source up to 10,000 characters, 10,001 token slots, 5,000 AST nodes, 5,000 IR instructions, up to 1,000 distinct variable names, and block nesting up to 99 levels. Exceeding a table limit is an error, not an invitation to write beyond the table.

The generated `.asm` output is an assembly file, not an executable. Successful COBOL compilation confirms the compiler itself builds; successful NASM assembly/linking is a separate validation step. The current execution environment did not have GnuCOBOL or NASM available, so run the supplied build and smoke-test scripts on your machine before relying on the result.
