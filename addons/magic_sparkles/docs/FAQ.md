# FAQ

## General

### Do I need to write shaders?

No. All three nodes work out of the box via Inspector settings.

### Which Godot version?

Godot **4.7+**. Tested with Compatibility and Forward+ renderers.

### Can I use this in commercial projects?

Yes. MIT license. See [LICENSE](../LICENSE) for third-party sprite attribution.

## Setup

### Sparkles don't appear

1. Is the **Magic Sparkles** plugin enabled?
2. Is `MagicSparkleLight` a **child** of the button/panel (or `host` set correctly)?
3. For **On Hover** — are you hovering the host control, not the sparkle node?
4. Is `particle_count` > 0?
5. For `Node2D` hosts — an auto `Area2D` is created; ensure the host has a valid size.

### Sparkles only show in a thin line (Label host)

Put sparkles on a `PanelContainer` or `Button` with `custom_minimum_size`, not a bare `Label` with one line height.

### Wrong size / position

- Leave **host** empty when the sparkle node is a direct child of the target.
- Set **custom_size** for empty `Node2D` hosts.
- Use **overlap** for aura beyond the host edge.

## Performance

### How many particles can I use?

- **MagicSparkleLight:** 1–150 (Inspector slider). Best for UI: 20–80.
- **MagicSparkleBatch:** 50–5000. Typical ambient: 200–1500.

### Web and mobile

- Prefer **MagicSparkleLight** on interactive UI.
- Use **MagicSparkleBatch** sparingly on mobile (200–500 particles).
- Reduce `max_particles` on `MagicSparkleCursor` for low-end devices.

### Touch doesn't work in a web build

`MagicSparkleCursor` listens to `ScreenDrag` and `ScreenTouch`. In your Godot web export settings, make sure touch input is enabled.

## Cursor dust

### Dust appears behind UI

Raise `draw_z_index` to 200+. Host button sparkles use 100.

### Dust shows over the title bar

Set `content_margin_top` to your chrome height (e.g. 56 px).

## Signals

### When does `deactivated` fire?

After the fade-out animation completes — not when `deactivate()` is called.

### Can I use signals in the editor?

Yes. Select the sparkle node → Node tab → connect `activated`, `hover_entered`, etc.
