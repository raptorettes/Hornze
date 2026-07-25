extends CharacterBody2D

signal hit
@export var friction = 0.1
@export var acceleration = 0.15  # Reduced for smoother velocity transition
@export var speed = 400.0        # Move speed in pixels/sec
@export var rotation_smoothness = 10.0 # Higher = faster rotation, Lower = smoother
var target_position: Vector2 = Vector2.ZERO
const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta):
	# 1. Get input vector from keyboard or analogue stick
	var direction = Input.get_vector("Left", "Right", "Jump", "Down")
	
	# 2. Handle Movement and Velocity
	if direction.length() > 0:
		
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		
		# 3. Handle Smooth Rotation
		# Get the angle of the current movement direction
		var target_angle = direction.angle()
		
		# Interpolate smoothly between current rotation and target angle
		rotation = lerp_angle(rotation, target_angle, rotation_smoothness * delta)
		
		#sprite_anim.play ("walk")
	else:
		# Smoothly stop when no input is pressed
		velocity = velocity.lerp(target_position, friction)
		#sprite_anim.stop ()
		#anim_player.play("Horse_Idle")
		
	#var input_direction = Input.get_vector("left", "right", "up", "down")
	#if input_direction != Vector2.ZERO:
		##$Lizard_Sprite.animation = "idle"
		#anim_player.play("Lizard_Idle")
	#else:
		#$Lizard_Sprite.animation = "walk"
		##anim_player.play("Lizard_Idle")
		#
	#move_and_slide()
	move_and_collide(velocity * delta)

#func _process(delta: float) -> void:
	# 2. Trigger an animation via user input
	#var input_direction = Input.get_vector("left", "right", "up", "down")
	#if input_direction != Vector2.ZERO:
		##$Lizard_Sprite.animation = "idle"
		#anim_player.play("Lizard_Idle")
	#else:
		#$Lizard_Sprite.animation = "walk"
		##anim_player.play("Lizard_Idle")


#Default move script:

#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("Left", "Right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
