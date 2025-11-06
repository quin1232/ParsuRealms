extends Area3D

@export var allowed_body: Node3D
			  # Only this body can trigger (leave empty to allow anyone)
func _ready() -> void:
	# Signals for enter/exit
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if allowed_body and body != allowed_body:
		return
	if Dialogic.VAR.IsfoundBox == false:
		Dialogic.start("COED","Box")
		allowed_body.set_physics_process(false)
		$"../PlayerTemplate".play_idle(true)
		Dialogic.VAR.IsfoundBox = true
