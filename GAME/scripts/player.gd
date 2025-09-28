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
var is_hurt: bool = false # NEW: State to manage hurt animation

func _ready() -> void:
	# Reset attack after animation ends
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Damage on specific attack frame
	animated_sprite.frame_changed.connect(_on_frame_changed)
	attack_area.body_entered.connect(_on_attack_area_entered)


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
		print("Attack bodies: ", attack_area.get_overlapping_bodies())
		return # don’t allow movement during attack

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
	if not is_attacking and not is_hurt: # MODIFIED: Check is_hurt
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
	attack_timer.start()# short cooldown


func _on_frame_changed() -> void:
	if animated_sprite.animation == "attack" and animated_sprite.frame == 1:# adjust frame index
		print("Attack frame: ", animated_sprite.frame)
		for body in attack_area.get_overlapping_bodies():
			print("Detected body on frame ", animated_sprite.frame, ": ", body.name)
			# MODIFIED: Check for the Orc type AND confirm the method exists
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
	if is_dead or is_hurt: # NEW: Ignore damage if already dead or hurt
		return
	health -= amount
	if health > 0:
		is_hurt = true # NEW: Set hurt state
		animated_sprite.play("hurt")
		# NEW: Connect to a function to reset the state when the hurt animation finishes
		animated_sprite.animation_finished.connect(_on_hurt_animation_finished, CONNECT_ONE_SHOT)
	else:
		die()

# NEW: Function to reset the hurt state
func _on_hurt_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		is_hurt = false

func die() -> void:
	is_dead = true
	animated_sprite.play("death")
	set_physics_process(false)# stop processing movement


func _on_attack_area_entered(body: Node) -> void:
	print("AttackArea detected: ", body)
# TEMPORARY DEBUG CODE IN Player.gd
