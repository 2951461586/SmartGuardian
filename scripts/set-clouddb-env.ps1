# Set Cloud DB server environment variables for current session
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$credentialPath = Join-Path $repoRoot 'secrets\agc-apiclient-1937040078446550272-d06fe7bb66d14b50bb9adb3ff98074e9.json'

$env:SMARTGUARDIAN_CLOUD_DB_PROVIDER='agc'
$env:SMARTGUARDIAN_CLOUD_DB_ZONE='ClouddbDev'
$env:SMARTGUARDIAN_PROJECT_CREDENTIAL=$credentialPath
$env:SMARTGUARDIAN_REGION='CN'

$env:AGC_CLOUD_DB_ZONE=$env:SMARTGUARDIAN_CLOUD_DB_ZONE
$env:PROJECT_CREDENTIAL=$env:SMARTGUARDIAN_PROJECT_CREDENTIAL
$env:AGC_REGION=$env:SMARTGUARDIAN_REGION

Write-Host "Cloud DB environment variables set:" -ForegroundColor Green
Write-Host "  SMARTGUARDIAN_CLOUD_DB_PROVIDER = $env:SMARTGUARDIAN_CLOUD_DB_PROVIDER"
Write-Host "  SMARTGUARDIAN_CLOUD_DB_ZONE = $env:SMARTGUARDIAN_CLOUD_DB_ZONE"
Write-Host "  SMARTGUARDIAN_PROJECT_CREDENTIAL = $env:SMARTGUARDIAN_PROJECT_CREDENTIAL"
Write-Host "  SMARTGUARDIAN_REGION = $env:SMARTGUARDIAN_REGION"
Write-Host ""
Write-Host "To verify, run: .\scripts\check-agc-prerequisites.ps1" -ForegroundColor Yellow
