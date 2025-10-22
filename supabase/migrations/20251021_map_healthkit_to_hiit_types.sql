-- =====================================================
-- Map HealthKit Identifiers to HIIT Types
-- =====================================================
-- Adds healthkit_identifier column and maps the single HK HIIT type
-- to primary HIIT protocols (Tabata, Sprint Intervals, Circuit, etc.)
--
-- Note: HealthKit has ONE HIIT type that maps to multiple user protocols
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add HealthKit Identifier Column
-- =====================================================

ALTER TABLE def_ref_hiit_types
ADD COLUMN IF NOT EXISTS healthkit_identifier TEXT REFERENCES healthkit_mapping(healthkit_identifier);

-- Create index
CREATE INDEX IF NOT EXISTS idx_hiit_types_hk_identifier
  ON def_ref_hiit_types(healthkit_identifier);


-- =====================================================
-- PART 2: Map HK HIIT Identifier to Primary Protocols
-- =====================================================

-- Map the single HealthKit HIIT type to most common HIIT protocols
-- Users select the protocol when logging; HealthKit sync uses generic HIIT

UPDATE def_ref_hiit_types
SET healthkit_identifier = 'HKWorkoutActivityTypeHighIntensityIntervalTraining'
WHERE hiit_type_key IN (
  'tabata',           -- Most common HIIT protocol
  'sprint_intervals', -- Classic HIIT
  'circuit_training', -- Common gym HIIT
  'emom',             -- Popular functional fitness
  'amrap',            -- Functional fitness
  'bodyweight_hiit',  -- At-home HIIT
  'custom_hiit'       -- Catch-all for synced workouts
);


-- =====================================================
-- PART 3: Add Comments
-- =====================================================

COMMENT ON COLUMN def_ref_hiit_types.healthkit_identifier IS
'HealthKit has ONE HIIT workout type. Multiple protocols map to it. When syncing from HealthKit, default to custom_hiit and let user specify protocol.';

COMMENT ON TABLE def_ref_hiit_types IS
'HIIT protocol types. HealthKit sync uses HKWorkoutActivityTypeHighIntensityIntervalTraining, user selects specific protocol (Tabata, EMOM, etc.) for tracking.';

COMMIT;
