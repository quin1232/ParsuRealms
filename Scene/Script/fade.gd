extends CanvasLayer

signal fade_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func fade_out():
	animation_player.play("fade_out")

func fade_in():
	animation_player.play("fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out" or anim_name == "fade_in":
		emit_signal("fade_finished")
