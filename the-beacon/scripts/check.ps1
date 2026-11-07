<#
.SYNOPSIS
  Pipeline de verificação: versão do Godot, formatação, lint, documentação, parse e testes.
  Para na primeira etapa que falhar e retorna exit code 1.

.PARAMETER Fast
  Roda só os testes unitários (test/unit), pulando os testes de cena.

.PARAMETER Fix
  Aplica gdformat nos scripts do projeto antes de verificar.

.EXAMPLE
  .\scripts\check.ps1              # completo: antes de concluir uma tarefa
  .\scripts\check.ps1 -Fix -Fast   # formata e roda o check rápido
#>
param([switch]$Fast, [switch]$Fix)

$ErrorActionPreference = "Continue"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root

function Invoke-Step([string]$Name, [scriptblock]$Action) {
    Write-Host "`n== $Name ==" -ForegroundColor Cyan
    $global:LASTEXITCODE = 0
    & $Action
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FALHOU: $Name" -ForegroundColor Red
        exit 1
    }
    Write-Host "OK: $Name" -ForegroundColor Green
}

# Scripts do projeto, sem addons de terceiros e sem o cache do Godot
$gdFiles = @(Get-ChildItem -Path $root -Recurse -Filter *.gd |
    Where-Object { $_.FullName -notmatch '\\(addons|\.godot)\\' } |
    ForEach-Object { $_.FullName })

# 1. Versão do Godot (também valida o GODOT_PATH)
Invoke-Step "Versão do Godot" {
    & (Join-Path $PSScriptRoot "check-godot-version.ps1")
}

# 2. Formatação e 3. lint (gdtoolkit)
if ($gdFiles.Count -gt 0) {
    if ($Fix) {
        Invoke-Step "Aplicar formatação (gdformat)" { gdformat $gdFiles }
    }
    Invoke-Step "Formatação (gdformat --check)" { gdformat --check $gdFiles }
    Invoke-Step "Lint (gdlint)" { gdlint $gdFiles }
} else {
    Write-Host "`n(sem scripts .gd do projeto: formatação e lint pulados)" -ForegroundColor DarkGray
}

# 4. Toda função do jogo com ## logo acima (decisão 0021).
Invoke-Step "Documentação das funções" {
    & (Join-Path $PSScriptRoot "check-docs.ps1")
}

# 5. Parse de todos os scripts (decisão 0013, substitui a 0007).
#    O --import só atualiza cache e .uid: ele não compila scripts que nenhuma cena usa.
#    Por isso scripts/parse_check.gd compila cada script numa única execução headless.
#    Não é --check-only: nesse modo o Godot não registra os autoloads e todo script que
#    usa um deles falharia com "Identifier not found".
#    A busca no texto cobre versões do Godot que não sinalizam o erro no exit code.
#    Não amplie o regex para "ERROR" genérico: há ruído conhecido (Remote Debugger).
Invoke-Step "Parse dos scripts (Godot headless)" {
    $importOutput = & $env:GODOT_PATH --headless --path $root --import 2>&1 | Out-String
    if ([string]::IsNullOrWhiteSpace($importOutput)) {
        Write-Host "Saída vazia: o Godot não devolveu nada ao terminal." -ForegroundColor Yellow
        $global:LASTEXITCODE = 1
        return
    }
    # scripts/ tem .gdignore: o que está lá não é res:// e não entra no parse.
    $scriptsDir = Join-Path $root "scripts\"
    $resPaths = @($gdFiles | Where-Object { -not $_.StartsWith($scriptsDir) } |
        ForEach-Object { "res://" + $_.Substring($root.Length + 1).Replace('\', '/') })
    $parser = Join-Path $PSScriptRoot "parse_check.gd"
    $output = & $env:GODOT_PATH --headless --path $root --script $parser -- @resPaths 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|Failed to load script') {
        Write-Host $output
        $global:LASTEXITCODE = 1
        return
    }
    $summary = $output -split "`r?`n" | Where-Object { $_ -match '^Scripts compilados' }
    Write-Host $summary
    $global:LASTEXITCODE = 0
}

# 6. Testes (gdUnit4). O runtest.cmd lê o executável do Godot em GODOT_BIN.
$testDir = if ($Fast) { "test/unit" } else { "test" }
if (Test-Path (Join-Path $root $testDir)) {
    Invoke-Step "Testes gdUnit4 ($testDir)" {
        $env:GODOT_BIN = $env:GODOT_PATH
        & (Join-Path $root "addons\gdUnit4\runtest.cmd") -a "res://$testDir"
    }
} else {
    Write-Host "`nFALHOU: pasta $testDir não existe" -ForegroundColor Red
    exit 1
}

Write-Host "`nCHECK OK" -ForegroundColor Green
exit 0
