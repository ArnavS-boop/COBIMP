# Archived project notes

This is a preserved copy of the original planning notes from the uploaded repository. The implemented language and target decisions are documented in `README.md` and `language-spec.md`.

---

AI NOTES AID:


                FIRST NOTE:

Yes. Let's freeze the scope before we touch code. If we're doing the **COBOL implementation**, I want the project to be small enough to finish, but complete enough that nobody can say "you skipped the compiler stages."

I'm going to assume our target is **a small custom imperative language → three-address code → optimized TAC → assembly**, with the compiler itself written in COBOL.

## 1. The complete system

```text
                    OUR SOURCE LANGUAGE
                           │
                           ▼
                 ┌───────────────────┐
                 │  COBOL COMPILER   │
                 └─────────┬─────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
           TOKENS         AST       ERRORS
              │            │
              └──────┬─────┘
                     ▼
             SEMANTIC ANALYSIS
                     │
                     ▼
             THREE-ADDRESS CODE
                     │
                     ▼
                 OPTIMIZER
                     │
                     ▼
              ASSEMBLY GENERATOR
                     │
                     ▼
                 assembly
```

The compiler itself is the main artifact.

---

# 2. Tools we'll need

### Required

**1. GnuCOBOL**

This is the COBOL compiler we'll use to compile **our compiler**.

```text
our_compiler.cob
       ↓
    GnuCOBOL
       ↓
our_compiler.exe
```

We'll use a modern GnuCOBOL release appropriate for your OS.

---

**2. Git**

For version control.

We'll have commits corresponding roughly to:

```text
lexer working
parser working
semantic analysis working
TAC working
optimizer working
assembly generation working
```

This is especially useful because we're doing something unusual and don't want one catastrophic refactor to eat the entire project.

---

**3. VS Code**

Editor.

We'll use a COBOL extension for:

* syntax highlighting
* indentation
* navigation
* diagnostics where supported

---

**4. GitHub**

Repository for the project.

Not strictly necessary for compilation, but I strongly recommend it.

---

**5. An assembler/emulator for the target**

This needs to be decided **before we implement code generation**.

I don't want us generating some random assembly syntax that we can't actually execute.

For an educational compiler, I'd prefer a deliberately simple target architecture/emulator if your professor allows it.

If she specifically requires x86/x86-64 assembly, we'll target that instead.

This is one of the few things I would **not guess**.

---

# 3. Files we'll make

I'd structure the repository like this:

```text
cobol-compiler/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── src/
│   │
│   ├── main.cob
│   │
│   ├── lexer.cob
│   ├── parser.cob
│   ├── semantic.cob
│   ├── tac.cob
│   ├── optimizer.cob
│   ├── codegen.cob
│   │
│   ├── token.cob
│   ├── ast.cob
│   ├── symbol.cob
│   ├── ir.cob
│   └── error.cob
│
├── include/
│   └── compiler-defs.cpy
│
├── examples/
│   ├── hello.src
│   ├── arithmetic.src
│   ├── variables.src
│   ├── conditionals.src
│   ├── loops.src
│   └── complex.src
│
├── tests/
│   │
│   ├── lexer/
│   ├── parser/
│   ├── semantic/
│   ├── tac/
│   ├── optimizer/
│   └── codegen/
│
├── output/
│   ├── tokens/
│   ├── tac/
│   ├── optimized/
│   └── assembly/
│
├── docs/
│   ├── architecture.md
│   ├── language-spec.md
│   ├── compiler-phases.md
│   ├── ir-design.md
│   └── testing.md
│
└── scripts/
    ├── build
    ├── run
    └── test
```

That's the **logical structure**. We can consolidate some COBOL modules if GnuCOBOL's compilation model makes that cleaner.

---

# 4. What each source file does

## `main.cob`

The conductor.

It will:

```text
read source file
      ↓
lexer
      ↓
parser
      ↓
semantic analysis
      ↓
TAC generation
      ↓
optimization
      ↓
assembly generation
```

It should contain almost no actual compiler logic.

---

## `lexer.cob`

Characters → tokens.

Input:

```text
x = 10 + 20;
```

Output:

```text
IDENTIFIER(x)
ASSIGN
INTEGER(10)
PLUS
INTEGER(20)
SEMICOLON
```

It will recognize things like:

```text
identifiers
numbers
keywords
operators
parentheses
braces
semicolons
```

---

## `token.cob`

Defines what a token looks like.

Conceptually:

```text
TOKEN
├── type
├── value
├── line
└── column
```

For example:

```text
IDENTIFIER
x
line 1
column 1
```

---

# 5. `parser.cob`

Tokens → AST.

Input:

```text
x = 10 + 20;
```

AST:

```text
       ASSIGN
       /    \
      x      +
            / \
          10   20
```

We'll probably use **recursive descent parsing** because it is straightforward and perfect for a small language.

---

# 6. `ast.cob`

Defines our AST node representation.

Because we're using COBOL, we'll probably use a table-based representation:

```text
NODE  TYPE       LEFT   RIGHT   VALUE
---------------------------------------
1     ASSIGN     2      3
2     IDENTIFIER              x
3     ADD        4      5
4     INTEGER                 10
5     INTEGER                 20
```

This is one of the areas where we'll deliberately adapt the data structures to COBOL.

---

# 7. `semantic.cob`

AST → validated AST / semantic information.

It catches things like:

```text
x = 10;
y = x + 5;
```

Good.

But:

```text
y = mystery + 5;
```

Bad.

It can report:

```text
ERROR:
Undeclared variable 'mystery'
Line 1
```

It will also handle basic type checking.

