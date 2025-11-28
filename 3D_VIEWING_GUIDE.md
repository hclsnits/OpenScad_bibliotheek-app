# 3D Viewing Integration Guide

## Current Status

✅ **What's Present:**
- OpenSCAD CLI tool (generates 3D geometry)
- Flask web app (`app.py`) with API endpoints
- HTML template (`templates/index.html`) for configurator UI
- Support for `.dxf` export (2D only)

❌ **What's Missing:**
- 3D output formats (STL, 3MF, OBJ)
- 3D viewer in web browser
- 3D preview during generation

## How to Add 3D Viewing

### Option 1: STL Export + Three.js Viewer (Recommended)

**Why STL?**
- Widely supported format
- Small file size for web
- Compatible with all 3D viewers
- Perfect for 3D printing preview

#### Step 1: Generate STL from OpenSCAD

Modify `scripts/generate_model.py` to also export STL:

```python
# In Step 3: Render with OpenSCAD

# After generating .dxf, also generate .stl
stl_scad_file = project_root / f".gen_{config_name}_stl.scad"
stl_content = template.render(...)  # Same template, no projection
stl_scad_file.write_text(stl_content, encoding="utf-8")

stl_file = output_dir / f"{config_name}.stl"
cmd = ["openscad", "-o", str(stl_file.absolute()), str(stl_scad_file.absolute())]
result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(Path.cwd()))

if result.returncode != 0:
    debug_log(f"STL export failed", "ERROR")
else:
    debug_log(f"✓ Generated STL to {stl_file}", "INFO")

stl_scad_file.unlink()  # Clean up temp file
```

#### Step 2: Add STL to API Response

Modify `app.py` to include STL in download links:

```python
# In generate endpoint response
outputs = {
    "dxf": { "filename": "...dxf", "size": size, "mime": "application/dxf" },
    "stl": { "filename": "...stl", "size": size, "mime": "model/stl" },
    "xlsx": { ... }
}
```

#### Step 3: Add Three.js Viewer to Frontend

Add to `templates/index.html`:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@r128/examples/js/loaders/STLLoader.js"></script>

<div id="viewer-container" style="width: 100%; height: 500px; margin: 20px 0;"></div>

<script>
// Initialize Three.js scene
const container = document.getElementById('viewer-container');
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(container.clientWidth, container.clientHeight);
container.appendChild(renderer.domElement);

// Load STL file
const loader = new THREE.STLLoader();
loader.load('path/to/model.stl', (geometry) => {
    const material = new THREE.MeshPhongMaterial({ color: 0x00ff00 });
    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);
    
    // Auto-fit camera
    const box = new THREE.Box3().setFromObject(mesh);
    camera.position.z = box.max.z * 2;
    
    // Render
    renderer.render(scene, camera);
});

// Handle window resize
window.addEventListener('resize', () => {
    camera.aspect = container.clientWidth / container.clientHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(container.clientWidth, container.clientHeight);
});
</script>
```

### Option 2: babylon.js Viewer (More Powerful)

babylon.js offers better material support and performance:

```html
<script src="https://cdn.babylonjs.com/babylon.js"></script>
<script src="https://cdn.babylonjs.com/loaders/babylon.stlFileLoader.js"></script>

<canvas id="renderCanvas" style="width: 100%; height: 500px;"></canvas>

<script>
const canvas = document.getElementById('renderCanvas');
const engine = new BABYLON.Engine(canvas, true);
const scene = new BABYLON.Scene(engine);

// Load STL
BABYLON.SceneLoader.ImportMesh("", "", "model.stl", scene, (meshes) => {
    meshes.forEach(mesh => {
        mesh.material = new BABYLON.StandardMaterial("mat", scene);
        mesh.material.diffuse = new BABYLON.Color3(0.3, 0.8, 0.3);
    });
});

