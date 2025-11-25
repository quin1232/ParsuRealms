
extends TextureButton
var _press_tween: Tween

func _pressed_animation():
	if _press_tween:
		_press_tween.kill()
	self.scale = Vector2(1, 1)
	if has_method("set_pivot_offset"):
		set_pivot_offset(Vector2(size.x / 2, size.y / 2))
	elif "pivot_offset" in self:
		self.pivot_offset = Vector2(size.x / 2, size.y / 2)
	_press_tween = create_tween()
	_press_tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_press_tween.tween_property(self, "scale", Vector2(1, 1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

@onready var register_panel = $"../../../login2"
@onready var login_panel =$"../.."

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	_pressed_animation()
	await get_tree().create_timer(0.2).timeout
	login_panel.hide()
	register_panel.modulate.a = 0.0
	register_panel.show()
	var tween = create_tween()
	tween.tween_property(register_panel, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	print("press")
