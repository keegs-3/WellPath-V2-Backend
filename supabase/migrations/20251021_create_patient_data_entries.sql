-- =====================================================
-- Create Patient Data Entries Table
-- =====================================================
-- Central unified table for ALL raw patient data
-- Maps to data_entry_fields for field definitions
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create patient_data_entries table
-- =====================================================

CREATE TABLE IF NOT EXISTS patient_data_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- What field is this data for?
  field_id TEXT NOT NULL REFERENCES data_entry_fields(field_id),

  -- When did this happen?
  entry_date DATE NOT NULL,
  entry_timestamp TIMESTAMPTZ,

  -- The actual value (store in appropriate column based on field_type)
  value_quantity NUMERIC,
  value_text TEXT,
  value_reference TEXT, -- References def_ref_* tables (stores the key/id)
  value_category TEXT,
  value_rating INTEGER,
  value_boolean BOOLEAN,
  value_timestamp TIMESTAMPTZ,

  -- Data source and sync info
  source TEXT DEFAULT 'manual', -- 'manual', 'healthkit', 'import', 'api', 'system'
  healthkit_source_name TEXT,
  healthkit_uuid TEXT, -- For deduplication

  -- Metadata
  metadata JSONB DEFAULT '{}'::jsonb,

  -- Tracking
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add check constraint: exactly one value column should be non-null
ALTER TABLE patient_data_entries
ADD CONSTRAINT patient_data_entries_one_value_check
CHECK (
  (value_quantity IS NOT NULL)::int +
  (value_text IS NOT NULL)::int +
  (value_reference IS NOT NULL)::int +
  (value_category IS NOT NULL)::int +
  (value_rating IS NOT NULL)::int +
  (value_boolean IS NOT NULL)::int +
  (value_timestamp IS NOT NULL)::int = 1
);

-- Add check constraint: source must be valid
ALTER TABLE patient_data_entries
ADD CONSTRAINT patient_data_entries_source_check
CHECK (source IN ('manual', 'healthkit', 'import', 'api', 'system'));


-- =====================================================
-- PART 2: Create indexes for performance
-- =====================================================

-- Core lookup indexes
CREATE INDEX IF NOT EXISTS idx_patient_data_entries_user_id
  ON patient_data_entries(user_id);

CREATE INDEX IF NOT EXISTS idx_patient_data_entries_field_id
  ON patient_data_entries(field_id);

CREATE INDEX IF NOT EXISTS idx_patient_data_entries_entry_date
  ON patient_data_entries(entry_date);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_patient_data_entries_user_field
  ON patient_data_entries(user_id, field_id);

CREATE INDEX IF NOT EXISTS idx_patient_data_entries_user_date
  ON patient_data_entries(user_id, entry_date);

CREATE INDEX IF NOT EXISTS idx_patient_data_entries_user_field_date
  ON patient_data_entries(user_id, field_id, entry_date);

-- HealthKit deduplication index
CREATE UNIQUE INDEX IF NOT EXISTS idx_patient_data_entries_healthkit_uuid
  ON patient_data_entries(healthkit_uuid)
  WHERE healthkit_uuid IS NOT NULL;


-- =====================================================
-- PART 3: Add helpful comments
-- =====================================================

COMMENT ON TABLE patient_data_entries IS
'Central unified table for ALL raw patient data. Maps to data_entry_fields. Source for instance calculations and aggregations.';

COMMENT ON COLUMN patient_data_entries.field_id IS
'References data_entry_fields - determines which value column to use based on field_type';

COMMENT ON COLUMN patient_data_entries.entry_date IS
'Date of the data entry (required for all entries, used for time-based aggregations)';

COMMENT ON COLUMN patient_data_entries.entry_timestamp IS
'Precise timestamp (optional, for time-of-day sensitive data like sleep bedtime)';

COMMENT ON COLUMN patient_data_entries.value_quantity IS
'For field_type = quantity (steps, duration, weight, distance, etc.)';

COMMENT ON COLUMN patient_data_entries.value_text IS
'For field_type = text (free-form text entries)';

COMMENT ON COLUMN patient_data_entries.value_reference IS
'For field_type = reference (links to def_ref_* tables, stores period_name, cardio_type_key, etc.)';

COMMENT ON COLUMN patient_data_entries.value_category IS
'For field_type = category (predefined category values)';

COMMENT ON COLUMN patient_data_entries.value_rating IS
'For field_type = rating (1-5, 1-10 scales)';

COMMENT ON COLUMN patient_data_entries.value_boolean IS
'For field_type = boolean (yes/no, true/false)';

COMMENT ON COLUMN patient_data_entries.value_timestamp IS
'For field_type = timestamp (bedtime, wake time, meal time, start/end times)';

COMMENT ON COLUMN patient_data_entries.source IS
'Data source: manual (user input), healthkit (synced), import (bulk), api (external), system (calculated)';

COMMENT ON COLUMN patient_data_entries.healthkit_uuid IS
'HealthKit sample UUID for deduplication (prevents duplicate syncs)';


-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Patient Data Entries Table Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Table: patient_data_entries';
  RAISE NOTICE 'Purpose: Unified storage for ALL patient data';
  RAISE NOTICE '';
  RAISE NOTICE 'Value columns by field_type:';
  RAISE NOTICE '  - quantity → value_quantity';
  RAISE NOTICE '  - text → value_text';
  RAISE NOTICE '  - reference → value_reference';
  RAISE NOTICE '  - category → value_category';
  RAISE NOTICE '  - rating → value_rating';
  RAISE NOTICE '  - boolean → value_boolean';
  RAISE NOTICE '  - timestamp → value_timestamp';
  RAISE NOTICE '';
  RAISE NOTICE 'Data flows:';
  RAISE NOTICE '  patient_data_entries → instance_calculations → aggregation_metrics → display_metrics';
END $$;

COMMIT;
