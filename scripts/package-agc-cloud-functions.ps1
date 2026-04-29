param(
  [ValidateSet('layered', 'full', 'all')]
  [string]$Mode = 'layered',
  [string]$DateStamp = (Get-Date -Format 'yyyyMMdd')
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$cloudRoot = Join-Path $repoRoot 'cloud-functions'
$distRoot = Join-Path $repoRoot 'dist'
$manifestPath = Join-Path $cloudRoot 'function-manifest.json'
$nodeModulesPath = Join-Path $cloudRoot 'node_modules'
$stagingRoot = Join-Path $distRoot '.agc-package-staging'
$layerDir = Join-Path $distRoot 'agc-cloud-function-layers'
$layeredDir = Join-Path $distRoot 'agc-cloud-functions-layered'
$fullDir = Join-Path $distRoot 'agc-cloud-functions'

if (-not (Test-Path $manifestPath)) {
  throw "Function manifest not found: $manifestPath"
}

$distRootFull = [System.IO.Path]::GetFullPath($distRoot)

function Assert-UnderDist([string]$Path) {
  $fullPath = [System.IO.Path]::GetFullPath($Path)
  $distPrefix = $distRootFull.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
  if ($fullPath -ne $distPrefix -and -not $fullPath.StartsWith($distPrefix + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to modify path outside dist: $fullPath"
  }
}

function Reset-Directory([string]$Path) {
  Assert-UnderDist $Path
  if (Test-Path $Path) {
    Remove-Item -LiteralPath $Path -Recurse -Force
  }
  New-Item -ItemType Directory -Path $Path | Out-Null
}

function Copy-IfExists([string]$Source, [string]$Destination) {
  if (Test-Path $Source) {
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
  }
}

function Add-CommonFunctionFiles([string]$StageDir, [object]$FunctionEntry) {
  $domainDir = Join-Path $cloudRoot $FunctionEntry.domain
  if (-not (Test-Path $domainDir)) {
    throw "Function domain directory not found: $domainDir"
  }

  Copy-Item -LiteralPath (Join-Path $domainDir 'index.js') -Destination (Join-Path $StageDir 'index.js') -Force
  Copy-Item -LiteralPath (Join-Path $domainDir 'contract.json') -Destination (Join-Path $StageDir 'contract.json') -Force
  Copy-Item -LiteralPath (Join-Path $cloudRoot 'package.json') -Destination (Join-Path $StageDir 'package.json') -Force
  Copy-Item -LiteralPath (Join-Path $cloudRoot 'package-lock.json') -Destination (Join-Path $StageDir 'package-lock.json') -Force
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'cloud-env-loader.js') -Destination (Join-Path $StageDir 'cloud-env-loader.js') -Force
  Copy-Item -LiteralPath (Join-Path $cloudRoot 'README.md') -Destination (Join-Path $StageDir 'README-upload.md') -Force

  Copy-Item -LiteralPath (Join-Path $cloudRoot 'shared') -Destination (Join-Path $StageDir 'shared') -Recurse -Force
  Copy-Item -LiteralPath (Join-Path $cloudRoot 'cloud-db') -Destination (Join-Path $StageDir 'cloud-db') -Recurse -Force

  Get-ChildItem -Path (Join-Path $cloudRoot 'shared') -File | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $StageDir $_.Name) -Force
  }
  Copy-IfExists (Join-Path $cloudRoot 'cloud-db\schema.json') (Join-Path $StageDir 'schema.json')
  Copy-IfExists (Join-Path $cloudRoot 'cloud-db\seed-data.json') (Join-Path $StageDir 'seed-data.json')
}

