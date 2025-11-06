extends "res://addons/stairs-body/stairs_character_body_3d.gd"  # ← path to the addon script ← path to the addon script

# ───────── Physics process state hook ─────────
func _set_physics_process(enable: bool) -> void:
	set_physics_process(enable)
	if not enable and walking_sound_playing:
		walking_audio.stop()
		walking_sound_playing = false
		print("DEBUG: Walking sound stopped (_set_physics_process)")

# ───────── AnimationTree / State Machine ─────────
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

# ───────── Camera handle ─────────
@onready var cam_h: Node3D = $Camroot/h as Node3D

# ───────── Character mesh (for facing direction) ─────────
@export_node_path("Node3D") var PlayerCharacterMesh: NodePath
@onready var player_mesh: Node3D = (get_node(PlayerCharacterMesh) as Node3D) if PlayerCharacterMesh != NodePath() else ($Character as Node3D)

# ───────── Movement tuning ─────────
@export var gravity: float = 9.8
@export var jump_force: float = 6.0
@export var walk_speed: float = 2.5
@export var run_speed: float = 20.5
@export var angular_acceleration: float = 10.0
@export var acceleration: float = 15.0
@export var jump_windup: float = 0.25  # jump wind-up before lift

# ───────── Ground smoothing (prevents fake InAir on stairs) ─────────
@export var ground_buffer := 0.12        # seconds to remember ground contact
@export var air_speed_threshold := 1.2   # m/s; tiny vertical bumps ignored
var _ground_timer := 0.0
var _jump_lock_frames := 0                # force "not grounded" briefly after jump

# ───────── State ─────────
var is_walking := false
var is_running := false
var direction := Vector3.ZERO
var horizontal_velocity := Vector3.ZERO
var vertical_velocity := 0.0
var movement_speed: float = 0.0

# ───────── Walking Sound ─────────
@onready var walking_audio: AudioStreamPlayer3D = $SoundEffecs/Walking_Run
var walking_sound_playing := false

# Jump flow flags
var _jump_in_progress := false
var _airborne := false
var _was_on_floor := true
var _just_landed := false
var _air_time := 0.0

# Watchdog helpers
var _on_floor_frames := 0
var _landing_force_cooldown := 0

# UI-queued jump request
var _wants_jump := false
func request_jump() -> void:
	_wants_jump = true

# NEW: touch sprint button state (set by HUD)
var _run_pressed := false
func set_run_pressed(v: bool) -> void:
	_run_pressed = v

func _ready() -> void:
	$SoundEffecs/Backgroundmusic.play()
	# Facing init
	direction = Vector3.BACK.rotated(Vector3.UP, cam_h.rotation.y)

	# CharacterBody3D ground settings (still honored by stairs base)
	floor_snap_length = 0.55                      # a bit larger helps on risers
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	up_direction = Vector3.UP
	floor_max_angle = deg_to_rad(46.0)

	# AnimationTree
	animation_tree.active = true
	animation_tree.root_motion_track = NodePath("")  # disables root motion extraction
	playback.start("Idle")

	# Debug: Check walking_audio node assignment
	if walking_audio:
		print("DEBUG: walking_audio node found")
	else:
		print("DEBUG: walking_audio node NOT found")

