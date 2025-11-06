extends TextureButton
@export var values: Control
@export var UI: CanvasLayer

var is_panel_visible: bool = false
var is_animating: bool = false

func _ready():
	# Initialize panel as hidden
	if values:
		values.visible = false
		values.modulate.a = 0.0

func _on_pressed() -> void:
	if not values or not UI:
		$"../../../../SoundEffects/Select".play()
		return

	if is_animating:
		return
	is_animating = true

	is_panel_visible = !is_panel_visible
	var tween = create_tween()

	if is_panel_visible:
		# Show panel, hide canvas
		values.visible = true
		UI.visible = false
		tween.tween_property(values, "modulate:a", 1.0, 0.3)
	else:
		# Hide panel, show canvas
		UI.visible = true
		tween.tween_property(values, "modulate:a", 0.0, 0.3)
		tween.finished.connect(func(): values.visible = false)

	tween.finished.connect(_on_animation_complete)
func _on_animation_complete():
	is_animating = false
