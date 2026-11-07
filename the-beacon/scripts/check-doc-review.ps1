<#
.SYNOPSIS
  Reprova função alterada cujo ## não foi alterado nem confirmado (decisão 0022).

.DESCRIPTION
  Compara o código com o HEAD (git diff, mudanças preparadas ou não). Uma função de arquivo
  já versionado conta como alterada quando muda alguma linha da assinatura ou do corpo; o
  ## conta como revisado quando muda alguma linha do bloco ## logo acima dela.
  Quando o ## continua correto, -Reviewed confirma a função: o hash do corpo atual vai para
  .doc-review (ignorado pelo git). Mexer de novo na função invalida a confirmação, e as
  entradas que não valem mais são descartadas a cada execução.
  Arquivos novos não são verificados aqui; o ## deles é exigido pelo check-docs.ps1.
  Exit 0 = ok; exit 1 = há função alterada sem ## revisado, ou -Reviewed inválido.

.PARAMETER Reviewed
  Funções cujo ## foi revisado e continua correto, no formato "<arquivo>::<função>",
  separadas por vírgula.

.EXAMPLE
  .\scripts\check-doc-review.ps1 -Reviewed "player/player.gd::sit,player/player.gd::kill"
#>
param([string[]]$Reviewed = @())

# Com powershell -File a lista chega como um texto só: separa pelas vírgulas.
$Reviewed = @($Reviewed | ForEach-Object { $_ -split ',' } |
    ForEach-Object { $_.Trim().Replace('\', '/') } | Where-Object { $_ -ne "" })
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $root
$reviewFile = Join-Path $root ".doc-review"
$funcPattern = '^(\s*)(?:static\s+)?func\s+(\w+)'
$docPattern = '^\s*##'
$hunkPattern = '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@'


function Get-Indent([string]$line) {
    return $line.Length - $line.TrimStart().Length
}


# Linhas do arquivo atual (1 = primeira) tocadas pelo diff. Uma remoção marca a linha que
# ficou logo antes dela, para contar como mudança da função onde aconteceu.
function Get-ChangedLines([string]$path) {
    $changed = New-Object 'System.Collections.Generic.HashSet[int]'
    foreach ($line in (git -c core.quotepath=off diff -U0 HEAD -- $path 2>$null)) {
        if (-not ($line -match $hunkPattern)) {
            continue
        }
        $start = [int]$Matches[1]
        $count = 1
        if ($Matches[2]) {
            $count = [int]$Matches[2]
        }
        if ($count -eq 0) {
            [void]$changed.Add([Math]::Max($start, 1))
            continue
        }
        for ($n = $start; $n -lt $start + $count; $n++) {
            [void]$changed.Add($n)
        }
    }
    return , $changed
}


function Get-BodyHash([string[]]$bodyLines) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($bodyLines -join "`n"))
    $sha = [System.Security.Cryptography.SHA256]::Create()
    return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "")
}


# Funções alteradas cujo ## não mudou, de um arquivo versionado.
function Get-PendingFunctions([string]$path) {
    $result = @()
    $changed = Get-ChangedLines $path
    if ($changed.Count -eq 0) {
        return $result
    }
    $lines = @(Get-Content -LiteralPath (Join-Path $root $path) -Encoding UTF8)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if (-not ($lines[$i] -match $funcPattern)) {
            continue
        }
        $name = $Matches[2]
        $indent = Get-Indent $lines[$i]
        # O corpo vai até a próxima linha não vazia com indentação igual ou menor.
        $bodyEnd = $i
        for ($j = $i + 1; $j -lt $lines.Count; $j++) {
            if ($lines[$j].Trim() -eq "") {
                continue
            }
            if ((Get-Indent $lines[$j]) -le $indent) {
                break
            }
            $bodyEnd = $j
        }
        $docStart = $i
        while ($docStart -gt 0 -and $lines[$docStart - 1] -match $docPattern) {
            $docStart--
        }
        $functionChanged = $false
        for ($n = $i + 1; $n -le $bodyEnd + 1; $n++) {
            if ($changed.Contains($n)) {
                $functionChanged = $true
                break
            }
        }
        $docChanged = $false
        for ($n = $docStart + 1; $n -le $i; $n++) {
            if ($changed.Contains($n)) {
                $docChanged = $true
                break
            }
        }
        if ($functionChanged -and -not $docChanged) {
            $docLines = @()
            if ($docStart -lt $i) {
                $docLines = $lines[$docStart..($i - 1)]
            }
            $result += [PSCustomObject]@{
                Key = "${path}::$name"
                Line = $i + 1
                Hash = Get-BodyHash $lines[$i..$bodyEnd]
                Doc = $docLines
            }
        }
    }
    return $result
}


$paths = @(git -c core.quotepath=off diff --name-only --relative HEAD -- '*.gd' 2>$null |
    Where-Object { $_ -notmatch '^(addons|\.godot|test)/' -and (Test-Path -LiteralPath $_) })
$pending = @()
foreach ($path in $paths) {
    $pending += @(Get-PendingFunctions $path)
}

$confirmed = @{}
if (Test-Path -LiteralPath $reviewFile) {
    foreach ($entry in (Get-Content -LiteralPath $reviewFile -Encoding UTF8)) {
        if ($entry.Trim() -ne "") {
            $confirmed[$entry.Trim()] = $true
        }
    }
}

$invalid = @()
foreach ($key in $Reviewed) {
    $matching = @($pending | Where-Object { $_.Key -eq $key })
    if ($matching.Count -eq 0) {
        $invalid += $key
        continue
    }
    foreach ($function in $matching) {
        $confirmed["$($function.Key) $($function.Hash)"] = $true
    }
}

# Só ficam as confirmações que ainda valem para o diff atual.
$stillValid = @()
$unreviewed = @()
$reviewedNow = @()
foreach ($function in $pending) {
    $entry = "$($function.Key) $($function.Hash)"
    if ($confirmed.ContainsKey($entry)) {
        $stillValid += $entry
        $reviewedNow += $function.Key
    } else {
        $unreviewed += $function
    }
}
if ($stillValid.Count -gt 0) {
    Set-Content -LiteralPath $reviewFile -Value ($stillValid | Sort-Object -Unique) -Encoding UTF8
} elseif (Test-Path -LiteralPath $reviewFile) {
    Remove-Item -LiteralPath $reviewFile -Confirm:$false
}

$failed = $false
if ($invalid.Count -gt 0) {
    Write-Output "Não são funções alteradas com o ## pendente: $($invalid -join ', ')"
    $failed = $true
}
if ($unreviewed.Count -gt 0) {
    Write-Output "Funções alteradas com o ## sem revisão ($($unreviewed.Count)):"
    foreach ($function in $unreviewed) {
        Write-Output "  $($function.Key) (linha $($function.Line))"
        foreach ($docLine in $function.Doc) {
            Write-Output "      $($docLine.Trim())"
        }
    }
    Write-Output "Atualize o ## ou, se ele continua correto, confirme com:"
    $keys = ($unreviewed | ForEach-Object { $_.Key } | Sort-Object -Unique) -join ","
    Write-Output "  scripts/check-doc-review.ps1 -Reviewed `"$keys`""
    $failed = $true
}
if ($failed) {
    exit 1
}
if ($reviewedNow.Count -gt 0) {
    Write-Output "## confirmados sem mudança: $(($reviewedNow | Sort-Object -Unique) -join ', ')"
}
Write-Output "Toda função alterada tem o ## revisado."
exit 0
