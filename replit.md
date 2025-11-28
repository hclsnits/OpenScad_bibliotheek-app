# OpenSCAD Filterslang Generator

## Project Overview

This is a parametric 3D filter sleeve generator built with OpenSCAD and Python. It provides both a command-line interface and a web-based configurator for generating custom filter sleeves with automated Bill of Materials (BOM) extraction and 2D CAD exports.

**Current State:** Fully functional web application running on Replit with Flask frontend.

## Recent Changes (2025-11-28)

- Installed Python dependencies: PyYAML, Jinja2, openpyxl, Flask, Flask-CORS
- Installed OpenSCAD 2021.01 for 3D model rendering
- Created Flask web application (`app.py`) with REST API endpoints
- Created web UI configurator (`templates/index.html`) with multi-step form
- Configured Flask to run on 0.0.0.0:5000 (required for Replit proxy)
- Set up workflow for Flask Frontend on port 5000
- Configured deployment for autoscale (stateless web app)
- Added .gitignore for Python and generated files
- Successfully tested CLI generation with example configurations
- **Improvements after architect review:**
  - Enhanced error handling: subprocess failures now capture stderr/stdout as error_details
  - Improved frontend error display with dedicated error area and retry buttons
  - Added visual feedback (red progress bar) when generation fails
  - Error details now surfaced to users with actionable guidance
  - Reset functionality clears error states properly

## Project Architecture

### Backend (Python)
- **app.py**: Flask web server providing REST API and serving the configurator UI
  - Binds to 0.0.0.0:5000 (allows Replit proxy access)
  - CORS enabled for cross-origin requests
  - Background job processing for model generation
  
- **CLI Tools** (in `scripts/`):
  - `generate_model.py`: Main orchestrator for model generation
  - `config_to_params.py`: Parses YAML configs and validates against presets
  - `render_bom.py`: Extracts BOM from OpenSCAD echo output
  - `bom_producer.py`: Generates Excel BOMs for production

### Frontend
- **templates/index.html**: Multi-step web configurator with:
  - Material preset selection (PE_500, PPS_550)
  - Dimension configuration with validation
  - Closure type selection
  - Real-time progress tracking during generation
  - File download interface for generated outputs

### Core Assets
- **products/filterslang/**: OpenSCAD library and presets
  - `filterslang.scad`: Core OpenSCAD module
  - `presets.yaml`: Material presets with constraints and valid values
  - `config_schema.json`: Validation schema
  
- **data/parts.csv**: Parts catalog for BOM generation

### Output Files
Generated models produce:
- `.dxf` - 2D CAD drawing for manufacturing
- `_bom_production.xlsx` - Excel BOM for production planning
- `_bom.csv` - CSV BOM for ERP integration
- `_bom.jsonl` - Technical parameters in JSON format

## How to Use

### Web Interface (Recommended)
1. Open the Replit webview - the configurator will load automatically
2. Select a material preset (PE_500 or PPS_550)
3. Configure dimensions (length, diameter, thickness)
4. Choose closure types
5. Review and generate
6. Download generated files (DXF, Excel, CSV, JSON)

### Command Line
```bash
python scripts/generate_model.py \
  --config configs/example_pe500_medium.yaml \
  --presets products/filterslang/presets.yaml \
  --output-dir out/custom_models
```

## API Endpoints

- `GET /api/presets` - Get all material presets
- `GET /api/presets/<preset_id>` - Get specific preset
- `POST /api/validate` - Validate configuration
- `POST /api/generate` - Start model generation job
- `GET /api/generate/<job_id>` - Poll job status
- `GET /api/download/<job_id>/<file_type>` - Download generated file
- `GET /api/examples` - Get example configurations

## Configuration Structure

Example configuration:
```yaml
name: "My_Custom_Filter"
preset: "PE_500"  # or "PPS_550"

overrides:
  L: 2000           # Length (mm)
  D: 160            # Diameter (mm)
  t: 2.0            # Thickness (mm)
  top: "snapring"   # Top closure type
  bottom: "platdicht"
  bottom_opt: "zoom"
  productzijde: "buiten"  # Material side
  rings_auto: true
  rings_count: 6
  ring_w: 10
  ring_t: 2
  reinforce_enable: false
```

## Technical Details

### Dependencies
- **Python 3.11** with packages:
  - flask, flask-cors (web server)
  - jinja2 (templating)
  - pyyaml (config parsing)
  - openpyxl (Excel generation)
  
- **OpenSCAD 2021.01** (3D model rendering)

### Replit Configuration
- **Workflow**: Flask Frontend runs `python app.py` on port 5000
- **Deployment**: Configured for autoscale (stateless web app)
- **Host Configuration**: Allows all hosts (0.0.0.0) for Replit proxy compatibility

## File Structure
```
.
├── app.py                          # Flask web server
├── templates/
│   └── index.html                  # Web configurator UI
├── scripts/                        # CLI tools
│   ├── generate_model.py          # Main generator
│   ├── config_to_params.py        # Config parser
│   ├── render_bom.py              # BOM extractor
│   └── bom_producer.py            # Excel generator
├── products/filterslang/          # OpenSCAD library
│   ├── filterslang.scad
│   ├── presets.yaml
│   └── config_schema.json
├── configs/                        # Example configs
├── data/                           # Parts catalog
├── out/                            # Generated outputs
│   └── custom_models/             # Web-generated models
└── lib/core/                       # OpenSCAD utilities
```

## Notes for Future Development

### Known Features
- Multi-step wizard UI for configuration
- Real-time validation against preset constraints
- Background job processing with progress tracking
- Automatic BOM generation from OpenSCAD output
- Support for custom reinforcement rings and spans

### Testing Status
- ✅ CLI generation tested and working
- ✅ Web UI loads and displays presets correctly
- ✅ All output formats generated (DXF, Excel, CSV, JSON)
- ✅ OpenSCAD rendering functional

### Future Enhancements (if needed)
- Add more material presets
- Implement user authentication for saved configurations
- Add 3D preview visualization
- Support for batch generation
- Integration with external CAD systems
