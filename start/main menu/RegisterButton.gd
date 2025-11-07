extends TextureButton

@export var email_input: LineEdit
@export var password_input : LineEdit
@export var confirm_password_input : LineEdit
@export var loginPanel: Panel
@export var regester_message: Label

func _ready() -> void:
	self.pressed.connect(_on_register_pressed)

func _on_register_pressed() -> void:
	var email = email_input.text.strip_edges()
	var password = password_input.text
	var confirm_password = confirm_password_input.text
	
	# Validation
	if email.is_empty() or password.is_empty() or confirm_password.is_empty():
		_show_message("Please fill all fields")
		return

	# Email format validation
	var email_regex = RegEx.new()
	email_regex.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
	if not email_regex.search(email):
		_show_message("Invalid email address")
		return

	if password != confirm_password:
		_show_message("Passwords do not match")
		return

	if password.length() < 6:
		_show_message("Password must be at least 6 characters")
		return
	
	# Extract username from email (before @)
	var username = email.split("@")[0]

	# No pre-check for email existence; rely on signup error

	# Disable button to prevent multiple clicks
	self.disabled = true
	_show_message("Creating account...")

	# Call database manager
	var result = await Database.db_manager.signup(email, password, username)

	self.disabled = false

	if result["success"]:
		_show_message("Registration successful! \nCheck your inbox to confirm your account.")
		if regester_message:
			regester_message.add_theme_color_override("font_color", Color(0, 0.7, 0)) # Green
		# Clear fields
		email_input.text = ""
		password_input.text = ""
		confirm_password_input.text = ""
		await get_tree().create_timer(5.0).timeout
		self.get_parent().hide()
		loginPanel.show()
	# No automatic panel switch after registration
	else:
		var error = result.get("error", "Unknown error")
		var error_lower = error.to_lower()
		if error_lower.find("already registered") != -1 or error_lower.find("already exists") != -1 or error_lower.find("email exists") != -1:
			_show_message("Email is already registered.")
			if regester_message:
				regester_message.add_theme_color_override("font_color", Color(1.0, 0.4078, 0.3372)) # HEX #ff6856
		else:
			_show_message("Registration failed: " + error)
			if regester_message:
				regester_message.add_theme_color_override("font_color", Color(1.0, 0.4078, 0.3372)) # HEX #ff6856
		password_input.text = ""
		confirm_password_input.text = ""

func _show_message(message: String):
	print(message)
	if regester_message:
		regester_message.text = message
		regester_message.visible = true
