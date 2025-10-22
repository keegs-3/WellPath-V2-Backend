-- =====================================================
-- Create Biometric Instance Calculations
-- =====================================================
-- Calculated biometrics like BMI, Hip-to-Waist Ratio, etc.
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: BMI Calculation
-- =====================================================
-- BMI = weight (kg) / height (m)²

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_BMI', 'calculate_bmi', 'BMI', 'Calculate BMI from weight and height', 'calculate_formula', 'kilograms_per_square_meter',
 '{
    "formula": "weight_kg / (height_m * height_m)",
    "output_field": "DEF_BMI",
    "output_source": "auto_calculated",
    "rounding": 1
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_BMI', 'DEF_WEIGHT', 'weight_kg', 'input', 1),
('CALC_BMI', 'DEF_HEIGHT', 'height_m', 'input', 2);


-- =====================================================
-- PART 2: Hip-to-Waist Ratio
-- =====================================================
-- Hip-to-Waist Ratio = waist circumference / hip circumference

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_HIP_WAIST_RATIO', 'calculate_hip_waist_ratio', 'Hip-to-Waist Ratio', 'Calculate hip-to-waist ratio from measurements', 'calculate_formula', NULL,
 '{
    "formula": "waist_cm / hip_cm",
    "output_field": "DEF_HIP_WAIST_RATIO",
    "output_source": "auto_calculated",
    "rounding": 2
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_HIP_WAIST_RATIO', 'DEF_WAIST_CIRCUMFERENCE', 'waist_cm', 'input', 1),
('CALC_HIP_WAIST_RATIO', 'DEF_HIP_CIRCUMFERENCE', 'hip_cm', 'input', 2);


-- =====================================================
-- PART 3: BMR (Basal Metabolic Rate)
-- =====================================================
-- Mifflin-St Jeor Equation:
-- Men: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + 5
-- Women: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) - 161

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_BMR', 'calculate_bmr', 'BMR', 'Calculate Basal Metabolic Rate using Mifflin-St Jeor equation', 'calculate_formula', 'kilocalorie',
 '{
    "formula": "gender_based_bmr",
    "output_field": "DEF_BMR",
    "output_source": "auto_calculated",
    "rounding": 0,
    "notes": "Requires weight (kg), height (cm), age (years), and gender"
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_BMR', 'DEF_WEIGHT', 'weight_kg', 'input', 1),
('CALC_BMR', 'DEF_HEIGHT', 'height_cm', 'input', 2),
('CALC_BMR', 'DEF_AGE', 'age_years', 'input', 3),
('CALC_BMR', 'DEF_GENDER', 'gender', 'input', 4);


-- =====================================================
-- PART 4: Body Fat Percentage (US Navy Method)
-- =====================================================
-- Men: 86.010 × log10(abdomen - neck) - 70.041 × log10(height) + 36.76
-- Women: 163.205 × log10(waist + hip - neck) - 97.684 × log10(height) - 78.387

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_BODY_FAT_PERCENTAGE', 'calculate_body_fat', 'Body Fat %', 'Calculate body fat percentage using US Navy method', 'calculate_formula', 'percent',
 '{
    "formula": "gender_based_navy_bodyfat",
    "output_field": "DEF_BODY_FAT_PCT",
    "output_source": "auto_calculated",
    "rounding": 1,
    "notes": "Requires neck, waist, hip (women only), height, and gender"
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_BODY_FAT_PERCENTAGE', 'DEF_NECK_CIRCUMFERENCE', 'neck_cm', 'input', 1),
('CALC_BODY_FAT_PERCENTAGE', 'DEF_WAIST_CIRCUMFERENCE', 'waist_cm', 'input', 2),
('CALC_BODY_FAT_PERCENTAGE', 'DEF_HIP_CIRCUMFERENCE', 'hip_cm', 'input', 3),
('CALC_BODY_FAT_PERCENTAGE', 'DEF_HEIGHT', 'height_cm', 'input', 4),
('CALC_BODY_FAT_PERCENTAGE', 'DEF_GENDER', 'gender', 'input', 5);


-- =====================================================
-- PART 5: Lean Body Mass
-- =====================================================
-- LBM = Weight × (1 - (Body Fat % / 100))

INSERT INTO instance_calculations (calc_id, calc_name, display_name, description, calculation_method, unit_id, calculation_config)
VALUES
('CALC_LEAN_BODY_MASS', 'calculate_lean_body_mass', 'Lean Body Mass', 'Calculate lean body mass from weight and body fat percentage', 'calculate_formula', 'kilogram',
 '{
    "formula": "weight_kg * (1 - (bodyfat_percent / 100))",
    "output_field": "DEF_LEAN_BODY_MASS",
    "output_source": "auto_calculated",
    "rounding": 1
  }'::jsonb);

INSERT INTO instance_calculations_dependencies (instance_calculation_id, data_entry_field_id, parameter_name, parameter_role, parameter_order)
VALUES
('CALC_LEAN_BODY_MASS', 'DEF_WEIGHT', 'weight_kg', 'input', 1),
('CALC_LEAN_BODY_MASS', 'DEF_BODY_FAT_PCT', 'bodyfat_percent', 'input', 2);


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  calc_count INT;
BEGIN
  SELECT COUNT(*) INTO calc_count
  FROM instance_calculations
  WHERE calculation_method = 'calculate_formula';

  RAISE NOTICE '✅ Created % biometric calculations', calc_count;
END $$;

COMMIT;
