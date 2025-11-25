# 🚀 Performance Optimization Guide - ParSU Realms

## ✅ Optimizations Applied

### 1. **Rendering Settings** (`project.godot`)
```gdscript
# Reduced shadow quality for mobile
lights_and_shadows/directional_shadow/size=2048  # Lower from default 4096
lights_and_shadows/directional_shadow/soft_shadow_filter_quality=0  # Disabled soft shadows

# Disabled anti-aliasing (heavy on mobile)
anti_aliasing/quality/msaa_2d=0
anti_aliasing/quality/msaa_3d=0
anti_aliasing/quality/screen_space_aa=0

# Texture filtering
textures/canvas_textures/default_texture_filter=2  # Bilinear (faster than trilinear)
```

### 2. **Debug Print Removal** (`PlayerTemplate.gd`)
Removed all `print()` statements that were running every frame:
- Walking sound debug prints (4 locations)
- Audio node check prints
- Physics process debug prints

**Impact:** Debug prints are expensive and slow down the game significantly.

---

## 🎯 Additional Optimizations to Apply

### 3. **Reduce DirectionalLight Shadow Distance**
In your main scenes (`GoaCampus.tscn`, `main.tscn`, etc.):

```gdscript
# Find DirectionalLight3D nodes and add:
directional_shadow_max_distance = 50.0  # Default is 200.0
directional_shadow_fade_start = 0.8
```

**Why:** Shadows are very expensive. Shorter distance = fewer shadow calculations.

---

### 4. **Use Visibility Ranges for Distant Objects**
For decorative meshes and buildings far from player:

```gdscript
# In scene editor, select MeshInstance3D nodes
# Add GeometryInstance3D properties:
visibility_range_begin = 0.0
visibility_range_end = 50.0  # Object disappears beyond 50 meters
visibility_range_fade_mode = FADE_AUTOMATIC
```

**Apply to:** Decorative trees, distant buildings, small props

---

### 5. **Optimize Collision Shapes**
Your scenes have many complex collision shapes. Simplify them:

**Current (Slow):**
```gdscript
# Complex mesh collisions
CollisionShape3D with ConvexPolygonShape3D (many vertices)
```

**Optimized (Fast):**
```gdscript
# Use simple shapes for collision
CollisionShape3D with BoxShape3D / CapsuleShape3D
# Combine multiple simple shapes instead of one complex mesh
```

---

### 6. **Reduce Process Frequency**
For non-critical scripts, reduce update frequency:

**Example - `goa_3_dmap.gd`:**
```gdscript
# OLD - runs every frame (60 FPS = 60 times/sec)
func _process(_delta: float) -> void:
    update_minimap()

# NEW - runs every 3rd frame (20 times/sec)
var frame_count = 0
func _process(_delta: float) -> void:
    frame_count += 1
    if frame_count % 3 == 0:
        update_minimap()
```

---

### 7. **Optimize Car Physics**
Cars are heavy on physics. Disable when not in use:

```gdscript
# In car scenes, when player exits:
$VehicleBody3D.set_physics_process(false)
$VehicleBody3D.set_process(false)

# Enable only when player enters
$VehicleBody3D.set_physics_process(true)
```

✅ You're already doing this in `goa_campus.gd` - good!

---

### 8. **LOD (Level of Detail) for Complex Models**
For high-poly models like buildings:

```gdscript
# Create 3 versions of the same model:
# - High detail (0-20m from player)
# - Medium detail (20-50m from player)  
# - Low detail (50-100m from player)

# Use VisibilityRange to switch between them
```

**Priority Models:**
- ParSU campus building (`parsu.tscn`)
- Character models
- Vehicles

---

### 9. **Batch Static Meshes**
Combine small static decorations into single meshes:

**Tools:**
1. In Godot Editor → Select multiple MeshInstance3D
2. Right-click → "Merge Meshes"
3. This reduces draw calls significantly

**Apply to:**
- Cones (`cone.tscn` - you have many instances)
- Small props
- Furniture inside buildings

---

### 10. **Optimize Dialogic**
Your dialogue system processes every frame:

