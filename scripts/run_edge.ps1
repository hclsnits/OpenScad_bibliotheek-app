param(
  [string]$Product = "filterslang",
  [string]$Version = "1.0.0",
  [double]$Epsilon = 0.0005
)

$ErrorActionPreference = "Stop"
Set-Location -Path (Split-Path -Parent $PSCommandPath)
Set-Location ..

New-Item -ItemType Directory -Force .\out | Out-Null

Write-Host "==> Render EDGE .echo" -ForegroundColor Cyan
openscad.com -o ".\out\smoke_edge.echo" ".\tests\smoke_filterslang_edgecases.scad"

Write-Host "==> Extract EDGE BOM -> JSONL en diff met golden" -ForegroundColor Cyan
python ".\scripts\render_bom.py" --product $Product --version $Version `
  --echo ".\out\smoke_edge.echo" --jsonl ".\out\bom_edge.jsonl" `
| python ".\scripts\bom_diff.py" ".\tests\golden\bom_edge.jsonl" --epsilon $Epsilon

if ($LASTEXITCODE -ne 0) { throw "EDGE diff failed (exit $LASTEXITCODE)" }

Write-Host "==> OK: EDGE" -ForegroundColor Green
