# Flexibele Verbindingen — Frontend Configurator Voorstel

## TL;DR — De Hiërarchie

```
User Flow:
1. Kiest "Flexibele Verbindingen" (niet Filterslang)
2. Kiest Sector/Toepassing (of "Onbekend" voor geen filtering):
   Industrieel, Voeding, Pharma, Medisch, ATEX, of Onbekend
   → Backend laadt connector database (gefilterd of niet)
3. Start WIZARD (5 stappen):
   Stap 1: Dimensies (L, D_in, D_out) — VERPLICHT
   Stap 2: Medium (Water, Lucht, Olie, of Onbekend) — Optioneel filter
   Stap 3: Temperatuur & Druk (sliders, of Onbekend) — Optioneel filter
   Stap 4: Connector Type (gefilterd op basis van boven) — ✓ ✗ ~
   Stap 5: Materiaal & Kleur
   Stap 6: Samenvatting & Genereer
4. Download SCAD, DXF, BOM (JSONL/CSV/XLSX)
5. Resultaat kan BOM aangeven: LAMPE of BFM variant
```

---

## 1. Huidige Situatie

### Bestaande Frontend (Filterslang)
- Eenvoudige vorm: Materiaal → Afmetingen → Top/Bodem → Ringen → Versterking
- Presets: PE_500, PPS_550
- Enums voor top, bottom, productzijde
- Beperkte validatie

### Nieuwe Functionaliteit (Flexibele Verbindingen)
- **Complexer model** met 5 fases (A, B, C.1, C.2+D, E)
- **4 connector types** met verschillende limieten
- **3 product variants** (LAMPE snelkoppeling, jacob, triclamp)
- **Dynamische constraint validatie** (fase A→B→C.1)
- **Intelligente routing** (welke connectors beschikbaar?)

---

## 2. Configurator Stroomdiagram (Hiërarchie)

```
STAP 0: PRODUCT TYPE KEUZE (Landing Page)
┌─────────────────────────────────────────────────────────┐
│ Wat wil je configureren?                                │
│                                                         │
│ [1] FILTERSLANG (bestaand)                             │
│     → Eenvoudig: lengte, diameter, top/bodem          │
│                                                         │
│ [2] FLEXIBELE VERBINDINGEN (nieuw)                     │
│     → Geavanceerd: Phase A-E validatie                 │
│     → Intelligente connector filtering                  │
│                                                         │
│ [3] (Toekomst) BANJO ADAPTERS                          │
│     → Industrieel: BFM spigots                         │
└─────────────────────────────────────────────────────────┘
                          ↓
                    (User kiest [2])
                          ↓
STAP 0.1: SECTOR/TOEPASSING SELECTIE
┌─────────────────────────────────────────────────────────┐
│ Wat is de toepassing/sector?                            │
│ (Dit bepaalt filtering; geen selectie = geen filter)   │
│                                                         │
│ ○ Onbekend                                              │
│   └─ Geen filtering — alle connectoren beschikbaar     │
│                                                         │
│ ○ Industrieel                                           │
│   └─ Hygiene: Algemeen                                 │
│   └─ Filter: Snelkoppeling, Jacob, BFM              │
│                                                         │
│ ○ Voeding & Dranken                                    │
│   └─ Hygiene: Food (FDA 3A)                            │
│   └─ Filter: Snelkoppeling, Triclamp                 │
│                                                         │
│ ○ Farmaceutisch                                        │
│   └─ Hygiene: Pharma (USP/EP)                          │
│   └─ Filter: Triclamp, Snelkoppeling                 │
│                                                         │
│ ○ Medisch Device                                       │
│   └─ Hygiene: Medical (FDA 21 CFR)                     │
│   └─ Filter: Triclamp (primair)                       │
│                                                         │
│ ○ ATEX (Explosief)                                     │
│   └─ Hygiene: ATEX                                     │
│   └─ Filter: Jacob, Snelkoppeling                    │
│                                                         │
│ Selected: [ Onbekend ▼ ] → Continue                   │
└─────────────────────────────────────────────────────────┘
                          ↓
                   WIZARD STAP 1-6
```

---

## 3. WIZARD STAP 1-6

### Stap 1: Dimensies (Phase B) — VERPLICHT
                          ↓
