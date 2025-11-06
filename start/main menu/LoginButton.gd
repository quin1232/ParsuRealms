extends TextureButton

@export var email_input: LineEdit
@export var password_input: LineEdit


func _on_login_pressed() -> void:
	print("press")
	var email = email_input.text.strip_edges()
	var password = password_input.text
	
	if email.is_empty() or password.is_empty():
		_show_message("Please enter email and password")
		return
	
	# Disable button to prevent multiple clicks
	self.disabled = true
	_show_message("Logging in...")
	
	# Call database manager
	var result = await Database.db_manager.login(email, password)
	
	self.disabled = false
	
	if result["success"]:
		_show_message("Login successful!")
		# Store username if available
		var user_data = result.get("data", {}).get("user", {})
		var username = user_data.get("user_metadata", {}).get("username", "Player")
		
		# Save to Global autoload
		Global.player_username = username
		Global.player_email = email
		Global.is_logged_in = true
		Global.is_guest = false
		
		print("Welcome, " + username + "!")
		
		# Change scene or continue game
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Map/Map.tscn")  # Change to your main game scene
	else:
		var error = result.get("error", "Unknown error")
		_show_message("Login failed: " + error)
		password_input.text = ""  # Clear password on failed login

func _show_message(message: String):
	print(message)
	# You can add a Label node to display messages to the user
	# For example: $"../../../MessageLabel".text = message
