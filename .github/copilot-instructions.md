# OpenSCAD Bibliotheek App — Copilot Instructions

## Project Overview

This is a parametric **filter sleeve (filterslang) generator** in OpenSCAD with a Python-based BOM (Bill of Materials) extraction and validation pipeline. The system:

1. **Generates 3D models** via OpenSCAD using parametric modules
2. **Extracts BOMs** from OpenSCAD echo output to JSON/CSV
3. **Validates against golden snapshots** to ensure reproducible results
4. **Exports 2D projections** as DXF for CAD verification
5. **Supports multi-platform CI** (Windows PowerShell & Linux)

## Architecture & Key Components

### 1. **OpenSCAD Core Library** (`lib/core/`)
- **`core.scad`**: Enum validation functions, BOM echo utility, helper functions
- **`geom.scad`**: Base geometry modules (e.g., `tube_len()` for hollow cylinders)
- Pattern: Helper functions prefixed with `_` (private), modules unprefixed (public)
- Enums validated via `_enum_*_valid()` functions; assertions enforce constraints

### 2. **Product Definition** (`products/filterslang/`)
- **`filterslang.scad`**: Main parametric module with 15+ parameters (L, D, t, top, bottom, rings, reinforcement, etc.)
- **`manifest.toml`**: Product metadata (name, version, units, BOM schema, enum mappings)
- **`schema.json`**: JSON Schema defining parameter types, ranges, conditional validation (e.g., `bottom_opt` depends on `bottom` type)
- BOM output uses `_bom_echo(tag, [key, value, key, value, ...])` pattern (alternating key-value pairs)

### 3. **BOM Extraction & Validation**
- **`scripts/render_bom.py`**: Parses OpenSCAD `.echo` output (console logs), extracts `BOM_ITEM` records, outputs JSONL (JSON Lines) and optionally CSV
  - Robust line-by-line parser + regex fallbacks for malformed OpenSCAD output
  - Supports three echo formats (console, quoted, unquoted)
  - Key parameters auto-mapped to JSON keys from alternating array structure
- **`scripts/bom_diff.py`**: Compares current JSONL against golden snapshot with configurable epsilon tolerance (default 0.0005)
  - Numeric fields compared with floating-point tolerance
  - Supports arrays, dicts, strings; BOM-tolerant UTF-8 parsing
  - Exit code 0 on match, 1 on diff

### 4. **2D Export & Verification**
- **`tests/smoke_filterslang_default_dxf.scad`** & **`tests/smoke_filterslang_edgecases_dxf.scad`**: 2D projections wrapped in `projection(cut=false)` for DXF export
- Generated `.dxf` files validate parametric geometry from multiple viewpoints
- DXF files can be opened in standard CAD tools (LibreCAD, AutoCAD, Inkscape)

### 5. **Testing & CI**
- **Smoke tests**: `tests/smoke_filterslang_default.scad` and `tests/smoke_filterslang_edgecases.scad`
  - Call `filterslang()` with fixed parameters to test common and edge configurations
  - Render to `.echo` files in `out/`
- **2D Projection tests**: `tests/smoke_filterslang_default_dxf.scad` and `tests/smoke_filterslang_edgecases_dxf.scad`
  - Wrapped in `projection(cut=false)` for orthogonal 2D view
  - Export as `.dxf` for CAD verification
- **Golden snapshots**: `tests/golden/bom_default.jsonl`, `tests/golden/bom_edge.jsonl`
  - Reference outputs; BOM assertions compare new runs against these
- **CI workflow** (`github/workflows/ci.yml`): Multi-platform (Windows + Ubuntu)
  - Installs OpenSCAD via Chocolatey (Windows) or apt (Ubuntu)
  - Runs smoke tests, extracts BOMs, renders DXF projections
  - Compares BOMs with golden files
  - Uploads artifacts (JSONL + DXF) for each platform
  - PowerShell for cross-platform path handling

## Critical Workflows & Commands

### Local Development (Windows PowerShell)

**Full smoke test cycle:**
```powershell
# Render default test to .echo
openscad.com -o .\out\smoke_default.echo "tests\smoke_filterslang_default.scad"

# Extract BOM and compare with golden
python .\scripts\render_bom.py --product filterslang --version 1.0.0 `
  --echo .\out\smoke_default.echo --jsonl .\out\bom_default.jsonl `
| python .\scripts\bom_diff.py .\tests\golden\bom_default.jsonl --epsilon 0.0005
```

**Run all tests** (see `scripts/run_all.ps1`):
- Default test → `bom_default.jsonl` → compare golden
- Edge cases test → `bom_edge.jsonl` → compare golden
- Exit 0 if all match, 1 if any diff

### Key Parameters for filterslang()

| Param | Type | Constraints | Purpose |
|-------|------|-------------|---------|
| `L`, `D`, `t` | number | > 0 | Length, outer diameter, wall thickness |
| `top` | enum | 8 values (snapring, kopring, etc.) | Top closure style |
| `bottom` | enum | enkel/dubbel/platdicht | Bottom type |
| `bottom_opt` | enum | Depends on `bottom` | Bottom sub-option |
| `rings_auto` | bool | — | Auto-distribute rings or manual positions |
| `rings_count` | int | ≥ 0 | Count if `rings_auto=true` |
| `ring_w`, `ring_t` | number | > 0 | Ring width & thickness |
| `reinforce_enable` | bool | — | Enable reinforcement strips |
| `reinforce_side` | enum | boven/onder | Reinforcement placement |
| `reinforce_spans` | array<[num, num]> | positions 0 < x < L | Reinforcement intervals |
| `productzijde` | enum | buiten/binnen | Material side orientation |

## Project-Specific Conventions

1. **BOM Output Format**: OpenSCAD modules call `_bom_echo(tag, [key, val, key, val, ...])` with alternating key-value pairs (not JSON objects—simpler parsing)

2. **File Organization**:
   - `lib/core/` = reusable utilities & enums
   - `products/X/` = per-product implementation + metadata
   - `scripts/` = Python extraction/validation tools
   - `tests/` = smoke test `.scad` files + golden snapshots
   - `out/` = build artifacts (`.echo`, `.jsonl`, `.csv`)

3. **Enum Validation**: Functions like `_enum_bottom_opt_valid()` enforce conditional enums; manifests define valid values

4. **Echo Parsing**: `render_bom.py` is defensive—expects malformed OpenSCAD console output; tries line-by-line, then regex fallbacks

5. **Golden Snapshot Workflow**: Update `tests/golden/*.jsonl` only after manual verification of BOM changes; CI enforces these as immutable references

## Cross-Component Communication

- **OpenSCAD → Python**: Modules emit `BOM_ITEM` records to console; render output captured as `.echo`
- **Python → Python**: `render_bom.py` outputs JSONL to stdout (piped to `bom_diff.py`) and optionally writes files
- **CI Glue**: PowerShell scripts orchestrate OpenSCAD rendering, Python extraction, and validation in sequence
- **Configuration**: `manifest.toml` metadata (product name, BOM keys, enums) drives parser and CSV column ordering

## Development Tips

- **Debugging echo parsing**: Use `render_bom.py --debug` to see first 400 chars of input
- **Validate parameters**: Add `assert()` in `filterslang()` early; test edge cases via `smoke_*_edgecases.scad`
- **Update golden files**: Only after manual inspection; ensure parametric geometry changes are intentional
- **Test locally before push**: Run full smoke suite locally; CI validates on both platforms
- **Epsilon tolerance**: Numeric floating-point diffs allowed up to 0.0005mm; adjust if geometry precision changes

