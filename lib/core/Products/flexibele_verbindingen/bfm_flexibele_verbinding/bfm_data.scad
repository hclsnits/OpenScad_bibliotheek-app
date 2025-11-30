// bfm_data.scad
// =====================================================================
// BFM Data Tables - Materials, limits, certifications & "Other" rules
// Derived from the BFM Quick Reference Limitations Summary (especially p.2)
// This file contains NO geometry, only data + lookup functions.
// =====================================================================


// =====================================================================
// 1. PRODUCT-SPECIFIC DATA (temperature, pressure, certifications)
// =====================================================================
//
// BFM_PRODUCT_SPECS = [
//   id,                  // short code used in configurator
//   label,               // readable name
//   temp_cont_min_C,     // minimum continuous temperature (°C) - undef if unknown
//   temp_cont_max_C,     // maximum continuous temperature (°C)
//   temp_surge_C,        // short peak temperature (°C)
//   max_pressure_psi,    // max. pressure in PSI
//   surface_resistivity, // text from table (order of magnitude / "Insulative" / "N/A")
//   foodsafe_approval,   // true if FDA + EU mentioned
//   threeA_certified,    // true if 3-A "Yes (20-)" indicated
//   atex_category        // "all_dust" | "restrictions" | "yes"
// ]

BFM_PRODUCT_SPECS = [
    ["020E", "Seeflex 020E",
        -25, 80,          // continuous temperature
        100,              // surge
        1.5,              // PSI
        "10^10 Ω",
        true,             // foodsafe (FDA + EU)
        true,             // 3-A yes
        "all_dust"        // ATEX: all dust zones (some restrictions)
    ],
    ["040E", "Seeflex 040E",
        -25, 110,
        120,
        5.0,
        "10^10 Ω",
        true,
        true,
        "all_dust"
    ],
    ["040AS", "Seeflex 040AS",
        -25, 95,
        100,
        3.5,
        "10^8 Ω",
        true,
        true,
        "all_dust"
    ],
    ["060ES", "Seeflex 060ES",
        -25, 110,
        140,
        24.0,
        "10^10 Ω",
        true,
        true,
        "all_dust"
    ],
    ["TNPB", "Teflex NP (Black)",
        -73, 300,
        316,
        3.0,
        "10^6 Ω",
        true,
        true,
        "all_dust"
    ],
    ["FLEXI", "Flexi (& Flexi-Light/Earthed)",
        20, 85,
        100,
        3.0,
        "N/A",
        true,
        true,
        "all_dust"
    ],
    ["LM4", "LM4",
        undef, 130,       // lower bound not specified → undef
        150,
        3.0,
        "10^9 Ω",
        true,
        true,
        "restrictions"    // ATEX: "Restrictions apply"
    ],
    ["LM3", "LM3",
        undef, 110,
        150,
        3.0,
        "10^7 Ω",
        true,
        true,
        "restrictions"
    ],
    ["TWOVEN", "Teflex (Woven)",
        250, 250,         // table: ">250°C" → here as lowest continuous value 250°C
        300,
        3.0,
        "Insulative",
        true,
        false,            // 3-A not explicitly mentioned
        "restrictions"
    ],
    ["FM1", "FM1",
        undef, 130,
        150,
        3.0,
        "Insulative",
        true,
        false,
        "restrictions"
    ],
    ["TNPO", "Teflex NP (Opaque)",
        undef, 300,
        316,
        3.0,
        "Insulative",
        true,
        false,            // "TBC" in table → not yet 3-A
        "yes"             // ATEX: "Yes"
    ]
];


// =====================================================================
// 2. CONNECTOR LIMITS WITHOUT RINGS (per product type)
// =====================================================================
//
// BFM_CONNECTOR_LIMITS = [
//   id,
//   min_diameter_mm,                 // smallest Ø for which type is available
//   max_diameter_mm_without_rings,   // largest Ø without rings for this type
//   min_length_mm,                   // minimum connector length (CL, body-only)
//   max_length_mm_for_dia_le_650_mm  // max. length at Ø ≤ 650mm
// ]
//
// For Ø > 650mm, general bucket rules apply (section 3).

