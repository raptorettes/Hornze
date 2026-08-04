@tool
## Lightweight sparkle overlay using [method Control._draw] — best for 1–150 particles on buttons and UI.
extends "res://addons/magic_sparkles/scripts/magic_sparkle_base.gd"
class_name MagicSparkleLight


func _validate_property(property: Dictionary) -> void:
	if property.name == "particle_count":
		property.hint = PROPERTY_HINT_RANGE
		property.hint_string = "1,150,1"


func _apply_count_limits() -> void:
	if particle_count > 150:
		push_warning("MagicSparkleLight: particle_count > 150 — consider MagicSparkleBatch for better performance.")


func _draw() -> void:
	if not _engine.is_active() or _sprite == null:
		return

	for particle in _engine.get_particles():
		var opacity: float = particle["opacity"]
		if opacity <= 0.0:
			continue
		var pos: Vector2 = particle["position"]
		var frame_x: int = particle["frame"]
		var color: Color = particle["color"]
		color.a = opacity * MagicSparkleTypes.TINT_ALPHA
		var src := Rect2(frame_x, 0, MagicSparkleTypes.SPRITE_SIZE, MagicSparkleTypes.SPRITE_SIZE)
		var dst := Rect2(pos, Vector2(MagicSparkleTypes.SPRITE_SIZE, MagicSparkleTypes.SPRITE_SIZE))
		draw_texture_rect_region(_sprite, dst, src, color)


func _sync_renderer() -> void:
	queue_redraw()


func _on_activation_changed(_active: bool) -> void:
	queue_redraw()
