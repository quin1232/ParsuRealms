extends CanvasLayer

@export var player_path: NodePath
@onready var player = get_node(player_path)
@onready var jump_btn: TextureButton = $jump
@onready var run_btn: TextureButton = $run

var run_toggled := false
var run_btn_normal_texture
var run_btn_focus_texture

func _ready() -> void:
	# Each button handles its own touch; no focus stealing.
	jump_btn.focus_mode = Control.FOCUS_NONE
	run_btn.focus_mode  = Control.FOCUS_NONE
	jump_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	run_btn.mouse_filter  = Control.MOUSE_FILTER_STOP

	# Connect signals once (remove the inline lambdas to avoid duplicates)
	jump_btn.pressed.connect(_on_jump_button_pressed)
	run_btn.pressed.connect(_on_run_button_toggled)
	# Save original textures
	run_btn_normal_texture = run_btn.texture_normal
	run_btn_focus_texture = run_btn.texture_focused
func _on_jump_button_pressed() -> void:
	if player and player.has_method("request_jump"):
		player.request_jump()

func _on_run_button_toggled() -> void:
	run_toggled = !run_toggled
	if player and player.has_method("set_run_pressed"):
		player.set_run_pressed(run_toggled)
	# Change button texture
	if run_toggled:
		run_btn.texture_normal = run_btn_focus_texture
	else:
		run_btn.texture_normal = run_btn_normal_texture
