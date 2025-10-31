-- =====================================================
-- Clean Up Event Types
-- =====================================================
-- Adds event types for new HealthKit fields and removes obsolete dependencies
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add Event Types for New HealthKit Fields
-- =====================================================

INSERT INTO event_types (
  event_type_id,
  name,
  description,
  category,
  is_active,
  supports_manual_entry,
  supports_api_ingestion
) VALUES
(
  'EVT_HEART_RATE',
  'Heart Rate',
  'Heart rate measurement in beats per minute',
  'biometric',
  true,
  true,
  true
),
(
  'EVT_HEART_RATE_VARIABILITY',
  'Heart Rate Variability',
  'Heart rate variability (HRV) measurement in milliseconds',
  'biometric',
  true,
  false,
  true
),
(
  'EVT_RESTING_HEART_RATE',
  'Resting Heart Rate',
  'Resting heart rate measurement in beats per minute',
  'biometric',
  true,
  true,
  true
),
(
  'EVT_VO2_MAX',
  'VO2 Max',
  'Maximum oxygen uptake (VO2 max) in mL/kg/min',
  'biometric',
  true,
  false,
  true
),
(
  'EVT_RESPIRATORY_RATE',
  'Respiratory Rate',
  'Breathing rate in breaths per minute',
  'biometric',
  true,
  true,
  true
)
ON CONFLICT (event_type_id) DO NOTHING;

-- =====================================================
-- 2. Add Dependencies for New HealthKit Fields
-- =====================================================

-- Heart Rate
INSERT INTO event_types_dependencies (
  event_type_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('EVT_HEART_RATE', 'DEF_HEART_RATE', 'field'),
  ('EVT_HEART_RATE', 'DEF_HEART_RATE_TIME', 'field')
ON CONFLICT DO NOTHING;

-- Heart Rate Variability
INSERT INTO event_types_dependencies (
  event_type_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('EVT_HEART_RATE_VARIABILITY', 'DEF_HEART_RATE_VARIABILITY', 'field'),
  ('EVT_HEART_RATE_VARIABILITY', 'DEF_HEART_RATE_VARIABILITY_TIME', 'field')
ON CONFLICT DO NOTHING;

-- Resting Heart Rate
INSERT INTO event_types_dependencies (
  event_type_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('EVT_RESTING_HEART_RATE', 'DEF_RESTING_HEART_RATE', 'field'),
  ('EVT_RESTING_HEART_RATE', 'DEF_RESTING_HEART_RATE_TIME', 'field')
ON CONFLICT DO NOTHING;

-- VO2 Max
INSERT INTO event_types_dependencies (
  event_type_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('EVT_VO2_MAX', 'DEF_VO2_MAX', 'field'),
  ('EVT_VO2_MAX', 'DEF_VO2_MAX_TIME', 'field')
ON CONFLICT DO NOTHING;

-- Respiratory Rate
INSERT INTO event_types_dependencies (
  event_type_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('EVT_RESPIRATORY_RATE', 'DEF_RESPIRATORY_RATE', 'field'),
  ('EVT_RESPIRATORY_RATE', 'DEF_RESPIRATORY_RATE_TIME', 'field')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. Update Existing Event Types for Renamed Fields
-- =====================================================

-- Update fiber event to use DEF_FIBER_TYPE instead of DEF_FIBER_SOURCE
UPDATE event_types_dependencies
SET data_entry_field_id = 'DEF_FIBER_TYPE'
WHERE event_type_id = 'EVT_FIBER'
  AND data_entry_field_id = 'DEF_FIBER_SOURCE';

-- =====================================================
-- 4. Remove Obsolete Event Types
-- =====================================================

-- Remove AGE and GENDER event types (moved to patient onboarding)
DELETE FROM event_types_dependencies
WHERE event_type_id IN ('EVT_AGE', 'EVT_GENDER');

DELETE FROM event_types
WHERE event_type_id IN ('EVT_AGE', 'EVT_GENDER');

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_total_event_types INTEGER;
  v_total_deps INTEGER;
  v_biometric_events INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total_event_types FROM event_types;
  SELECT COUNT(*) INTO v_total_deps FROM event_types_dependencies;
  SELECT COUNT(*) INTO v_biometric_events FROM event_types WHERE category = 'biometric';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Event Types Cleaned Up!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total event types: %', v_total_event_types;
  RAISE NOTICE '  Biometric event types: %', v_biometric_events;
  RAISE NOTICE '  Total dependencies: %', v_total_deps;
  RAISE NOTICE '';
  RAISE NOTICE 'Added HealthKit Event Types:';
  RAISE NOTICE '  ✅ EVT_HEART_RATE';
  RAISE NOTICE '  ✅ EVT_HEART_RATE_VARIABILITY';
  RAISE NOTICE '  ✅ EVT_RESTING_HEART_RATE';
  RAISE NOTICE '  ✅ EVT_VO2_MAX';
  RAISE NOTICE '  ✅ EVT_RESPIRATORY_RATE';
  RAISE NOTICE '';
  RAISE NOTICE 'Removed:';
  RAISE NOTICE '  ❌ EVT_AGE (moved to patient onboarding)';
  RAISE NOTICE '  ❌ EVT_GENDER (moved to patient onboarding)';
  RAISE NOTICE '';
END $$;

COMMIT;
