# 📊 ParSU Realms - Database Structure (ERD)

## Overview
This document describes the complete database structure for ParSU Realms game, including authentication and quest progress tracking.

---

## 🗄️ Database Tables

### 1. `auth.users` (Supabase Authentication Table)

**Purpose:** Stores user authentication and account information

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| **id** | UUID | PRIMARY KEY | User unique identifier |
| email | VARCHAR | UNIQUE, NOT NULL | User email address |
| encrypted_password | VARCHAR | NOT NULL | Encrypted password |
| email_confirmed_at | TIMESTAMP | NULLABLE | Email confirmation timestamp |
| created_at | TIMESTAMP | DEFAULT NOW() | Account creation date |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last account update |
| last_sign_in_at | TIMESTAMP | NULLABLE | Last login timestamp |
| raw_user_meta_data | JSONB | NULLABLE | Custom user data |
| └─ username | STRING | - | Player username (custom field) |

**Managed By:** Supabase Authentication System

---

### 2. `player_progress` (Quest Progress Table)

**Purpose:** Tracks quest completion and player progress

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| **id** | UUID | PRIMARY KEY, FK | References auth.users(id) |
| | | ON DELETE CASCADE | Auto-delete when user deleted |
| **ced_finish** | BOOLEAN | DEFAULT false | College of Education quest |
| **cec_finish** | BOOLEAN | DEFAULT false | College of Engineering quest |
| **cos_finish** | BOOLEAN | DEFAULT false | College of Science quest |
| **cbm_finish** | BOOLEAN | DEFAULT false | College of Business Management |
| **cah_finish** | BOOLEAN | DEFAULT false | College of Arts & Humanities |
| **sangay_finish** | BOOLEAN | DEFAULT false | Sagnay Campus quest |
| **sanjose_finish** | BOOLEAN | DEFAULT false | San Jose Campus quest |
| **finish_quest_count** | INTEGER | DEFAULT 0 | Total completed quests (0-7) |
| **last_played** | TIMESTAMPTZ | DEFAULT NOW() | Last game session |
| **created_at** | TIMESTAMPTZ | DEFAULT NOW() | Progress record creation |
| **updated_at** | TIMESTAMPTZ | DEFAULT NOW() | Auto-updated on changes |

**Indexes:**
- `idx_player_progress_last_played` on `last_played` column

**Triggers:**
- `update_player_progress_updated_at` - Automatically updates `updated_at` timestamp

---

### 3. `quest_completion_stats` (Statistics View)

**Purpose:** Aggregated statistics for game analytics (read-only)

| Column | Type | Description |
|--------|------|-------------|
| total_players | INTEGER | Total number of players |
| ced_completions | INTEGER | Players who completed CED |
| cec_completions | INTEGER | Players who completed CEC |
| cos_completions | INTEGER | Players who completed COS |
| cbm_completions | INTEGER | Players who completed CBM |
| cah_completions | INTEGER | Players who completed CAH |
| sangay_completions | INTEGER | Players who completed SANGAY |
| sanjose_completions | INTEGER | Players who completed SANJOSE |
| avg_quests_completed | DECIMAL(10,2) | Average quests per player |

---

## 🔗 Entity Relationships

```
┌─────────────────────────────────┐
│        auth.users               │
│  (Supabase Authentication)      │
├─────────────────────────────────┤
│  🔑 id (UUID)                   │
│     email                       │
│     encrypted_password          │
│     raw_user_meta_data          │
│       └─ username               │
│     created_at                  │
│     updated_at                  │
│     last_sign_in_at             │
└──────────┬──────────────────────┘
           │
           │ 1:1 (optional)
           │ ON DELETE CASCADE
           │
┌──────────▼──────────────────────┐
│     player_progress             │
│   (Quest Tracking)              │
├─────────────────────────────────┤
│  🔑 id (UUID, FK)               │
│     ced_finish                  │
│     cec_finish                  │
│     cos_finish                  │
│     cbm_finish                  │
│     cah_finish                  │
│     sangay_finish               │
│     sanjose_finish              │
│     finish_quest_count          │
│     last_played                 │
│     created_at                  │
│     updated_at                  │
└─────────────────────────────────┘
```

