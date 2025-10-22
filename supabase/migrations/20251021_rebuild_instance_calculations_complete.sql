-- =====================================================
-- REBUILD Instance Calculations - Complete
-- =====================================================
-- Drops and rebuilds instance_calculations with ALL
-- required calculations for individual instances
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Drop existing data
-- =====================================================

-- Drop dependencies first (foreign key)
TRUNCATE instance_calculations_dependencies CASCADE;

-- Drop all instance calculations
TRUNCATE instance_calculations CASCADE;

DO $$ BEGIN
  RAISE NOTICE 'Cleared all existing instance_calculations';
END $$;


-- =====================================================
-- PART 2: Duration Calculations (Single Session/Period)
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_001', 'cardio_session_duration', 'Cardio Session Duration', 'Duration of ONE cardio session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_CARDIO_START", "end_time": "DEF_CARDIO_END"}, "output_unit": "minute"}'::jsonb),

('IC_002', 'strength_session_duration', 'Strength Session Duration', 'Duration of ONE strength training session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_STRENGTH_START", "end_time": "DEF_STRENGTH_END"}, "output_unit": "minute"}'::jsonb),

('IC_003', 'mobility_session_duration', 'Mobility Session Duration', 'Duration of ONE mobility/flexibility session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_MOBILITY_START", "end_time": "DEF_MOBILITY_END"}, "output_unit": "minute"}'::jsonb),

('IC_004', 'mindfulness_session_duration', 'Mindfulness Session Duration', 'Duration of ONE mindfulness/meditation session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_MINDFULNESS_START", "end_time": "DEF_MINDFULNESS_END"}, "output_unit": "minute"}'::jsonb),

('IC_005', 'hiit_session_duration', 'HIIT Session Duration', 'Duration of ONE HIIT workout session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_HIIT_START", "end_time": "DEF_HIIT_END"}, "output_unit": "minute"}'::jsonb),

