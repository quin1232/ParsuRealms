extends TextureButton

@export var email_input: LineEdit
@export var password_input : LineEdit
@export var confirm_password_input : LineEdit
@export var loginPanel: Panel

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
	
	if password != confirm_password:
		_show_message("Passwords do not match")
		return
	
	if password.length() < 6:
		_show_message("Password must be at least 6 characters")
		return
	
	# Extract username from email (before @)
	var username = email.split("@")[0]
	
	# Disable button to prevent multiple clicks
	self.disabled = true
	_show_message("Creating account...")
	
	# Call database manager
	var result = await Database.db_manager.signup(email, password, username)
	
	self.disabled = false
	
	if result["success"]:
		_show_message("Registration successful! Please check your email.")
		# Clear fields
		email_input.text = ""
		password_input.text = ""
		confirm_password_input.text = ""
		
		# Switch back to login panel
		await get_tree().create_timer(2.0).timeout
		$"..".hide()
		loginPanel.show()
	else:
		var error = result.get("error", "Unknown error")
		_show_message("Registration failed: " + error)
		password_input.text = ""
		confirm_password_input.text = ""

func _show_message(message: String):
	print(message)
	# You can add a Label node to display messages to the user
	# For example: $"../../MessageLabel".text = message
