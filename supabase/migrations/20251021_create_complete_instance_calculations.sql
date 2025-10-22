-- =====================================================
-- Create Complete Instance Calculations
-- =====================================================
-- All instance calculations for:
-- - Unit conversions (protein, fat, water, distance)
-- - Category to macro (fruits, grains, legumes, nuts)
-- - Duration calculations (any timed event)
-- - Heart rate zones (placeholder)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Protein Unit Conversions
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_PROTEIN_SERVINGS_TO_GRAMS', 'protein_servings_to_grams', 'Protein (servings → g)', 'Convert protein servings to grams using source type lookup', 'lookup_multiply', 'gram',
 '{
    "lookup_table": "def_ref_protein_types",
    "lookup_key_field": "protein_type_key",
    "lookup_value_field": "protein_grams_per_serving",
    "operation": "multiply",
    "output_field": "DEF_PROTEIN_GRAMS",
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'protein_grams_to_servings', 'Protein (g → servings)', 'Convert protein grams to servings using source type lookup', 'lookup_divide', 'serving',
 '{
    "lookup_table": "def_ref_protein_types",
    "lookup_key_field": "protein_type_key",
    "lookup_value_field": "protein_grams_per_serving",
    "operation": "divide",
    "output_field": "DEF_PROTEIN_SERVINGS",
    "output_source": "auto_calculated"
  }'::jsonb);

-- Dependencies for protein conversions
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_PROTEIN_SERVINGS_TO_GRAMS', 'DEF_PROTEIN_TYPE', 'source_type', 'lookup_key', 1),
('CALC_PROTEIN_SERVINGS_TO_GRAMS', 'DEF_PROTEIN_SERVINGS', 'quantity_servings', 'multiplier', 2),
('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'DEF_PROTEIN_TYPE', 'source_type', 'lookup_key', 1),
('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'DEF_PROTEIN_GRAMS', 'quantity_grams', 'dividend', 2);


-- =====================================================
-- PART 2: Fat Unit Conversions
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_FAT_SERVINGS_TO_GRAMS', 'fat_servings_to_grams', 'Fat (servings → g)', 'Convert fat servings to grams using source type lookup', 'lookup_multiply', 'gram',
 '{
    "lookup_table": "def_ref_fat_sources",
    "lookup_key_field": "fat_source_key",
    "lookup_value_field": "fat_grams_per_serving",
    "operation": "multiply",
    "output_field": "DEF_FAT_GRAMS",
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_FAT_GRAMS_TO_SERVINGS', 'fat_grams_to_servings', 'Fat (g → servings)', 'Convert fat grams to servings using source type lookup', 'lookup_divide', 'serving',
 '{
    "lookup_table": "def_ref_fat_sources",
    "lookup_key_field": "fat_source_key",
    "lookup_value_field": "fat_grams_per_serving",
    "operation": "divide",
    "output_field": "DEF_FAT_SERVINGS",
    "output_source": "auto_calculated"
  }'::jsonb);

-- Dependencies for fat conversions
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_FAT_SERVINGS_TO_GRAMS', 'DEF_FAT_TYPE', 'source_type', 'lookup_key', 1),
('CALC_FAT_SERVINGS_TO_GRAMS', 'DEF_FAT_SERVINGS', 'quantity_servings', 'multiplier', 2),
('CALC_FAT_GRAMS_TO_SERVINGS', 'DEF_FAT_TYPE', 'source_type', 'lookup_key', 1),
('CALC_FAT_GRAMS_TO_SERVINGS', 'DEF_FAT_GRAMS', 'quantity_grams', 'dividend', 2);


-- =====================================================
-- PART 3: Water Unit Conversions
-- =====================================================
-- Uses existing unit_conversions table for all volume conversions

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_WATER_UNIT_CONVERSION', 'water_unit_conversion', 'Water Unit Conversion', 'Convert water between any volume units using unit_conversions table', 'lookup_multiply', NULL,
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "operation": "multiply",
    "output_field": "DEF_WATER_QUANTITY",
    "output_source": "auto_calculated",
    "notes": "Generic water conversion - uses from_unit and to_unit to look up conversion factor"
  }'::jsonb);

-- Dependencies for water conversion
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_WATER_UNIT_CONVERSION', 'DEF_WATER_UNIT', 'from_unit', 'lookup_key', 1),
('CALC_WATER_UNIT_CONVERSION', 'DEF_WATER_QUANTITY', 'quantity', 'multiplier', 2);


-- =====================================================
-- PART 4: Exercise Distance Conversions
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_DISTANCE_MILES_TO_KM', 'distance_miles_to_km', 'Distance (mi → km)', 'Convert miles to kilometers', 'lookup_multiply', 'kilometer',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "operation": "multiply",
    "output_field": "DEF_EXERCISE_DISTANCE_KM",
    "output_source": "auto_calculated",
    "fixed_from_unit": "mile",
    "fixed_to_unit": "kilometer"
  }'::jsonb),
