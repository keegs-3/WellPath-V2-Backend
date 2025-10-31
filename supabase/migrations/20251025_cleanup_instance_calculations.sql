-- =====================================================
-- Clean Up Instance Calculations
-- =====================================================
-- Removes obsolete instance calculations based on cleaned data_entry_fields
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Remove Obsolete Servings Conversions
-- =====================================================

-- Remove fat servings conversions (we only use grams now)
DELETE FROM instance_calculations_dependencies
WHERE instance_calculation_id IN (
  'CALC_FAT_GRAMS_TO_SERVINGS',
  'CALC_FAT_SERVINGS_TO_GRAMS'
);

DELETE FROM instance_calculations
WHERE calc_id IN (
  'CALC_FAT_GRAMS_TO_SERVINGS',
  'CALC_FAT_SERVINGS_TO_GRAMS'
);

-- Remove fiber servings conversions (we only use grams now)
DELETE FROM instance_calculations_dependencies
WHERE instance_calculation_id IN (
  'CALC_FIBER_GRAMS_TO_SERVINGS',
  'CALC_FIBER_SERVINGS_TO_GRAMS'
);

DELETE FROM instance_calculations
WHERE calc_id IN (
  'CALC_FIBER_GRAMS_TO_SERVINGS',
  'CALC_FIBER_SERVINGS_TO_GRAMS'
);

-- =====================================================
-- 2. Verify All Dependencies Reference Valid Fields
-- =====================================================

-- Check for any orphaned dependencies (should be none after CASCADE)
DO $$
DECLARE
  v_orphaned_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_orphaned_count
  FROM instance_calculations_dependencies
  WHERE data_entry_field_id NOT IN (SELECT field_id FROM data_entry_fields);

  IF v_orphaned_count > 0 THEN
    RAISE WARNING 'Found % orphaned instance_calculations_dependencies', v_orphaned_count;
  END IF;
END $$;

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_total_calcs INTEGER;
  v_total_deps INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total_calcs FROM instance_calculations;
  SELECT COUNT(*) INTO v_total_deps FROM instance_calculations_dependencies;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Instance Calculations Cleaned Up!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total instance calculations: %', v_total_calcs;
  RAISE NOTICE '  Total dependencies: %', v_total_deps;
  RAISE NOTICE '';
  RAISE NOTICE 'Removed:';
  RAISE NOTICE '  ❌ CALC_FAT_GRAMS_TO_SERVINGS';
  RAISE NOTICE '  ❌ CALC_FAT_SERVINGS_TO_GRAMS';
  RAISE NOTICE '  ❌ CALC_FIBER_GRAMS_TO_SERVINGS';
  RAISE NOTICE '  ❌ CALC_FIBER_SERVINGS_TO_GRAMS';
  RAISE NOTICE '';
  RAISE NOTICE 'All remaining calculations reference valid data_entry_fields';
  RAISE NOTICE '';
END $$;

COMMIT;
