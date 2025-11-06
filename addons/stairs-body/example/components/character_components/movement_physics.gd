extends Node

@export var character: StairsCharacterBody3D

@export var speed: float = 10

func _physics_process(delta: float) -> void:
	#var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var wish_dir := (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	character.velocity.x = wish_dir.x * speed
	character.velocity.z = wish_dir.z * speed
