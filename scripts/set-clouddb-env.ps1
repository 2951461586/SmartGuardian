# Set Cloud DB server environment variables for current session
$env:SMARTGUARDIAN_CLOUD_DB_PROVIDER='agc'
$env:AGC_CLOUD_DB_ZONE='ClouddbDev'
$env:PROJECT_CREDENTIAL='F:\HarmonyOSProjects\SmartGuardian\secrets\agc-apiclient-smartguardian.json'
$env:AGC_REGION='CN'

Write-Host "Cloud DB environment variables set:" -ForegroundColor Green
Write-Host "  SMARTGUARDIAN_CLOUD_DB_PROVIDER = $env:SMARTGUARDIAN_CLOUD_DB_PROVIDER"
Write-Host "  AGC_CLOUD_DB_ZONE = $env:AGC_CLOUD_DB_ZONE"
Write-Host "  PROJECT_CREDENTIAL = $env:PROJECT_CREDENTIAL"
Write-Host "  AGC_REGION = $env:AGC_REGION"
Write-Host ""
Write-Host "To verify, run: .\scripts\check-agc-prerequisites.ps1" -ForegroundColor Yellow
