extends CharacterBody2D
class_name Player

const SPEED = 150.0
const JUMP_VELOCITY = -350.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$auto_climb.disabled = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	#flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if direction:
		velocity.x = direction * SPEED
		$stairchecker.scale.x = sign(velocity.x)
	
	#play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else :
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	#Checking if we need to climb stairs
	if direction and velocity.y >=0.0 :
		var next_to_stair = not $stairchecker/top_check.is_colliding() and $stairchecker/st_check.is_colliding()
		$auto_climb.disabled = not next_to_stair
