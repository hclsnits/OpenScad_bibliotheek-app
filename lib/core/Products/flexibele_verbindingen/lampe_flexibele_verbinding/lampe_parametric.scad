// lampe_parametric.scad
// LAMPE Flexible Connector - Parametric Configurator
// Entry point for laboratory/medical/pharma flexible hose connector system

use <../general/general_application_context.scad>;
use <../general/general_base_dimensions.scad>;
use <../general/general_end_type_selection.scad>;
use <../general/general_evaluation.scad>;
use <lampe_assembly.scad>;

// ============================================================
// CONFIGURATOR PARAMETERS - LAMPE VARIANT
// ============================================================

/* [Application Context] */
process_medium = "water";              // [water, air, oil, food, pharma, chemical]
hygiene_class = "general";              // [general, food, pharma, atex]
atex_zone = 2;                          // [0:2] - ATEX zone (if hygiene_class=atex)

/* [Temperature Profile] */
process_temp_cont = 20;                 // Continuous operating temperature (°C) [-40:100]
process_temp_surge = 60;                // Surge/peak temperature (°C) [-40:120]
process_temp_min = -10;                 // Minimum storage temperature (°C) [-60:50]

/* [Pressure Profile] */
process_pressure_max = 10;              // Maximum working pressure (bar) [1:100]
process_pressure_surge = 15;            // Surge/peak pressure (bar) [1:150]

/* [Dimensions] */
L_tube = 500;             // Length of flexible tubing (mm) [100:2000]
D_in = 50;                // Inner diameter (mm) [10:100]
D_out = 60;               // Outer diameter (mm) [20:150]
gap_length = 10;          // Gap between tube and connector (mm) [0:50]

/* [Material] */
material = "PU";          // [PU, silicone, rubber, EPDM, PVC]
color_mat = [1.0, 1.0, 1.0, 0.15];  // RGBA - semi-transparent white (PU)

/* [End Connectors] */
end_type_1 = "jacob";     // ["snelkoppeling", "jacob", "triclamp", "bfm"]
end_type_2 = "jacob";     // ["snelkoppeling", "jacob", "triclamp", "bfm"]
coupling_type_1 = "male"; // ["male", "female"] - only for snelkoppeling
coupling_type_2 = "female"; // ["male", "female"] - only for snelkoppeling

/* [Display] */
fn_segments = 96;         // Circle resolution [48:128]
show_measurements = false; // Show dimension text

// ============================================================
// PHASE A-B-C.1: General Pipeline Setup
// ============================================================
// These are imported from general/ modules above
// They validate application, dimensions, and route to variant

// ============================================================
// PHASE C.2+D: Product Assembly (LAMPE Specific)
// ============================================================

lampe_assembly(
    L = L_tube,
    D_in = D_in,
    D_out = D_out,
    material = material,
    color_mat = color_mat,
    end_type_1 = end_type_1,
    end_type_2 = end_type_2,
    coupling_type_1 = coupling_type_1,
    coupling_type_2 = coupling_type_2,
    $fn = fn_segments
);

// ============================================================
// PHASE E: Validation & Summary
// ============================================================

wall = (D_out - D_in) / 2;
generate_summary_report(
    L = L_tube,
    D_in = D_in,
    D_out = D_out,
    wall = wall,
    gap = 10,  // Standard gap length
    process_medium = process_medium,
    hygiene_class = hygiene_class,
    atex_zone = atex_zone,
    process_temp_cont = process_temp_cont,
    process_temp_surge = process_temp_surge,
    process_temp_min = process_temp_min,
    process_pressure_max = process_pressure_max,
    process_pressure_surge = process_pressure_surge,
    variant = "lampe",
    end_type_1 = end_type_1,
    end_type_2 = end_type_2
);
