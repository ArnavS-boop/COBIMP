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
