extends TextureButton

# This function runs when you press the button down. 
# It must be connected to the 'pressed()' signal.
func _on_pressed() -> void:
	# Force the "ui_right" action (Steering Right) to be active
	Input.action_press("ui_down")
	print("Button pressed: Steering Right Active")

# This function runs when you let go of the button. 
# It must be connected to the 'released()' signal.
func _on_released() -> void:
	# Force the "ui_right" action (Steering Right) to be inactive
	Input.action_release("ui_down")
	print("Button released: Steering Right Inactive")
