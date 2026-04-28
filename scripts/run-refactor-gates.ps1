$ErrorActionPreference = 'Stop'

$scripts = @(
  (Join-Path $PSScriptRoot 'check-legacy-artifacts.ps1'),
  (Join-Path $PSScriptRoot 'check-page-registry.ps1'),
  (Join-Path $PSScriptRoot 'check-agc-consistency.ps1'),
  (Join-Path $PSScriptRoot 'check-page-budget.ps1'),
  (Join-Path $PSScriptRoot 'check-ui-governance.ps1'),
  (Join-Path $PSScriptRoot 'check-build-warnings.ps1')
)

foreach ($scriptPath in $scripts) {
  if (-not (Test-Path $scriptPath)) {
    throw "Gate script not found: $scriptPath"
  }

  Write-Host ''
  Write-Host "Running $(Split-Path $scriptPath -Leaf) ..."
  if ((Split-Path $scriptPath -Leaf) -eq 'check-build-warnings.ps1') {
    & $scriptPath -RunBuild
  } else {
    & $scriptPath
  }
}

Write-Host ''
Write-Host 'Running assembleHap --analyze=advanced ...'
Push-Location (Resolve-Path (Join-Path $PSScriptRoot '..'))
try {
  & .\hvigorw.bat assembleHap --analyze=advanced
  if ($LASTEXITCODE -ne 0) {
    throw 'hvigor assembleHap --analyze=advanced failed.'
  }
} finally {
  Pop-Location
}

Write-Host ''
Write-Host 'All refactor gates passed.'
