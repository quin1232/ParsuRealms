# CollectButton.gd
extends TextureButton

@export var pickup_area: NodePath
@onready var _pa := get_node_or_null(pickup_area)

func _ready() -> void:
	visible = false
	disabled = true
	pressed.connect(_on_pressed)

	# React to nearby changes so the button only shows when useful
	if _pa and _pa.has_signal("nearby_changed"):
		_pa.nearby_changed.connect(_on_nearby_changed)

func _on_nearby_changed(has_nearby: bool) -> void:
	visible = has_nearby
	disabled = not has_nearby

func _on_pressed() -> void:
	$"../../SoundEffecs/Collect".play()
	if _pa and _pa.has_method("PickupNearestItem"):
		_pa.PickupNearestItem()
		if Dialogic.VAR.Book == true:
			$"../../../Historybook".show()
			$"..".hide()
		elif Dialogic.VAR.corevalues == true:
			$"../../../Core Values".show()
			$"..".hide()
		elif Dialogic.VAR.vision == true:
			$"../../../Misson Vission".show()
			$"..".hide()
		visible = false
		disabled = true
