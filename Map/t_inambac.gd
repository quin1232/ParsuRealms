
extends Sprite2D

# --- Visual refs ---
@export var outline: Sprite2D
@export var icon: Sprite2D

# --- Visual states ---
@export var selected_scale: Vector2 = Vector2(0.539, 0.551)
@export var deselected_scale: Vector2 = Vector2(0.339, 0.351)
@export var raised_z_index: int = 1000

# --- Which scene index to load from loader's scenes array ---
@export_range(0, 999) var scene_index: int = 0

# --- Loading scene (shown first) ---
@export var select_colleges: PackedScene    # Assign Loading.tscn here

# --- Close animation ---
@export var anim_player: AnimationPlayer
@export var close_anim_name: String = "closeclounds"

# --- Behavior: revert visuals while close animation plays ---
@export var revert_on_close: bool = true
@export var close_revert_time: float = 0.12  # kept for compatibility, not used by delta lerp

# --- Delta-based animation controls ---
@export var scale_smooth_speed: float = 12.0  # higher = faster approach

# --- NEW: Hover Animation ---
@export_group("Hover Animation")
@export var hover_enabled: bool = true
@export var hover_amplitude: float = 8.0  # How many pixels to move up/down
@export var hover_speed: float = 4.0      # How fast to move

var _original_icon_position: Vector2 # NEW: To store the icon's start position
# --- End of New Variables ---

var _original_z_index: int
static var selected_sprite: Sprite2D = null
var _transitioning := false

# Target scale we lerp toward each frame
var _scale_target: Vector2

func _ready() -> void:
	_original_z_index = z_index
	if outline:
		outline.visible = false
	if icon:
		# Start deselected
		icon.scale = deselected_scale
		_scale_target = deselected_scale
		
		# --- NEW: Store original position for hover ---
		_original_icon_position = icon.position
		# --- End of New Code ---
	
	# Set process mode to optimize performance
	set_process(true)

func _process(delta: float) -> void:
	# Skip if not visible or no icon
	if not icon or not visible:
		return
	
	# Smooth, framerate-independent scale animation
	# Only process if scale is not at target (optimization)
	if icon.scale.distance_to(_scale_target) > 0.001:
		# Convert speed (per second) to a 0..1 lerp factor this frame
		var t: float = clamp(scale_smooth_speed * delta, 0.0, 1.0)
		icon.scale = icon.scale.lerp(_scale_target, t)
	# --- Apply hover animation only when enabled ---
	if hover_enabled:
		# Use Engine time instead of ticks for better performance
		var time: float = Time.get_ticks_msec() * 0.001
		
		# Calculate new Y position using a sine wave
		var new_y: float = _original_icon_position.y + (sin(time * hover_speed) * hover_amplitude)
		
		# Apply the new Y position, keeping the original X
		icon.position.y = new_y
		
func _exit_tree() -> void:
	if selected_sprite == self:
		selected_sprite = null

# Connect Area2D's "input_event" to this function
func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	if _transitioning:
		return

	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:

		# Second click on same sprite => close animation + go
		if selected_sprite == self and outline and outline.visible:
			_transitioning = true
			await _play_close_and_go()
			return

		# First click => select this sprite
		if is_instance_valid(selected_sprite) and selected_sprite != self:
			selected_sprite.deselect()
		select()

func select() -> void:
	if outline:
		outline.visible = true
		$"../../SoundEffects/Select".play()
	z_index = raised_z_index
	selected_sprite = self
	# Set the delta-animated target
	_scale_target = selected_scale
	
	# --- NEW: Stop hover when selected ---
	hover_enabled = false
	# Snap icon back to its original Y position
	icon.position.y = _original_icon_position.y
	# --- End of New Code ---


func deselect() -> void:
	if outline:
		outline.visible = false
	z_index = _original_z_index
	if selected_sprite == self:
		selected_sprite = null
	# Set the delta-animated target
	_scale_target = deselected_scale
	
	# --- NEW: Resume hover when deselected ---
	hover_enabled = true
	# --- End of New Code ---

# --- Play close animation, revert visuals, set global var, switch to loader ---
func _play_close_and_go() -> void:
	if revert_on_close:
		if outline:
			outline.visible = false
		z_index = _original_z_index
		if icon:
			# Snap target to deselected; lerp will smoothly take it there
			_scale_target = deselected_scale
			
			# --- NEW: Ensure hover is on if we revert ---
			hover_enabled = true
			# --- End of New Code ---

	# Play close animation
	if anim_player and close_anim_name != "" and anim_player.has_animation(close_anim_name):
		anim_player.play(close_anim_name)
		$"../../SoundEffects/Select2".play()
		await anim_player.animation_finished

	# Clear selection
	if selected_sprite == self:
		selected_sprite = null

	# Set global index
	Global.scene_index = scene_index

	# Go to loading scene
	if select_colleges:
		get_tree().change_scene_to_packed(select_colleges)
	else:
		push_error("No loading_scene assigned on %s" % name)

	_transitioning = false

static func clear_selection() -> void:
	if is_instance_valid(selected_sprite):
		selected_sprite.deselect()
