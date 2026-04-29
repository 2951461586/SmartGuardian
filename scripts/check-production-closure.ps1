param(
  [switch]$RequireDevice,
  [switch]$RunBuild,
  [switch]$RunCloudSmoke
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$cloudEnvPath = Join-Path $repoRoot 'cloud-functions\.env'
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

function Get-EnvValue {
  param([string]$Key)

  $value = [Environment]::GetEnvironmentVariable($Key)
  if (-not [string]::IsNullOrWhiteSpace($value)) {
    return $value
  }

  if (-not (Test-Path $cloudEnvPath)) {
    return ''
  }

  $lines = Get-Content -Path $cloudEnvPath
  foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith('#')) {
      continue
    }
    $separatorIndex = $line.IndexOf('=')
    if ($separatorIndex -lt 1) {
      continue
    }
    $currentKey = $line.Substring(0, $separatorIndex).Trim()
    if ($currentKey -eq $Key) {
      return $line.Substring($separatorIndex + 1).Trim().Trim('"').Trim("'")
    }
  }
  return ''
}

function Test-Placeholder {
  param([string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $true
  }
  return $Value.StartsWith('<') -and $Value.EndsWith('>')
}

Write-Host ''
Write-Host 'SmartGuardian first-batch production closure scan'

try {
  & (Join-Path $PSScriptRoot 'check-production-readiness.ps1')
  Write-CheckResult 'Baseline production readiness' $true 'passed'
} catch {
  Write-CheckResult 'Baseline production readiness' $false 'failed; see details above'
}

$deliveryMode = Get-EnvValue 'SMARTGUARDIAN_PUSH_DELIVERY_MODE'
$pushAppId = Get-EnvValue 'HUAWEI_PUSH_APP_ID'
$pushClientId = Get-EnvValue 'HUAWEI_PUSH_CLIENT_ID'
$pushClientSecret = Get-EnvValue 'HUAWEI_PUSH_CLIENT_SECRET'
$eventSecret = Get-EnvValue 'SMARTGUARDIAN_EVENT_CONSUMER_SECRET'
$storageBucket = Get-EnvValue 'SMARTGUARDIAN_STORAGE_BUCKET'
if ([string]::IsNullOrWhiteSpace($storageBucket)) {
  $storageBucket = Get-EnvValue 'AGC_CLOUD_STORAGE_BUCKET'
}

Write-CheckResult 'Push delivery mode' ($deliveryMode -eq 'real') ("current='{0}'" -f $deliveryMode)
Write-CheckResult 'Huawei Push app id' (-not (Test-Placeholder $pushAppId)) 'HUAWEI_PUSH_APP_ID'
Write-CheckResult 'Huawei Push client id' (-not (Test-Placeholder $pushClientId)) 'HUAWEI_PUSH_CLIENT_ID'
Write-CheckResult 'Huawei Push client secret' (-not (Test-Placeholder $pushClientSecret)) 'HUAWEI_PUSH_CLIENT_SECRET'
Write-CheckResult 'Event trigger consumer secret' (-not (Test-Placeholder $eventSecret)) 'SMARTGUARDIAN_EVENT_CONSUMER_SECRET'
Write-CheckResult 'AGC Cloud Storage bucket' (-not (Test-Placeholder $storageBucket)) 'SMARTGUARDIAN_STORAGE_BUCKET or AGC_CLOUD_STORAGE_BUCKET'

$pushSourcePath = Join-Path $repoRoot 'entry\src\main\ets\services\PushTokenProviderService.ets'
$endpointRegistrationPath = Join-Path $repoRoot 'entry\src\main\ets\services\NotificationEndpointRegistrationService.ets'
$storageUploadPath = Join-Path $repoRoot 'entry\src\main\ets\services\CloudStorageUploadService.ets'
$formSyncPath = Join-Path $repoRoot 'entry\src\main\ets\services\FormCardSyncService.ets'
$eventFunctionPath = Join-Path $repoRoot 'cloud-functions\event\index.js'
$pushGatewayPath = Join-Path $repoRoot 'cloud-functions\shared\push.js'

$pushSourceText = Get-Content -Path $pushSourcePath -Encoding utf8 -Raw
$endpointRegistrationText = Get-Content -Path $endpointRegistrationPath -Encoding utf8 -Raw
$storageUploadText = Get-Content -Path $storageUploadPath -Encoding utf8 -Raw
$formSyncText = Get-Content -Path $formSyncPath -Encoding utf8 -Raw
$eventFunctionText = Get-Content -Path $eventFunctionPath -Encoding utf8 -Raw
$pushGatewayText = Get-Content -Path $pushGatewayPath -Encoding utf8 -Raw

Write-CheckResult 'Push token provider boundary' ($pushSourceText -match 'registerSource' -and $pushSourceText -match 'persistPushKitToken') $pushSourcePath
Write-CheckResult 'Session endpoint registration' ($endpointRegistrationText -match 'registerSessionDevice' -and $endpointRegistrationText -match 'canRegisterRemoteEndpoint') $endpointRegistrationPath
Write-CheckResult 'Huawei Push gateway real mode' ($pushGatewayText -match 'SMARTGUARDIAN_PUSH_DELIVERY_MODE' -and $pushGatewayText -match 'sendHuaweiPushAsync') $pushGatewayPath
Write-CheckResult 'Event trigger secret enforcement' ($eventFunctionText -match 'SMARTGUARDIAN_EVENT_CONSUMER_SECRET' -and $eventFunctionText -match 'x-smartguardian-event-secret') $eventFunctionPath
Write-CheckResult 'Cloud Storage upload adapter boundary' ($storageUploadText -match 'CloudStorageUploadAdapter' -and $storageUploadText -match 'uploadAttachment') $storageUploadPath
Write-CheckResult 'Form card device refresh service' ($formSyncText -match 'formProvider\.updateForm' -and $formSyncText -match 'getConsistency\(studentId,\s*true\)') $formSyncPath

try {
  & (Join-Path $PSScriptRoot 'check-form-card-consistency.ps1') -RequireDevice:$RequireDevice
  Write-CheckResult 'Form card consistency gate' $true 'passed'
} catch {
  Write-CheckResult 'Form card consistency gate' $false 'failed; see details above'
}

if ($RunCloudSmoke) {
  Push-Location (Join-Path $repoRoot 'cloud-functions')
  try {
    npm run smoke
    Write-CheckResult 'Cloud function smoke' ($LASTEXITCODE -eq 0) 'npm run smoke'
  } finally {
    Pop-Location
  }
}

if ($RunBuild) {
  Push-Location $repoRoot
  try {
    & .\hvigorw.bat assembleHap
    Write-CheckResult 'HAP build' ($LASTEXITCODE -eq 0) 'hvigorw assembleHap'
  } finally {
    Pop-Location
  }
}

if ($hasFailure) {
  Write-Host ''
  Write-Host 'First-batch production closure scan failed.'
  exit 1
}

Write-Host ''
Write-Host 'First-batch production closure scan passed.'
