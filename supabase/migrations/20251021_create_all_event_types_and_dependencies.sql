-- =====================================================
-- Create All Event Types and Dependencies
-- =====================================================
-- Links event types to their required fields and calculations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Event Types
-- =====================================================

-- Sleep Events
INSERT INTO event_types (event_type_id, name, description, category, is_active)
VALUES
('sleep_period', 'Sleep Period', 'Full night sleep tracking', 'sleep', true)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  is_active = EXCLUDED.is_active;

-- Exercise Events
INSERT INTO event_types (event_type_id, name, description, category, is_active)
VALUES
('cardio_session', 'Cardio Session', 'Cardiovascular exercise session', 'exercise', true),
('hiit_session', 'HIIT Session', 'High-Intensity Interval Training session', 'exercise', true),
('strength_session', 'Strength Training', 'Strength/resistance training session', 'exercise', true),
('mobility_session', 'Mobility Session', 'Mobility/flexibility training', 'exercise', true)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  is_active = EXCLUDED.is_active;

-- Mindfulness & Behavioral Events
INSERT INTO event_types (event_type_id, name, description, category, is_active)
VALUES
('mindfulness_session', 'Mindfulness Session', 'Meditation or mindfulness practice', 'behavioral', true),
('brain_training_session', 'Brain Training', 'Cognitive training activity', 'behavioral', true),
('journaling_session', 'Journaling Session', 'Reflective journaling practice', 'behavioral', true),
('outdoor_time', 'Outdoor Time', 'Time spent outdoors', 'behavioral', true),
('sunlight_exposure', 'Sunlight Exposure', 'Direct sunlight exposure', 'behavioral', true)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  is_active = EXCLUDED.is_active;

-- Biometric Events
INSERT INTO event_types (event_type_id, name, description, category, is_active)
VALUES
('biometric_reading', 'Biometric Reading', 'Body measurements and vital signs', 'biometric', true)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  is_active = EXCLUDED.is_active;

-- Nutrition Events (expand existing)
INSERT INTO event_types (event_type_id, name, description, category, is_active)
VALUES
('water_intake', 'Water Intake', 'Water/fluid intake tracking', 'nutrition', true),
('sugar_intake', 'Sugar Intake', 'Added sugar consumption', 'nutrition', true),
('alcohol_intake', 'Alcohol Intake', 'Alcoholic beverage consumption', 'nutrition', true),
('sodium_intake', 'Sodium Intake', 'Sodium consumption tracking', 'nutrition', true)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  is_active = EXCLUDED.is_active;


-- =====================================================
-- PART 2: Link Fields to Event Types
-- =====================================================

