# Testing

Run `scripts/test.ps1` on Windows or `./scripts/test` on Linux/WSL. The smoke test rebuilds the compiler, checks that every example compiles and creates a sibling `.asm` file, and verifies that malformed examples fail.

The examples exercise literal output, precedence, variable declarations and assignment, comparisons, if/else, loops, and nested control flow. To validate the generated target code as well, assemble a generated `.asm` with NASM and link it with GCC on Linux x86-64 (see the README).

These tests have not been executed in the authoring environment because GnuCOBOL and NASM were unavailable there.
