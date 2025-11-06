extends Button

func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	$"../../Node/questc".play()
	$"../../completequest".show()
	$"..".hide()
