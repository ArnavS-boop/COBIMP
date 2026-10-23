param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Source
)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path ".\cobimp.exe")) { & ".\scripts\build.ps1" }
& ".\cobimp.exe" $Source
exit $LASTEXITCODE
