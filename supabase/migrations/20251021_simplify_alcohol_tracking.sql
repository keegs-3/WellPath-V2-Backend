-- =====================================================
-- Simplify Alcohol Tracking
-- =====================================================
-- Removes DEF_ALCOHOL_TYPE field per user requirement
-- Keeps only quantity tracking (standard drinks)
--
-- Supports REC0005: Reduce or Eliminate Alcohol Consumption
-- REC0044: Alcohol Intake ≤3-4 Hours Before Bed
--
-- Simplification: Just track "drinks" - no type differentiation
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Mark Alcohol Type Field as Inactive
-- =====================================================

UPDATE data_entry_fields
SET
  is_active = false,
  updated_at = NOW()
WHERE field_id = 'DEF_ALCOHOL_TYPE';

-- Add comment explaining the simplification
COMMENT ON COLUMN data_entry_fields.is_active IS
'Indicates if field is active and available for data entry. DEF_ALCOHOL_TYPE deprecated 2025-10-21 - simplified to quantity-only tracking.';


-- =====================================================
-- PART 2: Archive Alcohol Types Reference Table
-- =====================================================

-- Rename table to indicate it's archived (keep data for historical reference)
ALTER TABLE IF EXISTS def_ref_alcohol_types
RENAME TO z_old_def_ref_alcohol_types;

COMMENT ON TABLE z_old_def_ref_alcohol_types IS
'ARCHIVED 2025-10-21: Alcohol types reference table. No longer used - alcohol tracking simplified to quantity only (standard drinks).';


-- =====================================================
-- PART 3: Update Alcohol Quantity Field Description
-- =====================================================

UPDATE data_entry_fields
SET
  description = 'Number of standard drinks consumed (simplified tracking - no type differentiation)',
  updated_at = NOW()
WHERE field_id = 'DEF_ALCOHOL_QUANTITY';


-- =====================================================
-- PART 4: Data Cleanup (Optional - for existing entries)
-- =====================================================

-- Note: Existing patient_data_entries with DEF_ALCOHOL_TYPE are preserved
-- but will no longer be created going forward. Historical data remains intact.

-- If you want to clean up existing alcohol type entries, uncomment below:
-- UPDATE patient_data_entries
-- SET is_active = false
-- WHERE field_id = 'DEF_ALCOHOL_TYPE';

COMMIT;
