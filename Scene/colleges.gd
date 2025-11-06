extends TextureButton

# --- Which scene to load after click ---
@export var loading_scene: PackedScene = preload("res://Scene/loading.tscn")
@export_range(0, 999) var scene_index: int = 0

# Track click state
var _clicked_once := false

# Static list to track all college buttons
static var _all_college_buttons := []

func _init():
	# Register this button
	_all_college_buttons.append(self)

func _exit_tree():
	# Unregister this button
	_all_college_buttons.erase(self)

func _ready() -> void:
	# Connect the button's pressed signal
	self.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if not _clicked_once:
		# Reset all other buttons
		for btn in _all_college_buttons:
			if btn != self:
				btn._clicked_once = false
		_clicked_once = true
		self.grab_focus()
		$"../../../../SoundEffects/Click".play()
		return

	# Second click: continue as normal
	Global.scene_index = scene_index
	GlobalTracking.set_college(scene_index)
	if loading_scene:
		get_tree().change_scene_to_packed(loading_scene)
	else:
		push_error("No loading_scene assigned on %s" % name)
