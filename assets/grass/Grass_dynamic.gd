extends Area2D
@onready var grass_blade_1: Sprite2D = $GrassBlade1
@onready var grass_dynamic: Area2D = $"."

var min_skew := -800
var max_skew := 800



func _ready() -> void:
	randomize()
	#grass_blade_1.material.set("shader_parameter/offset", randi() % 3)
	#grass_blade_1.frame = randi() % 2
	#grass_dynamic.position.y = randf_range(0, 5)
	grass_blade_1.material.set("shader_parameter/skew", 0)


func _on_Grass_body_entered(body: Node) -> void:
	if body.is_in_group("Horse"):
		var direction = global_position.direction_to(body.global_position)
		#var skew = body.maxSpeed
		var skew = clamp(remap(body.velocity.length() * sign(-direction.x), -body.maxSpeed, body.maxSpeed, min_skew, max_skew), min_skew, max_skew)
		#print (skew)
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(grass_blade_1.material, "shader_parameter/skew", skew, 1)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_SPRING)
		tween.tween_property(grass_blade_1.material, "shader_parameter/skew", 0.0, 3.0)
