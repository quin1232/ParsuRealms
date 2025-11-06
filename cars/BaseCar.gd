extends VehicleBody3D

@export var STEER_SPEED: float = 1.5
@export var STEER_LIMIT: float = 0.6
@export var engine_force_value: float = 35.0

# If GAS makes you go backward, flip this to -1.0
@export var FORWARD_SIGN: float = 1.0
# If RIGHT turns left (or vice-versa), flip this to -1.0
@export var STEER_SIGN: float = 1.0

@export_node_path("BaseButton") var btn_left_path: NodePath
@export_node_path("BaseButton") var btn_right_path: NodePath
@export_node_path("BaseButton") var btn_gas_path: NodePath
@export_node_path("BaseButton") var btn_reverse_path: NodePath   # ⬅ Reverse only, no brake

@onready var _btn_left:   BaseButton = _get_btn(btn_left_path,   "Control/left2")
@onready var _btn_right:  BaseButton = _get_btn(btn_right_path,  "Control/right")
@onready var _btn_gas:    BaseButton = _get_btn(btn_gas_path,    "Control/gas")
@onready var _btn_reverse: BaseButton = _get_btn(btn_reverse_path, "Control/reverse")

var steer_target: float = 0.0

func _get_btn(path: NodePath, fallback: String) -> BaseButton:
	if path != NodePath("") and has_node(path):
		return get_node(path)
	if has_node(fallback):
		return get_node(fallback)
	return null

func _ready() -> void:
	if not _btn_gas:
		push_warning("Gas button not found at Control/gas (or exported path).")
	if not _btn_reverse:
		push_warning("Reverse button not found at Control/reverse (or exported path).")

func _physics_process(delta: float) -> void:
	# Forward is -Z in Godot
	var fwd: Vector3 = -transform.basis.z
	var abs_speed := linear_velocity.length()
	var speed_kph := abs_speed * Engine.get_frames_per_second() * delta * 3.8

	if has_node("Control/speed"):
		$Control/speed.text = str(round(speed_kph)) + "  KMPH"

	# ---- POLL BUTTONS ----
	var ui_left_btn  := _btn_left  != null and _btn_left.button_pressed
	var ui_right_btn := _btn_right != null and _btn_right.button_pressed
	var ui_gas_btn   := _btn_gas   != null and _btn_gas.button_pressed
	var ui_rev_btn   := _btn_reverse != null and _btn_reverse.button_pressed

	# ---- MERGE INPUTS ----
	var want_left  := Input.is_action_pressed("ui_left")  or ui_left_btn
	var want_right := Input.is_action_pressed("ui_right") or ui_right_btn
	var want_gas   := Input.is_action_pressed("ui_up")    or ui_gas_btn
	var want_rev   := Input.is_action_pressed("ui_down")  or ui_rev_btn

	# ---- STEERING ----
	var steer_input := 0.0
	if want_left:  steer_input += 1.0
	if want_right: steer_input -= 1.0
	steer_target = steer_input * STEER_LIMIT * STEER_SIGN
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

	# ---- THROTTLE / REVERSE ----
	engine_force = 0.0
	var base_force := engine_force_value * FORWARD_SIGN

	if want_gas:
		if abs_speed < 20.0 and abs_speed != 0.0:
			engine_force = clamp(base_force * -3.0 / abs_speed, -300.0, 300.0)
		else:
			engine_force = base_force
	elif want_rev:
		if abs_speed < 30.0 and abs_speed != 0.0:
			engine_force = clamp(-base_force * -10.0 / abs_speed, -300.0, 300.0)
		else:
			engine_force = -base_force

	# Extra grip with speed
	apply_central_force(Vector3.DOWN * abs_speed)
