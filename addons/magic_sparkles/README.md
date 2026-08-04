# Magic Sparkles

Godot 4.7+ addon — animated sparkle overlay for **UI Controls** and **2D nodes**.

## Install

1. Copy `magic_sparkles` into your project's `addons/` folder.
2. **Project → Project Settings → Plugins** → enable **Magic Sparkles**.
3. **Add Node** → `MagicSparkleLight`, `MagicSparkleBatch`, or `MagicSparkleCursor`.

Requires Godot **4.7+**. Works with Compatibility and Forward+ renderers.

## Quick example

```
Button
  └── MagicSparkleLight   # child of the host control
```

Set **Activation Mode** to **On Hover** (default) or **Always Active**. Connect signals or call `activate()` / `deactivate()` from code.

**Fastest path:** open `addons/magic_sparkles/examples/scenes/button_hover.tscn` and press F6.

## Nodes

| Node | Use case | Particles |
|------|----------|-----------|
| **MagicSparkleLight** | Buttons, labels, images | 1–150 (`_draw`) |
| **MagicSparkleBatch** | Dense / fullscreen effects | 50–5000 (MultiMesh) |
| **MagicSparkleCursor** | Mouse / touch magic dust trail | 20–400 (spawn on move) |

**7 motion presets** — Classic, Drift, Rise, Swirl, Orbit, Pulse, Rain — with Inspector tuning for turbulence, gravity, swirl, and more.

## Highlights

- **Drop-in setup** — add a child node, hover, done
- **Custom colors** — any palette in the `Colors` array
- **Rainbow mode** — one checkbox for random vivid hues
- **7 motion presets** — from subtle UI shimmer to star-rain storms
- **Cursor magic dust** — scatter sparkles as the pointer moves (mouse + touch)
- **Signal API** — `activated`, `deactivated`, `hover_entered`, `burst_triggered`, and more
- **Inspector tooltips** — every property documented with tuned sliders

## Docs

- [Quick Start](docs/QUICK_START.md)
- [API Reference](docs/API.md)
- [Recipes](docs/RECIPES.md)
- [FAQ](docs/FAQ.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Example Scenes](examples/README.md)
- [Changelog](CHANGELOG.md)

## Support

Questions or bug reports? Leave a comment on the [product page](https://sir-g.itch.io/godot-magic-sparkles).

## Third-party

Sparkle sprite from [simeydotme/jQuery-canvas-sparkles](https://github.com/simeydotme/jQuery-canvas-sparkles) (MIT). See [LICENSE](LICENSE).

## Author

Sir_G
