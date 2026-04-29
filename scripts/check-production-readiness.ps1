$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$hasFailure = $false

function Write-CheckResult {
  param(
    [string]$Label,
    [bool]$Passed,
    [string]$Detail
  )

  $status = if ($Passed) { 'PASS' } else { 'FAIL' }
  Write-Host ("[{0}] {1}: {2}" -f $status, $Label, $Detail)
  if (-not $Passed) {
    $script:hasFailure = $true
  }
}

function Read-JsonFile {
  param([string]$Path)
  return Get-Content -Path $Path -Encoding utf8 -Raw | ConvertFrom-Json
}

Write-Host ''
Write-Host 'SmartGuardian production readiness scan'

$agcPrereq = Join-Path $PSScriptRoot 'check-agc-prerequisites.ps1'
try {
  & $agcPrereq
  Write-CheckResult 'AGC prerequisites script' $true 'passed'
} catch {
  Write-CheckResult 'AGC prerequisites script' $false 'failed; see details above'
}

$manifestPath = Join-Path $repoRoot 'cloud-functions\function-manifest.json'
$schemaPath = Join-Path $repoRoot 'cloud-functions\cloud-db\schema.json'
$collectionsPath = Join-Path $repoRoot 'cloud-functions\cloud-db\collections.json'
$seedPath = Join-Path $repoRoot 'cloud-functions\cloud-db\seed-data.json'
$openApiFile = Get-ChildItem -Path (Join-Path $repoRoot 'docs') -Recurse -Filter 'openapi-full.yaml' | Select-Object -First 1
if (-not $openApiFile) {
  Write-CheckResult 'OpenAPI contract file' $false 'openapi-full.yaml not found under docs/'
  exit 1
}

$manifest = Read-JsonFile $manifestPath
$schema = Read-JsonFile $schemaPath
$collections = Read-JsonFile $collectionsPath
$seed = Read-JsonFile $seedPath
$openApi = Get-Content -Path $openApiFile.FullName -Encoding utf8 -Raw

$schemaNames = @{}
foreach ($collection in $schema.collections) {
  $schemaNames[$collection.name] = $true
}

$collectionNames = @{}
foreach ($collection in $collections.collections) {
  $collectionNames[$collection.name] = $true
}

$requiredCollections = @(
  'users',
  'user_sessions',
  'students',
  'orders',
  'sessions',
  'attendance_records',
  'leave_requests',
  'homework_tasks',
  'messages',
  'alerts',
  'form_cards',
  'security_audit_events',
  'domain_events',
  'notification_jobs',
  'notification_delivery_receipts',
  'user_notification_preferences',
  'cloud_attachments',
  'workbench_manifests'
)
foreach ($name in $requiredCollections) {
  Write-CheckResult "Cloud DB schema collection $name" ($schemaNames.ContainsKey($name)) $name
  Write-CheckResult "Cloud DB collections registry $name" ($collectionNames.ContainsKey($name)) $name
  $seedHasCollection = $seed.PSObject.Properties.Name -contains $name
  Write-CheckResult "Cloud DB seed collection $name" $seedHasCollection $name
}

$auditCollectionInAllFunctions = $true
foreach ($fn in $manifest.functions) {
  if ($fn.collections -notcontains 'security_audit_events') {
    $auditCollectionInAllFunctions = $false
    Write-CheckResult "Function audit collection $($fn.domain)" $false 'missing security_audit_events'
  }
}
if ($auditCollectionInAllFunctions) {
  Write-CheckResult 'Function audit collection coverage' $true 'all manifest functions can write security_audit_events'
}

$requiredDomains = @(
  'auth',
  'user',
  'student',
  'service',
  'order',
  'session',
  'attendance',
  'homework',
  'message',
  'alert',
  'report',
  'refund',
  'timeline',
  'card',
  'payment',
  'workbench',
  'agent',
  'security',
  'event',
  'notification',
  'storage'
)
foreach ($domain in $requiredDomains) {
  $fn = $manifest.functions | Where-Object { $_.domain -eq $domain } | Select-Object -First 1
  Write-CheckResult "Manifest domain $domain" ($null -ne $fn) $domain
  if ($null -ne $fn) {
    $entryPath = Join-Path $repoRoot ('cloud-functions\' + $fn.entry)
    $contractPath = Join-Path (Split-Path $entryPath -Parent) 'contract.json'
    Write-CheckResult "Function entry $domain" (Test-Path $entryPath) $entryPath
    Write-CheckResult "Function contract $domain" (Test-Path $contractPath) $contractPath
    $hasOpenApiDomain = $openApi -match "x-agc-function-domain:\s*$domain"
    Write-CheckResult "OpenAPI domain $domain" $hasOpenApiDomain $domain
  }
}

if ($hasFailure) {
  Write-Host ''
  Write-Host 'Production readiness scan failed.'
  exit 1
}

Write-Host ''
Write-Host 'Production readiness scan passed.'
