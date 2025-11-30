# OpenSCAD Flexible Connector Library & Configurator

**Intelligent five-phase parametric design system** for flexible tube assemblies with constraint-driven product routing, BOM generation, and comprehensive validation.

## Overview

This system enables automated design synthesis of flexible connector assemblies through a five-phase pipeline:

1. **Phase A:** Application Context Analysis (environment, material, certifications)
2. **Phase B:** Base Dimensions Framework (geometry validation, derived calculations)
3. **Phase C.1:** End Type Selection & Intelligent Routing (constraint-based connector selection)
4. **Phase C.2+D:** Product Assembly (3D geometry generation)
5. **Phase E:** Comprehensive Evaluation (4-block summary, manufacturing readiness)

### Core Features

- ✅ **Constraint-Compliant Routing:** Only coded connector types used (snelkoppeling, jacob, triclamp, bfm)
- ✅ **Five-Phase Pipeline:** Environment → Dimensions → Routing → Assembly → Evaluation
- ✅ **Multi-Application Support:** Industrial pneumatic, food-grade, medical device, pharmaceutical
- ✅ **Intelligent Filtering:** Systematic constraint validation across all phases
- ✅ **Material Database:** BFM Quick Reference with 11 product types, 21 helper functions
- ✅ **Connector Evaluation:** All 4 coded types tested; only viable options recommended
- ✅ **BOM Extraction:** Automated JSON/CSV generation from OpenSCAD echo output
- ✅ **Golden Snapshot Testing:** Reproducibility validation with epsilon tolerance
- ✅ **Multi-Platform CI:** Windows PowerShell + Linux Bash support
- ✅ **2D DXF Export:** Orthogonal projections for CAD verification

### Example: Medical Sterile Water System (Request FV-2025-1201-042)

**Customer Request:**
- Application: Sterile water delivery in surgical robot irrigation system
- Tube: 800mm × 12mm ID / 20mm OD (ISO 1452 medical standard)
- Material: Silicone medical-grade (transparent white)
- Connectors: Sanitary triclamp (T316L stainless steel)
- Operating: 0.107-0.33 bar pressure, 4-121°C (with 50× autoclave cycles)
- Certifications: FDA 21 CFR, ISO 13485, CE Class I

**Phase A Results:** ✅ PASSED (6 assertions)
- Material: silicone_medical (FDA-approved)
- Hygiene class: medical (FDA/ISO 13485)
- Sterilization: autoclave 121°C (50 cycles)
- Temperature profile: 4-121°C (extreme thermal cycling)

**Phase B Results:** ✅ PASSED (8 assertions)
- Cross-section area: 201.06 mm²
- Tube volume: 160.85 mL (minimal dead volume)
- Safety factor: 12.1× (exceeds medical minimum 10×)
- Connector: Triclamp 12mm (compatible)

**Phase C.1 Results:** ✅ PASSED (4 assertions)
Tested all 4 coded connector types:
- **snelkoppeling** (quick coupling): ~ NOT IDEAL (deadspace risk, thermal cycling concern)
- **jacob** (welding end): ✗ ELIMINATED (permanent connection, no reusability)
- **triclamp** (sanitary snap-fit): ✓ OPTIMAL (zero-deadspace, 50+ cycles, industry standard)
- **bfm** (spigot connections): ✗ ELIMINATED (minimum 100mm bore, incompatible with 12mm)

**Decision:** Triclamp selected (only viable option meeting all medical requirements)

## Prerequisites

- **OpenSCAD** 3.0+ (for rendering)
- **Python 3.x** (for BOM extraction & validation)
- **(Windows)** PowerShell 5.1+ or PowerShell 7+
- **(Linux/macOS)** Bash 4.0+

## Quick Start

### Windows (PowerShell)
```powershell
# Run all smoke tests
.\scripts\run_all.ps1

# Individual tests
.\scripts\run_default.ps1
.\scripts\run_edge.ps1
```

### Linux/macOS (Bash)
```bash
bash scripts/ci_smoke.sh
```

## Output Artifacts

