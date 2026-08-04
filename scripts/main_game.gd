extends Node2D

@onready var animation_player = $Automator
var has_entered : bool = false
@onready var moon_star: Area2D = $Clouds_Lvl2/Cloud4/Moon_star
@onready var horse: Hornse = $Horse

@onready var star: Area2D = $Clouds_Lvl1/Cloud4/Star
@onready var mushroom_2: Area2D = $Mushroom2
@onready var star_anim: AnimationPlayer = $Clouds_Lvl1/Cloud4/Star/Star_anim
@onready var moon_star_anim: AnimationPlayer = $Clouds_Lvl2/Cloud4/Moon_star/Moon_star_anim

####HORSE PARTICLES
@onready var particle_gravity=$Horse/horse_particle.process_material.gravity
@onready var particle_end = $Horse/horse_particle.emitting
@onready var horse_vel = $Horse.velocity
@onready var horse_particle: GPUParticles2D = $Horse/horse_particle

func _ready() -> void:
	horse_particle.visible = false
	$Horse.dashes = 0
	star_anim.play("Star_Pulse")
	moon_star_anim.play("Moon_star_Pulse")
	$"Music Soft".play()
	
#### unlock 3rd double jump + gravity modifier on eating 2nd mushroom.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		animation_player.play("SpiritHorseGod")
		$"Music Soft".stop()
		$Horse.gravityScale *=0.5
		horse_particle.visible = true
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
	
	#### HORSE PARTICLES!!

	var direction = Input.get_vector("Left","Right","Jump","Down")
	#print("horse velocity: ",horse_vel)
	#particle_gravity=horse_vel*100
	if direction.length() > 0:
		#horse_particle.restart()
		horse_particle.set_emitting(true)
	else:
		#horse_particle.restart()
		horse_particle.set_emitting(false)
	#print(particle_end)
	#print("direction: " ,direction)
	#print ("gravity: ", particle_gravity)

	### HORSE TRANSPARENCY
	if horse.dashing:
		var dash_transparency = get_tree().create_tween()
		dash_transparency.tween_property($Horse/AnimatedSprite2D.material, "shader_parameter/Horse_Alpha",0.5,0.2)
		dash_transparency.tween_property($Horse/AnimatedSprite2D.material, "shader_parameter/Horse_Alpha",1,0.2)

func _on_moon_star_body_entered(body: Node2D) -> void:
	if body.is_in_group("Horse"):
		animation_player.play("NightHorseGod")
		$Horse.dashes = 1
		var eat_tween = get_tree().create_tween()
	#	eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property($Clouds_Lvl2/Cloud4/Moon_star/Moon_Star_Pickup,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished
		
		moon_star.queue_free()
	#pass # Replace with function body.
