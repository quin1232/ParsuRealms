extends Control

signal quest_set_completed(set_index: int, set_data: Array)

@export var label1: Label
@export var checkbox1: CheckBox
@export var label2: Label
@export var checkbox2: CheckBox
@export var glow: Node3D

@export_node_path("Area3D") var pickup_area_path: NodePath = NodePath()

# ─────────────────────────────────────────────
# DIALOG MAP: item name -> Dialogic {timeline, label}
# ─────────────────────────────────────────────
const ITEM_DIALOGS: Dictionary = {
	"clock":         {"timeline": "COEDtask", "label": "ClockFound"},
	"answer sheets": {"timeline": "COEDtask", "label": "AnswerSheetsFound"},
	"battery":       {"timeline": "CEC",  "label": "BatteryFound"},
	"spark plug":    {"timeline": "CEC",  "label": "SparkPlugFound"},
	"calculator":    {"timeline": "CBM",  "label": "CalculatorFound"},
	"ledger":    {"timeline": "CBM",  "label": "LedgerFound"},
	"fishing rod":    {"timeline": "sangay",  "label": "FishingrodFound"},
	"fishing bait":    {"timeline": "sangay",  "label": "FishingbaitFound"},
}

# Quests (two items per set)
var quest_sets: Array = [
	[
		{"name": "Clock", "completed": false},
		{"name": "Answer Sheets", "completed": false},
	],
	[
		{"name": "Battery", "completed": false},
		{"name": "Spark Plug", "completed": false}
	],
	[
		{"name": "Battery", "completed": false},
		{"name": "Spark Plug", "completed": false}
	],
	[
		{"name": "Battery", "completed": false},
		{"name": "Spark Plug", "completed": false}
	],
	[
		{"name": "Calculator", "completed": false},
		{"name": "Ledger", "completed": false}
	],
	[
		{"name": "Fishing Rod", "completed": false},
		{"name": "Fishing Bait", "completed": false}
	]
	
	
]

var current_set_index: int = 0

# Prevent double-firing per set
var _completion_fired_for_set: Array = []

# Prevent per-item dialog re-triggers (e.g., {"battery": true})
var _dialog_fired_for_item: Dictionary = {}   # you can also type as Dictionary[String, bool] in 4.3+

func _ready() -> void:
	# init set-complete flags
	_completion_fired_for_set.resize(quest_sets.size())
	for i in _completion_fired_for_set.size():
		_completion_fired_for_set[i] = false

	# choose quest set based on your global selector
	if GlobalTracking.get_selected_college() == 0:
		show_quest(0)
	elif GlobalTracking.get_selected_college() == 1:
		show_quest(1)
	elif GlobalTracking.get_selected_college() == 4:
		show_quest(4)

	# UI wiring
	checkbox1.toggled.connect(_on_checkbox_toggled)
	checkbox2.toggled.connect(_on_checkbox_toggled)

	# Wire pickup signal (Area3D script should emit: signal OnItemPickedUp(item: ItemData))
	if pickup_area_path != NodePath():
		var pickup := get_node_or_null(pickup_area_path)
		if pickup and pickup.has_signal("OnItemPickedUp"):
			pickup.OnItemPickedUp.connect(_on_item_picked)

# ─────────────────────────────────────────────
# UI: show a quest set in labels/checkboxes
# ─────────────────────────────────────────────
func show_quest(set_index: int) -> void:
	if set_index < 0 or set_index >= quest_sets.size():
		push_warning("Invalid quest set index!")
		return

	current_set_index = set_index
	var cur: Array = quest_sets[set_index]

	var q0: Dictionary = cur[0]
	var q1: Dictionary = cur[1]

	label1.text = String(q0["name"])
	checkbox1.button_pressed = bool(q0["completed"])

	label2.text = String(q1["name"])
	checkbox2.button_pressed = bool(q1["completed"])

	# In case it was already completed
	_check_completion_and_trigger()

