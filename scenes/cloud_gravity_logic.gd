extends RigidBody2D

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	pass # Replace with function body.


func _on_cloud_enter_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Lazer"):
		queue_free()
	var cloud_tween = get_tree().create_tween()
	cloud_tween.set_trans(Tween.TRANS_LINEAR)
	cloud_tween.set_parallel(false)
	cloud_tween.tween_property(self, "gravity_scale",  1 , 0.01)

	cloud_tween.tween_interval(0.1)

	cloud_tween.tween_property(self, "gravity_scale", -1, 0.01)

	cloud_tween.tween_interval(0.1)

	cloud_tween.tween_property(self, "gravity_scale", 0, 0.1)

	cloud_tween.tween_interval(0.1)

	cloud_tween.tween_property(self, "linear_velocity", Vector2.ZERO, 0.4)
