-- =====================================================
-- Create Duration Output Fields
-- =====================================================
-- Output fields for all calculated durations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, supports_healthkit_sync)
VALUES
('DEF_SLEEP_DURATION', 'sleep_duration', 'Sleep Duration', 'Total sleep duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_SLEEP_PERIOD_DURATION', 'sleep_period_duration', 'Sleep Period Duration', 'Individual sleep period duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_CARDIO_DURATION', 'cardio_duration', 'Cardio Duration', 'Cardio workout duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_HIIT_DURATION', 'hiit_duration', 'HIIT Duration', 'HIIT workout duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_STRENGTH_DURATION', 'strength_duration', 'Strength Duration', 'Strength training duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_MOBILITY_DURATION', 'mobility_duration', 'Mobility Duration', 'Mobility workout duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_MINDFULNESS_DURATION', 'mindfulness_duration', 'Mindfulness Duration', 'Mindfulness session duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_BRAIN_TRAINING_DURATION', 'brain_training_duration', 'Brain Training Duration', 'Brain training session duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_JOURNALING_DURATION', 'journaling_duration', 'Journaling Duration', 'Journaling session duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_OUTDOOR_DURATION', 'outdoor_duration', 'Outdoor Duration', 'Outdoor time duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false),
('DEF_SUNLIGHT_DURATION', 'sunlight_duration', 'Sunlight Duration', 'Sunlight exposure duration in minutes (calculated)', 'quantity', 'numeric', 'minute', true, false)
ON CONFLICT (field_id) DO NOTHING;

DO $$
DECLARE
  new_fields_count INT;
BEGIN
  SELECT COUNT(*) INTO new_fields_count
  FROM data_entry_fields
  WHERE field_id LIKE 'DEF_%_DURATION';

  RAISE NOTICE '✅ Duration output fields created';
  RAISE NOTICE 'Total duration fields: %', new_fields_count;
END $$;

COMMIT;
