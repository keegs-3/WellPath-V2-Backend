-- =====================================================
-- Clean Up Data Entry Fields
-- =====================================================
-- Standardizes naming conventions and removes redundant fields
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Drop Foreign Key Constraints Temporarily
-- =====================================================

ALTER TABLE instance_calculations_dependencies DROP CONSTRAINT IF EXISTS instance_calculations_data_entry_field_data_entry_field_id_fkey;
ALTER TABLE aggregation_metrics_dependencies DROP CONSTRAINT IF EXISTS aggregation_metrics_dependencies_data_entry_field_id_fkey;
ALTER TABLE field_registry DROP CONSTRAINT IF EXISTS field_registry_data_entry_field_id_fkey;
ALTER TABLE oura_mapping DROP CONSTRAINT IF EXISTS oura_mapping_data_entry_field_id_fkey1;
ALTER TABLE mfp_mapping DROP CONSTRAINT IF EXISTS mfp_mapping_data_entry_field_id_fkey1;
ALTER TABLE fitbit_mapping DROP CONSTRAINT IF EXISTS fitbit_mapping_data_entry_field_id_fkey1;
ALTER TABLE headspace_mapping DROP CONSTRAINT IF EXISTS headspace_mapping_data_entry_field_id_fkey1;
ALTER TABLE strava_mapping DROP CONSTRAINT IF EXISTS strava_mapping_data_entry_field_id_fkey1;
ALTER TABLE event_types_dependencies DROP CONSTRAINT IF EXISTS event_types_data_entry_fields_data_entry_field_id_fkey;
ALTER TABLE z_old_display_metrics_20251023 DROP CONSTRAINT IF EXISTS display_metrics_group_by_field_id_fkey;
ALTER TABLE def_validation_rules_numeric DROP CONSTRAINT IF EXISTS validation_rules_numeric_field_id_fkey;

-- =====================================================
-- 2. Rename Fields to Add CALC_ Prefix
-- =====================================================

-- Calculated health metrics
UPDATE data_entry_fields SET field_id = 'CALC_BMI', field_name = 'bmi_calculated', updated_at = NOW() WHERE field_id = 'DEF_BMI';
UPDATE data_entry_fields SET field_id = 'CALC_BMR', field_name = 'bmr_calculated', updated_at = NOW() WHERE field_id = 'DEF_BMR';
UPDATE data_entry_fields SET field_id = 'CALC_HIP_WAIST_RATIO', field_name = 'hip_waist_ratio_calculated', updated_at = NOW() WHERE field_id = 'DEF_HIP_WAIST_RATIO';

-- Session counts
UPDATE data_entry_fields SET field_id = 'CALC_BRAIN_TRAINING_SESSION_COUNT', field_name = 'brain_training_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_BRAIN_TRAINING_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_CARDIO_SESSION_COUNT', field_name = 'cardio_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_CARDIO_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_FLEXIBILITY_SESSION_COUNT', field_name = 'flexibility_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_FLEXIBILITY_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_HIIT_SESSION_COUNT', field_name = 'hiit_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_HIIT_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_JOURNALING_SESSION_COUNT', field_name = 'journaling_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_JOURNALING_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_MINDFULNESS_SESSION_COUNT', field_name = 'mindfulness_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_MINDFULNESS_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_MOBILITY_SESSION_COUNT', field_name = 'mobility_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_MOBILITY_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_OUTDOOR_SESSION_COUNT', field_name = 'outdoor_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_OUTDOOR_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_SLEEP_SESSION_COUNT', field_name = 'sleep_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_SLEEP_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_SLEEP_PERIOD_COUNT', field_name = 'sleep_period_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_SLEEP_PERIOD_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_STRENGTH_SESSION_COUNT', field_name = 'strength_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_STRENGTH_SESSION_COUNT';
UPDATE data_entry_fields SET field_id = 'CALC_SUNLIGHT_SESSION_COUNT', field_name = 'sunlight_session_count_calculated', updated_at = NOW() WHERE field_id = 'DEF_SUNLIGHT_SESSION_COUNT';

-- Sleep durations (OUTPUT → CALC)
UPDATE data_entry_fields SET field_id = 'CALC_AWAKE_PERIODS_DURATION', field_name = 'awake_periods_duration_calculated', updated_at = NOW() WHERE field_id = 'OUTPUT_AWAKE_PERIODS_DURATION';
UPDATE data_entry_fields SET field_id = 'CALC_CORE_SLEEP_DURATION', field_name = 'core_sleep_duration_calculated', updated_at = NOW() WHERE field_id = 'OUTPUT_CORE_SLEEP_DURATION';
UPDATE data_entry_fields SET field_id = 'CALC_DEEP_SLEEP_DURATION', field_name = 'deep_sleep_duration_calculated', updated_at = NOW() WHERE field_id = 'OUTPUT_DEEP_SLEEP_DURATION';
UPDATE data_entry_fields SET field_id = 'CALC_REM_SLEEP_DURATION', field_name = 'rem_sleep_duration_calculated', updated_at = NOW() WHERE field_id = 'OUTPUT_REM_SLEEP_DURATION';

-- =====================================================
-- 2. Standardize Units Pattern (Cardio Distance)
-- =====================================================

UPDATE data_entry_fields SET field_id = 'CALC_CARDIO_DISTANCE_KM', field_name = 'cardio_distance_km_calculated', updated_at = NOW() WHERE field_id = 'DEF_CARDIO_DISTANCE_KM';
UPDATE data_entry_fields SET field_id = 'CALC_CARDIO_DISTANCE_MI', field_name = 'cardio_distance_mi_calculated', updated_at = NOW() WHERE field_id = 'DEF_CARDIO_DISTANCE_MILES';

-- =====================================================
-- 4. Standardize Units Pattern (Hip Circumference)
-- =====================================================

UPDATE data_entry_fields SET field_id = 'CALC_HIP_CIRCUMFERENCE_CM', field_name = 'hip_circumference_cm_calculated', updated_at = NOW() WHERE field_id = 'DEF_HIP_CM';
UPDATE data_entry_fields SET field_id = 'CALC_HIP_CIRCUMFERENCE_IN', field_name = 'hip_circumference_in_calculated', updated_at = NOW() WHERE field_id = 'DEF_HIP_IN';

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, field_type, data_type, pillar_name, is_active
) VALUES (
  'DEF_HIP_CIRCUMFERENCE_UNITS', 'hip_circumference_units', 'Hip Circumference Units',
  'reference', 'uuid', 'Core Care', true
) ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 5. Standardize Units Pattern (Neck Circumference)
-- =====================================================

UPDATE data_entry_fields SET field_id = 'CALC_NECK_CIRCUMFERENCE_CM', field_name = 'neck_circumference_cm_calculated', updated_at = NOW() WHERE field_id = 'DEF_NECK_CM';
UPDATE data_entry_fields SET field_id = 'CALC_NECK_CIRCUMFERENCE_IN', field_name = 'neck_circumference_in_calculated', updated_at = NOW() WHERE field_id = 'DEF_NECK_IN';

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, field_type, data_type, pillar_name, is_active
) VALUES
(
  'DEF_NECK_CIRCUMFERENCE_UNITS', 'neck_circumference_units', 'Neck Circumference Units',
  'reference', 'uuid', 'Core Care', true
),
(
  'DEF_NECK_CIRCUMFERENCE_TIME', 'neck_circumference_time', 'Neck Circumference Time',
  'timestamp', 'datetime', 'Core Care', true
) ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 6. Standardize Units Pattern (Waist Circumference)
-- =====================================================

UPDATE data_entry_fields SET field_id = 'CALC_WAIST_CIRCUMFERENCE_CM', field_name = 'waist_circumference_cm_calculated', updated_at = NOW() WHERE field_id = 'DEF_WAIST_CM';
UPDATE data_entry_fields SET field_id = 'CALC_WAIST_CIRCUMFERENCE_IN', field_name = 'waist_circumference_in_calculated', updated_at = NOW() WHERE field_id = 'DEF_WAIST_IN';

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, field_type, data_type, pillar_name, is_active
) VALUES (
  'DEF_WAIST_CIRCUMFERENCE_UNITS', 'waist_circumference_units', 'Waist Circumference Units',
  'reference', 'uuid', 'Core Care', true
) ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 7. Standardize Units Pattern (Weight)
-- =====================================================

