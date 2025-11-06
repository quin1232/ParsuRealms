extends Button

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	$"../Panel/Page 3".hide()
	$"../Panel/Page 4".hide()
	$"../Panel/Page 1".show()
	$"../Panel/Page 2".show()
	$"../Panel/TextureRect2".show()
	$"../next".show()
	$"../Panel/Label".show()
	hide()
