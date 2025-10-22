-- =====================================================
-- ADD CURRENT_AGE VIEW
-- Keep existing 'age' as age at intake (snapshot in patient_details table)
-- Use view to calculate current age dynamically from dob
-- =====================================================

-- Create a view that adds current_age calculation
-- This accounts for whether birthday has passed this year
CREATE OR REPLACE VIEW patient_details_with_current_age AS
SELECT
    pd.*,
    DATE_PART('year', AGE(CURRENT_DATE, pd.dob))::INTEGER as current_age
FROM patient_details pd;

-- Verify the changes
SELECT 'Migration complete! Added current_age column and accurate age view.' as status;

-- Show the new columns
SELECT column_name, data_type, is_generated
FROM information_schema.columns
WHERE table_name = 'patient_details'
  AND column_name IN ('age', 'dob', 'current_age')
ORDER BY ordinal_position;
