extends Node3D

# Choose a unique slot name for this scene/dialog
const SAVE_SLOT := "cec_dialog_resume0"
@export var locker: AnimationPlayer   
@export var toolbox: AnimationPlayer 
@export var car: AnimationPlayer 
@export var target_body: RigidBody3D   # Assign in inspector
@export var fixbtn : TextureButton # Assign in inspector
@onready var target_collision := target_body.get_node_or_null("CollisionShape3D")
@export_node_path("TextureButton") var button_path
@onready var _btn: TextureButton = get_node_or_null(button_path)
@export var target_body1: RigidBody3D
@onready var target_collision1 := target_body1.get_node_or_null("CollisionShape3D")
@export var car_body: VehicleBody3D  
@export var Questpanel: Panel
@export var anim: AnimationPlayer



func _ready() -> void:
	anim.play("Idle")
	if Global.CECfinish == true:
		Dialogic.VAR.Completequest = true
		Dialogic.VAR.CollectComplete = true
	else:
		Dialogic.VAR.Completequest = false
		Dialogic.VAR.CollectComplete = false
		Dialogic.VAR.Quest1complete = false
		Dialogic.VAR.Quest2complete = false
	car_body.set_physics_process(false)
	target_body.freeze = true
	target_body1.freeze = true

	if target_collision:
		target_collision.disabled = true
		target_collision1.disabled = true
		
	Dialogic.timeline_ended.connect(ended)
	Dialogic.start("CEC")
	$PlayerTemplate.set_physics_process(false)
	
	# Always connect your signal handler
	Dialogic.signal_event.connect(_on_dialogic_signal)
	FadeLayer.fade_in()

func _on_dialogic_signal(value: String) -> void:
	if value == "arrow":
		$PlayerTemplate/CanvasLayer/arrowmap.visible = true
	elif  value == "correct":
		locker.play("Open")
		_enable_rigidbody()
	elif value == "correctanswer":
		toolbox.play("open")
		_enable_rigidbody1()
	elif  value == "open":
		if _btn:
			_btn.visible = true
			_btn.disabled = false
			_btn.playerPhysicsDis()
	elif value == "fixbtn":
		fixbtn.visible =  true
	elif value == "questpanel":
		Questpanel.visible = true
	elif value == "CECCompleteQ":
		Global.CECfinish = true
		$questcom.visible = true
		$questcom/Node/QuestComplete.play()
		$PlayerTemplate/CanvasLayer.hide()
		
func save_dialog_progress() -> void:
	Dialogic.Save.save(SAVE_SLOT, false, Dialogic.Save.ThumbnailMode.NONE)
func ended():
	$PlayerTemplate.set_physics_process(true)
	
	
func _enable_rigidbody() -> void:
	if not target_body:
		return

	target_body.freeze = false
	if target_collision:
		target_collision.disabled = false
		
func _enable_rigidbody1() -> void:
	if not target_body1:
		return
	
	target_body1.freeze = false
	if target_collision1:
		target_collision1.disabled = false
