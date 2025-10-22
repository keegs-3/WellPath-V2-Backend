-- =====================================================
-- Create Session Count Instance Calculations
-- =====================================================
-- For every event type with start/end times, create a
-- session count calculation that outputs 1 per event.
-- Aggregations can then SUM these to get total sessions.
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Session Count Fields
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, validation_type, validation_config)
VALUES
-- Exercise session counts
('DEF_CARDIO_SESSION_COUNT', 'cardio_session_count', 'Session Count', 'Count of cardio sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_STRENGTH_SESSION_COUNT', 'strength_session_count', 'Session Count', 'Count of strength sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_HIIT_SESSION_COUNT', 'hiit_session_count', 'Session Count', 'Count of HIIT sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_MOBILITY_SESSION_COUNT', 'mobility_session_count', 'Session Count', 'Count of mobility sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_FLEXIBILITY_SESSION_COUNT', 'flexibility_session_count', 'Session Count', 'Count of flexibility sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),

-- Sleep session counts
('DEF_SLEEP_SESSION_COUNT', 'sleep_session_count', 'Session Count', 'Count of sleep sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_SLEEP_PERIOD_COUNT', 'sleep_period_count', 'Period Count', 'Count of individual sleep periods', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),

-- Mental wellness session counts
('DEF_MINDFULNESS_SESSION_COUNT', 'mindfulness_session_count', 'Session Count', 'Count of mindfulness sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_JOURNALING_SESSION_COUNT', 'journaling_session_count', 'Session Count', 'Count of journaling sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_BRAIN_TRAINING_SESSION_COUNT', 'brain_training_session_count', 'Session Count', 'Count of brain training sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),

-- Other session counts
('DEF_OUTDOOR_SESSION_COUNT', 'outdoor_session_count', 'Session Count', 'Count of outdoor activity sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb),
('DEF_SUNLIGHT_SESSION_COUNT', 'sunlight_session_count', 'Session Count', 'Count of sunlight exposure sessions', 'quantity', 'integer', 'count', 'numeric', '{"min": 1, "max": 1}'::jsonb)

ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  field_type = EXCLUDED.field_type,
  data_type = EXCLUDED.data_type,
  unit = EXCLUDED.unit,
  validation_type = EXCLUDED.validation_type,
  validation_config = EXCLUDED.validation_config;


-- =====================================================
-- PART 2: Create Instance Calculations
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, calculation_config, unit_id, is_active)
VALUES
-- Exercise session counts
('CALC_CARDIO_SESSION_COUNT', 'cardio_session_count', 'Session Count', 'Count cardio sessions (1 per event)',
 'constant', '{"output_field": "DEF_CARDIO_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_STRENGTH_SESSION_COUNT', 'strength_session_count', 'Session Count', 'Count strength sessions (1 per event)',
 'constant', '{"output_field": "DEF_STRENGTH_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_HIIT_SESSION_COUNT', 'hiit_session_count', 'Session Count', 'Count HIIT sessions (1 per event)',
 'constant', '{"output_field": "DEF_HIIT_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_MOBILITY_SESSION_COUNT', 'mobility_session_count', 'Session Count', 'Count mobility sessions (1 per event)',
 'constant', '{"output_field": "DEF_MOBILITY_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_FLEXIBILITY_SESSION_COUNT', 'flexibility_session_count', 'Session Count', 'Count flexibility sessions (1 per event)',
 'constant', '{"output_field": "DEF_FLEXIBILITY_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

-- Sleep session counts
('CALC_SLEEP_SESSION_COUNT', 'sleep_session_count', 'Session Count', 'Count sleep sessions (1 per event)',
 'constant', '{"output_field": "DEF_SLEEP_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_SLEEP_PERIOD_COUNT', 'sleep_period_count', 'Period Count', 'Count individual sleep periods (1 per period)',
 'constant', '{"output_field": "DEF_SLEEP_PERIOD_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

-- Mental wellness session counts
('CALC_MINDFULNESS_SESSION_COUNT', 'mindfulness_session_count', 'Session Count', 'Count mindfulness sessions (1 per event)',
 'constant', '{"output_field": "DEF_MINDFULNESS_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_JOURNALING_SESSION_COUNT', 'journaling_session_count', 'Session Count', 'Count journaling sessions (1 per event)',
 'constant', '{"output_field": "DEF_JOURNALING_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_BRAIN_TRAINING_SESSION_COUNT', 'brain_training_session_count', 'Session Count', 'Count brain training sessions (1 per event)',
 'constant', '{"output_field": "DEF_BRAIN_TRAINING_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

-- Other session counts
('CALC_OUTDOOR_SESSION_COUNT', 'outdoor_session_count', 'Session Count', 'Count outdoor activity sessions (1 per event)',
 'constant', '{"output_field": "DEF_OUTDOOR_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true),

('CALC_SUNLIGHT_SESSION_COUNT', 'sunlight_session_count', 'Session Count', 'Count sunlight exposure sessions (1 per event)',
 'constant', '{"output_field": "DEF_SUNLIGHT_SESSION_COUNT", "output_unit": "count", "output_source": "auto_calculated", "constant_value": 1}'::jsonb, 'count', true)

ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  calculation_method = EXCLUDED.calculation_method,
  calculation_config = EXCLUDED.calculation_config,
  unit_id = EXCLUDED.unit_id,
  is_active = EXCLUDED.is_active;


-- =====================================================
-- PART 3: Create Dependencies
-- =====================================================

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_order, parameter_role)
VALUES
-- Exercise dependencies
('CALC_CARDIO_SESSION_COUNT', 'DEF_CARDIO_START', 'trigger_field', 1, 'trigger'),
('CALC_STRENGTH_SESSION_COUNT', 'DEF_STRENGTH_START', 'trigger_field', 1, 'trigger'),
('CALC_HIIT_SESSION_COUNT', 'DEF_HIIT_START', 'trigger_field', 1, 'trigger'),
('CALC_MOBILITY_SESSION_COUNT', 'DEF_MOBILITY_START', 'trigger_field', 1, 'trigger'),
('CALC_FLEXIBILITY_SESSION_COUNT', 'DEF_FLEXIBILITY_START', 'trigger_field', 1, 'trigger'),

-- Sleep dependencies
('CALC_SLEEP_SESSION_COUNT', 'DEF_SLEEP_BEDTIME', 'trigger_field', 1, 'trigger'),
('CALC_SLEEP_PERIOD_COUNT', 'DEF_SLEEP_PERIOD_START', 'trigger_field', 1, 'trigger'),

-- Mental wellness dependencies
('CALC_MINDFULNESS_SESSION_COUNT', 'DEF_MINDFULNESS_START', 'trigger_field', 1, 'trigger'),
('CALC_JOURNALING_SESSION_COUNT', 'DEF_JOURNALING_START', 'trigger_field', 1, 'trigger'),
('CALC_BRAIN_TRAINING_SESSION_COUNT', 'DEF_BRAIN_TRAINING_START', 'trigger_field', 1, 'trigger'),

-- Other dependencies
('CALC_OUTDOOR_SESSION_COUNT', 'DEF_OUTDOOR_START', 'trigger_field', 1, 'trigger'),
('CALC_SUNLIGHT_SESSION_COUNT', 'DEF_SUNLIGHT_START', 'trigger_field', 1, 'trigger')

ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  field_count INT;
  calc_count INT;
  dep_count INT;
BEGIN
  SELECT COUNT(*) INTO field_count FROM data_entry_fields WHERE field_id LIKE '%_SESSION_COUNT' OR field_id LIKE '%_PERIOD_COUNT';
  SELECT COUNT(*) INTO calc_count FROM instance_calculations WHERE calc_id LIKE 'CALC_%_SESSION_COUNT' OR calc_id LIKE 'CALC_%_PERIOD_COUNT';
  SELECT COUNT(*) INTO dep_count FROM instance_calculations_dependencies WHERE instance_calculation_id LIKE 'CALC_%_SESSION_COUNT' OR instance_calculation_id LIKE 'CALC_%_PERIOD_COUNT';

  RAISE NOTICE '✅ Session Count Calculations Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Session Count Fields: %', field_count;
  RAISE NOTICE '  Instance Calculations: %', calc_count;
  RAISE NOTICE '  Dependencies: %', dep_count;
  RAISE NOTICE '';
  RAISE NOTICE 'How it works:';
  RAISE NOTICE '  1. User enters start time → trigger fires';
  RAISE NOTICE '  2. Instance calc outputs value of 1';
  RAISE NOTICE '  3. Aggregations SUM these 1s to get total sessions per period';
  RAISE NOTICE '';
  RAISE NOTICE 'Example: 5 cardio sessions this week = 5 × 1 = 5';
END $$;

COMMIT;
