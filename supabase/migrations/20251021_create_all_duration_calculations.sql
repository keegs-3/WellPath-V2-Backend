-- =====================================================
-- Create ALL Duration Calculations
-- =====================================================
-- Duration calculations for every activity with start/end times
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Duration Calculations
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
-- Sleep
('CALC_SLEEP_DURATION', 'sleep_duration', 'Sleep Duration', 'Calculate sleep duration from bedtime to wake time', 'calculate_duration', 'minute',
 '{"output_field": "DEF_SLEEP_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Sleep Periods
('CALC_SLEEP_PERIOD_DURATION', 'sleep_period_duration', 'Sleep Period Duration', 'Calculate individual sleep period duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_SLEEP_PERIOD_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Cardio
('CALC_CARDIO_DURATION', 'cardio_duration', 'Cardio Duration', 'Calculate cardio exercise duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_CARDIO_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- HIIT
('CALC_HIIT_DURATION', 'hiit_duration', 'HIIT Duration', 'Calculate HIIT workout duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_HIIT_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Strength
('CALC_STRENGTH_DURATION', 'strength_duration', 'Strength Training Duration', 'Calculate strength training duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_STRENGTH_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Mobility
('CALC_MOBILITY_DURATION', 'mobility_duration', 'Mobility Duration', 'Calculate mobility workout duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_MOBILITY_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Mindfulness
('CALC_MINDFULNESS_DURATION', 'mindfulness_duration', 'Mindfulness Duration', 'Calculate mindfulness session duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_MINDFULNESS_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Brain Training
('CALC_BRAIN_TRAINING_DURATION', 'brain_training_duration', 'Brain Training Duration', 'Calculate brain training session duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_BRAIN_TRAINING_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Journaling
('CALC_JOURNALING_DURATION', 'journaling_duration', 'Journaling Duration', 'Calculate journaling session duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_JOURNALING_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Outdoor Time
('CALC_OUTDOOR_DURATION', 'outdoor_duration', 'Outdoor Time Duration', 'Calculate outdoor time duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_OUTDOOR_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb),

-- Sunlight Exposure
('CALC_SUNLIGHT_DURATION', 'sunlight_duration', 'Sunlight Exposure Duration', 'Calculate sunlight exposure duration', 'calculate_duration', 'minute',
 '{"output_field": "DEF_SUNLIGHT_DURATION", "output_source": "auto_calculated", "output_unit": "minute"}'::jsonb)

ON CONFLICT (calc_id) DO NOTHING;


-- =====================================================
-- Dependencies for Duration Calculations
-- =====================================================

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
-- Sleep
('CALC_SLEEP_DURATION', 'DEF_SLEEP_BEDTIME', 'start_time', 'start_time', 1),
('CALC_SLEEP_DURATION', 'DEF_SLEEP_WAKETIME', 'end_time', 'end_time', 2),

-- Sleep Periods
('CALC_SLEEP_PERIOD_DURATION', 'DEF_SLEEP_PERIOD_START', 'start_time', 'start_time', 1),
('CALC_SLEEP_PERIOD_DURATION', 'DEF_SLEEP_PERIOD_END', 'end_time', 'end_time', 2),

-- Cardio
('CALC_CARDIO_DURATION', 'DEF_CARDIO_START', 'start_time', 'start_time', 1),
('CALC_CARDIO_DURATION', 'DEF_CARDIO_END', 'end_time', 'end_time', 2),

-- HIIT
('CALC_HIIT_DURATION', 'DEF_HIIT_START', 'start_time', 'start_time', 1),
('CALC_HIIT_DURATION', 'DEF_HIIT_END', 'end_time', 'end_time', 2),

-- Strength
('CALC_STRENGTH_DURATION', 'DEF_STRENGTH_START', 'start_time', 'start_time', 1),
('CALC_STRENGTH_DURATION', 'DEF_STRENGTH_END', 'end_time', 'end_time', 2),

-- Mobility
('CALC_MOBILITY_DURATION', 'DEF_MOBILITY_START', 'start_time', 'start_time', 1),
('CALC_MOBILITY_DURATION', 'DEF_MOBILITY_END', 'end_time', 'end_time', 2),

-- Mindfulness
('CALC_MINDFULNESS_DURATION', 'DEF_MINDFULNESS_START', 'start_time', 'start_time', 1),
('CALC_MINDFULNESS_DURATION', 'DEF_MINDFULNESS_END', 'end_time', 'end_time', 2),

-- Brain Training
('CALC_BRAIN_TRAINING_DURATION', 'DEF_BRAIN_TRAINING_START', 'start_time', 'start_time', 1),
('CALC_BRAIN_TRAINING_DURATION', 'DEF_BRAIN_TRAINING_END', 'end_time', 'end_time', 2),

-- Journaling
('CALC_JOURNALING_DURATION', 'DEF_JOURNALING_START', 'start_time', 'start_time', 1),
('CALC_JOURNALING_DURATION', 'DEF_JOURNALING_END', 'end_time', 'end_time', 2),

-- Outdoor Time
('CALC_OUTDOOR_DURATION', 'DEF_OUTDOOR_START', 'start_time', 'start_time', 1),
('CALC_OUTDOOR_DURATION', 'DEF_OUTDOOR_END', 'end_time', 'end_time', 2),

-- Sunlight Exposure
('CALC_SUNLIGHT_DURATION', 'DEF_SUNLIGHT_START', 'start_time', 'start_time', 1),
('CALC_SUNLIGHT_DURATION', 'DEF_SUNLIGHT_END', 'end_time', 'end_time', 2)

ON CONFLICT DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  calc_count INT;
  dep_count INT;
BEGIN
  SELECT COUNT(*) INTO calc_count FROM instance_calculations
  WHERE calc_id LIKE 'CALC_%_DURATION';

  SELECT COUNT(*) INTO dep_count FROM instance_calculations_dependencies
  WHERE instance_calculation_id LIKE 'CALC_%_DURATION';

  RAISE NOTICE '✅ Created duration calculations';
  RAISE NOTICE 'Duration calculations: %', calc_count;
  RAISE NOTICE 'Duration dependencies: %', dep_count;
END $$;

COMMIT;