-- SLEEP: sleep_period
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('sleep_period', 'DEF_SLEEP_BEDTIME', 'field', true, 1),
('sleep_period', 'DEF_SLEEP_WAKETIME', 'field', true, 2),
('sleep_period', 'DEF_SLEEP_QUALITY', 'field', false, 3),
('sleep_period', 'DEF_SLEEP_INTERRUPTIONS', 'field', false, 4),
('sleep_period', 'DEF_SLEEP_DEEP_SLEEP_MINUTES', 'field', false, 5),
('sleep_period', 'DEF_SLEEP_REM_MINUTES', 'field', false, 6)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- CARDIO: cardio_session
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('cardio_session', 'DEF_CARDIO_START', 'field', true, 1),
('cardio_session', 'DEF_CARDIO_END', 'field', true, 2),
('cardio_session', 'DEF_CARDIO_TYPE', 'field', false, 3),
('cardio_session', 'DEF_CARDIO_DISTANCE', 'field', false, 4),
('cardio_session', 'DEF_CARDIO_DISTANCE_UNIT', 'field', false, 5),
('cardio_session', 'DEF_CARDIO_AVG_HEART_RATE', 'field', false, 6),
('cardio_session', 'DEF_CARDIO_MAX_HEART_RATE', 'field', false, 7),
('cardio_session', 'DEF_CARDIO_CALORIES_BURNED', 'field', false, 8)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- HIIT: hiit_session
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('hiit_session', 'DEF_HIIT_START', 'field', true, 1),
('hiit_session', 'DEF_HIIT_END', 'field', true, 2),
('hiit_session', 'DEF_HIIT_TYPE', 'field', false, 3),
('hiit_session', 'DEF_HIIT_ROUNDS', 'field', false, 4),
('hiit_session', 'DEF_HIIT_WORK_INTERVAL', 'field', false, 5),
('hiit_session', 'DEF_HIIT_REST_INTERVAL', 'field', false, 6),
('hiit_session', 'DEF_HIIT_AVG_HEART_RATE', 'field', false, 7),
('hiit_session', 'DEF_HIIT_MAX_HEART_RATE', 'field', false, 8)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- STRENGTH: strength_session
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('strength_session', 'DEF_STRENGTH_START', 'field', true, 1),
('strength_session', 'DEF_STRENGTH_END', 'field', true, 2),
('strength_session', 'DEF_STRENGTH_TYPE', 'field', false, 3),
('strength_session', 'DEF_STRENGTH_MUSCLE_GROUP', 'field', false, 4),
('strength_session', 'DEF_STRENGTH_SETS', 'field', false, 5),
('strength_session', 'DEF_STRENGTH_REPS', 'field', false, 6),
('strength_session', 'DEF_STRENGTH_WEIGHT', 'field', false, 7),
('strength_session', 'DEF_STRENGTH_WEIGHT_UNIT', 'field', false, 8)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- MOBILITY: mobility_session
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('mobility_session', 'DEF_MOBILITY_START', 'field', true, 1),
('mobility_session', 'DEF_MOBILITY_END', 'field', true, 2),
('mobility_session', 'DEF_MOBILITY_TYPE', 'field', false, 3),
('mobility_session', 'DEF_MOBILITY_FOCUS_AREA', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- MINDFULNESS: mindfulness_session
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('mindfulness_session', 'DEF_MINDFULNESS_START', 'field', true, 1),
('mindfulness_session', 'DEF_MINDFULNESS_END', 'field', true, 2),
('mindfulness_session', 'DEF_MINDFULNESS_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- BRAIN TRAINING: brain_training_session
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('brain_training_session', 'DEF_BRAIN_TRAINING_START', 'field', true, 1),
('brain_training_session', 'DEF_BRAIN_TRAINING_END', 'field', true, 2),
('brain_training_session', 'DEF_BRAIN_TRAINING_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- JOURNALING: journaling_session
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('journaling_session', 'DEF_JOURNALING_START', 'field', true, 1),
('journaling_session', 'DEF_JOURNALING_END', 'field', true, 2),
('journaling_session', 'DEF_JOURNALING_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- OUTDOOR TIME: outdoor_time
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('outdoor_time', 'DEF_OUTDOOR_START', 'field', true, 1),
('outdoor_time', 'DEF_OUTDOOR_END', 'field', true, 2),
('outdoor_time', 'DEF_OUTDOOR_ACTIVITY_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- SUNLIGHT: sunlight_exposure
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('sunlight_exposure', 'DEF_SUNLIGHT_START', 'field', true, 1),
('sunlight_exposure', 'DEF_SUNLIGHT_END', 'field', true, 2),
('sunlight_exposure', 'DEF_SUNLIGHT_TIME_OF_DAY', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- BIOMETRICS: biometric_reading
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('biometric_reading', 'DEF_WEIGHT', 'field', false, 1),
('biometric_reading', 'DEF_HEIGHT', 'field', false, 2),
('biometric_reading', 'DEF_WAIST_CIRCUMFERENCE', 'field', false, 3),
('biometric_reading', 'DEF_HIP_CIRCUMFERENCE', 'field', false, 4),
('biometric_reading', 'DEF_NECK_CIRCUMFERENCE', 'field', false, 5),
('biometric_reading', 'DEF_BODY_FAT_PERCENTAGE', 'field', false, 6),
('biometric_reading', 'DEF_MUSCLE_MASS', 'field', false, 7),
('biometric_reading', 'DEF_BONE_MASS', 'field', false, 8),
('biometric_reading', 'DEF_BLOOD_PRESSURE_SYSTOLIC', 'field', false, 9),
('biometric_reading', 'DEF_BLOOD_PRESSURE_DIASTOLIC', 'field', false, 10),
('biometric_reading', 'DEF_RESTING_HEART_RATE', 'field', false, 11),
('biometric_reading', 'DEF_VO2_MAX', 'field', false, 12)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: protein_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('protein_intake', 'DEF_PROTEIN_SERVINGS', 'field', false, 1),
('protein_intake', 'DEF_PROTEIN_TYPE', 'field', false, 2),
('protein_intake', 'DEF_PROTEIN_GRAMS', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: vegetable_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('vegetable_intake', 'DEF_VEGETABLE_QUANTITY', 'field', true, 1),
('vegetable_intake', 'DEF_VEGETABLE_CATEGORY', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: fruit_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('fruit_intake', 'DEF_FRUIT_QUANTITY', 'field', true, 1),
('fruit_intake', 'DEF_FRUIT_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: whole_grain_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('whole_grain_intake', 'DEF_WHOLE_GRAIN_QUANTITY', 'field', true, 1),
('whole_grain_intake', 'DEF_WHOLE_GRAIN_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: fat_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('fat_intake', 'DEF_HEALTHY_FAT_SERVINGS', 'field', true, 1),
('fat_intake', 'DEF_HEALTHY_FAT_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: legume_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('legume_intake', 'DEF_LEGUME_QUANTITY', 'field', true, 1),
('legume_intake', 'DEF_LEGUME_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: nut_seed_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('nut_seed_intake', 'DEF_NUT_SEED_QUANTITY', 'field', true, 1),
('nut_seed_intake', 'DEF_NUT_SEED_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: fiber_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('fiber_intake', 'DEF_FIBER_GRAMS', 'field', true, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: water_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('water_intake', 'DEF_WATER_QUANTITY', 'field', true, 1),
('water_intake', 'DEF_WATER_UNITS', 'field', true, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: sugar_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('sugar_intake', 'DEF_SUGAR_GRAMS', 'field', true, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: alcohol_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('alcohol_intake', 'DEF_ALCOHOL_SERVINGS', 'field', true, 1),
('alcohol_intake', 'DEF_ALCOHOL_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;

-- NUTRITION: sodium_intake
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('sodium_intake', 'DEF_SODIUM_MILLIGRAMS', 'field', true, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO NOTHING;


-- =====================================================
-- PART 3: Link Instance Calculations to Event Types
-- =====================================================

-- SLEEP: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('sleep_period', 'CALC_SLEEP_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- CARDIO: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('cardio_session', 'CALC_CARDIO_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- HIIT: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('hiit_session', 'CALC_HIIT_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- STRENGTH: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('strength_session', 'CALC_STRENGTH_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- MOBILITY: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('mobility_session', 'CALC_MOBILITY_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- MINDFULNESS: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('mindfulness_session', 'CALC_MINDFULNESS_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- BRAIN TRAINING: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('brain_training_session', 'CALC_BRAIN_TRAINING_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- JOURNALING: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('journaling_session', 'CALC_JOURNALING_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- OUTDOOR: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('outdoor_time', 'CALC_OUTDOOR_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- SUNLIGHT: Duration calculation
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('sunlight_exposure', 'CALC_SUNLIGHT_DURATION', 'calculation', true, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- BIOMETRICS: All biometric calculations
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('biometric_reading', 'CALC_BMI', 'calculation', false, 101),
('biometric_reading', 'CALC_BMR', 'calculation', false, 102),
('biometric_reading', 'CALC_HIP_WAIST_RATIO', 'calculation', false, 103),
('biometric_reading', 'CALC_BODY_FAT_PERCENTAGE', 'calculation', false, 104),
('biometric_reading', 'CALC_LEAN_BODY_MASS', 'calculation', false, 105),
('biometric_reading', 'CALC_WEIGHT_LB_TO_KG', 'calculation', false, 106),
('biometric_reading', 'CALC_WEIGHT_KG_TO_LB', 'calculation', false, 107),
('biometric_reading', 'CALC_HEIGHT_IN_TO_CM', 'calculation', false, 108),
('biometric_reading', 'CALC_HEIGHT_CM_TO_IN', 'calculation', false, 109),
('biometric_reading', 'CALC_WAIST_IN_TO_CM', 'calculation', false, 110),
('biometric_reading', 'CALC_WAIST_CM_TO_IN', 'calculation', false, 111),
('biometric_reading', 'CALC_HIP_IN_TO_CM', 'calculation', false, 112),
('biometric_reading', 'CALC_HIP_CM_TO_IN', 'calculation', false, 113),
('biometric_reading', 'CALC_NECK_IN_TO_CM', 'calculation', false, 114),
('biometric_reading', 'CALC_NECK_CM_TO_IN', 'calculation', false, 115)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

-- NUTRITION: Protein conversions
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('protein_intake', 'CALC_PROTEIN_SERVINGS_TO_GRAMS', 'calculation', false, 101),
('protein_intake', 'CALC_PROTEIN_GRAMS_TO_SERVINGS', 'calculation', false, 102)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  event_count INT;
  field_dep_count INT;
  calc_dep_count INT;
BEGIN
  SELECT COUNT(*) INTO event_count FROM event_types;
  SELECT COUNT(*) INTO field_dep_count FROM event_types_dependencies WHERE dependency_type = 'field';
  SELECT COUNT(*) INTO calc_dep_count FROM event_types_dependencies WHERE dependency_type = 'calculation';

  RAISE NOTICE '✅ Event Types and Dependencies Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Event Types: %', event_count;
  RAISE NOTICE '  Field Dependencies: %', field_dep_count;
  RAISE NOTICE '  Calculation Dependencies: %', calc_dep_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Categories:';
  RAISE NOTICE '  - Sleep: sleep_period';
  RAISE NOTICE '  - Exercise: cardio, hiit, strength, mobility';
  RAISE NOTICE '  - Behavioral: mindfulness, brain_training, journaling, outdoor, sunlight';
  RAISE NOTICE '  - Biometric: biometric_reading';
  RAISE NOTICE '  - Nutrition: protein, vegetable, fruit, whole_grain, fat, legume, nut_seed, fiber, water, sugar, alcohol, sodium';
END $$;

COMMIT;
