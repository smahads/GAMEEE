extends Area2D
class_name Key

func _ready() -> void:
	# Connect the body_entered signal to our handler function
	body_entered.connect(_on_body_entered)
	
	# Ensure monitoring is ON for collision detection
	set_monitoring(true)

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the Player class
	if body is Player:
		# 1. Stop monitoring to prevent double-calls
		set_monitoring(false)
		
		# 2. Remove the key from the scene (This is the "collected" status)
		queue_free()
