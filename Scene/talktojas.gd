extends TextureButton
@export var character: CharacterBody3D
@onready var anim : AnimationPlayer = $"../../../CBMNPC/AnimationPlayer"

func _on_pressed() -> void:
	if Dialogic.VAR.CollectComplete!= true:
		Dialogic.VAR.TalktoJasmine = true
		Dialogic.start("CBM", "TalktoJasmine")
		character.set_physics_process(false)
		character.play_idle(true)
		anim.play("Talking_001")
		hide()
	else:
		Dialogic.start("CBM", "ComputeTask")
		character.set_physics_process(false)
		character.play_idle(true)
		hide()
