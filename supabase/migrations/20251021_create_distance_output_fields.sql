-- =====================================================
-- Create Distance Output Fields
-- =====================================================
-- Output fields for distance conversions
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, supports_healthkit_sync)
VALUES
('DEF_CARDIO_DISTANCE_KM', 'cardio_distance_km', 'Distance (km)', 'Cardio distance in kilometers (calculated)', 'quantity', 'numeric', 'kilometer', true, false),
('DEF_CARDIO_DISTANCE_MILES', 'cardio_distance_miles', 'Distance (miles)', 'Cardio distance in miles (calculated)', 'quantity', 'numeric', 'mile', true, false)
ON CONFLICT (field_id) DO NOTHING;

DO $$
BEGIN
  RAISE NOTICE '✅ Distance output fields created';
END $$;

COMMIT;
