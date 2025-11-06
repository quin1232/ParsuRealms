extends Button

@export_file("res://Map/Map.tscn") var scene_path: String

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("No scene path assigned on %s" % name)
