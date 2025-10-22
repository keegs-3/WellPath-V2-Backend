-- =====================================================
-- Add Session Count Fields to Field Registry
-- =====================================================
-- Register all session count fields so they can be
-- written to patient_data_entries
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

INSERT INTO field_registry (
    field_id,
    field_name,
    display_name,
    description,
    data_entry_field_id,
    instance_calculation_id,
    field_source,
    unit,
    is_active
)
VALUES
-- Exercise session counts
('DEF_CARDIO_SESSION_COUNT', 'cardio_session_count', 'Cardio Session Count', 'Auto-calculated count of cardio sessions', 'DEF_CARDIO_SESSION_COUNT', 'CALC_CARDIO_SESSION_COUNT', 'calculated', 'count', true),
('DEF_STRENGTH_SESSION_COUNT', 'strength_session_count', 'Strength Session Count', 'Auto-calculated count of strength sessions', 'DEF_STRENGTH_SESSION_COUNT', 'CALC_STRENGTH_SESSION_COUNT', 'calculated', 'count', true),
('DEF_HIIT_SESSION_COUNT', 'hiit_session_count', 'HIIT Session Count', 'Auto-calculated count of HIIT sessions', 'DEF_HIIT_SESSION_COUNT', 'CALC_HIIT_SESSION_COUNT', 'calculated', 'count', true),
('DEF_MOBILITY_SESSION_COUNT', 'mobility_session_count', 'Mobility Session Count', 'Auto-calculated count of mobility sessions', 'DEF_MOBILITY_SESSION_COUNT', 'CALC_MOBILITY_SESSION_COUNT', 'calculated', 'count', true),
('DEF_FLEXIBILITY_SESSION_COUNT', 'flexibility_session_count', 'Flexibility Session Count', 'Auto-calculated count of flexibility sessions', 'DEF_FLEXIBILITY_SESSION_COUNT', 'CALC_FLEXIBILITY_SESSION_COUNT', 'calculated', 'count', true),

-- Sleep session counts
('DEF_SLEEP_SESSION_COUNT', 'sleep_session_count', 'Sleep Session Count', 'Auto-calculated count of sleep sessions', 'DEF_SLEEP_SESSION_COUNT', 'CALC_SLEEP_SESSION_COUNT', 'calculated', 'count', true),
('DEF_SLEEP_PERIOD_COUNT', 'sleep_period_count', 'Sleep Period Count', 'Auto-calculated count of individual sleep periods', 'DEF_SLEEP_PERIOD_COUNT', 'CALC_SLEEP_PERIOD_COUNT', 'calculated', 'count', true),

-- Mental wellness session counts
('DEF_MINDFULNESS_SESSION_COUNT', 'mindfulness_session_count', 'Mindfulness Session Count', 'Auto-calculated count of mindfulness sessions', 'DEF_MINDFULNESS_SESSION_COUNT', 'CALC_MINDFULNESS_SESSION_COUNT', 'calculated', 'count', true),
('DEF_JOURNALING_SESSION_COUNT', 'journaling_session_count', 'Journaling Session Count', 'Auto-calculated count of journaling sessions', 'DEF_JOURNALING_SESSION_COUNT', 'CALC_JOURNALING_SESSION_COUNT', 'calculated', 'count', true),
('DEF_BRAIN_TRAINING_SESSION_COUNT', 'brain_training_session_count', 'Brain Training Session Count', 'Auto-calculated count of brain training sessions', 'DEF_BRAIN_TRAINING_SESSION_COUNT', 'CALC_BRAIN_TRAINING_SESSION_COUNT', 'calculated', 'count', true),

-- Other session counts
('DEF_OUTDOOR_SESSION_COUNT', 'outdoor_session_count', 'Outdoor Session Count', 'Auto-calculated count of outdoor activity sessions', 'DEF_OUTDOOR_SESSION_COUNT', 'CALC_OUTDOOR_SESSION_COUNT', 'calculated', 'count', true),
('DEF_SUNLIGHT_SESSION_COUNT', 'sunlight_session_count', 'Sunlight Session Count', 'Auto-calculated count of sunlight exposure sessions', 'DEF_SUNLIGHT_SESSION_COUNT', 'CALC_SUNLIGHT_SESSION_COUNT', 'calculated', 'count', true)

ON CONFLICT (field_id) DO UPDATE SET
    field_name = EXCLUDED.field_name,
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    data_entry_field_id = EXCLUDED.data_entry_field_id,
    instance_calculation_id = EXCLUDED.instance_calculation_id,
    field_source = EXCLUDED.field_source,
    unit = EXCLUDED.unit,
    is_active = EXCLUDED.is_active;

DO $$
DECLARE
  registry_count INT;
BEGIN
  SELECT COUNT(*) INTO registry_count
  FROM field_registry
  WHERE field_id LIKE '%_SESSION_COUNT' OR field_id LIKE '%_PERIOD_COUNT';

  RAISE NOTICE '✅ Session Count Fields Added to Registry';
  RAISE NOTICE '';
  RAISE NOTICE 'Total in registry: %', registry_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Now session counts can be written to patient_data_entries!';
END $$;

COMMIT;