BFM_CONNECTOR_LIMITS = [
    ["020E", 100, 1650,  80, 6000],  // 6000mm max for Seeflex 020E/040E/040AS & Flexi-range
    ["040E", 100, 1650,  80, 6000],
    ["040AS",100, 1650,  80, 6000],
    ["060ES",100, 1650,  80, 1000],  // 1000mm max
    ["TNPB",100,  500,  80, 1000],   // 500mm max Ø, 1000mm max length
    ["FLEXI",100, 350, 200, 6000],   // 200mm Flexi/Light; 250mm Flexi-Earthed (see comment)
    ["LM4", 100, 1650,  80, 1500],
    ["LM3", 100, 1650,  80, 1500],
    ["TWOVEN",100,1650, 80, 1500],
    ["FM1", 100,  650, 100, 1000],   // min 100mm, max 1000mm
    ["TNPO",100,  500,  80, 1000]
];


// =====================================================================
// 3. GENERAL LENGTH BUCKETS FOR LARGE DIAMETERS (without rings)
// =====================================================================
//
// From table "CONNECTORS (without rings)":
// - Ø 700–1000mm → max 500mm length
// - Ø 1050–1650mm → max 200mm length
//
// This array is mainly documentary; bfm_get_max_length_no_rings uses
// the same values internally.

BFM_CONNECTOR_LENGTH_BUCKETS = [
    ["700_1000",   700, 1000, 500], // Ø 700–1000mm → max 500mm
    ["1050_1650", 1050, 1650, 200]  // Ø 1050–1650mm → max 200mm
];


// =====================================================================
// 4. CONNECTOR LIMITS WITH RINGS (per product type) + "Other" ring-info
// =====================================================================
//
// The "WITH RINGS" column + "Other" yield:
// - minimum length with rings (150mm for all)
// - maximum lengths per Ø bucket
// - max ring count: 10 (Teflex NP: 8)
// - which types are supplied with rings as standard
//   (040E, 040AS, LM3, LM4, Teflex, Teflex NP)
// - Seeflex 020E: rings only on request (not standard)
//
// BFM_RING_LIMITS = [
//   id,
//   min_length_with_rings_mm,  // always 150mm (6")
//   max_length_mm_dia_le_500,  // max length at Ø ≤ 500mm
//   max_length_mm_dia_550_1000,// max length at Ø 550–1000mm (plastic rings)
//   max_length_mm_dia_1050_1650,// max length at Ø 1050–1650mm (plastic rings)
//   max_rings,                 // max ring count for this type
//   rings_standard             // true = "supplied with rings", false = on request only
// ]

BFM_RING_LIMITS = [
    // Seeflex 020E: rings only on request
    ["020E", 150, 4500, 500, 200, 10, false],

    // Supplied with rings as standard:
    ["040E", 150, 4500, 500, 200, 10, true],
    ["040AS",150, 4500, 500, 200, 10, true],

    // Teflex NP Black & Opaque: max 8 rings
    ["TNPB",150, 1000, 500, 200,  8, true],
    ["TNPO",150, 1000, 500, 200,  8, true],

    // LM3/LM4/Teflex Woven: 1500mm max at Ø ≤ 500
    ["LM3", 150, 1500, 500, 200, 10, true],
    ["LM4", 150, 1500, 500, 200, 10, true],
    ["TWOVEN",150,1500, 500, 200, 10, true]
];

// Global ring rules for all types with rings.
// Spacing:
BFM_RING_SPIGOT_MIN_DIST_MM = 75;  // min distance spigot ↔ first ring
BFM_RING_RING_MIN_DIST_MM   = 75;  // min distance between rings

// Max ring count as default and Teflex NP-specific:
BFM_RING_MAX_COUNT_DEFAULT = 10;
BFM_RING_MAX_COUNT_TNP     = 8;

// Max. temperature for PE (plastic) rings:
BFM_RING_PE_MAX_TEMP_C = 110;      // °C


