$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
if (-not (Get-Command cobc -ErrorAction SilentlyContinue)) {
    throw "GnuCOBOL (cobc) was not found on PATH. Install GnuCOBOL, then rerun scripts\build.ps1."
}
$files = @(
    "src\main.cob",
    "src\lexer.cob",
    "src\token.cob",
    "src\parser.cob",
    "src\ast.cob",
    "src\semantic.cob",
    "src\symbol.cob",
    "src\tac.cob",
    "src\ir.cob",
    "src\optimizer.cob",
    "src\codegen.cob",
    "src\error.cob"
)
& cobc -free -x -I include -o cobimp.exe @files
if ($LASTEXITCODE -ne 0) { throw "COBIMP build failed with exit code $LASTEXITCODE." }
Write-Host "Built cobimp.exe successfully."
