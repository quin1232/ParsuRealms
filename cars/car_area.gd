extends Area3D

@export var allowed_body: Node3D
@export_node_path("TextureButton") var button_path
@onready var _btn: TextureButton = get_node_or_null(button_path)

func _ready() -> void:
	# Signals for enter/exit
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if _btn:
		_btn.visible = false
		_btn.disabled = true

func _on_body_entered(body: Node) -> void:
	if Dialogic.VAR.carFixed != true:
		return

	if allowed_body and body != allowed_body:
		return
	_btn.visible = true
	_btn.disabled = false

func _on_body_exited(body: Node) -> void:

	if allowed_body and body != allowed_body:
		return
		
	if _btn:
		_btn.visible = false
		_btn.disabled = true
