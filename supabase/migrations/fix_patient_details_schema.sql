-- =====================================================
-- FIX PATIENT_DETAILS SCHEMA - ADD PROPER MULTI-TENANT ARCHITECTURE
-- =====================================================

-- Step 1: Add practice_id column to patient_details
ALTER TABLE patient_details
ADD COLUMN IF NOT EXISTS practice_id UUID;

-- Step 2: Backfill practice_id from assigned_clinician's practice
-- (Assumes patients should be in same practice as their clinician)
UPDATE patient_details pd
SET practice_id = au.practice_id
FROM auth_users au
WHERE pd.assigned_clinician_id = au.id
AND pd.practice_id IS NULL;

-- Step 3: Make practice_id NOT NULL (after backfill)
ALTER TABLE patient_details
ALTER COLUMN practice_id SET NOT NULL;

-- Step 4: Add foreign key constraint
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_patient_details_practice') THEN
        ALTER TABLE patient_details ADD CONSTRAINT fk_patient_details_practice
            FOREIGN KEY (practice_id) REFERENCES practices(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Step 5: Add practice_id to auth_users if it doesn't exist
ALTER TABLE auth_users
ADD COLUMN IF NOT EXISTS practice_id UUID;

-- Step 6: Add foreign key for auth_users.practice_id
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_auth_users_practice') THEN
        ALTER TABLE auth_users ADD CONSTRAINT fk_auth_users_practice
            FOREIGN KEY (practice_id) REFERENCES practices(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Step 7: Create function to validate patient and clinician are in same practice
CREATE OR REPLACE FUNCTION validate_patient_clinician_same_practice()
RETURNS TRIGGER AS $$
DECLARE
    clinician_practice_id UUID;
BEGIN
    -- If no clinician assigned, allow it
    IF NEW.assigned_clinician_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Get the clinician's practice_id
    SELECT practice_id INTO clinician_practice_id
    FROM auth_users
    WHERE id = NEW.assigned_clinician_id;

    -- Check if clinician exists and is in same practice
    IF clinician_practice_id IS NULL THEN
        RAISE EXCEPTION 'Assigned clinician does not exist';
    END IF;

    IF clinician_practice_id != NEW.practice_id THEN
        RAISE EXCEPTION 'Patient and assigned clinician must be in the same practice';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 8: Create trigger to enforce the constraint
DROP TRIGGER IF EXISTS check_patient_clinician_same_practice ON patient_details;
CREATE TRIGGER check_patient_clinician_same_practice
    BEFORE INSERT OR UPDATE ON patient_details
    FOR EACH ROW
    EXECUTE FUNCTION validate_patient_clinician_same_practice();

-- Step 8: Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_patient_details_practice_id ON patient_details(practice_id);
CREATE INDEX IF NOT EXISTS idx_patient_details_assigned_clinician ON patient_details(assigned_clinician_id);
CREATE INDEX IF NOT EXISTS idx_auth_users_practice_id ON auth_users(practice_id);

-- Verify the changes
SELECT 'Migration complete! Verifying schema...' as status;

-- Show patient_details columns
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'patient_details'
ORDER BY ordinal_position;

-- Show foreign keys
SELECT conname as constraint_name, contype as constraint_type
FROM pg_constraint
WHERE conrelid = 'patient_details'::regclass
AND contype = 'f';
