$ErrorActionPreference = 'Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    $swiftPath = (Get-Command swift -ErrorAction Stop).Source
    $sources = @(Get-ChildItem Sources,Tests,UITests -Recurse -Filter *.swift | ForEach-Object { $_.FullName })
    & $swiftPath -frontend -parse @sources
    if ($LASTEXITCODE -ne 0) { throw 'Fallo el analisis sintactico Swift.' }
    Write-Output "OK: sintaxis de $($sources.Count) archivos Swift (sin resolver SDK ni macros)."
    git diff --check
    if ($LASTEXITCODE -ne 0) { throw 'git diff --check detecto errores.' }
} finally {
    Pop-Location
}
