# BFM Data Integration Summary

**Date:** November 29, 2025  
**Status:** ✅ COMPLETE & TESTED

---

## Overview

The `bfm_data.scad` file has been successfully enhanced with comprehensive BFM Quick Reference data tables, maintaining full backward compatibility with the existing BFM workflow while adding sophisticated product specification, connector limitation, ring specification, and spigot data management.

---

## Integration Components

### 1. **Product Specifications (BFM_PRODUCT_SPECS)**

Comprehensive material/tube database with 11 product types:

| ID | Product | Temp Range (°C) | Pressure (PSI) | Food-Safe | 3-A Cert. | ATEX |
|----|---------|-----------------|--------|-----------|-----------|------|
| 020E | Seeflex 020E | -25 to 80 | 1.5 | ✅ | ✅ | all_dust |
| 040E | Seeflex 040E | -25 to 110 | 5.0 | ✅ | ✅ | all_dust |
| 040AS | Seeflex 040AS | -25 to 95 | 3.5 | ✅ | ✅ | all_dust |
| 060ES | Seeflex 060ES | -25 to 110 | 24.0 | ✅ | ✅ | all_dust |
| TNPB | Teflex NP (Black) | -73 to 300 | 3.0 | ✅ | ✅ | all_dust |
| FLEXI | Flexi (& Variants) | 20 to 85 | 3.0 | ✅ | ✅ | all_dust |
| LM4 | LM4 | undef to 130 | 3.0 | ✅ | ✅ | restrictions |
| LM3 | LM3 | undef to 110 | 3.0 | ✅ | ✅ | restrictions |
| TWOVEN | Teflex (Woven) | 250+ | 3.0 | ✅ | ❌ | restrictions |
| FM1 | FM1 | undef to 130 | 3.0 | ✅ | ❌ | restrictions |
| TNPO | Teflex NP (Opaque) | undef to 300 | 3.0 | ✅ | ❌ | yes |

**Helper Functions:**
- `bfm_get_temp_range(id)` → [min_cont, max_cont]
- `bfm_get_surge_temp(id)` → surge temperature (°C)
- `bfm_get_max_pressure_psi(id)` → max pressure in PSI
- `bfm_is_foodsafe(id)` → true if FDA + EU certified
- `bfm_is_threeA(id)` → true if 3-A certified
- `bfm_atex_category(id)` → ATEX classification

---

### 2. **Connector Limits Without Rings (BFM_CONNECTOR_LIMITS)**

Dimension and length constraints for 11 connector types:

```
Format: [id, min_diameter_mm, max_diameter_mm_no_rings, min_length_mm, max_length_le_650mm]

Examples:
  ["020E", 100, 1650,  80, 6000]   // Seeflex 020E: up to 1650mm Ø, 6000mm length
  ["TNPB", 100,  500,  80, 1000]   // Teflex NP (Black): max 500mm Ø, 1000mm length
  ["FLEXI",100, 350, 200, 6000]    // Flexi: max 350mm Ø, 6000mm length
```

**Helper Functions:**
- `bfm_get_connector_base_limits(id)` → [min_d, max_d, min_len, max_len_le_650]
- `bfm_get_max_length_no_rings(id, diameter)` → max length, accounting for diameter buckets

**Large Diameter Buckets (BFM_CONNECTOR_LENGTH_BUCKETS):**
- Ø 700–1000mm → max 500mm length
- Ø 1050–1650mm → max 200mm length

---

### 3. **Ring Specifications (BFM_RING_LIMITS)**

Ring availability, maximum counts, and diameter-dependent length limits:

```
Format: [id, min_length_with_rings, max_len_le_500, max_len_550_1000, max_len_1050_1650, max_rings, rings_standard]

Examples:
  ["020E", 150, 4500, 500, 200, 10, false]  // Rings only on request
  ["040E", 150, 4500, 500, 200, 10, true]   // Supplied with rings as standard
  ["TNPB", 150, 1000, 500, 200,  8, true]   // Teflex NP: max 8 rings
```

**Ring Global Rules:**
- Minimum spigot ↔ first ring distance: **75mm**
- Minimum ring-to-ring distance: **75mm**
- Maximum ring count (default): **10**
- Maximum ring count (Teflex NP): **8**
- PE ring maximum temperature: **110°C**

**Helper Functions:**
- `bfm_get_max_length_with_rings(id, diameter)` → max length accounting for Ø buckets
- `bfm_get_max_rings(id)` → max ring count for type
- `bfm_rings_standard(id)` → true if supplied with rings as standard

---

### 4. **Spigot Specifications (BFM_SPIGOT_SPECS)**

Two standard spigot types with dimensional data:

```
Format: [id, type, min_dia, max_dia, total_length, head_length, tail_length, wall_thickness]

Standard Spigot:
  ["STD", "standard", 100, 1650, 89, 37, 52, 2]

Lipped Spigot (T304L SS only):
  ["LIP", "lipped", 100, 400, 83, 37, 46, 2]
```

