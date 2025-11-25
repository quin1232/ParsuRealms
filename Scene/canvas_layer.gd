extends CanvasLayer

@export var player_path: NodePath
@onready var player = get_node(player_path)
@onready var jump_btn: TextureButton = $jump
@onready var run_btn: TextureButton = $run

var run_toggled := false
var run_btn_normal_texture
var run_btn_focus_texture
var jump_touch_index := -1
var run_touch_index := -1

func _ready() -> void:
	# Each button handles its own touch; no focus stealing.
	jump_btn.focus_mode = Control.FOCUS_NONE
	run_btn.focus_mode  = Control.FOCUS_NONE
	jump_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	run_btn.mouse_filter  = Control.MOUSE_FILTER_STOP

	# Enable accumulated input so the engine delivers per-touch events
	# This allows multiple on-screen buttons to be pressed simultaneously
	# (necessary for multitouch on mobile devices).
	Input.set_use_accumulated_input(true)

	# Connect gui_input to handle per-touch events (multi-touch safe)
	jump_btn.gui_input.connect(_on_jump_gui_input)
	run_btn.gui_input.connect(_on_run_gui_input)
	# Save original textures
	run_btn_normal_texture = run_btn.texture_normal
	run_btn_focus_texture = run_btn.texture_focused
func _on_jump_gui_input(event: InputEvent) -> void:
	# Handle screen touch (mobile) and mouse click (desktop).
	if event is InputEventScreenTouch:
		if event.pressed:
			jump_touch_index = event.index
			if player and player.has_method("request_jump"):
				player.request_jump()
		elif event.index == jump_touch_index:
			# touch released for this button
			jump_touch_index = -1
	elif event is InputEventMouseButton:
		if event.pressed:
			if player and player.has_method("request_jump"):
				player.request_jump()

func _on_run_gui_input(event: InputEvent) -> void:
	# Hold-to-run: run is true while the button is pressed.
	if event is InputEventScreenTouch:
		if event.pressed:
			run_touch_index = event.index
			run_toggled = true
			if player and player.has_method("set_run_pressed"):
				player.set_run_pressed(true)
			run_btn.texture_normal = run_btn_focus_texture
		elif event.index == run_touch_index:
			# release for this touch
			run_touch_index = -1
			run_toggled = false
			if player and player.has_method("set_run_pressed"):
				player.set_run_pressed(false)
			run_btn.texture_normal = run_btn_normal_texture
	elif event is InputEventMouseButton:
		# Treat mouse press as hold while button is pressed
		if event.pressed:
			run_toggled = true
			if player and player.has_method("set_run_pressed"):
				player.set_run_pressed(true)
			run_btn.texture_normal = run_btn_focus_texture
		else:
			run_toggled = false
			if player and player.has_method("set_run_pressed"):
				player.set_run_pressed(false)
			run_btn.texture_normal = run_btn_normal_texture
