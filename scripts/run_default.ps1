param(
  [string]$Product = "filterslang",
  [string]$Version = "1.0.0",
  [double]$Epsilon = 0.0005
)

$ErrorActionPreference = "Stop"
Set-Location -Path (Split-Path -Parent $PSCommandPath)
Set-Location ..

New-Item -ItemType Directory -Force .\out | Out-Null

Write-Host "==> Render DEFAULT .echo" -ForegroundColor Cyan
openscad.com -o ".\out\smoke_default.echo" ".\tests\smoke_filterslang_default.scad"

Write-Host "==> Render DEFAULT .dxf (2D projection)" -ForegroundColor Cyan
openscad.com -o ".\out\smoke_default.dxf" ".\tests\smoke_filterslang_default_dxf.scad"

Write-Host "==> Extract DEFAULT BOM -> JSONL en diff met golden" -ForegroundColor Cyan
$cmd = "python .\scripts\render_bom.py --product $Product --version $Version --echo .\out\smoke_default.echo --jsonl .\out\bom_default.jsonl"
Write-Host $cmd -ForegroundColor DarkGray
python ".\scripts\render_bom.py" --product $Product --version $Version `
  --echo ".\out\smoke_default.echo" --jsonl ".\out\bom_default.jsonl" `
| python ".\scripts\bom_diff.py" ".\tests\golden\bom_default.jsonl" --epsilon $Epsilon

if ($LASTEXITCODE -ne 0) { throw "DEFAULT diff failed (exit $LASTEXITCODE)" }

Write-Host "==> Verify DEFAULT .dxf exists" -ForegroundColor Cyan
if (!(Test-Path ".\out\smoke_default.dxf")) { throw "DXF file not generated" }

Write-Host "==> Produce DEFAULT BOM (JSONL → CSV/XLSX)" -ForegroundColor Cyan
python ".\scripts\bom_producer.py" --product $Product --version $Version `
  --jsonl ".\out\bom_default.jsonl" --parts ".\data\parts.csv" `
  --csv ".\out\bom_default_production.csv" --xlsx ".\out\bom_default_production.xlsx"

if ($LASTEXITCODE -ne 0) { throw "BOM production failed (exit $LASTEXITCODE)" }

Write-Host "==> OK: DEFAULT" -ForegroundColor Green