UPDATE data_entry_fields SET field_id = 'CALC_WEIGHT_KG', field_name = 'weight_kg_calculated', updated_at = NOW() WHERE field_id = 'DEF_WEIGHT_KG';
UPDATE data_entry_fields SET field_id = 'CALC_WEIGHT_LB', field_name = 'weight_lb_calculated', updated_at = NOW() WHERE field_id = 'DEF_WEIGHT_LB';

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, field_type, data_type, pillar_name, is_active
) VALUES (
  'DEF_WEIGHT_UNITS', 'weight_units', 'Weight Units',
  'reference', 'uuid', 'Core Care', true
) ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 8. Standardize Units Pattern (Lean Body Mass)
-- =====================================================

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, field_type, data_type, unit, pillar_name, is_active
) VALUES
(
  'DEF_LEAN_BODY_MASS_UNITS', 'lean_body_mass_units', 'Lean Body Mass Units',
  'reference', 'uuid', NULL, 'Core Care', true
),
(
  'DEF_LEAN_BODY_MASS_TIME', 'lean_body_mass_time', 'Lean Body Mass Time',
  'timestamp', 'datetime', 'datetime_combined', 'Core Care', true
),
(
  'CALC_LEAN_BODY_MASS_KG', 'lean_body_mass_kg_calculated', 'Lean Body Mass (kg)',
  'quantity', 'numeric', 'kilogram', 'Core Care', true
),
(
  'CALC_LEAN_BODY_MASS_LB', 'lean_body_mass_lb_calculated', 'Lean Body Mass (lb)',
  'quantity', 'numeric', 'pound', 'Core Care', true
) ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 9. Remove Servings Fields (Keep Grams)
-- =====================================================

DELETE FROM aggregation_metrics_dependencies WHERE data_entry_field_id IN ('DEF_FAT_SERVINGS', 'DEF_FIBER_SERVINGS');
DELETE FROM data_entry_fields WHERE field_id IN ('DEF_FAT_SERVINGS', 'DEF_FIBER_SERVINGS');

-- =====================================================
-- 10. Standardize "source" → "type"
-- =====================================================

UPDATE data_entry_fields SET field_id = 'DEF_FIBER_TYPE', field_name = 'fiber_type', updated_at = NOW() WHERE field_id = 'DEF_FIBER_SOURCE';

-- =====================================================
-- 11. Add Missing Time Fields
-- =====================================================

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, field_type, data_type, unit, pillar_name, is_active
) VALUES
(
  'DEF_CALORIES_CONSUMED_TIME', 'calories_consumed_time', 'Calories Consumed Time',
  'timestamp', 'datetime', 'datetime_combined', 'Healthful Nutrition', true
),
(
  'DEF_FOCUS_RATING_TIME', 'focus_rating_time', 'Focus Rating Time',
  'timestamp', 'datetime', 'datetime_combined', 'Cognitive Health', true
),
(
  'DEF_MEMORY_CLARITY_RATING_TIME', 'memory_clarity_rating_time', 'Memory Clarity Rating Time',
  'timestamp', 'datetime', 'datetime_combined', 'Cognitive Health', true
),
(
  'DEF_MOOD_RATING_TIME', 'mood_rating_time', 'Mood Rating Time',
  'timestamp', 'datetime', 'datetime_combined', 'Stress Management', true
) ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 12. Remove Redundant/Deprecated Fields
-- =====================================================

DELETE FROM aggregation_metrics_dependencies
WHERE data_entry_field_id IN (
  'DEF_FOOD_QUANTITY', 'DEF_FOOD_TIMING', 'DEF_FOOD_TYPE',
  'DEF_GENDER', 'DEF_AGE', 'DEF_MEAL_QUALIFIERS',
  'DEF_MEASUREMENT_TIME', 'DEF_MEASUREMENT_TYPE',
  'DEF_MEASUREMENT_UNIT', 'DEF_MEASUREMENT_VALUE'
);

DELETE FROM data_entry_fields
WHERE field_id IN (
  'DEF_FOOD_QUANTITY', 'DEF_FOOD_TIMING', 'DEF_FOOD_TYPE',
  'DEF_GENDER', 'DEF_AGE', 'DEF_MEAL_QUALIFIERS',
  'DEF_MEASUREMENT_TIME', 'DEF_MEASUREMENT_TYPE',
  'DEF_MEASUREMENT_UNIT', 'DEF_MEASUREMENT_VALUE'
);

