-- =====================================================
-- CREATE PATIENT DATA STORAGE TABLES
-- For WellPath scoring system integration
-- =====================================================

-- 1. SURVEY RESPONSES
-- Stores patient answers to survey questions
CREATE TABLE IF NOT EXISTS survey_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patient_details(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL, -- References survey_questions.record_id
    response_option_id TEXT, -- References survey_response_options.record_id (if applicable)
    response_value TEXT, -- Text response
    response_numeric NUMERIC, -- Numeric response (for scoring)
    response_data JSONB, -- Additional structured data
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicate responses to same question
    CONSTRAINT unique_patient_question UNIQUE (patient_id, question_id)
);

-- 2. BIOMARKER READINGS
-- Stores lab results and clinical biomarkers
CREATE TABLE IF NOT EXISTS biomarker_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patient_details(id) ON DELETE CASCADE,
    marker_id TEXT NOT NULL, -- References intake_markers.record_id
    value NUMERIC NOT NULL,
    unit TEXT,
    test_date DATE NOT NULL,
    source TEXT DEFAULT 'manual_entry', -- 'lab', 'manual_entry', 'import'
    lab_name TEXT,
    reference_range_min NUMERIC,
    reference_range_max NUMERIC,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. METRIC READINGS
-- Stores daily lifestyle/biometric tracking data
CREATE TABLE IF NOT EXISTS metric_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patient_details(id) ON DELETE CASCADE,
    metric_id TEXT NOT NULL, -- References intake_metrics.record_id or calculated_metrics
    value NUMERIC,
    value_text TEXT, -- For categorical metrics
    value_json JSONB, -- For complex metrics (e.g., meal details, sleep stages)
    recorded_date DATE NOT NULL,
    recorded_time TIME,
    source TEXT DEFAULT 'manual', -- 'manual', 'healthkit', 'oura', 'calculated'
    metadata JSONB, -- Additional context (e.g., meal type, exercise type)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Allow multiple readings per day per metric (e.g., multiple meals)
    -- But add index for efficient querying
    CONSTRAINT idx_metric_readings_lookup UNIQUE (patient_id, metric_id, recorded_date, recorded_time)
);

-- 4. PATIENT RECOMMENDATIONS
-- Stores AI-matched recommendations assigned to patients
CREATE TABLE IF NOT EXISTS patient_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patient_details(id) ON DELETE CASCADE,
    recommendation_id TEXT NOT NULL, -- REC0001, REC0002, etc. (base ID without level)
    level INTEGER NOT NULL CHECK (level IN (1, 2, 3)), -- Difficulty level
    config_id TEXT NOT NULL, -- Full config ID: REC0001.1-BINARY-THRESHOLD
    config_data JSONB, -- Full JSON config from generated_configs

    -- Assignment details
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    assigned_by UUID REFERENCES auth_users(id), -- Clinician who assigned (null if AI-assigned)
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'rejected')),

    -- Impact scoring (from wellpath_impact_scorer)
    impact_score NUMERIC, -- Personalized impact score for this patient
    pillar_id TEXT, -- Primary pillar this targets
    improvement_potential NUMERIC, -- Expected score improvement

    -- Goal tracking
    start_date DATE,
    target_completion_date DATE,
    actual_completion_date DATE,

    -- Additional data
    notes TEXT,
    patient_notes TEXT, -- Patient's own notes about this recommendation
    clinician_notes TEXT, -- Clinician's notes

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- One recommendation at a time per patient (can have multiple levels over time)
    CONSTRAINT unique_active_recommendation UNIQUE (patient_id, recommendation_id, status)
);

