$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$pagesRoot = Join-Path $repoRoot 'entry\src\main\ets\pages'
$pageWarnBudget = 450
$pageFailBudget = 650

if (-not (Test-Path $pagesRoot)) {
  throw "Pages directory not found: $pagesRoot"
}

$pageStats = Get-ChildItem -Path $pagesRoot -Recurse -Filter '*.ets' | ForEach-Object {
  $lineCount = (Get-Content -Path $_.FullName -Encoding utf8).Count
  [PSCustomObject]@{
    Path = $_.FullName
    Lines = $lineCount
  }
}

$warningPages = $pageStats | Where-Object { $_.Lines -gt $pageWarnBudget } | Sort-Object Lines -Descending
$failingPages = $pageStats | Where-Object { $_.Lines -gt $pageFailBudget } | Sort-Object Lines -Descending

Write-Host ''
Write-Host 'Page size budget summary'
Write-Host "  Pages scanned: $($pageStats.Count)"
Write-Host "  Warning budget: $pageWarnBudget"
Write-Host "  Fail budget: $pageFailBudget"

if ($warningPages.Count -gt 0) {
  Write-Host ''
  Write-Host 'Pages over warning budget:'
  foreach ($page in $warningPages | Select-Object -First 10) {
    Write-Host "  - $($page.Lines) lines :: $($page.Path)"
  }
}

if ($failingPages.Count -gt 0) {
  Write-Host ''
  Write-Host 'Pages over fail budget:'
  foreach ($page in $failingPages) {
    Write-Host "  - $($page.Lines) lines :: $($page.Path)"
  }
  exit 1
}

Write-Host ''
Write-Host 'Page size budget check passed.'
