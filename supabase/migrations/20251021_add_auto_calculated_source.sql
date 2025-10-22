-- =====================================================
-- Add 'auto_calculated' to patient_data_entries source check
-- =====================================================
-- Allows instance calculations to insert auto-calculated entries
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Drop existing constraint
ALTER TABLE patient_data_entries
DROP CONSTRAINT IF EXISTS patient_data_entries_source_check;

-- Recreate with 'auto_calculated' added
ALTER TABLE patient_data_entries
ADD CONSTRAINT patient_data_entries_source_check
CHECK (source = ANY (ARRAY[
  'manual'::text,
  'healthkit'::text,
  'import'::text,
  'api'::text,
  'system'::text,
  'auto_calculated'::text
]));

COMMIT;
