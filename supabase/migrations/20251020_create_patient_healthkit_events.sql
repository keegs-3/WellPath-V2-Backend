-- =====================================================
-- Patient HealthKit Event Tables
-- =====================================================
-- Creates patient event tables following Apple's HealthKit data model:
-- - HKObject properties: UUID, metadata, source, device
-- - HKSample properties: type, start_date, end_date
-- - Hybrid pattern: healthkit_identifier (text) + healthkit_mapping_id (FK)
--
-- Four main event types matching HealthKit sample types:
-- 1. patient_quantity_events (HKQuantitySample)
-- 2. patient_category_events (HKCategorySample)
-- 3. patient_workout_events (HKWorkout)
-- 4. patient_correlation_events (HKCorrelation)
--
-- Created: 2025-10-20
-- =====================================================

BEGIN;

-- =====================================================
-- 1. patient_quantity_events (HKQuantitySample)
-- =====================================================
-- Numeric measurements: nutrition, activity, vitals, body measurements
-- Examples: steps, calories, heart rate, weight, blood pressure
CREATE TABLE IF NOT EXISTS patient_quantity_events (
  -- HKObject properties
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Hybrid HealthKit reference
  healthkit_identifier TEXT,  -- Raw HK identifier (e.g., HKQuantityTypeIdentifierStepCount)
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,
  healthkit_uuid UUID,  -- Original UUID from HealthKit (for deduplication)

  -- HKSample temporal properties
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,

  -- HKQuantitySample value
  quantity NUMERIC NOT NULL,
  unit TEXT NOT NULL,  -- e.g., "count", "mg", "kcal", "bpm"

  -- HKObject metadata
  metadata JSONB,  -- Additional HK metadata (workout route, device info, etc.)

  -- Source information (HKSourceRevision)
  source_name TEXT,  -- App or device name
  source_version TEXT,  -- App/OS version
  source_bundle_id TEXT,  -- App bundle identifier

  -- Device information (HKDevice)
  device_name TEXT,  -- e.g., "Apple Watch Series 8"
  device_manufacturer TEXT,  -- e.g., "Apple Inc."
  device_model TEXT,  -- e.g., "Watch6,1"
  device_hardware TEXT,  -- Hardware version
  device_software TEXT,  -- Software version

  -- Sync metadata
  was_user_entered BOOLEAN DEFAULT false,
  sync_source TEXT,  -- 'healthkit', 'manual', 'integration'
  sync_identifier TEXT,  -- External system identifier
  last_synced_at TIMESTAMPTZ,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for patient_quantity_events
CREATE INDEX IF NOT EXISTS idx_quantity_events_user_time
  ON patient_quantity_events(user_id, start_time DESC);

CREATE INDEX IF NOT EXISTS idx_quantity_events_hk_identifier
  ON patient_quantity_events(healthkit_identifier);

CREATE INDEX IF NOT EXISTS idx_quantity_events_hk_mapping
  ON patient_quantity_events(healthkit_mapping_id);

CREATE INDEX IF NOT EXISTS idx_quantity_events_hk_uuid
  ON patient_quantity_events(healthkit_uuid);

CREATE INDEX IF NOT EXISTS idx_quantity_events_sync_source
  ON patient_quantity_events(sync_source, last_synced_at);

-- Unique constraint to prevent duplicate HealthKit imports
CREATE UNIQUE INDEX IF NOT EXISTS idx_quantity_events_hk_dedup
  ON patient_quantity_events(user_id, healthkit_uuid)
  WHERE healthkit_uuid IS NOT NULL;

-- Partial index for user-entered data
CREATE INDEX IF NOT EXISTS idx_quantity_events_user_entered
  ON patient_quantity_events(user_id, start_time DESC)
  WHERE was_user_entered = true;

COMMENT ON TABLE patient_quantity_events IS
'Stores HKQuantitySample data: numeric measurements like steps, calories, heart rate, weight, etc.';


-- =====================================================
-- 2. patient_category_events (HKCategorySample)
-- =====================================================
-- Categorical data from finite set of values
-- Examples: sleep analysis, mindfulness, toothbrushing
CREATE TABLE IF NOT EXISTS patient_category_events (
  -- HKObject properties
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Hybrid HealthKit reference
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,
  healthkit_uuid UUID,

  -- HKSample temporal properties
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,

  -- HKCategorySample value (enum value from predefined set)
  category_value INTEGER NOT NULL,  -- Maps to HKCategoryValue enum
  category_value_text TEXT,  -- Human-readable value

  -- HKObject metadata
  metadata JSONB,

  -- Source information
  source_name TEXT,
  source_version TEXT,
  source_bundle_id TEXT,

  -- Device information
  device_name TEXT,
  device_manufacturer TEXT,
  device_model TEXT,
  device_hardware TEXT,
  device_software TEXT,

  -- Sync metadata
  was_user_entered BOOLEAN DEFAULT false,
  sync_source TEXT,
  sync_identifier TEXT,
  last_synced_at TIMESTAMPTZ,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for patient_category_events
CREATE INDEX IF NOT EXISTS idx_category_events_user_time
  ON patient_category_events(user_id, start_time DESC);

CREATE INDEX IF NOT EXISTS idx_category_events_hk_identifier
  ON patient_category_events(healthkit_identifier);

CREATE INDEX IF NOT EXISTS idx_category_events_hk_mapping
  ON patient_category_events(healthkit_mapping_id);

CREATE INDEX IF NOT EXISTS idx_category_events_hk_uuid
  ON patient_category_events(healthkit_uuid);

CREATE UNIQUE INDEX IF NOT EXISTS idx_category_events_hk_dedup
  ON patient_category_events(user_id, healthkit_uuid)
  WHERE healthkit_uuid IS NOT NULL;

COMMENT ON TABLE patient_category_events IS
'Stores HKCategorySample data: sleep analysis, mindfulness, toothbrushing, etc.';


-- =====================================================
-- 3. patient_workout_events (HKWorkout)
-- =====================================================
-- Physical activity sessions
-- Examples: running, cycling, swimming, strength training
CREATE TABLE IF NOT EXISTS patient_workout_events (
  -- HKObject properties
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Hybrid HealthKit reference
  healthkit_identifier TEXT,  -- HKWorkoutActivityType
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,
  healthkit_uuid UUID,

  -- HKSample temporal properties
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  duration_minutes NUMERIC GENERATED ALWAYS AS (
    EXTRACT(EPOCH FROM (end_time - start_time)) / 60
  ) STORED,

  -- HKWorkout specific properties
  workout_activity_type TEXT,  -- e.g., "Running", "Cycling", "Swimming"
  total_distance NUMERIC,
  total_distance_unit TEXT,  -- e.g., "mi", "km", "m"
  total_energy_burned NUMERIC,  -- Active calories
  total_energy_burned_unit TEXT,  -- e.g., "kcal"

  -- Additional workout metrics
  average_heart_rate NUMERIC,
  max_heart_rate NUMERIC,
  elevation_gain NUMERIC,
  elevation_gain_unit TEXT,

  -- Indoor/outdoor
  is_indoor BOOLEAN,

  -- Weather conditions (from metadata)
  weather_temperature NUMERIC,
  weather_humidity NUMERIC,

  -- Route information
  has_route BOOLEAN DEFAULT false,
  route_data JSONB,  -- Geo coordinates if available

  -- HKObject metadata
  metadata JSONB,

  -- Source information
  source_name TEXT,
  source_version TEXT,
  source_bundle_id TEXT,

  -- Device information
  device_name TEXT,
  device_manufacturer TEXT,
  device_model TEXT,
  device_hardware TEXT,
  device_software TEXT,

  -- Sync metadata
  was_user_entered BOOLEAN DEFAULT false,
  sync_source TEXT,
  sync_identifier TEXT,
  last_synced_at TIMESTAMPTZ,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Constraints
  CONSTRAINT workout_end_after_start CHECK (end_time > start_time)
);

-- Indexes for patient_workout_events
CREATE INDEX IF NOT EXISTS idx_workout_events_user_time
  ON patient_workout_events(user_id, start_time DESC);

CREATE INDEX IF NOT EXISTS idx_workout_events_hk_identifier
  ON patient_workout_events(healthkit_identifier);

CREATE INDEX IF NOT EXISTS idx_workout_events_hk_mapping
  ON patient_workout_events(healthkit_mapping_id);

CREATE INDEX IF NOT EXISTS idx_workout_events_activity_type
  ON patient_workout_events(workout_activity_type);

CREATE INDEX IF NOT EXISTS idx_workout_events_hk_uuid
  ON patient_workout_events(healthkit_uuid);

CREATE UNIQUE INDEX IF NOT EXISTS idx_workout_events_hk_dedup
  ON patient_workout_events(user_id, healthkit_uuid)
  WHERE healthkit_uuid IS NOT NULL;

COMMENT ON TABLE patient_workout_events IS
'Stores HKWorkout data: physical activity sessions with duration, distance, calories, heart rate, etc.';


-- =====================================================
-- 4. patient_correlation_events (HKCorrelation)
-- =====================================================
-- Composite measurements combining multiple samples
-- Examples: blood pressure (systolic + diastolic), food (nutrition facts)
CREATE TABLE IF NOT EXISTS patient_correlation_events (
  -- HKObject properties
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Hybrid HealthKit reference
  healthkit_identifier TEXT,  -- HKCorrelationTypeIdentifier
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,
  healthkit_uuid UUID,

  -- HKSample temporal properties
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,

  -- HKCorrelation type
  correlation_type TEXT,  -- 'blood_pressure', 'food'

  -- Correlation components (stored as JSONB for flexibility)
  -- Blood pressure: {"systolic": 120, "diastolic": 80}
  -- Food: {"calories": 250, "protein": 15, "carbs": 30, "fat": 10}
  components JSONB NOT NULL,

  -- HKObject metadata
  metadata JSONB,

  -- Source information
  source_name TEXT,
  source_version TEXT,
  source_bundle_id TEXT,

  -- Device information
  device_name TEXT,
  device_manufacturer TEXT,
  device_model TEXT,
  device_hardware TEXT,
  device_software TEXT,

  -- Sync metadata
  was_user_entered BOOLEAN DEFAULT false,
  sync_source TEXT,
  sync_identifier TEXT,
  last_synced_at TIMESTAMPTZ,

  -- Audit
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for patient_correlation_events
CREATE INDEX IF NOT EXISTS idx_correlation_events_user_time
  ON patient_correlation_events(user_id, start_time DESC);

CREATE INDEX IF NOT EXISTS idx_correlation_events_hk_identifier
  ON patient_correlation_events(healthkit_identifier);

CREATE INDEX IF NOT EXISTS idx_correlation_events_hk_mapping
  ON patient_correlation_events(healthkit_mapping_id);

CREATE INDEX IF NOT EXISTS idx_correlation_events_type
  ON patient_correlation_events(correlation_type);

CREATE INDEX IF NOT EXISTS idx_correlation_events_hk_uuid
  ON patient_correlation_events(healthkit_uuid);

CREATE UNIQUE INDEX IF NOT EXISTS idx_correlation_events_hk_dedup
  ON patient_correlation_events(user_id, healthkit_uuid)
  WHERE healthkit_uuid IS NOT NULL;

-- GIN index for JSONB component queries
CREATE INDEX IF NOT EXISTS idx_correlation_events_components
  ON patient_correlation_events USING GIN (components);

COMMENT ON TABLE patient_correlation_events IS
'Stores HKCorrelation data: composite measurements like blood pressure, food nutrition, etc.';


-- =====================================================
-- Enable Row Level Security (RLS)
-- =====================================================
ALTER TABLE patient_quantity_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_category_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_workout_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_correlation_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Users can only access their own data
CREATE POLICY "Users can view own quantity events"
  ON patient_quantity_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quantity events"
  ON patient_quantity_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own quantity events"
  ON patient_quantity_events FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own quantity events"
  ON patient_quantity_events FOR DELETE
  USING (auth.uid() = user_id);

-- Repeat for other tables
CREATE POLICY "Users can view own category events"
  ON patient_category_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own category events"
  ON patient_category_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own workout events"
  ON patient_workout_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workout events"
  ON patient_workout_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own correlation events"
  ON patient_correlation_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own correlation events"
  ON patient_correlation_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);


-- =====================================================
-- Create updated_at triggers
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quantity_events_updated_at
  BEFORE UPDATE ON patient_quantity_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_category_events_updated_at
  BEFORE UPDATE ON patient_category_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_events_updated_at
  BEFORE UPDATE ON patient_workout_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_correlation_events_updated_at
  BEFORE UPDATE ON patient_correlation_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMIT;