function New-ZipFromDirectory([string]$SourceDir, [string]$ZipPath) {
  if (Test-Path $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
  }
  $children = Join-Path $SourceDir '*'
  $lastError = $null
  for ($attempt = 1; $attempt -le 5; $attempt++) {
    try {
      Compress-Archive -Path $children -DestinationPath $ZipPath -Force
      return
    } catch {
      $lastError = $_
      if (Test-Path $ZipPath) {
        Remove-Item -LiteralPath $ZipPath -Force
      }
      Start-Sleep -Milliseconds (400 * $attempt)
    }
  }
  throw $lastError
}

function New-DeploymentManifest([object]$Manifest, [string]$OutputPath, [string]$PackageMode) {
  $functions = @()
  foreach ($functionEntry in $Manifest.functions) {
    $functions += [pscustomobject]@{
      domain = $functionEntry.domain
      functionName = $functionEntry.functionName
      zip = "$($functionEntry.functionName).zip"
      entry = 'index.handler'
      runtime = 'Node.js'
      triggerType = 'HTTP'
      method = 'POST'
      suggestedTriggerIdentifier = "$($functionEntry.functionName)-`$latest"
      routePrefixes = $functionEntry.routePrefixes
      collections = $functionEntry.collections
    }
  }

  $deploymentManifest = [pscustomobject]@{
    generatedAt = (Get-Date).ToString('s')
    source = 'cloud-functions/function-manifest.json'
    packageMode = $PackageMode
    packageCount = $functions.Count
    commonEnvironment = [pscustomobject]@{
      SMARTGUARDIAN_CLOUD_DB_PROVIDER = 'agc'
      SMARTGUARDIAN_CLOUD_DB_ZONE = 'ClouddbDev'
      SMARTGUARDIAN_REGION = 'CN'
      SMARTGUARDIAN_PROJECT_CREDENTIAL_JSON_BASE64 = '<agc-apiclient-json-base64>'
      AGC_CLOUD_DB_ZONE = 'ClouddbDev'
      AGC_REGION = 'CN'
      SMARTGUARDIAN_LLM_PROVIDER = 'baiduqianfancodingplan'
      SMARTGUARDIAN_LLM_BASE_URL = 'https://qianfan.baidubce.com/v2/coding'
      SMARTGUARDIAN_LLM_MODEL = 'qianfan-code-latest'
      SMARTGUARDIAN_LLM_API_KEY = '<configure-in-agc-environment>'
      SMARTGUARDIAN_LLM_TIMEOUT_MS = '30000'
      SMARTGUARDIAN_LLM_DISABLED = 'false'
    }
    functions = $functions
  }

  $deploymentManifest | ConvertTo-Json -Depth 12 | Set-Content -Path $OutputPath -Encoding UTF8
}

function Write-LayeredReadme([string]$OutputPath) {
  @'
# SmartGuardian AGC Cloud Functions Layered Packages

Upload or refresh the dependency layer first:

- smartguardian-nodejs-deps-layer.zip

Then upload each smartguardian-*.zip package as the matching AGC Cloud Function.
Use entry: index.handler
Use trigger type: HTTP
Use method: POST

Common environment variables are listed in deployment-manifest.layered.json.
Do not put Server SDK private credentials or LLM API keys inside ZIP files.
'@ | Set-Content -Path $OutputPath -Encoding UTF8
}

function Write-RuntimeConfigTemplate([string]$OutputPath) {
  @'
# SmartGuardian runtime environment template
# Copy these values to AGC Cloud Function environment variables or secret configuration.
# Do not put real API keys or Server SDK credentials into the layer ZIP.

SMARTGUARDIAN_LLM_PROVIDER=baiduqianfancodingplan
SMARTGUARDIAN_LLM_BASE_URL=https://qianfan.baidubce.com/v2/coding
SMARTGUARDIAN_LLM_MODEL=qianfan-code-latest
SMARTGUARDIAN_LLM_API_KEY=<configure-in-agc-environment>
SMARTGUARDIAN_LLM_TIMEOUT_MS=30000
SMARTGUARDIAN_LLM_DISABLED=false
SMARTGUARDIAN_CLOUD_DB_PROVIDER=agc
SMARTGUARDIAN_REGION=CN
SMARTGUARDIAN_CLOUD_DB_ZONE=ClouddbDev
SMARTGUARDIAN_PROJECT_CREDENTIAL_JSON_BASE64=<agc-apiclient-json-base64>
'@ | Set-Content -Path $OutputPath -Encoding UTF8
}

