# Fase 1 — Completion Status

## ✅ FASE 1 GEREED — Library "feature-complete"

### Acceptatiecriteria - Allemaal voltooid:

- ✅ **Schema v1.0 + validatie** — `schema.json` met conditionale validatie; `render_bom.py` enforceert vereisten
- ✅ **Parametrische geometrie** — `filterslang()` module met 15+ parameters (tops, bodems, ringen, versterking, etc.)
- ✅ **2D export (DXF)** — `projection()` + test files `smoke_filterslang_*_dxf.scad`
- ✅ **Rooktest-matrix** — `smoke_filterslang_default.scad` + `smoke_filterslang_edgecases.scad`
- ✅ **Golden snapshots** — `tests/golden/bom_default.jsonl` + `bom_edge.jsonl`
- ✅ **CI artefacts** — Workflow uploads `.jsonl` + `.dxf` naar artifacts

### Implementatiedetails:

#### 1. DXF-export modules
- **`tests/smoke_filterslang_default_dxf.scad`** — 2D projection van default parameters
- **`tests/smoke_filterslang_edgecases_dxf.scad`** — 2D projection van edge cases
- Beide gebruiken `projection(cut=false)` voor orthogonale 2D export

#### 2. Run-scripts uitgebreid
- **`scripts/run_default.ps1`** — Renders `.echo` + `.dxf`, extraheert BOM, valideert golden, verifyeert DXF bestaat
- **`scripts/run_edge.ps1`** — Idem voor edge cases
- **`scripts/run_all.ps1`** — Roept beide aan in volgorde
- **`scripts/ci_smoke.sh`** — Linux/macOS equivalent (bash)

#### 3. CI Workflow uitgebreid (`github/workflows/ci.yml`)
- Rendert DXF projecties voor default + edge cases
- Fixt typo in edge-case versienummer (was `1.0s.0`)
- Upload artifacts: `out/*.jsonl` + `out/*.dxf` per platform

#### 4. Documentatie
- **`README.md`** — Geupdate met features, quick start commands, output beschrijving
- **`.github/copilot-instructions.md`** — Uitgebreid met 2D export info, DXF test files

---

## Project Status Summary

| Onderdeel | Status |
|-----------|--------|
| **Parametrische geometrie** | ✅ Compleet (15+ parameters) |
| **BOM extraction** | ✅ Compleet (JSONL + CSV) |
| **Golden snapshot validation** | ✅ Compleet (epsilon tolerance) |
| **2D DXF export** | ✅ Compleet |
| **Smoke test suite** | ✅ Compleet (default + edge) |
| **Multi-platform CI** | ✅ Compleet (Windows + Linux) |
| **Artifact upload** | ✅ Compleet (JSONL + DXF) |

---

## Volgende stappen (Fase 2+)

### Fase 2 — BOM-producer & stuklijst-integratie
- CSV kolommen normaliseren (materiaalcode, ringcount, etc.)
- `data/parts.csv` mapping (enums → artikelnummers)
- BOM exporter (JSONL → CSV/Excel)

### Fase 3 — Configurator (MVP)
- CLI: `configs/filterslang.yaml` → `.scad` + BOM
- Preset-sets per medium (PE_500, PPS_550)

### Fase 4 — Kwaliteit & performance
- `$fn` strategie (snelle tests vs productie)
- Self-checks in OpenSCAD (verboden combinaties)

### Fase 5 — Developer experience
- Extended README
- Cookbook
- UTF-8 normalisatie script

---

## Local Testing (Windows)

```powershell
# Run all tests
.\scripts\run_all.ps1

# Or use individual scripts
.\scripts\run_default.ps1   # Default parameters
.\scripts\run_edge.ps1      # Edge cases
```

## Local Testing (Linux/macOS)

```bash
bash scripts/ci_smoke.sh
```

## Check Artifacts

After running tests, check:
```bash
ls -lh out/
# smoke_default.echo   — OpenSCAD console output
# bom_default.jsonl    — Extracted BOM
# smoke_default.dxf    — 2D projection
# (same for edge cases with "_edge" suffix)
```

---

## Files Modified/Created

### Created
- `tests/smoke_filterslang_default_dxf.scad`
- `tests/smoke_filterslang_edgecases_dxf.scad`

### Modified
- `scripts/run_default.ps1` — Added DXF render + verify
- `scripts/run_edge.ps1` — Added DXF render + verify
- `scripts/ci_smoke.sh` — Rewritten for full pipeline
- `github/workflows/ci.yml` — Added DXF render + fixed typo + extended artifacts
- `README.md` — Updated with full feature list
- `.github/copilot-instructions.md` — Added 2D export docs

