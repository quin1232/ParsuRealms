# Quest Progress Database Integration

## Overview
This system saves player quest completion data to the Supabase database, allowing persistent progress across sessions and devices.

## Database Setup

### 1. Run the SQL Migration
Execute the SQL file in your Supabase SQL Editor:
```
database_migrations/001_create_player_progress.sql
```

This will create:
- `player_progress` table with quest completion flags
- Row Level Security policies (users can only access their own data)
- Automatic timestamp updates
- Optional statistics view

### 2. Verify Table Creation
In Supabase Dashboard → Table Editor, you should see:
- `player_progress` table
- Columns: id, ced_finish, cec_finish, cos_finish, cbm_finish, cah_finish, sangay_finish, sanjose_finish, finish_quest_count, last_played, created_at, updated_at

## Usage in Game

### Loading Quest Progress (After Login)
Call this after a successful login to restore player's quest progress:

```gdscript
# In your login success handler
func _on_login_success():
    Global.player_email = email
    Global.is_logged_in = true
    
    # Load quest progress from database
    await Global.load_quest_progress_from_db()
    
    # Now Global.CEDfinish, Global.CECfinish, etc. are loaded
    print("Player has completed ", Global.finishQuest, " quests")
```

### Saving Quest Progress
There are two ways to save progress:

#### Option 1: Manual Save (Recommended for checkpoints)
```gdscript
# Save whenever a quest is completed
func _on_quest_completed():
    Global.CEDfinish = true
    await Global.save_quest_progress_to_db()
```

#### Option 2: Complete Quest Helper (Recommended)
```gdscript
# Use the helper method which automatically saves
Global.complete_quest("CED")  # Marks quest complete and saves to DB
Global.complete_quest("SANGAY")  # Works for any quest name
```

### Checking Quest Completion
```gdscript
if Global.CEDfinish:
    print("CED quest is completed!")

if Global.finishQuest >= 5:
    print("Player has completed at least 5 quests")
```

## Auto-Save Recommendations

### When to Save
Consider auto-saving quest progress at these points:
1. **After quest completion** (most important)
2. **On scene changes** (checkpoint system)
3. **Periodically** (every 5-10 minutes)
4. **On game exit** (if player closes game)

### Example Auto-Save Implementation

Add to your main game script or Global.gd:

```gdscript
# In Global.gd
var _auto_save_timer: Timer

func _ready():
    # Set up periodic auto-save (every 5 minutes)
    _auto_save_timer = Timer.new()
    _auto_save_timer.wait_time = 300.0  # 5 minutes
    _auto_save_timer.timeout.connect(_on_auto_save)
    add_child(_auto_save_timer)
    _auto_save_timer.start()
    
    # Save on game exit
    get_tree().root.tree_exiting.connect(_on_game_exiting)

func _on_auto_save():
    if is_logged_in and not is_guest:
        save_quest_progress_to_db()
        print("Auto-saved quest progress")

func _on_game_exiting():
    if is_logged_in and not is_guest:
        # Note: await won't work here, but request will still send
        save_quest_progress_to_db()
```

## API Reference

### Global.gd Methods

#### `save_quest_progress_to_db() -> void`
Saves all quest completion flags to the database.
- **Async**: Use `await` when calling
- **Requires**: User must be logged in
- **Returns**: Prints success/error message

#### `load_quest_progress_from_db() -> void`
Loads quest progress from database and updates Global variables.
- **Async**: Use `await` when calling
- **Requires**: User must be logged in
- **Updates**: CEDfinish, CECfinish, COSfinish, CBMfinish, CAHfinish, SANGAYfinish, SANJOSEfinish, finishQuest

#### `complete_quest(quest_name: String) -> void`
Marks a quest as complete and auto-saves to database.
- **Parameters**: quest_name (e.g., "CED", "SANGAY", "SANJOSE")
- **Async**: Internally uses await for save
- **Side effects**: Increments finishQuest counter

### DatabaseManager.gd Methods

#### `save_quest_progress(quest_data: Dictionary) -> Dictionary`
Low-level method to save quest data.
- **Returns**: `{"success": bool, "data": {...}}` or `{"success": false, "error": String}`

#### `load_quest_progress() -> Dictionary`
Low-level method to load quest data.
- **Returns**: `{"success": bool, "data": {...}}` or `{"success": false, "error": String}`

## Quest Names Reference

| Variable | Quest Name | Description |
|----------|------------|-------------|
| CEDfinish | CED | College of Education |
| CECfinish | CEC | College of Engineering and Computing |
| COSfinish | COS | College of Science |
| CBMfinish | CBM | College of Business Management |
| CAHfinish | CAH | College of Arts and Humanities |
| SANGAYfinish | SANGAY | Sangay Quest |
| SANJOSEfinish | SANJOSE | San Jose Quest |

## Testing

### Test Quest Save/Load
```gdscript
# Test saving
Global.CEDfinish = true
Global.CECfinish = true
Global.finishQuest = 2
await Global.save_quest_progress_to_db()

# Reset local values
Global.CEDfinish = false
Global.CECfinish = false
Global.finishQuest = 0

# Test loading
await Global.load_quest_progress_from_db()
print("CED:", Global.CEDfinish)  # Should print: CED: true
print("CEC:", Global.CECfinish)  # Should print: CEC: true
print("Total:", Global.finishQuest)  # Should print: Total: 2
```

### Check Supabase Dashboard
1. Go to Supabase Dashboard → Table Editor
2. Select `player_progress` table
3. Verify your test data appears with correct user ID

## Troubleshooting

### Quest progress not saving
- Check Godot console for error messages
- Verify user is logged in: `Database.db_manager.is_logged_in()`
- Check Supabase logs (Dashboard → Logs → Postgres)
- Verify RLS policies are set correctly

### Quest progress not loading
- Ensure `load_quest_progress_from_db()` is called after successful login
- Check if data exists in Supabase table
- Verify user ID matches between auth.users and player_progress

### "User not logged in" error
- Make sure login completes successfully before saving/loading
- Verify `Database.db_manager.auth_token` is not null

## Migration Notes

If you have existing players with local progress:
1. Load their local progress (from Global.gd variables)
2. Call `Global.save_quest_progress_to_db()` to migrate to database
3. From then on, use database as source of truth

## Security

- Row Level Security (RLS) ensures players can only access their own data
- All database operations require valid authentication token
- Guest users cannot save progress (check `Global.is_guest` before saving)
