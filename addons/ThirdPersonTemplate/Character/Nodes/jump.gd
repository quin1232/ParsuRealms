extends TextureButton

var active_touch_index = null

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			active_touch_index = event.index
			emit_signal("pressed")
		elif not event.pressed and event.index == active_touch_index:
			active_touch_index = null
			emit_signal("released")