STAP 0.2: TOEPASSING SELECTIE (Alleen LAMPE)
┌─────────────────────────────────────────────────────────┐
│ Wat is de toepassing/sector?                            │
│ (Dit bepaalt hygiene klasse & voorgeselecteerde Medium) │
│                                                         │
│ ○ Industrieel (Water/Lucht)                            │
│   └─ Hygiene: Algemeen                                 │
│   └─ Mediumopties: Water, Lucht, Olie                  │
│                                                         │
│ ○ Voeding & Dranken                                    │
│   └─ Hygiene: Food (FDA 3A compliant)                  │
│   └─ Mediumopties: Water, Voeding, Zuivel             │
│                                                         │
│ ○ Farmaceutisch                                        │
│   └─ Hygiene: Pharma (USP/EP certified)               │
│   └─ Mediumopties: Steriel Water, API, Solventen     │
│                                                         │
│ ○ Medisch Device                                       │
│   └─ Hygiene: Medical (FDA 21 CFR certified)          │
│   └─ Mediumopties: Steriel Water, Bloed, Zuurstof    │
│                                                         │
│ ○ ATEX (Explosieve omgeving)                           │
│   └─ Hygiene: ATEX (Zone 0/1/2)                       │
│   └─ Mediumopties: Lucht, Stikstof, Inert gas        │
│                                                         │
│ Select → Stap 1 (Dimensies)                            │
└─────────────────────────────────────────────────────────┘
                          ↓
                   STAP 1-7 WIZARD
            (Zien het onderstaande voorstel)
