## OpenSCAD Filterslang Generator — BOM & Validation Pipeline

Parametric 3D filter sleeve generator in OpenSCAD with automated BOM extraction and golden snapshot validation.

### Features
- **Parametric 3D models** via OpenSCAD (15+ configurable parameters)
- **Automated BOM extraction** from OpenSCAD echo output → JSON/CSV
- **Golden snapshot testing** with configurable epsilon tolerance
- **Multi-platform CI** (Windows PowerShell + Linux Bash)
- **2D DXF export** for 2D projection verification

### Prerequisites
- **OpenSCAD** (3.0+)
- **Python 3.x**
- **(Windows)** PowerShell 5.1+ or PowerShell 7+

### Quick Start

#### Windows (PowerShell)
```powershell
# Run all smoke tests (default + edge cases)
.\scripts\run_all.ps1

# Or individual tests
.\scripts\run_default.ps1
.\scripts\run_edge.ps1
```

#### Linux/macOS (Bash)
```bash
bash scripts/ci_smoke.sh
```

### Output
Tests produce:
- `out/smoke_default.echo` & `out/smoke_edge.echo` — OpenSCAD console logs
- `out/bom_default.jsonl` & `out/bom_edge.jsonl` — Extracted Bill of Materials (JSON Lines)
- `out/smoke_default.dxf` & `out/smoke_edge.dxf` — 2D projections for CAD verification
