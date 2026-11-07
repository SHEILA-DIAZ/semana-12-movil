param([switch]$SoloSintaxis)
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    $swiftPath = (Get-Command swift -ErrorAction Stop).Source
    $swiftCompiler = Join-Path (Split-Path -Parent $swiftPath) 'swiftc.exe'
    $sources = @(Get-ChildItem Sources,Tests,UITests -Recurse -Filter *.swift | ForEach-Object { $_.FullName })
    & $swiftPath -frontend -parse @sources
    if ($LASTEXITCODE -ne 0) { throw 'Fallo el analisis sintactico Swift.' }
    Write-Output "OK: sintaxis de $($sources.Count) archivos Swift (sin resolver SDK ni macros)."
    & $swiftPath -frontend -parse scripts/ReglasCompraWindows.swift
    if ($LASTEXITCODE -ne 0) { throw 'Error de sintaxis en el verificador de reglas.' }
    git diff --check
    if ($LASTEXITCODE -ne 0) { throw 'git diff --check detecto errores.' }
    if ($SoloSintaxis) { return }
    New-Item -ItemType Directory -Force -Path .build/windows | Out-Null
    & $swiftCompiler Sources/Services/ReglasCompra.swift scripts/ReglasCompraWindows.swift -o .build/windows/ReglasCompra.exe
    if ($LASTEXITCODE -ne 0) { throw 'No se pudieron compilar las reglas Foundation. Verifica MSVC y Windows SDK en un Developer PowerShell; -SoloSintaxis no requiere estos componentes.' }
    & ./.build/windows/ReglasCompra.exe
    if ($LASTEXITCODE -ne 0) { throw 'Fallo la ejecucion de reglas Foundation.' }
    git diff --check
    if ($LASTEXITCODE -ne 0) { throw 'git diff --check detecto errores.' }
} finally {
    Pop-Location
}
