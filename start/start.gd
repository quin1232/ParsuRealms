extends Node3D


@onready var animation_player = $AnimationPlayer
@onready var ui = $MainMenu


func _ready() -> void:
	ui.modulate.a = 0.0  # Start with UI fully transparent
	animation_player.play("OPENING")
	animation_player.animation_finished.connect(_on_animation_finished)
	fade_in_ui()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "OPENING":
		fade_in_ui()
		var login = $MainMenu/login
		login.show()
		login.scale = Vector2(0.5, 0.5)
		var tween = create_tween()
		tween.tween_property(login, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func fade_in_ui() -> void:
	ui.visible = true
	var tween = create_tween()  # Create a new tween instance
	tween.tween_property(ui, "modulate:a", 1.0, 1.5)  # Fade in over 1.5 seconds
