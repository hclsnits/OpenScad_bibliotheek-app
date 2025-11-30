# Flexibele Verbindingen — Frontend Configurator (Vereenvoudigd)

## TL;DR — De User Flow

```
1. Kies "Flexibele Verbindingen" (vs Filterslang)
   ↓
2. Kies Sector (of "Onbekend" voor geen filtering)
   • Onbekend / Industrieel / Voeding / Pharma / Medisch / ATEX
   • Dit bepaalt welke connectoren beschikbaar zijn
   ↓
3. WIZARD STAP 1-6:
   1. Dimensies (VERPLICHT)     — L, D_in, D_out
   2. Medium (OPTIONEEL)         — Water/Lucht/Olie/etc of "Onbekend"
   3. Temp & Druk (OPTIONEEL)    — Sliders of "Onbekend"
   4. Connector Type (GEFILTERD) — ✓ PASS | ~ RISKY | ✗ DISABLED
   5. Materiaal & Kleur          — PU/Silicone/etc + RGB
   6. Samenvatting & Genereer    — 4-blocks validatie + [GENEREER]
   ↓
4. Download SCAD, DXF, BOM
   (Backend bepaalt automatisch: LAMPE of BFM variant)
```

---

## Scenario 1: User Zonder Kennis

```
Stap 0.1: Sector = "Onbekend"
  → Geen filtering
  → Backend laadt ALLE 4 connectoren

Stap 1: Dimensies
  • L = 500mm, D_in = 50mm, D_out = 60mm
  
Stap 2: Medium = "Onbekend"
  → Geen filtering toegepast
  
Stap 3: Temp & Druk = "Onbekend"
  → Geen filtering toegepast

Stap 4: Connector Selectie
  → Alle 4 beschikbaar (totdat andere stappen filteren)
  → Bore check: 50mm past in alle types
  → Alle 4 radio buttons tonen met specs

User selecteert: "Triclamp"
  ↓
Stap 5: Materiaal = "PU"
Stap 6: Samenvatting & Genereer
  ↓
Result: Flexibele leiding (LAMPE variant, Triclamp couplings)
```

---

## Scenario 2: User Met Medische Vereisten

```
Stap 0.1: Sector = "Medisch Device"
  → Backend filters op hygiene_class = "medical"
  → Laadt connectoren: [triclamp, snelkoppeling] (jacob & bfm excluded)

Stap 1: Dimensies
  • L = 800mm, D_in = 12mm, D_out = 20mm
  
Stap 2: Medium = "Steriel Water"
  → Hygiëne confirmed
  
Stap 3: Temp & Druk
  • Temp: 4 tot 121°C (autoclave)
  • Druk: 0.33 bar (ultra-low medical)
  → Jacob al excluded (permanent weld, niet herbruikbaar)
  → BFM al excluded (bore 100+ vs 12mm)
  → Snelkoppeling: ~ RISKY (thermal cycling concern)
  → Triclamp: ✓ PASS (perfect match)

Stap 4: Connector Selectie
  Radio buttons:
  • Snelkoppeling ~ RISKY badge (thermal stress)
  • Triclamp ✓ PASS [PRE-SELECTED]

User behoudt: Triclamp
  ↓
Stap 5: Materiaal = "Silicone Medical" (suggested)
Stap 6: Samenvatting
  ✅ IDENTITEIT: Medical sterile water system
  ✅ GEOMETRIE: 800mm × 12/20mm, Volume 160.85mL
  ✅ CONNECTOREN: Triclamp T316L SS
  ✅ LIMIET: 0.33 bar, -4 tot 121°C, 50 cycles
  ↓
Result: Medical Device (LAMPE variant, Triclamp)
```

---

## Frontend Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                   STAP 0: PRODUCT KEUZE                      │
│   ○ Filterslang  ○ Flexibele Verbindingen  ○ BFM Banjo     │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
                (User kiest Flexibele Verbindingen)
                     ↓
┌──────────────────────────────────────────────────────────────┐
│             STAP 0.1: SECTOR SELECTIE                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Wat is de toepassing/sector?                         │   │
│  │ (Bepaalt filtering; geen selectie = alle connectoren)│   │
│  │                                                      │   │
│  │ ○ Onbekend           ← Geen filtering              │   │
│  │ ○ Industrieel        ← Filter: snelkop, jacob, bfm │   │
│  │ ○ Voeding            ← Filter: snelkop, triclamp   │   │
│  │ ○ Farmaceutisch      ← Filter: triclamp, snelkop   │   │
│  │ ○ Medisch Device     ← Filter: triclamp (primair)  │   │
│  │ ○ ATEX               ← Filter: jacob, snelkop      │   │
│  │                                                      │   │
│  │ Selected: [Onbekend ▼] → [Continue]               │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
           (WIZARD START — STAP 1-6)
                     ↓