Tests produce:
- `out/smoke_*.echo` — OpenSCAD console logs (5 phases of processing)
- `out/bom_*.jsonl` — Bill of Materials (JSON Lines format)
- `out/smoke_*.dxf` — 2D orthogonal projections for CAD
- `out/bom_*.csv` — BOM in CSV format (optional)

## Architecture

### Three-Layer System

1. **general/** — Shared five-phase implementation
   - `general_application_context.scad` (Phase A)
   - `general_base_dimensions.scad` (Phase B)
   - `general_end_type_selection.scad` (Phase C.1)
   - `general_evaluation.scad` (Phase E)

2. **lampe_*** — Product-specific (food-grade, medical connectors)
   - `lampe_parametric.scad` (entry point)
   - `lampe_assembly.scad` (Phase C.2+D)
   - `lampe_data.scad` (material/connector specs)

3. **bfm_*** — Product-specific (pneumatic/hydraulic industrial)
   - `bfm_parametric.scad` (entry point)
   - `bfm_assembly.scad` (Phase C.2+D)
   - `bfm_data.scad` (11 BFM products, 21 functions)

### Constraint Compliance

✅ **System operates ONLY within coded constraints:**
- 4 connector types: `snelkoppeling`, `jacob`, `triclamp`, `bfm`
- Material specs from `*_data.scad` files
- Dimensional ranges validated against LAMPE/BFM limits
- **No external solutions proposed** (e.g., ISO 6149, NPT, JIC not available)
- **Rejection with explanation** when no coded option satisfies constraints

## Design Decision Example: FV-2025-1201-042

### Why Not BFM?
```
Customer bore: 12mm
BFM minimum: 100mm
Result: ✗ SIZE INCOMPATIBLE (eliminated)
```

### Why Not Welding End (jacob)?
```
Customer requirement: Reusable (50 autoclave cycles)
jacob property: Permanent welding (no reusability)
Result: ✗ REUSABILITY INCOMPATIBLE (eliminated)
```

### Why Not Quick Coupling (snelkoppeling)?
```
Medical requirement: Minimal dead volume (endotoxin risk)
snelkoppeling deadspace: 2-5 mL
Thermal cycling: 50× at 121°C degrades standard seals
Result: ~ NOT IDEAL (technical issues with premium cost)
```

### Why Triclamp? ✓
```
Zero-deadspace: Sanitary design (pharmaceutical standard)
Sterilization: 50+ cycles (standard LAMPE product, no premium)
Material: T316L fully compatible with silicone
Temperature: Mechanical clamp accommodates thermal cycling
Industry: Standard in surgical irrigation systems
Result: ✓ OPTIMAL (all requirements met)
```

## Key Principles

1. **Constraint-Driven:** All decisions based on Phase A+B constraints, validated against 4 coded options
2. **Transparent:** Every filtering step documented with clear reasoning
3. **Fail-Fast:** Assertions validate constraints; violations block progression
4. **Cross-Phase Propagation:** Phase A outputs → Phase B constraints; Phase B outputs → Phase C.1 constraints
5. **No Invention:** Only options in code are considered; external solutions rejected
6. **Traceability:** Full BOM, certifications, testing requirements documented

## Testing & Validation

- **Smoke Tests:** `tests/smoke_filterslang_*.scad` + `tests/smoke_*_*.scad`
- **Golden Snapshots:** `tests/golden/bom_*.jsonl` (reference outputs)
- **BOM Comparison:** `scripts/bom_diff.py` (epsilon-tolerant validation)
- **DXF Projections:** 2D views for CAD verification

## Documentation

- `README_v3.md` — High-level system overview
- `FRONTEND_SPEC.md` — Configurator user interface
- `PHASE1_COMPLETE.md` — Phase 1 implementation notes
- `PHASE2_COMPLETE.md` — Phase 2 implementation notes
- `PHASE3_COMPLETE.md` — Phase 3 (routing engine) notes
- `PHASE_ENHANCEMENTS_SUMMARY.md` — Comprehensive Phase A-E enhancements
- `IMPLEMENTATION_INDEX.md` — Cross-reference guide
