-- =====================================================
-- Create ALL Data Entry Fields
-- =====================================================
-- Complete data_entry_fields based on display_metrics requirements
-- Implements refined architecture with specific tracking patterns
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Delete obsolete generic fields
-- =====================================================

-- Mark beverage fields as inactive (being replaced with specific tracking)
UPDATE data_entry_fields
SET is_active = false
WHERE field_id IN ('DEF_BEVERAGE_TYPE', 'DEF_BEVERAGE_QUANTITY');

-- Mark generic measurement fields as inactive (being replaced with specific biometrics)
UPDATE data_entry_fields
SET is_active = false
WHERE field_id IN ('DEF_MEASUREMENT_TYPE', 'DEF_MEASUREMENT_VALUE', 'DEF_MEASUREMENT_UNIT', 'DEF_MEASUREMENT_TIME');


-- =====================================================
-- PART 2: Add HIIT (split from cardio)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_HIIT_START', 'hiit_start_time', 'HIIT Start Time', 'Start time of HIIT workout', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_HIIT_END', 'hiit_end_time', 'HIIT End Time', 'End time of HIIT workout', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_HIIT_INTENSITY', 'hiit_intensity', 'HIIT Intensity', 'HIIT workout intensity rating (1-5)', 'rating', 'integer', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 3: Add Protein tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_PROTEIN_QUANTITY', 'protein_quantity', 'Protein Quantity', 'Amount of protein consumed', 'quantity', 'numeric', 'gram', true, NULL, false, '{"min": 0, "max": 200, "increment": 1}'::jsonb),
('DEF_PROTEIN_TYPE', 'protein_type', 'Protein Type', 'Type of protein source', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_PROTEIN_TIME', 'protein_time', 'Protein Consumption Time', 'When protein was consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Create protein types reference table
CREATE TABLE IF NOT EXISTS def_ref_protein_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  protein_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT, -- 'animal', 'plant', 'supplement'
  is_lean BOOLEAN DEFAULT false,
  is_processed BOOLEAN DEFAULT false,
  is_fish BOOLEAN DEFAULT false,
  is_red_meat BOOLEAN DEFAULT false,
  typical_serving_size NUMERIC DEFAULT 3, -- ounces
  typical_protein_grams NUMERIC, -- per serving
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert protein types
INSERT INTO def_ref_protein_types (protein_type_key, display_name, category, is_lean, is_processed, is_fish, is_red_meat, typical_protein_grams) VALUES
('fish', 'Fish', 'animal', true, false, true, false, 21),
('fatty_fish', 'Fatty Fish (Salmon, Mackerel)', 'animal', true, false, true, false, 22),
('lean_poultry', 'Lean Poultry', 'animal', true, false, false, false, 26),
('lean_beef', 'Lean Beef', 'animal', true, false, false, true, 26),
('red_meat', 'Red Meat', 'animal', false, false, false, true, 22),
('processed_meat', 'Processed Meat', 'animal', false, true, false, false, 15),
('eggs', 'Eggs', 'animal', true, false, false, false, 6),
('greek_yogurt', 'Greek Yogurt', 'animal', true, false, false, false, 17),
('cottage_cheese', 'Cottage Cheese', 'animal', true, false, false, false, 14),
('plant_protein', 'Plant-Based Protein', 'plant', true, false, false, false, 15),
('tofu', 'Tofu', 'plant', true, false, false, false, 10),
('tempeh', 'Tempeh', 'plant', true, false, false, false, 19),
('seitan', 'Seitan', 'plant', true, false, false, false, 21),
('protein_powder_whey', 'Whey Protein Powder', 'supplement', true, false, false, false, 25),
('protein_powder_plant', 'Plant Protein Powder', 'supplement', true, false, false, false, 20)
ON CONFLICT (protein_type_key) DO NOTHING;

-- Link to data_entry_fields
UPDATE data_entry_fields
SET reference_table = 'def_ref_protein_types'
WHERE field_id = 'DEF_PROTEIN_TYPE';


-- =====================================================
-- PART 4: Add Fat tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_FAT_QUANTITY', 'fat_quantity', 'Fat Quantity', 'Amount of fat consumed', 'quantity', 'numeric', 'gram', true, NULL, false, '{"min": 0, "max": 100, "increment": 0.5}'::jsonb),
('DEF_FAT_TYPE', 'fat_type', 'Fat Type', 'Type of fat consumed', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_FAT_TIME', 'fat_time', 'Fat Consumption Time', 'When fat was consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Create fat types reference table
CREATE TABLE IF NOT EXISTS def_ref_fat_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fat_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  fat_category TEXT, -- 'saturated', 'monounsaturated', 'polyunsaturated'
  is_healthy BOOLEAN DEFAULT true,
  omega_type TEXT, -- 'omega-3', 'omega-6', NULL
  typical_serving_size NUMERIC DEFAULT 1, -- tablespoons
  typical_fat_grams NUMERIC, -- per serving
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert fat types (link to existing food types where possible)
INSERT INTO def_ref_fat_types (fat_type_key, display_name, fat_category, is_healthy, omega_type, typical_fat_grams) VALUES
('olive_oil', 'Olive Oil', 'monounsaturated', true, NULL, 14),
('avocado_oil', 'Avocado Oil', 'monounsaturated', true, NULL, 14),
('avocado', 'Avocado', 'monounsaturated', true, NULL, 10),
('nuts_almonds', 'Almonds', 'monounsaturated', true, NULL, 14),
('nuts_walnuts', 'Walnuts', 'polyunsaturated', true, 'omega-3', 18),
('chia_seeds', 'Chia Seeds', 'polyunsaturated', true, 'omega-3', 9),
('flax_seeds', 'Flax Seeds', 'polyunsaturated', true, 'omega-3', 12),
('fatty_fish_oil', 'Fatty Fish (Omega-3)', 'polyunsaturated', true, 'omega-3', 10),
('vegetable_oil', 'Vegetable Oil', 'polyunsaturated', true, 'omega-6', 14),
('butter', 'Butter', 'saturated', false, NULL, 11),
('coconut_oil', 'Coconut Oil', 'saturated', false, NULL, 14),
('palm_oil', 'Palm Oil', 'saturated', false, NULL, 14),
('lard', 'Lard', 'saturated', false, NULL, 13)
ON CONFLICT (fat_type_key) DO NOTHING;

-- Link to data_entry_fields
UPDATE data_entry_fields
SET reference_table = 'def_ref_fat_types'
WHERE field_id = 'DEF_FAT_TYPE';


-- =====================================================
-- PART 5: Add Legumes tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_LEGUME_QUANTITY', 'legume_quantity', 'Legume Quantity', 'Servings of legumes consumed', 'quantity', 'numeric', 'serving', true, NULL, false, '{"min": 0, "max": 10, "increment": 0.5}'::jsonb),
('DEF_LEGUME_TYPE', 'legume_type', 'Legume Type', 'Type of legume consumed', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_LEGUME_TIME', 'legume_time', 'Legume Consumption Time', 'When legumes were consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Link to existing def_ref_food_types (category = 'legumes')
UPDATE data_entry_fields
SET reference_table = 'def_ref_food_types'
WHERE field_id = 'DEF_LEGUME_TYPE';


-- =====================================================
-- PART 6: Add Nuts/Seeds tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_NUT_SEED_QUANTITY', 'nut_seed_quantity', 'Nuts/Seeds Quantity', 'Servings of nuts or seeds consumed', 'quantity', 'numeric', 'serving', true, NULL, false, '{"min": 0, "max": 10, "increment": 0.25}'::jsonb),
('DEF_NUT_SEED_TYPE', 'nut_seed_type', 'Nuts/Seeds Type', 'Type of nut or seed consumed', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_NUT_SEED_TIME', 'nut_seed_time', 'Nuts/Seeds Consumption Time', 'When nuts/seeds were consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Create nuts/seeds reference table
CREATE TABLE IF NOT EXISTS def_ref_nut_seed_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nut_seed_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT, -- 'nut', 'seed'
  primary_fat_type TEXT, -- 'MUFA', 'PUFA', 'saturated'
  omega_type TEXT,
  typical_serving_size TEXT DEFAULT '1 oz (28g)',
  typical_calories NUMERIC,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_nut_seed_types (nut_seed_key, display_name, category, primary_fat_type, omega_type, typical_calories) VALUES
('almonds', 'Almonds', 'nut', 'MUFA', NULL, 160),
('walnuts', 'Walnuts', 'nut', 'PUFA', 'omega-3', 185),
('cashews', 'Cashews', 'nut', 'MUFA', NULL, 155),
('pecans', 'Pecans', 'nut', 'MUFA', NULL, 195),
('pistachios', 'Pistachios', 'nut', 'MUFA', NULL, 160),
('brazil_nuts', 'Brazil Nuts', 'nut', 'PUFA', NULL, 185),
('macadamia', 'Macadamia Nuts', 'nut', 'MUFA', NULL, 200),
('chia_seeds', 'Chia Seeds', 'seed', 'PUFA', 'omega-3', 140),
('flax_seeds', 'Flax Seeds', 'seed', 'PUFA', 'omega-3', 150),
('hemp_seeds', 'Hemp Seeds', 'seed', 'PUFA', 'omega-3', 170),
('pumpkin_seeds', 'Pumpkin Seeds', 'seed', 'PUFA', NULL, 150),
('sunflower_seeds', 'Sunflower Seeds', 'seed', 'PUFA', NULL, 165),
('sesame_seeds', 'Sesame Seeds', 'seed', 'PUFA', NULL, 160)
ON CONFLICT (nut_seed_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_nut_seed_types'
WHERE field_id = 'DEF_NUT_SEED_TYPE';


-- =====================================================
-- PART 7: Add Whole Grains tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_WHOLE_GRAIN_QUANTITY', 'whole_grain_quantity', 'Whole Grain Quantity', 'Servings of whole grains consumed', 'quantity', 'numeric', 'serving', true, NULL, false, '{"min": 0, "max": 10, "increment": 0.5}'::jsonb),
('DEF_WHOLE_GRAIN_TYPE', 'whole_grain_type', 'Whole Grain Type', 'Type of whole grain consumed', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_WHOLE_GRAIN_TIME', 'whole_grain_time', 'Whole Grain Consumption Time', 'When whole grains were consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Link to existing def_ref_food_types (category = 'whole_grains')
UPDATE data_entry_fields
SET reference_table = 'def_ref_food_types'
WHERE field_id = 'DEF_WHOLE_GRAIN_TYPE';


-- =====================================================
-- PART 8: Add Fruits tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_FRUIT_QUANTITY', 'fruit_quantity', 'Fruit Quantity', 'Servings of fruit consumed', 'quantity', 'numeric', 'serving', true, NULL, false, '{"min": 0, "max": 10, "increment": 0.5}'::jsonb),
('DEF_FRUIT_TYPE', 'fruit_type', 'Fruit Type', 'Type of fruit consumed', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_FRUIT_TIME', 'fruit_time', 'Fruit Consumption Time', 'When fruit was consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Link to existing def_ref_food_types (category = 'fruits')
UPDATE data_entry_fields
SET reference_table = 'def_ref_food_types'
WHERE field_id = 'DEF_FRUIT_TYPE';


-- =====================================================
-- PART 9: Add Vegetables tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_VEGETABLE_QUANTITY', 'vegetable_quantity', 'Vegetable Quantity', 'Servings of vegetables consumed', 'quantity', 'numeric', 'serving', true, NULL, false, '{"min": 0, "max": 15, "increment": 0.5}'::jsonb),
('DEF_VEGETABLE_TYPE', 'vegetable_type', 'Vegetable Type', 'Type of vegetable consumed', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_VEGETABLE_TIME', 'vegetable_time', 'Vegetable Consumption Time', 'When vegetables were consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Link to existing def_ref_food_types (category = 'vegetables')
UPDATE data_entry_fields
SET reference_table = 'def_ref_food_types'
WHERE field_id = 'DEF_VEGETABLE_TYPE';


-- =====================================================
-- PART 10: Add Fiber tracking (quantity + source + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_FIBER_QUANTITY', 'fiber_quantity', 'Fiber Quantity', 'Grams of fiber consumed', 'quantity', 'numeric', 'gram', true, NULL, false, '{"min": 0, "max": 100, "increment": 1}'::jsonb),
('DEF_FIBER_SOURCE', 'fiber_source', 'Fiber Source', 'Source of fiber consumed', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_FIBER_TIME', 'fiber_time', 'Fiber Consumption Time', 'When fiber was consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Link to existing def_ref_food_types (category = 'fibrous_foods')
UPDATE data_entry_fields
SET reference_table = 'def_ref_food_types'
WHERE field_id = 'DEF_FIBER_SOURCE';


-- =====================================================
-- PART 11: Add Caffeine tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_CAFFEINE_QUANTITY', 'caffeine_quantity', 'Caffeine Quantity', 'Milligrams of caffeine consumed', 'quantity', 'numeric', 'milligram', true, NULL, false, '{"min": 0, "max": 800, "increment": 10, "recommended_max": 400}'::jsonb),
('DEF_CAFFEINE_TYPE', 'caffeine_type', 'Caffeine Type', 'Source of caffeine', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_CAFFEINE_TIME', 'caffeine_time', 'Caffeine Consumption Time', 'When caffeine was consumed (CRITICAL for sleep buffer)', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Create caffeine types reference table
CREATE TABLE IF NOT EXISTS def_ref_caffeine_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  caffeine_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  typical_caffeine_mg NUMERIC, -- per serving
  typical_serving_size TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_caffeine_types (caffeine_type_key, display_name, typical_caffeine_mg, typical_serving_size) VALUES
('coffee_brewed', 'Brewed Coffee', 95, '8 oz cup'),
('coffee_espresso', 'Espresso', 63, '1 oz shot'),
('coffee_instant', 'Instant Coffee', 62, '8 oz cup'),
('tea_black', 'Black Tea', 47, '8 oz cup'),
('tea_green', 'Green Tea', 28, '8 oz cup'),
('tea_white', 'White Tea', 15, '8 oz cup'),
('tea_oolong', 'Oolong Tea', 37, '8 oz cup'),
('matcha', 'Matcha', 70, '8 oz serving'),
('energy_drink', 'Energy Drink', 80, '8 oz can'),
('soda_caffeinated', 'Caffeinated Soda', 34, '12 oz can'),
('pre_workout', 'Pre-Workout Supplement', 200, '1 scoop'),
('caffeine_pill', 'Caffeine Pill', 200, '1 pill')
ON CONFLICT (caffeine_type_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_caffeine_types'
WHERE field_id = 'DEF_CAFFEINE_TYPE';


-- =====================================================
-- PART 12: Add Alcohol tracking (quantity + type + time)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_ALCOHOL_QUANTITY', 'alcohol_quantity', 'Alcohol Quantity', 'Number of standard drinks consumed', 'quantity', 'numeric', 'drink', true, NULL, false, '{"min": 0, "max": 20, "increment": 0.5}'::jsonb),
('DEF_ALCOHOL_TYPE', 'alcohol_type', 'Alcohol Type', 'Type of alcoholic beverage', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_ALCOHOL_TIME', 'alcohol_time', 'Alcohol Consumption Time', 'When alcohol was consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Create alcohol types reference table
CREATE TABLE IF NOT EXISTS def_ref_alcohol_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  alcohol_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  typical_serving_size TEXT,
  standard_drinks_per_serving NUMERIC DEFAULT 1,
  abv_percentage NUMERIC, -- typical alcohol by volume
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_alcohol_types (alcohol_type_key, display_name, typical_serving_size, standard_drinks_per_serving, abv_percentage) VALUES
('beer_regular', 'Regular Beer', '12 oz', 1.0, 5),
('beer_light', 'Light Beer', '12 oz', 0.8, 4.2),
('beer_ipa', 'IPA/Craft Beer', '12 oz', 1.3, 6.5),
('wine_red', 'Red Wine', '5 oz', 1.0, 12),
('wine_white', 'White Wine', '5 oz', 1.0, 12),
('wine_sparkling', 'Sparkling Wine', '5 oz', 1.0, 12),
('spirits', 'Spirits (Vodka, Whiskey, etc)', '1.5 oz', 1.0, 40),
('cocktail_standard', 'Standard Cocktail', '1 drink', 1.5, NULL),
('cocktail_strong', 'Strong Cocktail', '1 drink', 2.0, NULL),
('hard_seltzer', 'Hard Seltzer', '12 oz', 1.0, 5)
ON CONFLICT (alcohol_type_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_alcohol_types'
WHERE field_id = 'DEF_ALCOHOL_TYPE';


-- =====================================================
-- PART 13: Add Unhealthy Beverages tracking
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_UNHEALTHY_BEV_QUANTITY', 'unhealthy_beverage_quantity', 'Unhealthy Beverage Quantity', 'Ounces of unhealthy beverage consumed', 'quantity', 'numeric', 'ounce', true, NULL, false, '{"min": 0, "max": 128, "increment": 1}'::jsonb),
('DEF_UNHEALTHY_BEV_TYPE', 'unhealthy_beverage_type', 'Unhealthy Beverage Type', 'Type of unhealthy beverage', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_UNHEALTHY_BEV_TIME', 'unhealthy_beverage_time', 'Unhealthy Beverage Time', 'When unhealthy beverage was consumed', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Create unhealthy beverage types reference table
CREATE TABLE IF NOT EXISTS def_ref_unhealthy_beverage_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  beverage_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  typical_serving_size TEXT,
  typical_sugar_grams NUMERIC, -- per serving
  has_caffeine BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_unhealthy_beverage_types (beverage_type_key, display_name, typical_serving_size, typical_sugar_grams, has_caffeine) VALUES
('soda_regular', 'Regular Soda', '12 oz can', 39, true),
('soda_diet', 'Diet Soda', '12 oz can', 0, true),
('juice_fruit', 'Fruit Juice', '8 oz glass', 24, false),
('sports_drink', 'Sports Drink', '20 oz bottle', 34, false),
('sweetened_tea', 'Sweetened Iced Tea', '16 oz', 36, true),
('lemonade', 'Lemonade', '8 oz glass', 25, false),
('flavored_water', 'Flavored Water (Sweetened)', '16 oz', 20, false),
('milkshake', 'Milkshake', '16 oz', 60, false),
('sweet_coffee', 'Sweetened Coffee Drink', '16 oz', 45, true)
ON CONFLICT (beverage_type_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_unhealthy_beverage_types'
WHERE field_id = 'DEF_UNHEALTHY_BEV_TYPE';


-- =====================================================
-- Summary and commit
-- =====================================================

DO $$
DECLARE
  active_count INT;
  nutrition_count INT;
BEGIN
  SELECT COUNT(*) INTO active_count FROM data_entry_fields WHERE is_active = true;
  SELECT COUNT(*) INTO nutrition_count FROM data_entry_fields WHERE is_active = true AND (
    field_id LIKE 'DEF_PROTEIN%' OR
    field_id LIKE 'DEF_FAT%' OR
    field_id LIKE 'DEF_LEGUME%' OR
    field_id LIKE 'DEF_NUT%' OR
    field_id LIKE 'DEF_WHOLE_GRAIN%' OR
    field_id LIKE 'DEF_FRUIT%' OR
    field_id LIKE 'DEF_VEGETABLE%' OR
    field_id LIKE 'DEF_FIBER%' OR
    field_id LIKE 'DEF_CAFFEINE%' OR
    field_id LIKE 'DEF_ALCOHOL%' OR
    field_id LIKE 'DEF_UNHEALTHY_BEV%'
  );

  RAISE NOTICE '==========================================='  ;
  RAISE NOTICE 'Data Entry Fields - Part 1 Complete';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total active data_entry_fields: %', active_count;
  RAISE NOTICE 'Nutrition-related fields: %', nutrition_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Added:';
  RAISE NOTICE '  - HIIT tracking (3 fields)';
  RAISE NOTICE '  - Protein tracking (3 fields + protein_types table)';
  RAISE NOTICE '  - Fat tracking (3 fields + fat_types table)';
  RAISE NOTICE '  - Legumes tracking (3 fields)';
  RAISE NOTICE '  - Nuts/Seeds tracking (3 fields + nut_seed_types table)';
  RAISE NOTICE '  - Whole Grains tracking (3 fields)';
  RAISE NOTICE '  - Fruits tracking (3 fields)';
  RAISE NOTICE '  - Vegetables tracking (3 fields)';
  RAISE NOTICE '  - Fiber tracking (3 fields)';
  RAISE NOTICE '  - Caffeine tracking (3 fields + caffeine_types table)';
  RAISE NOTICE '  - Alcohol tracking (3 fields + alcohol_types table)';
  RAISE NOTICE '  - Unhealthy Beverages (3 fields + beverage_types table)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Part 2 - Cognitive, Social, Core Care fields';
END $$;

COMMIT;
