# Compara a versão do Godot em GODOT_PATH com a versão registrada em project.godot.
# Exit 0 = ok; exit 1 = problema (variável ausente, caminho inválido ou versão diferente).

if (-not $env:GODOT_PATH) {
    Write-Output "ERRO: GODOT_PATH não definido."
    exit 1
}
if (-not (Test-Path $env:GODOT_PATH -PathType Leaf)) {
    Write-Output "ERRO: GODOT_PATH ('$env:GODOT_PATH') não é um arquivo. Ele deve apontar para o .exe do Godot, não para a pasta."
    exit 1
}

$projectFile = Join-Path $PSScriptRoot "..\project.godot"
$match = Select-String -Path $projectFile -Pattern 'config/features=PackedStringArray\("(\d+\.\d+)"'
if (-not $match) {
    Write-Output "AVISO: versão do Godot não encontrada em project.godot."
    exit 0
}
$expected = $match.Matches[0].Groups[1].Value

$actual = (& $env:GODOT_PATH --version 2>&1 | Out-String).Trim()   # ex.: 4.7.2.stable.steam.abc123
if ([string]::IsNullOrWhiteSpace($actual)) {
    Write-Output "ERRO: '$env:GODOT_PATH --version' não retornou nada."
    exit 1
}

if ($actual.StartsWith("$expected.")) {
    Write-Output "OK: Godot $actual (projeto: $expected)"
    exit 0
}

Write-Output "ERRO: Godot instalado é $actual, mas o projeto usa $expected. Não abra nem edite o projeto antes de corrigir."
exit 1