┌──────────────────────────────────────────────────────────────┐
│                  STAP 1: DIMENSIES (Verplicht)               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Buis Afmetingen                                      │   │
│  │                                                      │   │
│  │ Lengte [100...2000mm]:     [500         ] mm         │   │
│  │ Inwendige diameter:        [50          ] mm         │   │
│  │ Buitendiameter:            [60          ] mm         │   │
│  │                                                      │   │
│  │ ℹ Wanddikte (auto):        5 mm                      │   │
│  │ ℹ Volume (auto):           196 mL                    │   │
│  │ ℹ Veiligheidsfactor:       OK ✓                      │   │
│  │                                                      │   │
│  │ [Next →]                                             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│            STAP 2: MEDIUM (Optioneel filter)                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Wat vloeit er door?                                  │   │
│  │ (Geen selectie = geen filtering)                     │   │
│  │                                                      │   │
│  │ ○ Onbekend                                           │   │
│  │ ○ Water                                              │   │
│  │ ○ Lucht (pneumatisch)                               │   │
│  │ ○ Olie (hydrauliek)                                 │   │
│  │ ○ Voeding                                            │   │
│  │ ○ Farmaceutisch                                      │   │
│  │ ○ Gas (stikstof, argon)                             │   │
│  │                                                      │   │
│  │ Selected: [Onbekend ▼]                              │   │
│  │ [Next →]                                             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│         STAP 3: TEMPERATUUR & DRUK (Optioneel filter)        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Bedrijfsomstandigheden                               │   │
│  │ (Geen selectie = geen filtering)                     │   │
│  │                                                      │   │
│  │ ○ Onbekend                                           │   │
│  │                                                      │   │
│  │ ○ Bepaald:                                           │   │
│  │   Bedrijfstemperatuur:    [◉────────] 20°C          │   │
│  │   Piektemperatuur:        [◉────────] 60°C          │   │
│  │   Min temp (opslag):      [◉────────] -10°C         │   │
│  │                                                      │   │
│  │   Werkdruk:               [◉────────] 10 bar        │   │
│  │   Piekdruk:               [◉────────] 15 bar        │   │
│  │                                                      │   │
│  │ [Next →]                                             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│     STAP 4: CONNECTOR SELECTIE (Gefilterd — KRITISCH)        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Welke connector aan beide uiteinden?                 │   │
│  │ (Gefilterd op Stap 0.1 + 1 + 2 + 3 constraints)    │   │
│  │                                                      │   │
│  │ Eerste Uiteinde:                                     │   │
│  │                                                      │   │
│  │ ✓ Triclamp (sanitary)                                │   │
│  │   [✓ PASS]                                           │   │
│  │   Druk: 100 bar | Temp: 100°C | Bore: 16-150mm    │   │
│  │   [SELECTED ●]                                       │   │
│  │                                                      │   │
│  │ ~ Snelkoppeling (quick)                              │   │
│  │   [~ RISKY] Thermal cycling concern               │   │
│  │   Druk: 250 bar | Temp: 80°C | Bore: 12-100mm    │   │
│  │   [ ]                                                │   │
│  │                                                      │   │
│  │ ✗ Jacob (weld)                                       │   │
│  │   [✗ DISABLED] Bore 20mm > 12mm (OK), maar:        │   │
│  │   Permanent weld (niet herbruikbaar)                │   │
│  │   [ ] (grayed out)                                   │   │
│  │                                                      │   │
│  │ ✗ BFM (spigot)                                       │   │
│  │   [✗ DISABLED] Bore 100+ mm > 50mm (incompatibel)  │   │
│  │   [ ] (grayed out)                                   │   │
│  │                                                      │   │
│  │ Tweede Uiteinde:                                     │   │
│  │ [Zelfde opties] [Triclamp ● selected]              │   │
│  │                                                      │   │
│  │ [Next →]                                             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│           STAP 5: MATERIAAL & KLEUR                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Materiaal & Kleur                                    │   │
│  │                                                      │   │
│  │ Materiaal:                                           │   │
│  │ [PU (Polyurethaan) ▼] - Translucent               │   │
│  │ Other: Silicone, Rubber, EPDM, PVC                │   │
│  │                                                      │   │
│  │ Kleur (RGB):                                         │   │
│  │ R: [◉─────] 0.9                                     │   │
│  │ G: [◉─────] 0.9                                     │   │
│  │ B: [◉─────] 0.95                                    │   │
│  │ A: [◉─────] 0.15 (transparantie)                   │   │
│  │                                                      │   │
│  │ 🖼️  Preview: Translucent witte buis                 │   │
│  │                                                      │   │
│  │ [Next →]                                             │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│          STAP 6: SAMENVATTING & VALIDATIE (Phase E)          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ONTWERP SAMENVATTING                                 │   │
│  │                                                      │   │
│  │ ✅ IDENTITEIT                                         │   │
│  │    Sector: Medisch Device                           │   │
│  │    Medium: Water                                     │   │
│  │    Hygiëne: Medical (FDA 21 CFR)                    │   │
│  │    Certificaten: FDA, ISO 13485, CE                 │   │
│  │                                                      │   │
│  │ ✅ GEOMETRIE                                          │   │
│  │    Lengte: 800 mm                                    │   │
│  │    ID: 12 mm | OD: 20 mm | Wand: 4 mm              │   │
│  │    Volume: 160.85 mL                                │   │
│  │    Veiligheidsfactor: 12.1× (OK)                    │   │
│  │                                                      │   │
│  │ ✅ VERBINDINGEN                                       │   │
│  │    Beide uiteinden: Triclamp (T316L SS)             │   │
│  │    Druk: 0.33 bar (100 bar capacity)                │   │
│  │    Temp: 4-121°C (100°C capacity)                   │   │
│  │    Herbruikbaar: Ja                                 │   │
│  │                                                      │   │
│  │ ✅ TECHNISCHE LIMIETEN                                │   │
│  │    Max werkdruk: 100 bar (303× reserve)             │   │
│  │    Autoclavebestendig: 121°C × 50 cycles            │   │
│  │    Dode volume: 160.85 mL (minimal!)                │   │
│  │    Status: VALID FOR MANUFACTURING                  │   │
│  │                                                      │   │
│  │ Variant Bepaald: LAMPE (Triclamp based)             │   │
│  │                                                      │   │
│  │ [GENEREER MODEL] [ANNULEER]                          │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
                     ↓
         (Backend genereert 5 stappen)
                     ↓
