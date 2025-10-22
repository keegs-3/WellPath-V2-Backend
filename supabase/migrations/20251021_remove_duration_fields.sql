-- =====================================================
-- Remove Incorrectly Created Duration Fields
-- =====================================================
-- Duration is calculated, not a data entry field
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

DELETE FROM data_entry_fields
WHERE field_id IN (
  'DEF_SLEEP_DURATION',
  'DEF_SLEEP_PERIOD_DURATION',
  'DEF_CARDIO_DURATION',
  'DEF_HIIT_DURATION',
  'DEF_STRENGTH_DURATION',
  'DEF_MOBILITY_DURATION',
  'DEF_MINDFULNESS_DURATION',
  'DEF_BRAIN_TRAINING_DURATION',
  'DEF_JOURNALING_DURATION',
  'DEF_OUTDOOR_DURATION',
  'DEF_SUNLIGHT_DURATION'
);

DO $$
BEGIN
  RAISE NOTICE '✅ Removed duration fields from data_entry_fields';
  RAISE NOTICE 'Duration values are calculated, not entered';
END $$;

COMMIT;
