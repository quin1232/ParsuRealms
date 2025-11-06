extends TextureRect

@export var start_scale: Vector2 = Vector2(0.1, 0.1)
@export var end_scale: Vector2 = Vector2.ONE
@export var duration: float = 3.0
@export var delay: float = 0.0
@export var fade_in: bool = true

func _ready() -> void:
	await get_tree().process_frame
	pivot_offset = size * 0.5

	# Start small and hidden
	scale = start_scale
	visible = false
	if fade_in:
		modulate.a = 0.0

	var t := create_tween()

	# Delay before showing
	if delay > 0.0:
		t.set_delay(delay)

	# Show before starting animation
	t.tween_callback(func():
		visible = true
	)

	# Fade in if enabled
	if fade_in:
		t.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.10)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

	# Scale up animation
	t.tween_property(self, "scale", end_scale, duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
