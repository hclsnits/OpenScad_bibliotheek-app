# Frontend Configurator Specification

## Overview

This document describes the OpenSCAD Filterslang Generator architecture to enable building a web/desktop frontend that integrates with the existing CLI tool.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend UI                              │
│  (Web/Desktop - React, Vue, Svelte, or similar)             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              REST/GraphQL API Backend                        │
│  (Node.js, Python Flask/FastAPI, or similar)                │
│                                                              │
│  - Serves preset definitions                                │
│  - Validates configurations                                 │
│  - Orchestrates CLI tool execution                          │
│  - Manages file storage                                     │
│  - Streams/polls generation progress                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│       Existing CLI Tool (generate_model.py)                 │
│                                                              │
│  ✓ Config parsing (YAML)                                    │
│  ✓ Parameter validation                                     │
│  ✓ OpenSCAD orchestration                                   │
│  ✓ BOM extraction & Excel generation                        │
│  ✓ DXF export                                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│       Core Artifacts (no changes needed)                    │
│                                                              │
│  ✓ OpenSCAD files (products/filterslang/*.scad)             │
│  ✓ Presets (products/filterslang/presets.yaml)              │
│  ✓ Schema validation (config_schema.json)                   │
│  ✓ Parts catalog (data/parts.csv)                           │
└─────────────────────────────────────────────────────────────┘
```

## Configuration Data Model

### Preset System

Two material presets with predefined constraints and sizes:

```json
{
  "PE_500": {
    "material": "Polyethylene",
    "weight": "500 g/m²",
    "defaults": {
      "thickness": 2.0,
      "diameter_min": 60,
      "diameter_max": 400,
      "length_min": 300,
      "length_max": 4000
    },
    "recommended_sizes": [
      {
        "name": "Small",
        "diameter": 100,
        "length": 1000,
        "thickness": 1.2
      },
      {
        "name": "Medium",
        "diameter": 160,
        "length": 2000,
        "thickness": 2.0
      },
      {
        "name": "Large",
        "diameter": 250,
        "length": 3500,
        "thickness": 2.5
      }
    ],
    "valid_enums": {
      "top": ["snapring", "kopring", "klemband", "clips", "veer", "zonder", "customtop", "othertype"],
      "bottom": ["enkel", "dubbel", "platdicht"],
      "bottom_opt": ["zonder", "lusje", "gat", "zoom", "customopt"],
      "productzijde": ["buiten", "binnen"],
      "reinforce_side": ["boven", "onder"]
    }
  },
  "PPS_550": {
    "material": "Polyphenylene Sulfide",
    "weight": "550 g/m²",
    "temperature_rating": "High-temp resistant",
    "defaults": {
      "thickness": 1.8,
      "diameter_min": 80,
      "diameter_max": 350,
      "length_min": 500,
      "length_max": 3500
    },
    "recommended_sizes": [
      {
        "name": "Small",
        "diameter": 120,
        "length": 1200,
        "thickness": 1.5
      },
      {
        "name": "Medium",
        "diameter": 180,
        "length": 2500,
        "thickness": 1.8
      },
      {
        "name": "Large",
        "diameter": 280,
        "length": 3200,
        "thickness": 2.0
      }
    ],
    "valid_enums": { ... }
  }
}
```

### Configuration Structure

```json
{
  "name": "PE500_Medium_Standard",
  "preset": "PE_500",
  "overrides": {
    "L": 2000,
    "D": 160,
    "t": 2.0,
    "top": "snapring",
    "bottom": "platdicht",
    "bottom_opt": "zoom",
    "rings_auto": true,
    "rings_count": 6,
    "ring_w": 10,
    "ring_t": 2,
    "reinforce_enable": true,
    "reinforce_side": "boven",
    "reinforce_spans": [[100, 200]],
    "productzijde": "buiten"
  }
}
```

### Validation Rules

**Structural validation** (from `config_schema.json`):
- `name` — string, required, alphanumeric + underscore
- `preset` — enum, required (PE_500 | PPS_550)
- `overrides` — object, all fields optional (validation only when provided)

**Range validation** (from presets):
- `L` (length) — number, min/max from preset
- `D` (diameter) — number, min/max from preset
- `t` (thickness) — number, typically 0.5–3.5mm

**Enum validation** (from presets):
- `top` — constrained to preset's valid values
- `bottom` — "enkel" | "dubbel" | "platdicht"
- `bottom_opt` — conditional (depends on `bottom` value)
- `reinforce_side` — "boven" | "onder"
- `productzijde` — "buiten" | "binnen"

**Conditional rules**:
- If `rings_auto=true` → `rings_count` used, `rings_positions` ignored
- If `rings_auto=false` → `rings_positions` array used, `rings_count` ignored
- If `reinforce_enable=false` → `reinforce_side` and `reinforce_spans` ignored

## Frontend UI Flow

### Step 1: Material Selection
```
┌─────────────────────────────────────────┐
│  Select Material Preset                 │
│                                         │
│  ○ PE_500 (Polyethylene, 500 g/m²)     │
│  ○ PPS_550 (Polyphenylene, 550 g/m²)   │
│                                         │
│  [Next] or [View Preset Details]       │
└─────────────────────────────────────────┘
```

**Backend**: Return preset definition with all constraints and valid enum values

### Step 2: Size Selection (Optional Quick Path)
```
┌─────────────────────────────────────────┐
│  Recommended Sizes (PE_500)              │
│                                         │
│  ○ Small   (D=100, L=1000, t=1.2)      │
│  ○ Medium  (D=160, L=2000, t=2.0) ← Selected
│  ○ Large   (D=250, L=3500, t=2.5)      │
│                                         │
│  [Continue] or [Custom Dimensions]     │
└─────────────────────────────────────────┘
```

**Backend**: Validate selected size against preset constraints

### Step 3: Basic Configuration
```
┌─────────────────────────────────────────┐
│  Filter Dimensions                      │
│                                         │
│  Length (L):       [2000______] mm      │
│                    (300–4000 mm)        │
│                                         │
│  Diameter (D):     [160_______] mm      │
│                    (60–400 mm)          │
│                                         │
│  Thickness (t):    [2.0_______] mm      │
│                    (1.2–3.0 mm)         │
│                                         │
│  [Next →] [← Back]                     │
└─────────────────────────────────────────┘
```

**Validation**: Real-time range checking against preset constraints

### Step 4: Closure Types
```
┌─────────────────────────────────────────┐
│  Top Closure                            │
│  ○ Snapring    ○ Kopring    ○ Klemband │
│  ○ Clips       ○ Veer       ○ Zonder   │
│                                         │
│  Bottom Type                            │
│  ○ Enkel (single)                       │
│  ○ Dubbel (double)                      │
│  ○ Platdicht (sealed)  ← Selected       │
│                                         │
│  Bottom Option (conditional)            │
│  ○ Zonder    ○ Lusje    ○ Gat          │
│  ○ Zoom              ← Selected         │
│  [Show: only if bottom selected]        │
│                                         │
│  [Next →] [← Back]                     │
└─────────────────────────────────────────┘
```

**Validation**: Enum validation, conditional field visibility

### Step 5: Reinforcement Configuration
```
┌─────────────────────────────────────────┐
│  Reinforcement Rings                    │
│                                         │
│  ☑ Enable reinforcement                 │
│                                         │
│  Distribution Mode:                     │
│  ○ Auto-distribute (count-based)        │
│  ○ Manual positions (array-based)       │
│                                         │
│  [Auto selected]                        │
│  Number of rings: [6_] (0–20)          │
│  Ring width:      [10_] mm              │
│  Ring thickness:  [2__] mm              │
│                                         │
│  [Manual selected]                      │
│  Positions: [100, 400, 600] mm          │
│  [+ Add]  [- Remove]                    │
│                                         │
│  Reinforcement Side:                    │
│  ○ Boven (top)   ○ Onder (bottom)       │
│                                         │
│  [Next →] [← Back]                     │
└─────────────────────────────────────────┘
```

**Logic**: 
- Toggle `reinforce_enable` shows/hides entire section
- Switch between auto/manual modes conditionally shows fields
- If manual: show repeatable position inputs

### Step 6: Advanced Options
```
┌─────────────────────────────────────────┐
│  Advanced Options                       │
│                                         │
│  Material Side (Productzijde):          │
│  ○ Buiten (outside)  ○ Binnen (inside) │
│                                         │
│  Configuration Name:                    │
│  [PE500_Medium_Standard_____]           │
│  (auto-generated, editable)             │
│                                         │
│  [Next →] [← Back]                     │
└─────────────────────────────────────────┘
```

### Step 7: Review & Generate
```
┌─────────────────────────────────────────┐
│  Configuration Summary                  │
│                                         │
│  Material:        PE_500                │
│  Name:            PE500_Medium_Standard │
│  Dimensions:      L=2000, D=160, t=2.0 │
│  Top:             Snapring              │
│  Bottom:          Platdicht + Zoom      │
│  Rings:           6 (auto-distributed) │
│  Reinforcement:   Enabled (boven)      │
│                                         │
│  Output will include:                   │
│  ✓ 3D Model (SCAD)                     │
│  ✓ Production BOM (Excel + CSV)        │
│  ✓ Technical BOM (JSON)                │
│  ✓ 2D Projection (DXF for CAD)         │
│                                         │
│  [Generate] or [Edit] [Cancel]         │
└─────────────────────────────────────────┘
```

### Step 8: Generation Progress
```
┌─────────────────────────────────────────┐
│  Generating Model...                    │
│                                         │
│  [████████░░░░░░░░░░] 50%              │
│                                         │
│  Step 1/5: Parsing configuration  ✓   │
│  Step 2/5: Generating SCAD file   ✓   │
│  Step 3/5: Rendering with OpenSCAD ⏳ │
│  Step 4/5: Extracting BOM         ⏳   │
│  Step 5/5: Generating DXF         ⏳   │
│                                         │
│  [Cancel]                               │
└─────────────────────────────────────────┘
```

### Step 9: Results Download
```
┌─────────────────────────────────────────┐
│  ✓ Generation Complete!                 │
│                                         │
│  Download your model:                   │
│                                         │
│  📄 PE500_Medium_Standard.dxf           │
│     (2D CAD drawing, 6.1 KB)            │
│                                         │
│  📊 PE500_Medium_Standard_bom.xlsx      │
│     (Production BOM, 5.5 KB)            │
│                                         │
│  📋 PE500_Medium_Standard_bom.csv       │
│     (ERP format, 317 B)                 │
│                                         │
│  📝 PE500_Medium_Standard_bom.jsonl     │
│     (Technical parameters, 402 B)      │
│                                         │
│  [Download All] [View DXF] [View BOM]  │
│  [Generate Another] [Share Config]     │
└─────────────────────────────────────────┘
```

## API Endpoints (Backend Required)

### GET `/api/presets`
Returns all preset definitions with constraints and valid enums.

```json
{
  "presets": {
    "PE_500": { ... },
    "PPS_550": { ... }
  }
}
```

### GET `/api/presets/:preset_id`
Returns single preset with detailed info.

### POST `/api/validate`
Validate configuration without generating.

**Request:**
```json
{
  "name": "test_config",
  "preset": "PE_500",
  "overrides": { ... }
}
```

**Response:**
```json
{
  "valid": true,
  "errors": [],
  "warnings": []
}
```

Or:
```json
{
  "valid": false,
  "errors": [
    "diameter must be between 60 and 400 (got 500)",
    "bottom_opt requires bottom to be set"
  ]
}
```

### POST `/api/generate`
Trigger model generation (async job).

**Request:**
```json
{
  "name": "PE500_Medium_Standard",
  "preset": "PE_500",
  "overrides": { ... }
}
```

**Response:**
```json
{
  "job_id": "abc-123-def",
  "status": "queued",
  "created_at": "2025-11-28T21:00:00Z"
}
```

### GET `/api/generate/:job_id`
Poll generation status and progress.

**Response (in progress):**
```json
{
  "job_id": "abc-123-def",
  "status": "processing",
  "progress": 60,
  "current_step": "Rendering with OpenSCAD",
  "logs": [
    "[INFO] Parsing configuration...",
    "[INFO] Generating OpenSCAD file..."
  ]
}
```

**Response (complete):**
```json
{
  "job_id": "abc-123-def",
  "status": "completed",
  "progress": 100,
  "outputs": {
    "dxf": { "filename": "PE500_Medium_Standard.dxf", "size": 6188, "mime": "application/dxf" },
    "xlsx": { "filename": "PE500_Medium_Standard_bom_production.xlsx", "size": 5500, "mime": "application/vnd.openxmlformats" },
    "csv": { "filename": "PE500_Medium_Standard_bom.csv", "size": 317, "mime": "text/csv" },
    "jsonl": { "filename": "PE500_Medium_Standard_bom.jsonl", "size": 402, "mime": "application/x-jsonlines" }
  },
  "download_url": "/api/download/abc-123-def"
}
```

### GET `/api/download/:job_id/:file_type`
Download generated file.

### GET `/api/configs/examples`
Get list of example configurations (for quick-start templates).

```json
{
  "examples": [
    {
      "id": "example_pe500_medium",
      "name": "PE500 Medium (Standard Production)",
      "preset": "PE_500",
      "config": { ... }
    },
    { ... }
  ]
}
```

### POST `/api/configs`
Save configuration to database (optional, for user library).

### GET `/api/configs`
Retrieve saved configurations (optional).

## Data Flow

```
User Input (Frontend)
    ↓
Validation (Frontend + Backend)
    ↓
Config JSON
    ↓
Backend: generate_model.py orchestration
    ├─ config_to_params.py (parse YAML)
    ├─ generate_model.py (template + render)
    ├─ OpenSCAD rendering
    ├─ render_bom.py (extract BOM)
    ├─ bom_producer.py (Excel generation)
    ↓
Output Files (SCAD, ECHO, JSONL, CSV, XLSX, DXF)
    ↓
File Storage (filesystem or S3)
    ↓
Download Links (Frontend)
    ↓
User Downloads
```

## Integration Points

### 1. **Configuration Serialization**
Frontend generates YAML config string, backend passes to CLI:

```python
# Backend pseudo-code
config_yaml = f"""
name: "{config['name']}"
preset: "{config['preset']}"

overrides:
  L: {config['overrides']['L']}
  D: {config['overrides']['D']}
  t: {config['overrides']['t']}
  top: "{config['overrides']['top']}"
  ...
"""

# Pass to CLI
subprocess.run([
    "python", "scripts/generate_model.py",
    "--config", config_yaml_file,
    "--presets", "products/filterslang/presets.yaml",
    "--output-dir", output_dir
])
```

### 2. **Progress Streaming**
Backend captures CLI output in real-time:

```python
# Capture generation progress from DEBUG logs
process = subprocess.Popen(..., stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
for line in process.stderr:
    if "[INFO]" in line:
        update_job_status(job_id, parse_progress(line))
    # Stream to frontend via WebSocket
```

### 3. **Error Handling**
Backend validates before CLI invocation, catches subprocess errors:

```python
try:
    result = subprocess.run([...], capture_output=True, timeout=300)
    if result.returncode != 0:
        job_status = "failed"
        error_msg = result.stderr
except subprocess.TimeoutExpired:
    job_status = "timeout"
except Exception as e:
    job_status = "error"
    error_msg = str(e)
```

## Frontend Technology Recommendations

### Option 1: React (Recommended for complex UX)
- **Pros**: Rich ecosystem, state management (Redux/Zustand), TypeScript support
- **Components**: React Hook Form for multi-step wizard, Recharts for progress visualization
- **Libraries**: `axios` for API calls, `react-query` for async state management

### Option 2: Vue 3
- **Pros**: Simpler learning curve, excellent documentation, good form handling
- **Libraries**: `vee-validate` for validation, Pinia for state management

### Option 3: Svelte
- **Pros**: Extremely lightweight, less boilerplate, great performance
- **Libraries**: SvelteKit for framework, `zod` for validation

### Option 4: Static HTML + HTMX
- **Pros**: Minimal JavaScript, works without build tools
- **Approach**: Form submission → Backend → HTML response + partial updates

## Backend Technology Recommendations

### Option 1: Python FastAPI (Recommended)
- **Pros**: Native Python, integrates easily with existing `generate_model.py`
- **Async**: WebSocket support for progress streaming
- **Code Example**:
```python
from fastapi import FastAPI, BackgroundTasks
from fastapi.responses import FileResponse
import asyncio, subprocess

app = FastAPI()

@app.post("/api/generate")
async def generate(config: ConfigSchema, background_tasks: BackgroundTasks):
    job_id = generate_job_id()
    background_tasks.add_task(run_generation, job_id, config)
    return {"job_id": job_id, "status": "queued"}

async def run_generation(job_id, config):
    # Serialize config to YAML
    # Execute subprocess with polling
    # Update job status in database/cache
```

### Option 2: Node.js Express
- **Pros**: Easy to deploy, good for real-time updates
- **Approach**: Spawn Python subprocess, stream output via WebSocket

### Option 3: Python Flask
- **Simpler** than FastAPI, fewer features needed

## Key UI/UX Considerations

### 1. **Preset-Driven Simplification**
- Start with preset selection to constrain parameter space
- Show recommended sizes as quick paths
- Allow "Advanced" mode for full parameter control

### 2. **Real-Time Validation**
- Validate each field as user types (debounced)
- Show range/constraint feedback immediately
- Disable invalid enum combinations

### 3. **Progressive Disclosure**
- Hide advanced options (reinforcement, side, material side) until needed
- Show conditional fields based on selections
- Keep UI clean and focused

### 4. **Visual Feedback**
- Multi-step form with progress indicator
- Live generation progress with step details
- Clear success/error messaging

### 5. **Accessibility**
- WCAG 2.1 AA compliant
- Keyboard navigation for all inputs
- Screen reader support for dynamic updates

## Database Schema (Optional)

If storing user configurations:

```sql
CREATE TABLE user_configs (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  name VARCHAR NOT NULL,
  preset VARCHAR NOT NULL,
  config_json JSONB NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE generation_jobs (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  config_id UUID,
  status ENUM ('queued', 'processing', 'completed', 'failed'),
  progress INT DEFAULT 0,
  output_files JSONB,
  error_message TEXT,
  created_at TIMESTAMP,
  completed_at TIMESTAMP
);
```

## Deployment Considerations

### Development
- Frontend: `npm start` (React/Vue/Svelte dev server)
- Backend: `python -m uvicorn app:app --reload`
- CLI: Already installed in venv

### Production
- **Containerization**: Docker with venv, OpenSCAD pre-installed
- **Async Jobs**: Celery or similar for long-running CLI execution
- **File Storage**: S3 or local filesystem with cleanup jobs
- **Rate Limiting**: Prevent abuse of expensive OpenSCAD rendering
- **Caching**: Cache preset definitions and validation rules

## Example Implementation Path

1. **Phase 1**: Basic form (Material → Dimensions → Closures)
2. **Phase 2**: Add reinforcement configuration
3. **Phase 3**: Add generation progress + download
4. **Phase 4**: Add user authentication + config saving
5. **Phase 5**: Advanced features (batch generation, templates, etc.)
