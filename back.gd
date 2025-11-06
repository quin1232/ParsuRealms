extends TextureButton

func _on_pressed() -> void:
	$"../../Panel".show()
	$"..".hide()
