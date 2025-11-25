extends Node



# Supabase Configuration loaded from Config.gd
const SUPABASE_URL = "https://blfsxyphkeuoddnepbvw.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJsZnN4eXBoa2V1b2RkbmVwYnZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MDY2MDUsImV4cCI6MjA3ODA4MjYwNX0.-VH1FhhUlwGCbx28KVe6gRlJeJ79ppM60yY9S0aaufQ"

# API Endpoints
const AUTH_SIGNUP_URL = "/auth/v1/signup"
const AUTH_LOGIN_URL = "/auth/v1/token?grant_type=password"

# Current user data
var current_user = null
var auth_token = null

func _ready():
	pass

# Register a new user
func signup(email: String, password: String, username: String) -> Dictionary:
	if not _validate_credentials(email, password, username):
		return {"success": false, "error": "Invalid input"}
	
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY
	]
	
	var body = JSON.stringify({
		"email": email,
		"password": password,
		"data": {
			"username": username
		}
	})
	
	var url = SUPABASE_URL + AUTH_SIGNUP_URL
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		http.queue_free()
		return {"success": false, "error": "No internet connection. Please check your network and try again."}
	
	var response = await http.request_completed
	http.queue_free()
	
	var status_code = response[1]
	var response_text = response[3].get_string_from_utf8()
	
	# Debug output - DETAILED
	print("=== SIGNUP DEBUG ===")
	print("Status Code: ", status_code)
	print("Raw Response: ", response_text)
	
	# Parse JSON safely
	var response_body = null
	if not response_text.is_empty():
		response_body = JSON.parse_string(response_text)
		if response_body == null:
			print("Warning: Failed to parse JSON response")
	
	print("Parsed Body: ", response_body)
	if response_body and typeof(response_body) == TYPE_DICTIONARY:
		print("Body Keys: ", response_body.keys())
		if "error" in response_body:
			print("Error field: ", response_body["error"])
		if "message" in response_body:
			print("Message field: ", response_body["message"])
		if "error_description" in response_body:
			print("Error Description: ", response_body["error_description"])
	print("===================")
	
	if status_code == 200 or status_code == 201:
		# Check if this is a duplicate registration attempt
		# Supabase returns 200 even for duplicates if email is unconfirmed
		# Key indicator: look for very recent created_at matching confirmation_sent_at
		if response_body and "id" in response_body:
			# Try to detect if this is a re-send by checking the response
			# New users have matching created_at and confirmation_sent_at (within milliseconds)
			# Re-registrations might have been created earlier
			
			# Alternative check: Use a simple heuristic
			# If identities array is empty, user hasn't confirmed email yet
			# This could mean it's a new signup OR a duplicate unconfirmed signup
			# We can't reliably distinguish, but we'll show a helpful message
			
			# For now, just return success and let them know to check email
			pass
		
		return {"success": true, "data": response_body}
	else:
		var error_message = "Registration failed"
		if response_body:
			# Check multiple possible error fields from Supabase
			if "error_description" in response_body:
				error_message = response_body["error_description"]
			elif "message" in response_body:
				error_message = response_body["message"]
			elif "msg" in response_body:
				error_message = response_body["msg"]
			elif "error" in response_body:
				var error_val = response_body["error"]
				if typeof(error_val) == TYPE_STRING:
					error_message = error_val
				elif typeof(error_val) == TYPE_DICTIONARY and "message" in error_val:
					error_message = error_val["message"]
				else:
					error_message = str(error_val)
		
		# Log the full error for debugging
		print("Signup Error Message: ", error_message)
		return {"success": false, "error": error_message}

# Login an existing user
func login(email: String, password: String) -> Dictionary:
	if email.is_empty() or password.is_empty():
		return {"success": false, "error": "Email and password required"}
	
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY
	]
	
	var body = JSON.stringify({
		"email": email,
		"password": password
	})
	
	var url = SUPABASE_URL + AUTH_LOGIN_URL
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		http.queue_free()
		return {"success": false, "error": "No internet connection. Please check your network and try again."}
	
	var response = await http.request_completed
	http.queue_free()
	
	var status_code = response[1]
	var response_text = response[3].get_string_from_utf8()
	
	# Debug output
	print("Login Status Code: ", status_code)
	print("Login Response Text: ", response_text)
	
	# Parse JSON safely
	var response_body = null
	if not response_text.is_empty():
		response_body = JSON.parse_string(response_text)
		if response_body == null:
			print("Error: Failed to parse login response JSON")
			return {"success": false, "error": "Invalid response from server"}
	
	print("Login Response Body: ", response_body)
	
	if status_code == 200:
		# Save user data
		if response_body and typeof(response_body) == TYPE_DICTIONARY and "access_token" in response_body:
			auth_token = response_body["access_token"]
			current_user = response_body.get("user", {})
			return {"success": true, "data": response_body}
	
	var error_message = "Login failed"
	if response_body and typeof(response_body) == TYPE_DICTIONARY:
		if "error_description" in response_body:
			error_message = response_body["error_description"]
		elif "error" in response_body:
			error_message = response_body["error"]
		elif "msg" in response_body:
			error_message = response_body["msg"]
	elif not response_text.is_empty():
		error_message = "Server error: " + response_text
	
	return {"success": false, "error": error_message}

