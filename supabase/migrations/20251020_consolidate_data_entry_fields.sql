-- =====================================================
-- Consolidate Data Entry Fields with HealthKit Integration
-- =====================================================
-- Phase 1: Add hybrid HealthKit columns
-- Phase 2: Link existing measurement fields to HealthKit
-- Phase 3: Mark deprecated screening fields as inactive
-- Phase 4: Add event_type_id for consolidated patterns
--
-- Goal: Clean architecture ready for Swift app by end of week
--
-- Created: 2025-10-20
-- =====================================================

BEGIN;

-- =====================================================
-- Phase 1: Add Hybrid HealthKit Columns
-- =====================================================

-- Add healthkit_identifier (if not exists, as hybrid partner to healthkit_type)
ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS healthkit_identifier TEXT,
ADD COLUMN IF NOT EXISTS healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL;

-- Add event_type reference for consolidated patterns
ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS event_type_id TEXT REFERENCES event_types(event_type_id) ON DELETE SET NULL;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_data_entry_fields_hk_identifier
  ON data_entry_fields(healthkit_identifier);

CREATE INDEX IF NOT EXISTS idx_data_entry_fields_hk_mapping
  ON data_entry_fields(healthkit_mapping_id);

CREATE INDEX IF NOT EXISTS idx_data_entry_fields_event_type
  ON data_entry_fields(event_type_id);

COMMENT ON COLUMN data_entry_fields.healthkit_identifier IS
'Raw HealthKit identifier (e.g., HKQuantityTypeIdentifierStepCount) for resilient sync';

COMMENT ON COLUMN data_entry_fields.healthkit_mapping_id IS
'FK to healthkit_mapping for structured queries. Can be NULL if no mapping exists yet.';

COMMENT ON COLUMN data_entry_fields.event_type_id IS
'Links field to consolidated event type (e.g., body_measurement, health_screening)';


-- =====================================================
-- Phase 2: Link Measurement Fields to HealthKit
-- =====================================================

-- Body Measurements
UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierBodyFatPercentage',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBodyFatPercentage')
WHERE field_id = 'DEF_113';  -- body_fat

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierLeanBodyMass',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierLeanBodyMass')
WHERE field_id = 'DEF_114';  -- lean_body_mass

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierBodyMass',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBodyMass')
WHERE field_id = 'DEF_116';  -- weight

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierHeight',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierHeight')
WHERE field_id = 'DEF_119';  -- height

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierWaistCircumference',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierWaistCircumference')
WHERE field_id = 'DEF_120';  -- waist

-- Cardiovascular
UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierRestingHeartRate',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierRestingHeartRate')
WHERE field_id = 'DEF_122';  -- resting_heart_rate

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierHeartRateVariabilitySDNN',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierHeartRateVariabilitySDNN')
WHERE field_id = 'DEF_123';  -- hrv

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureSystolic',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureSystolic')
WHERE field_id = 'DEF_124';  -- systolic_bp

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureDiastolic',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureDiastolic')
WHERE field_id = 'DEF_125';  -- diastolic_bp

UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierVO2Max',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierVO2Max')
WHERE field_id = 'DEF_126';  -- vo2_max

-- Activity
UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKQuantityTypeIdentifierStepCount',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierStepCount')
WHERE field_id = 'DEF_127';  -- steps

-- Link sleep fields to HealthKit category types
UPDATE data_entry_fields
SET
  healthkit_identifier = 'HKCategoryTypeIdentifierSleepAnalysis',
  healthkit_mapping_id = (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKCategoryTypeIdentifierSleepAnalysis')
WHERE field_name IN ('sleep_start', 'sleep_end', 'sleep_quality');


-- =====================================================
-- Phase 3: Mark Deprecated Screening Fields as Inactive
-- =====================================================
-- These are replaced by consolidated screening_name + screening_date

UPDATE data_entry_fields
SET
  is_active = false,
  updated_at = now()
WHERE field_id IN (
  'DEF_055',  -- dental_screening_date
  'DEF_056',  -- physical_exam_date
  'DEF_057',  -- skin_check_date
  'DEF_058',  -- vision_check_date
  'DEF_059',  -- colonoscopy_date
  'DEF_060',  -- mammogram_date
  'DEF_061',  -- breast_mri_date
  'DEF_062',  -- hpv_date
  'DEF_063',  -- pap_date
  'DEF_064'   -- psa_date
);

-- Link consolidated screening fields to event type
UPDATE data_entry_fields
SET event_type_id = 'health_screening'
WHERE field_id IN ('DEF_SCREENING_NAME', 'DEF_SCREENING_DATE');


-- =====================================================
-- Phase 4: Create Summary View
-- =====================================================

CREATE OR REPLACE VIEW data_entry_fields_with_healthkit AS
SELECT
  def.field_id,
  def.field_name,
  def.display_name,
  def.field_type,
  def.data_type,
  def.event_type_id,
  def.healthkit_identifier,
  hm.healthkit_type_name,
  hm.display_name as healthkit_display_name,
  hm.category as healthkit_category,
  hm.default_unit,
  hm.aggregation_style,
  hm.is_writable as healthkit_writable,
  def.is_active
FROM data_entry_fields def
LEFT JOIN healthkit_mapping hm ON def.healthkit_mapping_id = hm.id
WHERE def.is_active = true
ORDER BY def.field_name;

COMMENT ON VIEW data_entry_fields_with_healthkit IS
'Shows active data entry fields with their HealthKit mappings for easy reference';


-- =====================================================
-- Phase 5: Add HealthKit Support Flag
-- =====================================================

ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS supports_healthkit_sync BOOLEAN DEFAULT false;

-- Mark fields with HealthKit mapping as sync-enabled
UPDATE data_entry_fields
SET supports_healthkit_sync = true
WHERE healthkit_mapping_id IS NOT NULL;

COMMENT ON COLUMN data_entry_fields.supports_healthkit_sync IS
'Indicates if this field can be auto-populated from HealthKit sync';


COMMIT;
