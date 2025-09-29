extends Node2D

# ----------------------------------------------------
# EXPORTED VARIABLES (Set these in the Inspector)
# ----------------------------------------------------

# Set the path for the destination screen when the player hits the cage.
# IMPORTANT: This single variable will define the destination.
@export var cage_destination_scene_path: String = "res://scenes/enddd.tscn"

# ----------------------------------------------------
# ONREADY VARIABLES
# ----------------------------------------------------

# Reference ONLY to the CageTrigger Area2D node
@onready var cage_trigger_area: Area2D = $CageTrigger 
# NOTE: The door_area and key_node variables are REMOVED entirely.

func _ready() -> void:
	# Connect the CageTrigger's signal immediately.
	if is_instance_valid(cage_trigger_area):
		cage_trigger_area.body_entered.connect(_on_cage_trigger_body_entered)
	else:
		# CRITICAL: If this prints, your node name is wrong in the scene!
		print("ERROR: CageTrigger Area2D not found at path: ", cage_trigger_area.get_path())


# ----------------------------------------------------
# COLLISION HANDLER
# ----------------------------------------------------

# Function to handle collision with the CageTrigger
func _on_cage_trigger_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the Player
	if body is Player:
		# We use the exported path directly
		if ResourceLoader.exists(cage_destination_scene_path):
			get_tree().change_scene_to_file(cage_destination_scene_path)
		else:
			print("ERROR: Destination scene not found at path: ", cage_destination_scene_path)
