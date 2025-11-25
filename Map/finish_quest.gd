extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Just display the current quest count - don't increment it here
	# The Global.complete_quest() function handles incrementing when quests are completed
	_update_display()

func _update_display() -> void:
	text = str(Global.finishQuest) + "/7"
