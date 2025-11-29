// fv_hoofdmateriaal.scad
// Main flexible tubing component for flexible connectors
// OPEN at both ends - no closures

/**
 * Main flexible tube - OPEN hollow cylinder
 * This is the central component that connects two external components
 * 
 * @param L         Length of tubing (mm)
 * @param D_in      Inner diameter (mm)
 * @param D_out     Outer diameter (mm)
 * @param material  Material type identifier (for reference)
 * @param color_mat RGB color vector [R, G, B]
 * @param $fn       Circle resolution (higher = smoother)
 */
module fv_hoofdmateriaal(
    L = 500,
    D_in = 50,
    D_out = 60,
    material = "PU",
    color_mat = [0.9, 0.9, 0.95],
    $fn = 96
) {
    r_out = D_out / 2;
    r_in = D_in / 2;

    color(color_mat)
        difference() {
            // Outer cylinder
            cylinder(h = L, r = r_out, $fn = $fn);
            
            // Inner hollow (subtract to create tube)
            // Add 0.1mm extra height to avoid rendering artifacts
            cylinder(h = L + 0.1, r = r_in, $fn = $fn);
        }
}
