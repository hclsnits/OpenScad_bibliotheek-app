# BFM Flexible Connector - Product Variant

## Overview

**BFM** (Banjo Fitting/Hydraulic/Modular) is the flexible connector variant optimized for industrial hydraulic and pneumatic applications.

## Application Characteristics

- **Working Pressure**: Max 280 bar (medium), 200 bar (large), 5 bar (small)
- **Temperature Range**: -40°C to +100°C
- **Certifications**: ISO 4401, ISO 6149, CE 2014/68/EU (PED), AD 2000
- **Sterilizable**: No
- **Applications**: Hydraulic systems, pneumatic lines, industrial fluid transfer

## Size Families

| Family | D_out Range | Max Pressure | Use Case |
|--------|------------|--------------|----------|
| Small | 10-25 mm | 5 bar | Low pressure circuits |
| Medium | 25-75 mm | 280 bar | Standard hydraulic |
| Large | 75-100 mm | 200 bar | High flow applications |

## Component Files

| File | Phase | Purpose |
|------|-------|---------|
| `bfm_parametric.scad` | Entry | User-facing configurator |
| `bfm_assembly.scad` | C.2+D | Assembly orchestrator |
| `bfm_connector.scad` | D | Main flexible tube |
| `bfm_spigot.scad` | D | Banjo-style end connection |
| `bfm_rings.scad` | D | Support rings (future) |
| `bfm_data.scad` | D | Material/pressure tables |
| `bfm_validation.scad` | E | BFM-specific checks |

## Materials

All BFM connectors support these materials with pressure/temperature limits:

| Material | Color | Max Pressure | Max Temp |
|----------|-------|--------------|----------|
| PU | [1.0, 1.0, 1.0, 0.15] | 280 bar | +100°C |
| Silicone | [0.8, 0.2, 0.2] | 210 bar | +120°C |
| EPDM | [0.2, 0.5, 0.2] | 160 bar | +140°C |
| PVC | [0.5, 0.5, 0.5] | 100 bar | +60°C |

## Usage

Create `bfm_configurator.scad`:

```scad
use <path/to/bfm_flexibele_verbinding/bfm_parametric.scad>;

// BFM defaults already set, customize if needed:
L_tube = 1000;
D_in = 45;
D_out = 55;
```

Render with:
```bash
openscad --viewall --render -o output.png bfm_configurator.scad
```

## Validation

BFM includes automatic validation of:
- Diameter range (10-100 mm)
- Length range (100-1500 mm)
- Working pressure limits per size family
- Wall thickness (2-8 mm)

## Status

**Status**: BFM variant production ready ✓
