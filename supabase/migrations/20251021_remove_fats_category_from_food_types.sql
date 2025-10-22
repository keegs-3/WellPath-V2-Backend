-- =====================================================
-- Remove Fats Category from Food Types Table
-- =====================================================
-- Fats belong in specialized def_ref_fat_types table with omega metadata
-- Removes standalone fats category while keeping nuts (dual purpose)
--
-- Keeps: nuts in both food_types (for nut servings) AND fat_types (for healthy fats)
-- Removes: standalone fats category (coconut oil, lard, etc.)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Delete Standalone Fats from Food Types
-- =====================================================

DELETE FROM def_ref_food_types
WHERE category_name = 'fats';

-- Note: This does NOT remove nuts, which can exist in both:
-- - food_types (category='nuts_seeds') for nut servings recommendations
-- - fat_types for healthy fats recommendations


-- =====================================================
-- PART 2: Verify Food Types Categories
-- =====================================================

COMMENT ON COLUMN def_ref_food_types.category_name IS
'Food category for filtering and grouping. Valid categories: vegetables, fruits, whole_grains, legumes, nuts_seeds.

Note: Fats are tracked separately in def_ref_fat_types with omega-3/6/9 metadata.
Nuts appear in BOTH tables:
- food_types (nuts_seeds) - for tracking nut/seed servings recommendations
- fat_types - for tracking healthy fat sources recommendations';


COMMIT;
