# Compiler phases

1. **Lexer:** characters to token records with kind, spelling, line, and column.
2. **Parser:** token stream to AST records. The expression parser uses operator and operand stacks (shunting-yard style) to enforce precedence without recursive COBOL calls.
3. **Semantic analysis:** declaration uniqueness and identifier-use checks.
4. **TAC generation:** expression operations become temporary assignments; statements become moves, prints, conditional branches, labels, and jumps.
5. **Optimization:** numeric temporary operands are propagated and constant arithmetic/comparison operations are replaced with constant moves.
6. **Code generation:** each IR instruction maps to a small set of NASM instructions. Variables and temporaries are stored in `.bss`; `print` calls `printf`.