```

---

## 3. LAMPE Wizard — Stap 1-7 (Na Stap 0.2)

### Stap 1: Dimensies (Phase B)
```
┌─────────────────────────────────────────┐
│ Wat is de toepassing?                   │
├─────────────────────────────────────────┤
│ ○ Algemeen industrieel                  │
│ ○ Voeding & drinken                     │
│ ○ Farmaceutisch/steriel                 │ ← Triggert Phase A
│ ○ ATEX (explosief)                      │
│ ○ Medisch device                        │
└─────────────────────────────────────────┘
```

**Backend Action (Phase A):**
- Parse toepassing → `process_medium`, `hygiene_class`
- Load connector database
- Filter beschikbare connectoren op hygiene
- Return: Beschikbare optie-sets

### Stap 2: Medium Selectie (Dynamisch gefiltered)
### Stap 1: Medium Selectie (Phase A)
```
┌──────────────────────────────────────────┐
│ Wat vloeit er door?                      │
│ (Hygiene al gekozen in Stap 0.2)        │
├──────────────────────────────────────────┤
│ ○ Water                                 │
│ ○ Lucht (pneumatisch)                   │
│ ○ Olie (hydrauliek)                     │
│ ○ Voeding (FDA-compliant)               │
│ ○ Farmaceutisch (USP/EP)                │
│ ○ Gas (stikstof, argon)                 │
└──────────────────────────────────────────┘
```

### Stap 4: Connector Selectie (Phase C.1 - KRITISCH)
```
┌──────────────────────────────────────────────────┐
│ Welke connectortype aan beide uiteinden?         │
│ (Gefilterd op Phase A+B constraints)             │
├──────────────────────────────────────────────────┤
│                                                  │
│ EERSTE UITEINDE:                                 │
│                                                  │
│ ✓ Triclamp (sanitary)                            │
│   • Druk: 100 bar (jij: 10 bar) ✓               │
│   • Temp: 100°C (jij: 60°C) ✓                   │
│   • Bore: 16-150 mm (jij: 50 mm) ✓             │
│   • Hygiëne: PHARMA CERTIFIED ✓                 │
│   • OPTIMAAL VOOR MEDISCH                       │
│   [SELECTED]                                    │
│                                                  │
│ ~ Snelkoppeling (quick coupling)                │
│   • Druk: 250 bar ✓ | Temp: 80°C ~ (OK)        │
│   • Bore: 12-100 mm ✓                          │
│   • Hygiëne: Voeding ✓, Medisch ~ (risky)      │
│   • Status: AVAILABLE but ~ RISKY               │
│                                                  │
│ ✗ Jacob (welding)                               │
│   • Reason: Industrieel, niet medisch           │
│   • Status: DISABLED                            │
│                                                  │
│ ✗ BFM (spigot)                                   │
│   • Reason: Bore 100+ mm > 50 mm (te groot)    │
│   • Status: DISABLED                            │
│                                                  │
│ TWEEDE UITEINDE:                                │
│ [Zelfde opties] → [Triclamp ▼ selected]        │
│                                                  │
│ [Next] → Stap 5 (Materiaal)                    │
└──────────────────────────────────────────────────┘
```

### Stap 5: Materiaal & Kleur (Phase B)
```
┌──────────────────────────────────────────┐
│ Materiaal & Kleur                        │
├──────────────────────────────────────────┤
│ Materiaal:                               │
│ ○ PU (Polyurethaan) - Translucent       │
│ ○ Silicone - Rood                       │
│ ○ Rubber - Zwart                        │
│ ○ EPDM - Groen                          │
│ ○ PVC - Grijs                           │
│                                          │
│ Kleur (RGB):                             │
│ [R: ◉─────] 0.9                         │
│ [G: ◉─────] 0.9                         │
│ [B: ◉─────] 0.95                        │
│ [A: ◉─────] 0.15 (transparantie)        │
│                                          │
│ 🖼️ Preview: Translucent witte buis      │
│                                          │
│ [Next] → Stap 6 (Samenvatting)         │
└──────────────────────────────────────────┘
```

### Stap 6: Samenvatting & Validatie (Phase E)
```
┌──────────────────────────────────────────────┐
│ ONTWERP SAMENVATTING - VALIDATIE RAPPORT     │
├──────────────────────────────────────────────┤
│                                              │
```

---

## 4. Flow Diagram — Stap voor Stap

```
┌─────────────────────────────────────────────────────┐
│ STAP 0.0: Kies Product Type                         │
│ ┌──────────────────────────────────────────────────┐│
│ │ ○ Filterslang                                    ││
│ │ ○ Flexibele Verbindingen ← USER KIEST HIER      ││
│ │ ○ BFM Banjo Adapters (toekomst)                 ││
│ └──────────────────────────────────────────────────┘│
└────────────────┬──────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ STAP 0.1: Kies Productgroep                         │
│ ┌──────────────────────────────────────────────────┐│
│ │ ○ LAMPE (Lab/Medical/Pharma) ← ASSUMED          ││
│ │ ○ BFM (Industrial Heavy-Duty)                    ││
│ └──────────────────────────────────────────────────┘│
└────────────────┬──────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ STAP 0.2: Kies Toepassing & Sector                 │
│ ┌──────────────────────────────────────────────────┐│
│ │ Bepaalt: hygiene_class, voorgestelde medium    ││
│ │                                                 ││
│ │ ○ Industrieel                                   ││
│ │ ○ Voeding & Dranken                            ││
│ │ ○ Farmaceutisch ← PHASE A BEGINT               ││
│ │ ○ Medisch Device                               ││
│ │ ○ ATEX (explosief)                             ││
│ │                                                 ││
│ │ Backend Action:                                ││
│ │ → Laad connector database gefilterd op hygiene ││
│ │ → Bepaal welke connectoren beschikbaar zijn    ││
│ └──────────────────────────────────────────────────┘│
└────────────────┬──────────────────────────────────────┘
                 ↓ (Nu begint de 6-staps WIZARD)
┌─────────────────────────────────────────────────────┐
│ STAP 1: Medium Selectie (Phase A Detail)            │
│ → Water, Lucht, Olie, Voeding, Pharma              │
└────────────────┬──────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ STAP 2: Temp & Druk (Phase A Detail)                │
│ → Sliders: -40 tot 120°C, 0.1 tot 400 bar          │
│ → Backend validatie: welke connectoren kunnen dit? │
└────────────────┬──────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ STAP 3: Dimensies (Phase B)                         │
│ → L, D_in, D_out, gap_length                        │
│ → Real-time: wanddikte, volume, grootteklasse      │
│ → Filter connectoren op bore size                   │
└────────────────┬──────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ STAP 4: Connector Selectie (Phase C.1) ← KRITISCH  │
│ → Radio buttons: beschikbare connectoren            │
│ → Gefilterd op Stap 1-3 constraints                 │
│ → Wijd: ✓ OK | ~ RISKY | ✗ DISABLED                │
└────────────────┬──────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ STAP 5: Materiaal & Kleur (Phase B Detail)          │
│ → Dropdown: PU, Silicone, Rubber, EPDM, PVC        │
│ → RGB sliders + transparantie                       │
└────────────────┬──────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────┐
│ STAP 6: Samenvatting & Validatie (Phase E)          │
│ → 4-bloks rapport: Identiteit, Geometrie,          │
│   Verbindingen, Technische Limieten                 │
│ → [GENEREER MODEL] button                           │
└─────────────────────────────────────────────────────┘
```

---

## 5. UI Component Structuur (React/Vue)

### Endpoints

#### POST `/api/fv/validate` (Real-time Phase Validatie)
```python
Request:
{
  "phase": "C.1",  # After which phase to validate
  "config": { ...config object... }
}

