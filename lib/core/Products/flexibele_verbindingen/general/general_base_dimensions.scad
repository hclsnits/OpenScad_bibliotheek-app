// general_base_dimensions.scad
// PHASE B: Base Dimensions & Shared Geometry
// ═════════════════════════════════════════════════════════════════════════════
// Centralized dimension definitions shared across all product variants.
// Holds: tube geometry, gap lengths, size families, conversion helpers.

use <general_application_context.scad>;

// ---------------------------------------------------------
// PHASE B: Core Tube Dimensions
// ---------------------------------------------------------

// Tube inner diameter (mm)
// Range depends on application; validate below
D_in = 50;  // [10:150]

// Tube outer diameter (mm)
// Always: D_out = D_in + 2*wall_thickness
D_out = 60;  // [15:160]

// Tube length (mm)
// Range: LAMPE [100:2000], BFM [100:1500]
L_tube = 500;  // [100:2000]

// ---------------------------------------------------------
// PHASE B: Gap & Spacing Parameters
// ---------------------------------------------------------

// Gap length between components (mm)
// Space between tube end and connector start
gap_length = 10;  // [0:50]

// Target nominal diameter for sizing classification
// Used to classify tube families and connector compatibility
// Common: 16, 19, 22, 25, 32, 38, 50, 64 (ISO standard sizes in mm)
target_nominal_diameter = 50;  // [10:100]

// ---------------------------------------------------------
// PHASE B: Wall Thickness Calculation
// ---------------------------------------------------------

wall_thickness = (D_out - D_in) / 2;

// Validate wall thickness is positive
assert(
    wall_thickness > 0,
    str("Invalid wall_thickness: ", wall_thickness, " (D_out must be > D_in)")
);

// ---------------------------------------------------------
// PHASE B: Size Family Classification
// ---------------------------------------------------------

// Standard ISO nominal diameters for tubing
function get_size_family(nominal) =
    let (families = [
        [10, "very_small"],
        [16, "small"],
        [19, "compact"],
        [22, "standard"],
        [25, "medium"],
        [32, "large"],
        [38, "xlarge"],
        [50, "xxlarge"],
        [64, "industrial"]
    ])
    // Find closest match in families
    families[search(nominal, families, 1, 0)[0]][1];

target_family = get_size_family(target_nominal_diameter);

// ---------------------------------------------------------
// PHASE B: Diameter Conversion Helpers
// ---------------------------------------------------------

// Convert nominal diameter to equivalent inner diameter
// (Approximation: D_in ≈ nominal - 2 to nominal - 4)
function nominal_to_Din(nominal) =
    nominal > 38 ? nominal - 4 :
    nominal > 25 ? nominal - 3 :
    nominal - 2;

// Convert nominal diameter to equivalent outer diameter
// (Approximation: D_out ≈ nominal)
function nominal_to_Dout(nominal) =
    nominal * 1.2;  // Typical ratio

// Get inner diameter from outer diameter and target wall thickness
function Dout_to_Din(dout, wall = wall_thickness) =
    dout - 2 * wall;

// Get outer diameter from inner diameter and target wall thickness
function Din_to_Dout(din, wall = wall_thickness) =
    din + 2 * wall;

// ---------------------------------------------------------
// PHASE B: Dimension Range Validation
// ---------------------------------------------------------

// Get max length based on application
function get_max_length(app) =
    app == "lampe" ? 2000 :
    app == "bfm" ? 1500 :
    2000;

// Get max inner diameter based on application
function get_max_D_in(app) =
    app == "lampe" ? 100 :
    app == "bfm" ? 80 :
    100;

// Get max outer diameter based on application
function get_max_D_out(app) =
    app == "lampe" ? 150 :
    app == "bfm" ? 100 :
    150;

// Validate all dimensions
function validate_dimensions(L, Din, Dout, app = "lampe") =
    (L > 0 && L <= get_max_length(app) &&
     Din > 0 && Din <= get_max_D_in(app) &&
     Dout > Din && Dout <= get_max_D_out(app))
    ? true
    : false;

function validate_gap_length(gap) =
    (gap >= 0 && gap <= 50)
    ? true
    : false;

function validate_nominal_diameter(nominal) =
    (nominal > 0 && nominal <= 200)
    ? true
    : false;

// Run dimension validations
assert(
    validate_dimensions(L_tube, D_in, D_out, process_medium),
    str("Invalid dimensions: L=", L_tube, " mm, D_in=", D_in, 
        " mm, D_out=", D_out, " mm")
);

assert(
    validate_gap_length(gap_length),
    str("Invalid gap_length: ", gap_length, " (must be 0-50 mm)")
);

assert(
    validate_nominal_diameter(target_nominal_diameter),
    str("Invalid target_nominal_diameter: ", target_nominal_diameter)
);

// ---------------------------------------------------------
// PHASE B: Derived Dimensions
// ---------------------------------------------------------

// Calculate tube cross-section area (for flow calculations, informational)
A_tube = (D_out^2 - D_in^2) * 3.14159 / 4;

// Tube volume (mm³)
V_tube = A_tube * L_tube;

// ---------------------------------------------------------
// PHASE B: Echo Base Dimensions to Console
// ---------------------------------------------------------

echo(str(""));
echo(str("╔═════════════════════════════════════════════════════════════════╗"));
echo(str("║  PHASE B: BASE DIMENSIONS & SHARED GEOMETRY                    ║"));
echo(str("╚═════════════════════════════════════════════════════════════════╝"));
echo(str(""));

echo(str("📏 TUBE GEOMETRY"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Length: ", L_tube, " mm"));
echo(str("  Outer Diameter: ", D_out, " mm"));
echo(str("  Inner Diameter: ", D_in, " mm"));
echo(str("  Wall Thickness: ", wall_thickness, " mm"));
echo(str(""));

echo(str("📍 SPACING & GAPS"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Gap Length: ", gap_length, " mm"));
echo(str("  Target Nominal: ", target_nominal_diameter, " mm"));
echo(str("  Size Family: ", target_family));
echo(str(""));

echo(str("📊 DERIVED PARAMETERS"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Cross-section Area: ", A_tube, " mm²"));
echo(str("  Volume: ", V_tube, " mm³"));
echo(str(""));

echo(str("✓ All Phase B validations passed"));
echo(str(""));
