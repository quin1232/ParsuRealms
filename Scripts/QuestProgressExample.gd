extends Node

# Example Quest Completion Handler
# This script shows how to properly complete quests and save progress

# Call this when a quest is completed
func complete_quest_and_save(quest_name: String) -> void:
	print("Quest completed: ", quest_name)
	
	# Use the helper method which automatically saves to database
	await Global.complete_quest(quest_name)
	
	# Optional: Show completion message or reward
	_show_quest_completion_ui(quest_name)

# Alternative: Manual completion with explicit save
func complete_quest_manual(quest_name: String) -> void:
	# Update the specific quest flag
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
	
	# Increment counter
	Global.setfinishQuest()
	
	# Save to database
	await Global.save_quest_progress_to_db()
	
	print("Quest ", quest_name, " saved to database")

# Example: Check if quest is already completed
func is_quest_completed(quest_name: String) -> bool:
	match quest_name.to_upper():
		"CED":
			return Global.CEDfinish
		"CEC":
			return Global.CECfinish
		"COS":
			return Global.COSfinish
		"CBM":
			return Global.CBMfinish
		"CAH":
			return Global.CAHfinish
		"SANGAY":
			return Global.SANGAYfinish
		"SANJOSE":
			return Global.SANJOSEfinish
	return false

# Example: Check quest requirements before starting
func can_start_quest(quest_name: String) -> bool:
	# Example: CEC requires CED to be completed first
	if quest_name == "CEC" and not Global.CEDfinish:
		print("Complete CED quest first!")
		return false
	
	# Check if already completed
	if is_quest_completed(quest_name):
		print("Quest already completed!")
		return false
	
	return true

# Example: Periodic auto-save (call this from a Timer)
func auto_save_progress() -> void:
	if Global.is_logged_in and not Global.is_guest:
		await Global.save_quest_progress_to_db()
		print("Progress auto-saved at: ", Time.get_time_string_from_system())

# Example: Save on scene change
func _ready():
	# Connect to scene changes for auto-save
	get_tree().node_added.connect(_on_scene_changed)

func _on_scene_changed(_node):
	# Save progress when changing scenes
	if Global.is_logged_in and not Global.is_guest:
		Global.save_quest_progress_to_db()

# Example UI feedback
func _show_quest_completion_ui(quest_name: String):
	# Show a completion popup or animation
	print("🎉 Quest Completed: ", quest_name)
	print("Total Quests Completed: ", Global.finishQuest)

# Example: Batch complete multiple quests (testing/debug)
func complete_multiple_quests(quest_names: Array) -> void:
	for quest_name in quest_names:
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
	
	# Save once after all updates
	await Global.save_quest_progress_to_db()
	print("Completed ", quest_names.size(), " quests")

# Example: Reset all progress (testing/debug)
func reset_all_progress() -> void:
	Global.CEDfinish = false
	Global.CECfinish = false
	Global.COSfinish = false
	Global.CBMfinish = false
	Global.CAHfinish = false
	Global.SANGAYfinish = false
	Global.SANJOSEfinish = false
	Global.finishQuest = 0
	
	# Save reset state to database
	await Global.save_quest_progress_to_db()
	print("All quest progress reset")