# Logout
func logout():
	current_user = null
	auth_token = null

# Validate input
func _validate_credentials(email: String, password: String, username: String = "") -> bool:
	if email.is_empty() or not _is_valid_email(email):
		return false
	if password.length() < 6:
		return false
	if username != "":
		if username.length() < 3 or username.length() > 10:
			return false
	return true

# Simple email validation
func _is_valid_email(email: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email) != null

# Get current user
func get_current_user() -> Dictionary:
	return current_user if current_user else {}

# Check if user is logged in
func is_logged_in() -> bool:
	return auth_token != null

# =========================
# Player Progress API
# =========================

# Save quest completion data to database
func save_quest_progress(quest_data: Dictionary) -> Dictionary:
	if not is_logged_in():
		return {"success": false, "error": "User not logged in"}
	
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + auth_token,
		"Prefer: resolution=merge-duplicates"
	]
	
	# Get user ID
	var user_id = current_user.get("id", "")
	if user_id.is_empty():
		http.queue_free()
		return {"success": false, "error": "User ID not found"}
	
	# Prepare quest data for upsert
	var body = JSON.stringify({
		"id": user_id,
		"ced_finish": quest_data.get("CEDfinish", false),
		"cec_finish": quest_data.get("CECfinish", false),
		"cos_finish": quest_data.get("COSfinish", false),
		"cbm_finish": quest_data.get("CBMfinish", false),
		"cah_finish": quest_data.get("CAHfinish", false),
		"sangay_finish": quest_data.get("SANGAYfinish", false),
		"sanjose_finish": quest_data.get("SANJOSEfinish", false),
		"finish_quest_count": quest_data.get("finishQuest", 0),
		"last_played": Time.get_datetime_string_from_system(true)
	})
	
	# Upsert to player_progress table
	var url = SUPABASE_URL + "/rest/v1/player_progress"
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		http.queue_free()
		return {"success": false, "error": "No internet connection. Could not save quest progress."}
	
	var response = await http.request_completed
	http.queue_free()
	
	var status_code = response[1]
	var response_text = response[3].get_string_from_utf8()
	
	print("Quest Save Status: ", status_code)
	print("Quest Save Response Text: ", response_text)
	
	# Parse JSON only if response is not empty
	var response_body = null
	if not response_text.is_empty():
		response_body = JSON.parse_string(response_text)
		if response_body == null:
			print("Warning: Failed to parse JSON response, but status is ", status_code)
	
	if status_code == 200 or status_code == 201 or status_code == 204:
		# 204 No Content is success for upsert operations
		return {"success": true, "data": response_body if response_body else {}}
	else:
		var error_message = "Failed to save quest progress"
		if response_body and typeof(response_body) == TYPE_DICTIONARY and "message" in response_body:
			error_message = response_body["message"]
		elif not response_text.is_empty():
			error_message = "Server error: " + response_text
		return {"success": false, "error": error_message}

# Load quest completion data from database
func load_quest_progress() -> Dictionary:
	if not is_logged_in():
		return {"success": false, "error": "User not logged in"}
	
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + auth_token
	]
	
	# Get user ID
	var user_id = current_user.get("id", "")
	if user_id.is_empty():
		http.queue_free()
		return {"success": false, "error": "User ID not found"}
	
	# Query player_progress table
	var url = SUPABASE_URL + "/rest/v1/player_progress?id=eq." + user_id
	var error = http.request(url, headers, HTTPClient.METHOD_GET)
	
	if error != OK:
		http.queue_free()
		return {"success": false, "error": "No internet connection. Could not load quest progress."}
	
	var response = await http.request_completed
	http.queue_free()
	
	var status_code = response[1]
	var response_text = response[3].get_string_from_utf8()
	
	print("Quest Load Status: ", status_code)
	print("Quest Load Response Text: ", response_text)
	
	# Parse JSON only if response is not empty
	var response_body = null
	if not response_text.is_empty():
		response_body = JSON.parse_string(response_text)
		if response_body == null:
			print("Error: Failed to parse JSON response for quest load")
			return {"success": false, "error": "Invalid response from server"}
	
	if status_code == 200:
		if response_body and typeof(response_body) == TYPE_ARRAY and response_body.size() > 0:
			var progress = response_body[0]
			return {
				"success": true,
				"data": {
					"CEDfinish": progress.get("ced_finish", false),
					"CECfinish": progress.get("cec_finish", false),
					"COSfinish": progress.get("cos_finish", false),
					"CBMfinish": progress.get("cbm_finish", false),
					"CAHfinish": progress.get("cah_finish", false),
					"SANGAYfinish": progress.get("sangay_finish", false),
					"SANJOSEfinish": progress.get("sanjose_finish", false),
					"finishQuest": progress.get("finish_quest_count", 0)
				}
			}
		else:
			# No progress data found (new player)
			return {"success": true, "data": {}}
	else:
		var error_message = "Failed to load quest progress"
		if response_body and typeof(response_body) == TYPE_DICTIONARY and "message" in response_body:
			error_message = response_body["message"]
		elif not response_text.is_empty():
			error_message = "Server error: " + response_text
		return {"success": false, "error": error_message}
