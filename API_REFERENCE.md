# Database API Reference

## Quick Reference for Using the Database System

### Import / Access

The database is available globally via the `Database` autoload:

```gdscript
# Access from any script:
Database.db_manager.signup(email, password, username)
Database.db_manager.login(email, password)
Database.db_manager.logout()
```

---

## API Methods

### 1. Signup (Register New User)

```gdscript
var result = await Database.db_manager.signup(email, password, username)
```

**Parameters:**
- `email` (String): User's email address
- `password` (String): User's password (min 6 characters)
- `username` (String): Display name for the user

**Returns:** Dictionary
```gdscript
{
    "success": bool,
    "data": Dictionary,    # If success=true
    "error": String        # If success=false
}
```

**Example:**
```gdscript
var result = await Database.db_manager.signup(
    "player@example.com",
    "mypassword123",
    "CoolPlayer"
)

if result["success"]:
    print("Account created!")
else:
    print("Error: " + result["error"])
```

---

### 2. Login (Authenticate User)

```gdscript
var result = await Database.db_manager.login(email, password)
```

**Parameters:**
- `email` (String): User's email address
- `password` (String): User's password

**Returns:** Dictionary
```gdscript
{
    "success": bool,
    "data": {
        "access_token": String,
        "user": {
            "id": String,
            "email": String,
            "user_metadata": {
                "username": String
            }
        }
    },
    "error": String        # If success=false
}
```

**Example:**
```gdscript
var result = await Database.db_manager.login(
    "player@example.com",
    "mypassword123"
)

if result["success"]:
    var user_data = result["data"]["user"]
    var username = user_data["user_metadata"]["username"]
    print("Welcome back, " + username)
    
    # Save to Global
    Global.player_username = username
    Global.player_email = user_data["email"]
    Global.is_logged_in = true
else:
    print("Login failed: " + result["error"])
```

---

### 3. Logout

```gdscript
Database.db_manager.logout()
```

**No parameters, no return value.**

Clears the current user session.

**Example:**
```gdscript
func _on_logout_button_pressed():
    Database.db_manager.logout()
    Global.is_logged_in = false
    Global.player_username = ""
    Global.player_email = ""
    get_tree().change_scene_to_file("res://start/main menu/MainMenu.tscn")
```

---

### 4. Check Login Status

```gdscript
var logged_in = Database.db_manager.is_logged_in()
```

**Returns:** bool

**Example:**
```gdscript
if Database.db_manager.is_logged_in():
    print("User is logged in")
else:
    print("User is not logged in")
```

---

### 5. Get Current User

```gdscript
var user = Database.db_manager.get_current_user()
```

**Returns:** Dictionary (empty if not logged in)

**Example:**
```gdscript
var user = Database.db_manager.get_current_user()
if user:
    print("User ID: " + user["id"])
    print("Email: " + user["email"])
```

---

## Global Variables (After Login)

After successful login, use these globals:

```gdscript
Global.player_username     # String: Username
Global.player_email        # String: Email address
Global.is_logged_in        # bool: Authentication status
Global.is_guest           # bool: Guest mode flag
```

**Example Usage:**
```gdscript
# In any game script:
func _ready():
    if Global.is_guest:
        print("Playing as guest")
        # Disable online features
    elif Global.is_logged_in:
        print("Welcome, " + Global.player_username)
        # Enable online features, cloud saves, etc.
    else:
        # Shouldn't happen, but handle it
        print("Not logged in - redirect to login")
        get_tree().change_scene_to_file("res://start/main menu/MainMenu.tscn")
```

---

## Complete Login Flow Example

```gdscript
extends Control

@onready var email_field = $EmailLineEdit
@onready var password_field = $PasswordLineEdit
@onready var status_label = $StatusLabel
@onready var login_button = $LoginButton

func _ready():
    login_button.pressed.connect(_on_login_pressed)

func _on_login_pressed():
    var email = email_field.text.strip_edges()
    var password = password_field.text
    
    # Validate input
    if email.is_empty() or password.is_empty():
        status_label.text = "Please fill all fields"
        return
    
    # Disable button
    login_button.disabled = true
    status_label.text = "Logging in..."
    
    # Attempt login
    var result = await Database.db_manager.login(email, password)
    
    # Re-enable button
    login_button.disabled = false
    
    # Handle result
    if result["success"]:
        status_label.text = "Success!"
        
        # Save user data
        var user_data = result["data"]["user"]
        var username = user_data.get("user_metadata", {}).get("username", "Player")
        
        Global.player_username = username
        Global.player_email = email
        Global.is_logged_in = true
        Global.is_guest = false
        
        # Go to game
        await get_tree().create_timer(1.0).timeout
        get_tree().change_scene_to_file("res://main.tscn")
    else:
        status_label.text = "Error: " + result["error"]
        password_field.text = ""  # Clear password
```

---

## Complete Registration Flow Example

