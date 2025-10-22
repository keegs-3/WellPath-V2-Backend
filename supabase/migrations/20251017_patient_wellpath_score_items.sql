-- =====================================================
-- Patient WellPath Score Items Table
-- =====================================================
-- Stores individual scored items (biomarkers, biometrics, questions, functions)
-- with patient-specific scores and gender-specific max scores
--
-- This table is populated by the calculate-wellpath-score Edge Function
-- and serves as the source for all UI aggregation views
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- Drop table if exists (for clean rebuild)
DROP TABLE IF EXISTS patient_wellpath_score_items CASCADE;

-- =====================================================
-- Main Table: patient_wellpath_score_items
-- =====================================================
CREATE TABLE patient_wellpath_score_items (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Patient demographics (denormalized for query performance)
    patient_gender TEXT NOT NULL CHECK (patient_gender IN ('M', 'F')),
    patient_age INTEGER NOT NULL CHECK (patient_age >= 0 AND patient_age <= 150),

    -- Item identification (one of these will be filled)
    item_type TEXT NOT NULL CHECK (item_type IN ('biomarker', 'biometric', 'survey_question', 'survey_function', 'education', 'behavior')),
    biomarker_name TEXT,
    biometric_name TEXT,
    question_number TEXT,
    function_name TEXT,
    education_module_id TEXT,
    behavior_metric_id TEXT,

    -- Pillar mapping
    pillar_name TEXT NOT NULL,

    -- Patient's value and score
    patient_value TEXT,  -- Can store numbers, text, JSON for complex values
    patient_value_numeric NUMERIC,  -- For numeric values (biomarkers, biometrics)
    score_band TEXT,  -- e.g., "Optimal", "Borderline", etc. from biomarkers_detail/biometrics_detail
    raw_score NUMERIC,  -- Score from range/response (0-10 or 0-1 scale)
    normalized_score NUMERIC,  -- Score normalized to 0-1 scale

    -- Weights (raw and normalized, gender-specific)
    raw_weight NUMERIC NOT NULL,
    patient_normalized_score_male NUMERIC,  -- Only filled if patient is male
    patient_normalized_score_female NUMERIC,  -- Only filled if patient is female
    max_normalized_score_male NUMERIC NOT NULL,
    max_normalized_score_female NUMERIC NOT NULL,

    -- For survey functions: store constituent question responses
    function_question_responses JSONB,  -- Array of {question_number, response}

    -- Timestamps
    data_collected_at TIMESTAMP WITH TIME ZONE,  -- When the underlying data was collected
    scored_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Metadata
    max_grouping TEXT,  -- For items that share max logic (e.g., PAP/HPV)
    calculation_version TEXT DEFAULT '1.0',

    -- Constraints
    CONSTRAINT patient_score_items_one_item_type CHECK (
        (biomarker_name IS NOT NULL AND biometric_name IS NULL AND question_number IS NULL AND function_name IS NULL AND education_module_id IS NULL AND behavior_metric_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NOT NULL AND question_number IS NULL AND function_name IS NULL AND education_module_id IS NULL AND behavior_metric_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NULL AND question_number IS NOT NULL AND function_name IS NULL AND education_module_id IS NULL AND behavior_metric_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NULL AND question_number IS NULL AND function_name IS NOT NULL AND education_module_id IS NULL AND behavior_metric_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NULL AND question_number IS NULL AND function_name IS NULL AND education_module_id IS NOT NULL AND behavior_metric_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NULL AND question_number IS NULL AND function_name IS NULL AND education_module_id IS NULL AND behavior_metric_id IS NOT NULL)
    ),
    CONSTRAINT patient_score_gender_specific CHECK (
        (patient_gender = 'M' AND patient_normalized_score_male IS NOT NULL AND patient_normalized_score_female IS NULL) OR
        (patient_gender = 'F' AND patient_normalized_score_female IS NOT NULL AND patient_normalized_score_male IS NULL)
    )
);

-- =====================================================
-- Indexes for Performance
-- =====================================================

-- Primary query patterns
CREATE INDEX idx_score_items_user ON patient_wellpath_score_items(user_id);
CREATE INDEX idx_score_items_user_scored ON patient_wellpath_score_items(user_id, scored_at DESC);
CREATE INDEX idx_score_items_user_pillar ON patient_wellpath_score_items(user_id, pillar_name);
CREATE INDEX idx_score_items_user_type ON patient_wellpath_score_items(user_id, item_type);
CREATE INDEX idx_score_items_user_pillar_type ON patient_wellpath_score_items(user_id, pillar_name, item_type);

-- Item lookups
CREATE INDEX idx_score_items_biomarker ON patient_wellpath_score_items(biomarker_name) WHERE biomarker_name IS NOT NULL;
CREATE INDEX idx_score_items_biometric ON patient_wellpath_score_items(biometric_name) WHERE biometric_name IS NOT NULL;
CREATE INDEX idx_score_items_question ON patient_wellpath_score_items(question_number) WHERE question_number IS NOT NULL;
CREATE INDEX idx_score_items_function ON patient_wellpath_score_items(function_name) WHERE function_name IS NOT NULL;

-- Max grouping lookups (for PAP/HPV etc.)
CREATE INDEX idx_score_items_max_grouping ON patient_wellpath_score_items(max_grouping) WHERE max_grouping IS NOT NULL;

-- JSONB function responses
CREATE INDEX idx_score_items_function_responses ON patient_wellpath_score_items USING GIN(function_question_responses) WHERE function_question_responses IS NOT NULL;

-- =====================================================
-- Row Level Security (RLS)
-- =====================================================

