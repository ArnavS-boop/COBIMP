# Architecture

The compiler is intentionally table-based. The main program loads the file and owns one `COMPILER-STATE` group. Each phase receives that group by reference, so the modules share a single token table, AST table, symbol table, and IR table without hidden global state.

The parser creates AST nodes in a fixed table. Child links describe expressions and control-flow bodies; `NEXT` links statements in a block. `FIRST` records the earliest node in an expression subtree, allowing TAC generation to process expression nodes in postorder without recursive calls.

The semantic pass walks the AST node table in creation order. It uses the `SYMBOL` subprogram to look up declared names. The language uses program-wide variable names in this version; block-local scopes are not implemented.

TAC generation walks statement sibling links and uses an explicit stack for nested `if`/`while` bodies. Expression operations are emitted before their consuming statement. The optimizer modifies the TAC table in place. Code generation consumes only the optimized IR and emits NASM x86-64 text.
