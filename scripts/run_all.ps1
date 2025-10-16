param(
  [string]$Product = "filterslang",
  [string]$Version = "1.0.0",
  [double]$Epsilon = 0.0005
)
$ErrorActionPreference = "Stop"

& "$PSScriptRoot\run_default.ps1" -Product $Product -Version $Version -Epsilon $Epsilon
& "$PSScriptRoot\run_edge.ps1"    -Product $Product -Version $Version -Epsilon $Epsilon

Write-Host "==> ALL OK" -ForegroundColor Green