-- 5. ADHERENCE SCORES
-- Stores daily adherence scores for active recommendations (13 algorithms)
CREATE TABLE IF NOT EXISTS adherence_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patient_details(id) ON DELETE CASCADE,
    patient_recommendation_id UUID NOT NULL REFERENCES patient_recommendations(id) ON DELETE CASCADE,
    recommendation_id TEXT NOT NULL, -- Denormalized for easier queries
    config_id TEXT NOT NULL,

    -- Scoring details
    score_date DATE NOT NULL,
    algorithm_type TEXT NOT NULL, -- 'binary_threshold', 'minimum_frequency', etc.

    -- Dual progress tracking
    current_progress NUMERIC NOT NULL CHECK (current_progress >= 0 AND current_progress <= 100),
    max_potential NUMERIC NOT NULL CHECK (max_potential >= 0 AND max_potential <= 100),

    -- Raw data used for calculation
    algorithm_data JSONB, -- Raw inputs and intermediate calculations
    tracked_metrics JSONB, -- Which metrics were tracked this day

    -- Metadata
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    calculation_method TEXT DEFAULT 'automatic', -- 'automatic', 'manual_override'

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- One score per recommendation per day
    CONSTRAINT unique_daily_adherence UNIQUE (patient_id, patient_recommendation_id, score_date)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Survey responses
CREATE INDEX IF NOT EXISTS idx_survey_responses_patient ON survey_responses(patient_id);
CREATE INDEX IF NOT EXISTS idx_survey_responses_question ON survey_responses(question_id);
CREATE INDEX IF NOT EXISTS idx_survey_responses_answered_at ON survey_responses(answered_at DESC);

-- Biomarker readings
CREATE INDEX IF NOT EXISTS idx_biomarker_readings_patient ON biomarker_readings(patient_id);
CREATE INDEX IF NOT EXISTS idx_biomarker_readings_marker ON biomarker_readings(marker_id);
CREATE INDEX IF NOT EXISTS idx_biomarker_readings_test_date ON biomarker_readings(test_date DESC);
CREATE INDEX IF NOT EXISTS idx_biomarker_readings_patient_marker ON biomarker_readings(patient_id, marker_id, test_date DESC);

-- Metric readings
CREATE INDEX IF NOT EXISTS idx_metric_readings_patient ON metric_readings(patient_id);
CREATE INDEX IF NOT EXISTS idx_metric_readings_metric ON metric_readings(metric_id);
CREATE INDEX IF NOT EXISTS idx_metric_readings_recorded_date ON metric_readings(recorded_date DESC);
CREATE INDEX IF NOT EXISTS idx_metric_readings_patient_metric_date ON metric_readings(patient_id, metric_id, recorded_date DESC);

-- Patient recommendations
CREATE INDEX IF NOT EXISTS idx_patient_recs_patient ON patient_recommendations(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_recs_status ON patient_recommendations(status);
CREATE INDEX IF NOT EXISTS idx_patient_recs_patient_active ON patient_recommendations(patient_id, status) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_patient_recs_pillar ON patient_recommendations(pillar_id);

-- Adherence scores
CREATE INDEX IF NOT EXISTS idx_adherence_scores_patient ON adherence_scores(patient_id);
CREATE INDEX IF NOT EXISTS idx_adherence_scores_patient_rec ON adherence_scores(patient_recommendation_id);
CREATE INDEX IF NOT EXISTS idx_adherence_scores_date ON adherence_scores(score_date DESC);
CREATE INDEX IF NOT EXISTS idx_adherence_scores_patient_date ON adherence_scores(patient_id, score_date DESC);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_survey_responses_updated_at ON survey_responses;
CREATE TRIGGER update_survey_responses_updated_at
    BEFORE UPDATE ON survey_responses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_biomarker_readings_updated_at ON biomarker_readings;
CREATE TRIGGER update_biomarker_readings_updated_at
    BEFORE UPDATE ON biomarker_readings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_metric_readings_updated_at ON metric_readings;
CREATE TRIGGER update_metric_readings_updated_at
    BEFORE UPDATE ON metric_readings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_patient_recommendations_updated_at ON patient_recommendations;
CREATE TRIGGER update_patient_recommendations_updated_at
    BEFORE UPDATE ON patient_recommendations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VERIFICATION
-- =====================================================

SELECT '✅ Patient data tables created!' as status;
SELECT 'Tables created:' as info;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('survey_responses', 'biomarker_readings', 'metric_readings', 'patient_recommendations', 'adherence_scores')
ORDER BY table_name;
