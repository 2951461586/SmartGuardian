$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$docsRoot = Join-Path $repoRoot 'docs'

if (-not (Test-Path $docsRoot)) {
  throw "Docs directory not found: $docsRoot"
}

$files = Get-ChildItem -Path $docsRoot -Recurse -Filter *.md
foreach ($file in $files) {
  $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
  $normalized = $content -replace '(>\s*版本：)V\d+\.\d+', '$1V1.2'
  $normalized = $normalized -replace '(\*\*版本\*\*：)V\d+\.\d+', '$1V1.2'
  if ($normalized -ne $content) {
    Set-Content -LiteralPath $file.FullName -Value $normalized -Encoding UTF8
  }
}
