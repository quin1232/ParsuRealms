extends Button

@export_file("res://Scene/COED.tscn") var scene_path: String

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if scene_path != "":
		get_tree().reload_current_scene()
	else:
		push_error("No scene path assigned on %s" % name)
	Global.CEDfinish = false