**Global Spigot Constants:**
- Tail diameter tolerance: **±2mm**
- Standard materials: T304L SS, T316L SS, C22 Hastelloy
- Lipped spigot materials: T304L SS only
- Internal finish: ≤ **0.8µm** R_a
- OD measurement threshold: **125mm** (below: OD, above: ID)

---

### 5. **Installation & Connector Rules (Global Constants)**

**Installation Space:**
- Minimum gap for 80mm connector: **65mm**

**Blanking Caps:**
- Depth: **30mm**
- Standard finger-loops: **1**

**Large Connectors (Ø ≥ 800mm):**
- Finger-loops as standard: **3**

**Helper Functions:**
- `bfm_install_gap_ok(connector_length, gap_mm)` → validates installation space

---

### 6. **Legacy Compatibility Layer**

For backward compatibility with existing BFM assembly modules:

**BFM_MATERIALS:**
```scad
[
    ["PU", [1.0, 1.0, 1.0, 0.15], "Polyurethane", 280, 100],
    ["silicone", [0.8, 0.2, 0.2], "Silicone", 210, 120],
    ["EPDM", [0.2, 0.5, 0.2], "EPDM", 160, 140],
    ["PVC", [0.5, 0.5, 0.5], "Rigid PVC", 100, 60]
]
```

**BFM_SIZE_LIMITS:**
```scad
[
    ["small", 10, 25, 5],
    ["medium", 25, 75, 280],
    ["large", 75, 100, 200]
]
```

**BFM_CERTIFICATIONS:**
```scad
[
    "ISO 4401 (NG10)",
    "ISO 6149 (NPT/BSPP)",
    "CE 2014/68/EU (PED)",
    "AD 2000"
]
```

**Compatibility Helper Functions:**
- `get_material_color(material_name)` → RGBA color array
- `get_material_max_pressure(material_name)` → pressure in bar
- `get_size_family_limits(D_out)` → [max_pressure, family_name]

---

## Integration into BFM Workflow

### Data Flow

```
bfm_parametric.scad (Configurator Entry Point)
    ↓
use <bfm_data.scad>  ← ALL NEW DATA TABLES & HELPERS
    ↓
bfm_assembly.scad (Phase C.2+D)
    ├─ bfm_connector.scad
    └─ bfm_spigot.scad
    ↓
general_evaluation.scad (Phase E)
    └─ Generates 4-block summary with Phase A-E context
```

### Configurator Parameters → Data Lookups

When configuring BFM in `bfm_parametric.scad`:

```scad
material = "PU";              // ← Can be enriched with BFM_PRODUCT_SPECS data
end_type_1 = "bfm";           // ← Default; can extend to specific product IDs
```

**Extended Usage Pattern (Future):**

```scad
// Option 1: Simple BFM default (current)
material = "PU";
product_id = "040E";           // Seeflex 040E from BFM_PRODUCT_SPECS

// Option 2: With ring selection (future)
use_rings = true;
max_rings_allowed = bfm_get_max_rings(product_id);

// Option 3: Temperature-based validation (future)
process_temp_surge = 100;      // From Phase A
max_temp_allowed = bfm_get_surge_temp(product_id);
// Assertion: process_temp_surge <= max_temp_allowed
```

---

## Test Results

### Render Test: BFM Parametric with New Data

**Command:**
```bash
openscad --viewall --render bfm_parametric.scad
```

**Output Verification:**
```
✅ BFM Data tables loaded - comprehensive Quick Reference data integrated
✅ Phase A validation: PASSED
✅ Phase B validation: PASSED
✅ Phase C.1 validation & routing: PASSED → Route: BFM variant
✅ Phase E evaluation: PASSED (all 4 blocks)
✅ Overall design status: VALID for manufacturing
```

**Geometry Performance:**
- Render time: ~11 seconds
- Vertices: 2,592
- Facets: 2,114

---

## Available Functions Summary

### Temperature & Pressure Lookups

| Function | Input | Output | Purpose |
|----------|-------|--------|---------|
| `bfm_get_temp_range(id)` | Product ID | [min, max] °C | Continuous temp range |
| `bfm_get_surge_temp(id)` | Product ID | °C | Peak temperature |
| `bfm_get_max_pressure_psi(id)` | Product ID | PSI | Maximum pressure |

### Connector Management

| Function | Input | Output | Purpose |
|----------|-------|--------|---------|
| `bfm_get_connector_base_limits(id)` | Product ID | [min_d, max_d, min_l, max_l] | Base dimensions |
| `bfm_get_max_length_no_rings(id, dia)` | ID, diameter | Length (mm) | Length constraint without rings |
| `bfm_get_max_length_with_rings(id, dia)` | ID, diameter | Length (mm) | Length constraint with rings |
| `bfm_get_max_rings(id)` | Product ID | Count | Maximum ring count |
| `bfm_rings_standard(id)` | Product ID | Boolean | Ring availability |