engine.runRenderLoop(() => scene.render());
window.addEventListener('resize', () => engine.resize());
</script>
```

### Option 3: Model Viewer (Google, lightweight)

Lightweight, modern, works for GLTF/GLB:

```html
<model-viewer 
    src="path/to/model.gltf" 
    alt="Filter Model"
    auto-rotate
    camera-controls
    style="width: 100%; height: 500px;">
</model-viewer>

<script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3/model-viewer.min.js"></script>
```

**Note:** Requires conversion from STL → GLTF (via assimp or Blender)

---

## Complete Implementation Checklist

### Backend Changes (Python)

- [ ] Modify `scripts/generate_model.py` to export STL
- [ ] Update `app.py` to include STL in outputs
- [ ] Add `/api/download/:job_id/stl` endpoint
- [ ] Handle STL file storage/cleanup

**Code Location:** `scripts/generate_model.py` Step 5

```python
# Add after DXF generation
if not args.skip_stl:
    debug_log("[STL] Generating 3D model file...", "INFO")
    
    stl_scad_file = project_root / f".gen_{config_name}_stl.scad"
    stl_template = scad_template  # Use same template, no projection
    template = Template(stl_template)
    stl_content = template.render(config_name=config_name, **params)
    stl_scad_file.write_text(stl_content, encoding="utf-8")
    
    stl_file = output_dir / f"{config_name}.stl"
    cmd = ["openscad", "-o", str(stl_file.absolute()), str(stl_scad_file.absolute())]
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(Path.cwd()))
    
    if result.returncode != 0:
        debug_log(f"STL export failed", "ERROR")
        sys.exit(1)
    
    stl_scad_file.unlink()
    debug_log(f"✓ Generated STL to {stl_file}", "INFO")
```

### Frontend Changes (HTML/JavaScript)

- [ ] Add Three.js library to `templates/index.html`
- [ ] Create 3D viewer container div
- [ ] Add viewer initialization script
- [ ] Handle model loading from API
- [ ] Add rotation/zoom controls
- [ ] Responsive sizing

**Code Location:** `templates/index.html` in results section

```html
<div class="results-section">
    <h2>3D Preview</h2>
    <div id="viewer-container"></div>
    
    <div class="download-section">
        <h3>Download Files</h3>
        <a href="/api/download/{{job_id}}/stl" class="btn">📦 Download STL (3D Model)</a>
        <a href="/api/download/{{job_id}}/dxf" class="btn">📐 Download DXF (2D Drawing)</a>
        <a href="/api/download/{{job_id}}/xlsx" class="btn">📊 Download BOM (Excel)</a>
    </div>
</div>
```

### Configuration Changes

- [ ] Add `--skip-stl` flag to `generate_model.py` (optional)
- [ ] Update `.env` with viewer settings if needed
- [ ] Add STL to file cleanup routines

---

## OpenSCAD Export Options

### Generate Full 3D Model (STL)

```bash
openscad -o model.stl model.scad
```

**Output:** Complete 3D geometry, ready for viewing/printing

### Generate 2D Projection (DXF) - Current

```bash
openscad -o model.dxf model.scad  # With projection(cut=false) in SCAD
```

**Output:** 2D drawing (what we currently do)

### Generate 3D Rendering (PNG)

```bash
openscad -o model.png model.scad \
    --render \
    --camera "0,0,0,0,0,0,100" \
    --imgsize "1024,768"
