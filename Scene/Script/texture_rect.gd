extends TextureRect

@export var small_scale: Vector2 = Vector2(0.9, 0.9)
@export var large_scale: Vector2 = Vector2(1.0, 1.0)
@export var period_seconds: float = 2  # full cycle small→large→small

@export var normal_color: Color = Color(1, 1, 1, 1) # normal visible white
@export var blink_alpha: float = 1              # fully visible at peak
@export var fade_alpha: float = 0.10                # half-transparent at min

func _ready() -> void:
	await get_tree().process_frame
	pivot_offset = size * 0.5
	resized.connect(func(): pivot_offset = size * 0.5)

	scale = small_scale
	modulate = normal_color

	var t := create_tween().set_loops()

	# Scale up and brighten
	t.parallel().tween_property(self, "scale", large_scale, period_seconds * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(self, "modulate:a", blink_alpha, period_seconds * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Scale down and fade
	t.tween_property(self, "scale", small_scale, period_seconds * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(self, "modulate:a", fade_alpha, period_seconds * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
