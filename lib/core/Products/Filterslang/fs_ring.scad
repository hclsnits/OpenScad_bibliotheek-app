// products/filterslang/fs_rings.scad
// Ring distribution around the shell.

module fs_rings(
    L, D,
    rings_auto,
    rings_count,
    rings_positions,  // [] or list of z-positions
    ring_w,
    ring_t,
    $fn = 96
) {
    outer_r = D / 2 + ring_t;
    inner_r = outer_r - ring_t;

    // Determine positions
    ring_zs = rings_positions;
    if (rings_auto && rings_count > 0) {
        step = L / (rings_count + 1);
        ring_zs = [for (i = [1:rings_count]) i * step];
    }

    for (zpos = ring_zs)
        translate([0, 0, zpos - ring_w/2])
            difference() {
                cylinder(h = ring_w, r = outer_r, $fn = $fn);
                cylinder(h = ring_w + 0.1, r = inner_r, $fn = $fn);
            }
}
