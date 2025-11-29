// bfm_assembly.scad
// BFM Product Assembly Module - Phase C.2+D
// Orchestrates BFM-specific component placement

use <bfm_connector.scad>;
use <bfm_spigot.scad>;

/**
 * BFM Assembly - Industrial hydraulic/pneumatic connector
 */
module bfm_assembly(
    L = 500,
    D_in = 50,
    D_out = 60,
    material = "PU",
    color_mat = [1.0, 1.0, 1.0, 0.15],
    end_type_1 = "bfm",
    end_type_2 = "bfm",
    $fn = 96
) {
    // Main flexible connector body
    bfm_connector(
        L = L,
        D_in = D_in,
        D_out = D_out,
        color_mat = color_mat,
        $fn = $fn
    );

    // END 1 SPIGOT (at z = 0)
    if (end_type_1 == "bfm") {
        bfm_spigot(
            D_in = D_in,
            D_out = D_out,
            z_pos = 0,
            $fn = $fn
        );
    }

    // END 2 SPIGOT (at z = L)
    if (end_type_2 == "bfm") {
        bfm_spigot(
            D_in = D_in,
            D_out = D_out,
            z_pos = L,
            $fn = $fn
        );
    }
}
