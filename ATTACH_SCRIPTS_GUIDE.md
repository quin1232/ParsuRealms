# Visual Guide - Attach Scripts to Buttons

## Step-by-Step with Node Paths

### 1. Open MainMenu.tscn in Godot

### 2. Attach Login Button Script

**Node Path in Scene Tree:**
```
MainMenu
└── login (Panel)
    └── VBoxContainer
        └── VBoxContainer2
            └── TextureButton2 ← SELECT THIS NODE
```

**Steps:**
1. Click on `TextureButton2` node
2. In Inspector, look for "Script" property at the top
3. Click the empty script icon or "Script" label
4. Click "Load"
5. Navigate to `res://start/main menu/LoginButton.gd`
6. Click "Open"

---

### 3. Attach Register Button Script

**Node Path in Scene Tree:**
```
MainMenu
└── login2 (Panel)
    └── rig ← SELECT THIS NODE
```

**Steps:**
1. Click on `rig` node
2. In Inspector → Script
3. Load script: `res://start/main menu/RegisterButton.gd`

---

### 4. Attach Guest Button Script

**Node Path in Scene Tree:**
```
MainMenu
└── login (Panel)
    └── VBoxContainer
        └── VBoxContainer2
            └── guest ← SELECT THIS NODE
```

**Steps:**
1. Click on `guest` node
2. In Inspector → Script
3. Load script: `res://start/main menu/GuestButton.gd`

---

## Alternative Method: Drag & Drop

1. Open `FileSystem` panel in Godot
2. Navigate to `res://start/main menu/`
3. Drag `LoginButton.gd` onto the `TextureButton2` node
4. Drag `RegisterButton.gd` onto the `rig` node
5. Drag `GuestButton.gd` onto the `guest` node

---

## Verify Scripts Are Attached

After attaching, you should see:

### In Scene Tree:
- `TextureButton2` node will have a script icon 📜
- `rig` node will have a script icon 📜
- `guest` node will have a script icon 📜

### In Inspector (when node is selected):
- Top of Inspector shows the script name
- Script path shows: `res://start/main menu/[ScriptName].gd`

---

## Node References for Input Fields

The scripts expect these nodes to exist:

### For Login (TextureButton2's script):
```
../../../VBoxContainer/LineEdit       ← Email input
../../../VBoxContainer/LineEdit2      ← Password input
```

### For Register (rig's script):
```
../../VBoxContainer2/LineEdit         ← Email input
../../VBoxContainer2/LineEdit2        ← Password input
../../VBoxContainer2/LineEdit3        ← Confirm Password input
```

**These paths are already in the scripts and match your MainMenu.tscn structure!**

---

## Testing After Attaching

1. Save the scene (Ctrl+S)
2. Run the game (F5)
3. Check the Output panel for any errors
4. Try clicking each button - they should print messages to console

### Expected Console Output:

**When clicking Register button (without Supabase setup):**
```
Creating account...
Connection failed
```

**When clicking Guest button:**
```
Logged in as Guest
[Scene changes to main.tscn]
```

---

## If You See Errors

### Error: "Invalid get index 'text' (on base: 'null instance')"
**Cause:** Input field nodes not found
**Fix:** Check the node paths in the script match your scene structure

### Error: "Identifier 'Database' not declared"
**Cause:** Database autoload not added
**Fix:** Project > Project Settings > Autoload > Add `res://Global/Database.gd` as "Database"

### Error: "Parse Error"
**Cause:** Script syntax error
**Fix:** Open the script and check for typos (all scripts are already correct)

---

## Quick Test Checklist

- [ ] LoginButton.gd attached to TextureButton2
- [ ] RegisterButton.gd attached to rig
- [ ] GuestButton.gd attached to guest
- [ ] Database autoload enabled in Project Settings
- [ ] Supabase credentials added to DatabaseManager.gd
- [ ] Run game and test each button

---

## Screenshot Guide (What You Should See)

When you select `TextureButton2` in the scene tree:
```
Inspector Panel:
┌────────────────────────────────┐
│ 📜 TextureButton2 (TextureButton) │
│ Script: LoginButton.gd         │
│ [Open Editor] [Clear]          │
├────────────────────────────────┤
│ Node                           │
│ Name: TextureButton2           │
│ ...                            │
└────────────────────────────────┘
```

---

## Next: Add Supabase Credentials

After attaching scripts, follow `QUICK_SETUP.md` step 1 to add your Supabase credentials!
