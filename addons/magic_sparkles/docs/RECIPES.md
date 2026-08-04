# Recipes

Copy-paste patterns for common game and UI scenarios.

## 1. Game menu buttons

Add `MagicSparkleLight` as a child of each menu `Button`. Set brand colors in **Colors**, keep **On Hover**.

```gdscript
$MagicSparkleLight.colors = [Color.GOLD, Color.WHITE]
$MagicSparkleLight.overlap = 4.0
```

See `examples/scenes/menu_row.tscn`.

## 2. Visual novel dialogue box

Use **Always Active** + **Rise** on a `PanelContainer` overlay:

```
PanelContainer (dialogue box)
  └── Control (full rect)
        ├── RichTextLabel
        └── MagicSparkleLight   # activation_mode = ALWAYS, motion_mode = RISE
```

## 3. SFX on hover

```gdscript
func _ready() -> void:
    $MagicSparkleLight.hover_entered.connect($HoverSfx.play)
    $MagicSparkleLight.hover_exited.connect($HoverSfx.stop)
```

## 4. Loot popup burst

Disable auto click burst on the cursor overlay; trigger bursts from gameplay code:

```gdscript
$MagicSparkleCursor.click_burst_enabled = false

func _on_loot_collected(global_pos: Vector2) -> void:
    $MagicSparkleCursor.burst_at_global(global_pos, 1.5)
```

Connect `burst_triggered` for particle count scaling or combo text.

## 5. Seasonal snow / star rain

Fullscreen `MagicSparkleBatch`:

- **Motion Mode:** Rain
- **Activation:** Always Active
- **Rainbow:** on for holiday vibe, off for white snow
- **particle_count:** 500–1500

See `examples/scenes/ambient_rain.tscn`.

## 6. Mobile touch cursor

`MagicSparkleCursor` handles `InputEventScreenDrag` and `InputEventScreenTouch` automatically. Increase `spawn_density` slightly for finger trails:

```gdscript
$MagicSparkleCursor.apply_preset({
    "spawn_density": 0.07,
    "min_move_speed": 12.0,
})
```

## 7. Title screen ambient magic

Background `MagicSparkleBatch` behind UI (z_index 1), menu buttons with `MagicSparkleLight` on top (z_index 100).

## 8. Light vs Batch decision

| Scenario | Node | Typical count |
|----------|------|---------------|
| Single button | MagicSparkleLight | 30–80 |
| Card / panel | MagicSparkleLight | 50–120 |
| Fullscreen rain | MagicSparkleBatch | 500–2000 |
| HUD badge | MagicSparkleLight | 20–40 |

Inspector sliders enforce Light 1–150 and Batch 50–5000.

## 9. Z-index layering

| Layer | z_index |
|-------|---------|
| Background batch | 1 |
| UI content | 0–50 |
| Button sparkles | 100 |
| Cursor dust | 200 |
| Modals | 300+ |

Set `content_margin_top` on `MagicSparkleCursor` to skip the title bar chrome.
