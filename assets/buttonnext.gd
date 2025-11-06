extends Button

func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	$"../Panel/Label".hide()
	$"../Panel/Page 3".show()
	$"../Panel/Page 4".show()
	$"../Panel/Page 1".hide()
	$"../Panel/Page 2".hide()
	$"../Panel/TextureRect2".hide()
	$"../prev".show()
	$"../continue".show()
	hide()
	Global.CEDfinish = true
	
	
