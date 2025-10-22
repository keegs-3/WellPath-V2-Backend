-- =====================================================
-- Populate event_types_data_entry_fields Junction Table
-- =====================================================
-- Links consolidated event types to their data_entry_fields
-- Based on the event_type_id column in data_entry_fields
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Clear existing mappings for consolidated events
-- =====================================================
-- Keep health_screening and therapeutic_intake as they're already correct

DELETE FROM event_types_data_entry_fields
WHERE event_type_id IN (
  'cardio_event',
  'flexibility_event',
  'meal_event',
  'measurement_event',
  'mindfulness_event',
  'screening_event',
  'sleep_event',
  'strength_event',
  'substance_event'
);


-- =====================================================
-- Populate from data_entry_fields.event_type_id
-- =====================================================
-- Auto-populate junction table based on event_type_id links

INSERT INTO event_types_data_entry_fields (event_type_id, data_entry_field_id, is_required, display_order)
SELECT
  def.event_type_id,
  def.field_id,
  -- Mark timestamp and type fields as required
  CASE
    WHEN def.field_type IN ('timestamp', 'reference') AND def.field_name LIKE '%type%' THEN true
    WHEN def.field_name IN ('meal_time', 'measurement_time', 'substance_time') THEN true
    ELSE false
  END as is_required,
  -- Order: timestamps first, then type fields, then other fields
  CASE
    WHEN def.field_name LIKE '%start%' THEN 1
    WHEN def.field_name LIKE '%time' AND def.field_name NOT LIKE '%end%' THEN 2
    WHEN def.field_name LIKE '%type%' THEN 3
    WHEN def.field_name LIKE '%end%' THEN 10
    ELSE 5
  END as display_order
FROM data_entry_fields def
WHERE def.is_active = true
AND def.event_type_id IN (
  'cardio_event',
  'flexibility_event',
  'meal_event',
  'measurement_event',
  'mindfulness_event',
  'screening_event',
  'sleep_event',
  'strength_event',
  'substance_event'
)
ORDER BY def.event_type_id, display_order, def.field_name;


-- =====================================================
-- Verify field counts per event type
-- =====================================================

DO $$
DECLARE
  event_rec RECORD;
  expected_counts JSONB := '{
    "cardio_event": 5,
    "flexibility_event": 4,
    "meal_event": 8,
    "measurement_event": 4,
    "mindfulness_event": 5,
    "screening_event": 4,
    "sleep_event": 7,
    "strength_event": 5,
    "substance_event": 4
  }'::JSONB;
  actual_count INT;
  expected_count INT;
BEGIN
  FOR event_rec IN
    SELECT DISTINCT event_type_id
    FROM event_types
    WHERE event_type_id IN (
      'cardio_event', 'flexibility_event', 'meal_event',
      'measurement_event', 'mindfulness_event', 'screening_event',
      'sleep_event', 'strength_event', 'substance_event'
    )
  LOOP
    -- Get actual count
    SELECT COUNT(*) INTO actual_count
    FROM event_types_data_entry_fields
    WHERE event_type_id = event_rec.event_type_id;

    -- Get expected count
    expected_count := (expected_counts->>event_rec.event_type_id)::INT;

    -- Raise notice if mismatch
    IF actual_count != expected_count THEN
      RAISE NOTICE 'Field count mismatch for %: expected %, got %',
        event_rec.event_type_id, expected_count, actual_count;
    END IF;
  END LOOP;

  RAISE NOTICE 'Event type field mapping verification complete';
END $$;


COMMIT;