**Relationship Type:** One-to-One (Optional)
- One user can have zero or one progress record
- Progress record cannot exist without a user
- When user is deleted, progress is automatically deleted (CASCADE)

---

## 🎮 Quest Reference

| Quest Code | Full Name | Location |
|------------|-----------|----------|
| **CED** | College of Education | Goa Campus |
| **CEC** | College of Engineering & Computational Science | Goa Campus |
| **COS** | College of Science | Goa Campus |
| **CBM** | College of Business Management | Goa Campus |
| **CAH** | College of Arts & Humanities | Goa Campus |
| **SANGAY** | College of Fisheries & Marine Sciences | Sagnay Campus |
| **SANJOSE** | (Future Content) | San Jose Campus |

**Total Quests:** 7

---

## 🔒 Security (Row Level Security)

### RLS Policies on `player_progress`

| Policy Name | Operation | Rule |
|-------------|-----------|------|
| Users can view their own progress | SELECT | `auth.uid() = id` |
| Users can insert their own progress | INSERT | `auth.uid() = id` |
| Users can update their own progress | UPDATE | `auth.uid() = id` |

**Security Features:**
- ✅ Row Level Security (RLS) enabled
- ✅ Users can only access their own data
- ✅ JWT token authentication required
- ✅ API key protection
- ✅ HTTPS encryption (Supabase)

---

## 📡 API Endpoints

### Authentication Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/v1/signup` | POST | Register new user |
| `/auth/v1/token?grant_type=password` | POST | Login user |

### Data Endpoints

| Endpoint | Method | Purpose | Headers Required |
|----------|--------|---------|------------------|
| `/rest/v1/player_progress` | POST | Save quest progress (UPSERT) | Authorization: Bearer {token} |
| `/rest/v1/player_progress?id=eq.{user_id}` | GET | Load quest progress | Authorization: Bearer {token} |

**UPSERT Behavior:**
- Uses `Prefer: resolution=merge-duplicates` header
- Creates new record if doesn't exist
- Updates existing record if exists

---

## 🔄 Data Flow Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                      GODOT GAME CLIENT                        │
│                    (DatabaseManager.gd)                       │
└───────────────────┬───────────────────────┬───────────────────┘
                    │                       │
          ┌─────────▼─────────┐   ┌────────▼─────────┐
          │   REGISTRATION    │   │      LOGIN        │
          │   signup()        │   │      login()      │
          └─────────┬─────────┘   └────────┬─────────┘
                    │                       │
                    └───────────┬───────────┘
                                │
                    ┌───────────▼───────────┐
                    │  SUPABASE AUTH API    │
                    │  /auth/v1/...         │
                    └───────────┬───────────┘
                                │
                                │ Returns JWT Token
                                │ Creates/Validates User
                                │
                    ┌───────────▼───────────┐
                    │    auth.users         │
                    │  (id, email, ...)     │
                    └───────────┬───────────┘
                                │
          ┌─────────────────────┴─────────────────────┐
          │                                           │
  ┌───────▼────────┐                       ┌─────────▼────────┐
  │  SAVE PROGRESS │                       │  LOAD PROGRESS   │
  │  POST + JWT    │                       │  GET + JWT       │
  └───────┬────────┘                       └─────────┬────────┘
          │                                           │
          └───────────────┬───────────────────────────┘
                          │
              ┌───────────▼───────────┐
              │ SUPABASE REST API     │
              │ /rest/v1/player_...   │
              └───────────┬───────────┘
                          │
                          │ RLS Policy Check
                          │ UPSERT/SELECT
                          │
              ┌───────────▼───────────┐
              │   player_progress     │
              │ (quest flags, count)  │
              └───────────────────────┘
```

---

## 🛠️ Database Functions & Triggers

### Function: `update_updated_at_column()`

**Purpose:** Automatically update the `updated_at` timestamp

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Trigger: `update_player_progress_updated_at`

**Purpose:** Call the function before each UPDATE

```sql
CREATE TRIGGER update_player_progress_updated_at
  BEFORE UPDATE ON player_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## 💾 Sample Data Structures

