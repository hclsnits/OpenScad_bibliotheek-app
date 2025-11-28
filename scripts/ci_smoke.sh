#!/usr/bin/env bash
set -euo pipefail

PRODUCT="${1:-filterslang}"
VERSION="${2:-1.0.0}"
EPSILON="${3:-0.0005}"

echo "==> Creating out folder"
mkdir -p out

echo "==> Render DEFAULT .echo"
openscad -o out/smoke_default.echo tests/smoke_filterslang_default.scad

echo "==> Render DEFAULT .dxf (2D projection)"
openscad -o out/smoke_default.dxf tests/smoke_filterslang_default_dxf.scad

echo "==> Extract DEFAULT BOM and compare with golden"
python3 scripts/render_bom.py --product "$PRODUCT" --version "$VERSION" \
  --echo out/smoke_default.echo --jsonl out/bom_default.jsonl \
| python3 scripts/bom_diff.py tests/golden/bom_default.jsonl --epsilon "$EPSILON"

if [ ! -f out/smoke_default.dxf ]; then
  echo "ERROR: DXF file not generated"
  exit 1
fi

echo "==> Produce DEFAULT BOM (JSONL → CSV/XLSX)"
python3 scripts/bom_producer.py \
  --jsonl out/bom_default.jsonl \
  --parts data/parts.csv \
  --csv out/bom_default_production.csv \
  --xlsx out/bom_default_production.xlsx

echo "==> OK: DEFAULT"

echo "==> Render EDGE .echo"
openscad -o out/smoke_edge.echo tests/smoke_filterslang_edgecases.scad

echo "==> Render EDGE .dxf (2D projection)"
openscad -o out/smoke_edge.dxf tests/smoke_filterslang_edgecases_dxf.scad

echo "==> Extract EDGE BOM and compare with golden"
python3 scripts/render_bom.py --product "$PRODUCT" --version "$VERSION" \
  --echo out/smoke_edge.echo --jsonl out/bom_edge.jsonl \
| python3 scripts/bom_diff.py tests/golden/bom_edge.jsonl --epsilon "$EPSILON"

if [ ! -f out/smoke_edge.dxf ]; then
  echo "ERROR: DXF file not generated"
  exit 1
fi

echo "==> Produce EDGE BOM (JSONL → CSV/XLSX)"
python3 scripts/bom_producer.py \
  --jsonl out/bom_edge.jsonl \
  --parts data/parts.csv \
  --csv out/bom_edge_production.csv \
  --xlsx out/bom_edge_production.xlsx

echo "==> OK: EDGE"
echo "==> ALL OK"