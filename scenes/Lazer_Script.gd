extends Line2D

@onready var start_point = $"../Eye".position
@onready var end_point = $"../LazerEnd".position

var point0 = points [0]
var point1 = points [1]

func _ready() -> void:
	$"../LazerEnd/Cloud_lazer/Lazer_Collision".disabled = true
	point0 = start_point
	point1 = start_point
	set_point_position(0,point0)
	set_point_position(1,point1)
	print(start_point)


func _process(delta: float) -> void:
	var lazer = Input.is_action_just_pressed("Ability")
	set_point_position(0,point0)
	set_point_position(1,point1)
	if Input.is_action_pressed("Ability"):
		$"../LazerEnd/Cloud_lazer/Lazer_Collision".disabled = false
	else:
		$"../LazerEnd/Cloud_lazer/Lazer_Collision".disabled = true
	if   lazer:
		
		$"../../AnimationPlayer".play("lazer-sfx")
		var lazer_tween = get_tree().create_tween()
		lazer_tween.tween_property(self,"point0",start_point,0.1)
		lazer_tween.tween_property(self,"point1",end_point,0.1)
		lazer_tween.tween_property(self,"point0",start_point,0.1)
		lazer_tween.tween_property(self,"point1",start_point,0.1)

		