// =====================================================================
// 5. SPIGOT SPECIFICATIONS + "Other" info
// =====================================================================
//
// BFM_SPIGOT_SPECS = [
//   id,
//   type,               // "standard" or "lipped"
//   min_diameter_mm,
//   max_diameter_mm,
//   total_length_mm,    // total spigot length
//   head_length_mm,     // length of "head" (above)
//   tail_length_mm,     // length of "tail" (inside the tube)
//   wall_thickness_mm   // wall thickness
// ]
//
// Other global info from "Other":
// - Diameter measurement: 100mm measured on OD of tail; 125mm & larger on ID
// - Tail-diameter tolerance ±2mm
// - Standard spigots: materials T304L SS, T316L SS, C22 Hastelloy
// - Lipped spigots: T304L SS only
// - Internal finish R_a ≤ 0.8µm

BFM_SPIGOT_SPECS = [
    ["STD", "standard",
        100, 1650,
        89,   // total length
        37,   // head
        52,   // tail
        2     // wall thickness
    ],
    ["LIP", "lipped",
        100,  400,
        83,   // total length
        37,   // head
        46,   // tail
        2
    ]
];

// Global spigot constants (for validation / summary):
BFM_SPIGOT_TAIL_TOLERANCE_MM        = 2;   // ±2mm on tail Ø
BFM_SPIGOT_STANDARD_MATERIALS       = "T304L SS, T316L SS, C22 Hastelloy";
BFM_SPIGOT_LIPPED_MATERIALS         = "T304L SS only";
BFM_SPIGOT_INTERNAL_FINISH_RA_UM    = 0.8; // µm
BFM_SPIGOT_OD_MEASUREMENT_THRESHOLD = 125; // <125mm: OD, ≥125mm: ID


// =====================================================================
// 6. OTHER GLOBAL RULES FROM "OTHER" (CONNECTORS)
// =====================================================================
//
// - Smallest installation space: 65mm for an 80mm long connector
// - Blanking caps: 30mm deep, 1 finger-loop
// - Connectors Ø ≥ 800mm: 3 finger-loops as standard

BFM_INSTALL_GAP_MIN_MM          = 65;   // min. gap for 80mm connector
BFM_INSTALL_GAP_REF_LENGTH_MM   = 80;   // length this applies to

BFM_BLANKING_CAP_DEPTH_MM       = 30;   // depth of blanking caps
BFM_BLANKING_CAP_FINGER_LOOPS   = 1;    // finger-loops on blanking cap

BFM_CONNECTOR_FINGER_LOOP_THRESHOLD_MM = 800; // from this Ø...
BFM_CONNECTOR_FINGER_LOOPS_LARGE       = 3;   // ...3 finger-loops standard


// =====================================================================
// 7. LEGACY MATERIAL COMPATIBILITY LAYER (for backwards compatibility)
// =====================================================================
//
// These maintain compatibility with existing bfm_assembly and component modules.

// =====================================================================
// 8. HELPER FUNCTIONS FOR LOOKUPS & RULES
// =====================================================================
//
// All helpers work with the id string ("040AS", "FLEXI", "LM3", ...).
// search() returns a list of indices where an element occurs;
// we always take the first element ([0]) since ids are unique.
// =====================================================================


// ---- index helpers ---------------------------------------------------

function bfm_product_index(id) =
    let(ids = [for (p = BFM_PRODUCT_SPECS) p[0]])
    (len(search(id, ids)) > 0 ? search(id, ids)[0] : -1);

function bfm_connector_index(id) =
    let(ids = [for (p = BFM_CONNECTOR_LIMITS) p[0]])
    (len(search(id, ids)) > 0 ? search(id, ids)[0] : -1);

function bfm_ring_index(id) =
    let(ids = [for (p = BFM_RING_LIMITS) p[0]])
    (len(search(id, ids)) > 0 ? search(id, ids)[0] : -1);


// ---- temperature / pressure -----------------------------------------------

// Returns [min_cont, max_cont] in °C.
// NB: for some materials min_cont = undef (unknown).
function bfm_get_temp_range(id) =
    let(i = bfm_product_index(id))
    (i < 0 ? [undef, undef] : [BFM_PRODUCT_SPECS[i][2], BFM_PRODUCT_SPECS[i][3]]);

