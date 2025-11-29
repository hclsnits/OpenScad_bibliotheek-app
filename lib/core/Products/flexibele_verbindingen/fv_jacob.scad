// fv_jacob.scad
// Jacob-style welding end – parametric OpenSCAD model
// Realistic representation with proper flanging and geometry
// All dimensions in millimetres

// ---------------------------------------------------------
// JACOB standard welding end configurations
// ---------------------------------------------------------

// Convenience: list of common nominal diameters (Ød)
jacob_nominal_diameters = [
    60, 80, 100, 120, 140, 150, 175, 200,
    224, 250, 280, 300, 315, 350, 400,
    450, 500, 560, 630
];

// ---------------------------------------------------------
// Material colouring (purely visual)
//   "mild"       -> unpainted mild steel
//   "powder"     -> powder coated
//   "stainless"  -> stainless steel
// ---------------------------------------------------------
function jacob_material_color(mat) =
    mat == "mild"      ? [0.70, 0.70, 0.70] :     // slightly darker grey
    mat == "powder"    ? [0.85, 0.85, 0.90] :     // light, almost painted
    mat == "stainless" ? [0.78, 0.78, 0.82] :     // neutral stainless-ish
                         [0.8, 0.8, 0.8];         // default grey

// ---------------------------------------------------------
// 2D cross-section profile of the welding end
//   r_o    : outer radius of tube
//   L      : overall axial length
//   S      : sheet thickness
//   r_fl   : flange outer radius
//   orient : "bottom" (flange points down) or "top" (flange points up)
// ---------------------------------------------------------
module jacob_welding_end_profile(r_i = 50, r_o = 52, L = 55, S = 3, r_fl = 58, orient = "bottom") {
    
    if (orient == "bottom") {
        // Bottom welding end: flange points downward (external)
        /* Cross-section:
           
           F  E  ← Top (inner and outer tube)
           |  |
           |  |
           D--C  ← Flange top (at S height)
              B  ← Flange outer
           A--   ← Inner bottom, Flange bottom (external)
        */
        polygon(points = [
            [r_i,  S],     // A: inner at flange height
            [r_fl, 0],     // B: flange outer (pointing down - external)
            [r_fl, S],     // C: flange outer at top
            [r_o,  S],     // D: tube outer at flange top
            [r_o,  L],     // E: tube outer at end
            [r_i,  L]      // F: tube inner at end
        ]);
    } else {  // "top"
        // Top welding end: flange points upward (external)
        /* Cross-section:
           
           B     ← Flange outer (pointing up - external)
           A--C  ← Flange top
           |  |
           |  |
           F--E  ← Bottom (inner and outer tube)
        */
        polygon(points = [
            [r_i,  0],     // F: tube inner at start
            [r_o,  0],     // E: tube outer at start
            [r_o,  L-S],   // D: tube outer at flange base
            [r_fl, L-S],   // C: flange outer at bottom
            [r_fl, L],     // B: flange outer (pointing up - external)
            [r_i,  L-S]    // A: inner at flange base
        ]);
    }
}

// ---------------------------------------------------------
// Main 3D module: Jacob welding end
//   D_out         : outer diameter of tube (scales all dimensions)
//   D_in          : inner diameter of tube
//   orient        : "bottom" (flange down) or "top" (flange up)
//   mat           : "mild", "powder", "stainless"
//   z_pos         : Z position for placement
//   $fn           : circle resolution
// ---------------------------------------------------------
module fv_jacob(
    D_out     = 60,
    D_in      = 50,
    orient    = "bottom",
    mat       = "stainless",
    z_pos     = 0,
    $fn       = 128
) {
    // Scale all dimensions based on outer diameter
    scale_factor = D_out / 60;  // Base scale: 60mm outer diameter
    
    r_i = D_in / 2;
    r_o = D_out / 2;
    
    // Scaled dimensions
    L   = 55 * scale_factor;      // Overall length scales with diameter
    S   = (D_out - D_in) / 2;     // Sheet thickness = wall thickness
    lip = (D_out / 10);           // Flange lip is 10% of outer diameter
    r_fl = r_o + lip;             // Flange outer radius

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

// ---------------------------------------------------------
// Wrapper for flexible connector compatibility
// Automatically orients flanges based on position
// ---------------------------------------------------------
module fv_jacob_connector(
    D_in     = 50,
    D_out    = 60,
    z_pos    = 0,
    is_top   = false,
    $fn      = 96
) {
    // Determine orientation based on position
    orient = is_top ? "top" : "bottom";
    
    fv_jacob(
        D_out = D_out,
        D_in = D_in,
        orient = orient,
        mat = "stainless",
        z_pos = z_pos,
        $fn = $fn
    );
}
