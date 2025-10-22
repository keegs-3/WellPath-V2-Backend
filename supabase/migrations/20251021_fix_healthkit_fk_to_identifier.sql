-- =====================================================
-- Fix HealthKit Foreign Keys to Use Identifiers Not UUIDs
-- =====================================================
-- Changes FK pattern from UUID to text identifier for easier mapping
-- Pattern:
--   healthkit_identifier_text: Direct HK identifier string (e.g., 'HKQuantityTypeIdentifierStepCount')
--   healthkit_identifier: FK to healthkit_mapping.healthkit_identifier (text, not UUID)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Update healthkit_mapping table (if needed)
-- =====================================================
-- healthkit_identifier already has unique constraint (healthkit_mapping_healthkit_identifier_key1)
-- No changes needed


-- =====================================================
-- 2. Fix Reference Tables - Rename & Remap Columns
-- =====================================================

-- Pattern for each table:
-- 1. Drop UUID FK column (healthkit_mapping_id)
-- 2. Rename healthkit_identifier to healthkit_identifier_text
-- 3. Add new healthkit_identifier column (TEXT)
-- 4. Populate healthkit_identifier from healthkit_identifier_text (only if exists in healthkit_mapping)
-- 5. Add FK to healthkit_mapping.healthkit_identifier

-- Helper function to apply pattern to all tables
DO $$
DECLARE
  table_rec RECORD;
  table_list TEXT[] := ARRAY[
    'def_ref_cardio_types',
    'def_ref_strength_types',
    'def_ref_flexibility_types',
    'def_ref_sleep_period_types',
    'def_ref_mindfulness_types',
    'def_ref_measurement_types',
    'def_ref_selfcare_types',
    'def_ref_food_types'
  ];
  table_name_val TEXT;
BEGIN
  FOREACH table_name_val IN ARRAY table_list
  LOOP
    -- Drop UUID FK column and constraints
    EXECUTE format('
      ALTER TABLE %I
      DROP CONSTRAINT IF EXISTS %s_healthkit_mapping_id_fkey;
    ', table_name_val, REPLACE(table_name_val, 'def_ref_', ''));

    EXECUTE format('
      ALTER TABLE %I
      DROP COLUMN IF EXISTS healthkit_mapping_id;
    ', table_name_val);

    -- Rename healthkit_identifier to healthkit_identifier_text
    EXECUTE format('
      ALTER TABLE %I
      RENAME COLUMN healthkit_identifier TO healthkit_identifier_text;
    ', table_name_val);

    -- Add new healthkit_identifier column
    EXECUTE format('
      ALTER TABLE %I
      ADD COLUMN healthkit_identifier TEXT;
    ', table_name_val);

    -- Populate healthkit_identifier from text column (only if exists in healthkit_mapping)
    EXECUTE format('
      UPDATE %I t
      SET healthkit_identifier = t.healthkit_identifier_text
      WHERE t.healthkit_identifier_text IN (
        SELECT healthkit_identifier FROM healthkit_mapping
      );
    ', table_name_val);

    -- Add FK constraint
    EXECUTE format('
      ALTER TABLE %I
      ADD CONSTRAINT %s_healthkit_identifier_fkey
      FOREIGN KEY (healthkit_identifier)
      REFERENCES healthkit_mapping(healthkit_identifier);
    ', table_name_val, REPLACE(table_name_val, 'def_ref_', ''));

  END LOOP;
END $$;


-- =====================================================
-- 3. Add Comments
-- =====================================================

COMMENT ON COLUMN def_ref_cardio_types.healthkit_identifier_text IS
'Direct HealthKit identifier string (e.g., HKWorkoutActivityTypeRunning)';

COMMENT ON COLUMN def_ref_cardio_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMENT ON COLUMN def_ref_strength_types.healthkit_identifier_text IS
'Direct HealthKit identifier string';

COMMENT ON COLUMN def_ref_strength_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMENT ON COLUMN def_ref_flexibility_types.healthkit_identifier_text IS
'Direct HealthKit identifier string';

COMMENT ON COLUMN def_ref_flexibility_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMENT ON COLUMN def_ref_sleep_period_types.healthkit_identifier_text IS
'Direct HealthKit identifier string';

COMMENT ON COLUMN def_ref_sleep_period_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMENT ON COLUMN def_ref_mindfulness_types.healthkit_identifier_text IS
'Direct HealthKit identifier string';

COMMENT ON COLUMN def_ref_mindfulness_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMENT ON COLUMN def_ref_measurement_types.healthkit_identifier_text IS
'Direct HealthKit identifier string';

COMMENT ON COLUMN def_ref_measurement_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMENT ON COLUMN def_ref_selfcare_types.healthkit_identifier_text IS
'Direct HealthKit identifier string';

COMMENT ON COLUMN def_ref_selfcare_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMENT ON COLUMN def_ref_food_types.healthkit_identifier_text IS
'Direct HealthKit identifier string';

COMMENT ON COLUMN def_ref_food_types.healthkit_identifier IS
'FK to healthkit_mapping.healthkit_identifier for lookup';

COMMIT;
