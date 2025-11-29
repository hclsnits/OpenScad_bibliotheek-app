// fv_bfm.scad
// BFM (Banjo Fitting/Hydraulic) quick disconnect coupling

/**
 * BFM hydraulic quick disconnect (banjo fitting style)
 * @param D_in       Inner diameter of the flexible tubing
 * @param D_out      Outer diameter of the flexible tubing
 * @param z_pos      Z position for placement
 * @param $fn        Number of fragments for smooth cylinders
 */
module fv_bfm(
    D_in = 50,
    D_out = 60,
    z_pos = 0,
    $fn = 96
) {
    r_out = D_out / 2;
    r_in = D_in / 2;
    
    bfm_h = 28;
    banjo_r = r_out + 6;
    bolt_offset = r_out + 8;

    translate([0, 0, z_pos]) {
        color([0.4, 0.4, 0.4]) {
            // Main banjo body (rounded connection point)
            sphere(r = banjo_r);
            
            // Tube connection
            cylinder(h = bfm_h, r = r_out + 2, $fn = $fn);
            
            // Inner bore
            cylinder(h = bfm_h + 0.1, r = r_in, $fn = $fn);
            
            // Bolt hole bases (4x)
            for (angle = [0, 90, 180, 270]) {
                rotate([0, 0, angle])
                    translate([bolt_offset, 0, bfm_h - 3])
                        cylinder(h = 3, r = 1.5, $fn = 12);
            }
            
            // Sealing surface (top)
            translate([0, 0, bfm_h - 2])
                cylinder(h = 2, r = r_out + 3, $fn = $fn);
        }
    }
}
