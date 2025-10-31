-- =====================================================
-- Add range_bucket Column to Biomarker/Biometric Tables
-- =====================================================
-- Classify ranges into: Optimal, In-Range, Out-of-Range
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Columns
-- =====================================================

-- Add range_bucket to biomarkers_detail
ALTER TABLE biomarkers_detail
ADD COLUMN IF NOT EXISTS range_bucket TEXT;

-- Add range_bucket to biometrics_detail
ALTER TABLE biometrics_detail
ADD COLUMN IF NOT EXISTS range_bucket TEXT;

-- =====================================================
-- PART 2: Update Biomarkers
-- =====================================================

-- Optimal (3 ranges)
UPDATE biomarkers_detail SET range_bucket = 'Optimal' WHERE range_name = 'Optimal';
UPDATE biomarkers_detail SET range_bucket = 'Optimal' WHERE range_name = 'Optimal Ionized Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Optimal' WHERE range_name = 'Optimal Serum Calcium';

-- In-Range (12 ranges)
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'High Normal';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'High-Normal';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range (high)';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range (High)';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range (low)';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range (Low)';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range (Lower)';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range (Slightly High)';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range (Upper)';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'Near-Optimal';
UPDATE biomarkers_detail SET range_bucket = 'In-Range' WHERE range_name = 'Normal';

-- Out-of-Range (107 ranges)
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Borderline High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Borderline Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Clinical Hyperthyroid';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Clinical Hypothyroid';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically Elevated';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically High BUN';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically High DHEA-S';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically High Ionized Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically High Serum Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically Low DHEA-S';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically Low Ionized Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically Low Serum Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Deficient';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Diabetes';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Diabetes Risk';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Elevated';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excess';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessive';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessive Folate';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessively High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessively High Hgb';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessively Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Expected Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Extremely High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Extremely High Cortisol';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Extremely Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'High (Misaligned Phase?)';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'High Hct';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'High Morning Cortisol';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'High Risk';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Hyperproteinemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Hypoalbuminemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Impaired Fasting Glucose';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Insufficient';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Kidney Failure (ESRD)';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Low Morning Cortisol';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Low Risk';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Low Uric Acid';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Anemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Deficiency';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Elevation';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Eosinophilia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Hyperkalemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Hypernatremia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Hyperuricemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Hypokalemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Hyponatremia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Kidney Dysfunction';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Lymphopenia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Neutropenia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Neutrophilia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mild Resistance';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Elevated';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Elevated BUN';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Elevated DHEA-S';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Elevated Ionized Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Elevated Serum Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Low DHEA-S';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Low Ionized Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Mildly Low Serum Calcium';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderate Elevation';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderate Eosinophilia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderate Kidney Dysfunction';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderate Resistance';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderate Risk';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderate-Severe Kidney Dysfunction';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderately Elevated';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Prediabetes';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Anemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Deficiency';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Elevation';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Eosinophilia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Hyperkalemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Hypernatremia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Hyperuricemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Hypoalbuminemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Hypokalemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Hyponatremia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Hypoproteinemia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Kidney Dysfunction';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Lymphopenia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Neutropenia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severe Neutrophilia';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severely Elevated';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severely Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severely Low Testosterone';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Significant Resistance';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Significantly Elevated';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Significantly High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Significantly Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Subclinical Hyperthyroid';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Subclinical Hypothyroid';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Suboptimal';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Suboptimal High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Suboptimal Low';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Sufficient';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Toxic';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Unusually High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Very High';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Very High Cystatin C';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Very High Risk';
UPDATE biomarkers_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Very Low';


-- =====================================================
-- PART 3: Update Biometrics
-- =====================================================

-- Optimal (1 ranges)
UPDATE biometrics_detail SET range_bucket = 'Optimal' WHERE range_name = 'Optimal';

-- In-Range (2 ranges)
UPDATE biometrics_detail SET range_bucket = 'In-Range' WHERE range_name = 'Good';
UPDATE biometrics_detail SET range_bucket = 'In-Range' WHERE range_name = 'In-Range';

-- Out-of-Range (17 ranges)
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'At Risk';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically High';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Critically Low';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Elevated';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessive';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessively High';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Excessively Low';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'High';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'High Risk';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Hypertension (Stage 1)';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Hypertension (Stage 2)';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Low';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Moderate';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Severely Low';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Suboptimal';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Suboptimal High';
UPDATE biometrics_detail SET range_bucket = 'Out-of-Range' WHERE range_name = 'Suboptimal Low';


-- =====================================================
-- PART 4: Verify Results
-- =====================================================

DO $$
DECLARE
  biomarker_optimal INT;
  biomarker_inrange INT;
  biomarker_outofrange INT;
  biometric_optimal INT;
  biometric_inrange INT;
  biometric_outofrange INT;
BEGIN
  -- Count biomarkers by bucket
  SELECT COUNT(DISTINCT range_name) INTO biomarker_optimal
  FROM biomarkers_detail WHERE range_bucket = 'Optimal';

  SELECT COUNT(DISTINCT range_name) INTO biomarker_inrange
  FROM biomarkers_detail WHERE range_bucket = 'In-Range';

  SELECT COUNT(DISTINCT range_name) INTO biomarker_outofrange
  FROM biomarkers_detail WHERE range_bucket = 'Out-of-Range';

  -- Count biometrics by bucket
  SELECT COUNT(DISTINCT range_name) INTO biometric_optimal
  FROM biometrics_detail WHERE range_bucket = 'Optimal';

  SELECT COUNT(DISTINCT range_name) INTO biometric_inrange
  FROM biometrics_detail WHERE range_bucket = 'In-Range';

  SELECT COUNT(DISTINCT range_name) INTO biometric_outofrange
  FROM biometrics_detail WHERE range_bucket = 'Out-of-Range';

  RAISE NOTICE '✅ Range Buckets Added';
  RAISE NOTICE '';
  RAISE NOTICE 'Biomarkers:';
  RAISE NOTICE '  Optimal: %', biomarker_optimal;
  RAISE NOTICE '  In-Range: %', biomarker_inrange;
  RAISE NOTICE '  Out-of-Range: %', biomarker_outofrange;
  RAISE NOTICE '';
  RAISE NOTICE 'Biometrics:';
  RAISE NOTICE '  Optimal: %', biometric_optimal;
  RAISE NOTICE '  In-Range: %', biometric_inrange;
  RAISE NOTICE '  Out-of-Range: %', biometric_outofrange;
END $$;

COMMIT;
