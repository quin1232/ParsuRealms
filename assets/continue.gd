extends Button

func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	$"../../Questcomplete/Node/QuestComplete".play()
	$"..".hide()
	$"../../Questcomplete".show()
	$"../../PlayerTemplate/Quest".hide()
	# Save quest completion to database
	await Global.complete_quest("CED")
