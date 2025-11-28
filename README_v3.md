# OpenSCAD Filterslang Generator — Parametric 3D + BOM + Configurator

Parametric 3D filter sleeve generator in OpenSCAD with automated BOM extraction, golden snapshot validation, and user-friendly configuration system.

## Features

✅ **Parametric 3D Models** — 15+ configurable parameters (length, diameter, thickness, closures, rings, reinforcement)  
✅ **Automated BOM Extraction** — OpenSCAD echo output → JSON/CSV/Excel with Part Numbers  
✅ **Golden Snapshot Testing** — Multi-platform CI with epsilon tolerance (0.0005mm)  
✅ **2D DXF Export** — Orthogonal projections for CAD verification  
✅ **User-Friendly Configurator** — YAML-based config system with material presets  
✅ **Production Ready** — Excel BOMs with calculated fields (surface area, cut length)  
✅ **Multi-Platform CI** — Windows PowerShell + Linux Bash pipelines

## Quick Start

### 1. Run Smoke Tests (Phase 1 — Validation)

**Windows:**
```powershell
.\scripts\run_default.ps1
```

**Linux/macOS:**
```bash
bash scripts/ci_smoke.sh
```

### 2. Generate Models from Configuration (Phase 3 — Configurator)

```bash
python scripts/generate_model.py \
  --config configs/example_pe500_medium.yaml \
  --presets products/filterslang/presets.yaml \
  --output-dir out/my_model
```

**Output:** `.scad`, `.echo`, `.jsonl`, `.csv`, `.xlsx`, `.dxf` files

### 3. View Production BOM

```
out/my_model/
├── PE500_Medium_Standard_bom.xlsx       # Production BOM (Excel)
├── PE500_Medium_Standard_bom.csv        # ERP format (CSV)
├── PE500_Medium_Standard_bom.jsonl      # Technical BOM (JSON Lines)
├── PE500_Medium_Standard.dxf            # 2D Projection for CAD
└── PE500_Medium_Standard.scad           # Generated OpenSCAD file
```

## Prerequisites

- **OpenSCAD** 3.0+ ([download](https://openscad.org/downloads.html))
- **Python** 3.8+
- **venv** (virtual environment)

**Optional:**
- CAD viewer (LibreCAD, AutoCAD, Inkscape) for DXF files
- Excel for XLSX BOM review

## Installation

```bash
# Clone repo
git clone <repo-url>
cd OpenScad_bibliotheek-app

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate  # or `.venv\Scripts\activate` on Windows

# Install dependencies
pip install -r requirements.txt
```

## Configuration System (Phase 3)

### Example: PE500 Medium Filter

```yaml
name: "PE500_Medium_Standard"
preset: "PE_500"

overrides:
  L: 2000        # Length (mm)
  D: 160         # Diameter (mm)
  t: 2.0         # Thickness (mm)
  top: "snapring"
  bottom: "platdicht"
  rings_count: 6
  reinforce_enable: true
```

### Presets Available

| Preset | Material | Diameter | Length | Thickness | Sizes |
|--------|----------|----------|--------|-----------|-------|
| PE_500 | Polyethylene | 60–400 mm | 300–4000 mm | 1.2–3.0 mm | S/M/L |
| PPS_550 | Polyphenylene Sulfide | 80–350 mm | 500–3500 mm | 1.5–2.5 mm | S/M/L |

See [`CONFIGURATOR_USAGE.md`](CONFIGURATOR_USAGE.md) for complete documentation.

## Project Structure

```
├── products/filterslang/          # Filterslang product definition
│   ├── filterslang.scad           # Parametric 3D model (15+ params)
│   ├── presets.yaml               # Material presets (PE_500, PPS_550)
│   ├── config_schema.json         # Config validation schema
│   ├── manifest.toml              # Product metadata
│   └── schema.json                # Parameter schema
├── lib/core/                      # Shared utility libraries
│   ├── core.scad                  # Enums, validation, BOM output
│   └── geom.scad                  # Geometry modules (tubes, rings)
├── scripts/                       # Python orchestration
│   ├── generate_model.py          # [Phase 3] Config → SCAD → Render → BOM → DXF
│   ├── config_to_params.py        # [Phase 3] Parse YAML config → JSON params
│   ├── render_bom.py              # [Phase 1] Echo → JSONL/CSV
│   ├── bom_producer.py            # [Phase 2] JSONL → CSV/XLSX with Part Numbers
│   ├── bom_diff.py                # Compare BOM against golden snapshot
│   └── ci_smoke.sh                # Linux: Smoke test pipeline
├── tests/                         # Smoke test definitions
│   ├── smoke_filterslang_default.scad
│   ├── smoke_filterslang_edgecases.scad
│   ├── smoke_filterslang_default_dxf.scad
│   ├── smoke_filterslang_edgecases_dxf.scad
│   └── golden/                    # Golden reference snapshots
│       ├── bom_default.jsonl
│       └── bom_edge.jsonl
├── configs/                       # [Phase 3] Example configurations
│   ├── example_pe500_medium.yaml
│   ├── example_pe500_large.yaml
│   ├── example_pps550_compact.yaml
│   └── example_custom_minimal.yaml
├── data/                          # Part catalog
│   └── parts.csv                  # Enum → Part Number mappings
├── CONFIGURATOR_USAGE.md          # Phase 3 configuration guide
└── README.md                      # This file
```

## Phase Completion

### ✅ Phase 1: Parametric Library + Testing
- 15+ parameter filterslang module
- Smoke tests (default + edge cases)
- BOM extraction pipeline (echo → JSONL)
- Golden snapshot validation
- 2D DXF export

### ✅ Phase 2: BOM Producer + Part Catalog
- Parts catalog (22 entries)
- BOM producer (JSONL → CSV/XLSX)
- Calculated fields (surface area, cut length)
- Excel formatting

### ✅ Phase 3: User Configurator MVP
- Preset system (PE_500, PPS_550)
- YAML config parser
- Config validation (JSON Schema)
- Orchestration pipeline
- 4 example configurations (all tested ✓)

## Testing

### Smoke Tests

```bash
# Linux
bash scripts/ci_smoke.sh

# Windows
.\scripts\run_all.ps1
```

### Configurator Tests

```bash
# Generate all example models
for cfg in configs/example_*.yaml; do
  python scripts/generate_model.py \
    --config "$cfg" \
    --presets products/filterslang/presets.yaml \
    --output-dir "out/test_$(basename $cfg .yaml)"
done
```

## Status

| Feature | Phase | Status |
|---------|-------|--------|
| Parametric geometry | 1 | ✅ Complete |
| Golden validation | 1 | ✅ Complete |
| DXF export | 1 | ✅ Complete |
| BOM extraction | 1 | ✅ Complete |
| Part catalog | 2 | ✅ Complete |
| BOM producer | 2 | ✅ Complete |
| Excel export | 2 | ✅ Complete |
| Preset system | 3 | ✅ Complete |
| Config parser | 3 | ✅ Complete |
| Configurator MVP | 3 | ✅ Complete |

## Documentation

- **Configurator Guide** → `CONFIGURATOR_USAGE.md`
- **Filterslang Details** → `docs/filterslang.md`
- **Copilot Instructions** → `.github/copilot-instructions.md`