---

# 8. `symbol.cob`

Symbol table.

Something like:

```text
NAME       TYPE       ID
-------------------------
x          INTEGER    1
y          INTEGER    2
counter    INTEGER    3
```

The semantic analyzer uses this.

---

# 9. `tac.cob`

AST → **Three-Address Code**.

Example:

```text
x = 10 + 20;
```

becomes:

```text
t1 = 10 + 20
x = t1
```

We represent each TAC instruction as:

```text
OP
ARG1
ARG2
RESULT
```

So:

```text
ADD | 10 | 20 | t1
MOV | t1 |    | x
```

This is one of the key required artifacts.

---

# 10. `ir.cob`

Defines our intermediate representation.

TAC is one form of IR.

This module defines things like:

```text
instruction
temporary
label
jump
comparison
assignment
```

For example:

```text
t1 = x + y
IF t1 > 10 GOTO L1
GOTO L2
L1:
PRINT t1
L2:
```

---

# 11. `optimizer.cob`

TAC → optimized TAC.

We'll deliberately keep the optimizer manageable.

First version:

### Constant folding

```text
t1 = 10 + 20
```

becomes:

```text
t1 = 30
```

### Constant propagation

```text
x = 10
y = x + 5
```

becomes:

```text
x = 10
y = 15
```

### Dead-code elimination

Remove computations whose results are never used.

### Simple algebraic simplification

```text
x + 0 → x
x * 1 → x
```

That's enough to demonstrate a genuine optimization stage.

---

# 12. `codegen.cob`

Optimized TAC → assembly.

For example:

```text
t1 = x + y
```

could become:

```asm
LOAD R1, x
ADD R1, y
STORE t1, R1
```

The exact assembly depends on the target architecture we select.

---

# 13. `error.cob`

Centralized error reporting.

We'll distinguish at least:

```text
LEXICAL ERROR
SYNTAX ERROR
SEMANTIC ERROR
CODE GENERATION ERROR
```

For example:

```text
[SYNTAX ERROR]
Line 4, Column 9:
Expected ')' after expression.
```

---

# 14. `compiler-defs.cpy`

This is a COBOL copybook.

Think of it as a shared definitions file.

We'll put things like:

```text
token types
maximum table sizes
AST node types
TAC operation types
type identifiers
```

in here so we're not duplicating constants everywhere.

---

# 15. Our source language

This is **very important**.

We're not making a giant language.

Version 1 should support:

```text
integer variables
assignment
arithmetic
print
if/else
while
comparisons
```

Example:

```text
let x = 10;
let y = 20;

let z = x + y;

if (z > 20) {
    print z;
}
```

That's enough to demonstrate every compiler stage.

Later we can add things if we're ahead of schedule.

---

# 16. The test files

We'll have tests specifically for each phase.

### Lexer

```text
tests/lexer/basic.src
tests/lexer/operators.src
tests/lexer/keywords.src
tests/lexer/errors.src
```

### Parser

```text
tests/parser/arithmetic.src
tests/parser/if.src
tests/parser/while.src
tests/parser/errors.src
```

### Semantic

```text
tests/semantic/undeclared.src
tests/semantic/type-error.src
tests/semantic/valid.src
```

### TAC

```text
tests/tac/arithmetic.src
tests/tac/control-flow.src
```

### Optimizer

```text
tests/optimizer/constants.src
tests/optimizer/dead-code.src
```

### Code generation

```text
tests/codegen/arithmetic.src
tests/codegen/control-flow.src
```

---

# 17. Documentation we'll produce

This matters for your actual submission.

### `language-spec.md`

Defines exactly what our language accepts.

### `architecture.md`

Explains:

```text
Lexer
Parser
Semantic analyzer
TAC
Optimizer
Code generator
```

### `compiler-phases.md`

For each phase:

```text
Input
Processing
Output
Data structures
```

### `ir-design.md`

Explains our TAC representation.

### `testing.md`

Shows test cases and expected results.

---

# 18. What we absolutely do NOT build

This is where I want to be ruthless.

No:

```text
classes
generics
floating-point types
strings initially
arrays initially
functions initially
pointers
modules
garbage collection
exceptions
concurrency
LLVM
full COBOL support
AI
```

Not because we can't eventually add them.

Because **we have one month**.

The winning move is a tiny language with a complete pipeline.

---

# 19. The one thing we need to settle before writing the compiler

**The assembly target.**

Everything up through TAC is architecture-independent.

But code generation needs to know:

```text
Which CPU?
Which assembly syntax?
Which assembler?
How do we run the resulting program?
```

We should choose the target **before implementing `codegen.cob`**.

If your professor has specified something like:

> x86 assembly

then we use that.

If she only says:

> "generate assembly"

I'd strongly prefer an educational target where we can actually execute and demonstrate the generated code.

---

# 20. The final artifact

When we're done, you should be able to run something conceptually like:

```text
cobol-compiler program.src
```

and get:

```text
program.tac
program.optimized.tac
program.asm
```

with a report showing:

```text
SOURCE
  ↓
TOKENS
  ↓
AST
  ↓
SEMANTIC CHECK
  ↓
THREE-ADDRESS CODE
  ↓
OPTIMIZED THREE-ADDRESS CODE
  ↓
ASSEMBLY
```

That is the project.

**And yes, this is a reasonable one-month build if we freeze the language at this size and work incrementally.**

The next thing I'd do is **design the actual source language grammar and the exact data structures for Token, AST, Symbol, and TAC before writing any COBOL**. That is the part where we can prevent the COBOL implementation from becoming a swamp.





            SECOND NOTE:

