# Camera.gd (Godot 4.x) — Multiple LookPads, no gui_pick
extends Node3D

# ── Settings ──────────────────────────────────────────────────────────────────
@export var cam_v_max: float = 75.0    # degrees
@export var cam_v_min: float = -55.0   # degrees
@export var h_sensitivity: float = 0.005
@export var v_sensitivity: float = 0.005
@export var h_acceleration: float = 10.0
@export var v_acceleration: float = 10.0

# Optional joystick node (if it exposes a bool property "is_active")
@export var joystick_path: NodePath

# Multiple LookPads: assign any number of Control nodes here
@export var look_pad_paths: Array[NodePath] = []

# ── Cached nodes ──────────────────────────────────────────────────────────────
@onready var joystick: Node = get_node_or_null(joystick_path)
@onready var h_pivot: Node3D = $h
@onready var v_pivot: Node3D = $h/v
@onready var look_pads: Array[Control] = _collect_look_pads()

# ── State ────────────────────────────────────────────────────────────────────
var camrot_h := 0.0    # target yaw (radians)
var camrot_v := 0.0    # target pitch (radians)
var look_enabled := true

var look_finger := -1
var is_looking := false
var mouse_looking := false
var active_look_pad: Control = null

# ── Lifecycle ────────────────────────────────────────────────────────────────
func _ready() -> void:
	_set_capture(true)  # cursor visible; we gate by look_enabled
	camrot_h = h_pivot.rotation.y
	camrot_v = v_pivot.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_set_capture(!look_enabled)

# ── Input ────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if not look_enabled:
		return

	# Touch: press to arm, drag to rotate, release to stop
	if event is InputEventScreenTouch:
		if event.pressed:
			# Optional: if joystick has is_active=true, don't arm look
			if joystick and joystick.get("is_active"):
				return


			var pad := _pick_look_pad(event.position)
			if pad == null:
				return
			look_finger = event.index
			is_looking = true
			active_look_pad = pad
		else:
			if event.index == look_finger:
				is_looking = false
				look_finger = -1
				active_look_pad = null
		return

	if event is InputEventScreenDrag:
		if is_looking and event.index == look_finger and active_look_pad:
			camrot_h += -event.relative.x * h_sensitivity
			camrot_v +=  event.relative.y * v_sensitivity
		return

	# Mouse: rotate only while LMB is held, and only if started in any LookPad
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var pad_m := _pick_look_pad(event.position)
			if pad_m == null:
				mouse_looking = false
				return
			mouse_looking = true
			active_look_pad = pad_m
		else:
			mouse_looking = false
			active_look_pad = null
		return

	if event is InputEventMouseMotion:
		if mouse_looking and active_look_pad:
			camrot_h += -event.relative.x * h_sensitivity
			camrot_v +=  event.relative.y * v_sensitivity
		return

# ── Physics ──────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if not look_enabled:
		return

	# Clamp pitch
	var vmin := deg_to_rad(cam_v_min)
	var vmax := deg_to_rad(cam_v_max)
	camrot_v = clamp(camrot_v, vmin, vmax)

	# Smoothly approach target angles
	h_pivot.rotation.y = lerp_angle(h_pivot.rotation.y, camrot_h, delta * h_acceleration)
	v_pivot.rotation.x = lerp(v_pivot.rotation.x, camrot_v, delta * v_acceleration)

# ── Helpers ──────────────────────────────────────────────────────────────────
func _set_capture(captured: bool) -> void:
	look_enabled = captured
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # keep cursor; mobile-safe

func _collect_look_pads() -> Array[Control]:
	var pads: Array[Control] = []
	for p in look_pad_paths:
		var n := get_node_or_null(p)
		if n is Control:
			var c: Control = n
			c.mouse_filter = Control.MOUSE_FILTER_STOP  # capture touches in pad
			pads.append(c)
	return pads

# Returns the first LookPad whose rect contains the point (or null).
func _pick_look_pad(pos: Vector2) -> Control:
	if look_pads.is_empty():
		return null
	for pad in look_pads:
		if pad.visible and pad.get_global_rect().has_point(pos):
			return pad
	return null

# Optional external control
func pause_look() -> void:
	look_enabled = false

func resume_look() -> void:
	look_enabled = true
