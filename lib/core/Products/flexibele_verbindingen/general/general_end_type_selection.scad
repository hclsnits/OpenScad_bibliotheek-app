// general_end_type_selection.scad
// PHASE C.1: End Type Selection & Routing with Validation
// ═════════════════════════════════════════════════════════════════════════════
// Select connector types, validate against environment (Phase A/B),
// and route to appropriate product variant (LAMPE or BFM).

use <general_application_context.scad>;
use <general_base_dimensions.scad>;

// ---------------------------------------------------------
// PHASE C.1: End Type Selection
// ---------------------------------------------------------

// Available connector types by variant
// LAMPE types: snelkoppeling (quick coupling), jacob (welding end), triclamp (sanitary)
// BFM types: bfm (spigot connections)
LAMPE_CONNECTORS = ["snelkoppeling", "jacob", "triclamp"];
BFM_CONNECTORS = ["bfm"];
ALL_CONNECTORS = ["snelkoppeling", "jacob", "triclamp", "bfm"];

// Selected end types (one for each end of the tube)
end_type_1 = "jacob";      // First end (typically inlet/bottom)
end_type_2 = "jacob";      // Second end (typically outlet/top)

// Optional: coupling orientation for snelkoppeling only
coupling_type_1 = "male";  // ["male", "female"] - only used if end_type_1="snelkoppeling"
coupling_type_2 = "female";// ["male", "female"] - only used if end_type_2="snelkoppeling"

// ---------------------------------------------------------
// PHASE C.1: Connector Specifications Database
// ---------------------------------------------------------
// Technical limits for each connector type

function get_connector_max_pressure(conn_type) =
    conn_type == "snelkoppeling" ? 250 :   // bar
    conn_type == "jacob" ? 50 :            // bar (welding integrity)
    conn_type == "triclamp" ? 100 :        // bar (sanitary fitting)
    conn_type == "bfm" ? 280 :             // bar (industrial standard)
    0;  // Unknown

function get_connector_max_temperature(conn_type) =
    conn_type == "snelkoppeling" ? 80 :    // °C
    conn_type == "jacob" ? 120 :           // °C (welded joint)
    conn_type == "triclamp" ? 100 :        // °C (sterilizable)
    conn_type == "bfm" ? 100 :             // °C
    0;  // Unknown

function get_connector_diameter_min(conn_type) =
    conn_type == "snelkoppeling" ? 12 :    // mm
    conn_type == "jacob" ? 20 :            // mm (welding head min)
    conn_type == "triclamp" ? 16 :         // mm
    conn_type == "bfm" ? 10 :              // mm
    0;  // Unknown

function get_connector_diameter_max(conn_type) =
    conn_type == "snelkoppeling" ? 100 :   // mm
    conn_type == "jacob" ? 150 :           // mm (welding head max)
    conn_type == "triclamp" ? 150 :        // mm
    conn_type == "bfm" ? 100 :             // mm (industrial limit)
    1000;  // Unknown

function supports_hygiene_class(conn_type, hygiene) =
    hygiene == "pharma" ? 
        (conn_type == "triclamp" || conn_type == "snelkoppeling") :  // Only sterile-compatible
    hygiene == "food" ?
        (conn_type == "triclamp" || conn_type == "snelkoppeling") :  // FDA approved types
    hygiene == "atex" ?
        (conn_type == "jacob" || conn_type == "snelkoppeling") :     // Non-sparking types
    true;  // General industrial allows all

// ---------------------------------------------------------
// PHASE C.1: Validation Functions
// ---------------------------------------------------------

function is_valid_connector_type(conn_type) =
    (conn_type == "snelkoppeling" || conn_type == "jacob" || 
     conn_type == "triclamp" || conn_type == "bfm")
    ? true
    : false;

// Validate connector against Phase A (environment constraints)
function validate_connector_vs_environment(conn_type, temp_cont, temp_surge, pressure_max, hygiene) =
    let (
        conn_max_p = get_connector_max_pressure(conn_type),
        conn_max_t = get_connector_max_temperature(conn_type),
        hygiene_ok = supports_hygiene_class(conn_type, hygiene)
    )
    (pressure_max <= conn_max_p && temp_surge <= conn_max_t && hygiene_ok)
    ? true
    : false;

// Validate connector against Phase B (geometry constraints)
function validate_connector_vs_geometry(conn_type, Din, Dout) =
    let (
        conn_min_d = get_connector_diameter_min(conn_type),
        conn_max_d = get_connector_diameter_max(conn_type)
    )
    (Dout >= conn_min_d && Dout <= conn_max_d)
    ? true
    : false;

// Determine if combination is valid
function validate_connector_pair(type_1, type_2, temp_cont, temp_surge, pressure_max, hygiene, Din, Dout) =
    (validate_connector_vs_environment(type_1, temp_cont, temp_surge, pressure_max, hygiene) &&
     validate_connector_vs_environment(type_2, temp_cont, temp_surge, pressure_max, hygiene) &&
     validate_connector_vs_geometry(type_1, Din, Dout) &&
     validate_connector_vs_geometry(type_2, Din, Dout))
    ? true
    : false;

// ---------------------------------------------------------
// PHASE C.1: Route to Product Variant
// ---------------------------------------------------------
// Determine which product variant based on connector types and constraints

