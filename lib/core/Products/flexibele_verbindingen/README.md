# Flexibele Verbindingen (Flexible Connectors) - Product Documentation

## 🏗️ Architecture Overview: Layered Product Pipeline

The flexibele_verbindingen product system uses a **layered architecture** with shared pipeline phases and product-specific variants:

```
┌─────────────────────────────────────────────────────────┐
│  general/  ← Shared front & back of pipeline (A,B,C.1,E)│
│   ├── general_application_context.scad (Phase A)        │
│   ├── general_base_dimensions.scad (Phase B)            │
│   ├── general_end_type_selection.scad (Phase C.1)       │
│   ├── general_evaluation.scad (Phase E)                 │
│   └── README_general.md                                 │
│                                                         │
├─ lampe_flexibele_verbinding/ ← LAMPE variant (lab/med) │
│   ├── lampe_parametric.scad (Configurator entry)       │
│   ├── lampe_assembly.scad (Phase C.2+D)                │
│   ├── lampe_hoofdmateriaal.scad (Main tube)            │
│   ├── lampe_snelkoppeling.scad (Quick coupling)        │
│   ├── lampe_jacob.scad (Welding end)                   │
│   ├── lampe_triclamp.scad (Sanitary coupling)          │
│   └── README_lampe.md                                   │
│                                                         │
└─ bfm_flexibele_verbinding/ ← BFM variant (hydraulic)   │
    ├── bfm_parametric.scad (Configurator entry)         │
    ├── bfm_assembly.scad (Phase C.2+D)                  │
    ├── bfm_connector.scad (Main tube)                   │
    ├── bfm_spigot.scad (Connection interface)           │
    ├── bfm_rings.scad (Support rings)                   │
    ├── bfm_data.scad (Material/pressure tables)         │
    ├── bfm_validation.scad (BFM-specific checks)        │
    └── README_bfm.md                                     │
```

## 🔄 Pipeline Phases

Each product follows a complete validation pipeline:

### Phase A: Application Context
- Define use case (lampe, bfm, food, automotive)
- Set application-specific constraints
- Validate certifications needed

### Phase B: Base Dimensions
- Input core geometric parameters (L, D_in, D_out)
- Auto-calculate wall thickness
- Classify size family

### Phase C.1: End Type Selection & Routing
- Select connector types for both ends
- Route to appropriate product variant
- Validate connector compatibility

### Phase C.2+: Product-Specific Assembly
- **LAMPE**: snelkoppeling, jacob, triclamp connectors
- **BFM**: banjo spigots, rings, validation data

### Phase D: Manufacturing Details
- Generate component geometry
- Position connectors at tube ends
- Apply material colors and finish

### Phase E: Evaluation & Validation
- Global validation checks
- Pressure/temperature limits
- Generate summary report

## 📂 Product Variants

### LAMPE (Laboratory/Medical/Pharma)
- **Max Pressure**: 10 bar
- **Temp Range**: -20°C to +60°C
- **Certifications**: ISO 1402, ISO 6149
- **Connectors**: Snelkoppeling, Jacob, Tri-Clamp
- **Applications**: Lab tubing, medical devices, pharma fluid transfer

### BFM (Industrial Hydraulic/Pneumatic)
- **Max Pressure**: 280 bar (medium), 200 bar (large), 5 bar (small)
- **Temp Range**: -40°C to +100°C
- **Certifications**: ISO 4401, ISO 6149, CE 2014/68/EU, AD 2000
- **Connectors**: Banjo spigots, reinforcement rings
- **Applications**: Hydraulic systems, pneumatic lines, industrial transfer

## 🚀 Quick Start

### Use LAMPE Variant

Create `my_lampe_connector.scad`:
```scad
use <lib/core/Products/flexibele_verbindingen/lampe_flexibele_verbinding/lampe_parametric.scad>;

// Override parameters as needed
L_tube = 750;
end_type_1 = "jacob";
end_type_2 = "triclamp";
```

Render:
```bash
openscad --viewall --render -o my_connector.png my_lampe_connector.scad
```

### Use BFM Variant

Create `my_bfm_connector.scad`:
```scad
use <lib/core/Products/flexibele_verbindingen/bfm_flexibele_verbinding/bfm_parametric.scad>;

L_tube = 1000;
end_type_1 = "bfm";
end_type_2 = "bfm";
```

Render:
```bash
openscad --viewall --render -o my_bfm.png my_bfm_connector.scad
```

## 📊 Connector Types & Features

### Quick Coupling (Snelkoppeling)
- Male/female variants
- Tool-free connection
- Fast disconnect
- Locking ring mechanism
- **Supported in**: LAMPE

### Jacob Welding End
- Permanent flange connection
- External flange orientation (bottom↓, top↑)
- Diameter-proportional scaling
- Stainless steel (options: mild, powder coated)
- **Supported in**: LAMPE