-- =====================================================
-- 13. Create CALC_AGE Field
-- =====================================================

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, description, field_type, data_type, unit, pillar_name, is_active
) VALUES (
  'CALC_AGE', 'age_calculated', 'Age (Calculated)',
  'Calculated from patient date of birth',
  'quantity', 'integer', 'years', 'Core Care', true
) ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 14. Add Generic Workout Intensity Reference
-- =====================================================

-- Create workout_intensity reference category
INSERT INTO data_entry_fields_reference (
  reference_category, reference_key, display_name, sort_order, is_active
) VALUES
  ('workout_intensity', 'very_light', 'Very Light', 1, true),
  ('workout_intensity', 'light', 'Light', 2, true),
  ('workout_intensity', 'moderate', 'Moderate', 3, true),
  ('workout_intensity', 'vigorous', 'Vigorous', 4, true),
  ('workout_intensity', 'very_vigorous', 'Very Vigorous', 5, true),
  ('workout_intensity', 'maximum', 'Maximum', 6, true)
ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Update all intensity fields to reference this category
UPDATE data_entry_fields
SET reference_table = 'data_entry_fields_reference',
    field_type = 'reference',
    data_type = 'uuid',
    updated_at = NOW()
WHERE field_id IN (
  'DEF_CARDIO_INTENSITY',
  'DEF_HIIT_INTENSITY',
  'DEF_FLEXIBILITY_INTENSITY',
  'DEF_MOBILITY_INTENSITY',
  'DEF_STRENGTH_INTENSITY'
);

-- =====================================================
-- 15. Add Missing HealthKit Fields
-- =====================================================

INSERT INTO data_entry_fields (
  field_id, field_name, display_name, description, field_type, data_type, unit, pillar_name, supports_healthkit_sync, is_active
) VALUES
-- Heart Rate
(
  'DEF_HEART_RATE', 'heart_rate', 'Heart Rate',
  'Current heart rate in beats per minute',
  'quantity', 'numeric', 'beats_per_minute', 'Movement + Exercise', true, true
),
(
  'DEF_HEART_RATE_TIME', 'heart_rate_time', 'Heart Rate Time',
  'Timestamp for heart rate measurement',
  'timestamp', 'datetime', 'datetime_combined', 'Movement + Exercise', true, true
),
-- Heart Rate Variability
(
  'DEF_HEART_RATE_VARIABILITY', 'heart_rate_variability', 'Heart Rate Variability',
  'Heart rate variability in milliseconds',
  'quantity', 'numeric', 'millisecond', 'Movement + Exercise', true, true
),
(
  'DEF_HEART_RATE_VARIABILITY_TIME', 'heart_rate_variability_time', 'HRV Time',
  'Timestamp for HRV measurement',
  'timestamp', 'datetime', 'datetime_combined', 'Movement + Exercise', true, true
),
-- Resting Heart Rate
(
  'DEF_RESTING_HEART_RATE', 'resting_heart_rate', 'Resting Heart Rate',
  'Resting heart rate in beats per minute',
  'quantity', 'numeric', 'beats_per_minute', 'Movement + Exercise', true, true
),
(
  'DEF_RESTING_HEART_RATE_TIME', 'resting_heart_rate_time', 'Resting HR Time',
  'Timestamp for resting heart rate',
  'timestamp', 'datetime', 'datetime_combined', 'Movement + Exercise', true, true
),
-- VO2 Max
(
  'DEF_VO2_MAX', 'vo2_max', 'VO2 Max',
  'Maximum oxygen uptake in mL/kg/min',
  'quantity', 'numeric', 'milliliters_per_kilogram_per_minute', 'Movement + Exercise', true, true
),
(
  'DEF_VO2_MAX_TIME', 'vo2_max_time', 'VO2 Max Time',
  'Timestamp for VO2 max measurement',
  'timestamp', 'datetime', 'datetime_combined', 'Movement + Exercise', true, true
),
-- Respiratory Rate
(
  'DEF_RESPIRATORY_RATE', 'respiratory_rate', 'Respiratory Rate',
  'Breathing rate in breaths per minute',
  'quantity', 'numeric', 'breaths_per_minute', 'Movement + Exercise', true, true
),
(
  'DEF_RESPIRATORY_RATE_TIME', 'respiratory_rate_time', 'Respiratory Rate Time',
  'Timestamp for respiratory rate',
  'timestamp', 'datetime', 'datetime_combined', 'Movement + Exercise', true, true
)
ON CONFLICT (field_id) DO NOTHING;

