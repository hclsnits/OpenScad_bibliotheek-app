// bfm_spigot.scad
// BFM Spigot - Connection interface at tube ends

/**
 * BFM spigot connector - banjo fitting style
 */
module bfm_spigot(
    D_in = 50,
    D_out = 60,
    z_pos = 0,
    $fn = 96
) {
    r_out = D_out / 2;
    r_in = D_in / 2;
    
    spigot_h = 28;
    banjo_r = r_out + 6;
    bolt_offset = r_out + 8;

    translate([0, 0, z_pos]) {
        color([0.4, 0.4, 0.4]) {
            // Main banjo body
            sphere(r = banjo_r);
            
            // Tube connection
            cylinder(h = spigot_h, r = r_out + 2, $fn = $fn);
            
            // Inner bore
            cylinder(h = spigot_h + 0.1, r = r_in, $fn = $fn);
            
            // Bolt holes (4x)
            for (angle = [0, 90, 180, 270]) {
                rotate([0, 0, angle])
                    translate([bolt_offset, 0, spigot_h - 3])
                        cylinder(h = 3, r = 1.5, $fn = 12);
            }
            
            // Sealing surface
            translate([0, 0, spigot_h - 2])
                cylinder(h = 2, r = r_out + 3, $fn = $fn);
        }
    }
}
