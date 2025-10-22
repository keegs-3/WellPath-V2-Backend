-- =====================================================
-- Standardize Unhealthy Beverage Units
-- =====================================================
-- Changes DEF_UNHEALTHY_BEV_QUANTITY from "ounce" to "serving"
-- Aligns with overall simplification strategy
--
-- Per user guidance: standardize beverages to servings
-- (Water gets unit options, other beverages → servings)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Update Unhealthy Beverage Quantity Unit
-- =====================================================

UPDATE data_entry_fields
SET
  unit = 'serving',
  description = 'Number of servings of unhealthy beverages consumed (simplified to serving-based tracking)',
  validation_config = '{"min": 0, "max": 20, "increment": 1}'::jsonb,
  updated_at = NOW()
WHERE field_id = 'DEF_UNHEALTHY_BEV_QUANTITY';


-- =====================================================
-- PART 2: Update Reference Table with Serving Sizes
-- =====================================================

-- Add typical_serving_oz column (typical_serving_size already exists)
ALTER TABLE def_ref_unhealthy_beverage_types
ADD COLUMN IF NOT EXISTS typical_serving_oz NUMERIC;

-- Update existing types with typical serving information (if they exist)
UPDATE def_ref_unhealthy_beverage_types
SET typical_serving_oz = 12
WHERE beverage_type_key = 'soda' AND typical_serving_oz IS NULL;

UPDATE def_ref_unhealthy_beverage_types
SET typical_serving_oz = 8
WHERE beverage_type_key = 'sweet_tea' AND typical_serving_oz IS NULL;

UPDATE def_ref_unhealthy_beverage_types
SET typical_serving_oz = 8.4
WHERE beverage_type_key = 'energy_drink' AND typical_serving_oz IS NULL;

UPDATE def_ref_unhealthy_beverage_types
SET typical_serving_oz = 12
WHERE beverage_type_key = 'sports_drink' AND typical_serving_oz IS NULL;

UPDATE def_ref_unhealthy_beverage_types
SET typical_serving_oz = 20
WHERE beverage_type_key = 'flavored_water' AND typical_serving_oz IS NULL;


-- =====================================================
-- PART 3: Add Comments for Clarity
-- =====================================================

COMMENT ON COLUMN def_ref_unhealthy_beverage_types.typical_serving_size IS
'Typical serving size description for UI guidance (e.g., "12 oz can"). Users track servings, not ounces.';

COMMENT ON COLUMN def_ref_unhealthy_beverage_types.typical_serving_oz IS
'Typical ounces per serving for reference. Informational only - tracking is servings-based, not ounce-based.';

COMMIT;
