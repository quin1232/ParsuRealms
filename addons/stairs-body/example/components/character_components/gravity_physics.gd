extends Node

@export var character: StairsCharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	if not character.is_grounded:
		character.velocity.y -= gravity * delta
