// bfm_data.scad
// BFM Data Tables - Materials, pressure limits, certifications

// ---------------------------------------------------------
// BFM Material Specifications
// ---------------------------------------------------------

BFM_MATERIALS = [
    ["PU", [1.0, 1.0, 1.0, 0.15], "Polyurethane", 280, 100],
    ["silicone", [0.8, 0.2, 0.2], "Silicone", 210, 120],
    ["EPDM", [0.2, 0.5, 0.2], "EPDM", 160, 140],
    ["PVC", [0.5, 0.5, 0.5], "Rigid PVC", 100, 60]
];

// ---------------------------------------------------------
// Size Limits for BFM
// ---------------------------------------------------------

BFM_SIZE_LIMITS = [
    ["small", 10, 25, 5],        // [family, min_D, max_D, max_pressure_bar]
    ["medium", 25, 75, 280],
    ["large", 75, 100, 200]
];

// ---------------------------------------------------------
// Certification Strings
// ---------------------------------------------------------

BFM_CERTIFICATIONS = [
    "ISO 4401 (NG10)",
    "ISO 6149 (NPT/BSPP)",
    "CE 2014/68/EU (PED)",
    "AD 2000"
];

// ---------------------------------------------------------
// Helper Functions
// ---------------------------------------------------------

function get_material_color(material_name) =
    material_name == "PU" ? [1.0, 1.0, 1.0, 0.15] :
    material_name == "silicone" ? [0.8, 0.2, 0.2] :
    material_name == "EPDM" ? [0.2, 0.5, 0.2] :
    material_name == "PVC" ? [0.5, 0.5, 0.5] :
    [0.7, 0.7, 0.7];

function get_material_max_pressure(material_name) =
    material_name == "PU" ? 280 :
    material_name == "silicone" ? 210 :
    material_name == "EPDM" ? 160 :
    material_name == "PVC" ? 100 :
    100;

function get_size_family_limits(D_out_val) =
    (D_out_val <= 25) ? [5, "small"] :
    (D_out_val <= 75) ? [280, "medium"] :
    (D_out_val <= 100) ? [200, "large"] :
    [100, "extra_large"];

echo("BFM Data tables loaded");
