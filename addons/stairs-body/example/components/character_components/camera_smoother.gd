extends Node

@export var character: StairsCharacterBody3D

@export var CAMERA_NECK: Node3D
@export var CAMERA_HEAD: Node3D
@export var PLAYER_CAMERA: Camera3D
@export var CAMERA_SMOOTHING := 18.0	# Amount of camera smoothing.
@export var MOUSE_SENSITIVITY := 0.4	# Mouse movement sensitivity.

func _ready():
	# Capture mouse on start
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



# Function: Handle defined inputs
func _input(event):
	# Handle ESC input
	#if event.is_action_pressed("mouse_toggle"):
	if event.is_action_pressed("ui_cancel"):
		_toggle_mouse_mode()

	# Handle Mouse input
	if event is InputEventMouseMotion and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		_camera_input(event)

# Function: Handle mouse mode toggling
func _toggle_mouse_mode():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Function: Handle camera input
func _camera_input(event):
	var y_rotation = deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY)
	character.rotate_y(y_rotation)
	CAMERA_HEAD.rotate_y(y_rotation)
	PLAYER_CAMERA.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
	PLAYER_CAMERA.rotation.x = clamp(PLAYER_CAMERA.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta: float) -> void:
	_camera_smooth_jitter.call_deferred(delta)

func _camera_smooth_jitter(delta):
	CAMERA_HEAD.global_position.x = CAMERA_NECK.global_position.x
	CAMERA_HEAD.global_position.y = lerpf(CAMERA_HEAD.global_position.y, CAMERA_NECK.global_position.y, CAMERA_SMOOTHING * delta)
	CAMERA_HEAD.global_position.z = CAMERA_NECK.global_position.z

	# Limit how far camera can lag behind its desired position
	CAMERA_HEAD.global_position.y = clampf(CAMERA_HEAD.global_position.y,
										CAMERA_NECK.global_position.y - 1,
										CAMERA_NECK.global_position.y + 1)
