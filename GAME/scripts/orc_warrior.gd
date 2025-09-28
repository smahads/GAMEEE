extends CharacterBody2D
class_name Orc

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: Area2D = $Vision            # Vision must be a sibling of the sprite (not a child of sprite)
@onready var vision_shape: CollisionShape2D = $Vision/Vision_shape

var player: Node = null
var alert: bool = false

@export var speed := 30.0
@export var gravity := 400.0
@export var left_limit := -100.0   # relative to start_x
@export var right_limit := 100.0   # relative to start_x

var start_x := 0.0
var direction := 1   # used only by patrol

func _ready() -> void:
	start_x = global_position.x
	sprite.play("walk")
	# Connect signals robustly
	vision.connect("body_entered", Callable(self, "_on_vision_body_entered"))
	vision.connect("body_exited", Callable(self, "_on_vision_body_exited"))

	# Debug info (check output in the debugger/console)
	print("--- Orc ready ---")
	print("Vision node:", vision)
	print("Vision monitoring:", vision.monitoring, "monitorable:", vision.monitorable)
	print("Vision collision_layer:", vision.collision_layer, "collision_mask:", vision.collision_mask)
	print("Vision shape disabled:", vision_shape.disabled)
	print("Orc start_x:", start_x)

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# movement decision
	if alert and player:
		_chase_player()
	else:
		_patrol()

	# flip sprite based on actual motion (prevents mid-flip jitter)
	if velocity.x < 0:
		sprite.flip_h = true    # faces left
	elif velocity.x > 0:
		sprite.flip_h = false   # faces right

	move_and_slide()

func _patrol() -> void:
	velocity.x = direction * speed
	# reverse at bounds
	if global_position.x > start_x + right_limit:
		direction = -1
	elif global_position.x < start_x + left_limit:
		direction = 1

func _chase_player() -> void:
	if not player:
		velocity.x = 0
		alert = false
		return
	var left_bound = start_x + left_limit
	var right_bound = start_x + right_limit
	# only chase if player inside patrol zone
	if player.global_position.x >= left_bound and player.global_position.x <= right_bound:
		var to_player = player.global_position.x - global_position.x
		if abs(to_player) < 8:   # close enough -> stop / attack
			velocity.x = 0
			if sprite.animation != "attack":
				sprite.play("attack")
		else:
			if sprite.animation != "walk":
				sprite.play("walk")
			velocity.x = sign(to_player) * speed * 1.5
	else:
		# player left zone: stop chasing, fall back to patrol
		velocity.x = 0
		alert = false
		player = null
		sprite.play("walk")

# Signals (debug prints included)
func _on_vision_body_entered(body: Node) -> void:
	print("Vision body_entered:", body, "name:", body.name, "class:", body.get_class())
	if body.name.to_lower() == "player":   # match lowercase name
		print(" -> player detected")
		player = body
		alert = true
		sprite.play("walk")



func _on_vision_body_exited(body: Node) -> void:
	print("Vision body_exited:", body, "name:", body.name)
	if body.name.to_lower() == "player":
		print(" -> player left vision")
		alert = false
		player = null
		sprite.play("walk")
