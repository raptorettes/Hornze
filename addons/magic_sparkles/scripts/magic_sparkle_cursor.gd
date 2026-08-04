@tool
## Fullscreen pointer trail and click bursts — add once at the UI root for magical cursor dust.
extends Control
class_name MagicSparkleCursor

signal burst_triggered(local_position: Vector2, intensity: float)
signal enabled_changed(is_enabled: bool)

const _Types := preload("res://addons/magic_sparkles/scripts/magic_sparkle_types.gd")
const _EngineClass := preload("res://addons/magic_sparkles/scripts/magic_sparkle_cursor_engine.gd")

const _MAGICAL_PURPLE: Array[Color] = [
	Color(0.72, 0.45, 1.0, 1),
	Color(0.88, 0.62, 1.0, 1),
	Color(0.95, 0.82, 1.0, 1),
	Color(1.0, 0.55, 0.95, 1),
]

@export_group("Trail")

## Master switch for trail dust and bursts.
@export var enabled: bool = true:
	set(value):
		if enabled == value:
			return
		enabled = value
		enabled_changed.emit(enabled)

## Tint palette for trail motes. Ignored when Rainbow is on.
@export var colors: Array[Color] = _MAGICAL_PURPLE:
	set(value):
		colors = value
		_reconfigure_engine()

## Random vivid hue per trail mote.
@export var rainbow: bool = false:
	set(value):
		rainbow = value
		_reconfigure_engine()

## Bias tints toward violet–magenta hues (works with Rainbow too).
@export var magical_hues: bool = true:
	set(value):
		magical_hues = value
		_reconfigure_engine()

## Maximum live particles in the ring buffer.
@export_range(20, 400, 1) var max_particles: int = 220:
	set(value):
		max_particles = value
		_reconfigure_engine()

## Trail thickness — motes spawned per pixel of pointer travel.
@export_range(0.01, 0.5, 0.01) var spawn_density: float = 0.055:
	set(value):
		spawn_density = value

## Minimum pointer speed (px/s) before dust appears.
@export_range(0.0, 400.0, 1.0, "suffix:px/s") var min_move_speed: float = 18.0:
	set(value):
		min_move_speed = value

## How far motes scatter sideways from the pointer path.
@export_range(0.1, 1.5, 0.05) var spread: float = 0.45:
	set(value):
		spread = value
		_reconfigure_engine()

## Horizontal drift speed of trail motes.
@export_range(0.1, 2.0, 0.05, "suffix:×") var speed_scale: float = 0.55:
	set(value):
		speed_scale = value
		_reconfigure_engine()

## Upward impulse applied to each trail mote.
@export_range(0.0, 60.0, 1.0, "suffix:px/s") var lift: float = 16.0:
	set(value):
		lift = value
		_reconfigure_engine()

## Downward pull on trail motes.
@export_range(0.0, 80.0, 1.0, "suffix:px/s") var gravity: float = 28.0:
	set(value):
		gravity = value
		_reconfigure_engine()

## Lifetime of each trail mote in seconds.
@export_range(0.3, 3.0, 0.05, "suffix:s") var particle_life: float = 1.45:
	set(value):
		particle_life = value
		_reconfigure_engine()

## Gentle sideways sway while motes fall.
@export_range(0.0, 1.0, 0.01) var turbulence: float = 0.22:
	set(value):
		turbulence = value
		_reconfigure_engine()

## Motes spawned per tick along the path (1 = delicate trail).
@export_range(1, 2, 1) var sparks_per_emit: int = 1:
	set(value):
		sparks_per_emit = value
		_reconfigure_engine()

## Cap on spawn ticks per frame — prevents buffer wipe on fast swipes.
@export_range(1, 12, 1) var max_spawns_per_frame: int = 5:
	set(value):
		max_spawns_per_frame = value

@export_group("Click Burst")

## Auto burst on mouse click or touch tap.
@export var click_burst_enabled: bool = true

## Sparkles in one burst (scaled by Burst Intensity).
@export_range(4, 36, 1) var burst_particle_count: int = 14:
	set(value):
		burst_particle_count = value
		_reconfigure_engine()

