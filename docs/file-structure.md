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