-- =====================================================
-- Populate Nutrition Event Dependencies
-- =====================================================
-- Links event types to their:
-- 1. Field dependencies (which fields belong to the event)
-- 2. Calculation dependencies (which calculations run for the event)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Fiber Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('fiber_intake', 'field', 'DEF_FIBER_SOURCE', true, 1),
('fiber_intake', 'field', 'DEF_FIBER_TIME', true, 2),
('fiber_intake', 'field', 'DEF_FIBER_SERVINGS', false, 3),
('fiber_intake', 'field', 'DEF_FIBER_GRAMS', false, 4);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('fiber_intake', 'calculation', 'CALC_FIBER_SERVINGS_TO_GRAMS', false, 1),
('fiber_intake', 'calculation', 'CALC_FIBER_GRAMS_TO_SERVINGS', false, 2);


-- =====================================================
-- PART 2: Vegetable Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('vegetable_intake', 'field', 'DEF_VEGETABLE_TYPE', true, 1),
('vegetable_intake', 'field', 'DEF_VEGETABLE_QUANTITY', true, 2),
('vegetable_intake', 'field', 'DEF_VEGETABLE_TIME', true, 3);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('vegetable_intake', 'calculation', 'CALC_VEGETABLES_TO_FIBER', false, 1),
('vegetable_intake', 'calculation', 'CALC_VEGETABLE_TYPE_TO_NUTRITION', false, 2);


-- =====================================================
-- PART 3: Fruit Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('fruit_intake', 'field', 'DEF_FRUIT_TYPE', true, 1),
('fruit_intake', 'field', 'DEF_FRUIT_QUANTITY', true, 2),
('fruit_intake', 'field', 'DEF_FRUIT_TIME', true, 3);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('fruit_intake', 'calculation', 'CALC_FRUITS_TO_FIBER', false, 1),
('fruit_intake', 'calculation', 'CALC_FRUIT_TYPE_TO_NUTRITION', false, 2);


-- =====================================================
-- PART 4: Whole Grain Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('whole_grain_intake', 'field', 'DEF_WHOLE_GRAIN_TYPE', true, 1),
('whole_grain_intake', 'field', 'DEF_WHOLE_GRAIN_QUANTITY', true, 2),
('whole_grain_intake', 'field', 'DEF_WHOLE_GRAIN_TIME', true, 3);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('whole_grain_intake', 'calculation', 'CALC_WHOLE_GRAINS_TO_FIBER', false, 1),
('whole_grain_intake', 'calculation', 'CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION', false, 2);


-- =====================================================
-- PART 5: Legume Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('legume_intake', 'field', 'DEF_LEGUME_TYPE', true, 1),
('legume_intake', 'field', 'DEF_LEGUME_QUANTITY', true, 2),
('legume_intake', 'field', 'DEF_LEGUME_TIME', true, 3);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('legume_intake', 'calculation', 'CALC_LEGUMES_TO_FIBER_PROTEIN', false, 1),
('legume_intake', 'calculation', 'CALC_LEGUME_TYPE_TO_NUTRITION', false, 2);


-- =====================================================
-- PART 6: Nut/Seed Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('nut_seed_intake', 'field', 'DEF_NUT_SEED_TYPE', true, 1),
('nut_seed_intake', 'field', 'DEF_NUT_SEED_QUANTITY', true, 2),
('nut_seed_intake', 'field', 'DEF_NUT_SEED_TIME', true, 3);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('nut_seed_intake', 'calculation', 'CALC_NUTS_SEEDS_TO_NUTRITION', false, 1),
('nut_seed_intake', 'calculation', 'CALC_NUT_SEED_TYPE_TO_NUTRITION', false, 2);


-- =====================================================
-- PART 7: Protein Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('protein_intake', 'field', 'DEF_PROTEIN_TYPE', true, 1),
('protein_intake', 'field', 'DEF_PROTEIN_TIME', true, 2),
('protein_intake', 'field', 'DEF_PROTEIN_SERVINGS', false, 3),
('protein_intake', 'field', 'DEF_PROTEIN_GRAMS', false, 4);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('protein_intake', 'calculation', 'CALC_PROTEIN_SERVINGS_TO_GRAMS', false, 1),
('protein_intake', 'calculation', 'CALC_PROTEIN_GRAMS_TO_SERVINGS', false, 2);


-- =====================================================
-- PART 8: Fat Intake Event Dependencies
-- =====================================================

-- Field dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  data_entry_field_id,
  is_required,
  display_order
) VALUES
('fat_intake', 'field', 'DEF_FAT_TYPE', true, 1),
('fat_intake', 'field', 'DEF_FAT_TIME', true, 2),
('fat_intake', 'field', 'DEF_FAT_SERVINGS', false, 3),
('fat_intake', 'field', 'DEF_FAT_GRAMS', false, 4);

-- Calculation dependencies
INSERT INTO event_types_dependencies (
  event_type_id,
  dependency_type,
  instance_calculation_id,
  is_required,
  display_order
) VALUES
('fat_intake', 'calculation', 'CALC_FAT_SERVINGS_TO_GRAMS', false, 1),
('fat_intake', 'calculation', 'CALC_FAT_GRAMS_TO_SERVINGS', false, 2);


-- =====================================================
-- PART 9: Verify Dependencies
-- =====================================================

DO $$
DECLARE
  field_deps INT;
  calc_deps INT;
BEGIN
  SELECT COUNT(*) INTO field_deps
  FROM event_types_dependencies
  WHERE dependency_type = 'field';

  SELECT COUNT(*) INTO calc_deps
  FROM event_types_dependencies
  WHERE dependency_type = 'calculation';

  RAISE NOTICE 'Created % field dependencies', field_deps;
  RAISE NOTICE 'Created % calculation dependencies', calc_deps;
  RAISE NOTICE 'Total: % event dependencies', field_deps + calc_deps;
END $$;


COMMIT;