┌──────────────────────────────────────────────────────────────┐
│                    RESULTAAT                                 │
│  Downloads:                                                  │
│  • Medical_SterileWater_800mm.scad                          │
│  • Medical_SterileWater_800mm.dxf                           │
│  • bom_technical.jsonl                                      │
│  • bom_production.csv                                       │
│  • bom_production.xlsx                                      │
│                                                              │
│  Backend bepaald:                                            │
│  • Variant: LAMPE (kleine bore, snelkoppelingen)            │
│  • Connector type: Triclamp                                 │
│  • Material: PU (Polyurethaan) Translucent                  │
│  • 3D Model: SCAD rendering                                 │
│  • BOM: Uit OpenSCAD echo output                            │
└──────────────────────────────────────────────────────────────┘
```

---

## Filtrering Logic

### Stap 0.1: Sector → Connector Filter

```
Onbekend:     [snelkoppeling, jacob, triclamp, bfm] ← Alle
Industrieel:  [snelkoppeling, jacob, bfm]           ← No triclamp
Voeding:      [snelkoppeling, triclamp]             ← FDA
Pharma:       [triclamp, snelkoppeling]             ← USP/EP
Medisch:      [triclamp]                            ← FDA 21 CFR
ATEX:         [jacob, snelkoppeling]                ← Non-sparking
```

### Stap 2 & 3: Medium + Temp/Druk → Connector Validation

**Connector Database:**
```
snelkoppeling:
  • Max Pressure: 250 bar
  • Max Temperature: 80°C
  • Bore Range: 12-100 mm
  • Hygiene: Food, General (not Pharma/Medical)

jacob:
  • Max Pressure: 50 bar
  • Max Temperature: 120°C
  • Bore Range: 20-150 mm
  • Warning: Permanent weld (not reusable)
  • Hygiene: General, ATEX

