extends Control

@onready var next_scene_path: String = "res://Map/Map.tscn"
@onready var note_label: TextureButton = $login/VBoxContainer2/guest

var _transitioning := false
var _tree: SceneTree  # cache the tree early so it’s never null later

func _enter_tree() -> void:
	_tree = get_tree()

func _ready() -> void:
	FadeLayer.fade_in()
	
	# This tells the button to call 'fade_and_change_scene' when pressed.
	note_label.pressed.connect(fade_and_change_scene)


func fade_and_change_scene() -> void:
	# This stops the function from running again if it's already fading.
	Global.is_guest = true
	Global.is_logged_in = false
	Global.player_username = "Guest"
	Global.player_email = ""
	if _transitioning:
		return
	_transitioning = true
	
	# --- ADDED LINES to speed up animation ---
	# Find the AnimationPlayer in the FadeLayer.
	# Assumes it is named "AnimationPlayer".
	var anim_player: AnimationPlayer = FadeLayer.get_node_or_null("AnimationPlayer")
	
	if anim_player:
		# Set the animation to 2x speed. Increase this number for faster fades.
		anim_player.speed_scale = 2.0 
	else:
		push_error("Could not find 'AnimationPlayer' in FadeLayer.")
	# ------------------------------------------

	FadeLayer.fade_out()
	print("Fading out (fast)...")
	await FadeLayer.fade_finished
	print("Fade finished, changing scene to: ", next_scene_path)

	# --- ADDED LINE to reset speed ---
	# Reset the speed scale for the next time it's used
	if anim_player:
		anim_player.speed_scale = 1.0
	# ---------------------------------

	# Use the cached SceneTree, and change scene deferred
	if _tree:
		_tree.call_deferred("change_scene_to_file", next_scene_path)
		print("Scene change called (deferred)!")
	else:
		push_error("No SceneTree available (node left the tree before switch).")
	
	# The node will be freed, but resetting the flag is good practice
	_transitioning = false
