extends Area3D

@export var allowed_body: Node3D
@export var trigger_once: bool = true
@export var NPCCBM: AnimationPlayer
@export var btnTalk: TextureButton

var _fired: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited) # connect this signal too

func _on_body_entered(body: Node3D) -> void:
	if _fired:
		return
	if allowed_body and body != allowed_body:
		return
	
	btnTalk.visible = true
	
	if trigger_once:
		_fired = true
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)

func _on_body_exited(body: Node3D) -> void:
	if allowed_body and body != allowed_body:
		return
	btnTalk.visible = false
