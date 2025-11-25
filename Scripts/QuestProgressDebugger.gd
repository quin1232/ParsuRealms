extends Node

## Quest Progress Debugger
## Attach this to any node in your scene to test quest progress saving/loading
## Press the assigned keys to test various functions

# Keyboard shortcuts for testing
const KEY_SAVE = KEY_F5        # F5: Save current progress
const KEY_LOAD = KEY_F6        # F6: Load progress from database
const KEY_COMPLETE_CED = KEY_1 # 1: Complete CED quest
const KEY_COMPLETE_CEC = KEY_2 # 2: Complete CEC quest
const KEY_COMPLETE_COS = KEY_3 # 3: Complete COS quest
const KEY_RESET = KEY_F8       # F8: Reset all progress
const KEY_STATUS = KEY_F9      # F9: Print current status

func _ready():
	print("=== Quest Progress Debugger Loaded ===")
	print("F5: Save Progress | F6: Load Progress")
	print("1: Complete CED | 2: Complete CEC | 3: Complete COS")
	print("F8: Reset All | F9: Show Status")
	print("=====================================")

func _input(event: InputEvent):
	if not event is InputEventKey or not event.pressed:
		return
	
	match event.keycode:
		KEY_SAVE:
			_test_save_progress()
		KEY_LOAD:
			_test_load_progress()
		KEY_COMPLETE_CED:
			_test_complete_quest("CED")
		KEY_COMPLETE_CEC:
			_test_complete_quest("CEC")
		KEY_COMPLETE_COS:
			_test_complete_quest("COS")
		KEY_RESET:
			_test_reset_progress()
		KEY_STATUS:
			_print_status()

func _test_save_progress():
	print("\n[TEST] Saving quest progress...")
	if not Global.is_logged_in:
		print("❌ Cannot save: User not logged in")
		return
	
	await Global.save_quest_progress_to_db()
	print("✅ Save operation completed")

func _test_load_progress():
	print("\n[TEST] Loading quest progress...")
	if not Global.is_logged_in:
		print("❌ Cannot load: User not logged in")
		return
	
	await Global.load_quest_progress_from_db()
	print("✅ Load operation completed")
	_print_status()

func _test_complete_quest(quest_name: String):
	print("\n[TEST] Completing quest: ", quest_name)
	if not Global.is_logged_in:
		print("❌ Cannot complete: User not logged in")
		print("ℹ️  Quest marked locally (not saved to database)")
		_complete_quest_locally(quest_name)
		return
	
	await Global.complete_quest(quest_name)
	print("✅ Quest completed and saved")
	_print_status()

func _test_reset_progress():
	print("\n[TEST] Resetting all progress...")
	Global.CEDfinish = false
	Global.CECfinish = false
	Global.COSfinish = false
	Global.CBMfinish = false
	Global.CAHfinish = false
	Global.SANGAYfinish = false
	Global.SANJOSEfinish = false
	Global.finishQuest = 0
	
	if Global.is_logged_in:
		await Global.save_quest_progress_to_db()
		print("✅ Progress reset and saved to database")
	else:
		print("⚠️  Progress reset locally only (not logged in)")
	
	_print_status()

func _complete_quest_locally(quest_name: String):
	match quest_name.to_upper():
		"CED":
			Global.CEDfinish = true
		"CEC":
			Global.CECfinish = true
		"COS":
			Global.COSfinish = true
		"CBM":
			Global.CBMfinish = true
		"CAH":
			Global.CAHfinish = true
		"SANGAY":
			Global.SANGAYfinish = true
		"SANJOSE":
			Global.SANJOSEfinish = true
	Global.setfinishQuest()
	_print_status()

func _print_status():
	print("\n========== QUEST STATUS ==========")
	print("Login Status: ", "✅ Logged In" if Global.is_logged_in else "❌ Not Logged In")
	print("Guest Mode: ", "Yes" if Global.is_guest else "No")
	print("Username: ", Global.player_username if not Global.player_username.is_empty() else "N/A")
	print("Email: ", Global.player_email if not Global.player_email.is_empty() else "N/A")
	print("-----------------------------------")
	print("CED Quest: ", "✅ Complete" if Global.CEDfinish else "❌ Incomplete")
	print("CEC Quest: ", "✅ Complete" if Global.CECfinish else "❌ Incomplete")
	print("COS Quest: ", "✅ Complete" if Global.COSfinish else "❌ Incomplete")
	print("CBM Quest: ", "✅ Complete" if Global.CBMfinish else "❌ Incomplete")
	print("CAH Quest: ", "✅ Complete" if Global.CAHfinish else "❌ Incomplete")
	print("SANGAY Quest: ", "✅ Complete" if Global.SANGAYfinish else "❌ Incomplete")
	print("SANJOSE Quest: ", "✅ Complete" if Global.SANJOSEfinish else "❌ Incomplete")
	print("-----------------------------------")
	print("Total Quests Completed: ", Global.finishQuest)
	print("==================================\n")

# Optional: Auto-print status on ready
func _on_ready_print_status():
	await get_tree().create_timer(1.0).timeout
	_print_status()
