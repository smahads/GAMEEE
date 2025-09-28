extends CharacterBody2D
class_name Player

const SPEED = 150.0
const JUMP_VELOCITY = -450.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer

var health: int = 2
var is_attacking: bool = false
var is_dead: bool = false
var is_hurt: bool = false 

func _ready() -> void:
	# Reset attack after animation ends
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Damage on specific attack frame
	animated_sprite.frame_changed.connect(_on_frame_changed)
	attack_area.body_entered.connect(_on_attack_area_entered) # <-- This line needs the function below to exist


# ... (at the bottom of your script, under the DAMAGE SYSTEM or separate section)

func _on_attack_area_entered(body: Node) -> void:
	print("AttackArea detected: ", body) # <-- THIS FUNCTION MUST BE DEFINED


func _physics_process(delta: float) -> void:
	# Prioritize death and injury states
	if is_dead or is_hurt:
		if is_dead:
			return # stop all movement if dead
		# If hurt, still apply gravity and move but skip other inputs
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		$auto_climb.disabled = true

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		perform_attack()
		return

	# Movement
	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if direction and not is_attacking:
		velocity.x = direction * SPEED
		$stairchecker.scale.x = sign(velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animations
	if not is_attacking and not is_hurt:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("Idle")
			else:
				animated_sprite.play("walk")
		else:
			animated_sprite.play("jump")

	move_and_slide()

	# Auto stair climbing
	if direction and velocity.y >= 0.0:
		var next_to_stair = not $stairchecker/top_check.is_colliding() and $stairchecker/st_check.is_colliding()
		$auto_climb.disabled = not next_to_stair


# ------------------------
# ATTACK SYSTEM
# ------------------------
func perform_attack() -> void:
	is_attacking = true
	animated_sprite.play("attack")
	attack_timer.start()


func _on_frame_changed() -> void:
	if animated_sprite.animation == "attack" and animated_sprite.frame == 1: # Frame 1 check
		for body in attack_area.get_overlapping_bodies():
			if body is Orc and body.has_method("take_damage"):
				body.take_damage(1)


func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false


func _on_attack_timer_timeout() -> void:
	is_attacking = false


# ------------------------
# DAMAGE SYSTEM
# ------------------------
func take_damage(amount: int) -> void:
	if is_dead or is_hurt:
		return
	health -= amount
	if health > 0:
		is_hurt = true 
		animated_sprite.play("hurt")
		animated_sprite.animation_finished.connect(_on_hurt_animation_finished, CONNECT_ONE_SHOT)
	else:
		die()

func _on_hurt_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		is_hurt = false


# MODIFIED: Death function to stop all processes and connect the scene change
func die() -> void:
	if is_dead: 
		return
	is_dead = true
	velocity = Vector2.ZERO # Stop movement
	
	animated_sprite.play("death")
	
	# Connect the signal only once
	if not animated_sprite.animation_finished.is_connected(_on_death_animation_finished):
		animated_sprite.animation_finished.connect(_on_death_animation_finished, CONNECT_ONE_SHOT)
	
	# Stop ALL updates (physics and regular) to prevent errors during cleanup
	set_process(false) 
	set_physics_process(false) 


# MODIFIED: Scene change handler uses call_deferred for safety and the correct path
func _on_death_animation_finished() -> void:
	if animated_sprite.animation == "death":
		# The correct path provided by the user
		var game_over_scene_path = "res://scenes/GameOver.tscn" 
		
		# Use call_deferred to safely change the scene after the frame is done
		get_tree().call_deferred("change_scene_to_file", game_over_scene_path)
