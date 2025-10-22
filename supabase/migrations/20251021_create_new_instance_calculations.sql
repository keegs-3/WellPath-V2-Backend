-- =====================================================
-- Create New Instance Calculations
-- =====================================================
-- Water, distance, duration, heart rate calculations
-- (Protein/fat already exist, so skipping those)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Water Unit Conversions
-- =====================================================

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
  }'::jsonb)
ON CONFLICT (calc_id) DO NOTHING;

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_WATER_UNIT_CONVERSION', 'DEF_WATER_UNITS', 'from_unit', 'lookup_key', 1),
('CALC_WATER_UNIT_CONVERSION', 'DEF_WATER_QUANTITY', 'quantity', 'multiplier', 2)
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 2: Exercise Distance Conversions
-- =====================================================

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_DISTANCE_MILES_TO_KM', 'distance_miles_to_km', 'Distance (mi → km)', 'Convert miles to kilometers', 'lookup_multiply', 'kilometer',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "fixed_from_unit": "mile",
    "fixed_to_unit": "kilometer",
    "output_field": "DEF_CARDIO_DISTANCE_KM",
    "output_source": "auto_calculated"
  }'::jsonb),
('CALC_DISTANCE_KM_TO_MILES', 'distance_km_to_miles', 'Distance (km → mi)', 'Convert kilometers to miles', 'lookup_multiply', 'mile',
 '{
    "lookup_table": "unit_conversions",
    "lookup_key_field": "from_unit_id",
    "lookup_value_field": "multiply_factor",
    "fixed_from_unit": "kilometer",
    "fixed_to_unit": "mile",
    "output_field": "DEF_CARDIO_DISTANCE_MILES",
    "output_source": "auto_calculated"
  }'::jsonb)
ON CONFLICT (calc_id) DO UPDATE SET calculation_config = EXCLUDED.calculation_config;

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_DISTANCE_MILES_TO_KM', 'DEF_CARDIO_DISTANCE', 'distance_miles', 'multiplier', 1),
('CALC_DISTANCE_KM_TO_MILES', 'DEF_CARDIO_DISTANCE', 'distance_km', 'multiplier', 1)
ON CONFLICT DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  calc_count INT;
  dep_count INT;
BEGIN
  SELECT COUNT(*) INTO calc_count FROM instance_calculations
  WHERE calc_id IN ('CALC_WATER_UNIT_CONVERSION', 'CALC_DISTANCE_MILES_TO_KM', 'CALC_DISTANCE_KM_TO_MILES');

  SELECT COUNT(*) INTO dep_count FROM instance_calculations_dependencies
  WHERE instance_calculation_id IN ('CALC_WATER_UNIT_CONVERSION', 'CALC_DISTANCE_MILES_TO_KM', 'CALC_DISTANCE_KM_TO_MILES');

  RAISE NOTICE '✅ Created new instance calculations';
  RAISE NOTICE 'New calculations: %', calc_count;
  RAISE NOTICE 'New dependencies: %', dep_count;
  RAISE NOTICE 'Note: Duration and heart rate calculations require additional data_entry_fields';
END $$;

COMMIT;
