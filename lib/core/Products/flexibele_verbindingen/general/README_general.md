# GENERAL LAYER: Shared Pipeline & Phase Framework

This folder contains the **general layer** — shared phase definitions (A, B, C.1, E) that apply across all product variants (LAMPE, BFM, etc.). The general layer orchestrates the five-phase design pipeline before delegating to product-specific implementations.

## Overview: Five-Phase Pipeline

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        GENERAL LAYER (shared A,B,C.1,E)                  │
│                                                                           │
│  PHASE A: Application Context    PHASE B: Base Dimensions                │
│  ├─ Process medium               ├─ L_tube, D_in, D_out                  │
│  ├─ Hygiene class                ├─ gap_length, nominal_diameter         │
│  ├─ ATEX zone                    ├─ Conversion helpers                   │
│  ├─ Temp profile (cont/surge)    └─ Size family classification           │
│  └─ Pressure profile                                                      │
│         │                                  │                              │
│         └──────────────────────────────────┘                              │
│                         ↓                                                  │
│         ┌─────────────────────────────────────┐                          │
│         │ PHASE C.1: End Type Selection      │                          │
│         │ ├─ Validate connectors vs Phase A/B│                          │
│         │ ├─ Routing decision logic           │                          │
│         │ └─ Output: selected_variant        │                          │
│         │    (lampe | bfm | mixed)           │                          │
│         └─────────────────────────────────────┘                          │
│                         ↓                                                  │
│              ROUTE TO VARIANT                                             │
│            /                    \                                         │
│     LAMPE VARIANT          BFM VARIANT                                   │
│   (C.2+D modules)        (C.2+D modules)                                 │
│     Assembly              Assembly                                        │
│                                                                           │
│         ↓ (via callbacks)         ↓ (via callbacks)                      │
│                                                                           │
│  PHASE E: Comprehensive Evaluation (shared)                             │
│  ├─ Block 1: Identity & Use Case                                        │
│  ├─ Block 2: Geometry Summary                                           │
│  ├─ Block 3: End Connections Specs                                      │
│  ├─ Block 4: Technical Limits & Validation                              │
│  └─ Delegate product-specific checks (bfm_validation.scad, etc.)       │
└──────────────────────────────────────────────────────────────────────────┘
```

## Phase Responsibilities

### PHASE A: Application Context (`general_application_context.scad`)

**Responsibility:** Define environment-level constraints that apply across the entire system.

**Parameters:**

| Parameter | Type | Range | Purpose |
|-----------|------|-------|---------|
| `process_medium` | enum | water, air, oil, food, pharma, chemical | Type of fluid/gas being conveyed |
| `hygiene_class` | enum | general, food, pharma, atex | Sanitation/certification level |
| `atex_zone` | int | 0, 1, 2 | Explosive atmosphere classification (if `hygiene_class="atex"`) |
| `process_temp_cont` | float | -40...100 °C | Continuous operating temperature |
| `process_temp_surge` | float | -40...120 °C | Maximum surge/peak temperature |
| `process_temp_min` | float | -60...50 °C | Minimum storage/ambient temperature |
| `process_pressure_max` | float | 1...350 bar | Maximum working pressure |
| `process_pressure_surge` | float | 1...400 bar | Intermittent peak pressure (short duration) |

**Key Functions:**

```scad
get_material_requirement(medium)        // Returns material spec (oil-resistant, etc.)
get_max_pressure_by_class(hygiene)      // Returns pressure rating limit by class
get_required_certifications(hygiene)    // Returns array of required certifications
validate_temperature_profile(...)       // Checks temp_min < temp_cont < temp_surge
validate_pressure_profile(...)          // Checks pressure_cont <= pressure_surge
```

**Usage Examples:**

```scad
// Medical/pharma application with sterilization
process_medium = "pharma";
hygiene_class = "pharma";
process_temp_surge = 121;  // Autoclaving temperature
process_pressure_max = 10;

// Industrial hydraulic with ATEX compliance
process_medium = "oil";
hygiene_class = "atex";
atex_zone = 1;
process_temp_cont = 60;
process_pressure_max = 280;
```

### PHASE B: Base Dimensions (`general_base_dimensions.scad`)

**Responsibility:** Define shared geometric parameters and provide dimension conversion utilities.

**Parameters:**

| Parameter | Type | Range | Purpose |
|-----------|------|-------|---------|
| `L_tube` | float | 100...2000 mm | Length of main flexible tube |
| `D_in` | float | 10...150 mm | Inner diameter |
| `D_out` | float | 15...160 mm | Outer diameter |
| `gap_length` | float | 0...50 mm | Space between tube and connector |
| `target_nominal_diameter` | float | 10...100 mm | ISO nominal size (16, 19, 22, 25, 32, 38, 50, 64) |

**Derived Parameters:**

```scad
wall_thickness = (D_out - D_in) / 2;    // Calculated wall thickness
target_family = get_size_family(...);   // Size classification (small, medium, large, etc.)
A_tube = (D_out² - D_in²) × π / 4;     // Cross-section area (mm²)
V_tube = A_tube × L_tube;               // Total volume (mm³)
```

**Key Functions:**

```scad
// Conversion helpers
nominal_to_Din(nominal)                 // Approx inner diameter from nominal
nominal_to_Dout(nominal)                // Approx outer diameter from nominal
Dout_to_Din(dout, wall)                 // Calculate inner diameter given outer + wall
Din_to_Dout(din, wall)                  // Calculate outer diameter given inner + wall

