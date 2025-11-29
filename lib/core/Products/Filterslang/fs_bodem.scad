// products/filterslang/fs_bottoms.scad
// Bottom variants for filterslang.

module fs_bottom(
    D, t,
    bottom,      // e.g. "platdicht", "open", "conisch"
    bottom_opt,  // e.g. "zoom", "none"
    $fn = 96
) {
    // Example placeholder shapes; replace with your real variants.
    outer_r = D / 2;
    inner_r = outer_r - t;

    if (bottom == "platdicht") {
        // Flat disk
        cylinder(h = t, r = outer_r, $fn = $fn);
    } else if (bottom == "open") {
        // No bottom: nothing drawn
    } else if (bottom == "conisch") {
        // Simple cone bottom
        cone_h = 3 * t;
        cylinder(h = cone_h, r1 = outer_r, r2 = inner_r, $fn = $fn);
    }

    // Optionally add zoom/flange features
    if (bottom_opt == "zoom") {
        translate([0, 0, t])
            cylinder(h = t, r = outer_r + t, $fn = $fn);
    } else if (bottom_opt == "flens") {
        translate([0, 0, t])
            cylinder(h = t, r = outer_r + 2 * t, $fn = $fn);
    }
}
