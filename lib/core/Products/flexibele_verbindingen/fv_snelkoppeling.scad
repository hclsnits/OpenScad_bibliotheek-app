// fv_snelkoppeling.scad
// Quick coupling connector end piece (male/female variants)

/**
 * Quick coupling connector (snelkoppeling)
 * @param D_in       Inner diameter of the flexible tubing
 * @param D_out      Outer diameter of the flexible tubing
 * @param coupling_type "male" or "female"
 * @param z_pos      Z position for placement
 * @param $fn        Number of fragments for smooth cylinders
 */
module fv_snelkoppeling(
    D_in = 50,
    D_out = 60,
    coupling_type = "male",
    z_pos = 0,
    $fn = 96
) {
    r_out = D_out / 2;
    r_in = D_in / 2;
    
    quick_h = 25;
    flange_r = r_out + 5;

    translate([0, 0, z_pos]) {
        color([0.3, 0.3, 0.3]) {
            // Main body
            difference() {
                cylinder(h = quick_h, r = r_out + 3, $fn = $fn);
                cylinder(h = quick_h + 0.1, r = r_in - 1, $fn = $fn);
            }
            
            if (coupling_type == "male") {
                // Male: protruding pins
                for (angle = [0, 120, 240]) {
                    rotate([0, 0, angle])
                        translate([r_out + 3, 0, quick_h - 3])
                            cylinder(h = 3, r = 1.5, $fn = 16);
                }
            } else {  // female
                // Female: flange with grooves
                translate([0, 0, -2])
                    cylinder(h = 2, r = flange_r, $fn = $fn);
            }
            
            // Locking ring
            translate([0, 0, quick_h - 2])
                difference() {
                    cylinder(h = 2, r = r_out + 4, $fn = $fn);
                    cylinder(h = 2.2, r = r_out + 1, $fn = $fn);
                }
        }
    }
}
