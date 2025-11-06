extends Node3D

# assign the player node in the scene tree (was %PlayerTemplate)
@onready var player = $PlayerTemplate
@onready var anim : AnimationPlayer = $Teacher/AnimationPlayer

# In the Inspector:
# - Book Scene -> drag a PackedScene that contains the RigidBody3D you want to spawn
# - Book Spawn -> a Node3D (position/rotation) where the rigid body will be created
@export var book_scene: PackedScene
@export var book_spawn: Node3D

# spawn guard so we don't create multiple copies accidentally
var _book_spawned: bool = false

func _ready() -> void:
	if Global.CEDfinish == true:
		Dialogic.VAR.Completequest = true
		Dialogic.VAR.CollectComplete = true
	else:
		Dialogic.VAR.Completequest = false
		Dialogic.VAR.CollectComplete = false
		Dialogic.VAR.Quest1complete = false
		Dialogic.VAR.Quest2complete = false
	FadeLayer.fade_in()
	Dialogic.start("COED")
	player.set_physics_process(false)
	Dialogic.timeline_ended.connect(ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	anim.play("Idle")

func _on_dialogic_signal(value: String) -> void:
	if value == "arrow":
		$PlayerTemplate/CanvasLayer/arrowmap.visible = true
	elif value == "open":
		$PlayerTemplate/CanvasLayer/Collect2.show()
	elif value == "questpanel":
		$PlayerTemplate/Quest.visible = true
	elif value == "COEDComplete":
		_spawn_book_rigid_body()

func ended():
	player.set_physics_process(true)

# Spawner function
func _spawn_book_rigid_body() -> void:
	if _book_spawned:
		return # already spawned

	if not book_scene:
		push_error("No Book Scene assigned to 'book_scene' export.")
		return

	if not book_spawn:
		push_error("No Book Spawn assigned to 'book_spawn' export.")
		return

	var instance = book_scene.instantiate()
	if not instance:
		push_error("Failed to instantiate book_scene.")
		return

	# Prefer adding to a physics-safe parent (e.g., root of the world). We add it as a child of the spawn node's parent
	get_tree().root.add_child(instance) # or: book_spawn.add_child(instance) depending on desired scene tree layout

	# Place it exactly at the spawn node transform
	if instance is Node3D:
		instance.global_transform = book_spawn.global_transform

	# If the instance is a RigidBody3D, you can give it a small initial velocity to make it fall/slide
	if instance is RigidBody3D:
		# Example: give a small upward impulse so it pops up slightly (change as desired)
		# In Godot 4, directly set linear_velocity for an initial push:
		instance.linear_velocity = Vector3(0, 2, 0)

	_book_spawned = true
