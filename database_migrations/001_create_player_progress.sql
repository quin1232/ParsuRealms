-- Player Progress Table for Quest Completion Tracking
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS player_progress (
  -- Primary key references the auth.users table
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  
  -- Quest completion flags
  ced_finish BOOLEAN DEFAULT false,
  cec_finish BOOLEAN DEFAULT false,
  cos_finish BOOLEAN DEFAULT false,
  cbm_finish BOOLEAN DEFAULT false,
  cah_finish BOOLEAN DEFAULT false,
  sangay_finish BOOLEAN DEFAULT false,
  sanjose_finish BOOLEAN DEFAULT false,
  
  -- Total completed quests counter
  finish_quest_count INTEGER DEFAULT 0,
  
  -- Timestamps
  last_played TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE player_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own progress
CREATE POLICY "Users can view their own progress"
  ON player_progress
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can insert their own progress
CREATE POLICY "Users can insert their own progress"
  ON player_progress
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy: Users can update their own progress
CREATE POLICY "Users can update their own progress"
  ON player_progress
  FOR UPDATE
  USING (auth.uid() = id);

-- Create an index for faster queries
CREATE INDEX IF NOT EXISTS idx_player_progress_last_played 
  ON player_progress(last_played);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
CREATE TRIGGER update_player_progress_updated_at
  BEFORE UPDATE ON player_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Optional: Create a view for quest completion statistics
CREATE OR REPLACE VIEW quest_completion_stats AS
SELECT
  COUNT(*) as total_players,
  SUM(CASE WHEN ced_finish THEN 1 ELSE 0 END) as ced_completions,
  SUM(CASE WHEN cec_finish THEN 1 ELSE 0 END) as cec_completions,
  SUM(CASE WHEN cos_finish THEN 1 ELSE 0 END) as cos_completions,
  SUM(CASE WHEN cbm_finish THEN 1 ELSE 0 END) as cbm_completions,
  SUM(CASE WHEN cah_finish THEN 1 ELSE 0 END) as cah_completions,
  SUM(CASE WHEN sangay_finish THEN 1 ELSE 0 END) as sangay_completions,
  SUM(CASE WHEN sanjose_finish THEN 1 ELSE 0 END) as sanjose_completions,
  ROUND(AVG(finish_quest_count), 2) as avg_quests_completed
FROM player_progress;