Response:
{
  "phase": "C.1",
  "available_connectors": ["triclamp", "snelkoppeling"],
  "unavailable_connectors": {
    "jacob": "bore 12mm is below minimum 20mm",
    "bfm": "bore 12mm is below minimum 100mm (industrial)"
  },
  "recommended_connector": "triclamp",
  "warnings": [
    "snelkoppeling: deadspace 2-5mL at high temperature cycles",
    "process_pressure_max 0.33 bar is ultra-low; most connectors rated 10+ bar"
  ],
  "errors": [],
  "is_valid": True
}
```

#### POST `/api/fv/generate`
```python
Request:
{
  "name": "Medical_SterileWater_800mm",
  "config": { ...full config... }
}

Response (async):
{
  "job_id": "abc-123-def",
  "status": "queued",
  "created_at": "2025-11-30T10:30:00Z",
  "estimated_duration": 15  # seconds
}
```

#### GET `/api/fv/generate/{job_id}`
```python
Response:
{
  "job_id": "abc-123-def",
  "status": "rendering",  # queued, rendering, bom_extracting, dxf_exporting, complete, failed
  "progress": 65,  # percent
  "artifacts": null  # populated when complete
}

# When complete:
{
  "job_id": "abc-123-def",
  "status": "complete",
  "artifacts": {
    "scad_url": "/downloads/Medical_SterileWater_800mm.scad",
    "dxf_url": "/downloads/Medical_SterileWater_800mm.dxf",
    "bom_jsonl_url": "/downloads/bom_technical.jsonl",
    "bom_csv_url": "/downloads/bom_production.csv",
    "bom_xlsx_url": "/downloads/bom_production.xlsx"
  }
}
```

#### GET `/api/fv/connector-database`
```python
Response:
{
  "connectors": {
    "snelkoppeling": {
      "name": "Quick Coupling",
      "icon": "🔌",
      "max_pressure": 250,
      "max_temperature": 80,
      "diameter_min": 12,
      "diameter_max": 100,
      "hygiene_classes": ["general", "food"],
      "description": "Quick disconnect coupling..."
    },
    "jacob": { ... },
    "triclamp": { ... },
    "bfm": { ... }
  }
}
```

---

## 6. Implementatie Roadmap

### Fase 1: Backend Setup (Week 1)
- [ ] FastAPI app structuur
- [ ] Phase A → C.1 validatie logic (reuse OpenSCAD functions)
- [ ] `/api/fv/validate` endpoint
- [ ] Connector database expose via `/api/fv/connector-database`
- [ ] Unit tests voor validatie

### Fase 2: Frontend Basic (Week 2)
- [ ] React/Vue component structuur
- [ ] Stappen 1-4 forms (selection, dimensions)
- [ ] Real-time sliders + input validation
- [ ] State management setup

### Fase 3: Frontend Advanced (Week 3)
- [ ] Stap 5: Connector selectie met filtering
- [ ] Stap 6: Material & kleur selector
- [ ] Stap 7: Design summary rapport
- [ ] Integratie met `/api/fv/validate`

### Fase 4: Generation & Download (Week 4)
- [ ] POST `/api/fv/generate` integratie
- [ ] Job status polling + progress bar
- [ ] Download links voor artefacten
- [ ] Error handling & retry logic

### Fase 5: Polish & Testing (Week 5)
- [ ] Mobile responsiveness
- [ ] Accessibility (a11y)
- [ ] E2E tests
- [ ] Performance optimization

---

## 7. Key Design Decisions

### A. Waarom Stappen-Gebaseerd (Wizard)?
✅ Komplexiteit schijven → gebruiker begeleiding
✅ Backend validatie tussen stappen
✅ Progressive disclosure van opties
✅ Foutmeldingen op juiste moment

### B. Real-time Validatie vs. Submit?
✅ Real-time feedback op Phase A/B → connector pool kennen
✅ Interactieve dimensie-sliders → volume/area direct update
✅ Connector-kaarten met live disabled/warning states

### C. Waarom Validatie Dubbel (Frontend + Backend)?
✅ Frontend: Snelle UX feedback (sliders, disabled options)
✅ Backend: Officiële constraint check (OpenSCAD logic)
✅ Backend is "source of truth" voor Phase A-C.1 routing

### D. Connector Keuze als Separate Stap?
✅ Fase C.1 is kritisch → verdient eigen UI
✅ Tooltips kunnen redenering uitleggen (PASS/FAIL/RISKY)
✅ Connector specs transparant maken (druk, temp, bore)

---

## 8. Foutafhandeling & Validatie-Feedback

### Scenario's

#### Scenario 1: Bore te klein voor geselecteerde connectoren
```
User set: D_in = 8mm
Backend response:
{
  "available_connectors": [],
  "unavailable_connectors": {
    "snelkoppeling": "bore 8mm below minimum 12mm",
    "jacob": "bore 8mm below minimum 20mm",
    "triclamp": "bore 8mm below minimum 16mm",
    "bfm": "bore 8mm below minimum 100mm"
  },
  "errors": ["NO CONNECTORS AVAILABLE - increase bore to 12mm minimum"]
}

