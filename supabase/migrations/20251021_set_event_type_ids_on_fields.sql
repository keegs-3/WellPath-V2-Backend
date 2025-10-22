-- =====================================================
-- Set event_type_id on Data Entry Fields
-- =====================================================
-- Link data_entry_fields to their event types so the
-- edge function can find the right calculations to run
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

UPDATE data_entry_fields
SET event_type_id = CASE
    -- Cardio fields
    WHEN field_id LIKE 'DEF_CARDIO%' THEN 'EVT_CARDIO'

    -- Strength fields
    WHEN field_id LIKE 'DEF_STRENGTH%' THEN 'EVT_STRENGTH'

    -- HIIT fields
    WHEN field_id LIKE 'DEF_HIIT%' THEN 'EVT_HIIT'

    -- Mobility fields
    WHEN field_id LIKE 'DEF_MOBILITY%' THEN 'EVT_MOBILITY'

    -- Flexibility fields
    WHEN field_id LIKE 'DEF_FLEXIBILITY%' THEN 'EVT_FLEXIBILITY'

    -- Sleep fields
    WHEN field_id LIKE 'DEF_SLEEP%' THEN 'EVT_SLEEP'

    -- Mindfulness fields
    WHEN field_id LIKE 'DEF_MINDFULNESS%' THEN 'EVT_MINDFULNESS'

    -- Journaling fields
    WHEN field_id LIKE 'DEF_JOURNALING%' THEN 'EVT_JOURNALING'

    -- Brain training fields
    WHEN field_id LIKE 'DEF_BRAIN_TRAINING%' THEN 'EVT_BRAIN_TRAINING'

    -- Outdoor fields
    WHEN field_id LIKE 'DEF_OUTDOOR%' THEN 'EVT_OUTDOOR'

    -- Sunlight fields
    WHEN field_id LIKE 'DEF_SUNLIGHT%' THEN 'EVT_SUNLIGHT'

    ELSE event_type_id
END
WHERE field_id LIKE 'DEF_CARDIO%'
   OR field_id LIKE 'DEF_STRENGTH%'
   OR field_id LIKE 'DEF_HIIT%'
   OR field_id LIKE 'DEF_MOBILITY%'
   OR field_id LIKE 'DEF_FLEXIBILITY%'
   OR field_id LIKE 'DEF_SLEEP%'
   OR field_id LIKE 'DEF_MINDFULNESS%'
   OR field_id LIKE 'DEF_JOURNALING%'
   OR field_id LIKE 'DEF_BRAIN_TRAINING%'
   OR field_id LIKE 'DEF_OUTDOOR%'
   OR field_id LIKE 'DEF_SUNLIGHT%';

DO $$
DECLARE
  updated_count INT;
BEGIN
  GET DIAGNOSTICS updated_count = ROW_COUNT;

  RAISE NOTICE '✅ Set event_type_id on % fields', updated_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Now the edge function will find the right calculations!';
END $$;

COMMIT;
