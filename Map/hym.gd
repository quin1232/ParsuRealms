extends TextureButton
@export var historybook: Control
@export var UI: CanvasLayer

var is_panel_visible: bool = false

func _ready():
	# Initialize panel as hidden
	if historybook:
		historybook.visible = false
		historybook.modulate.a = 0.0

func _on_pressed() -> void:
	if not historybook or not UI:
		$"../../../../SoundEffects/Select".play()
		return
	
	is_panel_visible = !is_panel_visible
	
	var tween = create_tween()
	
	if is_panel_visible:
		# Show panel, hide canvas
		historybook.visible = true
		UI.visible = false
		tween.tween_property(historybook, "modulate:a", 1.0, 0.3)
	else:
		# Hide panel, show canvas
		UI.visible = true
		tween.tween_property(historybook, "modulate:a", 0.0, 0.3)
		tween.finished.connect(func(): historybook.visible = false)
