-- Create patient_item_scores_history table for tracking individual item scores over time
-- This table enables mobile charts to display individual biomarkers, biometrics, behaviors, and education scores
--
-- Design:
-- - One row per item-pillar combination per calculation
-- - Items that apply to multiple pillars (e.g., BMI on 6 pillars) get multiple rows
-- - Includes all score details needed for charts and historical tracking

CREATE TABLE IF NOT EXISTS patient_item_scores_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Patient and calculation identifiers
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    batch_id UUID NOT NULL,
    calculated_at TIMESTAMPTZ NOT NULL,

    -- Pillar and component classification
    pillar_name TEXT NOT NULL REFERENCES pillars_base(pillar_name) ON UPDATE CASCADE ON DELETE CASCADE,
    component_type TEXT NOT NULL CHECK (component_type IN ('markers', 'behaviors', 'education')),

    -- Item identification (exactly one must be non-null)
    item_type TEXT NOT NULL CHECK (item_type IN ('biomarker', 'biometric', 'survey_question', 'survey_function', 'education')),
    biomarker_name TEXT REFERENCES biomarkers_base(biomarker_name) ON UPDATE CASCADE ON DELETE CASCADE,
    biometric_name TEXT REFERENCES biometrics_base(biometric_name) ON UPDATE CASCADE ON DELETE CASCADE,
    question_number NUMERIC(5,2) REFERENCES survey_questions_base(question_number),
    function_name TEXT REFERENCES wellpath_scoring_survey_functions(function_name) ON UPDATE CASCADE ON DELETE CASCADE,
    education_module_id TEXT,

    -- Item display information
    item_name TEXT NOT NULL,
    item_display_name TEXT,

    -- Patient data
    patient_value TEXT,
    patient_value_numeric NUMERIC,
    patient_gender TEXT NOT NULL CHECK (patient_gender IN ('male', 'female')),
    patient_age INTEGER NOT NULL CHECK (patient_age >= 0 AND patient_age <= 150),

    -- Score details
    raw_score NUMERIC,
    normalized_score NUMERIC, -- 0-1 scale
    score_band TEXT,

    -- Weight and contribution to pillar
    raw_weight NUMERIC NOT NULL,
    item_weight_in_pillar NUMERIC NOT NULL, -- normalized weight for this pillar
    patient_score_contribution NUMERIC NOT NULL, -- actual contribution to pillar score
    max_score_contribution NUMERIC NOT NULL, -- max possible contribution to pillar score
    item_percentage NUMERIC, -- (patient_score / max_score) * 100

    -- Source data tracking
    data_collected_at TIMESTAMPTZ,
    data_source TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Ensure only one item identifier is set
    CONSTRAINT item_scores_history_one_item_type CHECK (
        (biomarker_name IS NOT NULL AND biometric_name IS NULL AND question_number IS NULL AND function_name IS NULL AND education_module_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NOT NULL AND question_number IS NULL AND function_name IS NULL AND education_module_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NULL AND question_number IS NOT NULL AND function_name IS NULL AND education_module_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NULL AND question_number IS NULL AND function_name IS NOT NULL AND education_module_id IS NULL) OR
        (biomarker_name IS NULL AND biometric_name IS NULL AND question_number IS NULL AND function_name IS NULL AND education_module_id IS NOT NULL)
    )
);

-- Indexes for efficient queries
CREATE INDEX idx_item_history_patient ON patient_item_scores_history(patient_id);
CREATE INDEX idx_item_history_patient_pillar ON patient_item_scores_history(patient_id, pillar_name);
CREATE INDEX idx_item_history_patient_component ON patient_item_scores_history(patient_id, component_type);
CREATE INDEX idx_item_history_patient_pillar_component ON patient_item_scores_history(patient_id, pillar_name, component_type);
CREATE INDEX idx_item_history_batch ON patient_item_scores_history(batch_id);
CREATE INDEX idx_item_history_calculated_at ON patient_item_scores_history(calculated_at DESC);
CREATE INDEX idx_item_history_patient_calculated ON patient_item_scores_history(patient_id, calculated_at DESC);

-- Partial indexes for each item type (performance optimization for type-specific queries)
CREATE INDEX idx_item_history_biomarker ON patient_item_scores_history(biomarker_name) WHERE biomarker_name IS NOT NULL;
CREATE INDEX idx_item_history_biometric ON patient_item_scores_history(biometric_name) WHERE biometric_name IS NOT NULL;
CREATE INDEX idx_item_history_question ON patient_item_scores_history(question_number) WHERE question_number IS NOT NULL;
CREATE INDEX idx_item_history_function ON patient_item_scores_history(function_name) WHERE function_name IS NOT NULL;
CREATE INDEX idx_item_history_education ON patient_item_scores_history(education_module_id) WHERE education_module_id IS NOT NULL;

-- RLS policies
ALTER TABLE patient_item_scores_history ENABLE ROW LEVEL SECURITY;

-- Users can view their own item history
CREATE POLICY "Users can view their own item score history"
    ON patient_item_scores_history
    FOR SELECT
    TO authenticated
    USING (patient_id = auth.uid());

-- Service role can manage all item history
CREATE POLICY "Service role can manage item score history"
    ON patient_item_scores_history
    USING (auth.role() = 'service_role');

-- Comments
COMMENT ON TABLE patient_item_scores_history IS
'Historical tracking of individual item scores (biomarkers, biometrics, survey questions, functions, education) for each patient. Items that apply to multiple pillars have one row per pillar. Used for charts and trend analysis.';

COMMENT ON COLUMN patient_item_scores_history.batch_id IS
'UUID identifying the scoring calculation run that created this record. Links to patient_wellpath_score_items.batch_id.';

COMMENT ON COLUMN patient_item_scores_history.component_type IS
'Component category: markers (biomarkers + biometrics), behaviors (questions + functions), or education';

COMMENT ON COLUMN patient_item_scores_history.item_weight_in_pillar IS
'Normalized weight of this item within this specific pillar (accounts for component weighting)';

COMMENT ON COLUMN patient_item_scores_history.patient_score_contribution IS
'This item''s actual contribution to the pillar score (normalized_score * item_weight_in_pillar)';

COMMENT ON COLUMN patient_item_scores_history.max_score_contribution IS
'Maximum possible contribution of this item to the pillar score';
