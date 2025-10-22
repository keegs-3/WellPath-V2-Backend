-- =====================================================
-- Fix Water Default Unit
-- =====================================================
-- Change default from 'cup' to 'fluid_ounce'
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Remove default from cup
UPDATE def_ref_water_units
SET is_default = false
WHERE water_unit_key = 'cup';

-- Set fluid_ounce as default
UPDATE def_ref_water_units
SET is_default = true
WHERE water_unit_key = 'fluid_ounce';

-- Verify
DO $$
DECLARE
  default_unit TEXT;
BEGIN
  SELECT water_unit_key INTO default_unit
  FROM def_ref_water_units
  WHERE is_default = true;

  RAISE NOTICE '✅ Water default unit is now: %', default_unit;
END $$;

COMMIT;
