<<<<<<< HEAD
# File structure

- `src/main.cob` — source loader and stage orchestration
- `src/lexer.cob` — character-to-token lexer (existing implementation, with capacity and keyword fixes)
- `src/token.cob` — token table display
- `src/parser.cob` — syntax analysis and AST construction
- `src/ast.cob` — AST table inspection
- `src/semantic.cob` — declaration and use validation
- `src/symbol.cob` — symbol lookup
- `src/tac.cob` — AST-to-three-address-code conversion
- `src/ir.cob` — IR inspection
- `src/optimizer.cob` — constant folding and temporary propagation
- `src/codegen.cob` — optimized IR to NASM x86-64 assembly
- `src/error.cob` — diagnostic reporting
- `include/compiler-defs.cpy` — token IDs
- `include/compiler-state.cpy` — shared token, AST, symbol, and IR tables
- `examples/` — valid COBIMP programs
- `tests/invalid/` — programs expected to fail
- `scripts/` — build, run, and smoke-test helpers
=======
cobimp/
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
>>>>>>> 53d6ddea4ca89eaa948a51b347e238418b2661c8
