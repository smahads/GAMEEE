extends CharacterBody2D
class_name Orc

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: Area2D = $Vision
@onready var vision_shape: CollisionShape2D = $Vision/Vision_shape

var player: Node = null
var alert: bool = false
var is_attacking: bool = false
var is_dead: bool = false

@export var speed := 30.0
@export var gravity := 400.0
@export var left_limit := -120.0
@export var right_limit := 120.0
@export var attack_range := 20.0
@export var health := 1   # dies in one hit
@export var attack_damage := 1

var start_x := 0.0
var direction := 1

func _ready() -> void:
	start_x = global_position.x
	sprite.play("walk")

	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)

	# Connect frame signal for attack timing
	sprite.frame_changed.connect(_on_frame_changed)

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

	if abs(to_player) <= attack_range:
		_attack()
	else:
		direction = sign(to_player)
		velocity.x = direction * speed * 1.5
		if sprite.animation != "walk":
			sprite.play("walk")

func _attack() -> void:
	is_attacking = true
	velocity.x = 0
	sprite.play("attack")
	sprite.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished() -> void:
	is_attacking = false
	if alert and player:
		sprite.play("walk")

# --- Damage timing during attack ---
func _on_frame_changed() -> void:
	if sprite.animation == "attack" and sprite.frame == 2:  # <-- adjust to your hit frame
		if player and player.global_position.distance_to(global_position) <= attack_range:
			if player.has_method("take_damage"):
				player.take_damage(attack_damage)

# --- Orc takes damage ---
func take_damage(amount: int) -> void:
	if is_dead: return
	health -= amount
	if health > 0:
		sprite.play("hurt")
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
	sprite.animation_finished.connect(func(): queue_free(), CONNECT_ONE_SHOT)

# --- Vision detection ---
func _on_vision_body_entered(body: Node) -> void:
	if body is Player:  # works if your Player.gd has "class_name Player"
		alert = true
		player = body

func _on_vision_body_exited(body: Node) -> void:
	if body is Player:
		alert = false
		player = null