### Tri-Clamp (SMS/DIN 32676)
- Sanitary application standard
- 3-tab locking mechanism
- Ferrule with sealing surface
- **Supported in**: LAMPE

### Banjo Fitting (BFM)
- Industrial hydraulic style
- Ball joint seating
- Bolt holes for manifold attachment
- High pressure rated
- **Supported in**: BFM

## 🎨 Material & Color System

**Standard Materials (RGBA):**
- **PU** (Polyurethane): `[1.0, 1.0, 1.0, 0.15]` - Semi-transparent white
- **Silicone**: `[0.8, 0.2, 0.2]` - Red
- **Rubber**: `[0.2, 0.2, 0.2]` - Black
- **EPDM**: `[0.2, 0.5, 0.2]` - Green
- **PVC**: `[0.5, 0.5, 0.5]` - Grey

**Connector Materials (fixed):**
- Quick coupling: Dark grey `[0.3, 0.3, 0.3]`
- Jacob welding end: Stainless steel `[0.78, 0.78, 0.82]`
- Tri-clamp: Light grey `[0.6, 0.6, 0.65]`
- BFM spigot: Dark grey `[0.4, 0.4, 0.4]`

## 📐 Parameter Ranges

### Shared Parameters (All Variants)

| Parameter | Min | Default | Max | Unit |
|-----------|-----|---------|-----|------|
| L_tube | 100 | 500 | 2000 | mm |
| D_in | 10 | 50 | 100 | mm |
| D_out | 20 | 60 | 150 | mm |
| $fn (resolution) | 48 | 96 | 128 | — |

### Application-Specific Limits

**LAMPE:**
- Max D_out: 150 mm
- Max working pressure: 10 bar
- Max length: 2000 mm

**BFM:**
- Max D_out: 100 mm
- Max working pressure: 280 bar (medium), 200 bar (large), 5 bar (small)
- Max length: 1500 mm

## 🔧 Extending the System

### Add New Connector Type

1. Create component module in product variant folder:
   ```
   lampe_mynewconnector.scad
   module lampe_mynewconnector(D_in, D_out, z_pos, $fn) { ... }
   ```

2. Update `lampe_assembly.scad` to include new type in routing

3. Update configurator dropdown to include option

### Create New Product Variant

1. Create folder: `mynewproduct_flexibele_verbinding/`
2. Copy structure from `lampe_flexibele_verbinding/` or `bfm_flexibele_verbinding/`
3. Create variant-specific assembly and components
4. Update general validation if needed
5. Document in variant README

## 📝 Specification Sheets

See individual READMEs for detailed specifications:
- `general/README_general.md` - Shared pipeline phases
- `lampe_flexibele_verbinding/README_lampe.md` - LAMPE variant
- `bfm_flexibele_verbinding/README_bfm.md` - BFM variant

## ✅ Validation & Quality Assurance

All designs validate:
- ✓ Geometry consistency (dimensions > 0, D_out > D_in)
- ✓ Application-specific limits (pressure, temperature, length)
- ✓ Material compatibility (per variant specs)
- ✓ Connector routing (end types match variant)
- ✓ Manufacturing feasibility (wall thickness, tolerances)

## 🔄 Versioning

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2025-11-29 | Layered architecture with general + product variants |
| 1.1 | 2025-11-29 | Jacob welding end with external flange & scaling |
| 1.0 | 2025-11-29 | Initial release with 4 connector types |

---

**Status**: Multi-variant architecture production ready ✓


---

## 📊 Technische Specificatie

### Standaard Parameters

```
Lengte (L):             500 mm    [100-2000 mm]
Binnendiameter (D_in):  50 mm     [10-100 mm]
Buitendiameter (D_out): 60 mm     [20-150 mm]
Wanddikte:              5 mm      (D_out - D_in) / 2

Materiaal:              PU (Polyurethaan)  [PU, silicone, rubber, EPDM, PVC]
Kleur:                  Semi-transparent wit (RGBA: 1.0, 1.0, 1.0, 0.15)
```

### Materiaal: Polyurethaan (PU)
- **Voordeel**: Semi-transparent wit, licht milky uiterlijk, flexibel, chemisch bestendig
- **Toepassing**: Standaard in industriële flexibele leidingen
- **Eigenschappen**: Zichtbaarheid door buiswand, duurzaam, temperatuurbestendig
- **Visuele representatie**: RGBA [1.0, 1.0, 1.0, 0.15] - Bijna kleurloos met zwakke opaciteit

### Eindkoppelingen

#### 1. Snelkoppeling (Quick Coupling)
- **Type**: Mannelijk of vrouwelijk
- **Toepassing**: Snelle verbinding/verbreking zonder tools
- **Industrie**: Luchtdruk, waterdichting, laboratorium
- **Hoogte**: 25 mm
- **Karakteristieken**: Flensontwerp met vergrendeling

