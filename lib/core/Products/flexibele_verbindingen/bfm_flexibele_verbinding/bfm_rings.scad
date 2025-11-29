// bfm_rings.scad
// BFM Rings - Support/reinforcement rings (future enhancement)

/**
 * BFM reinforcement ring - optional support element
 * Currently placeholder for future expansion
 */
module bfm_ring(
    D_in = 50,
    D_out = 60,
    ring_width = 5,
    ring_thickness = 2,
    z_pos = 0,
    $fn = 96
) {
    r_out = D_out / 2;
    
    translate([0, 0, z_pos])
        difference() {
            cylinder(h = ring_thickness, r = r_out + 5, $fn = $fn);
            cylinder(h = ring_thickness + 0.1, r = r_out, $fn = $fn);
        }
}
