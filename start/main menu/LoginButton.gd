extends TextureButton
var _press_tween: Tween

func _pressed_animation():
	if _press_tween:
		_press_tween.kill()
	self.scale = Vector2(1, 1)
	# Set pivot to center for proper scaling
	if has_method("set_pivot_offset"):
		set_pivot_offset(Vector2(size.x / 2, size.y / 2))
	elif "pivot_offset" in self:
		self.pivot_offset = Vector2(size.x / 2, size.y / 2)
	_press_tween = create_tween()
	_press_tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_press_tween.tween_property(self, "scale", Vector2(1, 1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


@export var email_input: LineEdit
@export var password_input: LineEdit
@export var error_label: Label


func _on_login_pressed() -> void:
	print("press")
	_pressed_animation()
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

	# Check for connection errors
	if not result:
		_show_message("No internet connection. Please check your network.", true)
		return
	
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
		
		# Load player's quest progress from database
		_show_message("Loading quest progress...", false, false)
		var load_success = await Global.load_quest_progress_from_db()
		if load_success == false:
			# Quest progress failed to load but continue anyway
			print("Warning: Could not load quest progress (offline or connection issue)")
			_show_message("Offline mode - progress not loaded", false, false)
			await get_tree().create_timer(1.5).timeout
		else:
			print("Quest progress loaded: ", Global.finishQuest, " quests completed")

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