```gdscript
extends Control

@onready var email_field = $EmailLineEdit
@onready var password_field = $PasswordLineEdit
@onready var confirm_field = $ConfirmLineEdit
@onready var status_label = $StatusLabel
@onready var register_button = $RegisterButton

func _ready():
    register_button.pressed.connect(_on_register_pressed)

func _on_register_pressed():
    var email = email_field.text.strip_edges()
    var password = password_field.text
    var confirm = confirm_field.text
    
    # Validate
    if email.is_empty() or password.is_empty() or confirm.is_empty():
        status_label.text = "Please fill all fields"
        return
    
    if password != confirm:
        status_label.text = "Passwords don't match"
        return
    
    if password.length() < 6:
        status_label.text = "Password must be at least 6 characters"
        return
    
    # Extract username from email
    var username = email.split("@")[0]
    
    # Disable button
    register_button.disabled = true
    status_label.text = "Creating account..."
    
    # Attempt signup
    var result = await Database.db_manager.signup(email, password, username)
    
    # Re-enable button
    register_button.disabled = false
    
    # Handle result
    if result["success"]:
        status_label.text = "Account created! Please check your email."
        
        # Clear fields
        email_field.text = ""
        password_field.text = ""
        confirm_field.text = ""
        
        # Wait then switch to login
        await get_tree().create_timer(2.0).timeout
        # Show login panel or change scene
    else:
        status_label.text = "Error: " + result["error"]
        password_field.text = ""
        confirm_field.text = ""
```

---

## Error Messages Reference

### Common Error Messages:

| Error | Meaning | Solution |
|-------|---------|----------|
| "Invalid input" | Validation failed | Check email format and password length |
| "Connection failed" | Network/API error | Check internet and Supabase credentials |
| "Registration failed" | Signup error | User might already exist |
| "Login failed" | Auth error | Wrong email/password |
| "Email and password required" | Empty fields | Fill all required fields |
| "User already registered" | Duplicate account | Use different email or login instead |
| "Invalid email" | Bad email format | Use proper email format (user@domain.com) |

---

## Helper Functions (Internal)

These are used internally by the DatabaseManager:

```gdscript
# Email validation
Database.db_manager._is_valid_email(email) → bool

# Credential validation
Database.db_manager._validate_credentials(email, password, username) → bool
```

---

## Configuration

### Changing Supabase Credentials

Edit `Scripts/DatabaseManager.gd`:

```gdscript
const SUPABASE_URL = "https://your-project.supabase.co"
const SUPABASE_KEY = "your-anon-key-here"
```

### Changing Auth Endpoints (Advanced)

If using Firebase or custom backend:

```gdscript
const AUTH_SIGNUP_URL = "/your/signup/endpoint"
const AUTH_LOGIN_URL = "/your/login/endpoint"
```

---

## Best Practices

### 1. Always Use `await` with Async Functions

```gdscript
# ✅ Correct
var result = await Database.db_manager.login(email, password)

# ❌ Wrong - will not wait for result
var result = Database.db_manager.login(email, password)
```

### 2. Check Success Before Using Data

```gdscript
# ✅ Correct
if result["success"]:
    var user = result["data"]["user"]

# ❌ Wrong - might crash if failed
var user = result["data"]["user"]  # "data" might not exist
```

### 3. Clear Sensitive Data After Use

```gdscript
# Clear password fields after login/signup
password_field.text = ""
confirm_password_field.text = ""
```

### 4. Disable Buttons During Requests

```gdscript
button.disabled = true
var result = await Database.db_manager.login(email, password)
button.disabled = false
```

### 5. Provide User Feedback

```gdscript
status_label.text = "Logging in..."
var result = await Database.db_manager.login(email, password)
status_label.text = "Success!" if result["success"] else "Failed"
```

---

## Testing Without Internet

For offline testing, you can mock the database:

```gdscript
# In DatabaseManager.gd, add debug mode:
const DEBUG_MODE = true  # Set to false for production

func login(email: String, password: String) -> Dictionary:
    if DEBUG_MODE:
        return {"success": true, "data": {
            "user": {
                "email": email,
                "user_metadata": {"username": "TestUser"}
            }
        }}
    
    # Normal login code...
```

---

## Extending the System

### Add Password Reset

```gdscript
func reset_password(email: String) -> Dictionary:
    var http = HTTPRequest.new()
    add_child(http)
    
    var headers = [
        "Content-Type: application/json",
        "apikey: " + SUPABASE_KEY
    ]
    
    var body = JSON.stringify({"email": email})
    var url = SUPABASE_URL + "/auth/v1/recover"
    
    var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
    if error != OK:
        return {"success": false, "error": "Connection failed"}
    
    var response = await http.request_completed
    http.queue_free()
    
    return {"success": true}
```

### Add Profile Update

```gdscript
func update_profile(username: String) -> Dictionary:
    if not auth_token:
        return {"success": false, "error": "Not logged in"}
    
    var http = HTTPRequest.new()
    add_child(http)
    
    var headers = [
        "Content-Type: application/json",
        "apikey: " + SUPABASE_KEY,
        "Authorization: Bearer " + auth_token
    ]
    
    var body = JSON.stringify({
        "data": {"username": username}
    })
    
    var url = SUPABASE_URL + "/auth/v1/user"
    var error = http.request(url, headers, HTTPClient.METHOD_PUT, body)
    
    # ... handle response
```

---

## Support & Documentation

- **Supabase Docs:** https://supabase.com/docs/reference/javascript/auth-signup
- **Godot HTTPRequest:** https://docs.godotengine.org/en/stable/classes/class_httprequest.html
- **Your Setup Guides:** See `DATABASE_SETUP.md` and `QUICK_SETUP.md`

---

**Happy coding! 🚀**
