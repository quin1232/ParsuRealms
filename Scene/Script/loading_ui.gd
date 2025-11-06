extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var loading_label: Label = $ProgressBar/Label2

# Array of scenes to load (drag them into the Inspector)
@export var scenes: Array[PackedScene]

# UI + Animation tweakables
@export var min_display_time: float = 0.75
@export var smooth_speed: float = 0.9
@export var idle_creep_speed: float = 0.15
@export var hold_max_before_switch: float = 0.12
@export var dot_speed: float = 0.5
@export var max_dots: int = 3

# Internal loading state
var _is_loading := false
var _elapsed := 0.0
var _display := 0.0
var _target := 0.0
var _done_animated := false
var _dot_count := 0
var _dot_timer := 0.0
var _scene_path := ""

func _ready() -> void:
	# Get target scene from global variable
	var index := Global.scene_index
	if index < 0 or index >= scenes.size():
		push_error("Invalid scene index: %s" % index)
		return

	_scene_path = scenes[index].resource_path

	progress_bar.min_value = 0
	progress_bar.max_value = 100
	_update_ui(0.0)

	# Start threaded load
	var err := ResourceLoader.load_threaded_request(_scene_path)
	if err != OK:
		push_error("Failed to start threaded load: %s (err %s)" % [_scene_path, err])
		return

	_is_loading = true
	set_process(true)

func _process(delta: float) -> void:
	if not _is_loading:
		return

	_elapsed += delta

	var prog: Array = []
	var status := ResourceLoader.load_threaded_get_status(_scene_path, prog)

	var real := 0.0
	if prog.size() > 0:
		real = clampf(float(prog[0]), 0.0, 1.0)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_target = max(_target, min(real, 0.98))
			_target = min(_target + idle_creep_speed * delta, 0.98)

		ResourceLoader.THREAD_LOAD_FAILED:
			_is_loading = false
			set_process(false)
			push_error("Loading failed: %s" % _scene_path)

		ResourceLoader.THREAD_LOAD_LOADED:
			_target = 1.0

	# Smooth approach
	_display = move_toward(_display, _target, smooth_speed * delta)

	# Animate dots
	_dot_timer += delta
	if _dot_timer >= dot_speed:
		_dot_timer = 0.0
		_dot_count = (_dot_count + 1) % (max_dots + 1)

	_update_ui(_display)

	# When loaded & fully displayed
	if status == ResourceLoader.THREAD_LOAD_LOADED and not _done_animated and absf(_display - 1.0) <= 0.002:
		_done_animated = true
		await _finish_and_change()

func _finish_and_change() -> void:
	_is_loading = false
	set_process(false)

	if _elapsed < min_display_time:
		await get_tree().create_timer(min_display_time - _elapsed).timeout

	if hold_max_before_switch > 0.0:
		await get_tree().create_timer(hold_max_before_switch).timeout

	var packed := ResourceLoader.load_threaded_get(_scene_path)
	if packed is PackedScene:
		get_tree().change_scene_to_packed(packed)
	else:
		get_tree().change_scene_to_file(_scene_path)

func _update_ui(p: float) -> void:
	var clamped := clampf(p, 0.0, 1.0)
	var pct := int(round(clamped * 100.0))
	progress_bar.value = pct
	loading_label.text = "Loading" + ".".repeat(_dot_count) + " " + str(pct) + "%"
