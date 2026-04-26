$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$pagesRoot = Join-Path $repoRoot 'entry\src\main\ets\pages'
$registryPath = Join-Path $repoRoot 'entry\src\main\resources\base\profile\main_pages.json'

if (-not (Test-Path $pagesRoot)) {
  throw "Pages directory not found: $pagesRoot"
}

if (-not (Test-Path $registryPath)) {
  throw "Page registry not found: $registryPath"
}

$registry = Get-Content -Path $registryPath -Encoding utf8 -Raw | ConvertFrom-Json
$registeredPages = @($registry.src | Sort-Object -Unique)

$actualPages = Get-ChildItem -Path $pagesRoot -Recurse -Filter *.ets |
  Where-Object {
    $content = Get-Content -Path $_.FullName -Encoding utf8 -Raw
    $content -match '@Entry'
  } |
  ForEach-Object {
    $relativePath = $_.FullName.Substring($pagesRoot.Length).TrimStart('\')
    $pagePath = 'pages/' + ($relativePath -replace '\\', '/' -replace '\.ets$', '')
    $pagePath
  } |
  Sort-Object -Unique

$missingFromRegistry = @($actualPages | Where-Object { $_ -notin $registeredPages })
$extraInRegistry = @($registeredPages | Where-Object { $_ -notin $actualPages })

Write-Host "Page registry scan summary"
Write-Host "  Registered: $($registeredPages.Count)"
Write-Host "  Actual @Entry pages: $($actualPages.Count)"

if ($missingFromRegistry.Count -gt 0) {
  Write-Host ''
  Write-Host 'Missing from main_pages.json:'
  $missingFromRegistry | ForEach-Object { Write-Host "  - $_" }
}

if ($extraInRegistry.Count -gt 0) {
  Write-Host ''
  Write-Host 'Registered but file/@Entry missing:'
  $extraInRegistry | ForEach-Object { Write-Host "  - $_" }
}

if ($missingFromRegistry.Count -gt 0 -or $extraInRegistry.Count -gt 0) {
  exit 1
}

Write-Host ''
Write-Host 'Page registry check passed.'
