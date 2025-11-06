extends TextureButton
@export var achiveBox: VBoxContainer
@export var achivePanel: Panel

var panel_min_height: float
var panel_max_height: float
var is_animating: bool = false

func _ready():
	# Defer initialization to next frame to improve load time
	call_deferred("_initialize_panel")

func _initialize_panel():
	achivePanel.visible = false
	achiveBox.visible = false
	panel_min_height = 0.0
	panel_max_height = achivePanel.size.y
	achivePanel.size.y = panel_min_height



func _on_pressed() -> void:
	# Prevent rapid clicking during animation
	if is_animating:
		return
		
	is_animating = true
	var show = achivePanel.size.y == panel_min_height
	achivePanel.visible = true
	achiveBox.visible = true
	$"../../SoundEffects/Select".play()
	var tween = create_tween()
	
	if show:
		tween.tween_property(achivePanel, "size:y", panel_max_height, 0.3)
		tween.tween_property(achiveBox, "modulate:a", 1.0, 0.3)
	else:
		tween.tween_property(achiveBox, "modulate:a", 0.0, 0.1)
		tween.tween_property(achivePanel, "size:y", panel_min_height, 0.3)
		tween.tween_callback(Callable(self, "_on_hide_panel"))
	
	# Re-enable button after animation completes
	tween.tween_callback(Callable(self, "_on_animation_complete"))

func _on_hide_panel():
	achivePanel.visible = false
	achiveBox.visible = false

func _on_animation_complete():
	is_animating = false
