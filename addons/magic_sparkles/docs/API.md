# API Reference

## MagicSparkleLight / MagicSparkleBatch

Both nodes share exports from `MagicSparkleBase`. Inspector tooltips match this document.

Particle count sliders are node-specific: **Light** 1–150, **Batch** 50–5000.

### Signals

| Signal | When |
|--------|------|
| `activated` | Effect turned on (`activate()`, hover enter, or Always mode) |
| `deactivated` | Fade-out finished and simulation stopped |
| `hover_entered` | Pointer entered the host (ON_HOVER mode) |
| `hover_exited` | Pointer left the host |

```gdscript
$MagicSparkleLight.activated.connect(func(): $SfxSparkle.play())
$MagicSparkleLight.deactivated.connect(_on_sparkles_off)
$MagicSparkleLight.hover_entered.connect(_on_button_glow)
```

`deactivated` fires after the fade animation completes — not immediately when `deactivate()` is called.

### Particles

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `particle_count` | int | 30 | Total sparkle count. Light: 20–80 typical. Batch: 200–1500 typical. |

### Appearance

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `colors` | Array[Color] | white | Tint palette — random pick per particle. Ignored when Rainbow is on. |
| `rainbow` | bool | false | Random vivid hue per particle. Overrides Colors. |

### Motion

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `motion_mode` | enum | CLASSIC | Movement preset (see Motion modes). |
| `speed` | float | 1.0 | Global speed multiplier. 0.3–0.8 calm; 1.5+ energetic. |

### Motion Tuning

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `direction_bias` | float | -90 | Flow direction in degrees. -90° up · 90° down. Drift, Rise, Rain. |
| `turbulence` | float | 0.35 | Organic wobble. 0 = straight; 1 = chaotic. |
| `gravity` | float | 0.0 | Acceleration. Positive = down. Rain: 0.4–0.8. |
| `swirl_strength` | float | 1.0 | Spin/pulse intensity. Swirl, Orbit, Pulse. |
| `motion_randomness` | float | 0.5 | Per-particle speed/path variance. |
| `overlap` | float | 0.0 | Extra pixels beyond host edge. 4–12 for soft aura. |

### Boundaries

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `boundary_mode` | enum | CLIP_WRAP | Clip+Wrap or Fade Exit. |
| `exit_fade_rate` | float | 0.05 | Fade speed outside host (Fade Exit only). |

### Activation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `activation_mode` | enum | ON_HOVER | On Hover or Always. |

### Target

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `host` | NodePath | empty | Bounds/hover node. Empty = parent. |
| `custom_size` | Vector2 | zero | Manual size when host has no layout size. |

### Motion modes

| Mode | Description | Best for |
|------|-------------|----------|
| **CLASSIC** | Twinkling probabilistic jitter | Buttons, default |
| **DRIFT** | Smooth omnidirectional float | Cards, ambient UI |
| **RISE** | Upward embers with sway | Menus, moonlit scenes |
| **SWIRL** | Spiral galaxy — 2–3 arms, slow differential spin | Portraits, icons |
| **ORBIT** | Steady concentric rings, fixed radius | Badges, focal points |
| **PULSE** | Breathe in/out from center | CTAs, hover highlights |
| **RAIN** | Fall downward, respawn at top | Night sky, star showers |

Rain and ambient modes use steady sine shimmer. Classic uses animated twinkle opacity.

### Methods

```gdscript
func activate() -> void
func deactivate() -> void
func is_active() -> bool
func set_colors(new_colors: Array[Color]) -> void
```

### Boundary modes

- **CLIP_WRAP** — Hard clip at host edge + particle wrap.
- **FADE_EXIT** — Soft fade outside host, respawn inside.

### Host support

- `Control` — auto layout + mouse hover
- `Sprite2D`, `TextureRect` — bounds from texture/size
- `Node2D` — auto `Area2D` for hover when using ON_HOVER

---

## MagicSparkleCursor

Fullscreen overlay that spawns short-lived sparkle dust along mouse or touch movement. Add once at the root of your UI.

### Signals

| Signal | Parameters | When |
|--------|------------|------|
| `burst_triggered` | `local_position: Vector2`, `intensity: float` | Any burst: click, `burst_at()`, `burst_at_global()` |
| `enabled_changed` | `is_enabled: bool` | `enabled` property toggled |

```gdscript
$MagicSparkleCursor.burst_triggered.connect(func(pos, i): _spawn_loot_fx(pos))
$MagicSparkleCursor.enabled_changed.connect(_on_cursor_toggled)
```

### Trail

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enabled` | bool | true | Master switch for trail and bursts. |
| `colors` | Array[Color] | violet palette | Dust tints. |
| `rainbow` | bool | false | Random vivid hue per dust particle. |
| `magical_hues` | bool | true | Violet–magenta bias. |
| `max_particles` | int | 220 | Ring-buffer pool size. |
| `spawn_density` | float | 0.055 | Particles per pixel of pointer travel. |
| `min_move_speed` | float | 18 | Minimum pointer speed (px/s) before trail spawns. |
| `spread` | float | 0.45 | Trail scatter amount. |
| `speed_scale` | float | 0.55 | Trail drift speed multiplier. |
| `lift` | float | 16 | Upward kick on trail spawn. |
| `gravity` | float | 28 | Downward pull while falling. |
| `particle_life` | float | 1.45 | Trail lifetime in seconds. |
| `turbulence` | float | 0.22 | Sideways sway while falling. |
| `sparks_per_emit` | int | 1 | Trail motes per spawn tick. |
| `max_spawns_per_frame` | int | 5 | Caps trail spawns per frame on fast swipes. |

### Click Burst

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `click_burst_enabled` | bool | true | Auto burst on mouse click / touch tap. |
| `burst_particle_count` | int | 14 | Sparkles per burst (× intensity). |
| `burst_intensity` | float | 1.0 | Scales burst size and speed. |
| `burst_spread` | float | 2.2 | Radial burst spread. |
| `burst_speed` | float | 1.15 | Outward burst speed multiplier. |
| `burst_lift` | float | 52 | Upward pop on click burst. |
| `burst_life` | float | 0.72 | Burst sparkle lifetime. |

### Rendering

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `additive_blend` | bool | true | Additive glow when drawing. |
| `content_margin_top` | float | 0 | Top inset — skip effects above this line. |
| `content_margin_bottom` | float | 0 | Bottom inset. |

### Ordering

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `draw_z_index` | int | 200 | Draw layer. Host sparkles use 100 — keep cursor dust above (150–250). |
| `draw_z_as_relative` | bool | false | `false` = absolute layer (recommended for root overlays). |

### Methods

```gdscript
func apply_preset(preset: Dictionary) -> void
func burst_at(local_pos: Vector2, intensity: float = 1.0) -> void
func burst_at_global(global_pos: Vector2, intensity: float = 1.0) -> void
```

### Presets

```gdscript
$MagicSparkleCursor.apply_preset(MagicSparkleCursorPresets.RAINBOW_BURST)
```

See `examples/presets/cursor_presets.gd` for SUBTLE, AMBIENT, RAINBOW_BURST.

### Layering guide

| Layer | Typical `draw_z_index` |
|-------|------------------------|
| Page content | 0 |
| MagicSparkleLight / Batch on buttons | 100 |
| MagicSparkleCursor | 200 |
| Modals above dust | 300+ |

Input: mouse motion and touch drag. `mouse_filter` is IGNORE — clicks pass through to UI below.
