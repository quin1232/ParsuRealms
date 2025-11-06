extends TextureButton

@export var target_scene: String = "res://Scene/GoaCampus.tscn"

func _ready() -> void:
	# Connect the pressed signal to the handler function
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
		
