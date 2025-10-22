-- =====================================================
-- Create Nutrition Instance Calculations
-- =====================================================
-- Implements cross-population architecture:
-- - Unit conversions (grams ↔ servings)
-- - Category auto-population (vegetables → fiber)
-- - Detailed food nutrition calculations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Fiber Grams ↔ Servings Conversions
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  unit_id,
  calculation_config
) VALUES
(
  'CALC_FIBER_SERVINGS_TO_GRAMS',
  'fiber_servings_to_grams',
  'Fiber Servings → Grams',
  'Converts fiber servings to grams based on source type (vegetables=4g, fruits=4g, whole_grains=5g, legumes=12g, nuts_seeds=4g, supplements=5g)',
  'lookup_multiply',
  'servings × def_ref_fiber_sources.fiber_grams_per_serving',
  false,
  true,
  'gram',
  '{
    "lookup_table": "def_ref_fiber_sources",
    "lookup_key_field": "source_key",
    "lookup_value_field": "fiber_grams_per_serving",
    "operation": "multiply",
    "output_field": "DEF_FIBER_GRAMS",
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_FIBER_GRAMS_TO_SERVINGS',
  'fiber_grams_to_servings',
  'Fiber Grams → Servings',
  'Converts fiber grams to servings based on source type',
  'lookup_divide',
  'grams ÷ def_ref_fiber_sources.fiber_grams_per_serving',
  false,
  true,
  'serving',
  '{
    "lookup_table": "def_ref_fiber_sources",
    "lookup_key_field": "source_key",
    "lookup_value_field": "fiber_grams_per_serving",
    "operation": "divide",
    "output_field": "DEF_FIBER_SERVINGS",
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


-- =====================================================
-- PART 2: Vegetables → Fiber/Protein Cross-Population
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES
(
  'CALC_VEGETABLES_TO_FIBER',
  'vegetables_to_fiber',
  'Vegetables → Fiber',
  'Auto-populates fiber tracking when vegetables are logged. Creates entries for DEF_FIBER_SOURCE, DEF_FIBER_SERVINGS, and DEF_FIBER_GRAMS.',
  'category_to_macro',
  'vegetable servings → fiber entries (source=vegetables, servings=same, grams=servings×4g)',
  false,
  true,
  '{
    "source_category": "vegetables",
    "target_macro": "fiber",
    "fiber_source_value": "vegetables",
    "grams_per_serving": 4,
    "output_fields": {
      "source": "DEF_FIBER_SOURCE",
      "servings": "DEF_FIBER_SERVINGS",
      "grams": "DEF_FIBER_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_VEGETABLE_TYPE_TO_NUTRITION',
  'vegetable_type_to_nutrition',
  'Vegetable Type → Nutrition',
  'Looks up specific vegetable in def_ref_food_types to populate exact fiber, protein, and fat values.',
  'food_lookup',
  'servings × def_ref_food_types[vegetable_type].(fiber|protein|fat)_grams_per_serving',
  false,
  true,
  '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "vegetables",
    "multiply_by_servings": true,
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


-- =====================================================
-- PART 3: Fruits → Fiber Cross-Population
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES
(
  'CALC_FRUITS_TO_FIBER',
  'fruits_to_fiber',
  'Fruits → Fiber',
  'Auto-populates fiber tracking when fruits are logged.',
  'category_to_macro',
  'fruit servings → fiber entries (source=fruits, servings=same, grams=servings×4g)',
  false,
  true,
  '{
    "source_category": "fruits",
    "target_macro": "fiber",
    "fiber_source_value": "fruits",
    "grams_per_serving": 4,
    "output_fields": {
      "source": "DEF_FIBER_SOURCE",
      "servings": "DEF_FIBER_SERVINGS",
      "grams": "DEF_FIBER_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_FRUIT_TYPE_TO_NUTRITION',
  'fruit_type_to_nutrition',
  'Fruit Type → Nutrition',
  'Looks up specific fruit in def_ref_food_types to populate exact nutrition values.',
  'food_lookup',
  'servings × def_ref_food_types[fruit_type].(fiber|protein|fat)_grams_per_serving',
  false,
  true,
  '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "fruits",
    "multiply_by_servings": true,
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


-- =====================================================
-- PART 4: Whole Grains → Fiber/Protein Cross-Population
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES
(
  'CALC_WHOLE_GRAINS_TO_FIBER',
  'whole_grains_to_fiber',
  'Whole Grains → Fiber',
  'Auto-populates fiber tracking when whole grains are logged.',
  'category_to_macro',
  'whole grain servings → fiber entries (source=whole_grains, servings=same, grams=servings×5g)',
  false,
  true,
  '{
    "source_category": "whole_grains",
    "target_macro": "fiber",
    "fiber_source_value": "whole_grains",
    "grams_per_serving": 5,
    "output_fields": {
      "source": "DEF_FIBER_SOURCE",
      "servings": "DEF_FIBER_SERVINGS",
      "grams": "DEF_FIBER_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION',
  'whole_grain_type_to_nutrition',
  'Whole Grain Type → Nutrition',
  'Looks up specific whole grain in def_ref_food_types to populate exact nutrition values.',
  'food_lookup',
  'servings × def_ref_food_types[whole_grain_type].(fiber|protein|fat)_grams_per_serving',
  false,
  true,
  '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "whole_grains",
    "multiply_by_servings": true,
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


-- =====================================================
-- PART 5: Legumes → Fiber/Protein Cross-Population
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES
(
  'CALC_LEGUMES_TO_FIBER_PROTEIN',
  'legumes_to_fiber_protein',
  'Legumes → Fiber/Protein',
  'Auto-populates fiber and protein tracking when legumes are logged.',
  'category_to_macro',
  'legume servings → fiber entries (source=legumes, grams=servings×12g) + protein entries',
  false,
  true,
  '{
    "source_category": "legumes",
    "target_macros": ["fiber", "protein"],
    "fiber_source_value": "legumes",
    "fiber_grams_per_serving": 12,
    "protein_grams_per_serving": 14.5,
    "output_fields": {
      "fiber_source": "DEF_FIBER_SOURCE",
      "fiber_servings": "DEF_FIBER_SERVINGS",
      "fiber_grams": "DEF_FIBER_GRAMS",
      "protein_grams": "DEF_PROTEIN_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_LEGUME_TYPE_TO_NUTRITION',
  'legume_type_to_nutrition',
  'Legume Type → Nutrition',
  'Looks up specific legume in def_ref_food_types to populate exact nutrition values.',
  'food_lookup',
  'servings × def_ref_food_types[legume_type].(fiber|protein|fat)_grams_per_serving',
  false,
  true,
  '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "legumes",
    "multiply_by_servings": true,
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


-- =====================================================
-- PART 6: Nuts/Seeds → Fiber/Protein/Fat Cross-Population
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES
(
  'CALC_NUTS_SEEDS_TO_NUTRITION',
  'nuts_seeds_to_nutrition',
  'Nuts/Seeds → Fiber/Protein/Fat',
  'Auto-populates fiber, protein, and fat tracking when nuts/seeds are logged.',
  'category_to_macro',
  'nut/seed servings → fiber (4g) + protein (6g) + fat (14g) entries',
  false,
  true,
  '{
    "source_category": "nuts_seeds",
    "target_macros": ["fiber", "protein", "fat"],
    "fiber_grams_per_serving": 4,
    "protein_grams_per_serving": 6,
    "fat_grams_per_serving": 14,
    "output_fields": {
      "fiber_source": "DEF_FIBER_SOURCE",
      "fiber_servings": "DEF_FIBER_SERVINGS",
      "fiber_grams": "DEF_FIBER_GRAMS",
      "protein_grams": "DEF_PROTEIN_GRAMS",
      "fat_grams": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_NUT_SEED_TYPE_TO_NUTRITION',
  'nut_seed_type_to_nutrition',
  'Nut/Seed Type → Nutrition',
  'Looks up specific nut/seed in def_ref_food_types to populate exact nutrition values.',
  'food_lookup',
  'servings × def_ref_food_types[nut_seed_type].(fiber|protein|fat)_grams_per_serving',
  false,
  true,
  '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "nuts_seeds",
    "multiply_by_servings": true,
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


-- =====================================================
-- PART 7: Protein Grams ↔ Servings Conversions
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  unit_id,
  calculation_config
) VALUES
(
  'CALC_PROTEIN_SERVINGS_TO_GRAMS',
  'protein_servings_to_grams',
  'Protein Servings → Grams',
  'Converts protein servings to grams based on protein type',
  'lookup_multiply',
  'servings × def_ref_protein_types.protein_grams_per_serving',
  false,
  true,
  'gram',
  '{
    "lookup_table": "def_ref_protein_types",
    "lookup_key_field": "protein_type_key",
    "lookup_value_field": "protein_grams_per_serving",
    "operation": "multiply",
    "output_field": "DEF_PROTEIN_GRAMS",
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_PROTEIN_GRAMS_TO_SERVINGS',
  'protein_grams_to_servings',
  'Protein Grams → Servings',
  'Converts protein grams to servings based on protein type',
  'lookup_divide',
  'grams ÷ def_ref_protein_types.protein_grams_per_serving',
  false,
  true,
  'serving',
  '{
    "lookup_table": "def_ref_protein_types",
    "lookup_key_field": "protein_type_key",
    "lookup_value_field": "protein_grams_per_serving",
    "operation": "divide",
    "output_field": "DEF_PROTEIN_SERVINGS",
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


-- =====================================================
-- PART 8: Fat Grams ↔ Servings Conversions
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  is_displayed_to_user,
  is_active,
  unit_id,
  calculation_config
) VALUES
(
  'CALC_FAT_SERVINGS_TO_GRAMS',
  'fat_servings_to_grams',
  'Fat Servings → Grams',
  'Converts fat servings to grams based on fat type',
  'lookup_multiply',
  'servings × def_ref_fat_types.fat_grams_per_serving',
  false,
  true,
  'gram',
  '{
    "lookup_table": "def_ref_fat_types",
    "lookup_key_field": "fat_type_key",
    "lookup_value_field": "fat_grams_per_serving",
    "operation": "multiply",
    "output_field": "DEF_FAT_GRAMS",
    "output_source": "auto_calculated"
  }'::jsonb
),
(
  'CALC_FAT_GRAMS_TO_SERVINGS',
  'fat_grams_to_servings',
  'Fat Grams → Servings',
  'Converts fat grams to servings based on fat type',
  'lookup_divide',
  'grams ÷ def_ref_fat_types.fat_grams_per_serving',
  false,
  true,
  'serving',
  '{
    "lookup_table": "def_ref_fat_types",
    "lookup_key_field": "fat_type_key",
    "lookup_value_field": "fat_grams_per_serving",
    "operation": "divide",
    "output_field": "DEF_FAT_SERVINGS",
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = now();


COMMIT;
