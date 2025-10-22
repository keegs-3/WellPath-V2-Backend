-- =====================================================
-- Convert survey_response_options.score to numeric
-- =====================================================
-- Changes 'custom_calc' to NULL and converts column to numeric
--
-- Created: 2025-10-18
-- =====================================================

BEGIN;

-- Step 1: Replace 'custom_calc' with NULL
UPDATE survey_response_options
SET score = NULL
WHERE score = 'custom_calc';

-- Step 2: Convert column type to numeric using USING clause
ALTER TABLE survey_response_options
ALTER COLUMN score TYPE numeric USING score::numeric;

-- Verification
DO $$
DECLARE
  custom_calc_count int;
  null_count int;
  numeric_count int;
BEGIN
  SELECT COUNT(*) INTO custom_calc_count
  FROM survey_response_options
  WHERE score::text = 'custom_calc';

  SELECT COUNT(*) INTO null_count
  FROM survey_response_options
  WHERE score IS NULL;

  SELECT COUNT(*) INTO numeric_count
  FROM survey_response_options
  WHERE score IS NOT NULL;

  RAISE NOTICE '✅ Conversion complete:';
  RAISE NOTICE '  - custom_calc values: %', custom_calc_count;
  RAISE NOTICE '  - NULL values: %', null_count;
  RAISE NOTICE '  - Numeric values: %', numeric_count;
END $$;

COMMIT;

COMMENT ON COLUMN survey_response_options.score IS
'Numeric score value (0-1 scale). NULL for custom calculated responses that require function evaluation.';
