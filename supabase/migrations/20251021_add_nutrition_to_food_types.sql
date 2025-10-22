-- =====================================================
-- Add Nutrition Metadata to Food Types Table
-- =====================================================
-- Adds nutrition content per serving to def_ref_food_types
-- Enables cross-population between category tracking and nutrition totals
--
-- Example: User logs "2 servings broccoli" in Vegetables
-- → Auto-populates: 8g fiber (2 × 4g), 5g protein (2 × 2.5g)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Nutrition Columns
-- =====================================================

ALTER TABLE def_ref_food_types
ADD COLUMN IF NOT EXISTS fiber_grams_per_serving NUMERIC,
ADD COLUMN IF NOT EXISTS protein_grams_per_serving NUMERIC,
ADD COLUMN IF NOT EXISTS fat_grams_per_serving NUMERIC;

-- Create index for category filtering
CREATE INDEX IF NOT EXISTS idx_food_types_category ON def_ref_food_types(category_name);


-- =====================================================
-- PART 2: Update Existing Foods with Nutrition Data
-- =====================================================

-- Vegetables (average 4g fiber, 2.5g protein per serving)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 4,
  protein_grams_per_serving = 2.5,
  fat_grams_per_serving = 0
WHERE category_name = 'vegetables';

-- Fruits (average 4g fiber, 1g protein per serving)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = 4,
  protein_grams_per_serving = 1,
  fat_grams_per_serving = 0
WHERE category_name = 'fruits';


-- =====================================================
-- PART 3: Add Whole Grains from CSV
-- =====================================================

INSERT INTO def_ref_food_types (
  food_name,
  display_name,
  category_name,
  description,
  fiber_grams_per_serving,
  protein_grams_per_serving,
  fat_grams_per_serving,
  default_serving_size,
  default_unit
) VALUES
('oats', 'Oats', 'whole_grains', 'Steel-cut oats, rolled oats, oatmeal', 5, 5, 3, 0.5, 'cup'),
('quinoa', 'Quinoa', 'whole_grains', 'All varieties of quinoa', 5, 8, 3.5, 0.5, 'cup'),
('brown_rice', 'Brown Rice', 'whole_grains', 'Brown rice, wild rice, black rice', 3.5, 5, 2, 0.5, 'cup'),
('whole_wheat', 'Whole Wheat', 'whole_grains', 'Whole wheat bread, pasta, flour products', 6, 8, 2, 1, 'slice'),
('barley', 'Barley', 'whole_grains', 'Pearled barley, hulled barley', 6, 3.5, 1, 0.5, 'cup'),
('buckwheat', 'Buckwheat', 'whole_grains', 'Buckwheat groats, buckwheat flour', 4.5, 6, 3, 0.5, 'cup'),
('millet', 'Millet', 'whole_grains', 'Whole millet grains', 2, 6, 4, 0.5, 'cup'),
('whole_grain_bread', 'Whole Grain Bread', 'whole_grains', '100% whole grain breads and products', 3, 4, 1.5, 1, 'slice'),
('farro', 'Farro', 'whole_grains', 'Ancient wheat grain farro', 5, 6, 1, 0.5, 'cup')
ON CONFLICT (food_name) DO UPDATE SET
  fiber_grams_per_serving = EXCLUDED.fiber_grams_per_serving,
  protein_grams_per_serving = EXCLUDED.protein_grams_per_serving,
  fat_grams_per_serving = EXCLUDED.fat_grams_per_serving;


-- =====================================================
-- PART 4: Add Legumes Nutrition (Already in table, add nutrition)
-- =====================================================

-- Legumes (average 12g fiber, 15g protein per serving)
UPDATE def_ref_food_types
SET
  fiber_grams_per_serving = CASE food_name
    WHEN 'lentils' THEN 15.6
    WHEN 'chickpeas' THEN 12.5
    WHEN 'black_beans' THEN 15
    WHEN 'kidney_beans' THEN 11
    WHEN 'pinto_beans' THEN 15
    WHEN 'navy_beans' THEN 19
    WHEN 'split_peas' THEN 16
    WHEN 'black_eyed_peas' THEN 11
    WHEN 'edamame' THEN 8
    WHEN 'green_peas' THEN 7
    ELSE 12 -- average
  END,
  protein_grams_per_serving = CASE food_name
    WHEN 'lentils' THEN 18
    WHEN 'chickpeas' THEN 14.5
    WHEN 'black_beans' THEN 15
    WHEN 'kidney_beans' THEN 15
    WHEN 'pinto_beans' THEN 15
    WHEN 'navy_beans' THEN 15
    WHEN 'split_peas' THEN 16
    WHEN 'black_eyed_peas' THEN 13
    WHEN 'edamame' THEN 18.5
    WHEN 'green_peas' THEN 8
    ELSE 15 -- average
  END,
  fat_grams_per_serving = CASE food_name
    WHEN 'edamame' THEN 8
    ELSE 1
  END
WHERE category_name = 'legumes'
  AND food_name IN ('lentils', 'chickpeas', 'black_beans', 'kidney_beans',
                    'pinto_beans', 'navy_beans', 'split_peas',
                    'black_eyed_peas', 'edamame', 'green_peas');


-- =====================================================
-- PART 5: Add Comments
-- =====================================================

COMMENT ON COLUMN def_ref_food_types.fiber_grams_per_serving IS
'Fiber content in grams per serving. Used by instance calculations for cross-population:
- User logs vegetables → auto-populates fiber intake
- User logs fiber from vegetables → auto-populates vegetable servings
Category averages: vegetables=4g, fruits=4g, whole_grains=5g, legumes=12g, nuts_seeds=4g';

COMMENT ON COLUMN def_ref_food_types.protein_grams_per_serving IS
'Protein content in grams per serving. Used for cross-population between food tracking and protein totals.';

COMMENT ON COLUMN def_ref_food_types.fat_grams_per_serving IS
'Fat content in grams per serving. Used for cross-population between food tracking and fat totals.';


COMMIT;
