// flexibele_verbinding_parametric.scad
// Parametric flexible connector configurator
// Connects two components via flexible tubing with multiple coupling options

use <../Products/flexibele_verbindingen/fv_flexibele_verbinding.scad>;

// ============================================================
// CONFIGURATOR PARAMETERS
// ============================================================

/* [Dimensions] */
L = 500;              // Length of flexible tubing (mm) [100:2000]
D_in = 50;            // Inner diameter (mm) [10:100]
D_out = 60;           // Outer diameter (mm) [20:150]

/* [Material] */
material = "PU";      // [PU, silicone, rubber, EPDM, PVC]
color_mat = [1.0, 1.0, 1.0, 0.15];  // Custom color [R,G,B,A] - PU semi-transparent white

/* [End Connectors] */
end_type_1 = "jacob";      // ["snelkoppeling", "jacob", "triclamp", "bfm"]
end_type_2 = "jacob";      // ["snelkoppeling", "jacob", "triclamp", "bfm"]
coupling_type_1 = "male";  // ["male", "female"] - only for snelkoppeling
coupling_type_2 = "female";// ["male", "female"] - only for snelkoppeling

/* [Display] */
fn_segments = 96;     // Circle resolution [48:128]
show_measurements = false; // Show dimension text

// ============================================================
// MAIN ASSEMBLY
// ============================================================

fv_flexibele_verbinding(
    L = L,
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

// Optional: Display measurements
if (show_measurements) {
    translate([0, 0, L/2])
        text(str("L:", L, "mm  D:", D_out, "mm"), size=10, halign="center");
}
