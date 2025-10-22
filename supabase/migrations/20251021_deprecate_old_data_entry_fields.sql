-- =====================================================
-- Deprecate Old Data Entry Fields
-- =====================================================
-- Marks old individual fields as inactive (is_active=false)
-- These are replaced by consolidated event-based patterns
--
-- Fields to KEEP active:
-- - New consolidated fields (event_type_id IS NOT NULL)
-- - Therapeutic fields (already using reference tables pattern)
-- - Any fields that don't have a consolidated replacement yet
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Mark all old fields as inactive EXCEPT:
-- 1. New consolidated fields (event_type_id IN our new events)
-- 2. Therapeutic fields (already good pattern)
-- 3. Fields that support HealthKit sync (we want to keep these)

UPDATE data_entry_fields
SET
  is_active = false,
  updated_at = now()
WHERE is_active = true
AND event_type_id IS NULL  -- Not linked to new consolidated events
AND field_name NOT LIKE 'therapeutic%'  -- Keep therapeutic fields
AND supports_healthkit_sync IS NOT TRUE  -- Keep HealthKit-synced fields
AND field_id NOT IN (
  -- Explicitly keep these fields that don't have replacements yet
  'DEF_BIRTH_DATE',  -- Patient characteristic
  'DEF_GENDER'  -- Patient characteristic
);

-- Create summary view of active vs deprecated fields
CREATE OR REPLACE VIEW data_entry_fields_summary AS
SELECT
  CASE
    WHEN event_type_id IS NOT NULL THEN 'Consolidated Event Field'
    WHEN field_name LIKE 'therapeutic%' THEN 'Therapeutic Field'
    WHEN supports_healthkit_sync = true THEN 'HealthKit Synced Field'
    WHEN is_active = false THEN 'Deprecated Field'
    ELSE 'Other Active Field'
  END as field_status,
  COUNT(*) as count
FROM data_entry_fields
GROUP BY field_status
ORDER BY count DESC;

COMMENT ON VIEW data_entry_fields_summary IS
'Summary of data_entry_fields by status (consolidated, therapeutic, deprecated, etc.)';

COMMIT;
