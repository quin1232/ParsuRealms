extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.SANGAYfinish == true:
		show()
		$"../PlayerTemplate/CanvasLayer".hide()
	else:
		hide()
		
