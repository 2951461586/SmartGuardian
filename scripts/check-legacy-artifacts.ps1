$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')

$blockedPaths = @(
  'backend',
  'entry\src\main\ets\services\mock'
)

$blockedFiles = @(
  'backend\pom.xml',
  'backend\src\main\java',
  'backend\docker-compose.mysql.yml'
)

$blockedPatterns = @(
  @{
    Name = 'retired runtime environment'
    Pattern = 'DEV_MOCK|TEST_REAL|USE_MOCK_DATA'
    Paths = @('entry\src\main\ets', 'entry\oh-package.json5', 'oh-package.json5')
  },
  @{
    Name = 'retired Java backend endpoint'
    Pattern = '127\.0\.0\.1:8080|localhost:8080|Spring Boot|MySQL'
    Paths = @('entry\src\main\ets', 'cloud-functions', 'scripts')
  },
  @{
    Name = 'retired mock dependency'
    Pattern = '@ohos/hamock|MockKit'
    Paths = @('oh-package.json5', 'oh-package-lock.json5', 'entry\oh-package.json5', 'entry\src')
  },
  @{
    Name = 'retired runtime mock switch'
    Pattern = 'MockServiceSwitch|MockControl|services\\mock'
    Paths = @('entry\src\main\ets')
  },
  @{
    Name = 'preview-only or stub runtime wording'
    Pattern = 'previewMessageDispatch|stub mode|stub invoked'
    Paths = @('entry\src\main\ets')
  }
)

$failed = $false

Write-Host ''
Write-Host 'Legacy artifact summary'

foreach ($relativePath in $blockedPaths + $blockedFiles) {
  $path = Join-Path $repoRoot $relativePath
  if (Test-Path $path) {
    Write-Host "  Blocked path exists: $relativePath"
    $failed = $true
  }
}

foreach ($rule in $blockedPatterns) {
  foreach ($relativePath in $rule.Paths) {
    $path = Join-Path $repoRoot $relativePath
    if (-not (Test-Path $path)) {
      continue
    }

    $files = @()
    if ((Get-Item $path).PSIsContainer) {
      $files = Get-ChildItem -Path $path -Recurse -File |
        Where-Object {
          $_.FullName -notmatch '\\(node_modules|oh_modules|\.git|\.hvigor|build)\\' -and
          $_.FullName -notlike '*\scripts\check-legacy-artifacts.ps1'
        }
    } else {
      $files = @(Get-Item $path)
    }

    $matches = $files | Select-String -Pattern $rule.Pattern -CaseSensitive:$false
    if (($matches | Measure-Object).Count -gt 0) {
      Write-Host "  Blocked pattern found: $($rule.Name)"
      foreach ($match in ($matches | Select-Object -First 8)) {
        $displayPath = Resolve-Path -Relative $match.Path
        Write-Host "    - ${displayPath}:$($match.LineNumber)"
      }
      $failed = $true
    }
  }
}

if ($failed) {
  Write-Host ''
  Write-Host 'Legacy artifact check failed.'
  exit 1
}

Write-Host '  No retired Mock / Java backend artifacts found in active runtime paths.'
Write-Host ''
Write-Host 'Legacy artifact check passed.'
