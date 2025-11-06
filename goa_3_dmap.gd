extends Node3D

@export var y_offset: float = 0.0
@export var follow_continuously := false

func _enter_tree() -> void:
	# Connect spawn_changed in deferred mode so it won't fire during enter/exit
	if Engine.has_singleton("Global"):
		Global.spawn_changed.connect(_on_spawn_changed, Object.CONNECT_DEFERRED)

func _ready() -> void:
	# Defer the fade so FadeLayer is guaranteed to be in the tree
	call_deferred("_safe_fade_in")

	# Apply saved spawn (safe even if none)
	if Engine.has_singleton("Global") and Global.has_spawn:
		_apply_global_spawn()

func _process(_delta: float) -> void:
	if follow_continuously and Engine.has_singleton("Global") and Global.has_spawn:
		_apply_global_spawn()

func _apply_global_spawn() -> void:
	var t := Global.get_spawn_transform()
	global_transform = t
	global_translate(Vector3(0, y_offset, 0))

func _on_spawn_changed(new_t: Transform3D) -> void:
	# This runs deferred (see CONNECT_DEFERRED), avoiding in/out-tree races
	if !is_inside_tree():
		return
	global_transform = new_t
	global_translate(Vector3(0, y_offset, 0))

func _safe_fade_in() -> void:
	# Wait a frame so sibling UI gets instanced
	await get_tree().process_frame

	# If FadeLayer is a node in the scene (not an autoload), find it safely:
	var fade_layer := get_node_or_null("/root/FadeLayer")
	if fade_layer and fade_layer.is_inside_tree():
		fade_layer.fade_in()
	elif Engine.has_singleton("FadeLayer"):
		# If you actually made FadeLayer an autoload singleton script:
		FadeLayer.fade_in()
