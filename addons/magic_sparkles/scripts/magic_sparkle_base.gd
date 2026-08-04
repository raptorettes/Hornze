@tool
## Shared host-sparkle settings — inherited by [MagicSparkleLight] and [MagicSparkleBatch].
extends Control
class_name MagicSparkleBase

signal activated
signal deactivated
signal hover_entered
signal hover_exited

const _Types := preload("res://addons/magic_sparkles/scripts/magic_sparkle_types.gd")
const _Bounds := preload("res://addons/magic_sparkles/scripts/magic_sparkle_bounds.gd")
const _EngineClass := preload("res://addons/magic_sparkles/scripts/magic_sparkle_engine.gd")

@export_group("Particles")

## Number of sparkle particles simulated at once.
@export_range(1, 5000, 1) var particle_count: int = 30:
	set(value):
		particle_count = value
		_apply_count_limits()
		_reconfigure_engine()

@export_group("Appearance")

## Tint palette — each particle picks a random color from this list.
@export var colors: Array[Color] = [Color.WHITE]:
	set(value):
		colors = value
		_reconfigure_engine()

## Random vivid hue per particle. Overrides Colors when enabled.
@export var rainbow: bool = false:
	set(value):
		rainbow = value
		_reconfigure_engine()

@export_group("Motion")

## Movement preset for all particles.
@export var motion_mode: MagicSparkleTypes.MotionMode = MagicSparkleTypes.MotionMode.CLASSIC:
	set(value):
		motion_mode = value
		_reconfigure_engine()

## Global speed multiplier for all motion presets.
@export_range(0.01, 5.0, 0.01, "suffix:×") var speed: float = 1.0:
	set(value):
		speed = value
		_reconfigure_engine()

@export_subgroup("Direction")

## Flow direction in degrees. -90° = up · 90° = down · 0° = right. Drift, Rise, Rain.
@export_range(-180.0, 180.0, 1.0, "suffix:°") var direction_bias: float = -90.0:
	set(value):
		direction_bias = value
		_reconfigure_engine()

@export_subgroup("Physics")

## Organic wobble. 0 = straight paths; 1 = lively chaos.
@export_range(0.0, 1.0, 0.01) var turbulence: float = 0.35:
	set(value):
		turbulence = value
		_reconfigure_engine()

## Constant acceleration. Positive = downward pull; negative = upward lift.
@export_range(-2.0, 2.0, 0.01) var gravity: float = 0.0:
	set(value):
		gravity = value
		_reconfigure_engine()

## Spin and pulse intensity for Swirl, Orbit, and Pulse modes.
@export_range(0.0, 3.0, 0.01) var swirl_strength: float = 1.0:
	set(value):
		swirl_strength = value
		_reconfigure_engine()

@export_subgroup("Variety")

## Per-particle speed and path variance. 0 = uniform; 1 = natural variety.
@export_range(0.0, 1.0, 0.01) var motion_randomness: float = 0.5:
	set(value):
		motion_randomness = value
		_reconfigure_engine()

## Extra pixels beyond the host edge. 4–12 px adds a soft aura around buttons.
@export_range(0.0, 64.0, 1.0, "suffix:px") var overlap: float = 0.0:
	set(value):
		overlap = value
		_update_layout()

@export_group("Boundaries")

## How particles behave at the host edge.
@export var boundary_mode: MagicSparkleTypes.BoundaryMode = MagicSparkleTypes.BoundaryMode.CLIP_WRAP:
	set(value):
		boundary_mode = value
		_apply_boundary_visuals()
		_reconfigure_engine()

## Fade speed outside the host. Only applies to Fade Exit mode.
@export_range(0.001, 0.5, 0.001) var exit_fade_rate: float = 0.05:
	set(value):
		exit_fade_rate = value
		_reconfigure_engine()

@export_group("Activation")

## When sparkles start and stop.
@export var activation_mode: MagicSparkleTypes.ActivationMode = MagicSparkleTypes.ActivationMode.ON_HOVER:
	set(value):
		activation_mode = value
		_apply_activation_mode()

@export_group("Target")

## Bounds and hover target. Empty = parent node.
@export var host: NodePath

## Manual host size in pixels when the host has no layout size.
@export var custom_size: Vector2 = Vector2.ZERO

var _host: Node
var _engine := _EngineClass.new()
var _host_size: Vector2 = Vector2(64, 64)
var _clip_rect: Rect2
var _simulation_rect: Rect2
var _sprite: Texture2D
var _hover_area: Area2D


func _ready() -> void:
	_apply_count_limits()
	_sprite = load(_Types.SPRITE_PATH) as Texture2D
	_host = _Bounds.resolve_host(self, host, custom_size)
	_update_layout()
	_connect_host_signals()
	_setup_hover_detection()
	_reconfigure_engine()
	_on_renderer_ready()
	_apply_boundary_visuals()
	_apply_activation_mode()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		set_process(false)
		return
	if not _engine.is_active():
		set_process(false)
		return
	var keep_running := _engine.update(delta)
	_sync_renderer()
	if not keep_running:
		set_process(false)
		_on_activation_changed(false)
		deactivated.emit()


