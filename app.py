#!/usr/bin/env python3
"""
Flask web frontend for OpenSCAD Filterslang Generator
Provides a configurator UI and API endpoints for model generation
"""

import os
import sys
import json
import yaml
import uuid
import subprocess
import threading
from pathlib import Path
from datetime import datetime
from flask import Flask, render_template, request, jsonify, send_file
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Configuration
OUTPUT_DIR = Path("out/custom_models")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
PRESETS_FILE = Path("products/filterslang/presets.yaml")
JOBS = {}

# Load presets
with open(PRESETS_FILE, 'r', encoding='utf-8') as f:
    PRESETS_DATA = yaml.safe_load(f)

PRESETS = PRESETS_DATA.get('presets', {})
VALID_ENUMS = PRESETS_DATA.get('valid_enums', {})

# Connector Database (Phase C.1)
CONNECTOR_DATABASE = {
    'snelkoppeling': {
        'name': 'Quick Coupling (Snelkoppeling)',
        'icon': '🔌',
        'max_pressure': 250,
        'max_temperature': 80,
        'diameter_min': 12,
        'diameter_max': 100,
        'hygiene_classes': ['general', 'food'],
        'description': 'Quick disconnect coupling for general industrial and food applications'
    },
    'jacob': {
        'name': 'Welding End (Jacob)',
        'icon': '🔗',
        'max_pressure': 50,
        'max_temperature': 120,
        'diameter_min': 20,
        'diameter_max': 150,
        'hygiene_classes': ['general', 'atex'],
        'description': 'Permanent welding connector for industrial use. Not reusable.'
    },
    'triclamp': {
        'name': 'Triclamp (Sanitary)',
        'icon': '🔧',
        'max_pressure': 100,
        'max_temperature': 100,
        'diameter_min': 16,
        'diameter_max': 150,
        'hygiene_classes': ['food', 'pharma', 'medical'],
        'description': 'Sanitary clamp connector. Perfect for food, pharmaceutical, and medical applications.'
    },
    'bfm': {
        'name': 'BFM Spigot',
        'icon': '⚙️',
        'max_pressure': 280,
        'max_temperature': 100,
        'diameter_min': 100,
        'diameter_max': 999,
        'hygiene_classes': ['general'],
        'description': 'Heavy-duty spigot connector for industrial hydraulic/pneumatic systems.'
    }
}

# Sector to Hygiene Class Mapping
SECTOR_HYGIENE_MAP = {
    'onbekend': None,
    'industrieel': 'general',
    'voeding': 'food',
    'farmaceutisch': 'pharma',
    'medisch': 'medical',
    'atex': 'atex'
}


@app.route('/')
def index():
    """Serve the main configurator UI"""
    return render_template('index.html')


@app.route('/api/presets', methods=['GET'])
def get_presets():
    """Get all preset definitions"""
    return jsonify({
        'presets': PRESETS,
        'valid_enums': VALID_ENUMS
    })


@app.route('/api/presets/<preset_id>', methods=['GET'])
def get_preset(preset_id):
    """Get a specific preset"""
    if preset_id not in PRESETS:
        return jsonify({'error': f'Preset {preset_id} not found'}), 404
    
    return jsonify({
        'preset': PRESETS[preset_id],
        'valid_enums': VALID_ENUMS
    })


@app.route('/api/connectors', methods=['GET'])
def get_connectors():
    """Get connector database"""
    return jsonify({
        'connectors': CONNECTOR_DATABASE
    })


