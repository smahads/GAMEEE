extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: Area2D = $AnimatedSprite2D/Vision
@onready var vision_shape: CollisionShape2D = $AnimatedSprite2D/Vision/Vision_shape
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var alert : bool = false
var player : Player 
func _ready() -> void:
	animation_player.seek(randf_range(0, animation_player.current_animation_length))
	vision_shape.shape.radius = 100
	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)



		
		
func change_direction() -> void:
	if position.x - player.position.x > 0:
		animated_sprite.flip_h = false
	elif position.x - player.position.x < 0:
		animated_sprite.flip_h = true

func _physics_process(_delta: float) -> void:
	if alert == true:
		change_direction()


		
func _on_vision_body_entered(body):
	if body is Player:
		alert = true
		player = body
		
		
func _on_vision_body_exited(body):
	if body is Player:
		alert = false
		player = null
