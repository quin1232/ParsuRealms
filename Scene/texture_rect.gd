extends TextureRect

@export var Player_camera: Camera3D 
@export var car_camera: Camera3D 

func _process(_delta):
	if $"../../../..".getprevCam() == "p":
		rotation = -Player_camera.global_rotation.y
	else: 
		rotation = -car_camera.global_rotation.y
