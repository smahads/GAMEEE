extends CharacterBody2D
class_name Orc

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: Area2D = $Vision
@onready var vision_shape: CollisionShape2D = $Vision/Vision_shape
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var player: Node = null
var alert: bool = false
var is_attacking: bool = false
var is_dead: bool = false

@export var speed := 30.0
@export var gravity := 400.0
@export var left_limit := -120.0
@export var right_limit := 120.0
@export var health := 1
@export var attack_damage := 1
const BASE_ATTACK_OFFSET := 25.0

var start_x := 0.0
var direction := 1

func _ready() -> void:
	start_x = global_position.x
	sprite.play("walk")

	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if alert and player:
		if not is_attacking:
			_chase_or_attack_player()
	else:
		_patrol()

	# Flip sprite
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
	
	 # NEW: FLIP ATTACK AREA POSITION
	if sprite.flip_h:
		# If facing left, move the attack area to the negative offset
		attack_area.position.x = -35-BASE_ATTACK_OFFSET
	else:
		# If facing right, use the positive offset
		attack_area.position.x = BASE_ATTACK_OFFSET- 10
	move_and_slide()

func _patrol() -> void:
	if is_attacking: return
	velocity.x = direction * speed
	if global_position.x > start_x + right_limit:
		direction = -1
	elif global_position.x < start_x + left_limit:
		direction = 1
	if sprite.animation != "walk":
		sprite.play("walk")

func _chase_or_attack_player() -> void:
	if not player: return
	var to_player = player.global_position.x - global_position.x

	if abs(to_player) <= 30: # attack range check (small buffer)
		_attack()
	else:
		direction = sign(to_player)
		velocity.x = direction * speed * 1.5
		if sprite.animation != "walk":
			sprite.play("walk")

# ORC SCRIPT
func _attack() -> void:
	# NEW: Guard clause to prevent starting a new attack while one is in progress
	if is_attacking:
		return

	is_attacking = true
	velocity.x = 0
	sprite.play("attack")
	attack_area.monitoring = true#enable hitbox
	# Ensure the connection is set up to disconnect automatically
	sprite.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished() -> void:
	is_attacking = false
	attack_area.monitoring = false# disable hitbox
	if alert and player:
		sprite.play("walk")

# --- When player is hit ---
func _on_attack_area_entered(body: Node) -> void:
	if body is Player and body.has_method("take_damage"): # Good check already in place
		body.take_damage(attack_damage)

# --- Orc takes damage ---
func take_damage(amount: int) -> void:
	if is_dead: return
	health -= amount
	if health > 0:
		sprite.play("hurt")
		# RECOMMENDED: Use CONNECT_ONE_SHOT for cleaner signal management
		sprite.animation_finished.connect(_on_hurt_finished, CONNECT_ONE_SHOT) 
	else:
		_die()

func _on_hurt_finished() -> void:
	if not is_dead:
		sprite.play("walk")

func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("death")
	$CollisionShape2D.disabled = true
	vision.monitoring = false
	attack_area.monitoring = false
	sprite.animation_finished.connect(func(): queue_free(), CONNECT_ONE_SHOT)

# --- Vision detection ---
func _on_vision_body_entered(body: Node) -> void:
	if body is Player:
		alert = true
		player = body

func _on_vision_body_exited(body: Node) -> void:
	if body is Player:
		alert = false
		player = null
