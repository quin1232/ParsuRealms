extends TextureButton

func _on_pressed() -> void:
	# Connected to the 'pressed()' signal
	Input.action_press("ui_right")

func _on_released() -> void:
	# This function is now connected to the 'button_up()' signal
	Input.action_release("ui_right")

# Note: The 'button_up()' signal now calls '_on_released'