@app.route('/api/validate', methods=['POST'])
def validate_config():
    """Validate a configuration without generating"""
    config = request.get_json()
    
    errors = []
    warnings = []
    
    # Check required fields
    if 'name' not in config:
        errors.append('Config name is required')
    if 'preset' not in config:
        errors.append('Preset is required')
    elif config['preset'] not in PRESETS:
        errors.append(f"Invalid preset: {config['preset']}")
    
    overrides = config.get('overrides', {})
    
    # Basic dimension validation
    if 'preset' in config and config['preset'] in PRESETS:
        preset = PRESETS[config['preset']]
        defaults = preset.get('defaults', {})
        
        # Check diameter
        if 'D' in overrides:
            d_min = defaults.get('diameter_min', 0)
            d_max = defaults.get('diameter_max', 999999)
            if overrides['D'] < d_min or overrides['D'] > d_max:
                errors.append(f"Diameter must be between {d_min} and {d_max}")
        
        # Check length
        if 'L' in overrides:
            l_min = defaults.get('length_min', 0)
            l_max = defaults.get('length_max', 999999)
            if overrides['L'] < l_min or overrides['L'] > l_max:
                errors.append(f"Length must be between {l_min} and {l_max}")
    
    # Enum validation
    if 'top' in overrides:
        valid_tops = VALID_ENUMS.get('top', [])
        if overrides['top'] not in valid_tops:
            errors.append(f"Invalid top closure: {overrides['top']}")
    
    if 'bottom' in overrides:
        valid_bottoms = VALID_ENUMS.get('bottom', [])
        if overrides['bottom'] not in valid_bottoms:
            errors.append(f"Invalid bottom type: {overrides['bottom']}")
    
    return jsonify({
        'valid': len(errors) == 0,
        'errors': errors,
        'warnings': warnings
    })


@app.route('/api/generate', methods=['POST'])
def generate_model():
    """Start a model generation job"""
    config = request.get_json()
    
    # Validate first
    validation = validate_config()
    validation_data = validation.get_json()
    
    if not validation_data['valid']:
        return jsonify({
            'error': 'Configuration validation failed',
            'details': validation_data['errors']
        }), 400
    
    # Create job ID
    job_id = str(uuid.uuid4())[:8]
    
    # Create job metadata
    JOBS[job_id] = {
        'id': job_id,
        'status': 'queued',
        'progress': 0,
        'current_step': 'Initializing...',
        'created_at': datetime.now().isoformat(),
        'config': config,
        'logs': [],
        'outputs': {}
    }
    
    # Start generation in background thread
    thread = threading.Thread(target=run_generation, args=(job_id, config))
    thread.daemon = True
    thread.start()
    
    return jsonify({
        'job_id': job_id,
        'status': 'queued',
        'created_at': JOBS[job_id]['created_at']
    })


def run_generation(job_id, config):
    """Background task to run model generation"""
    job = JOBS[job_id]
    
    try:
        job['status'] = 'processing'
        job['progress'] = 10
        job['current_step'] = 'Creating configuration file...'
        
        # Create temporary config YAML
        config_name = config.get('name', 'unnamed')
        config_yaml_file = OUTPUT_DIR / f"{config_name}_config.yaml"
        
        with open(config_yaml_file, 'w', encoding='utf-8') as f:
            yaml.dump(config, f)
        
        job['logs'].append('[INFO] Configuration file created')
        job['progress'] = 20
        job['current_step'] = 'Running model generator...'
        
        # Run generate_model.py
        cmd = [
            sys.executable, 'scripts/generate_model.py',
            '--config', str(config_yaml_file),
            '--presets', str(PRESETS_FILE),
            '--output-dir', str(OUTPUT_DIR),
            '--debug'
        ]
        
        job['logs'].append(f"[INFO] Executing: {' '.join(cmd)}")
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300,
            cwd=str(OUTPUT_DIR.parent.parent)  # Run from project root for proper library resolution
        )
        
        # Parse output
        for line in result.stderr.split('\n'):
            if line.strip():
                job['logs'].append(line)
                
                # Update progress based on steps
                if '[1/6]' in line:
                    job['progress'] = 20
                    job['current_step'] = 'Parsing configuration...'
                elif '[2/6]' in line:
                    job['progress'] = 35
                    job['current_step'] = 'Generating OpenSCAD file...'
                elif '[3/6]' in line:
                    job['progress'] = 50
                    job['current_step'] = 'Rendering with OpenSCAD...'
                elif '[4/6]' in line:
                    job['progress'] = 65
                    job['current_step'] = 'Extracting BOM...'
                elif '[5/6]' in line:
                    job['progress'] = 80
                    job['current_step'] = 'Generating 3D model (STL)...'
                elif '[6/6]' in line:
                    job['progress'] = 95
                    job['current_step'] = 'Generating DXF...'
        
        if result.returncode != 0:
            job['status'] = 'failed'
            job['logs'].append(f'[ERROR] Generation failed with return code {result.returncode}')
            # Capture error details from both stdout and stderr
            error_output = []
            if result.stderr:
                error_output.append("STDERR:\n" + result.stderr[-1000:])  # Last 1000 chars
            if result.stdout:
                error_output.append("STDOUT:\n" + result.stdout[-1000:])
            job['error_details'] = '\n\n'.join(error_output) if error_output else 'Generation failed. Check logs for details.'
            return
        
        job['progress'] = 100
        job['current_step'] = 'Complete!'
        job['status'] = 'completed'
        
        # List output files
        output_files = {
            'stl': OUTPUT_DIR / f"{config_name}.stl",
            'dxf': OUTPUT_DIR / f"{config_name}.dxf",
            'xlsx': OUTPUT_DIR / f"{config_name}_bom_production.xlsx",
            'csv': OUTPUT_DIR / f"{config_name}_bom.csv",
            'jsonl': OUTPUT_DIR / f"{config_name}_bom.jsonl"
        }
        
        for file_type, file_path in output_files.items():
            if file_path.exists():
                job['outputs'][file_type] = {
                    'filename': file_path.name,
                    'size': file_path.stat().st_size,
                    'path': str(file_path)
                }
        
        job['logs'].append('[INFO] Model generation complete!')
        
    except subprocess.TimeoutExpired as e:
        job['status'] = 'timeout'
        job['logs'].append('[ERROR] Generation timed out after 5 minutes')
        job['error_details'] = f'Model generation timed out after 5 minutes. This usually means OpenSCAD is taking too long to render the model. Try simplifying your configuration (smaller dimensions or fewer rings).\n\nCommand: {e.cmd}'
    except Exception as e:
        job['status'] = 'error'
        error_msg = str(e)
        job['logs'].append(f'[ERROR] {error_msg}')
        job['error_details'] = f'Unexpected error during generation:\n{error_msg}\n\nThis may be due to invalid configuration format or system issues. Please check your inputs and try again.'


