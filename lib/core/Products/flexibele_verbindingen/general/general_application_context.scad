// general_application_context.scad
// PHASE A: Application Context & Environment
// ═════════════════════════════════════════════════════════════════════════════
// Holds environment-level context that applies across the entire system.
// No product-specific decisions; just environment definition.

// ---------------------------------------------------------
// PHASE A: Process Medium & Environment Definition
// ---------------------------------------------------------

// Process medium type
// "water"        → Water/aqueous applications
// "air"          → Pneumatic/compressed air
// "oil"          → Hydraulic oil
// "food"         → Food-grade fluids
// "pharma"       → Pharmaceutical/sterile
// "chemical"     → Chemical resistant needed
process_medium = "water";  // [water, air, oil, food, pharma, chemical]

// ---------------------------------------------------------
// PHASE A: Hygiene & Certification Class
// ---------------------------------------------------------

// Hygiene classification
// "general"      → Standard industrial
// "food"         → Food processing (FDA/3A)
// "pharma"       → Pharmaceutical (USP/EP)
// "atex"         → Explosion-proof environment
hygiene_class = "general";  // [general, food, pharma, atex]

// ATEX zone classification (if applicable)
// 0 = normal operation (no gas), 1 = occasional, 2 = rare
atex_zone = 2;  // [0, 1, 2] - only relevant if hygiene_class="atex"

// ---------------------------------------------------------
// PHASE A: Temperature Profile
// ---------------------------------------------------------

// Continuous operating temperature (°C)
process_temp_cont = 20;  // [-40:100]

// Surge/peak temperature (°C) - can exceed continuous rating briefly
process_temp_surge = 60;  // [-40:120]

// Minimum ambient/storage temperature (°C)
process_temp_min = -10;  // [-60:50]

// ---------------------------------------------------------
// PHASE A: Pressure Profile
// ---------------------------------------------------------

// Maximum working pressure (bar)
process_pressure_max = 10;  // [1:350]

// Intermittent peak pressure (bar) - short duration spikes
process_pressure_surge = 15;  // [1:400]

// ---------------------------------------------------------
// PHASE A: Validation & Constraints
// ---------------------------------------------------------

function validate_temperature_profile(t_cont, t_surge, t_min) =
    (t_cont >= t_min && t_surge >= t_cont && t_min < t_surge)
    ? true
    : false;

function validate_pressure_profile(p_cont, p_surge) =
    (p_surge >= p_cont && p_cont > 0 && p_surge > 0)
    ? true
    : false;

function validate_hygiene_class(hygiene) =
    (hygiene == "general" || hygiene == "food" || 
     hygiene == "pharma" || hygiene == "atex")
    ? true
    : false;

function validate_process_medium(medium) =
    (medium == "water" || medium == "air" || medium == "oil" || 
     medium == "food" || medium == "pharma" || medium == "chemical")
    ? true
    : false;

// Run validations
assert(
    validate_temperature_profile(process_temp_cont, process_temp_surge, process_temp_min),
    str("Invalid temperature profile: cont=", process_temp_cont, 
        ", surge=", process_temp_surge, ", min=", process_temp_min)
);

assert(
    validate_pressure_profile(process_pressure_max, process_pressure_surge),
    str("Invalid pressure profile: max=", process_pressure_max, 
        ", surge=", process_pressure_surge)
);

assert(
    validate_hygiene_class(hygiene_class),
    str("Invalid hygiene_class: ", hygiene_class)
);

assert(
    validate_process_medium(process_medium),
    str("Invalid process_medium: ", process_medium)
);

// ATEX validation
if (hygiene_class == "atex") {
    assert(
        (atex_zone >= 0 && atex_zone <= 2),
        str("Invalid ATEX zone: ", atex_zone, " (must be 0, 1, or 2)")
    );
}

// ---------------------------------------------------------
// PHASE A: Helper Functions for Other Phases
// ---------------------------------------------------------

// Get required material resistance based on medium
function get_material_requirement(medium) =
    medium == "oil" ? "oil-resistant" :
    medium == "chemical" ? "chemical-resistant" :
    medium == "pharma" ? "USP/EP-compliant" :
    medium == "food" ? "FDA-compliant" :
    "general-purpose";

// Get max working pressure by hygiene class
// (used by C.1 routing to decide LAMPE vs BFM)
function get_max_pressure_by_class(hygiene) =
    hygiene == "pharma" ? 10 :
    hygiene == "food" ? 20 :
    hygiene == "atex" ? 8 :
    200;  // BFM-range for "general"

// Get certifications required by hygiene class
function get_required_certifications(hygiene) =
    hygiene == "pharma" ? ["USP <87>", "EP 2.9.49"] :
    hygiene == "food" ? ["FDA", "3A", "FSMA"] :
    hygiene == "atex" ? ["ATEX 2014/34/EU", "UKCA"] :
    [];

// ---------------------------------------------------------
// PHASE A: Echo Application Context to Console
// ---------------------------------------------------------

echo(str(""));
echo(str("╔═════════════════════════════════════════════════════════════════╗"));
echo(str("║  PHASE A: APPLICATION CONTEXT & ENVIRONMENT                    ║"));
echo(str("╚═════════════════════════════════════════════════════════════════╝"));
echo(str(""));
echo(str("📋 PROCESS ENVIRONMENT"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Medium: ", process_medium));
echo(str("  Hygiene Class: ", hygiene_class));
if (hygiene_class == "atex") {
    echo(str("  ATEX Zone: ", atex_zone));
}
echo(str(""));

echo(str("🌡️  TEMPERATURE PROFILE"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Continuous: ", process_temp_cont, "°C"));
echo(str("  Surge Peak: ", process_temp_surge, "°C"));
echo(str("  Min Storage: ", process_temp_min, "°C"));
echo(str(""));

echo(str("⚙️  PRESSURE PROFILE"));
echo(str("─────────────────────────────────────────────────────────────────"));
echo(str("  Working Max: ", process_pressure_max, " bar"));
echo(str("  Surge Peak: ", process_pressure_surge, " bar"));
echo(str("  Material Req: ", get_material_requirement(process_medium)));
echo(str(""));

echo(str("✓ All Phase A validations passed"));
echo(str(""));

