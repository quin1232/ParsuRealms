# Database Setup Guide for ParsuRealms

## Option 1: Supabase (Recommended - Easiest)

### Step 1: Create Supabase Account
1. Go to https://supabase.com
2. Click "Start your project"
3. Sign up with GitHub or email
4. Create a new project (choose a name, password, and region)

### Step 2: Get Your Credentials
1. In your Supabase dashboard, go to **Settings** > **API**
2. Copy these values:
   - **Project URL** (looks like: https://xxxxx.supabase.co)
   - **anon/public key** (starts with "eyJ...")

### Step 3: Configure DatabaseManager.gd
1. Open `Scripts/DatabaseManager.gd`
2. Replace these lines with your actual values:
```gdscript
const SUPABASE_URL = "https://your-project.supabase.co"
const SUPABASE_KEY = "your-anon-key-here"
```

### Step 4: Enable Email Auth in Supabase
1. In Supabase dashboard, go to **Authentication** > **Providers**
2. Make sure **Email** is enabled
3. (Optional) Disable email confirmation for testing:
   - Go to **Authentication** > **Settings**
   - Turn off "Enable email confirmations"

### Step 5: Add Database Autoload in Godot
1. Open Godot
2. Go to **Project** > **Project Settings** > **Autoload**
3. Add new autoload:
   - **Path**: `res://Global/Database.gd`
   - **Node Name**: `Database`
   - Click **Add**

### Step 6: Attach Scripts to Buttons in MainMenu.tscn
1. Open `MainMenu.tscn`
2. For the **Login Button** (TextureButton2 in login panel):
   - Attach script: `res://start/main menu/LoginButton.gd`
3. For the **Register Button** (rig in login2 panel):
   - Attach script: `res://start/main menu/RegisterButton.gd`

### Step 7: Test
1. Run your game
2. Try registering a new account
3. Check your email for confirmation (if enabled)
4. Try logging in

---

## Option 2: Firebase (Alternative)

### Setup Steps:
1. Go to https://firebase.google.com
2. Create a new project
3. Enable Authentication > Email/Password
4. Get your Web API Key from Project Settings
5. Modify `DatabaseManager.gd` to use Firebase REST API

Firebase API endpoints:
- Signup: `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]`
- Login: `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=[API_KEY]`

---

## Option 3: Custom Backend (Advanced)

If you want full control, create your own backend:

### Using Python Flask:
```python
from flask import Flask, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3

app = Flask(__name__)

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    # Hash password and store in database
    # Return success/error
    
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    # Verify credentials
    # Return auth token
```

### Using Node.js Express:
```javascript
const express = require('express');
const bcrypt = require('bcrypt');
const app = express();

app.post('/signup', async (req, res) => {
    // Handle signup
});

app.post('/login', async (req, res) => {
    // Handle login
});
```

---

## Troubleshooting

### "Connection failed" error:
- Check your internet connection
- Verify Supabase URL and API key are correct
- Make sure Supabase project is active (not paused)

### "Invalid credentials" error:
- Verify email format is correct
- Check password meets minimum requirements (6+ characters)

### Email not received:
- Check spam folder
- Disable email confirmation in Supabase for testing
- Verify email provider settings in Supabase

### CORS errors (if using custom backend):
- Enable CORS in your backend
- Add allowed origins

---

## Security Notes

⚠️ **IMPORTANT**: 
- Never commit your Supabase keys to GitHub
- Use environment variables for production
- Enable Row Level Security (RLS) in Supabase
- Add rate limiting for signup/login
- Use HTTPS in production

---

## Next Steps

1. Add a loading indicator during login/signup
2. Add a message label to display errors/success to users
3. Store user data in a Global autoload
4. Add password reset functionality
5. Add profile management
6. Save user progress to database
