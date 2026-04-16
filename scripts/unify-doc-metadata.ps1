$files = Get-ChildItem -Path "E:\hm-demo\SmartGuardian\docs" -Recurse -Filter *.md
foreach ($f in $files) {
  $c = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $n = $c -replace '(>\s*版本：)V\d+\.\d+', '$1V1.2'
  $n = $n -replace '(\*\*版本\*\*：)V\d+\.\d+', '$1V1.2'
  if ($n -ne $c) {
    Set-Content -LiteralPath $f.FullName -Value $n -Encoding UTF8
  }
}
