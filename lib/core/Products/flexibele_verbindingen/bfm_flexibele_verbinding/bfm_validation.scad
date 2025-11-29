// bfm_validation.scad
// BFM-Specific Validation Rules

use <bfm_data.scad>;

// ---------------------------------------------------------
// BFM Validation Functions
// ---------------------------------------------------------

function validate_bfm_pressure(D_out_val, working_pressure) =
    let (limits = get_size_family_limits(D_out_val))
    (working_pressure <= limits[0])
    ? true
    : false;

function validate_bfm_diameter_range(D_out_val) =
    (D_out_val >= 10 && D_out_val <= 100)
    ? true
    : false;

function validate_bfm_length(L_val) =
    (L_val >= 100 && L_val <= 1500)
    ? true
    : false;

// ---------------------------------------------------------
// BFM Validation Module
// ---------------------------------------------------------

module bfm_validate_all(D_out = 60, D_in = 50, L = 500, working_pressure = 200) {
    // Check diameter range
    assert(
        validate_bfm_diameter_range(D_out),
        str("BFM diameter out of range: ", D_out, " (10-100 mm only)")
    );
    
    // Check length range
    assert(
        validate_bfm_length(L),
        str("BFM length out of range: ", L, " (100-1500 mm only)")
    );
    
    // Check working pressure
    assert(
        validate_bfm_pressure(D_out, working_pressure),
        str("Working pressure ", working_pressure, " bar exceeds BFM limit for D_out=", D_out, " mm")
    );
    
    // Check wall thickness
    wall = (D_out - D_in) / 2;
    assert(wall >= 2 && wall <= 8, "BFM wall thickness must be 2-8 mm");
    
    echo("✓ All BFM validations passed");
}

echo("BFM validation module loaded");