// Returns surge temperature (°C).
function bfm_get_surge_temp(id) =
    let(i = bfm_product_index(id))
    (i < 0 ? undef : BFM_PRODUCT_SPECS[i][4]);

// Returns max. pressure in PSI.
function bfm_get_max_pressure_psi(id) =
    let(i = bfm_product_index(id))
    (i < 0 ? 0 : BFM_PRODUCT_SPECS[i][5]);


// ---- connector base limits (Ø ≤ 650mm, without rings) ---------

// Returns [min_dia, max_dia_no_rings, min_len, max_len_le_650].
function bfm_get_connector_base_limits(id) =
    let(i = bfm_connector_index(id))
    (i < 0 ? [0,0,0,0] :
        [ BFM_CONNECTOR_LIMITS[i][1],
          BFM_CONNECTOR_LIMITS[i][2],
          BFM_CONNECTOR_LIMITS[i][3],
          BFM_CONNECTOR_LIMITS[i][4] ]);

// Returns max. length WITHOUT rings, depending on diameter.
// - checks if diameter is within min/max of the type
// - then applies bucket rules for large diameters
function bfm_get_max_length_no_rings(id, dia_mm) =
    let(base = bfm_get_connector_base_limits(id),
        min_d = base[0],
        max_d = base[1],
        max_L_base = base[3])
    (dia_mm < min_d || dia_mm > max_d ? 0 :
        (dia_mm <= 650 ? max_L_base :
         (dia_mm <= 1000 ? 500 : 200)));  // 500mm resp. 200mm from buckets


// ---- connector limits WITH rings -----------------------------------

// Returns max. length WITH rings, depending on diameter.
// Returns 0 if no specific ring data for this type exists.
function bfm_get_max_length_with_rings(id, dia_mm) =
    let(i = bfm_ring_index(id))
    (i < 0 ? 0 :
        let(min_L = BFM_RING_LIMITS[i][1],
            max_le_500   = BFM_RING_LIMITS[i][2],
            max_550_1000 = BFM_RING_LIMITS[i][3],
            max_1050_1650 = BFM_RING_LIMITS[i][4])
        (dia_mm <= 500 ? max_le_500 :
         dia_mm <= 1000 ? max_550_1000 :
         max_1050_1650)
    );

// Maximum ring count for this type (0 = no ring data).
function bfm_get_max_rings(id) =
    let(i = bfm_ring_index(id))
    (i < 0 ? 0 : BFM_RING_LIMITS[i][5]);

// True if type is supplied with rings as standard (false = on request only).
function bfm_rings_standard(id) =
    let(i = bfm_ring_index(id))
    (i < 0 ? false : BFM_RING_LIMITS[i][6]);


// ---- certification / ATEX helpers -----------------------------------------

// True if material is FDA + EU (food-safe).
function bfm_is_foodsafe(id) =
    let(i = bfm_product_index(id))
    (i < 0 ? false : BFM_PRODUCT_SPECS[i][7]);

// True if material is 3-A certified.
function bfm_is_threeA(id) =
    let(i = bfm_product_index(id))
    (i < 0 ? false : BFM_PRODUCT_SPECS[i][8]);

// Returns ATEX category string ("all_dust", "restrictions", "yes").
function bfm_atex_category(id) =
    let(i = bfm_product_index(id))
    (i < 0 ? "" : BFM_PRODUCT_SPECS[i][9]);


// ---- installation space helper ----------------------------------------
//
// Simple check: for connector lengths around 80mm, warn if
// the specified installation space is less than 65mm.
function bfm_install_gap_ok(conn_length_mm, gap_mm) =
    (conn_length_mm <= BFM_INSTALL_GAP_REF_LENGTH_MM ?
        gap_mm >= BFM_INSTALL_GAP_MIN_MM :
        true);


// ---- legacy compatibility helpers ------------------------------------------

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


echo("BFM Data tables loaded - comprehensive Quick Reference data integrated");