('IC_006', 'outdoor_time_duration', 'Outdoor Time Duration', 'Duration of ONE outdoor time block', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_OUTDOOR_START", "end_time": "DEF_OUTDOOR_END"}, "output_unit": "minute"}'::jsonb),

('IC_007', 'sunlight_exposure_duration', 'Sunlight Exposure Duration', 'Duration of ONE sunlight exposure session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_SUNLIGHT_START", "end_time": "DEF_SUNLIGHT_END"}, "output_unit": "minute"}'::jsonb),

('IC_008', 'brain_training_duration', 'Brain Training Duration', 'Duration of ONE brain training session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_BRAIN_TRAINING_START", "end_time": "DEF_BRAIN_TRAINING_END"}, "output_unit": "minute"}'::jsonb),

('IC_009', 'journaling_duration', 'Journaling Duration', 'Duration of ONE journaling session', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_JOURNALING_START", "end_time": "DEF_JOURNALING_END"}, "output_unit": "minute"}'::jsonb),

('IC_010', 'sleep_session_duration', 'Sleep Session Duration', 'Duration of ONE complete sleep session (bed to wake)', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_SLEEP_SESSION_START", "end_time": "DEF_SLEEP_SESSION_END"}, "output_unit": "minute"}'::jsonb);


-- =====================================================
-- PART 3: Sleep Period Durations (Individual Periods)
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_020', 'rem_sleep_period_duration', 'REM Sleep Period Duration', 'Duration of ONE REM sleep period', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_SLEEP_PERIOD_START", "end_time": "DEF_SLEEP_PERIOD_END"}, "filter": {"type": "rem"}, "output_unit": "minute"}'::jsonb),

('IC_021', 'deep_sleep_period_duration', 'Deep Sleep Period Duration', 'Duration of ONE deep sleep period', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_SLEEP_PERIOD_START", "end_time": "DEF_SLEEP_PERIOD_END"}, "filter": {"type": "deep"}, "output_unit": "minute"}'::jsonb),

('IC_022', 'core_sleep_period_duration', 'Core Sleep Period Duration', 'Duration of ONE core/light sleep period', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_SLEEP_PERIOD_START", "end_time": "DEF_SLEEP_PERIOD_END"}, "filter": {"type": "core"}, "output_unit": "minute"}'::jsonb),

('IC_023', 'awake_period_duration', 'Awake Period Duration', 'Duration of ONE awake period during sleep', 'time_difference', 'end_time - start_time', 'minute', true, true,
  '{"parameters": {"start_time": "DEF_SLEEP_PERIOD_START", "end_time": "DEF_SLEEP_PERIOD_END"}, "filter": {"type": "awake"}, "output_unit": "minute"}'::jsonb);


-- =====================================================
-- PART 4: Cross-Field Biometric Calculations
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_030', 'bmi_calculated', 'BMI (Calculated)', 'Body Mass Index from ONE weight/height measurement', 'custom_calc', 'weight_kg / (height_m ^ 2)', 'decimal', true, true,
  '{"parameters": {"weight": "DEF_WEIGHT", "height": "DEF_HEIGHT"}, "formula": "weight / (height * height)", "output_unit": "kg/m²"}'::jsonb),

('IC_031', 'waist_to_hip_ratio', 'Waist-to-Hip Ratio', 'WHR from ONE waist/hip measurement', 'divide', 'waist / hip', 'decimal', true, true,
  '{"parameters": {"numerator": "DEF_WAIST", "denominator": "DEF_HIP"}, "output_unit": "ratio"}'::jsonb),

('IC_032', 'waist_to_height_ratio', 'Waist-to-Height Ratio', 'WHtR from ONE waist/height measurement', 'divide', 'waist / height', 'decimal', true, true,
  '{"parameters": {"numerator": "DEF_WAIST", "denominator": "DEF_HEIGHT"}, "output_unit": "ratio"}'::jsonb),

('IC_033', 'body_fat_mass', 'Body Fat Mass', 'Fat mass from ONE weight/bodyfat measurement', 'custom_calc', 'weight * (body_fat_pct / 100)', 'kilogram', true, true,
  '{"parameters": {"weight": "DEF_WEIGHT", "body_fat_pct": "DEF_BODY_FAT_PCT"}, "formula": "weight * (body_fat_pct / 100)", "output_unit": "kg"}'::jsonb),

('IC_034', 'lean_body_mass', 'Lean Body Mass', 'Lean mass from ONE weight/bodyfat measurement', 'custom_calc', 'weight * (1 - body_fat_pct / 100)', 'kilogram', true, true,
  '{"parameters": {"weight": "DEF_WEIGHT", "body_fat_pct": "DEF_BODY_FAT_PCT"}, "formula": "weight * (1 - body_fat_pct / 100)", "output_unit": "kg"}'::jsonb);


-- =====================================================
-- PART 5: Meal-Related Temporal Calculations
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_040', 'post_meal_to_exercise_window', 'Post-Meal Exercise Window', 'Time from THIS meal to NEXT exercise', 'time_difference', 'exercise_start - meal_time', 'minute', true, true,
  '{"parameters": {"meal_time": "DEF_MEAL_TIME", "exercise_start": ["DEF_CARDIO_START", "DEF_STRENGTH_START", "DEF_HIIT_START", "DEF_MOBILITY_START"]}, "aggregation": "min", "output_unit": "minute"}'::jsonb),

('IC_041', 'post_meal_to_snack_window', 'Post-Meal Snack Window', 'Time from THIS meal to NEXT small meal', 'time_difference', 'next_meal_time - meal_time', 'minute', false, true,
  '{"parameters": {"meal_time": "DEF_MEAL_TIME", "next_meal_time": "DEF_MEAL_TIME", "meal_size": "DEF_MEAL_SIZE"}, "filter": {"size": "small"}, "output_unit": "minute"}'::jsonb),

('IC_042', 'pre_workout_meal_window', 'Pre-Workout Meal Window', 'Time from LAST meal to THIS workout', 'time_difference', 'workout_start - meal_time', 'minute', true, true,
  '{"parameters": {"meal_time": "DEF_MEAL_TIME", "workout_start": ["DEF_CARDIO_START", "DEF_STRENGTH_START", "DEF_HIIT_START"]}, "aggregation": "last", "output_unit": "minute"}'::jsonb),

('IC_043', 'last_meal_to_sleep_gap', 'Last Meal to Sleep Gap', 'Time from LAST meal to THIS sleep session', 'time_difference', 'sleep_start - meal_time', 'hours', true, true,
  '{"parameters": {"meal_time": "DEF_MEAL_TIME", "sleep_start": "DEF_SLEEP_SESSION_START"}, "aggregation": "last", "output_unit": "hours"}'::jsonb),

('IC_044', 'first_meal_after_wake_delay', 'First Meal After Wake', 'Time from wake to FIRST meal', 'time_difference', 'meal_time - wake_time', 'minute', true, true,
  '{"parameters": {"wake_time": "DEF_SLEEP_SESSION_END", "meal_time": "DEF_MEAL_TIME"}, "aggregation": "first", "output_unit": "minute"}'::jsonb),

('IC_045', 'eating_window_duration', 'Eating Window Duration', 'Time from FIRST meal to LAST meal of day', 'time_difference', 'last_meal_time - first_meal_time', 'hours', true, true,
  '{"parameters": {"first_meal_time": "DEF_MEAL_TIME", "last_meal_time": "DEF_MEAL_TIME"}, "window": "same_day", "output_unit": "hours"}'::jsonb);


-- =====================================================
-- PART 6: Substance-Related Temporal Calculations
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_050', 'caffeine_to_sleep_window', 'Caffeine to Sleep Window', 'Time from LAST caffeine to THIS sleep (CRITICAL)', 'time_difference', 'sleep_start - caffeine_time', 'hours', true, true,
  '{"parameters": {"caffeine_time": "DEF_CAFFEINE_TIME", "sleep_start": "DEF_SLEEP_SESSION_START"}, "aggregation": "last", "alert_threshold": 6, "alert_message": "Caffeine within 6 hours of sleep may impact quality", "output_unit": "hours"}'::jsonb),

('IC_051', 'alcohol_to_sleep_window', 'Alcohol to Sleep Window', 'Time from LAST alcohol to THIS sleep', 'time_difference', 'sleep_start - alcohol_time', 'hours', true, true,
  '{"parameters": {"alcohol_time": "DEF_ALCOHOL_TIME", "sleep_start": "DEF_SLEEP_SESSION_START"}, "aggregation": "last", "alert_threshold": 3, "alert_message": "Alcohol within 3 hours may disrupt sleep architecture", "output_unit": "hours"}'::jsonb);


-- =====================================================
-- PART 7: Exercise-Related Temporal Calculations
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_060', 'exercise_to_sleep_window', 'Exercise to Sleep Window', 'Time from LAST exercise to THIS sleep', 'time_difference', 'sleep_start - exercise_end', 'hours', true, true,
  '{"parameters": {"exercise_end": ["DEF_CARDIO_END", "DEF_STRENGTH_END", "DEF_HIIT_END"], "sleep_start": "DEF_SLEEP_SESSION_START"}, "aggregation": "last", "output_unit": "hours"}'::jsonb),