func _physics_process(delta: float) -> void:
	var was_grounded := _smoothed_grounded()

	# ───────── Gravity ─────────
	if was_grounded and vertical_velocity < 0.0:
		vertical_velocity = -gravity * 0.1
	else:
		vertical_velocity -= gravity * delta

	# ───────── Jump input ─────────
	if (Input.is_action_just_pressed("jump") or _wants_jump):
		_wants_jump = false
		if was_grounded and not _jump_in_progress and not _airborne:
			_start_jump_sequence()

	# ───────── Locomotion input ─────────
	movement_speed = 0.0
	var is_on_floor := _smoothed_grounded()
	if Input.is_action_pressed("forward") \
	or Input.is_action_pressed("backward") \
	or Input.is_action_pressed("left") \
	or Input.is_action_pressed("right"):
		direction = Vector3(
			Input.get_action_strength("left") - Input.get_action_strength("right"),
			0.0,
			Input.get_action_strength("forward") - Input.get_action_strength("backward")
		).rotated(Vector3.UP, cam_h.rotation.y).normalized()
		is_walking = true
		var run_held := Input.is_action_pressed("sprint") or _run_pressed
		if run_held:
			movement_speed = run_speed
			is_running = true
		else:
			movement_speed = walk_speed
			is_running = false

		# Play walking sound if just started walking and on floor
		if is_on_floor:
			if not walking_sound_playing:
				walking_audio.play()
				walking_sound_playing = true
				print("DEBUG: Walking sound started")

			# Continuously update pitch while walking/running
			if is_running:
				walking_audio.pitch_scale = 1.7
				print("DEBUG: Running sound (pitch increased)")
			else:
				walking_audio.pitch_scale = 1.0
				print("DEBUG: Walking sound (normal pitch)")
		else:
			# If not on floor, stop sound
			if walking_sound_playing:
				walking_audio.stop()
				walking_sound_playing = false
				print("DEBUG: Walking sound stopped (air)")
				walking_audio.pitch_scale = 1.0
	else:
		is_walking = false
		is_running = false
		# Stop walking sound when not walking
		if walking_sound_playing:
			walking_audio.stop()
			walking_sound_playing = false
			print("DEBUG: Walking sound stopped")
			walking_audio.pitch_scale = 1.0

	# ───────── Face movement direction ─────────
	if direction.length() > 0.001:
		player_mesh.rotation.y = lerp_angle(
			player_mesh.rotation.y,
			atan2(direction.x, direction.z) - rotation.y,
			delta * angular_acceleration
		)

	# ───────── Horizontal velocity ─────────
	if is_walking:
		horizontal_velocity = horizontal_velocity.lerp(direction * movement_speed, acceleration * delta)
	else:
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, acceleration * delta)

	# ───────── Apply velocity ─────────
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	velocity.y = vertical_velocity

	# IMPORTANT: let the stairs base do step detection/correction this frame
	super(delta)

	# read back vertical component after parent processed movement
	vertical_velocity = velocity.y

	# ───────── Floor sample AFTER movement (smoothed) ─────────
	var on_floor := _smoothed_grounded()

	# Air/Floor bookkeeping
	if on_floor:
		_air_time = 0.0
		_on_floor_frames += 1
	else:
		_air_time += delta
		_on_floor_frames = 0

	# ───────── Landing detection ─────────
	_just_landed = false
	var just_landed := (on_floor and not _was_on_floor) or (on_floor and _airborne)
	if just_landed:
		_airborne = false
		_jump_in_progress = false
		_just_landed = true
		_landing_force_cooldown = 6
		playback.travel("Landing")

	_was_on_floor = on_floor

	# ───────── Conditions for transitions ─────────
	animation_tree["parameters/conditions/IsOnFloor"]    = on_floor
	animation_tree["parameters/conditions/IsInAir"]      = not on_floor
	animation_tree["parameters/conditions/IsWalking"]    = is_walking
	animation_tree["parameters/conditions/IsNotWalking"] = not is_walking
	animation_tree["parameters/conditions/IsRunning"]    = is_running
	animation_tree["parameters/conditions/IsNotRunning"] = not is_running
	animation_tree["parameters/conditions/IsJumpingUp"]  = _jump_in_progress
	animation_tree["parameters/conditions/IsLanding"]    = _just_landed

	if _landing_force_cooldown > 0:
		_landing_force_cooldown -= 1
	elif on_floor:
		var current := playback.get_current_node()
		if current == "OnAir" and _on_floor_frames >= 2:
			playback.travel("Landing")
			animation_tree["parameters/conditions/IsLanding"] = true

	# Decrement jump lock
	if _jump_lock_frames > 0:
		_jump_lock_frames -= 1

# ───────── Jump sequence ─────────
func _start_jump_sequence() -> void:
	_jump_in_progress = true
	_airborne = false
	animation_tree["parameters/conditions/IsJumpingUp"] = true
	playback.travel("JumpingUp")

	await get_tree().create_timer(jump_windup).timeout

	if _smoothed_grounded():
		# vertical impulse
		vertical_velocity = jump_force
		velocity.y = vertical_velocity
		# brief "ignore ground" so steps don't cancel jump immediately
		_jump_lock_frames = 2
		_ground_timer = 0.0

	_jump_in_progress = false
	animation_tree["parameters/conditions/IsJumpingUp"] = false
	_airborne = true
	playback.travel("OnAir")

# ───────── SAVE HELPERS ─────────
func save_spawn_now() -> void:
	Global.set_player(global_transform)

func _exit_tree() -> void:
	Global.set_player(global_transform)
	# Stop walking sound if physics process is disabled or node exits
	if walking_sound_playing:
		walking_audio.stop()
		walking_sound_playing = false
		print("DEBUG: Walking sound stopped (_exit_tree)")

# ───────── Animation helper ─────────
func play_idle(force: bool = false) -> void:
	var safe_to_idle := _smoothed_grounded() and not _jump_in_progress and not _airborne and _landing_force_cooldown <= 0
	if not force and not safe_to_idle:
		return

	is_walking = false
	is_running = false
	# Stop walking sound when idle
	if walking_sound_playing:
		walking_audio.stop()
		walking_sound_playing = false
		walking_audio.pitch_scale = 1.0
		print("DEBUG: Walking sound stopped (idle)")

	animation_tree["parameters/conditions/IsOnFloor"]    = true
	animation_tree["parameters/conditions/IsInAir"]      = false
	animation_tree["parameters/conditions/IsWalking"]    = false
	animation_tree["parameters/conditions/IsNotWalking"] = true
	animation_tree["parameters/conditions/IsRunning"]    = false
	animation_tree["parameters/conditions/IsNotRunning"] = true
	animation_tree["parameters/conditions/IsJumpingUp"]  = false
	animation_tree["parameters/conditions/IsLanding"]    = false

	if playback.get_current_node() != "Idle":
		playback.travel("Idle")
		$SoundEffecs/Arrived.play()
# ───────── Grounded smoother ─────────
func _smoothed_grounded() -> bool:
	# If we just jumped, force "not grounded" briefly to avoid canceling the jump
	if _jump_lock_frames > 0:
		return false

	var on_floor_raw := is_on_floor()

	# Maintain short memory of ground contact
	if on_floor_raw:
		_ground_timer = ground_buffer
	else:
		_ground_timer = max(0.0, _ground_timer - get_physics_process_delta_time())

	# Consider grounded if recently grounded AND vertical speed is tiny
	var tiny_y := absf(velocity.y) < air_speed_threshold
	return on_floor_raw or (_ground_timer > 0.0 and tiny_y)
