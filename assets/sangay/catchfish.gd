extends Control


@export var questions := [
	{
		"q":"res://assets/sangay/fish/carp.png",
		"options": ["Carp", "Milk Fish", "Eel"],
		"correct": 0
	},
	{
		"q": "res://assets/sangay/fish/Tilapia.png",
		"options": ["Milk Fish", "Carp", "Tilapia"],
		"correct": 2
	},
	{
		"q": "res://assets/sangay/fish/catfish.png",
		"options": ["Crab", "Cat Fish", "Mud Carp"],
		"correct": 1
	}
]

# Node references
@onready var img      : TextureRect = $Panel/VBoxContainer/HBoxContainer/TextureRect
@onready var choice0  : Button      = $Panel/VBoxContainer/Button
@onready var choice1  : Button      = $Panel/VBoxContainer/Button2
@onready var choice2  : Button      = $Panel/VBoxContainer/Button3
@onready var feedback : Label       = $Panel/Label


var buttons : Array = []
var current_index : int = 0
var answered : bool = false
var quiz_completed: bool = false

func _ready() -> void:
	buttons = [choice0, choice1, choice2]
	# Connect each button's pressed signal and pass its index as an extra arg
	for i in range(buttons.size()):
		if buttons[i].pressed.is_connected(Callable(self, "_on_choice_pressed")):
			buttons[i].pressed.disconnect(Callable(self, "_on_choice_pressed"))
		buttons[i].pressed.connect(Callable(self, "_on_choice_pressed").bind(i))
	show_question(current_index)

func show_question(idx: int) -> void:
	if quiz_completed:
		return
	# end condition
	if idx < 0 or idx >= questions.size():
		img.texture = null
		feedback.text = "Quiz finished."
		for b in buttons:
			b.disabled = true
			b.visible = false
		on_quiz_complete()
		return

	var qdata = questions[idx]

	# load the question image (string path expected)
	img.modulate = Color(1, 1, 1) # reset tint
	if typeof(qdata.q) == TYPE_STRING and qdata.q != "":
		var tex = load(qdata.q)
		if tex and tex is Texture2D:
			img.texture = tex
		else:
			img.texture = null
			push_warning("Could not load texture at: %s" % str(qdata.q))
	else:
		img.texture = null

	# populate buttons from qdata.options (safe against missing entries)
	for i in range(buttons.size()):
		var opt_text := ""
		if qdata.has("options") and i < qdata.options.size():
			opt_text = str(qdata.options[i])
		buttons[i].text = opt_text
		buttons[i].disabled = false
		buttons[i].visible = true
		buttons[i].modulate = Color(1, 1, 1)

	# clear feedback and state
	feedback.text = ""
	answered = false

func _on_choice_pressed(choice_idx: int) -> void:
	if answered or quiz_completed:
		return
	answered = true

	var qdata = questions[current_index]
	var correct_idx : int = int(qdata.correct)

	# correct branch
	if choice_idx == correct_idx:
		feedback.text = "Correct!"
		Dialogic.start("sangay", "correct")
		await get_tree().create_timer(1.0).timeout
		current_index += 1
		self.visible = true
		$"../FishingMinigame".show()
		$"../FishingMinigame".restart()
		show_question(current_index)
	else:
		on_incorrect_answer(choice_idx, correct_idx)

func on_incorrect_answer(choice_idx: int, correct_idx: int) -> void:
	feedback.text = "Wrong."
	Dialogic.start("sangay", "Wrong")
	$"../FishingMinigame".show()
	$"../FishingMinigame".restart()
	# disable and tint the wrong button
	if choice_idx >= 0 and choice_idx < buttons.size():
		buttons[choice_idx].disabled = true
		buttons[choice_idx].modulate = Color(1.0, 0.85, 0.85)
	answered = false

func on_quiz_complete() -> void:
	quiz_completed = true
	hide()
	$"../PlayerTemplate/CanvasLayer".hide()
	Dialogic.start("sangay", "complete")
	$"../Glow/fishing".hide()
	$"../Glow/fishing/CollisionShape3D".disabled = true
