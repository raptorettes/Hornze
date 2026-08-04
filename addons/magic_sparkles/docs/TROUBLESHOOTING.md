# Troubleshooting

Quick decision tree for common issues.

## Nothing visible

```
Plugin enabled?
  └─ No → Project Settings → Plugins → Magic Sparkles
  └─ Yes → Sparkle node child of host (or host path set)?
            └─ No → Reparent or set host NodePath
            └─ Yes → activation_mode = ON_HOVER and hovering?
                      └─ No → Switch to ALWAYS to test, then fix hover target
                      └─ Yes → particle_count > 0?
                                └─ No → Increase count in Inspector
                                └─ Yes → Check z_index / clip_contents on parent
```

## Performance drops

| Symptom | Fix |
|---------|-----|
| UI stutters with many buttons | Use Light (≤80 particles) per button, not Batch |
| Fullscreen lag | Reduce Batch count; try 300–500 on mobile |
| Cursor dust stutters on swipe | Lower `max_spawns_per_frame` or `spawn_density` |

## Wrong node type

| You want | Use |
|----------|-----|
| Button hover | MagicSparkleLight |
| 1000+ ambient particles | MagicSparkleBatch |
| Mouse trail | MagicSparkleCursor |

Inspector warns if Light count > 150 or Batch count < 50.

## Fade / boundary issues

| Problem | Fix |
|---------|-----|
| Hard cut at card edge | Switch to **Fade Exit** boundary mode |
| Particles teleport at edge | **Clip+Wrap** is working as designed |
| Trails outside card look bad | **Fade Exit** + tune `exit_fade_rate` |

## Still stuck?

1. Open `examples/scenes/button_hover.tscn` — if F6 works, compare scene tree to yours.
2. Check [FAQ](FAQ.md) and [Recipes](RECIPES.md).
3. See [Support](../README.md#support) in the README.
