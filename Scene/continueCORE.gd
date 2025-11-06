extends Button

func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	$"../../../PlayerTemplate/SoundEffecs/QuestComplete".play()
	$"../../../questcom".show()
	$"../..".hide()
