// products/filterslang/fs_reinforce.scad
// Adds reinforcement bands over certain spans.

module fs_reinforce(
    L, D, t,
    reinforce_enable,
    reinforce_side,   // "boven", "onder", "beide"
    reinforce_spans,  // e.g. [[100, 200]]
    $fn = 96
) {
    if (!reinforce_enable)
        return;

    outer_r = D / 2 + 2 * t;

    // Simple example: thicker bands over given spans.
    // Adjust based on reinforce_side if needed.
    for (span = reinforce_spans) {
        z_start = span[0];
        z_end   = span[1];
        band_h  = z_end - z_start;

        translate([0, 0, z_start])
            cylinder(h = band_h, r = outer_r, $fn = $fn);
    }
}
