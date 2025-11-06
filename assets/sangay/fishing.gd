extends Area3D

@export var allowed_body : CharacterBody3D
@export var camspring : SpringArm3D
@export var rod : Node3D

var target_spring_length : float = -4.0
const SMOOTHING_SPEED : float = 5.0

func _ready():
	camspring.spring_length = target_spring_length
func _process(delta: float) -> void:
	camspring.spring_length = lerp(camspring.spring_length, target_spring_length, delta * SMOOTHING_SPEED)


func _on_body_entered(body: Node3D) -> void:
	if Dialogic.VAR.CollectComplete == false:
		return
	if allowed_body != body:
		return
	$"../../FishingMinigame".show()
	target_spring_length = 0.0
	rod.show()


func _on_body_exited(body: Node3D) -> void:
	if allowed_body != body:
		return
	$"../../FishingMinigame".hide()
	target_spring_length = -4.0
	rod.hide()
