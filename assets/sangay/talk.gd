extends TextureButton
@onready var anim : AnimationPlayer = $"../../../Sangay NPC2/AnimationPlayer"


func _on_pressed() -> void:
	Dialogic.start("sangay", "MeetMaamMica")
	anim.play("Talking")
	hide()
