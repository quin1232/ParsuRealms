extends StairsCharacterBody3D

@export_category("Player Parameters")
@export var SPEED: float = 10
@export var JUMP_VELOCITY := 12.0		# Player's jump velocity.
@export var CAMERA_SMOOTHING := 18.0	# Amount of camera smoothing.
@export var MOUSE_SENSITIVITY := 0.4	# Mouse movement sensitivity.

@export_category("Components")
@export var CAMERA_NECK: Node3D
@export var CAMERA_HEAD: Node3D
@export var PLAYER_CAMERA: Camera3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	# Call movement in parent
	super(delta)

	# Horizontal Movement
	#var _input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var _input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var _wish_dir := (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	velocity.x = _wish_dir.x * SPEED
	velocity.z = _wish_dir.z * SPEED

	# Gravity
	if not is_grounded:
		velocity.y -= gravity * delta

	# Handle Jump
	#if character.is_grounded and Input.is_action_pressed("move_jump"):
	if is_grounded and Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# Smooth camera
	_camera_smooth_jitter.call_deferred(delta)


func _camera_smooth_jitter(delta):
	CAMERA_HEAD.global_position.x = CAMERA_NECK.global_position.x
	CAMERA_HEAD.global_position.y = lerpf(CAMERA_HEAD.global_position.y, CAMERA_NECK.global_position.y, CAMERA_SMOOTHING * delta)
	CAMERA_HEAD.global_position.z = CAMERA_NECK.global_position.z

	# Limit how far camera can lag behind its desired position
	CAMERA_HEAD.global_position.y = clampf(CAMERA_HEAD.global_position.y,
										CAMERA_NECK.global_position.y - 1,
										CAMERA_NECK.global_position.y + 1)


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
	rotate_y(y_rotation)
	CAMERA_HEAD.rotate_y(y_rotation)
	PLAYER_CAMERA.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
	PLAYER_CAMERA.rotation.x = clamp(PLAYER_CAMERA.rotation.x, deg_to_rad(-90), deg_to_rad(90))