function Build-LayerPackage() {
  Reset-Directory $layerDir
  $stageDir = Join-Path $stagingRoot 'layer'
  Reset-Directory $stageDir
  $nodejsDir = Join-Path $stageDir 'nodejs'
  New-Item -ItemType Directory -Path $nodejsDir | Out-Null
  Copy-Item -LiteralPath (Join-Path $cloudRoot 'package.json') -Destination (Join-Path $nodejsDir 'package.json') -Force
  Copy-Item -LiteralPath (Join-Path $cloudRoot 'package-lock.json') -Destination (Join-Path $nodejsDir 'package-lock.json') -Force
  Write-RuntimeConfigTemplate (Join-Path $nodejsDir 'smartguardian-runtime.env.example')
  if (Test-Path $nodeModulesPath) {
    Copy-Item -LiteralPath $nodeModulesPath -Destination (Join-Path $nodejsDir 'node_modules') -Recurse -Force
  } else {
    Write-Warning "node_modules not found under cloud-functions; layer package will only contain package files."
  }
  New-ZipFromDirectory $stageDir (Join-Path $layerDir 'smartguardian-nodejs-deps-layer.zip')
}

function Build-FunctionPackages([object]$Manifest, [string]$OutputDir, [bool]$IncludeNodeModules, [string]$PackageMode) {
  Reset-Directory $OutputDir
  foreach ($functionEntry in $Manifest.functions) {
    $stageDir = Join-Path $stagingRoot $functionEntry.functionName
    Reset-Directory $stageDir
    Add-CommonFunctionFiles $stageDir $functionEntry
    if ($IncludeNodeModules -and (Test-Path $nodeModulesPath)) {
      Copy-Item -LiteralPath $nodeModulesPath -Destination (Join-Path $stageDir 'node_modules') -Recurse -Force
    }
    New-ZipFromDirectory $stageDir (Join-Path $OutputDir "$($functionEntry.functionName).zip")
  }

  $manifestName = if ($PackageMode -eq 'layered') { 'deployment-manifest.layered.json' } else { 'deployment-manifest.json' }
  New-DeploymentManifest $Manifest (Join-Path $OutputDir $manifestName) $PackageMode
  Write-LayeredReadme (Join-Path $OutputDir 'README.md')
}

New-Item -ItemType Directory -Path $distRoot -Force | Out-Null
Reset-Directory $stagingRoot

$manifest = Get-Content -Path $manifestPath -Encoding UTF8 -Raw | ConvertFrom-Json

if ($Mode -eq 'layered' -or $Mode -eq 'all') {
  Build-LayerPackage
  Build-FunctionPackages $manifest $layeredDir $false 'layered'
  $bundlePath = Join-Path $distRoot "smartguardian-agc-cloud-functions-layered-$DateStamp.zip"
  New-ZipFromDirectory $layeredDir $bundlePath
}

if ($Mode -eq 'full' -or $Mode -eq 'all') {
  Build-FunctionPackages $manifest $fullDir $true 'full'
  $bundlePath = Join-Path $distRoot "smartguardian-agc-cloud-functions-$DateStamp.zip"
  New-ZipFromDirectory $fullDir $bundlePath
}

Reset-Directory $stagingRoot
Remove-Item -LiteralPath $stagingRoot -Recurse -Force

Write-Host ''
Write-Host 'AGC cloud function packages generated.'
Write-Host "  Mode: $Mode"
Write-Host "  Functions: $($manifest.functions.Count)"
Write-Host "  Dist: $distRoot"