#### 2. Jacob Koppeling (Jacob Coupling) - Welding End
- **Type**: Vaste aansluiting met flans
- **Toepassing**: Industriële flexibele leidingen met permanente verbinding
- **Hoogte**: 55 mm (standaard)
- **Karakteristieken**: 
  - Welded flange (permanent aansluiting)
  - Tubes oppervlak voor inlassing
  - Beschikbare nominale diameters: 60-630 mm
  - Materiaalsoorten: mild steel, powder coated, stainless steel
  - Sheet thickness (S): 2-3 mm typisch
  - Flange overhang (lip): ~6 mm

**Technische Details:**
- Ontwerp: rotate_extrude van 2D profiel met flange
- Innerbuis: Welded aan de flexibele leiding
- Buitenflange: Voor montagepunten en afdichting
- Materiaal standaard: Stainless steel (0.78, 0.78, 0.82)
- Beschikbare finishes: Mild steel, powder coated, stainless
- **Flange oriëntatie**: Altijd extern gericht
  - Bottom: Flange wijst naar beneden
  - Top: Flange wijst naar boven
- **Afmetingen schalen** met buitendiameter
  - Lengte: 55mm × (D_out/60) - Past zich aan aan grotere diameters
  - Lip: D_out/10 - Proportioneel aan diameter

#### 3. Tri-Clamp (SMS/DIN 32676)
- **Type**: Sanaire koppeling
- **Toepassing**: Voedsel, farmaceutisch, dranken
- **Hoogte**: 35 mm
- **Karakteristieken**: Ferrule, afdichtingsoppervlak, 3x tabs

#### 4. BFM (Banjo Fitting/Hydraulic)
- **Type**: Hydraulisch/pneumatisch
- **Toepassing**: Hydraulische systemen, pneumatiek
- **Hoogte**: 28 mm
- **Karakteristieken**: Banjo-stijl, kogel-voegpunt, boutgaten

---

## 🏗️ Bestandsstructuur

```
flexibele_verbindingen/
├── flexibele_verbinding_parametric.scad  (Configurator entry point)
├── fv_flexibele_verbinding.scad          (Assembly orchestrator)
├── fv_hoofdmateriaal.scad                (Main tube)
├── fv_snelkoppeling.scad                 (Quick coupling)
├── fv_jacob.scad                         (Welding end - NEW!)
├── fv_triclamp.scad                      (Sanitary coupling)
├── fv_bfm.scad                           (Hydraulic coupling)
└── README.md                             (This file)
```

### Componentrollen

#### flexibele_verbinding_parametric.scad
- **Rol**: Configurator (user-facing parameters)
- **Parameters**: Alle dimensies, materialen, koppelingtypen
- **Uitvoer**: Volledig geassembleerd 3D model

#### fv_flexibele_verbinding.scad
- **Rol**: Assembly orchestrator
- **Functie**: Roept componenten aan en positioneert ze
- **Logica**: IF-statements voor koppelingtype-selectie

#### fv_hoofdmateriaal.scad
- **Functie**: Open flexibele buis
- **Type**: Hollow cylinder via difference()
- **Parameters**:
  - `L` - Lengte
  - `D_in`, `D_out` - Diameters
  - `material` - Materiaal identifier
  - `color_mat` - RGB kleur

#### fv_snelkoppeling.scad
- **Functie**: Snelle koppelings eindstuk
- **Ondersteuning**: Mannelijke en vrouwelijke versies
- **Parameters**:
  - `coupling_type` - "male" of "female"
  - `z_pos` - Verticale positie
- **Ontwerp**: Flens met vergrendelingsmechanisme

#### fv_jacob.scad
- **Functie**: Jacob welding end – industriële leidingaansluiting
- **Ondersteuning**: Parametrische welding flange
- **Parameters**:
  - `D_out` - Buitendiameter (scales all dimensions)
  - `D_in` - Binnendiameter
  - `orient` - "bottom" (flange down) of "top" (flange up)
  - `mat` - Materiaalsoort ("mild", "powder", "stainless")
  - `z_pos` - Verticale positie
- **Ontwerp**: 
  - Realistische welding end met extern gerichte flange
  - rotate_extrude van 2D profiel
  - Beschikbare nominale diameters: 60-630 mm
  - Gesloten buitenflange voor montagepunten
  - Open binnenkant voor doorstroming
  - **Afmetingen schalen automatisch** met D_out
- **Toepassing**: Permanente verbinding in industriële pijpsystemen

#### fv_triclamp.scad
- **Functie**: Sanaire tri-clamp eindstuk
- **Ondersteuning**: SMS/DIN 32676 standaard
- **Parameters**:
  - `z_pos` - Verticale positie
