extends TextureButton
@export var character: CharacterBody3D
@export var anim : AnimationPlayer 
func _on_pressed() -> void:
	if Dialogic.VAR.IsTestDriveDone != true:
		Dialogic.VAR.TalktoEngr = true
		Dialogic.start("CEC", "TalktoEngr")
		anim.play("Wave")
		character.set_physics_process(false)
		character.play_idle(true)
		hide()
		
	else :
		Dialogic.start("CEC", "ReturnToEngineer")
		character.set_physics_process(false)
		character.play_idle(true)
		hide()
