-- =====================================================
-- Add Calories Burned Fields to All Workout Types
-- =====================================================
-- HealthKit provides calories burned for all workout types
-- Add calories field for cardio, strength, HIIT, and mobility
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Calories Fields for All Workout Types
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  is_active,
  healthkit_identifier,
  healthkit_mapping_id,
  supports_healthkit_sync,
  validation_config
) VALUES
-- Cardio calories
(
  'DEF_CARDIO_CALORIES',
  'cardio_calories',
  'Calories Burned',
  'Calories burned during cardio activity (HealthKit: Active Energy Burned)',
  'quantity',
  'numeric',
  'kilocalorie',
  true,
  'HKQuantityTypeIdentifierActiveEnergyBurned',
  (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierActiveEnergyBurned'),
  true,
  '{"min": 0, "max": 5000, "increment": 1}'::jsonb
),
-- Strength training calories
(
  'DEF_STRENGTH_CALORIES',
  'strength_calories',
  'Calories Burned',
  'Calories burned during strength training (HealthKit: Active Energy Burned)',
  'quantity',
  'numeric',
  'kilocalorie',
  true,
  'HKQuantityTypeIdentifierActiveEnergyBurned',
  (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierActiveEnergyBurned'),
  true,
  '{"min": 0, "max": 3000, "increment": 1}'::jsonb
),
-- HIIT calories
(
  'DEF_HIIT_CALORIES',
  'hiit_calories',
  'Calories Burned',
  'Calories burned during HIIT workout (HealthKit: Active Energy Burned)',
  'quantity',
  'numeric',
  'kilocalorie',
  true,
  'HKQuantityTypeIdentifierActiveEnergyBurned',
  (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierActiveEnergyBurned'),
  true,
  '{"min": 0, "max": 2000, "increment": 1}'::jsonb
),
-- Mobility/Flexibility calories
(
  'DEF_MOBILITY_CALORIES',
  'mobility_calories',
  'Calories Burned',
  'Calories burned during mobility/flexibility session (HealthKit: Active Energy Burned)',
  'quantity',
  'numeric',
  'kilocalorie',
  true,
  'HKQuantityTypeIdentifierActiveEnergyBurned',
  (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierActiveEnergyBurned'),
  true,
  '{"min": 0, "max": 1000, "increment": 1}'::jsonb
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 2: Add Comments for Clarity
-- =====================================================

COMMENT ON COLUMN data_entry_fields.healthkit_identifier IS
'HKQuantityTypeIdentifierActiveEnergyBurned - HealthKit tracks active calories burned during workouts. Unit: kilocalories (kcal).';

-- Note: All workout types use the same HealthKit identifier for calories
-- The workout type itself determines context (cardio vs strength vs HIIT)

COMMIT;
