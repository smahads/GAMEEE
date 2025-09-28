extends Node2D

# ----------------------------------------------------
# EXPORTED VARIABLES (Set these in the Inspector)
# ----------------------------------------------------

# CRITICAL: Set this to the exact name of your key node in the scene tree for Level 4.
@export var required_key_name: String = "Key" 

# Set the path for the next level (or victory/ending screen).
@export var next_level_path: String = "res://scenes/victory_screen.tscn" # Example: Change to your desired screen

# Reference to the Door Area2D node (if you still have a door)
@onready var door_area: Area2D = $Door # Adjust path if your door is named differently

# NEW: Reference to the CageTrigger Area2D node
@onready var cage_trigger_area: Area2D = $CageTrigger # Ensure this path is correct!

# ----------------------------------------------------
# INTERNAL STATE
# ----------------------------------------------------

var key_node: Node = null 

func _ready() -> void:
	# Key and Door setup (if applicable for Level 4)
	key_node = find_child(required_key_name, true, false)
	if is_instance_valid(door_area):
		door_area.body_entered.connect(_on_door_area_body_entered)
	
	# NEW: Connect the CageTrigger's signal
	if is_instance_valid(cage_trigger_area):
		cage_trigger_area.body_entered.connect(_on_cage_trigger_body_entered)
	else:
		print("ERROR: CageTrigger Area2D not found! Check the @onready path.")


func _on_door_area_body_entered(body: Node2D) -> void:
	if body is Player: 
		if not is_instance_valid(key_node):
			if next_level_path:
				get_tree().change_scene_to_file(next_level_path)
		else:
			pass

# NEW: Function to handle collision with the CageTrigger
func _on_cage_trigger_body_entered(body: Node2D) -> void:
	if body is Player:
		# Define the scene to switch to when the player touches the cage
		var cage_destination_scene_path = "res://scenes/boss_room.tscn" # <--- CUSTOMIZE THIS PATH
		
		# Ensure the path is valid before attempting to change
		if ResourceLoader.exists(cage_destination_scene_path):
			get_tree().change_scene_to_file(cage_destination_scene_path)
		else:
			print("ERROR: Cage destination scene not found at path: ", cage_destination_scene_path)
