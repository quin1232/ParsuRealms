extends TextureButton


func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	$"..".hide()
	$"../../login2".show()
