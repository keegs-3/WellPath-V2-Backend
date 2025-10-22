-- =====================================================
-- Clean Up data_entry_fields Table
-- =====================================================
-- 1. Drop unused columns (aggregation_type, allowed_values)
-- 2. Add validation threshold columns
-- 3. Update healthkit_type for reference fields
-- 4. Update supports_healthkit_sync to be accurate
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Drop Unused Columns
-- =====================================================

-- Drop aggregation_type (never populated, not used)
ALTER TABLE data_entry_fields
DROP COLUMN IF EXISTS aggregation_type;

-- Drop allowed_values (not used with reference tables)
ALTER TABLE data_entry_fields
DROP COLUMN IF EXISTS allowed_values;


-- =====================================================
-- 2. Add Validation Threshold Columns
-- =====================================================

ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS validation_min NUMERIC,
ADD COLUMN IF NOT EXISTS validation_max NUMERIC,
ADD COLUMN IF NOT EXISTS validation_prompt_threshold NUMERIC,
ADD COLUMN IF NOT EXISTS validation_max_threshold NUMERIC;

COMMENT ON COLUMN data_entry_fields.validation_min IS
'Minimum allowed value for quantity/rating fields';

COMMENT ON COLUMN data_entry_fields.validation_max IS
'Maximum allowed value for quantity/rating fields';

COMMENT ON COLUMN data_entry_fields.validation_prompt_threshold IS
'Value that triggers a warning prompt to user (e.g., high BP)';

COMMENT ON COLUMN data_entry_fields.validation_max_threshold IS
'Value that triggers hard validation error (e.g., impossible value)';


-- =====================================================
-- 3. Set Validation Rules for Common Field Types
-- =====================================================

-- Rating fields (1-10 scale)
UPDATE data_entry_fields
SET
  validation_min = 1,
  validation_max = 10
WHERE field_type = 'rating'
AND is_active = true;

-- Intensity fields (1-10 scale)
UPDATE data_entry_fields
SET
  validation_min = 1,
  validation_max = 10
WHERE field_name LIKE '%intensity%'
AND field_type = 'rating'
AND is_active = true;

-- Meal size (enum values via validation)
UPDATE data_entry_fields
SET
  validation_min = 1,
  validation_max = 3  -- 1=small, 2=regular, 3=large
WHERE field_name = 'meal_size'
AND is_active = true;


-- =====================================================
-- 4. Update healthkit_type for Reference Fields
-- =====================================================
-- Reference fields that link to types with HealthKit mappings

UPDATE data_entry_fields
SET healthkit_type = 'HKWorkoutActivityType'
WHERE field_name IN ('cardio_type_id', 'strength_type_id', 'flexibility_type_id')
AND is_active = true;

UPDATE data_entry_fields
SET healthkit_type = 'HKCategoryType'
WHERE field_name IN ('sleep_period_type')
AND is_active = true;

UPDATE data_entry_fields
SET healthkit_type = 'HKQuantityType'
WHERE field_name IN ('measurement_type_id', 'measurement_unit_id')
AND is_active = true;


-- =====================================================
-- 5. Update supports_healthkit_sync Accurately
-- =====================================================

-- TRUE: Fields that directly map to HealthKit OR reference types that have HK mappings
UPDATE data_entry_fields
SET supports_healthkit_sync = true
WHERE is_active = true
AND (
  -- Direct HealthKit fields (already set)
  healthkit_identifier IS NOT NULL

  -- Reference fields pointing to types with HealthKit mappings
  OR field_name IN (
    'cardio_type_id',           -- cardio_types has HK identifiers
    'strength_type_id',         -- strength_types has HK identifiers
    'flexibility_type_id',      -- flexibility_types has HK identifiers
    'sleep_period_type',        -- sleep_period_types has HK identifiers
    'measurement_type_id',      -- measurement_types has HK identifiers
    'mindfulness_type_id',      -- mindfulness_types has HK identifiers (partial)
    'selfcare_type_id'          -- selfcare_types has HK identifiers (partial)
  )

  -- Timestamp fields for HealthKit-compatible events
  OR (field_type = 'timestamp' AND event_type_id IN (
    'cardio_event',
    'strength_event',
    'flexibility_event',
    'sleep_event',
    'measurement_event',
    'mindfulness_event'
  ))
);

-- FALSE: Fields with NO HealthKit equivalent
UPDATE data_entry_fields
SET supports_healthkit_sync = false
WHERE is_active = true
AND supports_healthkit_sync IS NOT true
AND (
  -- Meal/nutrition tracking (no direct HK equivalent)
  event_type_id = 'meal_event'

  -- Screening events (no HK equivalent)
  OR event_type_id = 'screening_event'

  -- Substance tracking (no HK equivalent for detailed tracking)
  OR event_type_id = 'substance_event'

  -- Quality/rating fields (subjective, not in HK)
  OR field_name IN ('sleep_quality', 'stress_level', 'meal_size')

  -- Factor/qualifier arrays (not in HK)
  OR field_name IN ('sleep_factors', 'stress_factors', 'meal_qualifiers', 'muscle_groups')

  -- Food/beverage references (not in HK)
  OR field_name IN ('food_type_id', 'beverage_type_id', 'meal_type_id')

  -- Screening/substance references
  OR field_name IN ('screening_type_id', 'substance_type_id', 'substance_source_id')
);


-- =====================================================
-- 6. Add HealthKit Sync Notes Column
-- =====================================================

ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS healthkit_sync_notes TEXT;

COMMENT ON COLUMN data_entry_fields.healthkit_sync_notes IS
'Notes about HealthKit sync behavior for this field (e.g., "Maps via cardio_types table", "No HK equivalent")';

-- Add notes for reference fields
UPDATE data_entry_fields
SET healthkit_sync_notes = 'Syncs via ' || REPLACE(field_name, '_id', '') || ' table with HK identifiers'
WHERE field_name IN (
  'cardio_type_id', 'strength_type_id', 'flexibility_type_id',
  'sleep_period_type', 'measurement_type_id', 'mindfulness_type_id', 'selfcare_type_id'
)
AND is_active = true;

-- Add notes for non-HK fields
UPDATE data_entry_fields
SET healthkit_sync_notes = 'No HealthKit equivalent - app-specific tracking'
WHERE supports_healthkit_sync = false
AND is_active = true
AND healthkit_sync_notes IS NULL;


-- =====================================================
-- 7. Create Cleanup Summary View
-- =====================================================

CREATE OR REPLACE VIEW data_entry_fields_healthkit_summary AS
SELECT
  event_type_id,
  COUNT(*) as total_fields,
  COUNT(*) FILTER (WHERE supports_healthkit_sync = true) as hk_sync_fields,
  COUNT(*) FILTER (WHERE supports_healthkit_sync = false) as no_hk_sync,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE supports_healthkit_sync = true) / NULLIF(COUNT(*), 0),
    1
  ) as hk_sync_percent
FROM data_entry_fields
WHERE is_active = true
GROUP BY event_type_id
ORDER BY hk_sync_percent DESC NULLS LAST;

COMMENT ON VIEW data_entry_fields_healthkit_summary IS
'Summary of HealthKit sync support by event type';

COMMIT;