// Range getters
get_max_length(app)                     // Max L for application (lampe=2000, bfm=1500)
get_max_D_in(app)                       // Max inner diameter for application
get_max_D_out(app)                      // Max outer diameter for application

// Validation
validate_dimensions(L, Din, Dout, app)  // Check all dimensions within ranges
validate_gap_length(gap)                // Gap must be 0-50 mm
validate_nominal_diameter(nominal)      // Nominal must be positive
```

### PHASE C.1: End Type Selection & Routing (`general_end_type_selection.scad`)

**Responsibility:** Validate connector types against environment (Phase A) and geometry (Phase B), then route to appropriate product variant.

**Connector Specifications Database:**

Each connector type has inherent limits:

| Connector | Max Pressure | Max Temp | Diameter Range | Typical Use |
|-----------|--------------|----------|-----------------|------------|
| snelkoppeling | 250 bar | 80°C | 12-100 mm | General quick-disconnects |
| jacob | 50 bar | 120°C | 20-150 mm | Stainless steel welding ends |
| triclamp | 100 bar | 100°C | 16-150 mm | Sanitary (food/pharma/medical) |
| bfm | 280 bar | 100°C | 10-100 mm | Industrial hydraulic spigots |

**Routing Logic:**

```
IF   any end_type == "bfm"
     → Use BFM variant (handles 280 bar industrial pressures)

ELSE IF all end_types in [snelkoppeling, jacob, triclamp]
     → Use LAMPE variant (lab/medical/pharma, max 50 bar)

ELSE mixed types
     → Default to LAMPE variant
```

### PHASE E: Comprehensive Evaluation (`general_evaluation.scad`)

**Responsibility:** Perform final multi-block validation and generate structured design summary report.

**Four-Block Structure:**

1. **Block 1: Identity & Use Case** - Application context validation
2. **Block 2: Geometry** - Dimensional consistency and ranges
3. **Block 3: End Connections** - Connector compatibility specs
4. **Block 4: Technical Limits & Validation** - Operating range and variant-specific limits
- `end_type_2` - Connector for end 2
- `coupling_type_1`, `coupling_type_2` - Optional parameters for snelkoppeling

**Routing Logic:**
- If both ends use jacob/snelkoppeling/triclamp → "lampe" variant
- If either end uses bfm → "bfm" variant

**Output:** Selected product variant and routing confirmation

### general_evaluation.scad
**Phase E**: Final validation and summary report generation.

**Validations:**
1. Geometry consistency checks
2. Application-specific limits
3. Wall thickness reasonable
4. Material availability

**Output:** 
- Assertion errors if validation fails
- Summary report logged to console

## Parameter Flow: How Phases Connect

```
PHASE A (Application Context)
    ↓ provides: process_medium, hygiene_class, pressure/temperature limits
    
PHASE B (Base Dimensions)
    ↓ provides: L_tube, D_in, D_out, gap_length, wall_thickness
    
PHASE C.1 (End Type Selection)
    ↓ validates: end_type_1/2 against Phase A/B constraints
    ↓ routes: → LAMPE variant OR → BFM variant
    
PHASE C.2+D (Product Assembly) [VARIANT-SPECIFIC]
    ↓ orchestrates: variant-specific assembly logic
    
PHASE E (Evaluation & Summary)
    ↓ validates: all constraints across all phases
    ↓ reports: comprehensive 4-block design summary
    ↓ delegates: product-specific checks if needed
```

## Example: Complete Validation Flow

**Configuration:**
```scad
// User sets application context
process_medium = "pharma";
hygiene_class = "pharma";
process_temp_surge = 121;    // Autoclaving
process_pressure_max = 10;

// User sets dimensions
L_tube = 500;
D_in = 50;
D_out = 60;

// User selects connectors
end_type_1 = "triclamp";
end_type_2 = "triclamp";
```

**Validation Result:**
```
PHASE A: ✓ Pharma context valid
PHASE B: ✓ Dimensions within range
PHASE C.1: ✓ Tri-clamp connectors compatible with pharma
         ✓ Route to LAMPE variant
PHASE E: ✓ All 4 blocks validated
         → Design VALID for manufacturing
```

## Files in This Folder

| File | Purpose | Phase |
|------|---------|-------|
| `general_application_context.scad` | Environment definition & validation | A |
| `general_base_dimensions.scad` | Dimensional framework & helpers | B |
| `general_end_type_selection.scad` | Connector validation & routing | C.1 |
| `general_evaluation.scad` | Comprehensive evaluation & summary | E |

---

**Last Updated:** 2025  
**Version:** 2.0.0 (Comprehensive Phase Framework)  
**Compatibility:** OpenSCAD 2024+
