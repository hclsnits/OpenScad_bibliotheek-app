#!/usr/bin/env python3
# scripts/config_to_params.py
# Parse user YAML config + presets → OpenSCAD parameters

import sys, json, argparse, yaml
from pathlib import Path

p = argparse.ArgumentParser(description="Parse YAML config + presets → OpenSCAD parameters (JSON)")
p.add_argument("--config", required=True, help="User config YAML file")
p.add_argument("--presets", required=True, help="Presets YAML file")
p.add_argument("--output", default="", help="Output parameters JSON (optional; stdout if omitted)")
p.add_argument("--debug", action="store_true", help="Print debug info")
args = p.parse_args()

# --- Load presets ---
with open(args.presets, encoding="utf-8") as f:
    presets_data = yaml.safe_load(f)

presets = presets_data.get("presets", {})
valid_enums = presets_data.get("valid_enums", {})

if args.debug:
    sys.stderr.write(f"Loaded presets: {list(presets.keys())}\n")

# --- Load user config ---
with open(args.config, encoding="utf-8") as f:
    user_config = yaml.safe_load(f)

if not user_config:
    sys.stderr.write("ERROR: Config file is empty\n")
    sys.exit(1)

# --- Extract config fields ---
config_name = user_config.get("name", "unnamed")
preset_name = user_config.get("preset")
overrides = user_config.get("overrides", {})

if not preset_name:
    sys.stderr.write("ERROR: 'preset' field required in config\n")
    sys.exit(1)

if preset_name not in presets:
    sys.stderr.write(f"ERROR: Unknown preset '{preset_name}'. Available: {list(presets.keys())}\n")
    sys.exit(1)

preset = presets[preset_name]

# --- Build parameters (preset defaults + user overrides) ---
params = {
    "medium": preset["material"],
    "bom_tag": config_name,
}

# Set defaults from preset
if "defaults" in preset:
    params.update(preset["defaults"])

# Apply user overrides
params.update(overrides)

# --- Validation ---
errors = []

# Check required fields
required = ["L", "D", "t", "top", "bottom", "productzijde"]
for field in required:
    if field not in params:
        errors.append(f"Missing required parameter: {field}")

# Validate enum values
if "top" in params and params["top"] not in valid_enums.get("top", []):
    errors.append(f"Invalid top value: {params['top']}")

if "bottom" in params and params["bottom"] not in valid_enums.get("bottom", []):
    errors.append(f"Invalid bottom value: {params['bottom']}")

# Validate bottom_opt based on bottom type
if "bottom_opt" in params and "bottom" in params:
    bottom_type = params["bottom"]
    bottom_opt_val = params["bottom_opt"]
    valid_opts = valid_enums.get("bottom_opt", {}).get(bottom_type, [])
    if bottom_opt_val not in valid_opts:
        errors.append(f"Invalid bottom_opt '{bottom_opt_val}' for bottom type '{bottom_type}'. Valid: {valid_opts}")

if "productzijde" in params and params["productzijde"] not in valid_enums.get("productzijde", []):
    errors.append(f"Invalid productzijde: {params['productzijde']}")

if "reinforce_side" in params and params["reinforce_side"] not in valid_enums.get("reinforce_side", []):
    errors.append(f"Invalid reinforce_side: {params['reinforce_side']}")

# Check dimension ranges
preset_defaults = preset.get("defaults", {})
if "diameter_min" in preset_defaults and params.get("D", 0) < preset_defaults["diameter_min"]:
    errors.append(f"Diameter {params['D']} below preset minimum {preset_defaults['diameter_min']}")
if "diameter_max" in preset_defaults and params.get("D", 0) > preset_defaults["diameter_max"]:
    errors.append(f"Diameter {params['D']} above preset maximum {preset_defaults['diameter_max']}")

if errors:
    sys.stderr.write("Validation errors:\n")
    for err in errors:
        sys.stderr.write(f"  - {err}\n")
    sys.exit(1)

if args.debug:
    sys.stderr.write(f"✓ Validation passed\n")
    sys.stderr.write(f"Generated parameters:\n")
    for k, v in sorted(params.items()):
        sys.stderr.write(f"  {k}: {v}\n")

# --- Output ---
params_json = json.dumps(params, indent=2, ensure_ascii=False)

if args.output:
    Path(args.output).write_text(params_json, encoding="utf-8")
    print(f"✓ Parameters written to {args.output}")
else:
    print(params_json)

sys.exit(0)
