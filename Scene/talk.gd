extends TextureButton
@export var character: CharacterBody3D
@onready var anim : AnimationPlayer = $"../../../Teacher/AnimationPlayer"

func _on_pressed() -> void:
	if Dialogic.VAR.CollectComplete!= true:
		Dialogic.VAR.TalktoTeacher = true
		Dialogic.start("COED", "TalktoTeacher")
		character.set_physics_process(false)
		character.play_idle(true)
		anim.play("Talking")
		hide()
	else:
		Dialogic.start("COED", "Talk2")
		
		character.set_physics_process(false)
		character.play_idle(true)
		hide()
