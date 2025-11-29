# LAMPE Flexible Connector - Product Variant

## Overview

**LAMPE** (Laboratory/Medical/Pharma Extensible) is the flexible connector variant optimized for laboratory, medical, and pharmaceutical applications.

## Application Characteristics

- **Working Pressure**: Max 10 bar
- **Temperature Range**: -20°C to +60°C
- **Certifications**: ISO 1402, ISO 6149
- **Sterilizable**: Yes
- **Applications**: Lab tubing, medical devices, pharma fluid transfer

## Component Files

| File | Phase | Purpose |
|------|-------|---------|
| `lampe_parametric.scad` | Entry | User-facing configurator with phase pipeline |
| `lampe_assembly.scad` | C.2+D | Assembly orchestrator |
| `lampe_hoofdmateriaal.scad` | D | Main flexible tube geometry |
| `lampe_snelkoppeling.scad` | D | Quick coupling end connector |
| `lampe_jacob.scad` | D | Jacob welding end connector |
| `lampe_triclamp.scad` | D | Tri-clamp sanitary coupling |

## Connector Types Supported

1. **Snelkoppeling** (Quick Coupling)
   - Male/female variants
   - Tool-free connection
   - Fast disconnect

2. **Jacob Welding End**
   - Permanent flange connection
   - External flange orientation
   - Diameter-proportional scaling
   - Stainless steel (optional: mild, powder coated)

3. **Tri-Clamp** (SMS/DIN 32676)
   - Sanitary application standard
   - 3-tab locking mechanism
   - Ferrule with sealing surface

## Usage

Create a new file `lampe_configurator.scad`:

```scad
use <path/to/lampe_flexibele_verbinding/lampe_parametric.scad>;

// Parameters override (optional)
L_tube = 750;
end_type_1 = "jacob";
end_type_2 = "triclamp";
```

Render with:
```bash
openscad --viewall --render -o output.png lampe_configurator.scad
```

## Color System

**Standard Materials:**
- PU (Polyurethaan): `[1.0, 1.0, 1.0, 0.15]` - Semi-transparent white
- Silicone: `[0.8, 0.2, 0.2]` - Red
- Rubber: `[0.2, 0.2, 0.2]` - Black
- EPDM: `[0.2, 0.5, 0.2]` - Green
- PVC: `[0.5, 0.5, 0.5]` - Grey

## Status

**Status**: LAMPE variant production ready ✓
