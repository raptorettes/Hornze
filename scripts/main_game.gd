extends Node2D
@onready var animation_player = $Automator
var has_entered : bool = false
@onready var star: Area2D = $Clouds_Lvl1/Cloud4/Star
@onready var mushroom_2: Area2D = $Mushroom2
@onready var star_anim: AnimationPlayer = $Clouds_Lvl1/Cloud4/Star/Star_anim


func _ready() -> void:
	star_anim.play("Star_Pulse")
	$"Music Soft".play()
	
#### unlock 3rd double jump + gravity modifier on eating 2nd mushroom.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		animation_player.play("SpiritHorseGod")
		$"Music Soft".stop()
		$Horse.gravityScale *=0.5
		star.queue_free()



func _process(delta: float) -> void:
	var speed = $Horse.velocity.length()
	var t = clampf(speed / $Horse.maxSpeed, 0.0, 1.0)
	var target_zoom = lerpf(2.0, 1.9, t)
	
	var z = lerpf(%Camera2D.zoom.x, target_zoom, 10.0 * delta)
	%Camera2D.zoom = Vector2(z, z)
