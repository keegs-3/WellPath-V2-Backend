-- =====================================================
-- Link Session Count Calculations to Event Types
-- =====================================================
-- Add session count calculations to event_types_dependencies
-- so they run automatically when events are created
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, display_order)
VALUES
-- Exercise types
('EVT_CARDIO', 'CALC_CARDIO_SESSION_COUNT', 'calculation', 2),
('EVT_STRENGTH', 'CALC_STRENGTH_SESSION_COUNT', 'calculation', 2),
('EVT_HIIT', 'CALC_HIIT_SESSION_COUNT', 'calculation', 2),
('EVT_MOBILITY', 'CALC_MOBILITY_SESSION_COUNT', 'calculation', 2),
('EVT_FLEXIBILITY', 'CALC_FLEXIBILITY_SESSION_COUNT', 'calculation', 2),

-- Sleep types (sleep periods are part of EVT_SLEEP, so we only count main sessions)
('EVT_SLEEP', 'CALC_SLEEP_SESSION_COUNT', 'calculation', 2),

-- Mental wellness types
('EVT_MINDFULNESS', 'CALC_MINDFULNESS_SESSION_COUNT', 'calculation', 2),
('EVT_JOURNALING', 'CALC_JOURNALING_SESSION_COUNT', 'calculation', 2),
('EVT_BRAIN_TRAINING', 'CALC_BRAIN_TRAINING_SESSION_COUNT', 'calculation', 2),

-- Other types
('EVT_OUTDOOR', 'CALC_OUTDOOR_SESSION_COUNT', 'calculation', 2),
('EVT_SUNLIGHT', 'CALC_SUNLIGHT_SESSION_COUNT', 'calculation', 2)

ON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO NOTHING;

DO $$
DECLARE
  link_count INT;
BEGIN
  SELECT COUNT(*) INTO link_count
  FROM event_types_dependencies
  WHERE instance_calculation_id LIKE '%_SESSION_COUNT' OR instance_calculation_id LIKE '%_PERIOD_COUNT';

  RAISE NOTICE '✅ Session Count Calculations Linked to Event Types';
  RAISE NOTICE '';
  RAISE NOTICE 'Total links: %', link_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Now when an event is created, its session count will auto-calculate!';
END $$;

COMMIT;