In `project.godot`:
```gdscript
[dialogic]
# Add these performance settings:
text/letter_speed=0.01  # Faster text reveal (less updates)
text/advance_delay=0.05  # Reduce delay
```

---

### 11. **Occlusion Culling**
Hide objects behind walls/buildings:

**Option A - Manual:**
```gdscript
# In player script, raycast to camera
# Hide objects that are behind walls
if not camera_can_see_object:
    object.visible = false
```

**Option B - Godot 4.3+ Automatic:**
```gdscript
# Enable in WorldEnvironment
environment.use_occlusion_culling = true
```

---

### 12. **Reduce AudioStreamPlayer3D Range**
Audio has spatial calculations:

```gdscript
# Find all AudioStreamPlayer3D nodes
# Reduce their max_distance:
max_distance = 30.0  # Default is often 100+
attenuation_filter_cutoff_hz = 5000  # Lower = less CPU
```

---

## 📊 Performance Monitoring

### Enable FPS Counter (Temporary)
```gdscript
# Add to main scene script:
func _ready():
    # Show FPS
    Performance.add_custom_monitor("FPS", func(): return Engine.get_frames_per_second())
```

### Check Performance Metrics
Press `F3` in editor to show:
- Draw calls
- Vertices
- FPS
- Memory usage

**Target Goals:**
- **Mobile:** 30-60 FPS
- **Draw Calls:** < 500
- **Vertices:** < 500k

---

## 🎮 Scene-Specific Optimizations

### GoaCampus.tscn (780 lines - Complex!)
1. ✅ Physics process toggling (already done)
2. ⚠️ Has 51 sub-resources - consider splitting into smaller scenes
3. ⚠️ Many Area3D collision checks - use collision layers efficiently

### Ocean.tscn
```gdscript
# Water shader is expensive
# Reduce shader complexity:
shader_parameter/wave_count = 2  # Lower from 4+
shader_parameter/refraction_intensity = 0.2  # Lower from 0.4
```

### Character Models
```gdscript
# Reduce animation update frequency
$AnimationTree.active = false  # When off-screen
```

---

## 🚨 Critical Performance Killers to Avoid

### ❌ Don't Do This:
```gdscript
# Running every frame (60 times/sec)
func _process(_delta):
    var enemies = get_tree().get_nodes_in_group("enemy")  # SLOW!
    for enemy in enemies:
        check_collision(enemy)  # VERY SLOW!
```

### ✅ Do This Instead:
```gdscript
# Cache references, use collision signals
@onready var enemies = get_tree().get_nodes_in_group("enemy")

func _on_area_entered(area):  # Only when collision happens
    if area.is_in_group("enemy"):
        handle_collision(area)
```

---

## 📈 Expected Results

| Optimization | FPS Gain | Difficulty |
|-------------|----------|-----------|
| Remove debug prints | +5-10 FPS | ✅ Easy (Done) |
| Reduce shadow quality | +10-15 FPS | ✅ Easy (Done) |
| Visibility ranges | +15-20 FPS | 🟡 Medium |
| Simplify collisions | +5-10 FPS | 🟡 Medium |
| LOD system | +20-30 FPS | 🔴 Hard |
| Batch meshes | +10-15 FPS | 🟡 Medium |

---

## 🛠️ Quick Wins (Do These First)

1. ✅ **Applied:** Rendering settings
2. ✅ **Applied:** Remove debug prints
3. **Next:** Reduce shadow distance to 50m
4. **Next:** Add visibility ranges to distant objects
5. **Next:** Simplify collision shapes for buildings

---

## 📝 Testing Checklist

After each optimization:
- [ ] Test on actual device (not just editor)
- [ ] Check FPS in busy scenes (GoaCampus)
- [ ] Verify gameplay still works correctly
- [ ] Test on lowest-end target device

---

## 🎯 Target Devices

Mobile performance varies:
- **High-end** (2022+): 60 FPS target
- **Mid-range** (2019-2021): 45 FPS target
- **Low-end** (2018-): 30 FPS target

Adjust quality settings per device tier.
