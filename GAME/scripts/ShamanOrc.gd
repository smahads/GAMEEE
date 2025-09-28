extends Orc 
class_name ShamanOrc 

# Set the path to the victory/next level scene in the Inspector
@export var victory_scene_path: String = "res://scenes/end_choice.tscn" 

@export var cast_range: float = 200.0
@export var spell_damage: int = 5 

# ... (rest of your unique Shaman functions, like _chase_or_attack_player and _cast_spell)

# ---------------------------------------------------------------------
# MODIFIED: Override the _die function to change the scene instead of queue_free()
# ---------------------------------------------------------------------
func _die() -> void:
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	
	# 1. Start the death animation and disable hitboxes (Standard Orc steps)
	sprite.play("death")
	$CollisionShape2D.disabled = true
	vision.monitoring = false
	attack_area.monitoring = false

	# 2. Connect the animation finish signal to the scene change
	sprite.animation_finished.connect(_on_death_animation_finished, CONNECT_ONE_SHOT)

# NEW: Handler function to safely change the scene
func _on_death_animation_finished() -> void:
	if sprite.animation == "death":
		# Use call_deferred to safely transition to the final scene
		if victory_scene_path:
			get_tree().call_deferred("change_scene_to_file", victory_scene_path)
		# We DO NOT call queue_free() here, as changing the scene handles cleanup.
