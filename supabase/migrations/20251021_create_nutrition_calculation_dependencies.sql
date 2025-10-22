-- =====================================================
-- Create Nutrition Instance Calculation Dependencies
-- =====================================================
-- Links instance_calculations to the data_entry_fields they depend on
-- Defines which calculations trigger when specific fields are entered
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Fiber Grams ↔ Servings Dependencies
-- =====================================================

-- CALC_FIBER_SERVINGS_TO_GRAMS triggers when user enters servings
-- Depends on: DEF_FIBER_SOURCE (to lookup grams/serving) + DEF_FIBER_SERVINGS (quantity)
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_FIBER_SERVINGS_TO_GRAMS', 'DEF_FIBER_SOURCE', 'source_type', 'lookup_key', 1),
('CALC_FIBER_SERVINGS_TO_GRAMS', 'DEF_FIBER_SERVINGS', 'quantity_servings', 'multiplier', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- CALC_FIBER_GRAMS_TO_SERVINGS triggers when user enters grams
-- Depends on: DEF_FIBER_SOURCE (to lookup grams/serving) + DEF_FIBER_GRAMS (quantity)
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_FIBER_GRAMS_TO_SERVINGS', 'DEF_FIBER_SOURCE', 'source_type', 'lookup_key', 1),
('CALC_FIBER_GRAMS_TO_SERVINGS', 'DEF_FIBER_GRAMS', 'quantity_grams', 'dividend', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 2: Vegetables → Fiber/Protein Dependencies
-- =====================================================

-- CALC_VEGETABLES_TO_FIBER triggers when user enters vegetable quantity
-- Depends on: DEF_VEGETABLE_QUANTITY (quantity to multiply by 4g)
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_VEGETABLES_TO_FIBER', 'DEF_VEGETABLE_QUANTITY', 'quantity_servings', 'multiplier', 1)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- CALC_VEGETABLE_TYPE_TO_NUTRITION triggers when user selects specific vegetable
-- Depends on: DEF_VEGETABLE_TYPE (lookup key) + DEF_VEGETABLE_QUANTITY (quantity)
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_VEGETABLE_TYPE_TO_NUTRITION', 'DEF_VEGETABLE_TYPE', 'food_type', 'lookup_key', 1),
('CALC_VEGETABLE_TYPE_TO_NUTRITION', 'DEF_VEGETABLE_QUANTITY', 'quantity_servings', 'multiplier', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 3: Fruits → Fiber Dependencies
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_FRUITS_TO_FIBER', 'DEF_FRUIT_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_FRUIT_TYPE_TO_NUTRITION', 'DEF_FRUIT_TYPE', 'food_type', 'lookup_key', 1),
('CALC_FRUIT_TYPE_TO_NUTRITION', 'DEF_FRUIT_QUANTITY', 'quantity_servings', 'multiplier', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 4: Whole Grains → Fiber/Protein Dependencies
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_WHOLE_GRAINS_TO_FIBER', 'DEF_WHOLE_GRAIN_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION', 'DEF_WHOLE_GRAIN_TYPE', 'food_type', 'lookup_key', 1),
('CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION', 'DEF_WHOLE_GRAIN_QUANTITY', 'quantity_servings', 'multiplier', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 5: Legumes → Fiber/Protein Dependencies
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_LEGUMES_TO_FIBER_PROTEIN', 'DEF_LEGUME_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_LEGUME_TYPE_TO_NUTRITION', 'DEF_LEGUME_TYPE', 'food_type', 'lookup_key', 1),
('CALC_LEGUME_TYPE_TO_NUTRITION', 'DEF_LEGUME_QUANTITY', 'quantity_servings', 'multiplier', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 6: Nuts/Seeds → Fiber/Protein/Fat Dependencies
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_NUTS_SEEDS_TO_NUTRITION', 'DEF_NUT_SEED_QUANTITY', 'quantity_servings', 'multiplier', 1),
('CALC_NUT_SEED_TYPE_TO_NUTRITION', 'DEF_NUT_SEED_TYPE', 'food_type', 'lookup_key', 1),
('CALC_NUT_SEED_TYPE_TO_NUTRITION', 'DEF_NUT_SEED_QUANTITY', 'quantity_servings', 'multiplier', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 7: Protein Grams ↔ Servings Dependencies
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_PROTEIN_SERVINGS_TO_GRAMS', 'DEF_PROTEIN_TYPE', 'protein_type', 'lookup_key', 1),
('CALC_PROTEIN_SERVINGS_TO_GRAMS', 'DEF_PROTEIN_SERVINGS', 'quantity_servings', 'multiplier', 2),
('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'DEF_PROTEIN_TYPE', 'protein_type', 'lookup_key', 1),
('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'DEF_PROTEIN_GRAMS', 'quantity_grams', 'dividend', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 8: Fat Grams ↔ Servings Dependencies
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
('CALC_FAT_SERVINGS_TO_GRAMS', 'DEF_FAT_TYPE', 'fat_type', 'lookup_key', 1),
('CALC_FAT_SERVINGS_TO_GRAMS', 'DEF_FAT_SERVINGS', 'quantity_servings', 'multiplier', 2),
('CALC_FAT_GRAMS_TO_SERVINGS', 'DEF_FAT_TYPE', 'fat_type', 'lookup_key', 1),
('CALC_FAT_GRAMS_TO_SERVINGS', 'DEF_FAT_GRAMS', 'quantity_grams', 'dividend', 2)
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- PART 9: Verify Dependencies
-- =====================================================

DO $$
DECLARE
  dep_count INT;
BEGIN
  SELECT COUNT(*) INTO dep_count
  FROM instance_calculations_dependencies icd
  JOIN instance_calculations ic ON icd.instance_calculation_id = ic.calc_id
  WHERE ic.calc_id LIKE 'CALC_%FIBER%'
     OR ic.calc_id LIKE 'CALC_%VEGETABLE%'
     OR ic.calc_id LIKE 'CALC_%FRUIT%'
     OR ic.calc_id LIKE 'CALC_%GRAIN%'
     OR ic.calc_id LIKE 'CALC_%LEGUME%'
     OR ic.calc_id LIKE 'CALC_%NUT%'
     OR ic.calc_id LIKE 'CALC_%PROTEIN%'
     OR ic.calc_id LIKE 'CALC_%FAT%';

  RAISE NOTICE 'Created % nutrition calculation dependencies', dep_count;
END $$;


COMMIT;
