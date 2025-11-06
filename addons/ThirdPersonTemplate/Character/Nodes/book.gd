extends TextureButton

@export var book: Node
@export var hide_nodes: Array[Node] = []  # nodes to hide/show on toggle

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Toggle book visibility
	book.visible = not book.visible
	$"../../../SoundEffecs/Click".play()

	# Toggle visibility of all nodes in the array
	for node in hide_nodes:
		if node:
			node.visible = not node.visible