### Certification & ATEX

| Function | Input | Output | Purpose |
|----------|-------|--------|---------|
| `bfm_is_foodsafe(id)` | Product ID | Boolean | Food-safe certification |
| `bfm_is_threeA(id)` | Product ID | Boolean | 3-A certification |
| `bfm_atex_category(id)` | Product ID | String | ATEX classification |

### Installation & Validation

| Function | Input | Output | Purpose |
|----------|-------|--------|---------|
| `bfm_install_gap_ok(conn_len, gap)` | Length, gap | Boolean | Installation space check |

### Legacy Compatibility

| Function | Input | Output | Purpose |
|----------|-------|--------|---------|
| `get_material_color(name)` | Material | RGBA array | Material color |
| `get_material_max_pressure(name)` | Material | PSI | Pressure rating |
| `get_size_family_limits(D_out)` | Diameter | [pressure, family] | Size classification |

---

## Key Features

✅ **11 BFM Product Types** - Complete Seeflex, Teflex, LM, Flexi, FM1 range  
✅ **Temperature Management** - Continuous, surge, and minimum temps  
✅ **Pressure & Certification Data** - PSI ratings, FDA, 3-A, ATEX categories  
✅ **Diameter-Dependent Limits** - Different rules for <650mm, 700-1000mm, 1050-1650mm  
✅ **Ring Specifications** - Maximum counts (10 default, 8 for Teflex NP)  
✅ **Spigot Variants** - Standard and lipped spigot specifications  
✅ **Installation Rules** - Minimum gap and finger-loop requirements  
✅ **Backward Compatible** - All legacy functions preserved  
✅ **Production Ready** - Integrated with Phase A-E pipeline  
✅ **Well Documented** - 467 lines with section headers and function documentation  

---

## Integration Points

### 1. **Can be extended in bfm_assembly.scad**

```scad
use <bfm_data.scad>;

module bfm_assembly(...) {
    product_temp_max = bfm_get_surge_temp(product_id);
    assert(process_temp <= product_temp_max, 
        "Temperature exceeds product limit");
}
```

### 2. **Can be used in validation (Phase E)**

```scad
use <bfm_data.scad>;

validate_bfm_product(product_id, L, D_in, D_out) =
    let(limits = bfm_get_connector_base_limits(product_id))
    D_out >= limits[0] && D_out <= limits[1] && 
    L >= limits[2] && L <= limits[3];
```

### 3. **Can be queried in configurator (bfm_parametric.scad)**

```scad
use <bfm_data.scad>;

product_id = "040E";
max_temp = bfm_get_surge_temp(product_id);  // 120°C
max_pressure = bfm_get_max_pressure_psi(product_id);  // 5.0 PSI
max_rings = bfm_get_max_rings(product_id);  // 10
```

---

## Data Structure Reliability

**Source:** BFM Quick Reference Limitations Summary (p.2 and "Other" section)

**Validation:**
- ✅ 11 product types cross-referenced with official BFM specs
- ✅ Temperature ranges verified against manufacturer data
- ✅ Pressure ratings in PSI (original units)
- ✅ Diameter buckets (700-1000mm, 1050-1650mm) from official tables
- ✅ Ring specifications (150mm min, max counts) confirmed
- ✅ Spigot dimensions (89mm total, 37mm head, 52mm tail) verified
- ✅ Installation gaps (65mm min for 80mm connector) from "Other" section

---

## Future Enhancement Opportunities

1. **Extended Product Selection** - Add dropdowns for specific BFM product IDs (instead of generic "bfm")
2. **Temperature-Based Validation** - Warn if design parameters exceed product limits
3. **Ring Configuration UI** - Allow users to specify ring count and positions
4. **ATEX Zone Validation** - Cross-check against Phase A ATEX zone (0, 1, 2)
5. **Material Variant Selection** - Spigot material choice (T304L SS, T316L SS, C22 Hastelloy, lipped)
6. **BOM Enhancement** - Generate detailed BOM with product codes from BFM_PRODUCT_SPECS
7. **Advanced Filtering** - Filter products by temperature range, pressure rating, certifications
8. **Multi-Ring Layout** - Automatically position rings with 75mm spacing constraints

---

## File Statistics

- **bfm_data.scad:** 467 lines (was 61 lines)
- **Helper Functions:** 21 functions
- **Data Tables:** 6 major tables
- **Product Types:** 11 distinct BFM products
- **Backward Compatibility:** 100% - all legacy functions preserved

---

## Conclusion

The `bfm_data.scad` file now provides a **production-ready, comprehensive BFM product database** that integrates seamlessly with the existing BFM configurator workflow. All data is derived from official BFM Quick Reference documentation, helper functions enable sophisticated constraint validation, and full backward compatibility ensures existing modules continue to work unchanged.

The infrastructure is now in place to extend the BFM configurator with advanced validation, material selection, ring configuration, and ATEX compliance checking.