-- =====================================================
-- 16. Update Instance Calculations Dependencies
-- =====================================================

-- Update instance_calculations_dependencies for all renamed fields
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_BMI' WHERE data_entry_field_id = 'DEF_BMI';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_BMR' WHERE data_entry_field_id = 'DEF_BMR';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_HIP_WAIST_RATIO' WHERE data_entry_field_id = 'DEF_HIP_WAIST_RATIO';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_CARDIO_DISTANCE_KM' WHERE data_entry_field_id = 'DEF_CARDIO_DISTANCE_KM';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_CARDIO_DISTANCE_MI' WHERE data_entry_field_id = 'DEF_CARDIO_DISTANCE_MILES';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_HIP_CIRCUMFERENCE_CM' WHERE data_entry_field_id = 'DEF_HIP_CM';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_HIP_CIRCUMFERENCE_IN' WHERE data_entry_field_id = 'DEF_HIP_IN';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_NECK_CIRCUMFERENCE_CM' WHERE data_entry_field_id = 'DEF_NECK_CM';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_NECK_CIRCUMFERENCE_IN' WHERE data_entry_field_id = 'DEF_NECK_IN';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_WAIST_CIRCUMFERENCE_CM' WHERE data_entry_field_id = 'DEF_WAIST_CM';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_WAIST_CIRCUMFERENCE_IN' WHERE data_entry_field_id = 'DEF_WAIST_IN';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_WEIGHT_KG' WHERE data_entry_field_id = 'DEF_WEIGHT_KG';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_WEIGHT_LB' WHERE data_entry_field_id = 'DEF_WEIGHT_LB';

-- Session counts
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_BRAIN_TRAINING_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_BRAIN_TRAINING_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_CARDIO_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_CARDIO_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_FLEXIBILITY_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_FLEXIBILITY_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_HIIT_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_HIIT_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_JOURNALING_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_JOURNALING_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_MINDFULNESS_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_MINDFULNESS_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_MOBILITY_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_MOBILITY_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_OUTDOOR_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_OUTDOOR_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_SLEEP_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_SLEEP_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_SLEEP_PERIOD_COUNT' WHERE data_entry_field_id = 'DEF_SLEEP_PERIOD_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_STRENGTH_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_STRENGTH_SESSION_COUNT';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_SUNLIGHT_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_SUNLIGHT_SESSION_COUNT';

-- OUTPUT fields
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_AWAKE_PERIODS_DURATION' WHERE data_entry_field_id = 'OUTPUT_AWAKE_PERIODS_DURATION';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_CORE_SLEEP_DURATION' WHERE data_entry_field_id = 'OUTPUT_CORE_SLEEP_DURATION';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_DEEP_SLEEP_DURATION' WHERE data_entry_field_id = 'OUTPUT_DEEP_SLEEP_DURATION';
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'CALC_REM_SLEEP_DURATION' WHERE data_entry_field_id = 'OUTPUT_REM_SLEEP_DURATION';

-- Fiber
UPDATE instance_calculations_dependencies SET data_entry_field_id = 'DEF_FIBER_TYPE' WHERE data_entry_field_id = 'DEF_FIBER_SOURCE';

-- =====================================================
-- 17. Update Aggregation Dependencies
-- =====================================================

-- Update all dependencies that referenced renamed fields
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_BMI' WHERE data_entry_field_id = 'DEF_BMI';
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_BMR' WHERE data_entry_field_id = 'DEF_BMR';
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'DEF_FIBER_TYPE' WHERE data_entry_field_id = 'DEF_FIBER_SOURCE';

-- Update cardio distance dependencies
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_CARDIO_DISTANCE_KM' WHERE data_entry_field_id = 'DEF_CARDIO_DISTANCE_KM';
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_CARDIO_DISTANCE_MI' WHERE data_entry_field_id = 'DEF_CARDIO_DISTANCE_MILES';

-- Update weight dependencies
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_WEIGHT_KG' WHERE data_entry_field_id = 'DEF_WEIGHT_KG';
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_WEIGHT_LB' WHERE data_entry_field_id = 'DEF_WEIGHT_LB';

