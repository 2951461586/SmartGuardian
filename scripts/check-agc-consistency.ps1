$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$contractsPath = Join-Path $repoRoot 'entry\src\main\ets\services\agc\AgcFunctionContracts.ts'
$manifestPath = Join-Path $repoRoot 'cloud-functions\function-manifest.json'
$collectionsPath = Join-Path $repoRoot 'cloud-functions\cloud-db\collections.json'
$openApiFile = Get-ChildItem -Path (Join-Path $repoRoot 'docs') -Recurse -Filter 'openapi-full.yaml' | Select-Object -First 1
$mockHandlersRoot = Join-Path $repoRoot 'entry\src\main\ets\services\mock\handlers'
$pageRegistryScript = Join-Path $PSScriptRoot 'check-page-registry.ps1'

if (-not (Test-Path $contractsPath)) { throw "AGC contracts file not found: $contractsPath" }
if (-not (Test-Path $manifestPath)) { throw "Function manifest not found: $manifestPath" }
if (-not (Test-Path $collectionsPath)) { throw "Cloud DB collections file not found: $collectionsPath" }
if (-not $openApiFile) { throw 'OpenAPI file not found under docs/' }
if (-not (Test-Path $mockHandlersRoot)) { throw "Mock handlers directory not found: $mockHandlersRoot" }
if (-not (Test-Path $pageRegistryScript)) { throw "Page registry script not found: $pageRegistryScript" }

& $pageRegistryScript

$contractsContent = Get-Content -Path $contractsPath -Encoding utf8 -Raw
$contractsCatalogContent = ($contractsContent -split 'export class AgcFunctionContractRegistry')[0]
$openApiContent = Get-Content -Path $openApiFile.FullName -Encoding utf8 -Raw
$manifest = Get-Content -Path $manifestPath -Encoding utf8 -Raw | ConvertFrom-Json
$collections = Get-Content -Path $collectionsPath -Encoding utf8 -Raw | ConvertFrom-Json

$collectionNames = @{}
foreach ($collection in $collections.collections) {
  $collectionNames[$collection.name] = $true
}

$errors = New-Object System.Collections.Generic.List[string]
$checkedContracts = 0

foreach ($manifestEntry in $manifest.functions) {
  $domain = $manifestEntry.domain
  $functionName = $manifestEntry.functionName

  if ($contractsCatalogContent -notmatch [regex]::Escape("domain: '$domain'")) {
    $errors.Add("Contracts catalog missing domain: $domain")
  }
  if ($contractsCatalogContent -notmatch [regex]::Escape("functionName: '$functionName'")) {
    $errors.Add("Contracts catalog missing functionName: $functionName")
  }

  $entryPath = Join-Path $repoRoot ('cloud-functions\' + $manifestEntry.entry)
  if (-not (Test-Path $entryPath)) {
    $errors.Add("Cloud function entry missing for domain ${domain}: $entryPath")
  }

  $handlerName = (Get-Culture).TextInfo.ToTitleCase($domain) -replace '-', ''
  $mockHandlerPath = Join-Path $mockHandlersRoot ($handlerName + 'MockHandler.ts')
  if (-not (Test-Path $mockHandlerPath)) {
    $errors.Add("Mock handler missing for domain ${domain}: $mockHandlerPath")
  }

  if ($openApiContent -notmatch "x-agc-function-domain:\s*$domain") {
    $errors.Add("OpenAPI missing x-agc-function-domain for $domain")
  }
  if ($openApiContent -notmatch "x-agc-function-name:\s*$functionName") {
    $errors.Add("OpenAPI missing x-agc-function-name for $functionName")
  }

  foreach ($routePrefix in $manifestEntry.routePrefixes) {
    if ($openApiContent -notmatch [regex]::Escape($routePrefix)) {
      $errors.Add("OpenAPI missing route prefix $routePrefix for domain $domain")
    }
  }

  foreach ($collection in $manifestEntry.collections) {
    if (-not $collectionNames.ContainsKey($collection)) {
      $errors.Add("Cloud DB collections.json missing collection '$collection' referenced by $domain")
    }
  }

  $checkedContracts += 1
}

Write-Host ''
Write-Host 'AGC consistency scan summary'
Write-Host "  Contracts checked: $checkedContracts"
Write-Host "  Manifest functions: $($manifest.functions.Count)"
Write-Host "  Cloud DB collections: $($collections.collections.Count)"

if ($errors.Count -gt 0) {
  Write-Host ''
  Write-Host 'Consistency errors:'
  foreach ($errorItem in $errors) {
    Write-Host "  - $errorItem"
  }
  exit 1
}

Write-Host ''
Write-Host 'AGC consistency check passed.'
