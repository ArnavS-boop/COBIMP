# Build fixes in this revision

This revision fixes the compile errors reported by GnuCOBOL in the previous archive:

- Declares `IR-MODE` in `main.cob` before passing it to `IR`.
- Rewrites compound `EVALUATE` cases in the lexer, parser, TAC generator, and code generator as `EVALUATE TRUE` with explicit boolean conditions. GnuCOBOL does not accept `WHEN value-a OR value-b` as a list of alternatives for a single `EVALUATE` subject.
- Keeps the build command and module list in `scripts/build.ps1` unchanged.

Build from the extracted `COBIMP` directory:

```powershell
.\scripts\build.ps1
.\cobimp.exe examples\complex.cbimp
.\scripts\test.ps1
```

The source was statically reviewed after these edits, but this environment does not have GnuCOBOL installed, so a successful local compile has not been independently confirmed here.
