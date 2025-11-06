extends Area3D

@export var allowed_body: Node3D
@export var trigger_once: bool = true
@export var teacher: AnimationPlayer
@export var btnTalk: TextureButton

var _fired := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
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
	btnTalk.visible = false
	
