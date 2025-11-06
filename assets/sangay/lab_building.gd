extends Area3D

@export var allowed_body: Node3D
@export var trigger_once: bool = true
var _fired := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _fired:
		return
	if allowed_body and body != allowed_body:
		return

	Dialogic.VAR.CBMArrived = true
	Dialogic.start("sangay", "LabArrived")
	allowed_body.set_physics_process(false)
	allowed_body.play_idle(true)
	


	if trigger_once:
		_fired = true
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
