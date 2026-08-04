# Quick Start

## Fastest path

Open `addons/magic_sparkles/examples/scenes/button_hover.tscn` and press **F6**. Hover the button.

## 1. Enable the plugin

Copy `addons/magic_sparkles` into your project and enable **Magic Sparkles** in Project Settings → Plugins.

## 2. Add sparkles to a button

1. Select your `Button` in the scene tree.
2. Add child node → **MagicSparkleLight**.
3. The sparkle node fills the button automatically (with optional **Overlap**).
4. Run the scene and hover the button.

## 3. Activation

| Inspector value | Behavior |
|-----------------|----------|
| **On Hover** | Sparkles start on mouse enter, fade on leave (default) |
| **Always Active** | Sparkles run continuously |

From code:

```gdscript
$MagicSparkleLight.activate()
$MagicSparkleLight.deactivate()
if $MagicSparkleLight.is_active():
    pass
```

With signals:

```gdscript
$MagicSparkleLight.activated.connect(func(): $SfxSparkle.play())
$MagicSparkleLight.deactivated.connect(func(): $SfxSparkle.stop())
```

## 4. Colors

- **Colors** — array of tints; each particle picks one at random.
- **Rainbow** — one checkbox: every particle gets a random vivid hue.

```gdscript
$MagicSparkleLight.set_colors([Color.GOLD, Color.WHITE])
$MagicSparkleLight.rainbow = true
```

## 5. Motion presets

Pick **Motion Mode** in the Inspector:

| Mode | Vibe |
|------|------|
| Classic | Twinkling jitter (default) |
| Drift | Floating magical mist |
| Rise | Upward embers |
| Swirl | Vortex around center |
| Orbit | Circular sparkles |
| Pulse | Breathing halo |
| Rain | Falling star shower |

Fine-tune with **Motion Tuning**: `direction_bias`, `turbulence`, `gravity`, `swirl_strength`, `motion_randomness`.

## 6. Many particles?

Use **MagicSparkleBatch** on the same host for hundreds or thousands of sparkles (single draw call). Inspector slider: 50–5000 particles.

## 7. Cursor magic dust

Add **MagicSparkleCursor** as a fullscreen child of your root UI:

```
DemoRoot
  ├── PageContent
  └── MagicSparkleCursor   # draw_z_index = 200, mouse_filter = IGNORE
```

Move the mouse or drag a finger — dust particles scatter from the pointer path. **Click or tap** for a radial burst.

```gdscript
$MagicSparkleCursor.apply_preset(MagicSparkleCursorPresets.RAINBOW_BURST)
$MagicSparkleCursor.burst_at_global(get_global_mouse_position(), 1.4)
$MagicSparkleCursor.burst_triggered.connect(_on_burst)
$MagicSparkleCursor.click_burst_enabled = false  # manual bursts only
```

## Example scenes

See [examples/README.md](../examples/README.md) for all ready-to-run scenes.
