# Flexibele Verbindingen (Flexible Connectors) - Product Documentation

## 🔗 Product Beschrijving

Een **flexibele verbinding** is een parametrisch ontwerp voor flexibele leidingen/buizen die twee componenten met elkaar verbinden. Het product bestaat uit:

1. **Open flexibele buis** - Het centrale verbindingselement
2. **Eindkoppelingen** - Twee aansluitpunten (met verschillende koppelingtypen)

### Kernkenmerken
- ✓ **Open aan beide uiteinden** - Geen gesloten einden
- ✓ **Flexibel en buigbaar** - Wordt gebruikt tussen componenten
- ✓ **Parametrisch ontwerp** - Lengte, diameters, materiaal anpasbaar
- ✓ **Meerdere koppelingtypen** - 4 verschillende aansluittypes

---

## 📊 Technische Specificatie

### Standaard Parameters

```
Lengte (L):             500 mm    [100-2000 mm]
Binnendiameter (D_in):  50 mm     [10-100 mm]
Buitendiameter (D_out): 60 mm     [20-150 mm]
Wanddikte:              5 mm      (D_out - D_in) / 2

Materiaal:              PU (Polyurethaan)  [PU, silicone, rubber, EPDM, PVC]
Kleur:                  Translucent (RGB: 0.9, 0.9, 0.95)
```

### Materiaal: Polyurethaan (PU)
- **Voordeel**: Translucent, excellent flexibiliteit, chemisch bestendig
- **Toepassing**: Standaard in industriële flexibele leidingen
- **Eigenschappen**: Zichtbaarheid door buiswand, duurzaam, temperatuurbestendig

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
color_mat = [0.9, 0.9, 0.95]  // Translucent (standaard)
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
