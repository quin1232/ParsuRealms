extends Area3D

@onready var panel: Control = $"../Win"
@onready var allowed_body: VehicleBody3D = $"../car"

func _on_body_entered(body: Node3D) -> void:
	if allowed_body and body != allowed_body:
		return
	panel.visible = true
	panel.show_win_message()
	allowed_body.set_physics_process(false)
	$"../car/Control".hide()
	$"../PlayerTemplate/CanvasLayer/exit".hide()
