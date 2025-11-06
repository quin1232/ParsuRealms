extends TextureButton

func _ready() -> void:
	self.pressed.connect(_on_guest_pressed)

func _on_guest_pressed() -> void:
	# Set guest mode in Global
	Global.is_guest = true
	Global.is_logged_in = false
	Global.player_username = "Guest"
	Global.player_email = ""
	
	print("Logged in as Guest")
	
	# Change scene to main game
	get_tree().change_scene_to_file("res://main.tscn")  # Change to your main game scene
