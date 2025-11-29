// general_evaluation.scad
// PHASE E: Comprehensive Evaluation, Validation & Summary
// ═════════════════════════════════════════════════════════════════════════════
// Final multi-block validation pass across all constraints and environment.
// Generate structured 4-block summary report of the complete design.

use <general_application_context.scad>;
use <general_base_dimensions.scad>;
use <general_end_type_selection.scad>;

// ---------------------------------------------------------
// PHASE E: Comprehensive Validation Functions
// ---------------------------------------------------------

// Block 1 validation: Identity & use case
function validate_identity_block(
    process_medium, hygiene_class, atex_zone, variant
) =
    (process_medium != "" && hygiene_class != "" && variant != "")
    ? true
    : false;

// Block 2 validation: Geometry consistency
function validate_geometry_block(
    L, D_in, D_out, wall, gap_length
) =
    (L > 0 && D_in > 0 && D_out > D_in && wall > 0 && gap_length >= 0 &&
     wall >= 0.5 && wall <= 15)
    ? true
    : false;

// Block 3 validation: End connections compatibility
function validate_connections_block(
    end_type_1, end_type_2, D_out, pressure_max, temp_surge, hygiene_class
) =
    (is_valid_connector_type(end_type_1) && is_valid_connector_type(end_type_2) &&
     validate_connector_vs_geometry(end_type_1, D_out, D_out) &&
     validate_connector_vs_geometry(end_type_2, D_out, D_out) &&
     validate_connector_vs_environment(end_type_1, 0, temp_surge, pressure_max, hygiene_class) &&
     validate_connector_vs_environment(end_type_2, 0, temp_surge, pressure_max, hygiene_class))
    ? true
    : false;

// Block 4 validation: Technical limits
function validate_limits_block(
    L, D_out, wall, pressure_max, temp_cont, temp_surge, temp_min, variant
) =
    let (
        max_L = (variant == "lampe") ? 2000 : 1500,
        max_D = (variant == "lampe") ? 150 : 100,
        max_P = (variant == "lampe") ? 50 : 280,
        max_T = (variant == "lampe") ? 100 : 100
    )
    (L <= max_L && D_out <= max_D && pressure_max <= max_P && 
     temp_surge <= max_T && temp_cont <= temp_surge && temp_min <= temp_cont)
    ? true
    : false;

// ---------------------------------------------------------
// PHASE E: Global Validation Module
// ---------------------------------------------------------

module general_validation(
    L = 500,
    D_in = 50,
    D_out = 60,
    gap = 10,
    process_medium = "water",
    hygiene = "general",
    temp_cont = 20,
    temp_surge = 60,
    temp_min = -10,
    pressure_max = 10,
    variant = "lampe",
    end_1 = "jacob",
    end_2 = "jacob"
) {
    wall = (D_out - D_in) / 2;
    
    // Block 1: Identity validation
    assert(
        validate_identity_block(process_medium, hygiene, 0, variant),
        "VALIDATION FAILED: Identity/use case block"
    );
    
    // Block 2: Geometry validation
    assert(
        validate_geometry_block(L, D_in, D_out, wall, gap),
        str("VALIDATION FAILED: Geometry block (L=", L, ", D_in=", D_in, 
            ", D_out=", D_out, ", wall=", wall, ")")
    );
    
    // Block 3: Connections validation
    assert(
        validate_connections_block(end_1, end_2, D_out, pressure_max, temp_surge, hygiene),
        str("VALIDATION FAILED: Connections block (end_1=", end_1, ", end_2=", end_2, ")")
    );
    
    // Block 4: Technical limits validation
    assert(
        validate_limits_block(L, D_out, wall, pressure_max, temp_cont, temp_surge, temp_min, variant),
        str("VALIDATION FAILED: Technical limits block (variant=", variant, ", pressure=", pressure_max, " bar)")
    );
}

// ---------------------------------------------------------
// PHASE E: Generate Comprehensive 4-Block Summary Report
// ---------------------------------------------------------

