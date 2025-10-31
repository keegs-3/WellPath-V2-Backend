-- =====================================================================================
-- NOTE: This migration is intentionally empty
-- =====================================================================================
-- Originally planned to add unique constraint on patient_biometric_readings
-- Decision changed: We want to KEEP historical biometric values, not replace them
-- Edge functions use INSERT instead of UPSERT to preserve history
-- =====================================================================================

-- No changes needed - patient_biometric_readings allows multiple readings per user per biometric
-- This supports historical tracking and trend analysis
