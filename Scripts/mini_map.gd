extends ColorRect

@export var target: NodePath
@export var camera_distance := 20.0
@export var car_camera: Camera3D
@export var player_camera: Camera3D
@export var car: VehicleBody3D
@export var arrow: TextureRect
@export var dialog_manager_path: NodePath
var dialog_manager: Node = null
@export var TopView: Camera3D
var has_triggered_once := false # ✅ prevent multiple triggers
@onready var player: Node3D = get_node(target) if target else null
@onready var camera: Camera3D = $Panel/SubViewportContainer/SubViewport/Camera3D
@onready var texture_rect: TextureRect = $Panel/SubViewportContainer/SubViewport/TextureRect
@export var nodes_to_hide: Array[NodePath] = [] # 👈 Add nodes here via Inspector

# Initialize prevCam to a default that reflects the initial camera state (e.g., player)
var prevCam: String = "p"

func _ready() -> void:
	# Allow the ColorRect to receive mouse events
	mouse_filter = Control.MOUSE_FILTER_STOP
	if dialog_manager_path != NodePath():
		dialog_manager = get_node(dialog_manager_path)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Press")
		
		# --- Camera Switch Logic ---
		if player_camera.current:
			# Current camera is player_camera, switch to TopView and store "p"
			TopView.current = true
			player_camera.current = false
			prevCam = "p"
		elif car_camera.current:
			# Current camera is car_camera, switch to TopView and store "c"
			TopView.current = true
			car_camera.current = false
			prevCam = "c"
		else:
			# Current camera is TopView, switch back to the previous camera
			TopView.current = false
			if prevCam == "c":
				car_camera.current = true
			else:
				# Default to player_camera if prevCam is "p" or uninitialized
				player_camera.current = true
		# --- End Camera Switch Logic ---
		
		player.save_spawn_now()
		Global.IsArrowClick = true
		arrow.visible = false
		hide_nodes()
		
		# --- Dialogic Trigger Logic (Consolidated) ---
		var college_id = GlobalTracking.get_selected_college()
		if college_id == 1 or college_id == 0:
			if has_triggered_once:
				return # ✅ Prevent multiple clicks
			
			has_triggered_once = true # ✅ mark as triggered once
			Dialogic.VAR.IsArrowClick = true
			
			var dialog_name = ""
			if college_id == 1:
				dialog_name = "CEC"
			elif college_id == 0:
				dialog_name = "COED"
			
			Dialogic.start(dialog_name, "arrow")
			player.set_physics_process(false)
		# --- End Dialogic Trigger Logic ---

func _process(_delta: float) -> void:
	# This logic controls the small preview camera's (camera) position and the TextureRect
	if player and car: # Ensure both player and car nodes are valid before proceeding
		var target_node: Node3D = player if prevCam == "p" else car
		
		camera.position = target_node.position + Vector3(0, camera_distance, 0)
		# Note: Vector3.FORWARD (0, 0, -1) might be a better 'up' vector for a flat top-down view,
		# but using (0, 1, 0) or leaving it as default (0, 1, 0) is standard. 
		# I've kept it as it was: Vector3.FORWARD (0, 0, -1) which might be an unusual 'up'
		# vector unless you intend a specific rotation. If the camera is facing straight down,
		# the up vector might not matter much, but for clarity: Vector3.UP is (0, 1, 0).
		camera.look_at(target_node.position, Vector3.FORWARD)

		# Convert 3D target position to 2D screen position
		var screen_pos: Vector2 = camera.unproject_position(target_node.position)

		# Update TextureRect position (inside SubViewport)
		texture_rect.position = screen_pos - (texture_rect.size / 2)

func hide_nodes() -> void:
	# This function now correctly toggles visibility based on the current state.
	for path in nodes_to_hide:
		if has_node(path):
			var node = get_node(path)
			# Toggle visibility: true becomes false, false becomes true
			node.visible = not node.visible
func setprevCam(prev: String)  -> void:	
	prevCam = prev
func getprevCam():
	return prevCam
