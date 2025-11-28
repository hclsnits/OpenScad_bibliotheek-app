# Filterslang Configurator — Phase 3

## Quick Start

Generate a filter model from configuration:

```bash
python scripts/generate_model.py \
  --config configs/example_pe500_medium.yaml \
  --presets products/filterslang/presets.yaml \
  --output-dir out/my_model
```

## What You Get

```
out/my_model/
├── PE500_Medium_Standard.scad           # Generated OpenSCAD file
├── PE500_Medium_Standard.echo           # OpenSCAD console output
├── PE500_Medium_Standard_bom.jsonl      # Technical BOM (JSON Lines)
├── PE500_Medium_Standard_bom.csv        # ERP/Production BOM (CSV)
├── PE500_Medium_Standard_bom_production.xlsx  # Production BOM (Excel)
└── PE500_Medium_Standard.dxf            # 2D Projection (DXF for CAD)
```

## Configuration Files

### Example Configurations

- `configs/example_pe500_medium.yaml` — Standard production filter (L=2000mm, D=160mm)
- `configs/example_pe500_large.yaml` — Industrial large filter (L=3500mm, D=250mm)
- `configs/example_pps550_compact.yaml` — High-temp compact (L=800mm, D=120mm)
- `configs/example_custom_minimal.yaml` — Minimal custom configuration

### Creating Your Own Config

```yaml
name: "MyFilter_001"
preset: "PE_500"  # or "PPS_550"

overrides:
  L: 1500          # Length (mm)
  D: 140           # Diameter (mm)
  t: 1.8           # Thickness (mm)
  top: "snapring"  # or klemband, kopring, etc.
  bottom: "enkel"  # or dubbel, platdicht
  rings_count: 5   # Number of reinforcement rings
```

### Preset Options

**PE_500** (Polyethylene, 500 g/m²):
- Diameter range: 60–400 mm
- Length range: 300–4000 mm
- Thickness: 1.2–3.0 mm
- Sizes: Small (D=100, L=1000), Medium (D=160, L=2000), Large (D=250, L=3500)

**PPS_550** (Polyphenylene Sulfide, 550 g/m²):
- Diameter range: 80–350 mm
- Length range: 500–3500 mm
- Thickness: 1.5–2.5 mm
- Sizes: Small (D=120, L=1200), Medium (D=180, L=2500), Large (D=280, L=3200)

## Pipeline Steps

The `generate_model.py` script executes 5 steps:

1. **Parse Config** → Validates YAML, applies preset defaults, merges overrides
2. **Generate SCAD** → Creates OpenSCAD file from Jinja2 template
3. **Render** → Runs OpenSCAD to generate geometry and BOM output
4. **Extract BOM** → Parses echo file, exports technical + production formats
5. **Generate DXF** → Creates 2D projection for CAD verification

## Options

```
--config PATH              Config YAML file (required)
--presets PATH             Presets YAML file (required)
--output-dir DIR           Output directory (default: out)
--skip-render              Skip OpenSCAD rendering (debug mode)
--skip-bom                 Skip BOM extraction
--skip-dxf                 Skip DXF export
--debug                    Print verbose debug output
```

## Examples

### Standard Production

```bash
python scripts/generate_model.py \
  --config configs/example_pe500_medium.yaml \
  --presets products/filterslang/presets.yaml \
  --output-dir out/PE500_Standard_Batch_001
```

### Skip DXF (faster for batch generation)

```bash
python scripts/generate_model.py \
  --config configs/example_pe500_large.yaml \
  --presets products/filterslang/presets.yaml \
  --output-dir out/PE500_Large \
  --skip-dxf
```

### Debug Mode (see all subprocess commands and paths)

```bash
python scripts/generate_model.py \
  --config configs/example_pe500_medium.yaml \
  --presets products/filterslang/presets.yaml \
  --output-dir out/debug \
  --debug
```

## Output Files

### JSONL (Technical BOM)
- Key-value pairs: L, D, t, medium, top, bottom, rings, reinforcement, etc.
- For integration with parameterization pipelines
- Format: One JSON object per line (JSON Lines)

### CSV (ERP Integration)
- Column-delimited format
- Includes Part Numbers from `data/parts.csv`
- Ready for procurement systems

### XLSX (Production BOM)
- Formatted Excel workbook
- Colored headers, auto-sized columns
- Calculated fields: surface area (m²), cut length (m)
- Part supplier information included

### DXF (CAD Verification)
- 2D orthogonal projection (`projection(cut=false)`)
- Openable in LibreCAD, AutoCAD, Inkscape, etc.
- Verifies geometric correctness before manufacturing

## Troubleshooting

### "Can't open library" errors

Ensure you run from the project root:
```bash
cd /path/to/OpenScad_bibliotheek-app
python scripts/generate_model.py ...
```

The script generates temporary `.scad` files in the project root for OpenSCAD library resolution, then cleans them up.

### BOM extraction fails

Check the `.echo` file for OpenSCAD errors:
```bash
cat out/mymodel/*.echo | head -20
```

If no `BOM_ITEM` records found, OpenSCAD rendering may have failed silently.

### Configuration validation errors

Check the config file against the schema:
```bash
python scripts/config_to_params.py \
  --config configs/myconfig.yaml \
  --presets products/filterslang/presets.yaml \
  --debug
```

## Integration with CI/CD

Add to GitHub Actions for automated model generation:

```yaml
- name: Generate filterslang models
  run: |
    for cfg in configs/example_*.yaml; do
      python scripts/generate_model.py \
        --config "$cfg" \
        --presets products/filterslang/presets.yaml \
        --output-dir "out/$(basename $cfg .yaml)" \
        --skip-dxf
    done

- name: Upload BOM artifacts
  uses: actions/upload-artifact@v2
  with:
    name: BOMs
    path: out/*/*.xlsx
```

## Technical Details

### Library Path Resolution

OpenSCAD resolves `use <>` imports relative to the file being rendered. The configurator:
1. Generates `.scad` files in the project root (where `products/filterslang/` is accessible)
2. Tells OpenSCAD to write output (`.echo`, `.dxf`) to the target `--output-dir`
3. Cleans up temporary `.scad` files after successful render

### Parametric Model

The `filterslang()` module accepts 15+ parameters:

| Parameter | Type | Example |
|-----------|------|---------|
| L | number | 2000 (mm) |
| D | number | 160 (mm) |
| t | number | 2.0 (mm) |
| medium | string | "PE_500" |
| top | enum | "snapring" |
| bottom | enum | "platdicht" |
| bottom_opt | enum | "zoom" (conditional) |
| rings_auto | bool | true |
| rings_count | int | 6 |
| ring_w, ring_t | number | 10, 2 (mm) |
| reinforce_enable | bool | true |
| reinforce_side | enum | "boven" |
| reinforce_spans | array | [[100, 200]] (mm intervals) |
| productzijde | enum | "buiten" |
| bom_tag | string | "PE500_Medium_Standard" |

### Validation

Configurations are validated against:
1. **Schema** (`products/filterslang/config_schema.json`) — JSON Schema validation
2. **Presets** (`products/filterslang/presets.yaml`) — Range constraints, enum constraints
3. **OpenSCAD** — Module parameter validation via `assert()` statements
