// lampe_hoofdmateriaal.scad
// LAMPE Main Flexible Tubing Component
// OPEN hollow cylinder - central connector element

/**
 * Main flexible tube - OPEN hollow cylinder
 * This is the central component that connects two external components
 * 
 * @param L         Length of tubing (mm)
 * @param D_in      Inner diameter (mm)
 * @param D_out     Outer diameter (mm)
 * @param material  Material type identifier (for reference)
 * @param color_mat RGBA color vector [R, G, B, A]
 * @param $fn       Circle resolution (higher = smoother)
 */
module lampe_hoofdmateriaal(
    L = 500,
    D_in = 50,
    D_out = 60,
    material = "PU",
    color_mat = [1.0, 1.0, 1.0, 0.15],
    $fn = 96
) {
    r_out = D_out / 2;
    r_in = D_in / 2;

    color(color_mat)
        difference() {
            // Outer cylinder
            cylinder(h = L, r = r_out, $fn = $fn);
            
            // Inner hollow (subtract to create tube)
            cylinder(h = L + 0.1, r = r_in, $fn = $fn);
        }
}
