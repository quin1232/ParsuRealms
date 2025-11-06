extends TextureButton

@onready var register_panel = $"../../login2"
@onready var login_panel = $"../../login"

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	register_panel.hide()
	login_panel.show()