## Size and speed multiplier for bursts. 1.0 = default pop.
@export_range(0.25, 3.0, 0.05, "suffix:×") var burst_intensity: float = 1.0

## Radial spread of burst motes.
@export_range(0.5, 3.5, 0.05) var burst_spread: float = 2.2:
	set(value):
		burst_spread = value
		_reconfigure_engine()

## Outward speed of burst motes.
@export_range(0.3, 2.5, 0.05, "suffix:×") var burst_speed: float = 1.15:
	set(value):
		burst_speed = value
		_reconfigure_engine()

## Upward kick applied to burst motes.
@export_range(10.0, 120.0, 1.0, "suffix:px/s") var burst_lift: float = 52.0:
	set(value):
		burst_lift = value
		_reconfigure_engine()

## Lifetime of burst motes in seconds.
@export_range(0.15, 1.5, 0.05, "suffix:s") var burst_life: float = 0.72:
	set(value):
		burst_life = value
		_reconfigure_engine()

@export_group("Rendering")

## Additive blend for a soft magical glow. Off = normal alpha blending.
@export var additive_blend: bool = true:
	set(value):
		additive_blend = value
		_apply_additive_blend()

## Top margin in pixels — pointer dust ignored above this line (e.g. title bar).
@export_range(0.0, 128.0, 1.0, "suffix:px") var content_margin_top: float = 0.0

## Bottom margin in pixels — pointer dust ignored below this line.
@export_range(0.0, 128.0, 1.0, "suffix:px") var content_margin_bottom: float = 0.0

@export_group("Ordering")

## Draw layer. Host sparkles use 100 — keep cursor dust above (150–250).
@export_range(-128, 4096, 1) var draw_z_index: int = 200:
	set(value):
		draw_z_index = value
		z_index = value

## false = absolute z-order in scene tree (recommended for root overlays).
@export var draw_z_as_relative: bool = false:
	set(value):
		draw_z_as_relative = value
		z_as_relative = value

var _engine := _EngineClass.new()
var _sprite: Texture2D
var _blend_material: CanvasItemMaterial
var _last_pos: Vector2 = Vector2(-1000.0, -1000.0)
var _spawn_accumulator: float = 0.0
var _pointer_valid: bool = false
var _needs_redraw: bool = false


func _ready() -> void:
	_sprite = load(_Types.SPRITE_PATH) as Texture2D
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = draw_z_index
	z_as_relative = draw_z_as_relative
	_reconfigure_engine()
	_apply_additive_blend()
	if Engine.is_editor_hint():
		set_process(false)
	else:
		set_process(true)


func _input(event: InputEvent) -> void:
	if not enabled or Engine.is_editor_hint():
		return
	if event is InputEventMouseMotion:
		_track_pointer(_event_to_local(event.position), event.relative)
	elif event is InputEventScreenDrag:
		_track_pointer(_event_to_local(event.position), event.relative)
	elif click_burst_enabled:
		if event is InputEventMouseButton and event.pressed:
			_trigger_click_burst(_event_to_local(event.position))
		elif event is InputEventScreenTouch and event.pressed:
			_trigger_click_burst(_event_to_local(event.position))


func _process(delta: float) -> void:
	if not enabled:
		return

	var local_pos := get_local_mouse_position()
	if _pointer_in_bounds(local_pos):
		var travel := local_pos - _last_pos
		if travel.length_squared() > 0.01:
			_emit_for_travel(local_pos, travel, delta)
		elif not _pointer_valid:
			_last_pos = local_pos
			_pointer_valid = true

	_engine.update(delta)
	var has_live := _engine.has_live_particles()
	if has_live or _needs_redraw:
		queue_redraw()
	_needs_redraw = has_live


func apply_preset(preset: Dictionary) -> void:
	for key in preset:
		set(key, preset[key])


