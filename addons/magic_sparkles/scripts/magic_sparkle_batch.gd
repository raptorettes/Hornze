@tool
## High-density sparkle overlay using MultiMesh — best for 50–5000 particles and fullscreen effects.
extends "res://addons/magic_sparkles/scripts/magic_sparkle_base.gd"
class_name MagicSparkleBatch

var _multimesh_instance: MultiMeshInstance2D
var _multimesh: MultiMesh
var _material: ShaderMaterial


func _validate_property(property: Dictionary) -> void:
	if property.name == "particle_count":
		property.hint = PROPERTY_HINT_RANGE
		property.hint_string = "50,5000,1"


func _apply_count_limits() -> void:
	if particle_count < 50:
		push_warning("MagicSparkleBatch: particle_count < 50 — consider MagicSparkleLight instead.")


func _on_renderer_ready() -> void:
	_multimesh_instance = MultiMeshInstance2D.new()
	_multimesh_instance.name = "SparkleMultiMesh"
	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_2D
	_multimesh.use_colors = true
	_multimesh.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2(MagicSparkleTypes.SPRITE_SIZE, MagicSparkleTypes.SPRITE_SIZE)
	_multimesh.mesh = quad
	_material = ShaderMaterial.new()
	_material.shader = load(MagicSparkleTypes.SHADER_PATH) as Shader
	_material.set_shader_parameter("sparkle_atlas", _sprite)
	_multimesh_instance.material = _material
	_multimesh_instance.multimesh = _multimesh
	add_child(_multimesh_instance)
	_rebuild_multimesh()


func _reconfigure_engine() -> void:
	super._reconfigure_engine()
	_rebuild_multimesh()


func _rebuild_multimesh() -> void:
	if _multimesh == null:
		return
	_multimesh.instance_count = particle_count
	_sync_renderer()


func _sync_renderer() -> void:
	if _multimesh == null:
		return
	var particles := _engine.get_particles()
	var count := mini(particles.size(), _multimesh.instance_count)
	for i in count:
		var particle: Dictionary = particles[i]
		var opacity: float = particle["opacity"]
		var pos: Vector2 = particle["position"]
		var frame_x: int = particle["frame"]
		var color: Color = particle["color"]
		color.a = opacity * MagicSparkleTypes.TINT_ALPHA
		var half := Vector2(MagicSparkleTypes.SPRITE_SIZE * 0.5, MagicSparkleTypes.SPRITE_SIZE * 0.5)
		var xform := Transform2D(0.0, pos + half)
		if opacity <= 0.0:
			xform = Transform2D(0.0, Vector2(-10000, -10000))
		_multimesh.set_instance_transform_2d(i, xform)
		_multimesh.set_instance_color(i, color)
		_multimesh.set_instance_custom_data(i, Color(float(frame_x) / 27.0, 0.0, 0.0, 1.0))


func _on_activation_changed(active: bool) -> void:
	if _multimesh_instance:
		_multimesh_instance.visible = active or _engine.is_fading()