@app.route('/api/generate/<job_id>', methods=['GET'])
def get_job_status(job_id):
    """Get status of a generation job"""
    if job_id not in JOBS:
        return jsonify({'error': 'Job not found'}), 404
    
    job = JOBS[job_id]
    
    response = {
        'job_id': job['id'],
        'status': job['status'],
        'progress': job['progress'],
        'current_step': job['current_step'],
        'logs': job['logs'][-20:],  # Last 20 log lines
        'outputs': job.get('outputs', {})
    }
    
    # Include error details if job failed
    if job['status'] in ['failed', 'error', 'timeout']:
        response['error_details'] = job.get('error_details', 'Check logs for details')
    
    return jsonify(response)


@app.route('/api/download/<job_id>/<file_type>', methods=['GET'])
def download_file(job_id, file_type):
    """Download a generated file"""
    if job_id not in JOBS:
        return jsonify({'error': 'Job not found'}), 404
    
    job = JOBS[job_id]
    
    if file_type not in job.get('outputs', {}):
        return jsonify({'error': f'File type {file_type} not found'}), 404
    
    file_info = job['outputs'][file_type]
    file_path = Path(file_info['path'])
    
    if not file_path.exists():
        return jsonify({'error': 'File not found on disk'}), 404
    
    return send_file(
        file_path,
        as_attachment=True,
        download_name=file_info['filename']
    )


