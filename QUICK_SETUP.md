# Quick Setup Instructions

## ✅ What I've Created:

1. **DatabaseManager.gd** - Handles all database operations (signup/login)
2. **Database.gd** - Global autoload singleton
3. **LoginButton.gd** - Script for login button functionality
4. **RegisterButton.gd** - Script for register button functionality
5. **Updated project.godot** - Added Database autoload

## 🔧 What YOU Need to Do:

### 1. Get Supabase Credentials (5 minutes)
1. Go to https://supabase.com and sign up
2. Create a new project
3. Go to Settings > API
4. Copy your **Project URL** and **anon key**
5. Open `Scripts/DatabaseManager.gd` and paste them:
   ```gdscript
   const SUPABASE_URL = "https://your-project.supabase.co"
   const SUPABASE_KEY = "your-anon-key-here"
   ```

### 2. Attach Scripts to Buttons in Godot Editor

Open `MainMenu.tscn` and attach these scripts:

#### For Login Panel (login):
- Find: `VBoxContainer/VBoxContainer2/TextureButton2` (the Login button)
- Attach script: `res://start/main menu/LoginButton.gd`

#### For Register Panel (login2):
- Find: `login2/rig` (the Register button)
- Attach script: `res://start/main menu/RegisterButton.gd`

#### For Guest Button (login):
- Find: `VBoxContainer/VBoxContainer2/guest` (the Login as Guest button)
- Attach script: `res://start/main menu/GuestButton.gd`

### 3. Optional: Add Message Label for User Feedback
Add a Label node to show messages to users:

In **login** panel:
```
- Add a Label node under VBoxContainer
- Name it: MessageLabel
- Set text to empty
- Center align it
```

In **login2** panel:
```
- Add a Label node under VBoxContainer2
- Name it: MessageLabel
- Set text to empty
- Center align it
```

Then update LoginButton.gd and RegisterButton.gd to use:
```gdscript
func _show_message(message: String):
    print(message)
    if has_node("../../../MessageLabel"):
        $"../../../MessageLabel".text = message
```

### 4. Update Main Scene Path
In `LoginButton.gd` line 35, change:
```gdscript
get_tree().change_scene_to_file("res://main.tscn")
```
To your actual main game scene path.

### 5. Test It!
1. Run your game (F5)
2. Click Register
3. Enter email, password, confirm password
4. Click Register button
5. Check console for messages
6. Try logging in with the same credentials

## 📝 Notes:

- **Email format**: Must be valid (e.g., test@example.com)
- **Password**: Minimum 6 characters
- **Username**: Auto-generated from email (part before @)
- Messages are printed to console - add a Label for user-visible messages

## 🐛 If Something Doesn't Work:

1. Check Output/Console in Godot for error messages
2. Verify Supabase credentials are correct
3. Make sure scripts are attached to correct buttons
4. Check that Database autoload is enabled (Project > Project Settings > Autoload)
5. Read the full `DATABASE_SETUP.md` for detailed troubleshooting

## 🎯 Current Structure:

```
Your Game
├── Scripts/
│   └── DatabaseManager.gd (handles API calls)
├── Global/
│   └── Database.gd (autoload - access via Database.db_manager)
└── start/main menu/
    ├── LoginButton.gd (attach to login button)
    ├── RegisterButton.gd (attach to register button)
    ├── login.gd (switch to login panel)
    └── registers.gd (switch to register panel)
```

Good luck! 🚀