('IC_061', 'post_exercise_meal_window', 'Post-Exercise Meal Window', 'Time from THIS workout to NEXT meal', 'time_difference', 'meal_time - exercise_end', 'minute', true, true,
  '{"parameters": {"exercise_end": ["DEF_CARDIO_END", "DEF_STRENGTH_END", "DEF_HIIT_END"], "meal_time": "DEF_MEAL_TIME"}, "aggregation": "first", "output_unit": "minute"}'::jsonb);


-- =====================================================
-- PART 8: Sleep Quality Calculations (Per Session)
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_110', 'sleep_efficiency', 'Sleep Efficiency', '% of time in bed actually sleeping in THIS session', 'divide', 'total_sleep / time_in_bed * 100', 'percent', true, true,
  '{"parameters": {"total_sleep": "IC_111", "time_in_bed": "IC_010"}, "formula": "(total_sleep / time_in_bed) * 100", "output_unit": "percent"}'::jsonb),

('IC_111', 'total_sleep_duration', 'Total Sleep Duration', 'Total sleep time in THIS session (excludes awake)', 'sum', 'IC_020 + IC_021 + IC_022', 'minute', true, true,
  '{"parameters": {"rem": "IC_020", "deep": "IC_021", "core": "IC_022"}, "formula": "sum(rem, deep, core)", "output_unit": "minute"}'::jsonb),

('IC_112', 'total_awake_duration', 'Total Awake Duration', 'Total awake time in THIS session', 'sum', 'sum(IC_023)', 'minute', true, true,
  '{"parameters": {"awake_periods": "IC_023"}, "formula": "sum(awake_periods)", "output_unit": "minute"}'::jsonb),

('IC_113', 'rem_percentage', 'REM Percentage', '% REM in THIS session', 'divide', 'IC_020 / IC_111 * 100', 'percent', true, true,
  '{"parameters": {"rem_duration": "IC_020", "total_sleep": "IC_111"}, "formula": "(rem_duration / total_sleep) * 100", "output_unit": "percent"}'::jsonb),

