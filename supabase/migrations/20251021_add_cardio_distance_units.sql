-- =====================================================
-- Add Cardio Distance Unit Support
-- =====================================================
-- Adds unit field for cardio distance tracking
-- Leverages existing units_base (miles, kilometers, meters, etc.)
--
-- DEF_CARDIO_DISTANCE already exists, adding unit selection
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Cardio Distance Unit Field
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  is_active,
  healthkit_identifier,
  healthkit_mapping_id,
  supports_healthkit_sync,
  validation_config
) VALUES
-- Cardio distance units (reference to units_base)
(
  'DEF_CARDIO_DISTANCE_UNITS',
  'cardio_distance_units',
  'Distance Units',
  'Unit of measurement for cardio distance (references units_base.unit_id)',
  'reference',
  'text', -- Stores unit_id from units_base (e.g., 'mile', 'kilometer', 'meter')
  NULL,
  true,
  NULL,
  NULL,
  false,
  NULL
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 2: Update Existing Cardio Distance Field
-- =====================================================

UPDATE data_entry_fields
SET
  description = 'Distance covered during cardio activity (unit specified by DEF_CARDIO_DISTANCE_UNITS)',
  supports_healthkit_sync = true,
  healthkit_identifier = 'HKQuantityTypeIdentifierDistanceWalkingRunning',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierDistanceWalkingRunning'),
  validation_config = '{"min": 0, "max": 200, "increment": 0.1}'::jsonb,
  updated_at = NOW()
WHERE field_id = 'DEF_CARDIO_DISTANCE';


-- =====================================================
-- PART 3: Add comments for clarity
-- =====================================================

COMMENT ON COLUMN data_entry_fields.healthkit_identifier IS
'HKQuantityTypeIdentifierDistanceWalkingRunning - HealthKit stores distance in meters. Use unit_conversions for sync (miles, km, meters all supported).';

-- Note: Distance units already exist in units_base
-- Common cardio distance units available:
--   - mile (mi) - most common for US users
--   - kilometer (km) - metric
--   - meter (m) - HealthKit native unit
--   - yard (yd)
--   - foot (ft)

COMMIT;
