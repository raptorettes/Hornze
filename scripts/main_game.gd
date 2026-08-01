extends Node2D
@onready var animation_player = $Automator
var has_entered : bool = false
@onready var star: Area2D = $Clouds_Lvl1/Cloud4/Star
@onready var mushroom_2: Area2D = $Mushroom2
@onready var star_anim: AnimationPlayer = $Clouds_Lvl1/Cloud4/Star/Star_anim
@onready var mushroom_2Sprite	: Sprite2D = $Mushroom2/MushroomSprite

func _ready() -> void:
#	mushroom.body_entered.connect(_on_body_entered)
	#$Mushroom2.body_entered.connect(_on_body_entered)
	star_anim.play("Star_Pulse")
	$"Music Soft".play()
#### unlock 3rd double jump + gravity modifier on eating 2nd mushroom.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		animation_player.play("SpiritHorseGod")
		$"Music Soft".stop()
		$Horse.gravityScale *=0.5
		star.queue_free()


### Unlock first double jump, when eating mushroom on the ground
func _on_mushroom_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		$Horse.jumps += 1
		var eat_tween = get_tree().create_tween()
	#	eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property(mushroom_2Sprite,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished
		mushroom_2.queue_free()
