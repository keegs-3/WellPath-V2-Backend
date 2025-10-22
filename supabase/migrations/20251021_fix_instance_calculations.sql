-- =====================================================
-- Fix Instance Calculations - Correct Approach
-- =====================================================
-- Create instance calculations for:
-- 1. Duration for EVERY event type with start/end times
-- 2. Time since last screening for each screening type
-- 3. Body composition calculations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Clear All Existing Instance Calculations
-- =====================================================

TRUNCATE TABLE instance_calculations CASCADE;


-- =====================================================
-- 2. Event Duration Calculations (One Per Event Type)
-- =====================================================

-- Cardio Duration
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_001', 'cardio_duration', 'Cardio Duration',
  'Duration of cardio exercise session',
  'time_difference', 'cardio_end_time - cardio_start_time',
  ARRAY['cardio_start_time', 'cardio_end_time'],
  'minute', true, true
);

-- Strength Duration
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_002', 'strength_duration', 'Strength Duration',
  'Duration of strength training session',
  'time_difference', 'strength_end_time - strength_start_time',
  ARRAY['strength_start_time', 'strength_end_time'],
  'minute', true, true
);

-- Flexibility Duration
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_003', 'flexibility_duration', 'Flexibility Duration',
  'Duration of flexibility/mobility session',
  'time_difference', 'flexibility_end_time - flexibility_start_time',
  ARRAY['flexibility_start_time', 'flexibility_end_time'],
  'minute', true, true
);

-- Mindfulness Duration
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_004', 'mindfulness_duration', 'Mindfulness Duration',
  'Duration of mindfulness session',
  'time_difference', 'mindfulness_end_time - mindfulness_start_time',
  ARRAY['mindfulness_start_time', 'mindfulness_end_time'],
  'minute', true, true
);

-- Sleep Period Duration
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_005', 'sleep_period_duration', 'Sleep Period Duration',
  'Duration of individual sleep period (REM, deep, core, awake)',
  'time_difference', 'sleep_period_end - sleep_period_start',
  ARRAY['sleep_period_start', 'sleep_period_end'],
  'minute', true, true
);

-- Sleep Session Duration
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_006', 'sleep_session_duration', 'Sleep Session Duration',
  'Total duration of sleep session (bedtime to wake)',
  'time_difference', 'sleep_session_end - sleep_session_start',
  ARRAY['sleep_session_start', 'sleep_session_end'],
  'minute', true, true
);


-- =====================================================
-- 3. Screening Time Calculations (One Per Screening Type)
-- =====================================================

-- Time Since Colonoscopy
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_010', 'time_since_colonoscopy', 'Time Since Colonoscopy',
  'Days since last colonoscopy screening',
  'time_difference', 'NOW() - screening_date WHERE screening_type = colonoscopy',
  ARRAY['screening_date', 'screening_type_id'],
  'day', true, true
);

-- Time Since Mammogram
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_011', 'time_since_mammogram', 'Time Since Mammogram',
  'Days since last mammogram screening',
  'time_difference', 'NOW() - screening_date WHERE screening_type = mammogram',
  ARRAY['screening_date', 'screening_type_id'],
  'day', true, true
);

-- Time Since Physical Exam
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_012', 'time_since_physical', 'Time Since Physical Exam',
  'Days since last physical exam',
  'time_difference', 'NOW() - screening_date WHERE screening_type = physical',
  ARRAY['screening_date', 'screening_type_id'],
  'day', true, true
);

-- Time Since Dental Exam
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_013', 'time_since_dental', 'Time Since Dental Exam',
  'Days since last dental exam',
  'time_difference', 'NOW() - screening_date WHERE screening_type = dental',
  ARRAY['screening_date', 'screening_type_id'],
  'day', true, true
);

-- Time Since Skin Check
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_014', 'time_since_skin_check', 'Time Since Skin Check',
  'Days since last skin check',
  'time_difference', 'NOW() - screening_date WHERE screening_type = skin_check',
  ARRAY['screening_date', 'screening_type_id'],
  'day', true, true
);

-- Time Since Vision Check
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_015', 'time_since_vision_check', 'Time Since Vision Check',
  'Days since last vision check',
  'time_difference', 'NOW() - screening_date WHERE screening_type = vision',
  ARRAY['screening_date', 'screening_type_id'],
  'day', true, true
);

-- Time Since PSA Test
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_016', 'time_since_psa', 'Time Since PSA Test',
  'Days since last PSA test',
  'time_difference', 'NOW() - screening_date WHERE screening_type = psa',
  ARRAY['screening_date', 'screening_type_id'],
  'day', true, true
);


-- =====================================================
-- 4. Body Composition Calculations
-- =====================================================

-- BMI
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_020', 'bmi_calculated', 'BMI',
  'Body Mass Index calculated from weight and height',
  'custom_calc', 'weight_kg / (height_m * height_m)',
  ARRAY['weight', 'height'],
  'count', true, true
);

-- Hip to Waist Ratio
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_021', 'hip_to_waist_ratio', 'Hip-to-Waist Ratio',
  'Ratio of hip circumference to waist circumference',
  'divide', 'hip / waist',
  ARRAY['hip', 'waist'],
  'ratio', true, true
);

-- Waist to Height Ratio
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_022', 'waist_to_height_ratio', 'Waist-to-Height Ratio',
  'Waist circumference divided by height (health risk indicator)',
  'divide', 'waist / height',
  ARRAY['waist', 'height'],
  'ratio', true, true
);

-- Skeletal Muscle Mass
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_023', 'skeletal_muscle_mass', 'Skeletal Muscle Mass',
  'Estimated skeletal muscle mass from lean mass',
  'custom_calc', 'lean_mass * 0.5',
  ARRAY['lean_mass'],
  'kilogram', true, true
);

-- Body Fat Mass
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_024', 'body_fat_mass', 'Body Fat Mass',
  'Total body fat mass calculated from weight and body fat percentage',
  'custom_calc', 'weight * (body_fat_percent / 100)',
  ARRAY['weight', 'body_fat'],
  'kilogram', true, true
);

-- Skeletal Muscle to Fat-Free Mass Ratio
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_025', 'skeletal_muscle_to_ffm_ratio', 'Skeletal Muscle / FFM Ratio',
  'Ratio of skeletal muscle mass to fat-free mass',
  'divide', 'skeletal_muscle_mass / lean_mass',
  ARRAY['skeletal_muscle_mass', 'lean_mass'],
  'percentage', true, true
);


-- =====================================================
-- 5. Other Instance Calculations
-- =====================================================

-- User Age
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(), 'IC_030', 'user_age', 'User Age',
  'Current age calculated from date of birth',
  'time_difference', 'NOW() - date_of_birth',
  ARRAY['date_of_birth'],
  'years', true, true
);


-- =====================================================
-- 6. Summary
-- =====================================================

DO $$
DECLARE
  total_count INT;
BEGIN
  SELECT COUNT(*) INTO total_count
  FROM instance_calculations
  WHERE is_active = true;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Instance Calculations Created: %', total_count;
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Event Durations: 6';
  RAISE NOTICE 'Screening Time Checks: 7';
  RAISE NOTICE 'Body Composition: 6';
  RAISE NOTICE 'Other: 1 (age)';
END $$;

COMMIT;
