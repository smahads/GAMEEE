extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the Player class
	if body is Player:
		# Call the new lethal function on the player
		if body.has_method("take_hazard_damage"):
			body.take_hazard_damage()
