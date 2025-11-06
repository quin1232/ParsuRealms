extends TextureButton

@export var panel: Node
# adjust the path to your inventory panel node

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	
	panel.visible = not panel.visible
