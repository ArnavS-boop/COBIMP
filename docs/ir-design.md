# Three-address intermediate representation

Each IR entry has an operation, two optional operands, and one optional result.

| Operation | Meaning |
|---|---|
| `MOV a -> x` | Store `a` in variable or temporary `x` |
| `ADD a b -> t` | `t = a + b` |
| `SUB a b -> t` | `t = a - b` |
| `MUL a b -> t` | `t = a * b` |
| `DIV a b -> t` | signed integer `t = a / b` |
| `EQ`, `NE`, `LT`, `GT`, `LE`, `GE` | comparison producing 0 or 1 |
| `PRINT a` | print an integer |
| `IFZ a -> L` | jump to `L` if `a` is zero |
| `JMP -> L` | unconditional jump |
| `LABEL -> L` | define a branch target |

Temporaries are named `@T0001`, `@T0002`, etc. (the `@` prefix distinguishes internal temporaries from source identifiers) Labels are named `L0001`, `L0002`, etc. The optimizer edits this table in place; the code generator reads the same table afterward.
