extends Node2D

@onready var animation_player = $Automator
var has_entered : bool = false
@onready var moon_star: Area2D = $Clouds_Lvl2/Cloud4/Moon_star
@onready var horse: Hornse = $Horse
@onready var camera: Camera2D = $Horse/Camera2D
@onready var sun_star: Area2D = $Clouds_Lvl3/Cloud4/Sun_star
@onready var star: Area2D = $Clouds_Lvl1/Cloud2_flipped/Star
@onready var mushroom_2: Area2D = $Mushroom2
@onready var star_anim: AnimationPlayer = $Clouds_Lvl1/Cloud2_flipped/Star/Star_anim
@onready var moon_star_anim: AnimationPlayer = $Clouds_Lvl2/Cloud4/Moon_star/Moon_star_anim
@onready var sun_star_anim: AnimationPlayer = $Clouds_Lvl3/Cloud4/Sun_star/Sun_star_anim
@onready var rainbow_pickup: Area2D = $Clouds_Lvl4/cloudRigitBody_1/Rainbow_Pickup
@onready var cloud_rigid_body_3: RigidBody2D = $Clouds_Lvl4/cloudRigidBody_3


####HORSE PARTICLES
@onready var horse_particle: GPUParticles2D = $Horse/horse_particle
@onready var particle_gravity=$Horse/horse_particle.process_material.gravity
@onready var particle_end = $Horse/horse_particle.emitting

@onready var windFX: GPUParticles2D = $Horse/Horse_windFX
@onready var windFX_end = $Horse/Horse_windFX.emitting


@onready var horse_vel = $Horse.velocity



func _ready() -> void:
#	$Automator.play("RESET")
	horse_particle.visible = false
	horse.charged_jump = false
	horse.dashes = 0
	star_anim.play("Star_Pulse")
	moon_star_anim.play("Moon_star_Pulse")
	sun_star_anim.play("Sun_star_Pulse")
	$"Music Soft".play()

#### unlock 3rd double jump + gravity modifier on eating 2nd mushroom.
func _on_body_entered(body: Node2D) -> void:
	print ("camera: zoom: ", camera.zoom)
	if body.is_in_group("Horse"):
		animation_player.play("SpiritHorseGod")
		$"Music Soft".stop()
		$Horse.gravityScale *=0.5
		horse_particle.visible = true
		var eat_tween = get_tree().create_tween()
	#	eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property($Clouds_Lvl1/Cloud2_flipped/Star/Star_Pickup,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished
		star.queue_free()




func _process(delta: float) -> void:
#	print ("camera: zoom: ", camera.zoom)
	var speed = $Horse.velocity.length()
	var t = clampf(speed / $Horse.maxSpeed, 0.0, 1.0)
	var target_zoom = lerpf(%Camera2D.zoom.x, %Camera2D.zoom.y, t)

	var z = lerpf(%Camera2D.zoom.x, target_zoom, 10.0 * delta)
	%Camera2D.zoom = Vector2(z, z)

	#### HORSE PARTICLES!!

	var direction = Input.get_vector("Left","Right","Jump","Down")
	var isChargedJump = horse.velocity.y
	#print("horse velocity: ",horse_vel)
	#particle_gravity=horse_vel*100
	#INFO Jump particles
	if direction.length() > 0:
		#horse_particle.restart()
		horse_particle.set_emitting(true)
	else:
		#horse_particle.restart()
		horse_particle.set_emitting(false)

	#INFO Charge Jump wind FX
	if isChargedJump < 0:
		windFX.set_emitting(true)
		#print("wind gravity: ",windFX.process_material.gravity)
		windFX.process_material.gravity.x += horse_vel.x
		windFX.process_material.gravity.y += horse_vel.y
	else:
		windFX.set_emitting(false)

	#print(particle_end)
	#print("direction: " ,direction)
	#print ("gravity: ", particle_gravity)

	### HORSE TRANSPARENCY
	if horse.dashing:
		var dash_transparency = get_tree().create_tween()
		dash_transparency.tween_property($Horse/AnimatedSprite2D.material, "shader_parameter/Horse_Alpha",0.5,0.2)
		dash_transparency.tween_property($Horse/AnimatedSprite2D.material, "shader_parameter/Horse_Alpha",1,0.2)

func _on_moon_star_body_entered(body: Node2D) -> void:
	print ("camera: zoom: ", camera.zoom)
	if body.is_in_group("Horse"):
		$Horse.dashes = 1
		animation_player.play("NightHorseGod")

		var eat_tween = get_tree().create_tween()
	#	eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property($Clouds_Lvl2/Cloud4/Moon_star/Moon_Star_Pickup,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished

		moon_star.queue_free()
	#pass # Replace with function body.
func _on_sun_star_body_entered(body: Node2D)-> void:
	print ("camera: zoom: ", camera.zoom)
	if body.is_in_group("Horse"):
		horse.charged_jump = true
		horse.jumpCount = 0

		animation_player.play("DragonHorseGod")
		var eat_tween = get_tree().create_tween()
		eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property($Clouds_Lvl3/Cloud4/Sun_star/Sun_Star_Pickup,"global_scale",Vector2(0,0),0.2)
		await eat_tween.finished
		sun_star.queue_free()


func _on_rainbow_pickup_body_entered(body: Node2D) -> void:
	#pass # Replace with function body.
	if body.is_in_group("Horse"):
		##INFO new ability goes here:
		#horse needs to grow wings and learn to fly now, I guess.
		#let's try this, for funsies:
		#horse.motion_mode=CharacterBody2D.MOTION_MODE_FLOATING
		horse.gravityActive=false
		horse.charged_jump = false
		
		animation_player.play("PegasusHorseGod")
		
		var eat_tween = get_tree().create_tween()
		eat_tween.set_trans(Tween.TRANS_CUBIC)
		eat_tween.tween_property($Clouds_Lvl4/cloudRigitBody_1/Rainbow_Pickup/RainbowPickupSprite,"global_scale",Vector2(0,0),0.2)
		rainbow_pickup.queue_free()
		await eat_tween.finished
		
