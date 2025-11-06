extends TextureButton

@export var car: Camera3D
@export var player: CharacterBody3D
@export var playerCol: CollisionShape3D
@export var playerCam: Camera3D
@export var spawn: Node3D
@export var car_body: VehicleBody3D
@export var unhide_nodes: Array[Node] = [] # Add nodes you want to unhide in the inspector

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Turn off car camera
	car.current = false
	$"../../../car/Control".hide()
	$"../Mini Map".setprevCam("p")
	# Move player to spawn position
	if spawn and player:
		player.global_position = spawn.global_transform.origin

	# Reactivate player
	player.show()
	player.set_physics_process(true)
	playerCol.disabled = false

	# Activate player camera
	playerCam.current = true
	car_body.set_physics_process(false)

	# Unhide nodes in the array
	for node in unhide_nodes:
		if node:
			node.show()
	
	# Hide the exit button
	hide()
