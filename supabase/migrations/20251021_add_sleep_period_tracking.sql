-- =====================================================
-- Add Sleep Period Tracking
-- =====================================================
-- Creates separate event type for detailed sleep stage tracking
--
-- sleep_session_event - Overall sleep session (bedtime to wake)
-- sleep_period_event - Individual sleep stages (REM, Deep, Core, Awake)
--
-- Enables HealthKit-style sleep tracking with multiple periods per night
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Create sleep_period_event (separate from sleep_session)
-- =====================================================

-- Just add the new sleep_period_event (keep existing sleep_event as is)
INSERT INTO event_types (event_type_id, name, category, description, is_active) VALUES
('sleep_period_event', 'Sleep Period/Stage', 'sleep', 'Individual sleep stage within a session (REM, Deep, Core, Awake)', true)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  updated_at = now();

-- Update existing sleep_event description for clarity
UPDATE event_types
SET
  name = 'Sleep Session',
  description = 'Overall sleep session from bedtime to wake time'
WHERE event_type_id = 'sleep_event';


-- =====================================================
-- Add Sleep Period Fields (4 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_SLEEP_PERIOD_TYPE', 'sleep_period_type_id', 'Sleep Stage', 'Type of sleep stage (REM, Deep, Core, Awake)', 'reference', 'uuid', 'sleep_period_event', true),
('DEF_SLEEP_PERIOD_START', 'sleep_period_start', 'Period Start', 'When this sleep stage started', 'timestamp', 'datetime', 'sleep_period_event', true),
('DEF_SLEEP_PERIOD_END', 'sleep_period_end', 'Period End', 'When this sleep stage ended', 'timestamp', 'datetime', 'sleep_period_event', true),
('DEF_SLEEP_SESSION_ID', 'sleep_session_id', 'Sleep Session', 'Link to parent sleep session', 'reference', 'uuid', 'sleep_period_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- Update sleep_event field descriptions for clarity
-- =====================================================

UPDATE data_entry_fields
SET
  description = 'When got in bed (start of session)'
WHERE field_id = 'DEF_SLEEP_BEDTIME';

UPDATE data_entry_fields
SET
  description = 'When got out of bed (end of session)'
WHERE field_id = 'DEF_SLEEP_WAKETIME';

-- Session quality and factors remain the same


-- =====================================================
-- Create patient_sleep_periods table
-- =====================================================
-- Stores individual sleep stages within a session

CREATE TABLE IF NOT EXISTS patient_sleep_periods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Link to parent sleep session
  sleep_session_id UUID,  -- References patient_events or patient_sleep_sessions

  -- Sleep stage
  sleep_period_type_id UUID REFERENCES sleep_period_types(id) ON DELETE SET NULL,

  -- HealthKit integration (hybrid pattern)
  healthkit_identifier TEXT,  -- HKCategoryTypeIdentifierSleepAnalysis
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,
  healthkit_uuid UUID,  -- Original HK UUID for deduplication
  hk_category_value INTEGER,  -- HKCategoryValueSleepAnalysis enum (0-6)

  -- Time period
  period_start TIMESTAMPTZ NOT NULL,
  period_end TIMESTAMPTZ NOT NULL,
  duration_minutes NUMERIC GENERATED ALWAYS AS (
    EXTRACT(EPOCH FROM (period_end - period_start)) / 60
  ) STORED,

  -- Metadata
  source_name TEXT,  -- App that recorded (e.g., Apple Watch, manual)
  device_name TEXT,

  -- Sync metadata
  was_user_entered BOOLEAN DEFAULT false,
  sync_source TEXT,  -- 'healthkit', 'manual', 'integration'
  last_synced_at TIMESTAMPTZ,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Constraints
  CONSTRAINT sleep_period_end_after_start CHECK (period_end > period_start)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sleep_periods_user_time
  ON patient_sleep_periods(user_id, period_start DESC);

CREATE INDEX IF NOT EXISTS idx_sleep_periods_session
  ON patient_sleep_periods(sleep_session_id);

CREATE INDEX IF NOT EXISTS idx_sleep_periods_type
  ON patient_sleep_periods(sleep_period_type_id);

CREATE INDEX IF NOT EXISTS idx_sleep_periods_hk_uuid
  ON patient_sleep_periods(healthkit_uuid);

-- Unique constraint for HealthKit deduplication
CREATE UNIQUE INDEX IF NOT EXISTS idx_sleep_periods_hk_dedup
  ON patient_sleep_periods(user_id, healthkit_uuid)
  WHERE healthkit_uuid IS NOT NULL;

COMMENT ON TABLE patient_sleep_periods IS
'Stores individual sleep stages (REM, Deep, Core, Awake) within a sleep session. Matches HealthKit HKCategorySample structure.';


-- =====================================================
-- Create helper view for sleep analysis
-- =====================================================

CREATE OR REPLACE VIEW patient_sleep_analysis AS
SELECT
  user_id,
  DATE(period_start) as sleep_date,

  -- Session bounds (MIN/MAX of all periods for that night)
  MIN(period_start) as session_start,
  MAX(period_end) as session_end,

  -- Total time in bed
  EXTRACT(EPOCH FROM (MAX(period_end) - MIN(period_start))) / 60 as time_in_bed_minutes,

  -- Sleep stages (by type)
  SUM(duration_minutes) FILTER (WHERE spt.period_name = 'rem') as rem_minutes,
  SUM(duration_minutes) FILTER (WHERE spt.period_name = 'deep') as deep_minutes,
  SUM(duration_minutes) FILTER (WHERE spt.period_name = 'core') as core_minutes,
  SUM(duration_minutes) FILTER (WHERE spt.period_name = 'awake') as awake_minutes,

  -- Total sleep (all restorative periods)
  SUM(duration_minutes) FILTER (WHERE spt.is_restorative = true) as total_sleep_minutes,

  -- Sleep efficiency
  ROUND(
    (SUM(duration_minutes) FILTER (WHERE spt.is_restorative = true) /
     NULLIF(EXTRACT(EPOCH FROM (MAX(period_end) - MIN(period_start))) / 60, 0)) * 100,
    1
  ) as sleep_efficiency_percent

FROM patient_sleep_periods psp
LEFT JOIN sleep_period_types spt ON psp.sleep_period_type_id = spt.id
GROUP BY user_id, DATE(period_start);

COMMENT ON VIEW patient_sleep_analysis IS
'Aggregates sleep periods into nightly summaries with sleep stages, efficiency, and total sleep time.';


-- =====================================================
-- Enable RLS
-- =====================================================

ALTER TABLE patient_sleep_periods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sleep periods"
  ON patient_sleep_periods FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sleep periods"
  ON patient_sleep_periods FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sleep periods"
  ON patient_sleep_periods FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sleep periods"
  ON patient_sleep_periods FOR DELETE
  USING (auth.uid() = user_id);


-- =====================================================
-- Create updated_at trigger
-- =====================================================

CREATE TRIGGER update_sleep_periods_updated_at
  BEFORE UPDATE ON patient_sleep_periods
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMIT;
