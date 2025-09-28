extends Node2D

# ----------------------------------------------------
# EXPORTED VARIABLES (Set these in the Inspector)
# ----------------------------------------------------

# CRITICAL: Set this to the exact name of your key node in the scene tree for Level 2.
@export var required_key_name: String = "Key" 

# MODIFIED: Set the path for the next level to Level 3.
@export var next_level_path: String = "res://scenes/level_3.tscn"

# ----------------------------------------------------
# ONREADY VARIABLES
# ----------------------------------------------------

# Reference to the Door Area2D node
@onready var door_area: Area2D = $Door 

# ----------------------------------------------------
# INTERNAL STATE
# ----------------------------------------------------

# Will hold a reference to the Key node when the level starts
var key_node: Node = null 

func _ready() -> void:
	# 1. Find the key node by its name when the level starts
	key_node = find_child(required_key_name, true, false)
	
	# 2. Connect the Door's signal to the handler function in this script
	if is_instance_valid(door_area):
		door_area.body_entered.connect(_on_door_area_body_entered)


func _on_door_area_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the player
	if body is Player: 
		
		# Check if the key has been collected (The key node is no longer valid).
		if not is_instance_valid(key_node):
			
			# Key collected! Teleport to the next level (Level 3).
			if next_level_path:
				get_tree().change_scene_to_file(next_level_path)
				
		else:
			# Door is locked. 
			pass