```

**Output:** Static 3D image for preview

### Generate CSG (CSG.js format)

```bash
openscad -o model.csg model.scad
```

**Output:** CSG.js format (JavaScript-native 3D)

---

## File Format Comparison

| Format | File Size | Web Viewer | 3D Printing | Native Support |
|--------|-----------|-----------|-------------|----------------|
| **STL** | Medium | ✅ Three.js | ✅ Yes | ✅ Universal |
| **OBJ** | Medium | ✅ Three.js | ⚠️ Limited | ✅ Common |
| **GLTF/GLB** | Small | ✅ Model Viewer | ❌ No | ✅ Web native |
| **3MF** | Medium | ⚠️ Partial | ✅ Yes | ⚠️ Limited |
| **PNG** | Small | ✅ HTML | ❌ No | ✅ Universal |
| **DXF** | Small | ❌ No | ❌ No | ✅ CAD tools |

**Recommendation:** Start with **STL** (most compatible) using **Three.js** viewer

---

## Implementation Priority

1. **High** (MVP):
   - Add STL export to `generate_model.py`
   - Add Three.js viewer to web UI
   - Include STL in API responses

2. **Medium** (Enhancement):
   - Add PNG preview (static 3D image)
   - Implement model rotation/zoom controls
   - Add viewer settings (lighting, color)

3. **Low** (Future):
   - Support multiple formats (OBJ, 3MF, GLTF)
   - Advanced rendering options (ray tracing, materials)
   - Model annotation/measurement tools

---

## Testing 3D Export Manually

```bash
# Generate STL from existing SCAD
openscad -o test_model.stl tests/smoke_filterslang_default.scad

# Verify STL is valid
file test_model.stl
wc -c test_model.stl

# View locally with Meshlab or similar
meshlab test_model.stl
```

---

## Web Components Available

### Three.js Setup Code Template

```javascript
// Initialize viewer
function initThreeViewer(containerId, stlUrl) {
    const container = document.getElementById(containerId);
    
    // Scene setup
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0xffffff);
    
    // Camera
    const camera = new THREE.PerspectiveCamera(
        75,
        container.clientWidth / container.clientHeight,
        0.1,
        1000
    );
    camera.position.z = 150;
    
    // Renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.shadowMap.enabled = true;
    container.appendChild(renderer.domElement);
    
    // Lighting
    const light = new THREE.DirectionalLight(0xffffff, 1);
    light.position.set(100, 100, 100);
    scene.add(light);
    
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);
    
    // Load STL
    const loader = new THREE.STLLoader();
    loader.load(stlUrl, (geometry) => {
        geometry.center();
        geometry.computeBoundingBox();
        
        const material = new THREE.MeshPhongMaterial({
            color: 0x00aa00,
            specular: 0x111111,
            shininess: 200
        });
        
        const mesh = new THREE.Mesh(geometry, material);
        scene.add(mesh);
        
        // Auto-fit camera
        const box = new THREE.Box3().setFromObject(mesh);
        const size = box.getSize(new THREE.Vector3());
        const maxDim = Math.max(size.x, size.y, size.z);
        const fov = camera.fov * (Math.PI / 180);
        let cameraZ = Math.abs(maxDim / 2 / Math.tan(fov / 2));
        camera.position.z = cameraZ * 1.5;
        camera.lookAt(scene.position);
    });
    
    // Mouse controls (optional)
    let isDragging = false;
    let previousMousePosition = { x: 0, y: 0 };
    
    container.addEventListener('mousedown', (e) => { isDragging = true; });
    container.addEventListener('mouseup', (e) => { isDragging = false; });
    container.addEventListener('mousemove', (e) => {
        if (!isDragging) return;
        
        const deltaX = e.clientX - previousMousePosition.x;
        const deltaY = e.clientY - previousMousePosition.y;
        
        scene.children[0].rotation.y += deltaX * 0.01;
        scene.children[0].rotation.x += deltaY * 0.01;
        
        previousMousePosition = { x: e.clientX, y: e.clientY };
    });
    
    // Render loop
    const animate = () => {
        requestAnimationFrame(animate);
        renderer.render(scene, camera);
    };
    animate();
    
    // Handle resize
    window.addEventListener('resize', () => {
        camera.aspect = container.clientWidth / container.clientHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(container.clientWidth, container.clientHeight);
    });
}

// Usage
initThreeViewer('viewer-container', '/api/download/job-id/stl');
```

---

## Summary

**To enable 3D viewing:**

1. **Backend**: Add STL export to `generate_model.py` (5-10 lines)
2. **API**: Include STL file in response from `app.py`
3. **Frontend**: Add Three.js viewer to `templates/index.html` (30-50 lines)

**Result:** Full 3D preview + 3D file download for users

**Estimated effort:** 2-4 hours total implementation