('CALC_DISTANCE_KM_TO_MILES', 'distance_km_to_miles', 'Distance (km → mi)', 'Convert kilometers to miles', 'lookup_multiply', 'mile',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "operation": "multiply",
    "output_field": "DEF_EXERCISE_DISTANCE_MILES",
    "output_source": "auto_calculated",
    "fixed_from_unit": "kilometer",
    "fixed_to_unit": "mile"
  }'::jsonb);

-- Dependencies for distance conversions
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_DISTANCE_MILES_TO_KM', 'DEF_EXERCISE_DISTANCE_MILES', 'distance_miles', 'multiplier', 1),
('CALC_DISTANCE_KM_TO_MILES', 'DEF_EXERCISE_DISTANCE_KM', 'distance_km', 'multiplier', 1);


-- =====================================================
-- PART 5: Category to Macro - Fruits
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_FRUITS_TO_FIBER', 'fruits_to_fiber', 'Fruits → Fiber', 'Convert fruit servings to fiber entries', 'category_to_macro', 'gram',
 '{
    "target_macro": "fiber",
    "source_category": "fruits",
    "grams_per_serving": 3,
    "fiber_source_value": "fruits",
    "output_fields": {
      "source": "DEF_FIBER_SOURCE",
      "servings": "DEF_FIBER_SERVINGS",
      "grams": "DEF_FIBER_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_FRUIT_TYPE_TO_NUTRITION', 'fruit_type_to_nutrition', 'Fruit Nutrition Lookup', 'Lookup specific fruit nutrition data', 'food_lookup', NULL,
 '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "fruits",
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated",
    "multiply_by_servings": true
  }'::jsonb);

-- Dependencies for fruit calculations
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_FRUITS_TO_FIBER', 'DEF_FRUIT_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_FRUIT_TYPE_TO_NUTRITION', 'DEF_FRUIT_TYPE', 'food_type', 'lookup_key', 1),
('CALC_FRUIT_TYPE_TO_NUTRITION', 'DEF_FRUIT_QUANTITY', 'quantity_servings', 'multiplier', 2);


-- =====================================================
-- PART 6: Category to Macro - Whole Grains
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_WHOLE_GRAINS_TO_FIBER', 'whole_grains_to_fiber', 'Whole Grains → Fiber', 'Convert whole grain servings to fiber entries', 'category_to_macro', 'gram',
 '{
    "target_macro": "fiber",
    "source_category": "whole_grains",
    "grams_per_serving": 3,
    "fiber_source_value": "whole_grains",
    "output_fields": {
      "source": "DEF_FIBER_SOURCE",
      "servings": "DEF_FIBER_SERVINGS",
      "grams": "DEF_FIBER_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION', 'whole_grain_type_to_nutrition', 'Whole Grain Nutrition Lookup', 'Lookup specific whole grain nutrition data', 'food_lookup', NULL,
 '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "whole_grains",
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated",
    "multiply_by_servings": true
  }'::jsonb);

-- Dependencies for whole grain calculations
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_WHOLE_GRAINS_TO_FIBER', 'DEF_WHOLE_GRAIN_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION', 'DEF_WHOLE_GRAIN_TYPE', 'food_type', 'lookup_key', 1),
('CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION', 'DEF_WHOLE_GRAIN_QUANTITY', 'quantity_servings', 'multiplier', 2);


-- =====================================================
-- PART 7: Category to Macro - Legumes
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_LEGUMES_TO_FIBER_PROTEIN', 'legumes_to_fiber_protein', 'Legumes → Fiber + Protein', 'Convert legume servings to fiber and protein entries', 'category_to_macro', 'gram',
 '{
    "target_macro": "fiber_protein",
    "source_category": "legumes",
    "grams_per_serving": 8,
    "fiber_source_value": "legumes",
    "protein_grams_per_serving": 7,
    "output_fields": {
      "source": "DEF_FIBER_SOURCE",
      "servings": "DEF_FIBER_SERVINGS",
      "grams": "DEF_FIBER_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_LEGUME_TYPE_TO_NUTRITION', 'legume_type_to_nutrition', 'Legume Nutrition Lookup', 'Lookup specific legume nutrition data', 'food_lookup', NULL,
 '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "legumes",
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated",
    "multiply_by_servings": true
  }'::jsonb);

-- Dependencies for legume calculations
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_LEGUMES_TO_FIBER_PROTEIN', 'DEF_LEGUME_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_LEGUME_TYPE_TO_NUTRITION', 'DEF_LEGUME_TYPE', 'food_type', 'lookup_key', 1),
('CALC_LEGUME_TYPE_TO_NUTRITION', 'DEF_LEGUME_QUANTITY', 'quantity_servings', 'multiplier', 2);


