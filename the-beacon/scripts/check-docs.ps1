# Reprova função sem comentário de documentação (##) logo acima dela (decisão 0021).
# Vale para os scripts do jogo, fora de test/, addons/ e do cache do Godot.
# Exit 0 = ok; exit 1 = há função sem ##.

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$funcPattern = '^\s*(static\s+)?func\s+\w+'
$docPattern = '^\s*##'
$missing = @()

foreach ($file in Get-ChildItem -Path $root -Recurse -Filter *.gd) {
    $relative = $file.FullName.Substring($root.Length + 1)
    if ($relative -match '^(addons|\.godot|test)\\') {
        continue
    }
    $lines = @(Get-Content -LiteralPath $file.FullName -Encoding UTF8)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -notmatch $funcPattern) {
            continue
        }
        if ($i -eq 0 -or $lines[$i - 1] -notmatch $docPattern) {
            $missing += "${relative}:$($i + 1): $($lines[$i].Trim())"
        }
    }
}

if ($missing.Count -gt 0) {
    Write-Output "Funções sem ## logo acima ($($missing.Count)):"
    $missing | ForEach-Object { Write-Output "  $_" }
    exit 1
}
Write-Output "Toda função do jogo tem ##."
exit 0
