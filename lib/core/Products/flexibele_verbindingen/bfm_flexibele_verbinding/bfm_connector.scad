// bfm_connector.scad
// BFM Main Flexible Connector Body

/**
 * BFM flexible connector - open tube for hydraulic/pneumatic applications
 */
module bfm_connector(
    L = 500,
    D_in = 50,
    D_out = 60,
    color_mat = [1.0, 1.0, 1.0, 0.15],
    $fn = 96
) {
    r_out = D_out / 2;
    r_in = D_in / 2;

    color(color_mat)
        difference() {
            cylinder(h = L, r = r_out, $fn = $fn);
            cylinder(h = L + 0.1, r = r_in, $fn = $fn);
        }
}
