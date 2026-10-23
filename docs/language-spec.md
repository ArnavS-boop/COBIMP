# COBIMP language specification (implemented subset)

## Lexical forms

- Keywords: `let`, `print`, `if`, `else`, `while`
- Identifiers: ASCII letters or underscore first, followed by letters, digits, or underscores; maximum 64 characters
- Integer literals: decimal digits; 1–18 digits accepted by semantic analysis (the lexer token buffer allows up to 64 characters)
- Operators: `+ - * / = == != < > <= >=`
- Delimiters: `( ) { } ;`
- Whitespace: spaces, tabs, and newlines

Comments, strings, floats, unary operators, and logical conjunction/disjunction are not currently supported.

## Grammar

```text
program       -> statement* EOF
statement     -> declaration | assignment | print
               | if-statement | while-statement
declaration   -> "let" IDENTIFIER "=" expression ";"
assignment    -> IDENTIFIER "=" expression ";"
print         -> "print" expression ";"
if-statement  -> "if" "(" expression ")" block ("else" block)?
while-stmt    -> "while" "(" expression ")" block
block         -> "{" statement* "}"
expression    -> equality
equality      -> comparison (("==" | "!=") comparison)*
comparison    -> term (("<" | ">" | "<=" | ">=") term)*
term          -> factor (("+" | "-") factor)*
factor        -> primary (("*" | "/") primary)*
primary       -> INTEGER | IDENTIFIER | "(" expression ")"
```

All variables are integer-valued and program-wide. A declaration must be initialized. `0` is false and any nonzero condition is true. Comparison results are `0` or `1`.