- **Ontwerp**: Ferrule met 3x vergrendeling-tabs

#### fv_bfm.scad
- **Functie**: BFM hydraulische quick disconnect
- **Parameters**:
  - `z_pos` - Verticale positie
- **Ontwerp**: Banjo-stijl coupling met boutgaten

---

## 🎯 Gebruiksvoorbeelden

### Voorbeeld 1: Snelle Aansluiting (Quick Connect)
```scad
end_type_1 = "snelkoppeling"
coupling_type_1 = "male"
end_type_2 = "snelkoppeling"
coupling_type_2 = "female"
```
Resultaat: Twee snelle koppelingen die snel kunnen worden verbonden/verbroken

### Voorbeeld 2: Sanitaire Opstelling (Sanitary Setup)
```scad
end_type_1 = "snelkoppeling"
end_type_2 = "triclamp"
L = 1000
D_in = 50
```
Resultaat: Flexibele verbinding voor voedsel/farmaceutische toepassingen

### Voorbeeld 3: Hydraulische Leiding (Hydraulic Hose)
```scad
end_type_1 = "bfm"
end_type_2 = "bfm"
material = "PU"
color_mat = [1.0, 1.0, 1.0, 0.15]  // Semi-transparent wit (standaard)
```
Resultaat: Hydraulische leidingverbinding met BFM aansluitingen

### Voorbeeld 4: Industriële Leidingaansluiting met Jacob Welding End
```scad
end_type_1 = "jacob"
end_type_2 = "jacob"
L = 750
material = "PU"
D_in = 100      // Grotere diameter voor industrieel gebruik
D_out = 110
```
Resultaat: Twee welding ends voor permanente aansluiting in industriële pijpsystemen

**Jacob Welding End Kenmerken:**
- Stainless steel construction (0.78, 0.78, 0.82)
- Flange diameter: Nominale diameter + 12 mm (beide kanten flange)
- Ideaal voor gas, water, en procesvloeistoffen
- Geschikt voor inlassing (welding)
- Sheet thickness auto-berekend uit D_in/D_out

---

## 🔧 Aanpassingen en Uitbreidingen

### Nieuwe Koppelingtype Toevoegen

1. **Maak nieuw bestand**: `fv_[newtype].scad`
2. **Definieer module**: `module fv_[newtype](D_in, D_out, z_pos, $fn)`
3. **Voeg import toe** in `fv_flexibele_verbinding.scad`: `use <fv_[newtype].scad>;`
4. **Voeg IF-blok toe** in assembly module voor `end_type_1` en `end_type_2`
5. **Update configurator**: Voeg optie toe aan `end_type_1` en `end_type_2` dropdowns

### Materiaal Aanpassen

Wijzig `color_mat` in `flexibele_verbinding_parametric.scad`:
- Rood silicone: `[0.8, 0.2, 0.2]`
- Zwart rubber: `[0.2, 0.2, 0.2]`
- Groen EPDM: `[0.2, 0.5, 0.2]`
- Grijs PVC: `[0.5, 0.5, 0.5]`

---

## 📐 Dimensionering

### Flexibele Buis
- Lengte (L): Vrij te kiezen [100-2000 mm]
- Binnendiameter (D_in): [10-100 mm]
- Buitendiameter (D_out): [20-150 mm]
- Wanddikte: Automatisch = (D_out - D_in) / 2

**Voorbeeld**: D_out=60, D_in=50 → Wanddikte=5mm

### Jacob Welding End
- Lengte: 55mm × (D_out/60)
- Flange lip: D_out / 10
- Sheet thickness: (D_out - D_in) / 2

Dynamisch schalen zorgt ervoor dat grotere koppelingen proportioneel groter zijn.

---

## 🚀 Performance & Optimalisatie

- **Rendering**: ~11 seconden voor standaard configuratie
- **Geometry**: 2300+ vertices in complexe assemblies
- **$fn parameter**: Verhoog naar 128 voor smooth details, verlaag naar 48 voor preview
- **Modulair design**: Componenten onafhankelijk renderable

---

## 📝 Opmerkingen

- Alle maten in millimeters (mm)
- OpenSCAD 2024+ vereist voor volledige compatibiliteit
- use <> syntax voor betrouwbare path resolution
- rotate_extrude() gebruiken voor welvingcontourprofielen
- Material colors zijn puur visueel (voor preview)

---

## 🔄 Versiegeschiedenis

| Versie | Datum | Wijziging |
|--------|-------|-----------|
| 1.0    | 2025-11-29 | Initial release met 4 koppelingtypen |
| 1.1    | 2025-11-29 | Jacob welding end met externe flange en scaling |

---

**Status**: Production Ready ✓
