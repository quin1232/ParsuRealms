extends Control

@export var tap_rect: ColorRect
@export var progress_bar: ProgressBar
@export var win_panel: Control # Assign your win panel node in the editor
@export var start_btn: TextureButton # Assign your start button node in the editor

@export var taps_to_fill: int = 5 # Number of taps to reach 100
@export var decay_interval: float = 0.5 # Seconds between decreases
@export var decrease_amount: float = 10.0 # Amount to decrease per tick (set in editor)

var dragging_node = null
var drag_offset = Vector2.ZERO

var decay_timer: Timer
var has_won := false
var target_value: float = 0.0
var decaying := false
var game_started := false

func _ready():
	tap_rect.connect("gui_input", Callable(self, "_on_tap_rect_gui_input"))
	progress_bar.connect("gui_input", Callable(self, "_on_progress_bar_gui_input"))
	progress_bar.max_value = 100
	if win_panel:
		win_panel.visible = false
	decay_timer = Timer.new()
	decay_timer.wait_time = decay_interval
	decay_timer.autostart = false
	decay_timer.one_shot = false
	add_child(decay_timer)
	decay_timer.connect("timeout", Callable(self, "_on_decay_timer_timeout"))
	if start_btn:
		start_btn.visible = true
		start_btn.disabled = false
		start_btn.connect("pressed", Callable(self, "_on_start_btn_pressed"))

func _on_start_btn_pressed():
	game_started = true
	if start_btn:
		start_btn.visible = false
		$VBoxContainer.show()
	decay_timer.start()

func _on_tap_rect_gui_input(event):
	if not has_won and game_started:
		_on_gui_input(event, tap_rect)

func _on_progress_bar_gui_input(event):
	if not has_won and game_started:
		_on_gui_input(event, progress_bar)

func _on_gui_input(event, node):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging_node = node
				drag_offset = node.global_position - event.global_position
				# Move progress bar when tap_rect is tapped
				if node == tap_rect and not has_won:
					var base_increment = 100.0 / taps_to_fill
					var difficulty_factor = 0.5 + 0.5 * (1.0 - target_value / 100.0)
					var increment = base_increment * difficulty_factor
					target_value = clamp(target_value + increment, 0, 100)
					if target_value >= 100:
						target_value = 100
						win()
			else:
				dragging_node = null
	elif event is InputEventMouseMotion and dragging_node == node:
		node.global_position = event.global_position + drag_offset

func _unhandled_input(event):
	if event is InputEventMouseMotion and dragging_node:
		dragging_node.global_position = event.global_position + drag_offset

func _on_decay_timer_timeout():
	if not has_won and target_value > 0:
		decaying = true

func _process(delta):
	# Smoothly interpolate the progress bar value towards target_value
	progress_bar.value = lerp(progress_bar.value, target_value, 10 * delta)
	if abs(progress_bar.value - target_value) < 0.1:
		progress_bar.value = target_value

	# Smooth decay
	if decaying and not has_won and target_value > 0:
		target_value = clamp(target_value - decrease_amount * delta, 0, 100)
		if target_value <= 0:
			target_value = 0
			decaying = false

func win():
	has_won = true
	decay_timer.stop()
	if win_panel:
		$"../PlayerTemplate/CanvasLayer".hide()
		win_panel.visible = true
		win_panel.scale = Vector2(0.2, 0.2)
		var tween = create_tween()
		tween.tween_property(win_panel, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	hide()
		
func restart():
	has_won = false
	target_value = 0.0
	progress_bar.value = 0.0
	decaying = false
	game_started = false
	if win_panel:
		win_panel.visible = false
	if decay_timer:
		decay_timer.stop()
	if start_btn:
		start_btn.visible = true
		start_btn.disabled = false
	$VBoxContainer.hide()
