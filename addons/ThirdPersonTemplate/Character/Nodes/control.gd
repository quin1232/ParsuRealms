# LookPad.gd
extends Control
signal look_delta(rel: Vector2)

var finger: int = -1
var mouse_drag: bool = false

func _ready() -> void:
	# This stops events under this pad from reaching other nodes.
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	# Touch: press to claim, drag to emit, release to stop
	if event is InputEventScreenTouch:
		if event.pressed:
			finger = event.index
			accept_event()
		else:
			if event.index == finger:
				finger = -1
			accept_event()
	elif event is InputEventScreenDrag:
		if event.index == finger:
			emit_signal("look_delta", event.relative)
			accept_event()

	# Mouse (desktop testing): hold LMB and move
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_drag = event.pressed
		accept_event()
	elif event is InputEventMouseMotion and mouse_drag:
		emit_signal("look_delta", event.relative)
		accept_event()
