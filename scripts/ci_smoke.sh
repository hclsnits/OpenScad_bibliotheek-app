#!/usr/bin/env bash
set -euo pipefail


openscad -o /dev/null tests/smoke_filterslang_default.scad 2>&1 | tee /tmp/bom_default.txt
python3 scripts/render_bom.py tests/smoke_filterslang_default.scad > /tmp/bom_default.jsonl
# TODO: diff tegen tests/golden/bom_default.jsonl
echo "Smoke OK"