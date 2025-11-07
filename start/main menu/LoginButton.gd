extends TextureButton


@export var email_input: LineEdit
@export var password_input: LineEdit
@export var error_label: Label


func _on_login_pressed() -> void:
	print("press")
	var email = email_input.text.strip_edges()
	var password = password_input.text

	# Only clear error label if a new error or success is about to be shown
	var show_error = false

	if email.is_empty() or password.is_empty():
		show_error = true
		_show_message("Please enter email and password", true)
		email_input.text = ""
		password_input.text = ""
		return

	# Basic email format validation
	var email_regex = RegEx.new()
	email_regex.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
	if not email_regex.search(email):
		show_error = true
		_show_message("Invalid email address", true)
		email_input.text = ""
		password_input.text = ""
		return

	# Disable button to prevent multiple clicks
	self.disabled = true
	# Only show 'Logging in...' if not currently showing an error
	if not show_error:
		_show_message("Logging in...", false, false)

	# Call database manager
	var result = await Database.db_manager.login(email, password)

	self.disabled = false

	if result["success"]:
		_show_message("Login successful!", false)
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
		var error_lower = error.to_lower()
		if error_lower.find("invalid email") != -1:
			_show_message("Invalid email address", true)
		elif error_lower.find("wrong email") != -1 or error_lower.find("incorrect email") != -1:
			_show_message("Wrong email.", true)
		elif error_lower.find("wrong password") != -1 or error_lower.find("incorrect password") != -1:
			_show_message("Wrong password.", true)
		elif error_lower.find("invalid") != -1 or error_lower.find("wrong") != -1 or error_lower.find("incorrect") != -1:
			_show_message("Wrong email or password.", true)
		else:
			_show_message("Login failed: " + error, true)
		email_input.text = ""
		password_input.text = ""

func _show_message(message: String, is_error: bool = false, clear_error: bool = true):
	print(message)
	if error_label:
		# Only clear error label for success/info, not for info if error is currently displayed
		if is_error or clear_error:
			error_label.text = message
			error_label.visible = true
			if is_error:
				error_label.add_theme_color_override("font_color", Color(1.0, 0.4078, 0.3372)) # HEX #ff6856
				await get_tree().create_timer(2.0).timeout
				error_label.text = ""
			else:
				error_label.add_theme_color_override("font_color", Color(0, 0.7, 0)) # Green
				await get_tree().create_timer(2.0).timeout
				error_label.text = ""
