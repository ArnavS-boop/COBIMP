$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
& ".\scripts\build.ps1"
$valid = Get-ChildItem ".\examples\*.cbimp"
foreach ($file in $valid) {
    Write-Host "`n[VALID] $($file.Name)"
    & ".\cobimp.exe" $file.FullName
    if ($LASTEXITCODE -ne 0) {
        throw "Expected compilation to succeed for $($file.Name)."
    }
    $asm = [System.IO.Path]::ChangeExtension($file.FullName, ".asm")
    if (-not (Test-Path $asm)) { throw "Expected assembly output was not created: $asm" }
}
$invalid = Get-ChildItem ".\tests\invalid\*.cbimp"
foreach ($file in $invalid) {
    Write-Host "`n[INVALID] $($file.Name)"
    & ".\cobimp.exe" $file.FullName
    if ($LASTEXITCODE -eq 0) {
        throw "Expected compilation to fail for $($file.Name)."
    }
}
Write-Host "`nAll compiler smoke tests passed."