### User Registration Request
```json
{
  "email": "player@example.com",
  "password": "secure_password",
  "data": {
    "username": "PlayerOne"
  }
}
```

### Login Request
```json
{
  "email": "player@example.com",
  "password": "secure_password"
}
```

### Login Response
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": "uuid-here",
    "email": "player@example.com",
    "user_metadata": {
      "username": "PlayerOne"
    }
  }
}
```

### Save Quest Progress Request
```json
{
  "id": "user-uuid",
  "ced_finish": true,
  "cec_finish": true,
  "cos_finish": false,
  "cbm_finish": false,
  "cah_finish": false,
  "sangay_finish": false,
  "sanjose_finish": false,
  "finish_quest_count": 2,
  "last_played": "2025-11-23T10:30:00Z"
}
```

### Load Quest Progress Response
```json
[
  {
    "id": "user-uuid",
    "ced_finish": true,
    "cec_finish": true,
    "cos_finish": false,
    "cbm_finish": false,
    "cah_finish": false,
    "sangay_finish": false,
    "sanjose_finish": false,
    "finish_quest_count": 2,
    "last_played": "2025-11-23T10:30:00Z",
    "created_at": "2025-11-20T08:00:00Z",
    "updated_at": "2025-11-23T10:30:00Z"
  }
]
```

---

## 📊 ERD Visual Summary

```
                    ┌────────────────────┐
                    │   auth.users       │
                    ├────────────────────┤
                    │ 🔑 id (UUID)       │
                    │    email           │
                    │    password        │
                    │    username        │
                    │    created_at      │
                    └─────────┬──────────┘
                              │
                              │ 1:1 CASCADE
                              │
                    ┌─────────▼──────────┐
                    │ player_progress    │
                    ├────────────────────┤
                    │ 🔑 id (FK)         │
                    │    ced_finish      │
                    │    cec_finish      │
                    │    cos_finish      │
                    │    cbm_finish      │
                    │    cah_finish      │
                    │    sangay_finish   │
                    │    sanjose_finish  │
                    │    finish_quest_ct │
                    │    last_played     │
                    │    created_at      │
                    │    updated_at      │
                    └────────────────────┘
                              │
                              │ Aggregates to
                              │
                    ┌─────────▼──────────┐
                    │ quest_completion   │
                    │      _stats (VIEW) │
                    ├────────────────────┤
                    │    total_players   │
                    │    ced_completions │
                    │    cec_completions │
                    │    cos_completions │
                    │    ...             │
                    │    avg_completed   │
                    └────────────────────┘
```

---

## 🔍 Query Examples

### Get User Progress
```sql
SELECT * FROM player_progress 
WHERE id = 'user-uuid';
```

### Get Completion Statistics
```sql
SELECT * FROM quest_completion_stats;
```

### Check if User Completed All Quests
```sql
SELECT 
  id,
  (ced_finish AND cec_finish AND cos_finish AND 
   cbm_finish AND cah_finish AND sangay_finish AND 
   sanjose_finish) AS all_completed
FROM player_progress
WHERE id = 'user-uuid';
```

### Get Top Players by Quest Count
```sql
SELECT 
  u.raw_user_meta_data->>'username' as username,
  p.finish_quest_count
FROM player_progress p
JOIN auth.users u ON u.id = p.id
ORDER BY p.finish_quest_count DESC
LIMIT 10;
```

---

## 📝 Notes

- Database hosted on **Supabase** (PostgreSQL)
- Uses **JWT tokens** for authentication
- **RLS policies** ensure data privacy
- All timestamps in **UTC** (TIMESTAMPTZ)
- Quest completion is **idempotent** (can call multiple times safely)
- Progress is **automatically saved** after each quest completion
- Progress is **loaded on login**

---

## 🔗 Related Files

- `database_migrations/001_create_player_progress.sql` - Database schema
- `Scripts/DatabaseManager.gd` - API client
- `Global/Global.gd` - Quest management
- `start/main menu/LoginButton.gd` - Login handler
- `start/main menu/RegisterButton.gd` - Registration handler