triclamp:
  • Max Pressure: 100 bar
  • Max Temperature: 100°C (sterilizable)
  • Bore Range: 16-150 mm
  • Hygiene: Food, Pharma, Medical
  • Reusable: Yes

bfm:
  • Max Pressure: 280 bar
  • Max Temperature: 100°C
  • Bore Range: 100+ mm (industrial only)
  • Hygiene: General (not Pharma/Medical)
```

### Stap 4: Final Connector Selection

Backend test:
1. Filter op Sector (Stap 0.1)
2. Filter op Bore Size (Stap 1 Dimensies)
3. Filter op Medium Compatibility (Stap 2)
4. Filter op Pressure/Temperature (Stap 3)
5. Return: ✓ PASS | ~ RISKY | ✗ DISABLED

Frontend:
- Toon beschikbare connectoren met badges
- Tooltips voor DISABLED reden
- Pre-select OPTIMAL (meest aangeraden)

---

## State Management (React)

```javascript
const [config, setConfig] = useState({
  // Stap 0.1: Sector
  sector: "medisch",  // or "onbekend"
  hygiene_class: "medical",  // derived from sector
  
  // Stap 1: Dimensies (VERPLICHT)
  L_tube: 800,
  D_in: 12,
  D_out: 20,
  gap_length: 10,
  
  // Stap 2: Medium (OPTIONEEL)
  process_medium: "onbekend",  // or "water"
  
  // Stap 3: Temp & Druk (OPTIONEEL)
  process_temp_cont: null,  // null = "onbekend"
  process_temp_surge: null,
  process_temp_min: null,
  process_pressure_max: null,
  process_pressure_surge: null,
  
  // Stap 4: Connector
  end_type_1: "triclamp",
  end_type_2: "triclamp",
  coupling_type_1: null,  // only for snelkoppeling
  
  // Stap 5: Material
  material: "PU",
  color_mat: [0.9, 0.9, 0.95, 0.15],
});

const [validation, setValidation] = useState({
  available_connectors: ["triclamp", "snelkoppeling"],
  disabled_connectors: {
    jacob: "Permanent weld - not reusable",
    bfm: "Bore 100+ mm > 50 mm (too large)"
  },
  warnings: ["snelkoppeling: thermal cycling risk"],
  is_valid: true,
});
```

---

## Backend Validatie API

### POST `/api/fv/validate`

```python
Request:
{
  "sector": "medisch",
  "L_tube": 800,
  "D_in": 12,
  "D_out": 20,
  "process_medium": "water",
  "process_pressure_max": 0.33,
  "process_temp_surge": 121
}

Response:
{
  "available_connectors": ["triclamp", "snelkoppeling"],
  "disabled_connectors": {
    "jacob": "bore minimum 20mm > 12mm required",
    "bfm": "bore minimum 100mm > 12mm required"
  },
  "warnings": [
    "snelkoppeling: thermal cycling 121°C degrades standard seals"
  ],
  "recommended": "triclamp",
  "is_valid": true
}
```

### POST `/api/fv/generate`

```python
Request:
{
  "name": "Medical_SterileWater_800mm",
  "config": { ...full config object... }
}

Response (async):
{
  "job_id": "abc-123-def",
  "status": "queued",
  "created_at": "2025-11-30T10:30:00Z"
}

# Poll: GET /api/fv/generate/abc-123-def
{
  "status": "complete",
  "artifacts": {
    "scad_url": "/downloads/Medical_SterileWater_800mm.scad",
    "dxf_url": "/downloads/Medical_SterileWater_800mm.dxf",
    "bom_jsonl_url": "/downloads/bom_technical.jsonl",
    "bom_csv_url": "/downloads/bom_production.csv",
    "bom_xlsx_url": "/downloads/bom_production.xlsx"
  },
  "variant": "LAMPE",
  "connector_type": "triclamp"
}
```

---

## Key Design Decisions

✅ **Stap 0.1 is de enige pre-wizard stap** — bepaalt filtering
✅ **Dimensies zijn verplicht** — bepalen bore size filtering
✅ **Medium & Temp/Druk zijn optioneel** — "Onbekend" betekent geen filtering
✅ **Variant (LAMPE/BFM) bepaald in resultaat** — niet door user gekozen
✅ **Connector filtering gebeurt real-time** — per stap
✅ **Tooltips op DISABLED connectoren** — duidelijk waarom niet beschikbaar
