-- =====================================================
-- Dynamic WellPath Score Updating Tables
-- =====================================================
-- Enable automatic score updates based on tracked behaviors
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Survey Response Options → Aggregation Metrics
-- =====================================================

CREATE TABLE IF NOT EXISTS survey_response_options_aggregations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Survey response option
    response_option_id TEXT NOT NULL,  -- References survey_response_options(option_id)
    question_number NUMERIC NOT NULL,

    -- Aggregation metric
    agg_metric_id TEXT NOT NULL,  -- References aggregation_metrics(agg_id)

    -- Threshold criteria
    threshold_low NUMERIC,        -- Minimum value for this response option
    threshold_high NUMERIC,       -- Maximum value for this response option
    calculation_type_id TEXT,     -- Which calculation: 'AVG', 'SUM', 'COUNT', etc.
    period_type TEXT,             -- 'daily', 'weekly', 'monthly'

    -- Data quality requirements
    min_data_points INT DEFAULT 20,   -- Minimum entries required
    lookback_days INT DEFAULT 30,     -- Rolling window in days

    -- Metadata
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(response_option_id, agg_metric_id)
);

CREATE INDEX idx_sroa_question_number ON survey_response_options_aggregations(question_number);
CREATE INDEX idx_sroa_agg_metric ON survey_response_options_aggregations(agg_metric_id);

COMMENT ON TABLE survey_response_options_aggregations IS
'Maps survey response options to aggregation metrics for dynamic score updating. When a patient tracks behavior that matches a response option threshold, their effective response updates.';

-- =====================================================
-- PART 2: Biometric Aggregations → Scoring Ranges
-- =====================================================

CREATE TABLE IF NOT EXISTS biometric_aggregations_scoring (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Biometric aggregation
    agg_metric_id TEXT NOT NULL,  -- References aggregation_metrics(agg_id)

    -- Scoring range (similar to biomarkers_detail)
    range_name TEXT NOT NULL,
    range_bucket TEXT CHECK (range_bucket IN ('Optimal', 'In-Range', 'Out-of-Range')),
    range_low NUMERIC,
    range_high NUMERIC,
    range_score NUMERIC CHECK (range_score BETWEEN 0 AND 1),  -- Score for this range

    -- Demographic filters
    gender TEXT,
    age_low NUMERIC,
    age_high NUMERIC,

    -- Calculation settings
    calculation_type_id TEXT DEFAULT 'AVG',
    period_type TEXT DEFAULT 'monthly',
    min_data_points INT DEFAULT 10,
    lookback_days INT DEFAULT 30,

    -- Metadata
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bas_agg_metric ON biometric_aggregations_scoring(agg_metric_id);
CREATE INDEX idx_bas_range_bucket ON biometric_aggregations_scoring(range_bucket);

COMMENT ON TABLE biometric_aggregations_scoring IS
'Defines scoring ranges for biometric aggregations (weight, BMI, blood pressure, etc.). Maps tracked biometrics to score values similar to biomarkers.';

-- =====================================================
-- PART 3: Patient Effective Responses
-- =====================================================

CREATE TABLE IF NOT EXISTS patient_effective_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Patient and question
    user_id UUID NOT NULL,  -- References auth.users(id)
    question_number NUMERIC NOT NULL,

    -- Original survey response
    original_response_option_id TEXT,  -- References survey_response_options(option_id)
    original_score NUMERIC,
    original_response_date TIMESTAMPTZ,

    -- Current effective response (could be tracking-based)
    effective_response_option_id TEXT,  -- References survey_response_options(option_id)
    effective_score NUMERIC,

    -- How was effective response determined?
    response_source TEXT CHECK (response_source IN ('survey', 'tracking', 'hybrid')),

    -- Tracking metadata (if response_source = 'tracking')
    tracking_agg_metric_id TEXT,
    tracking_avg_value NUMERIC,
    tracking_data_points INT,
    tracking_period_start DATE,
    tracking_period_end DATE,

    -- Timestamps
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, question_number)
);

CREATE INDEX idx_per_user_id ON patient_effective_responses(user_id);
CREATE INDEX idx_per_question_number ON patient_effective_responses(question_number);
CREATE INDEX idx_per_response_source ON patient_effective_responses(response_source);

COMMENT ON TABLE patient_effective_responses IS
'Stores the current effective response for each patient-question pair. Effective response can be either the original survey response OR a tracking-based response if patient has sufficient tracked data. This table drives dynamic score calculations.';

-- =====================================================
-- PART 4: Views for Score Calculation
-- =====================================================

CREATE OR REPLACE VIEW patient_current_scores AS
SELECT
    per.user_id,
    sq.category_id as pillar,  -- Assuming category_id is pillar
    sq.section_id,
    sq.group_id,
    per.question_number,
    per.effective_score as score,
    per.response_source,
    per.tracking_avg_value,
    sq.question_text,
    CASE
        WHEN per.response_source = 'tracking' THEN
            'Score updated from tracked behavior'
        ELSE
            'Score from survey response'
    END as score_note
FROM patient_effective_responses per
JOIN survey_questions_base sq ON per.question_number = sq.question_number
WHERE per.effective_score IS NOT NULL;

COMMENT ON VIEW patient_current_scores IS
'Shows current effective scores for all patients for WellPath score calculation. Uses tracking-based scores when available, falls back to survey responses.';

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
    sroa_count INT;
    bas_count INT;
    per_count INT;
BEGIN
    SELECT COUNT(*) INTO sroa_count FROM survey_response_options_aggregations;
    SELECT COUNT(*) INTO bas_count FROM biometric_aggregations_scoring;
    SELECT COUNT(*) INTO per_count FROM patient_effective_responses;

    RAISE NOTICE '✅ Dynamic Scoring Tables Created';
    RAISE NOTICE '';
    RAISE NOTICE 'Tables:';
    RAISE NOTICE '  survey_response_options_aggregations: % mappings', sroa_count;
    RAISE NOTICE '  biometric_aggregations_scoring: % scoring ranges', bas_count;
    RAISE NOTICE '  patient_effective_responses: % patients', per_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '  1. Populate survey response → aggregation metric mappings';
    RAISE NOTICE '  2. Define biometric scoring ranges';
    RAISE NOTICE '  3. Create calculation functions and triggers';
END $$;

COMMIT;
