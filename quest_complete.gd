extends Control

signal all_questions_completed

# === Labels ===
@export var question_label: Label            # shows current question text
@export var expression_label: Label
@export var answer_label: Label

# === Buttons ===
@export var btn_mc: TextureButton
@export var btn_mplus: TextureButton
@export var btn_div: TextureButton
@export var btn_mul: TextureButton
@export var btn_plus: TextureButton
@export var btn_minus: TextureButton
@export var btn_equal: TextureButton
@export var btn_dot: TextureButton

@export var btn_0: TextureButton
@export var btn_1: TextureButton
@export var btn_2: TextureButton
@export var btn_3: TextureButton
@export var btn_4: TextureButton
@export var btn_5: TextureButton
@export var btn_6: TextureButton
@export var btn_7: TextureButton
@export var btn_8: TextureButton
@export var btn_9: TextureButton

# Optional: image to change when correct / incorrect answer
@export var target_image: TextureRect   # assign a TextureRect in inspector
@export var success_texture: Texture
@export var fail_texture: Texture

# Optional: nodes (e.g. choice buttons) to hide when player chooses an answer
@export var choice_nodes: Array[NodePath] = []

# === Questions array ===
# Each question is a dictionary { "prompt": String, "expected": float }
var questions: Array = [
	{"prompt": "The cost of an item is ₱100, and I want to add ₱20 as profit. 
	What’s the selling price?", "expected": 120.0},
	{"prompt": "I sold a product for ₱200, and it cost me ₱150. 
	How much is the profit?", "expected": 50.0},
	{"prompt": "If you bought 5 notebooks for ₱20 each, 
	how much did you spend in total?.", "expected": 100.0},
	{"prompt": "You earned ₱1,000 from sales and spent ₱800.
	 What’s your profit?", "expected": 200.0},
	{"prompt": "You sold 10 pens at ₱15 each. 
	What’s your total sales?", "expected": 150.0},
	
]

var question_index: int = 0

# === Variables (explicit types to avoid inference warnings) ===
var current_expression: String = ""
var memory_value: float = 0.0

# How long to show correct/wrong feedback (seconds)
const FEEDBACK_DELAY: float = 0.8

func _ready() -> void:
	FadeLayer.fade_in()
	# Connect number buttons by binding the digit with Callable.bind()
	for i in range(10):
		var prop_name: String = "btn_%d" % i
		var button: TextureButton = self.get(prop_name) as TextureButton
		if button:
			var c: Callable = Callable(self, "_on_number_pressed").bind(str(i))
			button.pressed.connect(c)

	# Connect operator buttons (bind operators explicitly)
	if btn_plus:
		btn_plus.pressed.connect(Callable(self, "_on_operator_pressed").bind("+"))
	if btn_minus:
		btn_minus.pressed.connect(Callable(self, "_on_operator_pressed").bind("-"))
	if btn_mul:
		btn_mul.pressed.connect(Callable(self, "_on_operator_pressed").bind("*"))
	if btn_div:
		btn_div.pressed.connect(Callable(self, "_on_operator_pressed").bind("/"))
	if btn_dot:
		btn_dot.pressed.connect(Callable(self, "_on_operator_pressed").bind("."))

	if btn_equal:
		btn_equal.pressed.connect(Callable(self, "_on_equal_pressed"))
	if btn_mc:
		btn_mc.pressed.connect(Callable(self, "_on_mc_pressed"))
	if btn_mplus:
		btn_mplus.pressed.connect(Callable(self, "_on_mplus_pressed"))

	# Init UI
	if expression_label:
		expression_label.text = ""
	if answer_label:
		answer_label.text = ""
	_load_question()

# -------------------------
# Input handlers
# -------------------------
func _on_number_pressed(num: String) -> void:
	# hide choice nodes if set
	for path in choice_nodes:
		var node: Node = get_node_or_null(path)
		if node and node.is_visible_in_tree():
			node.visible = false

	current_expression += num
	_update_expression_label()

func _on_operator_pressed(op: String) -> void:
	# Prevent some invalid starting operators
	if current_expression == "" and op in ["+", "*", "/", "."]:
		return

	# If last char is an operator and new is operator (not '.'), replace it
	if current_expression != "":
		var last_char: String = current_expression.substr(current_expression.length() - 1, 1)
		# use is_valid_int() to test if last_char is a digit
		if (not last_char.is_valid_int()) and last_char != "." and op != ".":
			current_expression = current_expression.substr(0, current_expression.length() - 1) + op
			_update_expression_label()
			return

	current_expression += op
	_update_expression_label()

func _on_equal_pressed() -> void:
	if current_expression.strip_edges() == "":
		return

	var expr: Expression = Expression.new()
	var err: int = expr.parse(current_expression)
	if err != OK:
		_set_answer_text("= ERROR")
		_set_image_on_answer(false)
		return

	var exec_result: Variant = expr.execute()
	if expr.has_execute_failed():
		_set_answer_text("= ERROR")
		_set_image_on_answer(false)
		return

	# numeric handling
	if typeof(exec_result) in [TYPE_FLOAT, TYPE_INT]:
		var numeric_result: float = float(exec_result)

		# Format and display
		var display: String = _format_number(numeric_result)
		_set_answer_text("= " + display)

		# check against current question's expected answer
		var expected: Variant = _current_expected()
		if expected != null and typeof(expected) in [TYPE_FLOAT, TYPE_INT] and abs(numeric_result - float(expected)) <= 0.0001:
			# correct -> advance after showing success feedback
			await _show_correct_feedback(numeric_result)
			_advance_question()
		else:
			# show wrong feedback (keeps expression so player can edit/try again)
			await _show_wrong_feedback(numeric_result)
	else:
		_set_answer_text("= " + str(exec_result))
		_set_image_on_answer(false)

func _on_mc_pressed() -> void:
	memory_value = 0.0
	current_expression = ""
	_update_expression_label()
	if answer_label:
		answer_label.text = ""

func _on_mplus_pressed() -> void:
	if current_expression.strip_edges() == "":
		return
	var expr: Expression = Expression.new()
	if expr.parse(current_expression) != OK:
		return
	var exec_result: Variant = expr.execute()
	if expr.has_execute_failed():
		return
	if typeof(exec_result) in [TYPE_FLOAT, TYPE_INT]:
		memory_value += float(exec_result)
		if answer_label:
			answer_label.text = "= MEM " + _format_number(memory_value)

# -------------------------
# Feedback helpers
# -------------------------
# Show a brief "Correct" feedback, then continue
func _show_correct_feedback(numeric_result: float) -> void:
	_set_image_on_answer(true)
	if answer_label:
		answer_label.text = "CORRECT (" + _format_number(numeric_result) + ")"
	# wait so player can see it
	await get_tree().create_timer(FEEDBACK_DELAY).timeout
	# optionally clear answer label or leave the correct message; we'll clear so next question shows fresh
	if answer_label:
		answer_label.text = ""

# Show a brief "Wrong" feedback, then restore result display so player can retry
func _show_wrong_feedback(numeric_result: float) -> void:
	_set_image_on_answer(false)
	if answer_label:
		answer_label.text = "INCORRECT"
	# wait so player can see the wrong feedback
	await get_tree().create_timer(FEEDBACK_DELAY).timeout
	# After the delay, show the numeric result again (or clear)
	if answer_label:
		# keep the numeric result shown so player sees what they produced
		answer_label.text = "= " + _format_number(numeric_result)

# -------------------------
# Question management
# -------------------------
func _load_question() -> void:
	if questions.is_empty():
		if question_label:
			question_label.text = "No questions available."
		return

	# Clamp index
	if question_index < 0:
		question_index = 0
	if question_index >= questions.size():
		# all done
		if question_label:
			question_label.text = "All questions completed!"
		if answer_label:
			answer_label.text = ""
		if expression_label:
			expression_label.text = ""
		emit_signal("all_questions_completed")
		$"../PlayerTemplate/CanvasLayer/run".show()
		$"../PlayerTemplate/CanvasLayer/jump".show()
		$"../PlayerTemplate/CanvasLayer/Virtual Joystick".show()
		$"../PlayerTemplate/CanvasLayer/Mini Map".show()
		self.visible = false # <-- Hide this node after completion
		Dialogic.VAR.Completequest = true
		Dialogic.start("CBM", "Completequest")
		return

	var q: Dictionary = questions[question_index]
	if question_label:
		question_label.text = q.get("prompt", "Question " + str(question_index + 1))
	# clear expression & answer so player starts fresh for the question
	current_expression = ""
	_update_expression_label()
	if answer_label:
		answer_label.text = ""

func _advance_question() -> void:
	question_index += 1
	_load_question()

# Allow returning null, so use Variant
func _current_expected() -> Variant:
	if questions.is_empty() or question_index >= questions.size():
		return null
	var q: Dictionary = questions[question_index]
	return q.get("expected", null)

# -------------------------
# Helpers & UI utils
# -------------------------
func _update_expression_label() -> void:
	if expression_label:
		expression_label.text = current_expression

func _set_answer_text(text: String) -> void:
	if answer_label:
		answer_label.text = text

func _format_number(n: float) -> String:
	if abs(n - round(n)) <= 0.000001:
		return str(int(round(n)))
	return str(n)

func _set_image_on_answer(correct: bool) -> void:
	if target_image == null:
		return
	if correct:
		if success_texture:
			target_image.texture = success_texture
	else:
		if fail_texture:
			target_image.texture = fail_texture
