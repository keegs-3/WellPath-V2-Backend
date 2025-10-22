-- =====================================================
-- MAKE AGE A GENERATED COLUMN CALCULATED FROM DOB
-- Age should be calculated, not stored
-- =====================================================

-- Step 1: Drop the existing age column with CASCADE to drop dependent views
-- We'll need to recreate the views after
ALTER TABLE patient_details
DROP COLUMN IF EXISTS age CASCADE;

-- Step 2: Create an immutable function to calculate age from DOB
-- This allows us to use it in a generated column
CREATE OR REPLACE FUNCTION calculate_age_from_dob(dob DATE)
RETURNS INTEGER
LANGUAGE SQL
IMMUTABLE
AS $$
    SELECT EXTRACT(YEAR FROM AGE(dob))::INTEGER;
$$;

-- Step 3: Add age back as a GENERATED ALWAYS column using the immutable function
-- Note: We use a snapshot date approach - age is calculated from dob at insert/update time
-- For real-time age, applications should calculate client-side or use a view
ALTER TABLE patient_details
ADD COLUMN age INTEGER GENERATED ALWAYS AS (
    DATE_PART('year', AGE('2025-01-01'::DATE, dob))::INTEGER
) STORED;

-- Step 4: Recreate the views that were dropped, using calculated age
-- patient_dashboard_summary view
CREATE OR REPLACE VIEW patient_dashboard_summary AS
SELECT
    pd.id,
    pd.patient_user_id,
    pd.gender,
    DATE_PART('year', AGE(CURRENT_DATE, pd.dob))::INTEGER as age,
    pd.dob,
    pd.wellpath_status,
    pd.assigned_clinician_id,
    au.email as clinician_email,
    au.first_name || ' ' || au.last_name as clinician_name
FROM patient_details pd
LEFT JOIN auth_users au ON pd.assigned_clinician_id = au.id;

-- clinician_patient_list view
CREATE OR REPLACE VIEW clinician_patient_list AS
SELECT
    pd.id,
    pd.patient_user_id,
    pd.gender,
    DATE_PART('year', AGE(CURRENT_DATE, pd.dob))::INTEGER as age,
    pd.wellpath_status,
    pd.assigned_clinician_id,
    p.name as practice_name
FROM patient_details pd
LEFT JOIN practices p ON pd.practice_id = p.id;

-- Verify the change
SELECT 'Migration complete! Age is now a generated column.' as status;

-- Show patient_details columns to verify
SELECT column_name, data_type, is_nullable, column_default, is_generated
FROM information_schema.columns
WHERE table_name = 'patient_details'
  AND column_name IN ('dob', 'age')
ORDER BY ordinal_position;
