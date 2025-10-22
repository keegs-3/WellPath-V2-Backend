-- =====================================================
-- Create Biometric Unit Conversion Calculations
-- =====================================================
-- Unit conversions for biometric measurements:
-- - Weight: pounds ↔ kg
-- - Height: inches/feet ↔ cm/m
-- - Circumferences: inches ↔ cm
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Weight Conversions
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_WEIGHT_LB_TO_KG', 'weight_lb_to_kg', 'Weight (lb → kg)', 'Convert weight from pounds to kilograms', 'lookup_multiply', 'kilogram',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "fixed_from_unit": "pound",
    "fixed_to_unit": "kilogram",
    "output_field": "DEF_WEIGHT_KG",
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_WEIGHT_KG_TO_LB', 'weight_kg_to_lb', 'Weight (kg → lb)', 'Convert weight from kilograms to pounds', 'lookup_multiply', 'pound',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "fixed_from_unit": "kilogram",
    "fixed_to_unit": "pound",
    "output_field": "DEF_WEIGHT_LB",
    "output_source": "auto_calculated"
  }'::jsonb);

-- Dependencies for weight conversions
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_WEIGHT_LB_TO_KG', 'DEF_WEIGHT_LB', 'weight_lb', 'multiplier', 1),
('CALC_WEIGHT_KG_TO_LB', 'DEF_WEIGHT_KG', 'weight_kg', 'multiplier', 1);


-- =====================================================
-- PART 2: Circumference Conversions
-- =====================================================
-- Height is stored in both cm and inches, not calculated

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_WAIST_IN_TO_CM', 'waist_in_to_cm', 'Waist (in → cm)', 'Convert waist circumference from inches to centimeters', 'lookup_multiply', 'centimeter',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "fixed_from_unit": "inch",
    "fixed_to_unit": "centimeter",
    "output_field": "DEF_WAIST_CM",
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_HIP_IN_TO_CM', 'hip_in_to_cm', 'Hip (in → cm)', 'Convert hip circumference from inches to centimeters', 'lookup_multiply', 'centimeter',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "fixed_from_unit": "inch",
    "fixed_to_unit": "centimeter",
    "output_field": "DEF_HIP_CM",
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_NECK_IN_TO_CM', 'neck_in_to_cm', 'Neck (in → cm)', 'Convert neck circumference from inches to centimeters', 'lookup_multiply', 'centimeter',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "fixed_from_unit": "inch",
    "fixed_to_unit": "centimeter",
    "output_field": "DEF_NECK_CM",
    "output_source": "auto_calculated"
  }'::jsonb);

-- Dependencies for circumference conversions
INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_WAIST_IN_TO_CM', 'DEF_WAIST_IN', 'waist_in', 'multiplier', 1),
('CALC_HIP_IN_TO_CM', 'DEF_HIP_IN', 'hip_in', 'multiplier', 1),
('CALC_NECK_IN_TO_CM', 'DEF_NECK_IN', 'neck_in', 'multiplier', 1);


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  calc_count INT;
BEGIN
  SELECT COUNT(*) INTO calc_count
  FROM instance_calculations
  WHERE calc_name LIKE '%_to_%' AND (calc_name LIKE 'weight%' OR calc_name LIKE '%_in_to_cm');

  RAISE NOTICE '✅ Created % biometric unit conversion calculations', calc_count;
  RAISE NOTICE 'Note: Height conversions are NOT included - height is stored in both cm and inches';
END $$;

COMMIT;
