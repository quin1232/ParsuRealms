extends TextureButton

@export var car: Camera3D
@export var player: CharacterBody3D
@export var playerCol: CollisionShape3D
@export var car_body: VehicleBody3D
@export var enter_spawn: Node3D
@export var nodes_to_hide: Array[NodePath] = []  # assign nodes in the Inspector
@export var camera_distance := 6.0      # distance behind the car
@export var camera_height := 2.5       # height above the car
@export var SpawnCone: PackedScene

# This new variable will store a reference to the spawned cone
# so we can find it later to destroy it.
var _current_cone_instance: Node3D = null


func _ready() -> void:
	self.pressed.connect(_on_pressed)

func destroy_spawn() -> void:
	# Check if the instance we're tracking is still valid
	if is_instance_valid(_current_cone_instance):
		# If it is, remove it from the scene
		_current_cone_instance.queue_free()
		# Clear our variable so we know it's gone
		_current_cone_instance = null

func reappear_spawn() -> void:
	# First, destroy any old cone that might still exist
	# This prevents creating duplicate cones
	destroy_spawn()
	
	# Now, create (reappear) the new one
	if SpawnCone:
		_current_cone_instance = SpawnCone.instantiate()
		get_tree().current_scene.add_child(_current_cone_instance)
		
		if _current_cone_instance is Node3D:
			# Set its global position to the exact coordinates
			_current_cone_instance.global_position = Vector3(79.30, 0, 94.212)


# -----------------------------------------------------------------
# 	MODIFIED _on_pressed function
# -----------------------------------------------------------------
func _on_pressed() -> void:
	FadeLayer.fade_out()
	
	# --- MODIFIED PART ---
	# We now call our new function to create the cone
	reappear_spawn()
	# --- END MODIFIED PART ---
			
	await get_tree().create_timer(1.0).timeout
	for node_path in nodes_to_hide:
		var node = get_node_or_null(node_path)
		if node:
			node.visible = false

	# ── 1) Spawn the car and rotate it ─────────────────────────────
	if enter_spawn and is_instance_valid(car_body):
		car_body.sleeping = true
		car_body.linear_velocity = Vector3.ZERO
		car_body.angular_velocity = Vector3.ZERO

		var t := enter_spawn.global_transform
		t.basis = t.basis.rotated(Vector3.UP, deg_to_rad(90))
		t = t.orthonormalized()    # ✅ correct Godot 4 syntax
		car_body.global_transform = t

		await get_tree().physics_frame
		car_body.sleeping = false
		car_body.set_physics_process(true)

	# ── 2) Position the camera behind the car ──────────────────────
	if is_instance_valid(car) and is_instance_valid(car_body):
		var back_offset := -car_body.global_transform.basis.z * camera_distance
		var cam_pos := car_body.global_transform.origin + back_offset * -1.0
		cam_pos.y += camera_height
		car.global_transform.origin = cam_pos
		car.look_at(car_body.global_transform.origin, Vector3.UP)

	# ── 3) Switch to car camera after short delay ──────────────────
	await get_tree().create_timer(0.5).timeout
	car.current = true

	# ── 4) Hide player while driving ───────────────────────────────
	if is_instance_valid(player):
		player.hide()
		player.set_physics_process(false)
	if is_instance_valid(playerCol):
		playerCol.disabled = true

	hide()
	$"../../../car/Control".visible = true
	FadeLayer.fade_in()
	$"../Mini Map".setprevCam("c")
	$"../exit".show()
