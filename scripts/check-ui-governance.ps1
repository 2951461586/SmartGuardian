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

if ($failed) {
  Write-Host ''
  Write-Host 'UI governance check failed.'
  exit 1
}

Write-Host ''
Write-Host 'UI governance check passed.'
