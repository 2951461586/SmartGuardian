$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$clientConfigPath = Join-Path $projectRoot 'entry\src\main\resources\rawfile\agconnect-services.json'
$cloudEnvPath = Join-Path $projectRoot 'cloud-functions\.env'
$placeholders = @(
  'YOUR_APP_ID',
  'YOUR_CLIENT_ID',
  'YOUR_CLIENT_SECRET',
  'YOUR_API_KEY',
  'YOUR_CP_ID',
  'YOUR_PRODUCT_ID'
)

function Write-CheckResult {
  param(
    [string]$Label,
    [bool]$Passed,
    [string]$Detail
  )

  $status = if ($Passed) { 'PASS' } else { 'FAIL' }
  Write-Output ("[{0}] {1}: {2}" -f $status, $Label, $Detail)
}

function Get-EnvValue {
  param(
    [string]$Key
  )

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
    if ($currentKey -ne $Key) {
      continue
    }

    return $line.Substring($separatorIndex + 1).Trim().Trim('"').Trim("'")
  }

  return ''
}

$hasFailure = $false

if (-not (Test-Path $clientConfigPath)) {
  Write-CheckResult 'AGC client config' $false "Missing $clientConfigPath"
  $hasFailure = $true
} else {
  $clientConfigRaw = Get-Content -Path $clientConfigPath -Raw
  $placeholderHits = @()
  foreach ($placeholder in $placeholders) {
    if ($clientConfigRaw.Contains($placeholder)) {
      $placeholderHits += $placeholder
    }
  }

  if ($placeholderHits.Count -gt 0) {
    Write-CheckResult 'AGC client config' $false ("Placeholder values still present: {0}" -f ($placeholderHits -join ', '))
    $hasFailure = $true
  } else {
    Write-CheckResult 'AGC client config' $true $clientConfigPath
  }
}

$provider = Get-EnvValue 'SMARTGUARDIAN_CLOUD_DB_PROVIDER'
$zone = Get-EnvValue 'SMARTGUARDIAN_CLOUD_DB_ZONE'
if ([string]::IsNullOrWhiteSpace($zone)) {
  $zone = Get-EnvValue 'AGC_CLOUD_DB_ZONE'
}
$configPath = Get-EnvValue 'SMARTGUARDIAN_CREDENTIAL_PATH'
if ([string]::IsNullOrWhiteSpace($configPath)) {
  $configPath = Get-EnvValue 'AGC_CONFIG'
}
$projectCredential = Get-EnvValue 'SMARTGUARDIAN_PROJECT_CREDENTIAL'
if ([string]::IsNullOrWhiteSpace($projectCredential)) {
  $projectCredential = Get-EnvValue 'PROJECT_CREDENTIAL'
}
$region = Get-EnvValue 'SMARTGUARDIAN_REGION'
if ([string]::IsNullOrWhiteSpace($region)) {
  $region = Get-EnvValue 'AGC_REGION'
}
$connectPrivateKeyFile = Get-EnvValue 'AGC_CONNECT_PRIVATE_KEY_FILE'

Write-CheckResult 'SMARTGUARDIAN_CLOUD_DB_PROVIDER' ($provider -eq 'agc') ("current='{0}'" -f $provider)
if ($provider -ne 'agc') {
  $hasFailure = $true
}

Write-CheckResult 'SMARTGUARDIAN_CLOUD_DB_ZONE' (-not [string]::IsNullOrWhiteSpace($zone)) ("current='{0}'" -f $zone)
if ([string]::IsNullOrWhiteSpace($zone)) {
  $hasFailure = $true
}

$resolvedCredential = ''
if (-not [string]::IsNullOrWhiteSpace($configPath)) {
  $resolvedCredential = $configPath
} elseif (-not [string]::IsNullOrWhiteSpace($projectCredential)) {
  $resolvedCredential = $projectCredential
}

if ([string]::IsNullOrWhiteSpace($resolvedCredential)) {
  Write-CheckResult 'AGC server credential' $false 'Neither AGC_CONFIG nor PROJECT_CREDENTIAL is set'
  $hasFailure = $true
} else {
  $credentialExists = Test-Path $resolvedCredential
  Write-CheckResult 'AGC server credential' $credentialExists $resolvedCredential
  if (-not $credentialExists) {
    $hasFailure = $true
  } else {
    try {
      $credentialJson = Get-Content -Path $resolvedCredential -Raw | ConvertFrom-Json
      $isClientConfig = $null -ne $credentialJson.client -and $null -ne $credentialJson.client.app_id
      $isServerCredential = -not [string]::IsNullOrWhiteSpace($credentialJson.client_id) -and -not [string]::IsNullOrWhiteSpace($credentialJson.client_secret) -and -not [string]::IsNullOrWhiteSpace($credentialJson.project_id)

      if ($isClientConfig) {
        Write-CheckResult 'AGC server credential type' $false 'Current file is agconnect-services.json. Use Server SDK credential JSON (agc-apiclient-*.json).'
        $hasFailure = $true
      } elseif ($isServerCredential) {
        Write-CheckResult 'AGC server credential type' $true 'Server SDK credential JSON detected'
      } else {
        Write-CheckResult 'AGC server credential type' $false 'Credential JSON format is not recognized as Server SDK credential'
        $hasFailure = $true
      }
    } catch {
      Write-CheckResult 'AGC server credential type' $false 'Credential file is not valid JSON'
      $hasFailure = $true
    }
  }
}

if ([string]::IsNullOrWhiteSpace($region)) {
  Write-CheckResult 'SMARTGUARDIAN_REGION' $true "unset, runtime will default to 'CN'"
} else {
  Write-CheckResult 'SMARTGUARDIAN_REGION' $true ("current='{0}'" -f $region)
}

if ([string]::IsNullOrWhiteSpace($connectPrivateKeyFile)) {
  Write-CheckResult 'AGC Connect API private key' $true 'optional, unset'
} else {
  $connectKeyExists = Test-Path $connectPrivateKeyFile
  Write-CheckResult 'AGC Connect API private key' $connectKeyExists $connectPrivateKeyFile
  if (-not $connectKeyExists) {
    $hasFailure = $true
  } else {
    try {
      $connectKeyJson = Get-Content -Path $connectPrivateKeyFile -Raw | ConvertFrom-Json
      $isConnectPrivateKey = -not [string]::IsNullOrWhiteSpace($connectKeyJson.key_id) -and -not [string]::IsNullOrWhiteSpace($connectKeyJson.private_key) -and -not [string]::IsNullOrWhiteSpace($connectKeyJson.sub_account) -and -not [string]::IsNullOrWhiteSpace($connectKeyJson.token_uri)

      if ($isConnectPrivateKey) {
        Write-CheckResult 'AGC Connect API private key type' $true 'Server auth private key JSON detected'
      } else {
        Write-CheckResult 'AGC Connect API private key type' $false 'Expected key_id, private_key, sub_account and token_uri'
        $hasFailure = $true
      }
    } catch {
      Write-CheckResult 'AGC Connect API private key type' $false 'Private key file is not valid JSON'
      $hasFailure = $true
    }
  }
}

if ($hasFailure) {
  exit 1
}

Write-Output 'AGC prerequisites are ready.'