@app.route('/api/generate-flexibele', methods=['POST'])
def generate_flexibele_model():
    """Start a flexibele verbindingen model generation job"""
    config = request.get_json()
    
    # Validate required fields
    errors = []
    if 'name' not in config:
        errors.append('Configuration name is required')
    if 'sector' not in config:
        errors.append('Sector is required')
    if 'medium' not in config:
        errors.append('Medium is required')
    if 'connector_end1' not in config or 'connector_end2' not in config:
        errors.append('Both connectors must be selected')
    
    # Validate connectors exist
    for end in ['connector_end1', 'connector_end2']:
        if config.get(end) not in CONNECTOR_DATABASE:
            errors.append(f'{end}: Unknown connector type')
    
    # Validate dimensions
    if config.get('diameter_inner', 0) >= config.get('diameter_outer', 0):
        errors.append('Inner diameter must be less than outer diameter')
    
    if errors:
        return jsonify({
            'error': 'Configuration validation failed',
            'details': errors
        }), 400
    
    # Create job ID
    job_id = str(uuid.uuid4())[:8]
    
    # Create job metadata
    JOBS[job_id] = {
        'id': job_id,
        'status': 'queued',
        'progress': 0,
        'current_step': 'Initializing flexibele verbindingen generation...',
        'created_at': datetime.now().isoformat(),
        'config': config,
        'logs': [],
        'outputs': {}
    }
    
    # Start generation in background thread
    thread = threading.Thread(target=run_flexibele_generation, args=(job_id, config))
    thread.daemon = True
    thread.start()
    
    return jsonify({
        'job_id': job_id,
        'status': 'queued',
        'created_at': JOBS[job_id]['created_at']
    })


def run_flexibele_generation(job_id, config):
    """Background task to run flexibele verbindingen model generation"""
    job = JOBS[job_id]
    
    try:
        job['status'] = 'processing'
        job['progress'] = 10
        job['current_step'] = 'Creating configuration file...'
        
        # Create temporary config YAML
        config_name = config.get('name', 'unnamed')
        config_yaml_file = OUTPUT_DIR / f"{config_name}_config.yaml"
        
        with open(config_yaml_file, 'w', encoding='utf-8') as f:
            yaml.dump(config, f)
        
        job['logs'].append('[INFO] Flexibele verbindingen configuration created')
        job['progress'] = 30
        job['current_step'] = 'Preparing 3D model generation...'
        
        # For now, simulate flexibele verbindingen generation
        # In production, this would call the appropriate OpenSCAD scripts
        job['logs'].append('[INFO] Sector: ' + config.get('sector', 'Unknown'))
        job['logs'].append('[INFO] Medium: ' + config.get('medium', 'Unknown'))
        job['logs'].append('[INFO] Connectors: ' + config.get('connector_end1', 'N/A') + ' / ' + config.get('connector_end2', 'N/A'))
        
        job['progress'] = 50
        job['current_step'] = 'This feature is coming soon!'
        job['logs'].append('[INFO] Flexibele verbindingen generation is currently in development')
        job['logs'].append('[INFO] Placeholder generation for UI demonstration')
        
        job['progress'] = 100
        job['current_step'] = 'Complete (Placeholder)'
        job['status'] = 'completed'
        job['logs'].append('[INFO] Placeholder generation complete - Feature in development')
        
        # Create placeholder output files
        output_files = {
            'scad': OUTPUT_DIR / f"{config_name}.scad",
            'dxf': OUTPUT_DIR / f"{config_name}.dxf",
            'jsonl': OUTPUT_DIR / f"{config_name}_bom.jsonl"
        }
        
        # Create placeholder files so downloads work
        for file_type, file_path in output_files.items():
            if not file_path.exists():
                with open(file_path, 'w') as f:
                    if file_type == 'scad':
                        f.write('// Placeholder OpenSCAD file - Feature in development\n')
                    elif file_type == 'dxf':
                        f.write('0\nSECTION\n2\nHEADER\n')
                    else:
                        f.write('{"placeholder": true, "product": "flexibele_verbindingen"}\n')
            
            job['outputs'][file_type] = {
                'filename': file_path.name,
                'size': file_path.stat().st_size,
                'path': str(file_path)
            }
        
    except Exception as e:
        job['status'] = 'error'
        error_msg = str(e)
        job['logs'].append(f'[ERROR] {error_msg}')
        job['error_details'] = f'Error during flexibele verbindingen generation:\n{error_msg}'


@app.route('/api/examples', methods=['GET'])
def get_examples():
    """Get example configurations"""
    examples = []
    
    config_files = Path('configs').glob('example_*.yaml')
    for config_file in config_files:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
            examples.append({
                'id': config_file.stem,
                'name': config.get('name', config_file.stem),
                'preset': config.get('preset', 'Unknown'),
                'config': config
            })
    
    return jsonify({'examples': examples})


if __name__ == '__main__':
    # CRITICAL: Allow all hosts for Replit proxy
    app.run(host='0.0.0.0', port=5000, debug=True)
