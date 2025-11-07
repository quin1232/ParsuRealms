extends Node



# Supabase Configuration loaded from Config.gd
const SUPABASE_URL = "https://iklrakwakfculjkpstio.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlrbHJha3dha2ZjdWxqa3BzdGlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MzExNzcsImV4cCI6MjA3ODAwNzE3N30.czkL7aO7fh_5CZdhyfAsMarO7QtIaIveGbop5yUIX-s"

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
		return {"success": false, "error": "Connection failed"}
	
	var response = await http.request_completed
	http.queue_free()
	
	var status_code = response[1]
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	
	# Debug output - DETAILED
	print("=== SIGNUP DEBUG ===")
	print("Status Code: ", status_code)
	print("Raw Response: ", response[3].get_string_from_utf8())
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
		return {"success": false, "error": "Connection failed"}
	
	var response = await http.request_completed
	http.queue_free()
	
	var status_code = response[1]
	var response_body = JSON.parse_string(response[3].get_string_from_utf8())
	
	# Debug output
	print("Login Status Code: ", status_code)
	print("Login Response Body: ", response_body)
	
	if status_code == 200:
		# Save user data
		if response_body and "access_token" in response_body:
			auth_token = response_body["access_token"]
			current_user = response_body.get("user", {})
			return {"success": true, "data": response_body}
	
	var error_message = "Login failed"
	if response_body and "error_description" in response_body:
		error_message = response_body["error_description"]
	elif response_body and "error" in response_body:
		error_message = response_body["error"]
	elif response_body and "msg" in response_body:
		error_message = response_body["msg"]
	
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
	if username != "" and username.length() < 3:
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
