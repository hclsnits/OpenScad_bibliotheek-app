// lampe_triclamp.scad
// LAMPE Tri-Clamp Sanitary Coupling (SMS/DIN 32676)

/**
 * Tri-clamp sanitary coupling for LAMPE variant
 * @param D_in       Inner diameter of the flexible tubing
 * @param D_out      Outer diameter of the flexible tubing
 * @param z_pos      Z position for placement
 * @param $fn        Number of fragments for smooth cylinders
 */
module lampe_triclamp(
    D_in = 50,
    D_out = 60,
    z_pos = 0,
    $fn = 96
) {
    r_out = D_out / 2;
    r_in = D_in / 2;
    
    triclamp_h = 35;
    ferrule_r = r_out + 4;
    tab_r = ferrule_r + 3;

    translate([0, 0, z_pos]) {
        color([0.6, 0.6, 0.65]) {
            // Main ferrule body
            difference() {
                cylinder(h = triclamp_h - 5, r = ferrule_r, $fn = $fn);
                cylinder(h = triclamp_h - 4, r = r_in, $fn = $fn);
            }
            
            // Top surface (sealing area)
            translate([0, 0, triclamp_h - 5])
                difference() {
                    cylinder(h = 2, r = ferrule_r, $fn = $fn);
                    cylinder(h = 2.2, r = r_in + 0.5, $fn = $fn);
                }
            
            // Tri-clamp tabs (3x 120° apart)
            for (angle = [0, 120, 240]) {
                rotate([0, 0, angle])
                    translate([tab_r, 0, triclamp_h - 8])
                        cylinder(h = 8, r = 2, $fn = 12);
            }
            
            // Top retention ring
            translate([0, 0, triclamp_h - 3])
                difference() {
                    cylinder(h = 3, r = ferrule_r + 1, $fn = $fn);
                    cylinder(h = 3.2, r = ferrule_r - 2, $fn = $fn);
                }
        }
    }
}
