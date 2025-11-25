# Quest Progress Database - Setup Checklist

## ✅ Steps to Enable Quest Progress Saving

### 1. Database Setup (Supabase)
- [ ] Log into your Supabase dashboard
- [ ] Navigate to SQL Editor
- [ ] Copy and paste the contents of `database_migrations/001_create_player_progress.sql`
- [ ] Click "Run" to execute the SQL
- [ ] Verify the `player_progress` table appears in Table Editor

### 2. Test the Integration

#### Test Saving Quest Progress
Add this code to test quest completion:

```gdscript
# After a quest is completed (e.g., in your quest complete dialog)
func _on_quest_ced_completed():
    await Global.complete_quest("CED")
    print("CED quest saved!")
```

#### Test Loading Quest Progress
The LoginButton.gd has been updated to automatically load quest progress after login.
Just login and check the console - you should see:
```
Quest progress loaded: X quests completed
```

### 3. Update Your Quest Completion Code

Find where you currently set quest completion flags and update them:

**Before:**
```gdscript
Global.CEDfinish = true
Global.finishQuest += 1
```

**After:**
```gdscript
await Global.complete_quest("CED")
```

This automatically:
- Sets the quest flag
- Increments the counter
- Saves to database

### 4. Common Places to Update

Search your project for these patterns and update them:

1. **Quest completion dialogs/scripts**
   - Search for: `CEDfinish = true`, `CECfinish = true`, etc.
   - Replace with: `await Global.complete_quest("CED")`

2. **Quest reward scripts**
   - After giving rewards, save progress

3. **Level/scene transitions**
   - Consider auto-saving on major checkpoints

### 5. Optional: Add Auto-Save Timer

Add to your main game scene or Global.gd:

```gdscript
var _auto_save_timer: Timer

func _ready():
    # Auto-save every 5 minutes
    _auto_save_timer = Timer.new()
    _auto_save_timer.wait_time = 300.0
    _auto_save_timer.timeout.connect(_on_auto_save)
    add_child(_auto_save_timer)
    _auto_save_timer.start()

func _on_auto_save():
    if Global.is_logged_in and not Global.is_guest:
        Global.save_quest_progress_to_db()
```

## 📁 Files Modified

- ✅ `Scripts/DatabaseManager.gd` - Added save/load quest methods
- ✅ `Global/Global.gd` - Added database sync methods
- ✅ `start/main menu/LoginButton.gd` - Auto-loads quest progress on login
- ✅ `database_migrations/001_create_player_progress.sql` - Database schema
- ✅ `QUEST_PROGRESS_GUIDE.md` - Complete documentation
- ✅ `Scripts/QuestProgressExample.gd` - Usage examples

## 🧪 Testing Checklist

- [ ] Run the SQL migration in Supabase
- [ ] Login to the game
- [ ] Complete a quest
- [ ] Check Supabase Table Editor - verify data is saved
- [ ] Logout and login again
- [ ] Verify quest progress is restored

## 🐛 Troubleshooting

### "User not logged in" error
- Make sure you're not in guest mode
- Verify login was successful before completing quests

### Data not saving
- Check Godot console for error messages
- Verify Supabase SQL ran successfully
- Check Supabase Dashboard → Logs for errors

### Data not loading
- Ensure `load_quest_progress_from_db()` is called after login
- Check if data exists in Supabase table
- Verify user ID matches

## 📖 Documentation

- Full guide: `QUEST_PROGRESS_GUIDE.md`
- API reference: See methods in `Global.gd` and `DatabaseManager.gd`
- Example usage: `Scripts/QuestProgressExample.gd`

## 🚀 Quick Start

1. Run SQL migration in Supabase
2. Login to the game
3. Find your quest completion code
4. Replace `Global.CEDfinish = true` with `await Global.complete_quest("CED")`
5. Done! Progress now saves to database automatically