-- =====================================================
-- PART 8: Category to Macro - Nuts & Seeds
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_NUTS_SEEDS_TO_NUTRITION', 'nuts_seeds_to_nutrition', 'Nuts/Seeds → Nutrition', 'Convert nut/seed servings to fiber, protein, and fat entries', 'category_to_macro', 'gram',
 '{
    "target_macro": "fiber_protein_fat",
    "source_category": "nuts_seeds",
    "grams_per_serving": 3,
    "fiber_source_value": "nuts_seeds",
    "protein_grams_per_serving": 6,
    "fat_grams_per_serving": 14,
    "output_fields": {
      "source": "DEF_FIBER_SOURCE",
      "servings": "DEF_FIBER_SERVINGS",
      "grams": "DEF_FIBER_GRAMS"
    },
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_NUT_SEED_TYPE_TO_NUTRITION', 'nut_seed_type_to_nutrition', 'Nut/Seed Nutrition Lookup', 'Lookup specific nut/seed nutrition data', 'food_lookup', NULL,
 '{
    "lookup_table": "def_ref_food_types",
    "lookup_key_field": "food_name",
    "category_filter": "nuts_seeds",
    "output_mappings": {
      "fiber_grams_per_serving": "DEF_FIBER_GRAMS",
      "protein_grams_per_serving": "DEF_PROTEIN_GRAMS",
      "fat_grams_per_serving": "DEF_FAT_GRAMS"
    },
    "output_source": "auto_calculated",
    "multiply_by_servings": true
  }'::jsonb);

-- Dependencies for nut/seed calculations
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_NUTS_SEEDS_TO_NUTRITION', 'DEF_NUT_SEED_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_NUT_SEED_TYPE_TO_NUTRITION', 'DEF_NUT_SEED_TYPE', 'food_type', 'lookup_key', 1),
('CALC_NUT_SEED_TYPE_TO_NUTRITION', 'DEF_NUT_SEED_QUANTITY', 'quantity_servings', 'multiplier', 2);


-- =====================================================
-- PART 9: Duration Calculations (Generic)
-- =====================================================

-- Sleep duration
INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_SLEEP_DURATION', 'sleep_duration', 'Sleep Duration', 'Calculate sleep duration from start and end times', 'calculate_duration', 'minute',
 '{
    "output_field": "DEF_SLEEP_DURATION",
    "output_source": "auto_calculated",
    "output_unit": "minute"
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_SLEEP_DURATION', 'DEF_SLEEP_START', 'start_time', 'start_time', 1),
('CALC_SLEEP_DURATION', 'DEF_SLEEP_END', 'end_time', 'end_time', 2);

-- Exercise duration
INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_EXERCISE_DURATION', 'exercise_duration', 'Exercise Duration', 'Calculate exercise duration from start and end times', 'calculate_duration', 'minute',
 '{
    "output_field": "DEF_EXERCISE_DURATION",
    "output_source": "auto_calculated",
    "output_unit": "minute"
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_EXERCISE_DURATION', 'DEF_EXERCISE_START', 'start_time', 'start_time', 1),
('CALC_EXERCISE_DURATION', 'DEF_EXERCISE_END', 'end_time', 'end_time', 2);

-- Meditation duration
INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_MEDITATION_DURATION', 'meditation_duration', 'Meditation Duration', 'Calculate meditation duration from start and end times', 'calculate_duration', 'minute',
 '{
    "output_field": "DEF_MEDITATION_DURATION",
    "output_source": "auto_calculated",
    "output_unit": "minute"
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_MEDITATION_DURATION', 'DEF_MEDITATION_START', 'start_time', 'start_time', 1),
('CALC_MEDITATION_DURATION', 'DEF_MEDITATION_END', 'end_time', 'end_time', 2);


-- =====================================================
-- PART 10: Heart Rate Zones (Placeholder)
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_HEART_RATE_ZONES', 'heart_rate_zones', 'Heart Rate Zones', 'Calculate time spent in each heart rate zone during exercise', 'calculate_heart_rate_zones', 'minute',
 '{
    "output_fields": {
      "zone1": "DEF_HR_ZONE1_MINUTES",
      "zone2": "DEF_HR_ZONE2_MINUTES",
      "zone3": "DEF_HR_ZONE3_MINUTES",
      "zone4": "DEF_HR_ZONE4_MINUTES",
      "zone5": "DEF_HR_ZONE5_MINUTES"
    },
    "output_source": "auto_calculated",
    "notes": "Requires heart rate data points - implementation pending"
  }'::jsonb);


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  calc_count INT;
  dep_count INT;
BEGIN
  SELECT COUNT(*) INTO calc_count FROM instance_calculations;
  SELECT COUNT(*) INTO dep_count FROM instance_calculations_dependencies;

  RAISE NOTICE '✅ Created instance calculations';
  RAISE NOTICE 'Total calculations: %', calc_count;
  RAISE NOTICE 'Total dependencies: %', dep_count;
END $$;

COMMIT;
