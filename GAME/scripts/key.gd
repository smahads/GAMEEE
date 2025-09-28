extends Area2D
class_name KeyItem

# IMPORTANT: Adjust this path if the Button is not a direct sibling of the Key Item's parent.
# This assumes the key item and the button are both children of the main scene root.
@onready var action_button: Button = get_tree().root.get_node("YourMainSceneName/Action_Button") 
# Replace "YourMainSceneName" with the actual name of your root node (e.g., "World")
# and "Action_Button" with the actual name of your button node.

func _ready() -> void:
	# Connect to the signal that detects when a body enters the Area2D
	body_entered.connect(_on_body_entered)
	
	# Simple check to make sure the button was found in the scene
	if not is_instance_valid(action_button):
		print("ERROR: KeyItem failed to find the Action_Button. Check the @onready path.")

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding body is the Player (using its class_name)
	if body is Player:
		# 1. Show the button
		if is_instance_valid(action_button):
			action_button.show()
			
		# 2. Prevent further collisions/cleanup
		set_monitoring(false)
		
		# 3. Remove the key item from the scene
		queue_free()
