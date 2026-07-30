extends RigidBody2D
@export var gravity_amount: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	#freeze = true
	#freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC



func _physics_process(delta: float) -> void:
	pass # Replace with function body.
	#if _on_cloud_enter_area_2d_area_entered():
		

func _on_cloud_enter_area_2d_area_entered(_area: Area2D) -> void:
	
	
	#freeze = false
	#linear_velocity = Vector2.ZERO
	var cloud_tween = get_tree().create_tween()
	cloud_tween.set_trans(Tween.TRANS_LINEAR)
	cloud_tween.set_parallel(false)
	cloud_tween.tween_property(self, "gravity_scale",  1 , 0.01)
	
	cloud_tween.tween_interval(0.1)
	
	cloud_tween.tween_property(self, "gravity_scale", -1, 0.01)
	
	cloud_tween.tween_interval(0.1)
	
	cloud_tween.tween_property(self, "gravity_scale", 0, 0.1)
	
	cloud_tween.tween_interval(0.1)
#	cloud_tween.set_ease(Tween.EASE_OUT)
	cloud_tween.tween_property(self, "linear_velocity", Vector2.ZERO, 0.4)

		
		
	
	#pass # Replace with function body.