('IC_114', 'deep_percentage', 'Deep Sleep Percentage', '% deep sleep in THIS session', 'divide', 'IC_021 / IC_111 * 100', 'percent', true, true,
  '{"parameters": {"deep_duration": "IC_021", "total_sleep": "IC_111"}, "formula": "(deep_duration / total_sleep) * 100", "output_unit": "percent"}'::jsonb),

('IC_115', 'core_percentage', 'Core Sleep Percentage', '% core sleep in THIS session', 'divide', 'IC_022 / IC_111 * 100', 'percent', true, true,
  '{"parameters": {"core_duration": "IC_022", "total_sleep": "IC_111"}, "formula": "(core_duration / total_sleep) * 100", "output_unit": "percent"}'::jsonb);


-- =====================================================
-- PART 9: Boolean/Status Calculations
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_120', 'post_meal_exercise_occurred', 'Post-Meal Exercise Occurred', 'Did exercise happen within 2h after THIS meal?', 'custom_calc', 'IC_040 <= 120', 'decimal', false, true,
  '{"parameters": {"post_meal_window": "IC_040"}, "formula": "post_meal_window <= 120", "threshold": 120, "output_unit": "boolean"}'::jsonb),

('IC_121', 'caffeine_cutoff_met', 'Caffeine Cutoff Met', 'Was last caffeine >6h before THIS sleep?', 'custom_calc', 'IC_050 >= 6', 'decimal', true, true,
  '{"parameters": {"caffeine_window": "IC_050"}, "formula": "caffeine_window >= 6", "threshold": 6, "output_unit": "boolean"}'::jsonb),

('IC_122', 'alcohol_cutoff_met', 'Alcohol Cutoff Met', 'Was last alcohol >3h before THIS sleep?', 'custom_calc', 'IC_051 >= 3', 'decimal', true, true,
  '{"parameters": {"alcohol_window": "IC_051"}, "formula": "alcohol_window >= 3", "threshold": 3, "output_unit": "boolean"}'::jsonb),

('IC_123', 'breakfast_within_hour', 'Breakfast Within Hour', 'Was first meal within 1h of wake?', 'custom_calc', 'IC_044 <= 60', 'decimal', true, true,
  '{"parameters": {"first_meal_delay": "IC_044"}, "formula": "first_meal_delay <= 60", "threshold": 60, "output_unit": "boolean"}'::jsonb),

('IC_124', 'eating_window_under_12h', 'Eating Window Under 12h', 'Was eating window <12h THIS day?', 'custom_calc', 'IC_045 < 12', 'decimal', true, true,
  '{"parameters": {"eating_window": "IC_045"}, "formula": "eating_window < 12", "threshold": 12, "output_unit": "boolean"}'::jsonb);


-- =====================================================
-- PART 10: Compliance & Screening
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, formula_definition, unit_id, is_displayed_to_user, is_active, calculation_config) VALUES
('IC_090', 'time_since_screening', 'Time Since Screening', 'Days since THIS screening', 'time_difference', 'current_date - screening_date', 'day', false, true,
  '{"parameters": {"screening_date": "DEF_SCREENING_DATE"}, "output_unit": "days"}'::jsonb),

('IC_092', 'user_age', 'User Age', 'Patient current age in years', 'time_difference', 'current_date - date_of_birth', 'years', false, true,
  '{"parameters": {"date_of_birth": "DEF_DATE_OF_BIRTH"}, "output_unit": "years"}'::jsonb);


DO $$
DECLARE
  calc_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO calc_count FROM instance_calculations;

  RAISE NOTICE '=========================================';
  RAISE NOTICE 'Instance Calculations Rebuilt';
  RAISE NOTICE '=========================================';
  RAISE NOTICE 'Created % instance calculations', calc_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Categories:';
  RAISE NOTICE '  - Duration calculations (sessions): 10';
  RAISE NOTICE '  - Sleep period durations: 4';
  RAISE NOTICE '  - Biometric calculations: 5';
  RAISE NOTICE '  - Meal timing: 6';
  RAISE NOTICE '  - Substance timing: 2';
  RAISE NOTICE '  - Exercise timing: 2';
  RAISE NOTICE '  - Sleep quality (per session): 6';
  RAISE NOTICE '  - Boolean/status checks: 5';
  RAISE NOTICE '  - Compliance/screening: 2';
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Create dependencies in part 2';
END $$;

COMMIT;
