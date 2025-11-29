// products/filterslang/fs_shell.scad
// No top-level geometry here!

module fs_shell(
    L, D, t,
    medium,
    productzijde,
    $fn = 96
) {
    // Example: simple tube. Replace with your real logic.
    outer_r = D / 2;
    inner_r = outer_r - t;

    difference() {
        cylinder(h = L, r = outer_r, $fn = $fn);
        cylinder(h = L + 0.1, r = inner_r, $fn = $fn);
    }
}
