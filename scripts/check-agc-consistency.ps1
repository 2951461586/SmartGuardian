$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$contractsPath = Join-Path $repoRoot 'entry\src\main\ets\services\agc\AgcFunctionContracts.ts'
$apiEndpointsPath = Join-Path $repoRoot 'entry\src\main\ets\constants\ApiEndpoints.ts'
$legacyContractsPath = Join-Path $repoRoot 'entry\src\main\ets\services\api\AgcServiceContracts.ts'
$manifestPath = Join-Path $repoRoot 'cloud-functions\function-manifest.json'
$collectionsPath = Join-Path $repoRoot 'cloud-functions\cloud-db\collections.json'
$openApiFile = Get-ChildItem -Path (Join-Path $repoRoot 'docs') -Recurse -Filter 'openapi-full.yaml' | Select-Object -First 1
$pageRegistryScript = Join-Path $PSScriptRoot 'check-page-registry.ps1'

if (-not (Test-Path $contractsPath)) { throw "AGC contracts file not found: $contractsPath" }
if (-not (Test-Path $apiEndpointsPath)) { throw "API endpoints file not found: $apiEndpointsPath" }
if (-not (Test-Path $manifestPath)) { throw "Function manifest not found: $manifestPath" }
if (-not (Test-Path $collectionsPath)) { throw "Cloud DB collections file not found: $collectionsPath" }
if (-not $openApiFile) { throw 'OpenAPI file not found under docs/' }
if (-not (Test-Path $pageRegistryScript)) { throw "Page registry script not found: $pageRegistryScript" }

& $pageRegistryScript

$contractsContent = Get-Content -Path $contractsPath -Encoding utf8 -Raw
$contractsCatalogContent = ($contractsContent -split 'export class AgcFunctionContractRegistry')[0]
$apiEndpointsContent = Get-Content -Path $apiEndpointsPath -Encoding utf8 -Raw
$openApiContent = Get-Content -Path $openApiFile.FullName -Encoding utf8 -Raw
$manifest = Get-Content -Path $manifestPath -Encoding utf8 -Raw | ConvertFrom-Json
$collections = Get-Content -Path $collectionsPath -Encoding utf8 -Raw | ConvertFrom-Json

$collectionNames = @{}
foreach ($collection in $collections.collections) {
  $collectionNames[$collection.name] = $true
}

$errors = New-Object System.Collections.Generic.List[string]
$checkedContracts = 0
$checkedContractRoutes = 0

if (Test-Path $legacyContractsPath) {
  $errors.Add("Legacy AGC service contract file must stay removed: $legacyContractsPath")
}

$apiEndpointValues = @{}
$apiBase = '/api/v1'
foreach ($match in [regex]::Matches($apiEndpointsContent, 'static readonly\s+([A-Z0-9_]+)\s*=\s*`([^`]+)`')) {
  $name = $match.Groups[1].Value
  $value = $match.Groups[2].Value.Replace('${API_BASE}', $apiBase)
  $apiEndpointValues[$name] = $value
}

$contractByDomain = @{}
foreach ($match in [regex]::Matches($contractsCatalogContent, "(?s)\{\s*domain:\s*'([^']+)'\s*,\s*functionName:\s*'([^']+)'\s*,\s*routePrefixes:\s*\[([^\]]*)\]\s*\}")) {
  $domain = $match.Groups[1].Value
  $functionName = $match.Groups[2].Value
  $routeSource = $match.Groups[3].Value
  $routes = New-Object System.Collections.Generic.List[string]

  foreach ($endpointMatch in [regex]::Matches($routeSource, 'ApiEndpoints\.([A-Z0-9_]+)')) {
    $endpointName = $endpointMatch.Groups[1].Value
    if ($apiEndpointValues.ContainsKey($endpointName)) {
      $routes.Add($apiEndpointValues[$endpointName])
    } else {
      $errors.Add("Contracts catalog references unknown ApiEndpoints.$endpointName for domain $domain")
    }
  }

  foreach ($literalMatch in [regex]::Matches($routeSource, "'([^']+)'")) {
    $routes.Add($literalMatch.Groups[1].Value)
  }

  $contractByDomain[$domain] = [pscustomobject]@{
    Domain = $domain
    FunctionName = $functionName
    Routes = $routes
  }
}

foreach ($manifestEntry in $manifest.functions) {
  $domain = $manifestEntry.domain
  $functionName = $manifestEntry.functionName

  if (-not $contractByDomain.ContainsKey($domain)) {
    $errors.Add("Contracts catalog missing domain: $domain")
  } else {
    $contractEntry = $contractByDomain[$domain]
    if ($contractEntry.FunctionName -ne $functionName) {
      $errors.Add("Contracts catalog function mismatch for ${domain}: expected $functionName, got $($contractEntry.FunctionName)")
    }

    foreach ($routePrefix in $manifestEntry.routePrefixes) {
      if (-not $contractEntry.Routes.Contains($routePrefix)) {
        $errors.Add("Contracts catalog missing route prefix $routePrefix for domain $domain")
      } else {
        $checkedContractRoutes += 1
      }
    }
  }

  $entryPath = Join-Path $repoRoot ('cloud-functions\' + $manifestEntry.entry)
  if (-not (Test-Path $entryPath)) {
    $errors.Add("Cloud function entry missing for domain ${domain}: $entryPath")
  }

  $contractPath = Join-Path (Split-Path $entryPath -Parent) 'contract.json'
  if (-not (Test-Path $contractPath)) {
    $errors.Add("Cloud function contract missing for domain ${domain}: $contractPath")
  } else {
    $domainContract = Get-Content -Path $contractPath -Encoding utf8 -Raw | ConvertFrom-Json
    if ($domainContract.domain -ne $domain) {
      $errors.Add("Domain contract mismatch in ${contractPath}: expected domain $domain, got $($domainContract.domain)")
    }
    if ($domainContract.functionName -ne $functionName) {
      $errors.Add("Domain contract mismatch in ${contractPath}: expected functionName $functionName, got $($domainContract.functionName)")
    }
    foreach ($routePrefix in $manifestEntry.routePrefixes) {
      if ($domainContract.routePrefixes -notcontains $routePrefix) {
        $errors.Add("Domain contract $contractPath missing route prefix $routePrefix")
      }
    }
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

if ($openApiContent -notmatch [regex]::Escape('/api/v1/auth/session-device')) {
  $errors.Add('OpenAPI missing /api/v1/auth/session-device')
}
if ($contractsCatalogContent -notmatch 'AUTH_SESSION_DEVICE') {
  $errors.Add('Contracts catalog should explicitly include ApiEndpoints.AUTH_SESSION_DEVICE')
}
if ((Get-Content -Path (Join-Path $repoRoot 'cloud-functions\auth\index.js') -Encoding utf8 -Raw) -notmatch [regex]::Escape('/api/v1/auth/session-device')) {
  $errors.Add('Auth cloud function missing /api/v1/auth/session-device route')
}

Write-Host ''
Write-Host 'AGC consistency scan summary'
Write-Host "  Contracts checked: $checkedContracts"
Write-Host "  Contract route prefixes checked: $checkedContractRoutes"
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
