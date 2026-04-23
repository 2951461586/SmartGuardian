param(
  [string]$JavaHome = 'D:\software\java17',
  [string]$DbUrl = 'jdbc:mysql://127.0.0.1:3306/smartguardian?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true',
  [string]$DbUsername = 'smartguardian',
  [string]$DbPassword = 'smartguardian123',
  [string]$JwtSecret = 'smartguardian-local-jwt-secret-2026-safe'
)

$javaExe = Join-Path $JavaHome 'bin\java.exe'
if (-not (Test-Path $javaExe)) {
  throw "JDK 17 not found: $javaExe"
}

$env:JAVA_HOME = $JavaHome
$env:Path = (Join-Path $JavaHome 'bin') + ';' + $env:Path
$env:DB_URL = $DbUrl
$env:DB_USERNAME = $DbUsername
$env:DB_PASSWORD = $DbPassword
$env:JWT_SECRET = $JwtSecret

Write-Host "JAVA_HOME=$env:JAVA_HOME"
Write-Host "DB_URL=$env:DB_URL"

mvn -DskipTests package
