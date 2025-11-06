extends Control

signal loading_done
@export var col: CollisionShape3D

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var loading_label: Label = $ProgressBar/Label2

# --- Theming ---
@export var action_verb: String = "Fixing the car"
@export var show_wrench_emoji: bool = true

# --- Start behavior ---
@export var auto_start: bool = false   # if true, starts on _ready; otherwise waits for start_loading()
@export var car: AnimationPlayer
@export var glow: Node3D

# --- Fake loading controls ---
@export var total_duration: float = 2.8
@export var jitter_per_second: float = 0.18
@export var smooth_speed: float = 0.9
@export var min_display_time: float = 0.75
@export var hold_after_complete: float = 0.3

# Dots animation
@export var dot_speed: float = 0.5
@export var max_dots: int = 3

# Optional step text (thresholds 0..1). Keep lengths equal.
@export var use_step_texts: bool = true
@export var step_thresholds: Array[float] = [0.15, 0.45, 0.75, 0.95, 0.96]
@export var step_texts: Array[String] = [
	"Checking the hood",
	"Replacing spark plug",
	"Charging the battery",
	"Tightening bolts",
	"Fixing Completed"
]

# ── Internals ──
var _elapsed: float = 0.0
var _display: float = 0.0
var _target: float = 0.0
var _dot_count: int = 0
var _dot_timer: float = 0.0
var _completed: bool = false
var _running: bool = false

func _ready() -> void:
	randomize()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	_update_ui(0.0)

	visible = auto_start
	_running = auto_start
	set_process(auto_start)

	if auto_start:
		_reset_state()

func _process(delta: float) -> void:
	if not _running or _completed:
		return

	_elapsed += delta

	var rate: float = 1.0 / maxf(0.1, total_duration)
	var jitter: float = randf_range(0.0, jitter_per_second) * delta
	_target = minf(1.0, _target + rate * delta + jitter)

	_display = move_toward(_display, _target, smooth_speed * delta)

	# Dots animation
	_dot_timer += delta
	if _dot_timer >= dot_speed:
		_dot_timer = 0.0
		_dot_count = (_dot_count + 1) % (max_dots + 1)

	_update_ui(_display)

	if _display >= 0.999 and not _completed:
		_completed = true
		await _finish_and_stop()

# ── PUBLIC API ─────────────────────────────────────────────────────────────────

func start_loading(duration: float = -1.0, verb: String = "") -> void:
	# Optional overrides from caller
	if duration > 0.0:
		total_duration = duration
	if verb != "":
		action_verb = verb

	_reset_state()
	visible = true
	_running = true
	set_process(true)

func stop_and_hide() -> void:
	_running = false
	_completed = true
	set_process(false)
	visible = false

func is_running() -> bool:
	return _running and not _completed

# ── Internals ─────────────────────────────────────────────────────────────────

func _reset_state() -> void:
	_elapsed = 0.0
	_display = 0.0
	_target = 0.0
	_dot_count = 0
	_dot_timer = 0.0
	_completed = false
	if progress_bar: progress_bar.value = 0.0
	_update_ui(0.0)

func _finish_and_stop() -> void:
	if _elapsed < min_display_time:
		await get_tree().create_timer(min_display_time - _elapsed).timeout
	if hold_after_complete > 0.0:
		await get_tree().create_timer(hold_after_complete).timeout

	_display = 1.0
	_update_ui(_display)

	_running = false
	set_process(false)
	car.play("CloseHood")
	Dialogic.VAR.carFixed = true
	col.disabled = true
	glow.hide()
	
	
	emit_signal("loading_done") # let the button (or anyone) know we're done

func _update_ui(p: float) -> void:
	var clamped: float = clampf(p, 0.0, 1.0)
	var pct_i: int = int(round(clamped * 100.0))
	progress_bar.value = float(pct_i)

	var dots: String = ".".repeat(_dot_count)
	# NOTE: your original code had a single space here; use an emoji if desired.
	var wrench: String = "" if show_wrench_emoji else ""

	var text: String = action_verb
	if use_step_texts and step_texts.size() == step_thresholds.size() and step_texts.size() > 0:
		for i in range(step_thresholds.size()):
			if clamped >= step_thresholds[i]:
				text = step_texts[i]
			else:
				break

	loading_label.text = "%s%s %d%%%s" % [text, dots, pct_i, wrench]
