-- =====================================================
-- Delete Specific Protein Types
-- =====================================================
-- Removes specific protein types, keeping only the 6 broad categories
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Delete Specific Protein Types (keep 6 broad categories)
-- =====================================================

-- Keep these 6:
-- 1. fatty_fish
-- 2. lean_protein
-- 3. plant_based
-- 4. processed_meat
-- 5. red_meat
-- 6. supplement

DELETE FROM data_entry_fields_reference
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
  v_remaining_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_remaining_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'protein_types';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Protein Types Cleaned Up!';
  RAISE NOTICE '';
  RAISE NOTICE 'Remaining protein types: %', v_remaining_count;
  RAISE NOTICE '  1. Fatty Fish';
  RAISE NOTICE '  2. Lean Protein';
  RAISE NOTICE '  3. Plant-Based';
  RAISE NOTICE '  4. Processed Meat';
  RAISE NOTICE '  5. Red Meat';
  RAISE NOTICE '  6. Supplement';
  RAISE NOTICE '';
  RAISE NOTICE 'Deleted: 12 specific types';
  RAISE NOTICE '  (eggs, greek yogurt, cottage cheese, tofu, tempeh, seitan, etc.)';
  RAISE NOTICE '';
END $$;

COMMIT;
