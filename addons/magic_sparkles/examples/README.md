# Example Scenes

Open any scene below and press **F6** (Run Current Scene) to preview.

| Scene | Demonstrates |
|-------|----------------|
| `scenes/button_hover.tscn` | Button + MagicSparkleLight, On Hover, brand colors |
| `scenes/menu_row.tscn` | Three buttons with different palettes |
| `scenes/ui_card_fade_exit.tscn` | Panel card with Fade Exit boundary |
| `scenes/ambient_rain.tscn` | Fullscreen MagicSparkleBatch, Rain, Always Active |
| `scenes/cursor_overlay.tscn` | MagicSparkleCursor trail + click burst |
| `scenes/signals_demo.tscn` | `activated`, `hover_entered`, `burst_triggered` signals |

## Cursor presets

Use [`presets/cursor_presets.gd`](presets/cursor_presets.gd):

```gdscript
$MagicSparkleCursor.apply_preset(MagicSparkleCursorPresets.RAINBOW_BURST)
```

## Drag into your project

Copy the `examples/` folder or individual `.tscn` files into your scene tree. Ensure the **Magic Sparkles** plugin is enabled.