module generate_summary_report(
    L = 500,
    D_in = 50,
    D_out = 60,
    wall = 5,
    gap = 10,
    process_medium = "water",
    hygiene_class = "general",
    atex_zone = 2,
    process_temp_cont = 20,
    process_temp_surge = 60,
    process_temp_min = -10,
    process_pressure_max = 10,
    process_pressure_surge = 15,
    variant = "lampe",
    end_type_1 = "jacob",
    end_type_2 = "jacob"
) {
    // Run all validations first
    general_validation(
        L, D_in, D_out, gap, process_medium, hygiene_class,
        process_temp_cont, process_temp_surge, process_temp_min,
        process_pressure_max, variant, end_type_1, end_type_2
    );
    
    echo(str(""));
    echo(str("╔═════════════════════════════════════════════════════════════════╗"));
    echo(str("║  PHASE E: COMPREHENSIVE DESIGN SUMMARY & VALIDATION REPORT     ║"));
    echo(str("╚═════════════════════════════════════════════════════════════════╝"));
    echo(str(""));
    
    // ─────────────────────────────────────────────────────────────────────────
    // BLOCK 1: IDENTITY & USE CASE
    // ─────────────────────────────────────────────────────────────────────────
    echo(str("📋 BLOCK 1: IDENTITY & USE CASE"));
    echo(str("─────────────────────────────────────────────────────────────────"));
    echo(str("  Process Medium: ", process_medium));
    echo(str("  Hygiene Class: ", hygiene_class));
    if (hygiene_class == "atex") {
        echo(str("  ATEX Zone: ", atex_zone));
    }
    echo(str("  Product Variant: ", variant));
    echo(str("  Intended Use: ", 
        variant == "lampe" ? "Laboratory/Medical/Pharma flexible connections" :
        variant == "bfm" ? "Industrial hydraulic/pneumatic fittings" :
        "General purpose flexible connector"));
    echo(str(""));
    
    // ─────────────────────────────────────────────────────────────────────────
    // BLOCK 2: GEOMETRY
    // ─────────────────────────────────────────────────────────────────────────
    echo(str("📐 BLOCK 2: GEOMETRY"));
    echo(str("─────────────────────────────────────────────────────────────────"));
    echo(str("  Tube Length: ", L, " mm"));
    echo(str("  Outer Diameter (D_out): ", D_out, " mm"));
    echo(str("  Inner Diameter (D_in): ", D_in, " mm"));
    echo(str("  Wall Thickness: ", wall, " mm"));
    echo(str("  Gap Length: ", gap, " mm"));
    echo(str("  Cross-section Area: ", (D_out^2 - D_in^2) * 3.14159 / 4, " mm²"));
    echo(str("  Total Volume: ", (D_out^2 - D_in^2) * 3.14159 * L / 4, " mm³"));
    echo(str(""));
    
    // ─────────────────────────────────────────────────────────────────────────
    // BLOCK 3: END CONNECTIONS
    // ─────────────────────────────────────────────────────────────────────────
    echo(str("🔌 BLOCK 3: END CONNECTIONS"));
    echo(str("─────────────────────────────────────────────────────────────────"));
    echo(str("  End 1 (Inlet): ", end_type_1));
    echo(str("    • Max Pressure: ", get_connector_max_pressure(end_type_1), " bar"));
    echo(str("    • Max Temperature: ", get_connector_max_temperature(end_type_1), "°C"));
    echo(str("    • Diameter Range: ", get_connector_diameter_min(end_type_1), "-",
        get_connector_diameter_max(end_type_1), " mm"));
    echo(str(""));
    echo(str("  End 2 (Outlet): ", end_type_2));
    echo(str("    • Max Pressure: ", get_connector_max_pressure(end_type_2), " bar"));
    echo(str("    • Max Temperature: ", get_connector_max_temperature(end_type_2), "°C"));
    echo(str("    • Diameter Range: ", get_connector_diameter_min(end_type_2), "-",
        get_connector_diameter_max(end_type_2), " mm"));
    echo(str(""));
    
    // ─────────────────────────────────────────────────────────────────────────
    // BLOCK 4: TECHNICAL LIMITS & VALIDATION
    // ─────────────────────────────────────────────────────────────────────────
    echo(str("⚙️  BLOCK 4: TECHNICAL LIMITS & OPERATING RANGE"));
    echo(str("─────────────────────────────────────────────────────────────────"));
    echo(str("  Operating Pressure:"));
    echo(str("    • Continuous: ", process_pressure_max, " bar"));
    echo(str("    • Surge Peak: ", process_pressure_surge, " bar"));
    echo(str("    • Limiting Connector: ",
        min(get_connector_max_pressure(end_type_1), get_connector_max_pressure(end_type_2)), " bar max"));
    echo(str(""));
    echo(str("  Temperature Profile:"));
    echo(str("    • Minimum: ", process_temp_min, "°C"));
    echo(str("    • Continuous: ", process_temp_cont, "°C"));
    echo(str("    • Surge Peak: ", process_temp_surge, "°C"));
    echo(str("    • Limiting Connector: ",
        min(get_connector_max_temperature(end_type_1), get_connector_max_temperature(end_type_2)), "°C max"));
    echo(str(""));
    echo(str("  Material Requirements:"));
    echo(str("    • Material Spec: ", get_material_requirement(process_medium)));
    echo(str("    • Certifications: ", 
        let (certs = get_required_certifications(hygiene_class))
        (certs == [] ? "General industrial" : str(certs))));
    echo(str(""));
    echo(str("  Variant-Specific Limits (", variant, "):"));
    if (variant == "lampe") {
        echo(str("    • Max Length: 2000 mm (current: ", L, " mm)"));
        echo(str("    • Max Diameter: 150 mm (current: ", D_out, " mm)"));
        echo(str("    • Max Pressure: 50 bar (current: ", process_pressure_max, " bar)"));
        echo(str("    • Max Temperature: 100°C (current: ", process_temp_surge, "°C)"));
    } else if (variant == "bfm") {
        echo(str("    • Max Length: 1500 mm (current: ", L, " mm)"));
        echo(str("    • Max Diameter: 100 mm (current: ", D_out, " mm)"));
        echo(str("    • Max Pressure: 280 bar (current: ", process_pressure_max, " bar)"));
        echo(str("    • Max Temperature: 100°C (current: ", process_temp_surge, "°C)"));
    }
    echo(str(""));
    
    // ─────────────────────────────────────────────────────────────────────────
    // VALIDATION SUMMARY
    // ─────────────────────────────────────────────────────────────────────────
    echo(str("✅ VALIDATION STATUS"));
    echo(str("─────────────────────────────────────────────────────────────────"));
    echo(str("  ✓ Block 1: Identity & Use Case"));
    echo(str("  ✓ Block 2: Geometry"));
    echo(str("  ✓ Block 3: End Connections"));
    echo(str("  ✓ Block 4: Technical Limits"));
    echo(str(""));
    echo(str("  All constraints satisfied. Design is VALID for manufacturing."));
    echo(str(""));
    echo(str(""));
    
    echo(str("═══════════════════════════════════════════════════════════════"));
}

// ---------------------------------------------------------
// Run validation
// ---------------------------------------------------------
// Note: uncomment when all parameters are defined
// general_validation(L=L_tube, D_in=D_in, D_out=D_out, app=application, variant=selected_variant);
