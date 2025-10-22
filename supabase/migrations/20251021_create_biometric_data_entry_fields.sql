-- =====================================================
-- Create Biometric Data Entry Fields
-- =====================================================
-- Create all unit-specific and calculated biometric fields
-- needed for instance calculations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Weight Fields (both units)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, supports_healthkit_sync, validation_config)
VALUES
('DEF_WEIGHT_LB', 'weight_lb', 'Weight (lbs)', 'Weight in pounds', 'quantity', 'numeric', 'pound', true, false, '{"min": 50, "max": 500, "increment": 0.1}'::jsonb),
('DEF_WEIGHT_KG', 'weight_kg', 'Weight (kg)', 'Weight in kilograms', 'quantity', 'numeric', 'kilogram', true, false, '{"min": 20, "max": 250, "increment": 0.1}'::jsonb)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 2: Circumference Fields (both units)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, supports_healthkit_sync, validation_config)
VALUES
-- Waist
('DEF_WAIST_IN', 'waist_inches', 'Waist (inches)', 'Waist circumference in inches', 'quantity', 'numeric', 'inch', true, false, '{"min": 10, "max": 80, "increment": 0.25}'::jsonb),
('DEF_WAIST_CM', 'waist_cm', 'Waist (cm)', 'Waist circumference in centimeters', 'quantity', 'numeric', 'centimeter', true, false, '{"min": 25, "max": 200, "increment": 0.5}'::jsonb),

-- Hip
('DEF_HIP_IN', 'hip_inches', 'Hip (inches)', 'Hip circumference in inches', 'quantity', 'numeric', 'inch', true, false, '{"min": 10, "max": 80, "increment": 0.25}'::jsonb),
('DEF_HIP_CM', 'hip_cm', 'Hip (cm)', 'Hip circumference in centimeters', 'quantity', 'numeric', 'centimeter', true, false, '{"min": 25, "max": 200, "increment": 0.5}'::jsonb),

-- Neck
('DEF_NECK_CIRCUMFERENCE', 'neck_circumference', 'Neck Circumference', 'Neck circumference (for body fat calculation)', 'quantity', 'numeric', 'centimeter', true, false, '{"min": 20, "max": 60, "increment": 0.5}'::jsonb),
('DEF_NECK_IN', 'neck_inches', 'Neck (inches)', 'Neck circumference in inches', 'quantity', 'numeric', 'inch', true, false, '{"min": 8, "max": 24, "increment": 0.25}'::jsonb),
('DEF_NECK_CM', 'neck_cm', 'Neck (cm)', 'Neck circumference in centimeters', 'quantity', 'numeric', 'centimeter', true, false, '{"min": 20, "max": 60, "increment": 0.5}'::jsonb)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 3: Calculated Biometric Fields
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, supports_healthkit_sync, validation_config)
VALUES
('DEF_BMI', 'bmi', 'BMI', 'Body Mass Index (calculated)', 'quantity', 'numeric', 'kilograms_per_square_meter', true, false, '{"min": 10, "max": 60, "increment": 0.1}'::jsonb),
('DEF_BMR', 'bmr', 'BMR', 'Basal Metabolic Rate (calculated)', 'quantity', 'numeric', 'kilocalorie', true, false, '{"min": 800, "max": 3000, "increment": 1}'::jsonb),
('DEF_LEAN_BODY_MASS', 'lean_body_mass', 'Lean Body Mass', 'Lean body mass in kg (calculated)', 'quantity', 'numeric', 'kilogram', true, false, '{"min": 20, "max": 150, "increment": 0.1}'::jsonb),
('DEF_HIP_WAIST_RATIO', 'hip_waist_ratio', 'Hip-to-Waist Ratio', 'Hip to waist ratio (calculated)', 'quantity', 'numeric', NULL, true, false, '{"min": 0.5, "max": 2.0, "increment": 0.01}'::jsonb)
-- Note: DEF_BODY_FAT_PCT already exists, using that instead of creating DEF_BODY_FAT_PERCENTAGE
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 4: Supporting Fields (Age, Gender)
-- =====================================================
-- Note: These are already in patient_details, but may need to be in data_entry_fields for instance calculations

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, supports_healthkit_sync)
VALUES
('DEF_AGE', 'age', 'Age', 'Current age in years', 'quantity', 'integer', 'years', true, false),
('DEF_GENDER', 'gender', 'Gender', 'Biological sex for calculations', 'selection', 'text', NULL, true, false)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  new_fields_count INT;
BEGIN
  SELECT COUNT(*) INTO new_fields_count
  FROM data_entry_fields
  WHERE field_id IN ('DEF_WEIGHT_LB', 'DEF_WEIGHT_KG', 'DEF_WAIST_IN', 'DEF_WAIST_CM',
                     'DEF_HIP_IN', 'DEF_HIP_CM', 'DEF_NECK_IN', 'DEF_NECK_CM', 'DEF_NECK_CIRCUMFERENCE',
                     'DEF_BMI', 'DEF_BMR', 'DEF_BODY_FAT_PERCENTAGE', 'DEF_LEAN_BODY_MASS',
                     'DEF_HIP_WAIST_RATIO', 'DEF_AGE', 'DEF_GENDER');

  RAISE NOTICE '✅ Biometric data entry fields created';
  RAISE NOTICE 'Total biometric fields: %', new_fields_count;
END $$;

COMMIT;
