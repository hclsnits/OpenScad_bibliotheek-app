// lampe_jacob.scad
// LAMPE Jacob Welding End - Realistic parametric model
// External flange orientation, diameter-proportional scaling

// ---------------------------------------------------------
// Material colouring
// ---------------------------------------------------------
function jacob_material_color(mat) =
    mat == "mild"      ? [0.70, 0.70, 0.70] :
    mat == "powder"    ? [0.85, 0.85, 0.90] :
    mat == "stainless" ? [0.78, 0.78, 0.82] :
                         [0.8, 0.8, 0.8];

// ---------------------------------------------------------
// 2D cross-section profile with external flange
// ---------------------------------------------------------
module jacob_welding_end_profile(r_i = 50, r_o = 52, L = 55, S = 3, r_fl = 58, orient = "bottom") {
    
    if (orient == "bottom") {
        // Bottom: flange points downward (external)
        polygon(points = [
            [r_i,  S],
            [r_fl, 0],     // Flange pointing down
            [r_fl, S],
            [r_o,  S],
            [r_o,  L],
            [r_i,  L]
        ]);
    } else {  // "top"
        // Top: flange points upward (external)
        polygon(points = [
            [r_i,  0],
            [r_o,  0],
            [r_o,  L-S],
            [r_fl, L-S],
            [r_fl, L],     // Flange pointing up
            [r_i,  L-S]
        ]);
    }
}

// ---------------------------------------------------------
// Main 3D module: Jacob welding end with scaling
// ---------------------------------------------------------
module lampe_jacob(
    D_out     = 60,
    D_in      = 50,
    orient    = "bottom",
    mat       = "stainless",
    z_pos     = 0,
    $fn       = 128
) {
    // Scale dimensions based on outer diameter
    scale_factor = D_out / 60;
    
    r_i = D_in / 2;
    r_o = D_out / 2;
    
    L   = 55 * scale_factor;
    S   = (D_out - D_in) / 2;
    lip = (D_out / 10);
    r_fl = r_o + lip;

    translate([0, 0, z_pos])
        color(jacob_material_color(mat))
            rotate_extrude($fn = $fn)
                jacob_welding_end_profile(
                    r_i = r_i,
                    r_o = r_o,
                    L = L,
                    S = S,
                    r_fl = r_fl,
                    orient = orient
                );
}