## Magical radial burst at local position (same space as this Control).
func burst_at(local_pos: Vector2, intensity: float = 1.0) -> void:
	if not enabled or Engine.is_editor_hint():
		return
	if not _pointer_in_bounds(local_pos):
		return
	var final_intensity := intensity * burst_intensity
	_engine.burst_at(local_pos, final_intensity)
	burst_triggered.emit(local_pos, final_intensity)
	_needs_redraw = true
	queue_redraw()


## Burst at global canvas position.
func burst_at_global(global_pos: Vector2, intensity: float = 1.0) -> void:
	burst_at(_event_to_local(global_pos), intensity)


func _trigger_click_burst(local_pos: Vector2) -> void:
	burst_at(local_pos, 1.0)


func _track_pointer(local_pos: Vector2, delta_pos: Vector2) -> void:
	if not _pointer_in_bounds(local_pos):
		return
	if delta_pos.length_squared() < 0.01:
		_last_pos = local_pos
		_pointer_valid = true
		return
	_emit_for_travel(local_pos, delta_pos, get_process_delta_time())


func _emit_for_travel(local_pos: Vector2, travel: Vector2, delta: float) -> void:
	var safe_delta := maxf(delta, 0.0001)
	var move_speed := travel.length() / safe_delta
	if move_speed < min_move_speed and travel.length() < 2.0:
		_last_pos = local_pos
		_pointer_valid = true
		return

	_spawn_accumulator += travel.length() * spawn_density
	if _spawn_accumulator < 1.0:
		_last_pos = local_pos
		_pointer_valid = true
		return

	var spawn_count := mini(int(_spawn_accumulator), max_spawns_per_frame)
	spawn_count = maxi(spawn_count, 1)
	var move_dir := travel.normalized() if travel.length_squared() > 0.01 else Vector2.DOWN

	for i in range(spawn_count):
		var t := float(i + 1) / float(spawn_count + 1)
		var spawn_pos := _last_pos.lerp(local_pos, t)
		_engine.emit_at(spawn_pos, move_dir, move_speed)

	_spawn_accumulator -= float(spawn_count)
	_last_pos = local_pos
	_pointer_valid = true
	queue_redraw()


func _pointer_in_bounds(local_pos: Vector2) -> bool:
	return Rect2(
		0.0,
		content_margin_top,
		size.x,
		maxf(size.y - content_margin_top - content_margin_bottom, 0.0)
	).has_point(local_pos)


func _event_to_local(global_pos: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * global_pos


func _reconfigure_engine() -> void:
	_engine.configure(
		max_particles,
		colors,
		rainbow,
		magical_hues,
		spread,
		speed_scale,
		lift,
		gravity,
		particle_life,
		turbulence,
		0.35,
		sparks_per_emit,
		burst_particle_count,
		burst_spread,
		burst_speed,
		burst_lift,
		burst_life
	)
	_needs_redraw = true
	if is_inside_tree():
		queue_redraw()


func _apply_additive_blend() -> void:
	if not is_inside_tree():
		return
	if additive_blend:
		if _blend_material == null:
			_blend_material = CanvasItemMaterial.new()
		_blend_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = _blend_material
	else:
		material = null


func _draw() -> void:
	if _sprite == null:
		return
	for particle in _engine.get_particles():
		var life: float = particle["life"]
		if life <= 0.0:
			continue
		var opacity: float = particle["opacity"]
		if opacity <= 0.0:
			continue
		var pos: Vector2 = particle["position"]
		var frame_x: int = particle["frame"]
		var color: Color = particle["color"]
		var scale: float = particle.get("scale", 1.0)
		var mode: int = particle.get("mode", 0)
		var alpha_mul := 0.92 if mode == _EngineClass.ParticleMode.BURST else 0.8
		if particle.get("glimmer", false):
			alpha_mul += 0.08
		color.a = opacity * alpha_mul
		var sprite_size := float(_Types.SPRITE_SIZE) * scale
		var half := sprite_size * 0.5
		var src := Rect2(frame_x, 0, _Types.SPRITE_SIZE, _Types.SPRITE_SIZE)
		var dst := Rect2(pos - Vector2(half, half), Vector2(sprite_size, sprite_size))
		draw_texture_rect_region(_sprite, dst, src, color)
