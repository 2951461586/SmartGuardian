param(
  [switch]$RequireDevice,
  [switch]$RunCloudSmoke,
  [switch]$RunBuild
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$formConfigPath = Join-Path $repoRoot 'entry\src\main\resources\base\profile\form_config.json'
$formAbilityPath = Join-Path $repoRoot 'entry\src\main\ets\formability\TodayGuardianFormAbility.ets'
$syncServicePath = Join-Path $repoRoot 'entry\src\main\ets\services\FormCardSyncService.ets'
$cardServicePath = Join-Path $repoRoot 'entry\src\main\ets\services\api\card.ts'
$openApiFile = Get-ChildItem -Path (Join-Path $repoRoot 'docs') -Recurse -Filter 'openapi-full.yaml' | Select-Object -First 1

if (-not (Test-Path $formConfigPath)) { throw "Form config not found: $formConfigPath" }
if (-not (Test-Path $formAbilityPath)) { throw "Form ability not found: $formAbilityPath" }
if (-not (Test-Path $syncServicePath)) { throw "Form sync service not found: $syncServicePath" }
if (-not (Test-Path $cardServicePath)) { throw "Card service not found: $cardServicePath" }
if (-not $openApiFile) { throw 'OpenAPI not found under docs.' }

$formConfig = Get-Content -Path $formConfigPath -Encoding utf8 -Raw | ConvertFrom-Json
$formNames = @()
foreach ($form in $formConfig.forms) {
  $formNames += $form.name
}

$errors = New-Object System.Collections.Generic.List[string]

if ($formNames -notcontains 'TodayGuardianCard') {
  $errors.Add('form_config.json missing TodayGuardianCard.')
}
if ($formNames -notcontains 'AbnormalAlertCard') {
  $errors.Add('form_config.json missing AbnormalAlertCard.')
}

$formConfigText = Get-Content -Path $formConfigPath -Encoding utf8 -Raw
if ($formConfigText -match 'formConfigAbility') {
  $errors.Add('form_config.json still declares formConfigAbility; remove stale or non-existing config abilities before device acceptance.')
}

$formAbilityText = Get-Content -Path $formAbilityPath -Encoding utf8 -Raw
if ($formAbilityText -notmatch 'registerForm\(this\.context,\s*formId,\s*dimension,\s*formName\)') {
  $errors.Add('TodayGuardianFormAbility should persist formName when a desktop form is added.')
}
if ($formAbilityText -notmatch 'buildAlertFormDataByDimension') {
  $errors.Add('TodayGuardianFormAbility should bind AbnormalAlertCard data.')
}

$syncServiceText = Get-Content -Path $syncServicePath -Encoding utf8 -Raw
if ($syncServiceText -notmatch 'ALERT_FORM_NAME') {
  $errors.Add('FormCardSyncService missing alert form routing.')
}
if ($syncServiceText -notmatch 'getAbnormalAlert') {
  $errors.Add('FormCardSyncService should fetch abnormal alert card data.')
}
if ($syncServiceText -notmatch 'getConsistency\(studentId,\s*true\)') {
  $errors.Add('FormCardSyncService should refresh cloud consistency before updating desktop forms.')
}
if ($syncServiceText -notmatch 'formProvider\.updateForm') {
  $errors.Add('FormCardSyncService should update registered desktop forms.')
}

$cardServiceText = Get-Content -Path $cardServicePath -Encoding utf8 -Raw
if ($cardServiceText -notmatch 'CARDS_CONSISTENCY') {
  $errors.Add('CardService missing cards consistency endpoint.')
}
if ($cardServiceText -notmatch 'CARDS_REFRESH') {
  $errors.Add('CardService missing cards refresh endpoint.')
}

$openApiText = Get-Content -Path $openApiFile.FullName -Encoding utf8 -Raw
if ($openApiText -notmatch '/api/v1/cards/consistency') {
  $errors.Add('OpenAPI missing /api/v1/cards/consistency.')
}
if ($openApiText -notmatch '/api/v1/cards/refresh') {
  $errors.Add('OpenAPI missing /api/v1/cards/refresh.')
}

if ($RunCloudSmoke) {
  Push-Location (Join-Path $repoRoot 'cloud-functions')
  try {
    npm run smoke
    if ($LASTEXITCODE -ne 0) {
      $errors.Add('Cloud function smoke failed.')
    }
  } finally {
    Pop-Location
  }
}

if ($RunBuild) {
  Push-Location $repoRoot
  try {
    & .\hvigorw.bat assembleHap
    if ($LASTEXITCODE -ne 0) {
      $errors.Add('assembleHap failed.')
    }
  } finally {
    Pop-Location
  }
}

$hdcCommand = Get-Command hdc -ErrorAction SilentlyContinue
if ($hdcCommand) {
  $targets = (& hdc list targets) -join "`n"
  if ($targets.Trim().Length -eq 0 -or $targets -match 'Empty') {
    if ($RequireDevice) {
      $errors.Add('No HarmonyOS device target detected by hdc.')
    } else {
      Write-Host '[INFO] hdc is available, but no device target is currently connected.'
    }
  } else {
    Write-Host '[PASS] hdc device target detected:'
    Write-Host $targets
  }
} elseif ($RequireDevice) {
  $errors.Add('hdc command is not available; cannot perform required device acceptance.')
} else {
  Write-Host '[INFO] hdc command is not available. Static and cloud-side checks will still run.'
}

Write-Host ''
Write-Host 'Form card consistency acceptance scan'
Write-Host "  Forms declared: $($formNames -join ', ')"
Write-Host "  Cloud smoke: $(if ($RunCloudSmoke) { 'executed' } else { 'skipped' })"
Write-Host "  HAP build: $(if ($RunBuild) { 'executed' } else { 'skipped' })"
Write-Host "  Require device: $RequireDevice"

if ($errors.Count -gt 0) {
  Write-Host ''
  Write-Host 'Acceptance errors:'
  foreach ($errorItem in $errors) {
    Write-Host "  - $errorItem"
  }
  exit 1
}

Write-Host ''
Write-Host 'Form card consistency acceptance scan passed.'
