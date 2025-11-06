extends Button

func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	$"../../Questcomplete/Node/QuestComplete".play()
	$"..".hide()
	$"../../Questcomplete".show()
	$"../../PlayerTemplate/Quest".hide()
	Global.CEDfinish = true
