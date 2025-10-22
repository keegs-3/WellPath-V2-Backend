-- =====================================================
-- Migrate Nuts/Seeds to Main Food Types Table
-- =====================================================
-- Consolidates def_ref_nut_seed_types into def_ref_food_types
-- Adds nutrition metadata for cross-population
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Migrate Existing Nuts/Seeds to Food Types
-- =====================================================

INSERT INTO def_ref_food_types (
  food_name,
  display_name,
  category_name,
  fiber_grams_per_serving,
  protein_grams_per_serving,
  fat_grams_per_serving,
  default_serving_size,
  default_unit,
  is_active
)
SELECT
  nut_seed_key as food_name,
  display_name,
  'nuts_seeds' as category_name,
  4 as fiber_grams_per_serving,  -- Average for nuts/seeds
  6 as protein_grams_per_serving,  -- Average
  14 as fat_grams_per_serving,  -- Average (healthy fats)
  1 as default_serving_size,
  'ounce' as default_unit,
  is_active
FROM def_ref_nut_seed_types
ON CONFLICT (food_name) DO UPDATE SET
  fiber_grams_per_serving = EXCLUDED.fiber_grams_per_serving,
  protein_grams_per_serving = EXCLUDED.protein_grams_per_serving,
  fat_grams_per_serving = EXCLUDED.fat_grams_per_serving;


-- =====================================================
-- PART 2: Update Specific Nuts/Seeds with Accurate Nutrition
-- =====================================================

-- Almonds (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 3.5,
  protein_grams_per_serving = 6,
  fat_grams_per_serving = 14
WHERE food_name = 'almonds';

-- Walnuts (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 2,
  protein_grams_per_serving = 4.3,
  fat_grams_per_serving = 18.5
WHERE food_name = 'walnuts';

-- Cashews (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 1,
  protein_grams_per_serving = 5,
  fat_grams_per_serving = 12
WHERE food_name = 'cashews';

-- Pecans (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 2.7,
  protein_grams_per_serving = 2.6,
  fat_grams_per_serving = 20
WHERE food_name = 'pecans';

-- Pistachios (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 3,
  protein_grams_per_serving = 6,
  fat_grams_per_serving = 13
WHERE food_name = 'pistachios';

-- Chia seeds (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 10,
  protein_grams_per_serving = 4.7,
  fat_grams_per_serving = 9
WHERE food_name = 'chia_seeds';

-- Flax seeds (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 8,
  protein_grams_per_serving = 5,
  fat_grams_per_serving = 12
WHERE food_name = 'flax_seeds' OR food_name = 'flaxseeds';

-- Pumpkin seeds (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 1.7,
  protein_grams_per_serving = 7,
  fat_grams_per_serving = 13
WHERE food_name = 'pumpkin_seeds';

-- Sunflower seeds (1 oz = 28g)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 3,
  protein_grams_per_serving = 5.5,
  fat_grams_per_serving = 14
WHERE food_name = 'sunflower_seeds';


-- =====================================================
-- PART 3: Update DEF_NUT_SEED_TYPE Field Reference
-- =====================================================

UPDATE data_entry_fields
SET
  reference_table = 'def_ref_food_types',
  description = 'Nut or seed type. References def_ref_food_types with category=nuts_seeds.'
WHERE field_id = 'DEF_NUT_SEED_TYPE';


-- =====================================================
-- PART 4: Archive Old Nut/Seed Types Table
-- =====================================================

-- Rename to indicate deprecated
ALTER TABLE def_ref_nut_seed_types
RENAME TO z_old_def_ref_nut_seed_types;

COMMENT ON TABLE z_old_def_ref_nut_seed_types IS
'DEPRECATED: Data migrated to def_ref_food_types with category=nuts_seeds. Kept for reference only.';


-- =====================================================
-- PART 5: Add Comments
-- =====================================================

COMMENT ON COLUMN def_ref_food_types.category_name IS
'Food category for filtering and grouping. Values: vegetables, fruits, whole_grains, legumes, nuts_seeds.
Each category corresponds to a recommendation tracking area and has average nutrition values for cross-population.';


COMMIT;
