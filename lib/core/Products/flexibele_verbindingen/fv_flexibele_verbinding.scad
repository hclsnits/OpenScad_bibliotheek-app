// fv_flexibele_verbinding.scad
// Flexible verbinding assembly module that integrates all component modules
// Component sources:
//   - fv_hoofdmateriaal.scad: main flexible tubing
//   - fv_snelkoppeling.scad: quick coupling connector
//   - fv_jacob.scad: jacob coupling connector
//   - fv_triclamp.scad: tri-clamp sanitary coupling
//   - fv_bfm.scad: BFM quick disconnect coupling

use <fv_hoofdmateriaal.scad>;
use <fv_snelkoppeling.scad>;
use <fv_jacob.scad>;
use <fv_triclamp.scad>;
use <fv_bfm.scad>;

/**
 * Flexible verbinding (flexible connector) assembly module
 * Connects two components via an open flexible tubing with end couplings
 * 
 * The connector is fundamentally an OPEN tube:
 * - Inner diameter flows through entire length for media transport
 * - End couplings are designed to slip over or connect to the tube ends
 * - Used to bridge distance and allow some movement/flex between components
 */
module fv_flexibele_verbinding(
    L              = 500,
    D_in           = 50,
    D_out          = 60,
    material       = "PU",
    color_mat      = [0.9, 0.9, 0.95],
    end_type_1     = "snelkoppeling",
    end_type_2     = "triclamp",
    coupling_type_1 = "male",
    coupling_type_2 = "female",
    $fn            = 96
) {
    // Main flexible tubing (hoofdmateriaal) - OPEN at both ends
    // This is the central connector that joins two components
    fv_hoofdmateriaal(
        L = L,
        D_in = D_in,
        D_out = D_out,
        material = material,
        color_mat = color_mat,
        $fn = $fn
    );

    // End connector 1 (at z = -5 to -30)
    // Positioned slightly BEFORE the tube start to show how it connects
    if (end_type_1 == "snelkoppeling") {
        fv_snelkoppeling(
            D_in = D_in,
            D_out = D_out,
            coupling_type = coupling_type_1,
            z_pos = -30,
            $fn = $fn
        );
    } else if (end_type_1 == "jacob") {
        fv_jacob(
            D_in = D_in,
            D_out = D_out,
            orient = "bottom",
            z_pos = -30,
            $fn = $fn
        );
    } else if (end_type_1 == "triclamp") {
        fv_triclamp(
            D_in = D_in,
            D_out = D_out,
            z_pos = -35,
            $fn = $fn
        );
    } else if (end_type_1 == "bfm") {
        fv_bfm(
            D_in = D_in,
            D_out = D_out,
            z_pos = -28,
            $fn = $fn
        );
    }

    // End connector 2 (at z = L to L+30)
    // Positioned after the tube end to show connection point
    if (end_type_2 == "snelkoppeling") {
        fv_snelkoppeling(
            D_in = D_in,
            D_out = D_out,
            coupling_type = coupling_type_2,
            z_pos = L,
            $fn = $fn
        );
    } else if (end_type_2 == "jacob") {
        fv_jacob(
            D_in = D_in,
            D_out = D_out,
            orient = "top",
            z_pos = L,
            $fn = $fn
        );
    } else if (end_type_2 == "triclamp") {
        fv_triclamp(
            D_in = D_in,
            D_out = D_out,
            z_pos = L,
            $fn = $fn
        );
    } else if (end_type_2 == "bfm") {
        fv_bfm(
            D_in = D_in,
            D_out = D_out,
            z_pos = L,
            $fn = $fn
        );
    }
}
