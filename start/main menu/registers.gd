extends TextureButton

@onready var register_panel = $"../../../../login2"
@onready var login_panel = $"../../.."

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	login_panel.hide()
	register_panel.show()
	print("press")
