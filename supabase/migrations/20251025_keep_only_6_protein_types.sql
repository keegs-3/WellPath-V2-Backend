-- =====================================================
-- Keep Only 6 Main Protein Types
-- =====================================================
-- Deactivates specific protein types, keeping only the 6 broad categories
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Deactivate Specific Protein Types (keep 6 broad categories)
-- =====================================================

-- Keep these 6:
-- 1. fatty_fish
-- 2. lean_protein
-- 3. plant_based
-- 4. processed_meat
-- 5. red_meat
-- 6. supplement

UPDATE data_entry_fields_reference
SET is_active = false
WHERE reference_category = 'protein_types'
  AND reference_key NOT IN (
    'fatty_fish',
    'lean_protein',
    'plant_based',
    'processed_meat',
    'red_meat',
    'supplement'
  );

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_active_count INTEGER;
  v_inactive_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_active_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'protein_types' AND is_active = true;

  SELECT COUNT(*) INTO v_inactive_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'protein_types' AND is_active = false;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Protein Types Simplified!';
  RAISE NOTICE '';
  RAISE NOTICE 'Active protein types: %', v_active_count;
  RAISE NOTICE '  1. Fatty Fish (salmon, mackerel, sardines)';
  RAISE NOTICE '  2. Lean Protein (chicken, turkey, white fish)';
  RAISE NOTICE '  3. Plant-Based (beans, lentils, tofu, tempeh, seitan)';
  RAISE NOTICE '  4. Processed Meat (bacon, sausage, deli meat)';
  RAISE NOTICE '  5. Red Meat (beef, pork, lamb)';
  RAISE NOTICE '  6. Supplement (protein powder, bars)';
  RAISE NOTICE '';
  RAISE NOTICE 'Deactivated: % specific types', v_inactive_count;
  RAISE NOTICE '  (eggs, greek yogurt, cottage cheese, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Mobile will only show these 6 options in dropdown';
  RAISE NOTICE '';
END $$;

COMMIT;