# Mark an item as collected (by display name)
func mark_collected_by_name(item_name: String) -> bool:
	var found: bool = false
	var name_l: String = item_name.strip_edges().to_lower()

	# Update data across ALL sets
	for s in quest_sets:
		var arr: Array = s
		for i in arr.size():
			var dq: Dictionary = arr[i]
			if String(dq["name"]).to_lower() == name_l:
				dq["completed"] = true
				found = true

	# Reflect in the CURRENT set’s checkboxes
	if found:
		var cur: Array = quest_sets[current_set_index]
		var q0: Dictionary = cur[0]
		var q1: Dictionary = cur[1]
		checkbox1.button_pressed = bool(q0["completed"])
		checkbox2.button_pressed = bool(q1["completed"])
		print("✅ Collected: %s" % item_name)
		_check_completion_and_trigger()
	else:
		print("⚠️ No quest named '%s' in any set." % item_name)

	return found

# ─────────────────────────────────────────────
# PICKUP + CHECKBOX HANDLERS
# ─────────────────────────────────────────────
func _on_item_picked(item: ItemData) -> void:
	# 1) reflect in quest UI
	mark_collected_by_name(item.ItemName)
	# 2) trigger the item-specific dialog (Battery, etc.)
	_trigger_item_dialog(item.ItemName)

func _on_checkbox_toggled(_pressed: bool) -> void:
	var cur: Array = quest_sets[current_set_index]
	var q0: Dictionary = cur[0]
	var q1: Dictionary = cur[1]
	q0["completed"] = checkbox1.button_pressed
	q1["completed"] = checkbox2.button_pressed

	# If a checkbox just became checked, attempt to trigger its dialog for that item
	if checkbox1.button_pressed:
		_trigger_item_dialog(label1.text)
	if checkbox2.button_pressed:
		_trigger_item_dialog(label2.text)

	_check_completion_and_trigger()

# ─────────────────────────────────────────────
# ITEM-SPECIFIC DIALOGIC TRIGGER (await instead of lambda)
# ─────────────────────────────────────────────
func _trigger_item_dialog(item_name: String) -> void:
	var key := item_name.strip_edges().to_lower()

	# avoid duplicate dialog for same item
	if bool(_dialog_fired_for_item.get(key, false)):
		return

	if ITEM_DIALOGS.has(key):
		var info: Dictionary = ITEM_DIALOGS[key]  # explicit type fixes inference

		# Mark as fired now to avoid races if called twice quickly
		_dialog_fired_for_item[key] = true
		
		var timeline := String(info.get("timeline", ""))
		var label := String(info.get("label", ""))

		if timeline.is_empty():
			push_warning("ITEM_DIALOGS for '%s' has no 'timeline'." % key)
			return

		Dialogic.start(timeline, label)
	else:
		print("ℹ️ No dialog mapped for item: %s" % item_name)

# ─────────────────────────────────────────────
# SET COMPLETION → REWARD / DIALOG
# ─────────────────────────────────────────────
func _is_set_complete(i: int) -> bool:
	if i < 0 or i >= quest_sets.size():
		return false
	var cur: Array = quest_sets[i]
	if cur.size() < 2:
		return false
	return bool(cur[0]["completed"]) and bool(cur[1]["completed"])

func _check_completion_and_trigger() -> void:
	if _is_set_complete(current_set_index) and not _completion_fired_for_set[current_set_index]:
		_completion_fired_for_set[current_set_index] = true
		emit_signal("quest_set_completed", current_set_index, quest_sets[current_set_index])
		_on_quest_set_completed(current_set_index)

func _on_quest_set_completed(_set_index: int) -> void:
	Dialogic.VAR.CollectComplete = true
	if GlobalTracking.get_selected_college() == 1: 
		Dialogic.start("CEC1", "CollectComplete")
		print(Dialogic.VAR.Completequest)
		print("hello")
		if glow:
			glow.visible = true
	elif GlobalTracking.get_selected_college() == 0:
		Dialogic.start("COEDtask", "CollectComplete")
	elif GlobalTracking.get_selected_college() == 4:
		Dialogic.start("CBM", "CollectComplete")
	
		