func activate() -> void:
	var should_emit: bool = not _engine.is_active() or _engine.is_fading()
	_engine.activate()
	set_process(true)
	_sync_renderer()
	_on_activation_changed(true)
	if should_emit:
		activated.emit()


func deactivate() -> void:
	if not _engine.is_active():
		return
	_engine.deactivate()
	set_process(true)


func is_active() -> bool:
	return _engine.is_active()


func set_colors(new_colors: Array[Color]) -> void:
	colors = new_colors


func get_clip_rect_local() -> Rect2:
	return _clip_rect


func get_simulation_rect_local() -> Rect2:
	return _simulation_rect


func get_sprite() -> Texture2D:
	return _sprite


func get_engine() -> MagicSparkleEngine:
	return _engine


func _apply_count_limits() -> void:
	pass


func _on_renderer_ready() -> void:
	pass


func _sync_renderer() -> void:
	pass


func _on_activation_changed(_active: bool) -> void:
	pass


func _connect_host_signals() -> void:
	if _host is Control:
		if not _host.resized.is_connected(_on_host_resized):
			_host.resized.connect(_on_host_resized)


func _on_host_resized() -> void:
	_update_layout()
	_reconfigure_engine()


func _update_layout() -> void:
	if not is_inside_tree():
		return
	_host_size = _Bounds.get_host_size(_host, custom_size)
	_clip_rect = _Bounds.clip_rect_in_overlay(overlap, _host_size)
	_simulation_rect = _Bounds.simulation_rect_in_overlay(overlap, _host_size)

	if get_parent() == _host:
		set_anchors_preset(Control.PRESET_FULL_RECT)
		offset_left = -overlap
		offset_top = -overlap
		offset_right = overlap
		offset_bottom = overlap
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		z_index = 100
	else:
		custom_minimum_size = _simulation_rect.size
		size = _simulation_rect.size

	_update_hover_area_shape()


func _reconfigure_engine() -> void:
	_engine.configure(
		particle_count,
		colors,
		rainbow,
		speed,
		boundary_mode,
		exit_fade_rate,
		_simulation_rect,
		_clip_rect,
		motion_mode,
		Vector2.from_angle(deg_to_rad(direction_bias)),
		turbulence,
		gravity,
		swirl_strength,
		motion_randomness
	)
	if _engine.is_active():
		_sync_renderer()


func _apply_boundary_visuals() -> void:
	clip_contents = boundary_mode == MagicSparkleTypes.BoundaryMode.CLIP_WRAP


func _apply_activation_mode() -> void:
	if not is_inside_tree():
		return
	if Engine.is_editor_hint():
		return
	if activation_mode == MagicSparkleTypes.ActivationMode.ALWAYS:
		activate()
	elif not _engine.is_active():
		set_process(false)


func _setup_hover_detection() -> void:
	if _host is Control:
		if not _host.mouse_entered.is_connected(_on_host_mouse_entered):
			_host.mouse_entered.connect(_on_host_mouse_entered)
		if not _host.mouse_exited.is_connected(_on_host_mouse_exited):
			_host.mouse_exited.connect(_on_host_mouse_exited)
	elif _host is Node2D:
		_create_hover_area()


func _create_hover_area() -> void:
	if _hover_area:
		return
	_hover_area = Area2D.new()
	_hover_area.name = "MagicSparkleHoverArea"
	_hover_area.monitorable = false
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = _host_size
	shape.shape = rect_shape
	_hover_area.add_child(shape)
	_host.add_child(_hover_area)
	_hover_area.position = Vector2.ZERO
	_update_hover_area_shape()
	if not _hover_area.mouse_entered.is_connected(_on_host_mouse_entered):
		_hover_area.mouse_entered.connect(_on_host_mouse_entered)
	if not _hover_area.mouse_exited.is_connected(_on_host_mouse_exited):
		_hover_area.mouse_exited.connect(_on_host_mouse_exited)


func _update_hover_area_shape() -> void:
	if not _hover_area:
		return
	var shape_node := _hover_area.get_child(0) as CollisionShape2D
	if shape_node and shape_node.shape is RectangleShape2D:
		(shape_node.shape as RectangleShape2D).size = _host_size


func _on_host_mouse_entered() -> void:
	hover_entered.emit()
	if activation_mode == MagicSparkleTypes.ActivationMode.ON_HOVER:
		activate()


func _on_host_mouse_exited() -> void:
	hover_exited.emit()
	if activation_mode == MagicSparkleTypes.ActivationMode.ON_HOVER:
		deactivate()


func _exit_tree() -> void:
	if _hover_area and is_instance_valid(_hover_area):
		_hover_area.queue_free()
		_hover_area = null
