extends TextureButton
@export var car: AnimationPlayer 
@export var fixbtn: TextureButton
@export var player: CharacterBody3D
@export var col: CollisionShape3D

func _on_pressed() -> void:
	
	# Your interaction logic
	if Dialogic.VAR.Isfoundlocker == true:
		Dialogic.start("CEC Question")
		$"../..".set_physics_process(false)
		$"../..".play_idle(true)
	elif Dialogic.VAR.Isfoundtoolbox == true:
		Dialogic.VAR.ITquest = true
		Dialogic.start("CEC IT Question", "ITquest")
		$"../..".set_physics_process(false)
		$"../..".play_idle(true)
	elif Dialogic.VAR.Car == true:
		car.play("OpenHood")
		Dialogic.VAR.Car = false
		fixbtn.visible = true
		Dialogic.VAR.Iscaropen = true
	elif Dialogic.VAR.IsfoundBox == true:
		car.play("OpenBox")
		col.disabled = false
		$"../../../Paper".freeze = false
	playerPhysicsEn()
	hide()
func playerPhysicsDis():
	player.set_physics_process(false)
func playerPhysicsEn():
	player.set_physics_process(true)
