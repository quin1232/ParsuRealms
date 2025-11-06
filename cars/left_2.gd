extends TextureButton

# This function runs when you press the button down
func _on_pressed() -> void:
	# 1. Force the "ui_up" action to be considered "pressed"
	Input.action_press("ui_left")
	print("Forward button pressed! (Car should start moving)")

func _on_released() -> void:
	# Force the "ui_right" action (Steering Right) to be inactive
	Input.action_release("ui_left")
	print("Button released: Steering Right Inactive")
