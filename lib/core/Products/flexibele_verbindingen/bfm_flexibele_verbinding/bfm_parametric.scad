// bfm_parametric.scad
// BFM Flexible Connector - Parametric Configurator
// Entry point for industrial hydraulic/pneumatic connector system

use <../general/general_application_context.scad>;
use <../general/general_base_dimensions.scad>;
use <../general/general_end_type_selection.scad>;
use <../general/general_evaluation.scad>;
use <bfm_assembly.scad>;

// ============================================================
// CONFIGURATOR PARAMETERS - BFM VARIANT
// ============================================================

/* [Application] */
application = "bfm";      // [lampe, bfm, food, automotive]

/* [Dimensions] */
L_tube = 500;             // Length of flexible tubing (mm) [100:1500]
D_in = 50;                // Inner diameter (mm) [10:80]
D_out = 60;               // Outer diameter (mm) [20:100]

/* [Material] */
material = "PU";          // [PU, silicone, rubber, EPDM, PVC]
color_mat = [1.0, 1.0, 1.0, 0.15];  // RGBA - semi-transparent white (PU)

/* [End Connectors] */
end_type_1 = "bfm";       // ["snelkoppeling", "jacob", "triclamp", "bfm"]
end_type_2 = "bfm";       // ["snelkoppeling", "jacob", "triclamp", "bfm"]

/* [Display] */
fn_segments = 96;         // Circle resolution [48:128]
show_measurements = false; // Show dimension text

// ============================================================
// PHASE A-B-C.1: General Pipeline Setup
// ============================================================

// ============================================================
// PHASE C.2+D: Product Assembly (BFM Specific)
// ============================================================

bfm_assembly(
    L = L_tube,
    D_in = D_in,
    D_out = D_out,
    material = material,
    color_mat = color_mat,
    end_type_1 = end_type_1,
    end_type_2 = end_type_2,
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
    app = application,
    variant = "bfm",
    end_type_1 = end_type_1,
    end_type_2 = end_type_2
);
