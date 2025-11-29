// lampe_assembly.scad
// LAMPE Product Assembly Module - Phase C.2+D
// Orchestrates all component placement and assembly logic

use <lampe_hoofdmateriaal.scad>;
use <lampe_snelkoppeling.scad>;
use <lampe_jacob.scad>;
use <lampe_triclamp.scad>;

/**
 * LAMPE Assembly - Flexible connector with configurable end couplings
 */
module lampe_assembly(
    L = 500,
    D_in = 50,
    D_out = 60,
    material = "PU",
    color_mat = [1.0, 1.0, 1.0, 0.15],
    end_type_1 = "jacob",
    end_type_2 = "jacob",
    coupling_type_1 = "male",
    coupling_type_2 = "female",
    $fn = 96
) {
    // Main flexible tubing (OPEN at both ends)
    lampe_hoofdmateriaal(
        L = L,
        D_in = D_in,
        D_out = D_out,
        material = material,
        color_mat = color_mat,
        $fn = $fn
    );

    // END 1 CONNECTOR (at z = -30)
    if (end_type_1 == "snelkoppeling") {
        lampe_snelkoppeling(
            D_in = D_in,
            D_out = D_out,
            coupling_type = coupling_type_1,
            z_pos = -30,
            $fn = $fn
        );
    } else if (end_type_1 == "jacob") {
        lampe_jacob(
            D_in = D_in,
            D_out = D_out,
            orient = "bottom",
            z_pos = -30,
            $fn = $fn
        );
    } else if (end_type_1 == "triclamp") {
        lampe_triclamp(
            D_in = D_in,
            D_out = D_out,
            z_pos = -35,
            $fn = $fn
        );
    }

    // END 2 CONNECTOR (at z = L)
    if (end_type_2 == "snelkoppeling") {
        lampe_snelkoppeling(
            D_in = D_in,
            D_out = D_out,
            coupling_type = coupling_type_2,
            z_pos = L,
            $fn = $fn
        );
    } else if (end_type_2 == "jacob") {
        lampe_jacob(
            D_in = D_in,
            D_out = D_out,
            orient = "top",
            z_pos = L,
            $fn = $fn
        );
    } else if (end_type_2 == "triclamp") {
        lampe_triclamp(
            D_in = D_in,
            D_out = D_out,
            z_pos = L,
            $fn = $fn
        );
    }
}
