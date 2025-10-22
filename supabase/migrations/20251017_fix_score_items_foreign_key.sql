-- =====================================================
-- Fix Foreign Key Constraint for patient_wellpath_score_items
-- =====================================================
-- Changes foreign key from auth.users(id) to patient_details(user_id)
-- This allows scoring to work with patient data that doesn't have auth entries
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- Drop the old foreign key constraint
ALTER TABLE patient_wellpath_score_items
DROP CONSTRAINT IF EXISTS patient_wellpath_score_items_user_id_fkey;

-- Add new foreign key constraint to patient_details
ALTER TABLE patient_wellpath_score_items
ADD CONSTRAINT patient_wellpath_score_items_user_id_fkey
FOREIGN KEY (user_id) REFERENCES patient_details(user_id) ON DELETE CASCADE;

COMMIT;

-- Verification
DO $$
BEGIN
    RAISE NOTICE '✅ Foreign key updated to reference patient_details(user_id)';
    RAISE NOTICE 'patient_wellpath_score_items can now accept user_ids from patient_details';
END $$;
