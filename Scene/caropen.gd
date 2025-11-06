extends Area3D

@export var allowed_body: Node3D
@export var fixbtn: TextureButton
			  # Only this body can trigger (leave empty to allow anyone)
@export var trigger_once: bool = true              # If true, interaction happens once then the area disables
@export_node_path("TextureButton") var button_path # Assign your TextureButton in the Inspector

var _fired := false
@onready var _btn: TextureButton = get_node_or_null(button_path)

func _ready() -> void:
	# Signals for enter/exit
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	Dialogic.VAR.CollectComplete = false

	# Start hidden/disabled for safety
	if _btn:
		_btn.visible = false
		_btn.disabled = true

func _on_body_entered(body: Node) -> void:
	if Dialogic.VAR.carFixed == true:
		return
	if _fired:
		return
	if allowed_body and body != allowed_body:
		return
	Dialogic.VAR.Cardialog = true
	Dialogic.VAR.Car = true
	Dialogic.start("CEC", "Cardialog")
	allowed_body.set_physics_process(false)
	$"../PlayerTemplate".play_idle(true)

func _on_body_exited(body: Node) -> void:
	if _fired:
		return
	if allowed_body and body != allowed_body:
		return
	# Hide the button when the player leaves
	Dialogic.VAR.Cardialog = false
	fixbtn.visible =  false
	if _btn:
		_btn.visible = false
		_btn.disabled = true
	if trigger_once:
		_fired = true
		if _btn:
			_btn.visible = false
			_btn.disabled = true
		# Defer to avoid changing monitoring during signal emission
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
