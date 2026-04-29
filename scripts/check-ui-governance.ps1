$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$targets = @(
  @{
    Name = 'pages'
    Path = Join-Path $repoRoot 'entry\src\main\ets\pages'
    Warn = 430
    Fail = 470
  },
  @{
    Name = 'components-common'
    Path = Join-Path $repoRoot 'entry\src\main\ets\components\common'
    Warn = 220
    Fail = 260
  }
)

$pattern = 'Color\.White|#[0-9A-Fa-f]{6}|#[0-9A-Fa-f]{8}'
$failed = $false

function Test-ContainsEmoji {
  param([string]$Text)

  for ($i = 0; $i -lt $Text.Length; $i++) {
    $code = [int][char]$Text[$i]
    if ($code -ge 0x2600 -and $code -le 0x27BF) {
      return $true
    }
    if ($code -ge 0xD83C -and $code -le 0xDBFF -and ($i + 1) -lt $Text.Length) {
      $nextCode = [int][char]$Text[$i + 1]
      if ($nextCode -ge 0xDC00 -and $nextCode -le 0xDFFF) {
        return $true
      }
    }
  }

  return $false
}

Write-Host ''
Write-Host 'UI governance summary'

foreach ($target in $targets) {
  if (-not (Test-Path $target.Path)) {
    throw "UI governance path not found: $($target.Path)"
  }

  $matches = Get-ChildItem -Path $target.Path -Recurse -Filter '*.ets' |
    Select-String -Pattern $pattern

  $total = ($matches | Measure-Object).Count
  $byFile = $matches | Group-Object Path | Sort-Object Count -Descending

  Write-Host "  Scope: $($target.Name)"
  Write-Host "    Files scanned: $((Get-ChildItem -Path $target.Path -Recurse -Filter '*.ets').Count)"
  Write-Host "    Hardcoded visual tokens: $total"
  Write-Host "    Warning budget: $($target.Warn)"
  Write-Host "    Fail budget: $($target.Fail)"

  if ($byFile.Count -gt 0) {
    Write-Host '    Top files:'
    foreach ($item in ($byFile | Select-Object -First 5)) {
      Write-Host "      - $($item.Count) :: $($item.Name)"
    }
  }

  if ($total -gt $target.Fail) {
    $failed = $true
  }
}

$emojiMatches = @()
$emojiTargets = @(
  (Join-Path $repoRoot 'entry\src\main\ets\pages'),
  (Join-Path $repoRoot 'entry\src\main\ets\components')
)

foreach ($emojiTarget in $emojiTargets) {
  if (-not (Test-Path $emojiTarget)) {
    continue
  }

  $files = Get-ChildItem -Path $emojiTarget -Recurse -Filter '*.ets'
  foreach ($file in $files) {
    $lineNumber = 0
    foreach ($line in (Get-Content -Path $file.FullName -Encoding UTF8)) {
      $lineNumber += 1
      if (Test-ContainsEmoji -Text $line) {
        $emojiMatches += [PSCustomObject]@{
          Path = $file.FullName
          LineNumber = $lineNumber
          Line = $line.Trim()
        }
      }
    }
  }
}

Write-Host "  Active UI emoji literals: $($emojiMatches.Count)"
if ($emojiMatches.Count -gt 0) {
  foreach ($match in ($emojiMatches | Select-Object -First 12)) {
    $displayPath = Resolve-Path -Relative $match.Path
    Write-Host "    - ${displayPath}:$($match.LineNumber) $($match.Line)"
  }
  $failed = $true
}

if ($failed) {
  Write-Host ''
  Write-Host 'UI governance check failed.'
  exit 1
}

Write-Host ''
Write-Host 'UI governance check passed.'
