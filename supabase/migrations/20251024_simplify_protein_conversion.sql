-- =====================================================
-- Simplify Protein Conversion: Fixed 25g per serving
-- =====================================================
-- Removes lookup table complexity
-- Simple conversion: 1 serving = 25 grams
-- =====================================================

-- Update GRAMS → SERVINGS (divide by 25)
UPDATE instance_calculations
SET
  calculation_method = 'simple_conversion',
  formula_definition = 'grams ÷ 25',
  calculation_config = jsonb_build_object(
    'input_field', 'DEF_PROTEIN_GRAMS',
    'output_field', 'DEF_PROTEIN_SERVINGS',
    'operation', 'divide',
    'conversion_rate', 25,
    'output_source', 'auto_calculated'
  )
WHERE calc_id = 'CALC_PROTEIN_GRAMS_TO_SERVINGS';

-- Update SERVINGS → GRAMS (multiply by 25)
UPDATE instance_calculations
SET
  calculation_method = 'simple_conversion',
  formula_definition = 'servings × 25',
  calculation_config = jsonb_build_object(
    'input_field', 'DEF_PROTEIN_SERVINGS',
    'output_field', 'DEF_PROTEIN_GRAMS',
    'operation', 'multiply',
    'conversion_rate', 25,
    'output_source', 'auto_calculated'
  )
WHERE calc_id = 'CALC_PROTEIN_SERVINGS_TO_GRAMS';

-- Remove dependencies on DEF_PROTEIN_TYPE (no longer needed)
DELETE FROM instance_calculations_dependencies
WHERE calc_id IN ('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'CALC_PROTEIN_SERVINGS_TO_GRAMS')
  AND field_id = 'DEF_PROTEIN_TYPE';

-- Add correct dependencies
INSERT INTO instance_calculations_dependencies (calc_id, field_id, dependency_role, sequence_order)
VALUES
  ('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'DEF_PROTEIN_GRAMS', 'input', 1),
  ('CALC_PROTEIN_SERVINGS_TO_GRAMS', 'DEF_PROTEIN_SERVINGS', 'input', 1)
ON CONFLICT (calc_id, field_id, dependency_role) DO NOTHING;

-- Verification
SELECT
  calc_id,
  calculation_method,
  formula_definition,
  calculation_config->'conversion_rate' as rate,
  is_active
FROM instance_calculations
WHERE calc_id IN ('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'CALC_PROTEIN_SERVINGS_TO_GRAMS');
