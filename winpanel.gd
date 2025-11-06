extends Control

@onready var car_body: VehicleBody3D = $"../car"
@onready var enter_spawn: Node3D = $"../spawn"
@onready var label: Label = $Panel/Label # Assign your Label node
@export var playerSpawn: Node3D
@export var npcSpawn: Node3D
@export var player: CharacterBody3D
@export var npc: StaticBody3D
@export var nodes_to_unhide: Array[NodePath] = []  # assign nodes in the Inspector

# ▼▼▼ NEWLY ADDED VARIABLES ▼▼▼
# (You must drag your car's Camera3D node into this slot in the Inspector)
@export var car: Camera3D 
@export var Playercol: CollisionShape3D
@export var camera_distance := 6.0
@export var camera_height := 2.5
# ▲▲▲ END OF NEW VARIABLES ▲▲▲


# ──────────────── TEXT ARRAYS ────────────────
var win_messages := [
	"You nailed it! Great job!",
	"Victory is yours!",
	"Fantastic! You won!",
	"Perfect run!",
	"Mission accomplished!"
]

var lose_messages := [
	"Don’t give up yet!",
	"Almost there—try again!",
	"You can do better next time!",
	"Keep pushing!",
	"Failure is just a step to success!"
]

func _ready() -> void:
	randomize()

# ──────────────── RETRY BUTTON ────────────────
func _on_retry_pressed() -> void:
	# Defer the actual work so the button's pressed signal finishes first.
	call_deferred("_do_retry")
	
func _do_retry() -> void:
	# Hide THIS Control immediately (works on first press)
	hide()
	await get_tree().process_frame  # let UI redraw once (optional, helps instant hide)

	FadeLayer.fade_out()
	await get_tree().create_timer(1.0).timeout
	
	$"../PlayerTemplate/CanvasLayer/drive".destroy_spawn()
	
	# Reset car
	if enter_spawn and is_instance_valid(car_body):
		car_body.sleeping = true
		car_body.linear_velocity = Vector3.ZERO
		car_body.angular_velocity = Vector3.ZERO

		var t := enter_spawn.global_transform
		t.basis = t.basis.rotated(Vector3.UP, deg_to_rad(90))
		car_body.global_transform = t

		await get_tree().physics_frame
		car_body.sleeping = false
		car_body.set_physics_process(true)

		# ▼▼▼ NEWLY ADDED CAMERA LOGIC ▼▼▼
		# This resets the camera to the car's new spawn position
		if is_instance_valid(car): 
			var back_offset := -car_body.global_transform.basis.z * camera_distance
			var cam_pos := car_body.global_transform.origin + back_offset * -1.0
			cam_pos.y += camera_height
			car.global_transform.origin = cam_pos
			car.look_at(car_body.global_transform.origin, Vector3.UP)
		# ▲▲▲ END OF NEW CAMERA LOGIC ▲▲▲

	# Cone reset logic
	$"../PlayerTemplate/CanvasLayer/drive".reappear_spawn()
	FadeLayer.fade_in()
	$"../car/Control".show()
	# NOTE: Do NOT call show() here unless you really want to re-open this panel now.
	
func _on_con_pressed() -> void:
	# Continue: proceed to your completion timeline, mark vars, then close panel
	FadeLayer.fade_out()

	if player and playerSpawn:
		player.global_position = playerSpawn.global_position
	if npc and npcSpawn:
		npc.global_position = npcSpawn.global_position
	await get_tree().create_timer(2.0).timeout
	car.current = false
	player.show()
	player.set_physics_process(true)
	Playercol.disabled = false
	FadeLayer.fade_in()
	Dialogic.start("CEC", "TestDriveComplete")
	Dialogic.VAR.IsTestDriveDone = true
	hide()
	$"../car/Control".hide()
	$"../PlayerTemplate/CanvasLayer/exit".hide()
	for node_path in nodes_to_unhide:
		var node = get_node_or_null(node_path)
		if node:
			node.visible = true
	
# ──────────────── MESSAGE FUNCTIONS ────────────────
func show_win_message() -> void:
	if label:
		label.text = win_messages[randi() % win_messages.size()]
		label.visible = true
		$Panel/retry.visible = false
		$Panel/Con.visible = true
		$Panel/exit.visible = false
		
func show_lose_message() -> void:
	if label:
		label.text = lose_messages[randi() % lose_messages.size()]
		label.visible = true
		
		# --- Added this logic to show/hide correct buttons ---
		$Panel/retry.visible = true
		$Panel/Con.visible = false
		$Panel/exit.visible = false # Or true, depending on your game
