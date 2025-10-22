-- =====================================================
-- Populate Event Type Dependencies
-- =====================================================
-- Auto-generated mapping of fields and calculations to events
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Field Dependencies
-- =====================================================

-- EVT_ADDED_SUGAR (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_ADDED_SUGAR', 'DEF_ADDED_SUGAR_QUANTITY', 'field', false, 1),
('EVT_ADDED_SUGAR', 'DEF_ADDED_SUGAR_TIME', 'field', false, 2),
('EVT_ADDED_SUGAR', 'DEF_ADDED_SUGAR_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_AGE (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_AGE', 'DEF_AGE', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_ALCOHOL (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_ALCOHOL', 'DEF_ALCOHOL_QUANTITY', 'field', false, 1),
('EVT_ALCOHOL', 'DEF_ALCOHOL_TIME', 'field', false, 2),
('EVT_ALCOHOL', 'DEF_ALCOHOL_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_BEVERAGE (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_BEVERAGE', 'DEF_BEVERAGE_QUANTITY', 'field', false, 1),
('EVT_BEVERAGE', 'DEF_BEVERAGE_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_BLOOD_PRESSURE (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_BLOOD_PRESSURE', 'DEF_BLOOD_PRESSURE_DIA', 'field', false, 1),
('EVT_BLOOD_PRESSURE', 'DEF_BLOOD_PRESSURE_SYS', 'field', false, 2),
('EVT_BLOOD_PRESSURE', 'DEF_BLOOD_PRESSURE_TIME', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_BMI (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_BMI', 'DEF_BMI', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_BMR (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_BMR', 'DEF_BMR', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_BODY_FAT (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_BODY_FAT', 'DEF_BODY_FAT_PCT', 'field', false, 1),
('EVT_BODY_FAT', 'DEF_BODY_FAT_TIME', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_BRAIN_TRAINING (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_BRAIN_TRAINING', 'DEF_BRAIN_TRAINING_END', 'field', true, 1),
('EVT_BRAIN_TRAINING', 'DEF_BRAIN_TRAINING_START', 'field', true, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_BRUSHING (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_BRUSHING', 'DEF_BRUSHING_TIME', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_CAFFEINE (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_CAFFEINE', 'DEF_CAFFEINE_QUANTITY', 'field', false, 1),
('EVT_CAFFEINE', 'DEF_CAFFEINE_TIME', 'field', false, 2),
('EVT_CAFFEINE', 'DEF_CAFFEINE_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_CALORIES (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_CALORIES', 'DEF_CALORIES_CONSUMED', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_CARDIO (9 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_CARDIO', 'DEF_CARDIO_CALORIES', 'field', false, 1),
('EVT_CARDIO', 'DEF_CARDIO_DISTANCE', 'field', false, 2),
('EVT_CARDIO', 'DEF_CARDIO_DISTANCE_KM', 'field', false, 3),
('EVT_CARDIO', 'DEF_CARDIO_DISTANCE_MILES', 'field', false, 4),
('EVT_CARDIO', 'DEF_CARDIO_DISTANCE_UNITS', 'field', false, 5),
('EVT_CARDIO', 'DEF_CARDIO_END', 'field', true, 6),
('EVT_CARDIO', 'DEF_CARDIO_INTENSITY', 'field', false, 7),
('EVT_CARDIO', 'DEF_CARDIO_START', 'field', true, 8),
('EVT_CARDIO', 'DEF_CARDIO_TYPE', 'field', false, 9)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_CIGARETTE (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_CIGARETTE', 'DEF_CIGARETTE_QUANTITY', 'field', false, 1),
('EVT_CIGARETTE', 'DEF_CIGARETTE_TIME', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_FAT (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_FAT', 'DEF_FAT_GRAMS', 'field', false, 1),
('EVT_FAT', 'DEF_FAT_SERVINGS', 'field', false, 2),
('EVT_FAT', 'DEF_FAT_TIME', 'field', false, 3),
('EVT_FAT', 'DEF_FAT_TYPE', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_FIBER (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_FIBER', 'DEF_FIBER_GRAMS', 'field', false, 1),
('EVT_FIBER', 'DEF_FIBER_SERVINGS', 'field', false, 2),
('EVT_FIBER', 'DEF_FIBER_SOURCE', 'field', false, 3),
('EVT_FIBER', 'DEF_FIBER_TIME', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_FLEXIBILITY (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_FLEXIBILITY', 'DEF_FLEXIBILITY_END', 'field', true, 1),
('EVT_FLEXIBILITY', 'DEF_FLEXIBILITY_INTENSITY', 'field', false, 2),
('EVT_FLEXIBILITY', 'DEF_FLEXIBILITY_START', 'field', true, 3),
('EVT_FLEXIBILITY', 'DEF_FLEXIBILITY_TYPE', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_FLOSSING (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_FLOSSING', 'DEF_FLOSSING_TIME', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_FOCUS (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_FOCUS', 'DEF_FOCUS_RATING', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_FOOD (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_FOOD', 'DEF_FOOD_QUANTITY', 'field', false, 1),
('EVT_FOOD', 'DEF_FOOD_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_FRUIT (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_FRUIT', 'DEF_FRUIT_QUANTITY', 'field', true, 1),
('EVT_FRUIT', 'DEF_FRUIT_TIME', 'field', false, 2),
('EVT_FRUIT', 'DEF_FRUIT_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_GENDER (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_GENDER', 'DEF_GENDER', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_GRATITUDE (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_GRATITUDE', 'DEF_GRATITUDE_CONTENT', 'field', false, 1),
('EVT_GRATITUDE', 'DEF_GRATITUDE_TIME', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_HEIGHT (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_HEIGHT', 'DEF_HEIGHT', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_HIIT (5 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_HIIT', 'DEF_HIIT_CALORIES', 'field', false, 1),
('EVT_HIIT', 'DEF_HIIT_END', 'field', true, 2),
('EVT_HIIT', 'DEF_HIIT_INTENSITY', 'field', false, 3),
('EVT_HIIT', 'DEF_HIIT_START', 'field', true, 4),
('EVT_HIIT', 'DEF_HIIT_TYPE', 'field', false, 5)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_HIP (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_HIP', 'DEF_HIP_CIRCUMFERENCE', 'field', false, 1),
('EVT_HIP', 'DEF_HIP_CM', 'field', false, 2),
('EVT_HIP', 'DEF_HIP_IN', 'field', false, 3),
('EVT_HIP', 'DEF_HIP_TIME', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_HIP_WAIST_RATIO (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_HIP_WAIST_RATIO', 'DEF_HIP_WAIST_RATIO', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_JOURNALING (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_JOURNALING', 'DEF_JOURNALING_END', 'field', true, 1),
('EVT_JOURNALING', 'DEF_JOURNALING_START', 'field', true, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_LEAN_MASS (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_LEAN_MASS', 'DEF_LEAN_BODY_MASS', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_LEGUME (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_LEGUME', 'DEF_LEGUME_QUANTITY', 'field', false, 1),
('EVT_LEGUME', 'DEF_LEGUME_TIME', 'field', false, 2),
('EVT_LEGUME', 'DEF_LEGUME_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_MEAL (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_MEAL', 'DEF_MEAL_QUALIFIERS', 'field', false, 1),
('EVT_MEAL', 'DEF_MEAL_SIZE', 'field', false, 2),
('EVT_MEAL', 'DEF_MEAL_TIME', 'field', false, 3),
('EVT_MEAL', 'DEF_MEAL_TYPE', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_MEASUREMENT (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_MEASUREMENT', 'DEF_MEASUREMENT_TIME', 'field', false, 1),
('EVT_MEASUREMENT', 'DEF_MEASUREMENT_TYPE', 'field', false, 2),
('EVT_MEASUREMENT', 'DEF_MEASUREMENT_UNIT', 'field', false, 3),
('EVT_MEASUREMENT', 'DEF_MEASUREMENT_VALUE', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_MEMORY (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_MEMORY', 'DEF_MEMORY_CLARITY_RATING', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_MINDFULNESS (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_MINDFULNESS', 'DEF_MINDFULNESS_END', 'field', true, 1),
('EVT_MINDFULNESS', 'DEF_MINDFULNESS_START', 'field', true, 2),
('EVT_MINDFULNESS', 'DEF_MINDFULNESS_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_MOBILITY (5 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_MOBILITY', 'DEF_MOBILITY_CALORIES', 'field', false, 1),
('EVT_MOBILITY', 'DEF_MOBILITY_END', 'field', true, 2),
('EVT_MOBILITY', 'DEF_MOBILITY_INTENSITY', 'field', false, 3),
('EVT_MOBILITY', 'DEF_MOBILITY_START', 'field', true, 4),
('EVT_MOBILITY', 'DEF_MOBILITY_TYPE', 'field', false, 5)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_MOOD (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_MOOD', 'DEF_MOOD_RATING', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_NECK (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_NECK', 'DEF_NECK_CIRCUMFERENCE', 'field', false, 1),
('EVT_NECK', 'DEF_NECK_CM', 'field', false, 2),
('EVT_NECK', 'DEF_NECK_IN', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_NUT_SEED (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_NUT_SEED', 'DEF_NUT_SEED_QUANTITY', 'field', false, 1),
('EVT_NUT_SEED', 'DEF_NUT_SEED_TIME', 'field', false, 2),
('EVT_NUT_SEED', 'DEF_NUT_SEED_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_OUTDOOR (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_OUTDOOR', 'DEF_OUTDOOR_END', 'field', true, 1),
('EVT_OUTDOOR', 'DEF_OUTDOOR_START', 'field', true, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_PROCESSED_MEAT (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_PROCESSED_MEAT', 'DEF_PROCESSED_MEAT_QUANTITY', 'field', false, 1),
('EVT_PROCESSED_MEAT', 'DEF_PROCESSED_MEAT_TIME', 'field', false, 2),
('EVT_PROCESSED_MEAT', 'DEF_PROCESSED_MEAT_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_PROTEIN (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_PROTEIN', 'DEF_PROTEIN_GRAMS', 'field', false, 1),
('EVT_PROTEIN', 'DEF_PROTEIN_SERVINGS', 'field', false, 2),
('EVT_PROTEIN', 'DEF_PROTEIN_TIME', 'field', false, 3),
('EVT_PROTEIN', 'DEF_PROTEIN_TYPE', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SCREENING (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SCREENING', 'DEF_SCREENING_DATE', 'field', false, 1),
('EVT_SCREENING', 'DEF_SCREENING_NAME', 'field', false, 2),
('EVT_SCREENING', 'DEF_SCREENING_RESULT', 'field', false, 3),
('EVT_SCREENING', 'DEF_SCREENING_TYPE', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SCREEN_TIME (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SCREEN_TIME', 'DEF_SCREEN_TIME_DATE', 'field', false, 1),
('EVT_SCREEN_TIME', 'DEF_SCREEN_TIME_QUANTITY', 'field', false, 2),
('EVT_SCREEN_TIME', 'DEF_SCREEN_TIME_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SKINCARE (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SKINCARE', 'DEF_SKINCARE_STEP', 'field', false, 1),
('EVT_SKINCARE', 'DEF_SKINCARE_TIME', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SLEEP (7 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SLEEP', 'DEF_SLEEP_BEDTIME', 'field', true, 1),
('EVT_SLEEP', 'DEF_SLEEP_FACTORS', 'field', false, 2),
('EVT_SLEEP', 'DEF_SLEEP_PERIOD_END', 'field', false, 3),
('EVT_SLEEP', 'DEF_SLEEP_PERIOD_START', 'field', false, 4),
('EVT_SLEEP', 'DEF_SLEEP_PERIOD_TYPE', 'field', false, 5),
('EVT_SLEEP', 'DEF_SLEEP_QUALITY', 'field', false, 6),
('EVT_SLEEP', 'DEF_SLEEP_WAKETIME', 'field', true, 7)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SOCIAL (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SOCIAL', 'DEF_SOCIAL_EVENT_TIME', 'field', false, 1),
('EVT_SOCIAL', 'DEF_SOCIAL_EVENT_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_STEPS (1 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_STEPS', 'DEF_STEPS', 'field', false, 1)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_STRENGTH (6 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_STRENGTH', 'DEF_STRENGTH_CALORIES', 'field', false, 1),
('EVT_STRENGTH', 'DEF_STRENGTH_END', 'field', true, 2),
('EVT_STRENGTH', 'DEF_STRENGTH_INTENSITY', 'field', false, 3),
('EVT_STRENGTH', 'DEF_STRENGTH_MUSCLE_GROUPS', 'field', false, 4),
('EVT_STRENGTH', 'DEF_STRENGTH_START', 'field', true, 5),
('EVT_STRENGTH', 'DEF_STRENGTH_TYPE', 'field', false, 6)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_STRESS (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_STRESS', 'DEF_STRESS_FACTORS', 'field', false, 1),
('EVT_STRESS', 'DEF_STRESS_LEVEL', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SUBSTANCE (5 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SUBSTANCE', 'DEF_SUBSTANCE_DATE', 'field', false, 1),
('EVT_SUBSTANCE', 'DEF_SUBSTANCE_QUANTITY', 'field', false, 2),
('EVT_SUBSTANCE', 'DEF_SUBSTANCE_SOURCE', 'field', false, 3),
('EVT_SUBSTANCE', 'DEF_SUBSTANCE_TYPE', 'field', false, 4),
('EVT_SUBSTANCE', 'DEF_SUBSTANCE_USAGE_LEVEL', 'field', false, 5)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SUNLIGHT (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SUNLIGHT', 'DEF_SUNLIGHT_END', 'field', true, 1),
('EVT_SUNLIGHT', 'DEF_SUNLIGHT_START', 'field', true, 2),
('EVT_SUNLIGHT', 'DEF_SUNLIGHT_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_SUNSCREEN (2 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_SUNSCREEN', 'DEF_SUNSCREEN_TIME', 'field', false, 1),
('EVT_SUNSCREEN', 'DEF_SUNSCREEN_TYPE', 'field', false, 2)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_THERAPEUTIC (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_THERAPEUTIC', 'DEF_THERAPEUTIC_DOSE', 'field', false, 1),
('EVT_THERAPEUTIC', 'DEF_THERAPEUTIC_TIME', 'field', false, 2),
('EVT_THERAPEUTIC', 'DEF_THERAPEUTIC_TYPE', 'field', false, 3),
('EVT_THERAPEUTIC', 'DEF_THERAPEUTIC_UNITS', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_ULTRA_PROCESSED (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_ULTRA_PROCESSED', 'DEF_ULTRA_PROCESSED_QUANTITY', 'field', false, 1),
('EVT_ULTRA_PROCESSED', 'DEF_ULTRA_PROCESSED_TIME', 'field', false, 2),
('EVT_ULTRA_PROCESSED', 'DEF_ULTRA_PROCESSED_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_UNHEALTHY_BEVERAGE (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_UNHEALTHY_BEVERAGE', 'DEF_UNHEALTHY_BEV_QUANTITY', 'field', false, 1),
('EVT_UNHEALTHY_BEVERAGE', 'DEF_UNHEALTHY_BEV_TIME', 'field', false, 2),
('EVT_UNHEALTHY_BEVERAGE', 'DEF_UNHEALTHY_BEV_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_VEGETABLE (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_VEGETABLE', 'DEF_VEGETABLE_QUANTITY', 'field', true, 1),
('EVT_VEGETABLE', 'DEF_VEGETABLE_TIME', 'field', false, 2),
('EVT_VEGETABLE', 'DEF_VEGETABLE_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_WAIST (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_WAIST', 'DEF_WAIST_CIRCUMFERENCE', 'field', false, 1),
('EVT_WAIST', 'DEF_WAIST_CM', 'field', false, 2),
('EVT_WAIST', 'DEF_WAIST_IN', 'field', false, 3),
('EVT_WAIST', 'DEF_WAIST_TIME', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_WATER (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_WATER', 'DEF_WATER_QUANTITY', 'field', true, 1),
('EVT_WATER', 'DEF_WATER_TIME', 'field', false, 2),
('EVT_WATER', 'DEF_WATER_UNITS', 'field', true, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_WEIGHT (4 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_WEIGHT', 'DEF_WEIGHT', 'field', false, 1),
('EVT_WEIGHT', 'DEF_WEIGHT_KG', 'field', false, 2),
('EVT_WEIGHT', 'DEF_WEIGHT_LB', 'field', false, 3),
('EVT_WEIGHT', 'DEF_WEIGHT_TIME', 'field', false, 4)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;

-- EVT_WHOLE_GRAIN (3 fields)
INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)
VALUES
('EVT_WHOLE_GRAIN', 'DEF_WHOLE_GRAIN_QUANTITY', 'field', true, 1),
('EVT_WHOLE_GRAIN', 'DEF_WHOLE_GRAIN_TIME', 'field', false, 2),
('EVT_WHOLE_GRAIN', 'DEF_WHOLE_GRAIN_TYPE', 'field', false, 3)
ON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET
  is_required = EXCLUDED.is_required,
  display_order = EXCLUDED.display_order;


-- =====================================================
-- PART 2: Calculation Dependencies
-- =====================================================

-- EVT_BMI (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_BMI', 'CALC_BMI', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_BMR (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_BMR', 'CALC_BMR', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_BODY_FAT (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_BODY_FAT', 'CALC_BODY_FAT_PERCENTAGE', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_BRAIN_TRAINING (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_BRAIN_TRAINING', 'CALC_BRAIN_TRAINING_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_CARDIO (3 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_CARDIO', 'CALC_CARDIO_DURATION', 'calculation', false, 100),
('EVT_CARDIO', 'CALC_DISTANCE_KM_TO_MILES', 'calculation', false, 101),
('EVT_CARDIO', 'CALC_DISTANCE_MILES_TO_KM', 'calculation', false, 102)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_FAT (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_FAT', 'CALC_FAT_GRAMS_TO_SERVINGS', 'calculation', false, 100),
('EVT_FAT', 'CALC_FAT_SERVINGS_TO_GRAMS', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_FIBER (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_FIBER', 'CALC_FIBER_GRAMS_TO_SERVINGS', 'calculation', false, 100),
('EVT_FIBER', 'CALC_FIBER_SERVINGS_TO_GRAMS', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_FRUIT (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_FRUIT', 'CALC_FRUIT_TYPE_TO_NUTRITION', 'calculation', false, 100),
('EVT_FRUIT', 'CALC_FRUITS_TO_FIBER', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_HIIT (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_HIIT', 'CALC_HIIT_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_HIP (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_HIP', 'CALC_HIP_IN_TO_CM', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_HIP_WAIST_RATIO (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_HIP_WAIST_RATIO', 'CALC_HIP_WAIST_RATIO', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_JOURNALING (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_JOURNALING', 'CALC_JOURNALING_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_LEAN_MASS (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_LEAN_MASS', 'CALC_LEAN_BODY_MASS', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_LEGUME (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_LEGUME', 'CALC_LEGUME_TYPE_TO_NUTRITION', 'calculation', false, 100),
('EVT_LEGUME', 'CALC_LEGUMES_TO_FIBER_PROTEIN', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_MINDFULNESS (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_MINDFULNESS', 'CALC_MINDFULNESS_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_MOBILITY (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_MOBILITY', 'CALC_MOBILITY_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_NECK (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_NECK', 'CALC_NECK_IN_TO_CM', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_NUT_SEED (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_NUT_SEED', 'CALC_NUT_SEED_TYPE_TO_NUTRITION', 'calculation', false, 100),
('EVT_NUT_SEED', 'CALC_NUTS_SEEDS_TO_NUTRITION', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_OUTDOOR (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_OUTDOOR', 'CALC_OUTDOOR_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_PROTEIN (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_PROTEIN', 'CALC_PROTEIN_GRAMS_TO_SERVINGS', 'calculation', false, 100),
('EVT_PROTEIN', 'CALC_PROTEIN_SERVINGS_TO_GRAMS', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_SLEEP (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_SLEEP', 'CALC_SLEEP_DURATION', 'calculation', false, 100),
('EVT_SLEEP', 'CALC_SLEEP_PERIOD_DURATION', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_STRENGTH (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_STRENGTH', 'CALC_STRENGTH_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_SUNLIGHT (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_SUNLIGHT', 'CALC_SUNLIGHT_DURATION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_VEGETABLE (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_VEGETABLE', 'CALC_VEGETABLE_TYPE_TO_NUTRITION', 'calculation', false, 100),
('EVT_VEGETABLE', 'CALC_VEGETABLES_TO_FIBER', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_WAIST (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_WAIST', 'CALC_WAIST_IN_TO_CM', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_WATER (1 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_WATER', 'CALC_WATER_UNIT_CONVERSION', 'calculation', false, 100)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_WEIGHT (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_WEIGHT', 'CALC_WEIGHT_KG_TO_LB', 'calculation', false, 100),
('EVT_WEIGHT', 'CALC_WEIGHT_LB_TO_KG', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;

-- EVT_WHOLE_GRAIN (2 calculations)
INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)
VALUES
('EVT_WHOLE_GRAIN', 'CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION', 'calculation', false, 100),
('EVT_WHOLE_GRAIN', 'CALC_WHOLE_GRAINS_TO_FIBER', 'calculation', false, 101)
ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET
  display_order = EXCLUDED.display_order;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  field_dep_count INT;
  calc_dep_count INT;
BEGIN
  SELECT COUNT(*) INTO field_dep_count FROM event_types_dependencies WHERE dependency_type = 'field';
  SELECT COUNT(*) INTO calc_dep_count FROM event_types_dependencies WHERE dependency_type = 'calculation';

  RAISE NOTICE '✅ Event Dependencies Populated';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Field Dependencies: %', field_dep_count;
  RAISE NOTICE '  Calculation Dependencies: %', calc_dep_count;
  RAISE NOTICE '  Total: %', field_dep_count + calc_dep_count;
END $$;

COMMIT;
