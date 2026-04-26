param(
  [switch]$RunBuild,
  [string]$LogPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')) 'build-warning-normal.log')
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$resolvedLogPath = $LogPath
if (-not [System.IO.Path]::IsPathRooted($resolvedLogPath)) {
  $resolvedLogPath = Join-Path $repoRoot $resolvedLogPath
}

if ($RunBuild) {
  Push-Location $repoRoot
  try {
    & cmd /c "hvigorw.bat clean > NUL 2>&1"
    if ($LASTEXITCODE -ne 0) {
      throw 'hvigor clean failed.'
    }
    & cmd /c "hvigorw.bat assembleHap > `"$resolvedLogPath`" 2>&1"
    if ($LASTEXITCODE -ne 0) {
      throw "hvigor assembleHap failed. See $resolvedLogPath"
    }
  } finally {
    Pop-Location
  }
}

if (-not (Test-Path $resolvedLogPath)) {
  throw "Build log not found: $resolvedLogPath. Run with -RunBuild or pass -LogPath."
}

$lines = Get-Content $resolvedLogPath
$warningLines = $lines | Where-Object {
  $_ -match 'WARN|Warning'
}
$errorLines = $lines | Where-Object {
  $_ -match 'ERROR|BUILD FAILED'
}

$agconnectWarnings = @()
$signingWarnings = @()
$applicationWarnings = @()
$otherWarnings = @()

foreach ($line in $warningLines) {
  if ($line -match 'oh_modules[\\/]\.ohpm[\\/]@hw-agconnect' -or $line -match "'page_show' conflict") {
    $agconnectWarnings += $line
    continue
  }

  if ($line -match 'No signingConfig found for product default' -or $line -match 'signingConfig') {
    $signingWarnings += $line
    continue
  }

  if ($line -match 'entry[\\/]src[\\/]main[\\/]ets') {
    $applicationWarnings += $line
    continue
  }

  $otherWarnings += $line
}

Write-Host ''
Write-Host 'Build warning summary'
Write-Host "  Log: $resolvedLogPath"
Write-Host "  Application warnings: $($applicationWarnings.Count)"
Write-Host "  AGConnect SDK warnings: $($agconnectWarnings.Count)"
Write-Host "  Signing warnings: $($signingWarnings.Count)"
Write-Host "  Other warnings: $($otherWarnings.Count)"

if ($applicationWarnings.Count -gt 0) {
  Write-Host ''
  Write-Host 'Application warnings:'
  foreach ($line in ($applicationWarnings | Select-Object -First 20)) {
    Write-Host "  - $line"
  }
}

if ($otherWarnings.Count -gt 0) {
  Write-Host ''
  Write-Host 'Other warnings:'
  foreach ($line in ($otherWarnings | Select-Object -First 20)) {
    Write-Host "  - $line"
  }
}

if ($errorLines.Count -gt 0) {
  Write-Host ''
  Write-Host 'Build errors detected:'
  foreach ($line in ($errorLines | Select-Object -First 20)) {
    Write-Host "  - $line"
  }
  exit 1
}

if ($applicationWarnings.Count -gt 0 -or $otherWarnings.Count -gt 0) {
  Write-Host ''
  Write-Host 'Build warning check failed.'
  exit 1
}

Write-Host ''
Write-Host 'Build warning check passed for application code.'
if ($agconnectWarnings.Count -gt 0 -or $signingWarnings.Count -gt 0) {
  Write-Host 'External warnings remain: AGConnect SDK package warnings and/or missing local signingConfig.'
}