ALTER TABLE patient_wellpath_score_items ENABLE ROW LEVEL SECURITY;

-- Patients can only read their own score items
CREATE POLICY "Users can read own score items"
ON patient_wellpath_score_items
FOR SELECT
USING (auth.uid() = user_id);

-- Only service role can insert/update (via Edge Function)
CREATE POLICY "Service role can manage score items"
ON patient_wellpath_score_items
FOR ALL
USING (auth.role() = 'service_role');

-- =====================================================
-- Triggers
-- =====================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_patient_score_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER patient_score_items_updated_at
BEFORE UPDATE ON patient_wellpath_score_items
FOR EACH ROW
EXECUTE FUNCTION update_patient_score_items_updated_at();

-- =====================================================
-- Comments for Documentation
-- =====================================================

COMMENT ON TABLE patient_wellpath_score_items IS
'Stores individual scored items for each patient. Populated by calculate-wellpath-score Edge Function. Source table for all UI aggregation views showing score breakdowns by pillar, category, section, etc.';

COMMENT ON COLUMN patient_wellpath_score_items.patient_gender IS 'Denormalized from patient_details for query performance';
COMMENT ON COLUMN patient_wellpath_score_items.patient_age IS 'Calculated age at time of scoring';
COMMENT ON COLUMN patient_wellpath_score_items.item_type IS 'Type of scored item: biomarker, biometric, survey_question, survey_function, education, or behavior';
COMMENT ON COLUMN patient_wellpath_score_items.patient_value IS 'Patient''s actual value/response as text (for display)';
COMMENT ON COLUMN patient_wellpath_score_items.patient_value_numeric IS 'Patient''s numeric value (for biomarkers/biometrics)';
COMMENT ON COLUMN patient_wellpath_score_items.score_band IS 'Descriptive band like "Optimal", "Borderline", "At Risk" from detail tables';
COMMENT ON COLUMN patient_wellpath_score_items.raw_score IS 'Raw score from range/response lookup (0-10 or 0-1 scale)';
COMMENT ON COLUMN patient_wellpath_score_items.normalized_score IS 'Score normalized to 0-1 scale';
COMMENT ON COLUMN patient_wellpath_score_items.patient_normalized_score_male IS 'Patient''s contribution to pillar score (males only)';
COMMENT ON COLUMN patient_wellpath_score_items.patient_normalized_score_female IS 'Patient''s contribution to pillar score (females only)';
COMMENT ON COLUMN patient_wellpath_score_items.max_normalized_score_male IS 'Maximum possible contribution for males';
COMMENT ON COLUMN patient_wellpath_score_items.max_normalized_score_female IS 'Maximum possible contribution for females';
COMMENT ON COLUMN patient_wellpath_score_items.function_question_responses IS 'For survey functions: array of {question_number, response} objects showing constituent questions';
COMMENT ON COLUMN patient_wellpath_score_items.max_grouping IS 'For items that share max logic (e.g., PAP and HPV both have max_grouping=cervical_cancer_screening)';

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_tables
        WHERE tablename = 'patient_wellpath_score_items'
    ) THEN
        RAISE NOTICE '✅ Table patient_wellpath_score_items created successfully';
    ELSE
        RAISE EXCEPTION '❌ Table patient_wellpath_score_items failed to create';
    END IF;
END $$;

-- =====================================================
-- Sample Usage (Commented Out)
-- =====================================================

-- Example 1: Get all biomarker scores for a patient
-- SELECT
--     biomarker_name,
--     patient_value_numeric,
--     score_band,
--     normalized_score,
--     patient_normalized_score_male,  -- or _female depending on patient
--     max_normalized_score_male,      -- or _female depending on patient
--     pillar_name
-- FROM patient_wellpath_score_items
-- WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
-- AND item_type = 'biomarker'
-- ORDER BY pillar_name, biomarker_name;

-- Example 2: Get survey function details with constituent questions
-- SELECT
--     function_name,
--     normalized_score,
--     patient_normalized_score_female,
--     function_question_responses,
--     pillar_name
-- FROM patient_wellpath_score_items
-- WHERE user_id = 'd9581a86-0f30-4be4-ba9e-6ae269700d4d'
-- AND item_type = 'survey_function'
-- ORDER BY pillar_name, function_name;

-- Example 3: Calculate total score for a pillar
-- SELECT
--     pillar_name,
--     SUM(
--         CASE
--             WHEN patient_gender = 'M' THEN patient_normalized_score_male
--             WHEN patient_gender = 'F' THEN patient_normalized_score_female
--         END
--     ) as patient_score,
--     SUM(
--         CASE
--             WHEN patient_gender = 'M' THEN max_normalized_score_male
--             WHEN patient_gender = 'F' THEN max_normalized_score_female
--         END
--     ) as max_score
-- FROM patient_wellpath_score_items
-- WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
-- GROUP BY pillar_name
-- ORDER BY pillar_name;

-- Example 4: Handle max_grouping (e.g., PAP/HPV)
-- For items in same max_grouping, take MAX of scores not SUM
-- SELECT
--     pillar_name,
--     max_grouping,
--     MAX(
--         CASE
--             WHEN patient_gender = 'M' THEN patient_normalized_score_male
--             WHEN patient_gender = 'F' THEN patient_normalized_score_female
--         END
--     ) as best_score_in_group
-- FROM patient_wellpath_score_items
-- WHERE user_id = 'd9581a86-0f30-4be4-ba9e-6ae269700d4d'
-- AND max_grouping = 'cervical_cancer_screening'
-- GROUP BY pillar_name, max_grouping;