Frontend: Show big red error, disable "Next" button
Suggestion: "Verhoog inwendige diameter tot minimaal 12 mm"
```

#### Scenario 2: Temperatuur te hoog voor connector
```
User set: process_temp_surge = 130°C, end_type = "jacob"
Backend: jacob max temp = 120°C
Response: 
{
  "warnings": ["jacob: selected connector max temperature 120°C, but process requires 130°C (surge)"]
}

Frontend: Yellow warning badge op jacob kaart
Tooltip: "⚠️ Welding integrity at risk above 120°C"
```

#### Scenario 3: Druk/Temp combinatie riskant
```
User: thermal cycling (121°C × 50 cycles) + snelkoppeling
Backend:
{
  "warnings": ["snelkoppeling: thermal cycling with standard seals creates progressive degradation risk. 50 cycles at 121°C may exceed seal lifetime."]
}

Frontend: ~ RISKY badge op snelkoppeling kaart
Tooltip: "~ Herhaalde thermische cycli kunnen vochtdichting aantasten"
```

---

## 9. Integratie met Bestaande Filterslang Configurator

### Dual-Product Landing
```
┌────────────────────────────────────────┐
│  CONFIGURATOR TYPE SELECTIE             │
├────────────────────────────────────────┤
│                                        │
│  [1] FILTERSLANG (Huidig)              │
│      └─ 15+ parameters                │
│      └─ Top/Bottom/Ringen/Versterking │
│      └─ Snel & simpel                 │
│      └─ [Start →]                     │
│                                        │
│  [2] FLEXIBELE VERBINDINGEN (Nieuw)    │
│      └─ 5-phase pipeline              │
│      └─ Connector routing             │
│      └─ Constraint validatie          │
│      └─ Medisch/Voeding/Industrie     │
│      └─ [Start →]                     │
│                                        │
└────────────────────────────────────────┘
```

### Gedeelde Code
```
Frontend:
  • Step indicator component
  • Form validation utils
  • Download handler

Backend:
  • Parameter parsing (YAML/JSON)
  • BOM extraction (existing Python)
  • File generation (existing Python)
```

---

## 10. Checklist voor Implementatie

- [ ] **Backend Phase A-C.1 logica exporteren** (uit OpenSCAD naar Python)
- [ ] **Connector database definities** (JSON/TOML)
- [ ] **FastAPI endpoints** (`/validate`, `/generate`, `/status`)
- [ ] **Frontend React components** (stappen 1-7)
- [ ] **State management** (Context API of Redux)
- [ ] **Real-time validation** (debounce sliders)
- [ ] **Error boundaries** (mooie foutpagina's)
- [ ] **Progress tracking** (job polling)
- [ ] **Download management** (file cleanup na 1 uur)
- [ ] **Testing** (unit + E2E)
- [ ] **Documentation** (user guide + API docs)
- [ ] **Deployment** (Docker, env vars)
