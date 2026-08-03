extends Node2D
@onready var animation_player = $Automator
var has_entered : bool = false
@onready var moon_star: Area2D = $Clouds_Lvl2/Cloud4/Moon_star
@onready var horse: Hornse = $Horse

@onready var star: Area2D = $Clouds_Lvl1/Cloud4/Star
@onready var mushroom_2: Area2D = $Mushroom2
@onready var star_anim: AnimationPlayer = $Clouds_Lvl1/Cloud4/Star/Star_anim
@onready var moon_star_anim: AnimationPlayer = $Clouds_Lvl2/Cloud4/Moon_star/Moon_star_anim


func _ready() -> void:
	#$Horse.dashes = 0
	star_anim.play("Star_Pulse")
	moon_star_anim.play("Moon_star_Pulse")
	$"Music Soft".play()
	
#### unlock 3rd double jump + gravity modifier on eating 2nd mushroom.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		animation_player.play("SpiritHorseGod")
		$"Music Soft".stop()
		$Horse.gravityScale *=0.5
		var eat_tween = get_tree().create_tween()
	#	eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property($Clouds_Lvl1/Cloud4/Star/Star_Pickup,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished
		star.queue_free()




func _process(delta: float) -> void:
	var speed = $Horse.velocity.length()
	var t = clampf(speed / $Horse.maxSpeed, 0.0, 1.0)
	var target_zoom = lerpf(2.0, 1.9, t)
	
	var z = lerpf(%Camera2D.zoom.x, target_zoom, 10.0 * delta)
	%Camera2D.zoom = Vector2(z, z)


func _on_moon_star_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		animation_player.play("NightHorseGod")
	#	$Horse.dashes = 1
		var eat_tween = get_tree().create_tween()
	#	eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property($Clouds_Lvl2/Cloud4/Moon_star/Moon_Star_Pickup,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished
	
		moon_star.queue_free()
	#pass # Replace with function body.
