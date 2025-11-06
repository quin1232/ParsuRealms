extends Node

@export var character: StairsCharacterBody3D
@export var JUMP_VELOCITY := 12.0		# Player's jump velocity.

func _physics_process(delta: float) -> void:
	# Handle Jump
	#if character.is_grounded and Input.is_action_pressed("move_jump"):
	if character.is_grounded and Input.is_action_pressed("ui_accept"):
		character.velocity.y = JUMP_VELOCITY
