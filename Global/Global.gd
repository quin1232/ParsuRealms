extends Node

## Emitted whenever the saved player transform changes
signal spawn_changed(new_transform: Transform3D)

## User Authentication Data
var player_email: String = ""
var player_username: String = ""
var is_guest: bool = false
var is_logged_in: bool = false

## Saved spawn data
var has_spawn: bool = false
var spawn_pos: Vector3 = Vector3.ZERO
var spawn_rot_y: float = 0.0  # yaw only
var scene_index: int = 0
var IsArrowClick: bool = false

var CEDfinish: bool = false
var CECfinish: bool = false
var COSfinish: bool = false
var CBMfinish: bool = false
var CAHfinish: bool = false
var SANGAYfinish: bool = false
var SANJOSEfinish: bool = false

var finishQuest: int = 0
# =========================
# Core API
# =========================

## Set from a full Transform3D (e.g., a CharacterBody3D's global_transform)
func set_player(t: Transform3D) -> void:
	spawn_pos = t.origin
	spawn_rot_y = t.basis.get_euler().y
	has_spawn = true
	emit_signal("spawn_changed", get_spawn_transform())

## Convenience: set directly from a Node3D
func set_player_from(node: Node3D) -> void:
	if node:
		set_player(node.global_transform)

## Set using raw values
func set_position_and_yaw(pos: Vector3, yaw_radians: float) -> void:
	spawn_pos = pos
	spawn_rot_y = yaw_radians
	has_spawn = true
	emit_signal("spawn_changed", get_spawn_transform())

## Get the saved transform (position + yaw only; no pitch/roll)
func get_spawn_transform() -> Transform3D:
	var t := Transform3D.IDENTITY
	t.origin = spawn_pos
	t.basis = Basis(Vector3.UP, spawn_rot_y)
	return t

## Clear the saved spawn
func clear_spawn() -> void:
	has_spawn = false
func setfinishQuest() -> void:
	finishQuest = finishQuest + 1
func  getfinishQuest()  -> int:
	return finishQuest

# =========================
# Database Sync API
# =========================

## Save all quest progress to database
## Returns true on success, false on failure
func save_quest_progress_to_db() -> bool:
	if not Database.db_manager or not Database.db_manager.is_logged_in():
		print("Cannot save quest progress: User not logged in")
		return false
	
	var quest_data = {
		"CEDfinish": CEDfinish,
		"CECfinish": CECfinish,
		"COSfinish": COSfinish,
		"CBMfinish": CBMfinish,
		"CAHfinish": CAHfinish,
		"SANGAYfinish": SANGAYfinish,
		"SANJOSEfinish": SANJOSEfinish,
		"finishQuest": finishQuest
	}
	
	var result = await Database.db_manager.save_quest_progress(quest_data)
	if result["success"]:
		print("Quest progress saved successfully")
		return true
	else:
		var error_msg = result.get("error", "Unknown error")
		print("Failed to save quest progress: ", error_msg)
		# Check if it's a connection error
		if error_msg.contains("internet") or error_msg.contains("connection"):
			push_warning("⚠️ No internet - Quest progress saved locally only")
		return false

## Load quest progress from database
## Returns true on success, false on failure
func load_quest_progress_from_db() -> bool:
	if not Database.db_manager or not Database.db_manager.is_logged_in():
		print("Cannot load quest progress: User not logged in")
		return false
	
	var result = await Database.db_manager.load_quest_progress()
	if result["success"]:
		var data = result.get("data", {})
		if data.size() > 0:
			CEDfinish = data.get("CEDfinish", false)
			CECfinish = data.get("CECfinish", false)
			COSfinish = data.get("COSfinish", false)
			CBMfinish = data.get("CBMfinish", false)
			CAHfinish = data.get("CAHfinish", false)
			SANGAYfinish = data.get("SANGAYfinish", false)
			SANJOSEfinish = data.get("SANJOSEfinish", false)
			finishQuest = data.get("finishQuest", 0)
			print("Quest progress loaded successfully")
		else:
			print("No saved quest progress found (new player)")
		return true
	else:
		var error_msg = result.get("error", "Unknown error")
		print("Failed to load quest progress: ", error_msg)
		# Check if it's a connection error
		if error_msg.contains("internet") or error_msg.contains("connection"):
			push_warning("⚠️ No internet - Playing in offline mode")
		return false

## Mark a quest as complete and save to database
## Returns true if saved to database, false if saved locally only
func complete_quest(quest_name: String) -> bool:
	var was_already_complete = false
	
	match quest_name.to_upper():
		"CED":
			was_already_complete = CEDfinish
			CEDfinish = true
		"CEC":
			was_already_complete = CECfinish
			CECfinish = true
		"COS":
			was_already_complete = COSfinish
			COSfinish = true
		"CBM":
			was_already_complete = CBMfinish
			CBMfinish = true
		"CAH":
			was_already_complete = CAHfinish
			CAHfinish = true
		"SANGAY":
			was_already_complete = SANGAYfinish
			SANGAYfinish = true
		"SANJOSE":
			was_already_complete = SANJOSEfinish
			SANJOSEfinish = true
	
	# Only increment counter if this quest wasn't already completed
	if not was_already_complete:
		setfinishQuest()
	var saved = await save_quest_progress_to_db()
	return saved
	