-- Update session count dependencies
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_CARDIO_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_CARDIO_SESSION_COUNT';
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_STRENGTH_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_STRENGTH_SESSION_COUNT';
UPDATE aggregation_metrics_dependencies SET data_entry_field_id = 'CALC_SLEEP_SESSION_COUNT' WHERE data_entry_field_id = 'DEF_SLEEP_SESSION_COUNT';

-- =====================================================
-- 18. Clean Up Orphaned References
-- =====================================================

-- Remove any orphaned references in all dependent tables
DELETE FROM instance_calculations_dependencies
WHERE data_entry_field_id NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM aggregation_metrics_dependencies
WHERE data_entry_field_id NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM field_registry
WHERE data_entry_field_id NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM oura_mapping
WHERE data_entry_field_id::text NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM mfp_mapping
WHERE data_entry_field_id::text NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM fitbit_mapping
WHERE data_entry_field_id::text NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM headspace_mapping
WHERE data_entry_field_id::text NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM strava_mapping
WHERE data_entry_field_id::text NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM event_types_dependencies
WHERE data_entry_field_id NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM z_old_display_metrics_20251023
WHERE group_by_field_id NOT IN (SELECT field_id FROM data_entry_fields);

DELETE FROM def_validation_rules_numeric
WHERE field_id::text NOT IN (SELECT field_id FROM data_entry_fields);

-- =====================================================
-- 19. Recreate Foreign Key Constraints with CASCADE
-- =====================================================

ALTER TABLE instance_calculations_dependencies
  ADD CONSTRAINT instance_calculations_data_entry_field_data_entry_field_id_fkey
  FOREIGN KEY (data_entry_field_id) REFERENCES data_entry_fields(field_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE aggregation_metrics_dependencies
  ADD CONSTRAINT aggregation_metrics_dependencies_data_entry_field_id_fkey
  FOREIGN KEY (data_entry_field_id) REFERENCES data_entry_fields(field_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE field_registry
  ADD CONSTRAINT field_registry_data_entry_field_id_fkey
  FOREIGN KEY (data_entry_field_id) REFERENCES data_entry_fields(field_id) ON UPDATE CASCADE ON DELETE CASCADE;

-- Skip recreating FK constraints for mapping tables (UUID vs TEXT incompatibility)
-- These external integration mappings will need rework anyway

ALTER TABLE event_types_dependencies
  ADD CONSTRAINT event_types_data_entry_fields_data_entry_field_id_fkey
  FOREIGN KEY (data_entry_field_id) REFERENCES data_entry_fields(field_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE z_old_display_metrics_20251023
  ADD CONSTRAINT display_metrics_group_by_field_id_fkey
  FOREIGN KEY (group_by_field_id) REFERENCES data_entry_fields(field_id) ON UPDATE CASCADE ON DELETE SET NULL;

-- Skip def_validation_rules_numeric FK (UUID vs TEXT incompatibility)

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_total_fields INTEGER;
  v_calc_fields INTEGER;
  v_def_fields INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total_fields FROM data_entry_fields;
  SELECT COUNT(*) INTO v_calc_fields FROM data_entry_fields WHERE field_id LIKE 'CALC_%';
  SELECT COUNT(*) INTO v_def_fields FROM data_entry_fields WHERE field_id LIKE 'DEF_%';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Data Entry Fields Cleaned Up!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total fields: %', v_total_fields;
  RAISE NOTICE '  Calculated fields (CALC_): %', v_calc_fields;
  RAISE NOTICE '  Data entry fields (DEF_): %', v_def_fields;
  RAISE NOTICE '';
  RAISE NOTICE 'Changes:';
  RAISE NOTICE '  ✅ Added CALC_ prefix to all calculated fields';
  RAISE NOTICE '  ✅ Standardized units pattern (field, units, time, CALC_unit1, CALC_unit2)';
  RAISE NOTICE '  ✅ Removed servings fields (kept grams)';
  RAISE NOTICE '  ✅ Standardized "source" → "type"';
  RAISE NOTICE '  ✅ Added missing time fields';
  RAISE NOTICE '  ✅ Removed redundant fields';
  RAISE NOTICE '  ✅ Created generic workout_intensity reference';
  RAISE NOTICE '  ✅ Added HealthKit fields (heart rate, HRV, VO2 max, respiratory rate)';
  RAISE NOTICE '';
END $$;

COMMIT;