function get_product_variant(type_1, type_2) =
    // If any end is BFM, use BFM variant (handles higher pressures, industrial)
    (type_1 == "bfm" || type_2 == "bfm")
    ? "bfm"
    // If both are LAMPE connectors, use LAMPE variant (lab/medical/pharma)
    : ((type_1 == "jacob" || type_1 == "snelkoppeling" || type_1 == "triclamp") &&
       (type_2 == "jacob" || type_2 == "snelkoppeling" || type_2 == "triclamp"))
    ? "lampe"
    // Mixed: default to LAMPE (can handle lower pressures)
    : "lampe";

selected_variant = get_product_variant(end_type_1, end_type_2);

// ---------------------------------------------------------
// PHASE C.1: Routing Decision Rationale
// ---------------------------------------------------------

function get_routing_reason(type_1, type_2) =
    (type_1 == "bfm" || type_2 == "bfm")
    ? "Contains BFM connector → industrial hydraulic variant"
    : ((type_1 == "jacob" || type_1 == "snelkoppeling" || type_1 == "triclamp") &&
       (type_2 == "jacob" || type_2 == "snelkoppeling" || type_2 == "triclamp"))
    ? "All LAMPE connectors → laboratory/medical/pharma variant"
    : "Mixed types → default to LAMPE variant";

routing_reason = get_routing_reason(end_type_1, end_type_2);

// ---------------------------------------------------------
// PHASE C.1: Run Validations
// ---------------------------------------------------------

assert(
    is_valid_connector_type(end_type_1),
    str("Invalid end_type_1: ", end_type_1, " (must be one of: ", ALL_CONNECTORS, ")")
);

assert(
    is_valid_connector_type(end_type_2),
    str("Invalid end_type_2: ", end_type_2, " (must be one of: ", ALL_CONNECTORS, ")")
);

assert(
    validate_connector_pair(end_type_1, end_type_2, process_temp_cont, process_temp_surge, 
                           process_pressure_max, hygiene_class, D_in, D_out),
    str("Connector pair incompatible with environment: ",
        "type1=", end_type_1, ", type2=", end_type_2, 
        " | pressure=", process_pressure_max, " bar, ",
        "surge_temp=", process_temp_surge, "°C, ",
        "hygiene=", hygiene_class, ", D_out=", D_out, " mm")
);

// ---------------------------------------------------------
// PHASE C.1: Echo End Type Selection & Routing to Console
// ---------------------------------------------------------

echo(str(""));
echo(str("╔═════════════════════════════════════════════════════════════════╗"));
echo(str("║  PHASE C.1: END TYPE SELECTION & ROUTING LOGIC                 ║"));
echo(str("╚═════════════════════════════════════════════════════════════════╝"));
echo(str(""));

echo(str("🔌 CONNECTOR SELECTION"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  End 1 (Inlet): ", end_type_1));
echo(str("  End 2 (Outlet): ", end_type_2));
if (end_type_1 == "snelkoppeling") echo(str("    Coupling 1: ", coupling_type_1));
if (end_type_2 == "snelkoppeling") echo(str("    Coupling 2: ", coupling_type_2));
echo(str(""));

echo(str("🔍 VALIDATION RESULTS"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Pressure Check: ", 
    process_pressure_max <= get_connector_max_pressure(end_type_1) &&
    process_pressure_max <= get_connector_max_pressure(end_type_2)
    ? "✓ PASS" : "✗ FAIL"));
echo(str("    Max allowed: ", 
    min(get_connector_max_pressure(end_type_1), get_connector_max_pressure(end_type_2)), " bar"));
echo(str("    Required: ", process_pressure_max, " bar"));

echo(str("  Temperature Check: ",
    process_temp_surge <= get_connector_max_temperature(end_type_1) &&
    process_temp_surge <= get_connector_max_temperature(end_type_2)
    ? "✓ PASS" : "✗ FAIL"));
echo(str("    Max allowed: ",
    min(get_connector_max_temperature(end_type_1), get_connector_max_temperature(end_type_2)), "°C"));
echo(str("    Required: ", process_temp_surge, "°C"));

echo(str("  Diameter Check: ",
    D_out >= max(get_connector_diameter_min(end_type_1), get_connector_diameter_min(end_type_2)) &&
    D_out <= min(get_connector_diameter_max(end_type_1), get_connector_diameter_max(end_type_2))
    ? "✓ PASS" : "✗ FAIL"));
echo(str("    Range: ",
    max(get_connector_diameter_min(end_type_1), get_connector_diameter_min(end_type_2)), "-",
    min(get_connector_diameter_max(end_type_1), get_connector_diameter_max(end_type_2)), " mm"));
echo(str("    Required: ", D_out, " mm"));

echo(str("  Hygiene Check: ",
    supports_hygiene_class(end_type_1, hygiene_class) &&
    supports_hygiene_class(end_type_2, hygiene_class)
    ? "✓ PASS" : "✗ FAIL"));
echo(str("    Class: ", hygiene_class));
echo(str(""));

echo(str("🛣️  ROUTING DECISION"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Selected Variant: ", selected_variant, " (UPPER CASE)"));
echo(str("  Reason: ", routing_reason));
echo(str(""));

echo(str("✓ All Phase C.1 validations passed"));
echo(str(""));
