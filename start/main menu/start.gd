extends Control

@onready var next_scene_path: String = "res://Map/Map.tscn"
@onready var note_label: TextureButton = $login/VBoxContainer2/guest
var _guest_press_tween: Tween

func _guest_pressed_animation():
	if _guest_press_tween:
		_guest_press_tween.kill()
	note_label.scale = Vector2(1, 1)
	if note_label.has_method("set_pivot_offset"):
		note_label.set_pivot_offset(Vector2(note_label.size.x / 2, note_label.size.y / 2))
	elif "pivot_offset" in note_label:
		note_label.pivot_offset = Vector2(note_label.size.x / 2, note_label.size.y / 2)
	_guest_press_tween = create_tween()
	_guest_press_tween.tween_property(note_label, "scale", Vector2(0.85, 0.85), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_guest_press_tween.tween_property(note_label, "scale", Vector2(1, 1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

var _transitioning := false
var _tree: SceneTree  # cache the tree early so it’s never null later

func _enter_tree() -> void:
	_tree = get_tree()

func _ready() -> void:
	FadeLayer.fade_in()
	
	# This tells the button to call 'fade_and_change_scene' when pressed.
	note_label.pressed.connect(_on_guest_pressed)

func _on_guest_pressed():
	_guest_pressed_animation()
	await get_tree().create_timer(0.2).timeout
	fade_and_change_scene()


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
