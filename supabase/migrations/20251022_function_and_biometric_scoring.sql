-- =====================================================================================
-- FUNCTION AND BIOMETRIC SCORING SYSTEM
-- =====================================================================================
-- This migration creates the infrastructure for dynamically updating function-based
-- scores using tracked data, and populates biometric scoring ranges.
--
-- Part 1: Function-to-Aggregation Mappings (for composite survey function scores)
-- Part 2: Patient Effective Function Scores (tracks current vs. original scores)
-- Part 3: Biometric Aggregation Scoring Ranges (BMI, BP, HR, etc.)
-- =====================================================================================

-- =====================================================================================
-- PART 1: FUNCTION AGGREGATION MAPPINGS TABLE
-- =====================================================================================
-- Maps survey functions to the aggregation metrics they depend on
-- Enables dynamic recalculation of function scores based on tracked data

CREATE TABLE IF NOT EXISTS function_aggregation_mappings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Function info
    function_name TEXT NOT NULL REFERENCES wellpath_scoring_survey_functions(function_name) ON DELETE CASCADE,

    -- Aggregation metric(s) this function depends on
    agg_metric_id TEXT NOT NULL REFERENCES aggregation_metrics(agg_id) ON UPDATE CASCADE ON DELETE CASCADE,

    -- How this metric contributes to function score
    weight_in_function NUMERIC,  -- If function uses multiple metrics (e.g., frequency + duration)
    contribution_type TEXT CHECK (contribution_type IN ('primary', 'secondary', 'modifier')),

    -- Scoring configuration for this metric
    calculation_type_id TEXT DEFAULT 'AVG',
    period_type TEXT DEFAULT 'monthly',

    -- Thresholds for scoring (JSON array of range objects)
    threshold_ranges JSONB,  -- Example: [{"low": 0, "high": 2, "score": 0.2}, {"low": 3, "high": 5, "score": 1.0}]

    -- Data quality requirements
    min_data_points INT DEFAULT 15,
    lookback_days INT DEFAULT 30,

    -- Metadata
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_fam_function ON function_aggregation_mappings(function_name);
CREATE INDEX idx_fam_agg_metric ON function_aggregation_mappings(agg_metric_id);
CREATE INDEX idx_fam_active ON function_aggregation_mappings(is_active) WHERE is_active = true;

COMMENT ON TABLE function_aggregation_mappings IS 'Maps survey scoring functions to aggregation metrics for dynamic score updates';
COMMENT ON COLUMN function_aggregation_mappings.weight_in_function IS 'Weight of this metric in composite function (e.g., frequency=0.5, duration=0.5)';
COMMENT ON COLUMN function_aggregation_mappings.contribution_type IS 'How metric contributes: primary (main score), secondary (combined), modifier (adjusts score)';
COMMENT ON COLUMN function_aggregation_mappings.threshold_ranges IS 'JSON array defining score ranges: [{"low": val, "high": val, "score": 0-1}]';


-- =====================================================================================
-- PART 2: PATIENT EFFECTIVE FUNCTION SCORES TABLE
-- =====================================================================================
-- Stores dynamically calculated function scores based on tracked data
-- Tracks both original survey-based score and current tracking-based score

CREATE TABLE IF NOT EXISTS patient_effective_function_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    user_id UUID NOT NULL,
    function_name TEXT NOT NULL REFERENCES wellpath_scoring_survey_functions(function_name) ON DELETE CASCADE,

    -- Original survey-based score
    original_score NUMERIC,
    original_score_date TIMESTAMPTZ,

    -- Current tracking-based score
    effective_score NUMERIC,
    effective_score_date TIMESTAMPTZ DEFAULT NOW(),

    -- How was it calculated
    score_source TEXT CHECK (score_source IN ('survey', 'tracking', 'hybrid', 'insufficient_data')),

    -- Tracking metadata
    contributing_metrics JSONB,  -- Example: {"AGG_CARDIO_SESSION_COUNT": 4, "AGG_CARDIO_DURATION": 180}
    metric_scores JSONB,          -- Example: {"AGG_CARDIO_SESSION_COUNT": 0.8, "AGG_CARDIO_DURATION": 1.0}
    data_quality JSONB,           -- Example: {"AGG_CARDIO_SESSION_COUNT": {"count": 20, "sufficient": true}}

    -- Score delta tracking
    score_change NUMERIC GENERATED ALWAYS AS (effective_score - original_score) STORED,

    -- Timestamps
    last_calculated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, function_name)
);

-- Indexes
CREATE INDEX idx_pefs_user ON patient_effective_function_scores(user_id);
CREATE INDEX idx_pefs_function ON patient_effective_function_scores(function_name);
CREATE INDEX idx_pefs_source ON patient_effective_function_scores(score_source);
CREATE INDEX idx_pefs_score_change ON patient_effective_function_scores(score_change);

COMMENT ON TABLE patient_effective_function_scores IS 'Stores dynamic function scores calculated from tracked data vs. original survey scores';
COMMENT ON COLUMN patient_effective_function_scores.score_source IS 'survey: from survey only, tracking: from tracked data, hybrid: combined, insufficient_data: not enough tracking data';
COMMENT ON COLUMN patient_effective_function_scores.score_change IS 'Automatic calculation of improvement/decline from original score';


-- =====================================================================================
-- PART 3: POPULATE FUNCTION AGGREGATION MAPPINGS
-- =====================================================================================
-- Map all 28 survey functions to their corresponding aggregation metrics

-- -------------------------------------------------------------------------------------
-- MOVEMENT FUNCTIONS (16-point weights each)
-- -------------------------------------------------------------------------------------

-- Cardio: Combines frequency (sessions) and duration (minutes)
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('movement_cardio_score', 'AGG_CARDIO_SESSION_COUNT', 0.5, 'primary',
 '[{"low": 0, "high": 1, "score": 0.2}, {"low": 2, "high": 2, "score": 0.4}, {"low": 3, "high": 4, "score": 0.7}, {"low": 5, "high": 999, "score": 1.0}]'::jsonb,
 'Q3.04: Cardio frequency - sessions per week'),
('movement_cardio_score', 'AGG_CARDIO_DURATION', 0.5, 'primary',
 '[{"low": 0, "high": 60, "score": 0.2}, {"low": 61, "high": 120, "score": 0.5}, {"low": 121, "high": 150, "score": 0.8}, {"low": 151, "high": 9999, "score": 1.0}]'::jsonb,
 'Q3.08: Cardio duration - total minutes per week');

-- Strength: Combines frequency and duration
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('movement_strength_score', 'AGG_STRENGTH_SESSION_COUNT', 0.5, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 0.3}, {"low": 2, "high": 2, "score": 0.6}, {"low": 3, "high": 999, "score": 1.0}]'::jsonb,
 'Q3.05: Strength frequency - sessions per week'),
('movement_strength_score', 'AGG_CALCULATED_EXERCISE_TIME', 0.5, 'primary',
 '[{"low": 0, "high": 30, "score": 0.2}, {"low": 31, "high": 60, "score": 0.5}, {"low": 61, "high": 90, "score": 0.8}, {"low": 91, "high": 9999, "score": 1.0}]'::jsonb,
 'Q3.09: Strength duration - total minutes per week');

-- HIIT: Combines frequency and duration
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('movement_hiit_score', 'AGG_HIIT_SESSION_COUNT', 0.5, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 0.4}, {"low": 2, "high": 2, "score": 0.7}, {"low": 3, "high": 999, "score": 1.0}]'::jsonb,
 'Q3.07: HIIT frequency - sessions per week'),
('movement_hiit_score', 'AGG_HIIT_DURATION', 0.5, 'primary',
 '[{"low": 0, "high": 20, "score": 0.2}, {"low": 21, "high": 40, "score": 0.5}, {"low": 41, "high": 60, "score": 0.8}, {"low": 61, "high": 9999, "score": 1.0}]'::jsonb,
 'Q3.11: HIIT duration - total minutes per week');

-- Mobility/Flexibility: Combines frequency and duration
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('movement_flexibility_score', 'AGG_MOBILITY_SESSION_COUNT', 0.5, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 0.3}, {"low": 2, "high": 3, "score": 0.6}, {"low": 4, "high": 999, "score": 1.0}]'::jsonb,
 'Q3.06: Flexibility/mobility frequency - sessions per week'),
('movement_flexibility_score', 'AGG_MOBILITY_DURATION', 0.5, 'primary',
 '[{"low": 0, "high": 20, "score": 0.2}, {"low": 21, "high": 40, "score": 0.5}, {"low": 41, "high": 60, "score": 0.8}, {"low": 61, "high": 9999, "score": 1.0}]'::jsonb,
 'Q3.10: Flexibility/mobility duration - total minutes per week');


-- -------------------------------------------------------------------------------------
-- SUBSTANCE FUNCTIONS
-- -------------------------------------------------------------------------------------

-- Alcohol: Track drinks per week
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('substance_alcohol_score', 'AGG_ALCOHOLIC_DRINKS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 1.0}, {"low": 1, "high": 3, "score": 0.8}, {"low": 4, "high": 7, "score": 0.5}, {"low": 8, "high": 14, "score": 0.3}, {"low": 15, "high": 9999, "score": 0.1}]'::jsonb,
 'Q8.01/8.05: Alcohol consumption - drinks per week (0 is optimal)');

-- Tobacco/Cigarettes: Track cigarettes per day
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('substance_tobacco_score', 'AGG_CIGARETTES', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 1.0}, {"low": 1, "high": 5, "score": 0.3}, {"low": 6, "high": 10, "score": 0.2}, {"low": 11, "high": 9999, "score": 0.0}]'::jsonb,
 'Q8.02/8.03: Cigarette consumption - cigarettes per day (0 is optimal)');

-- Nicotine (e-cigs, vaping): Track nicotine usage
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('substance_nicotine_score', 'AGG_SUBSTANCE_USAGE_LEVEL', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 1.0}, {"low": 1, "high": 3, "score": 0.5}, {"low": 4, "high": 7, "score": 0.2}, {"low": 8, "high": 9999, "score": 0.0}]'::jsonb,
 'Q8.11/8.12: Nicotine usage level - times per day (0 is optimal)');


-- -------------------------------------------------------------------------------------
-- NUTRITION FUNCTIONS
-- -------------------------------------------------------------------------------------

-- Protein Intake: Track grams of protein
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('protein_intake_score', 'AGG_PROTEIN_GRAMS', 1.0, 'primary',
 '[{"low": 0, "high": 40, "score": 0.2}, {"low": 41, "high": 70, "score": 0.5}, {"low": 71, "high": 100, "score": 0.8}, {"low": 101, "high": 9999, "score": 1.0}]'::jsonb,
 'Q2.11: Daily protein intake in grams');

-- Calorie Intake: Track daily calories (requires context-based calculation)
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('calorie_intake_score', 'AGG_CALORIES_CONSUMED', 1.0, 'primary',
 NULL,  -- Requires patient-specific BMR calculation
 'Q2.62: Daily calorie intake - scored against BMR-based target (context-dependent)');


-- -------------------------------------------------------------------------------------
-- SLEEP FUNCTIONS
-- -------------------------------------------------------------------------------------

-- Sleep Duration: Track hours of sleep
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('sleep_issues_score', 'AGG_SLEEP_DURATION', 0.4, 'primary',
 '[{"low": 0, "high": 5, "score": 0.2}, {"low": 5.1, "high": 6, "score": 0.5}, {"low": 6.1, "high": 7, "score": 0.7}, {"low": 7.1, "high": 9, "score": 1.0}, {"low": 9.1, "high": 24, "score": 0.7}]'::jsonb,
 'Q4.12: Sleep duration hours (7-9 is optimal)'),
('sleep_issues_score', 'AGG_SLEEP_QUALITY', 0.3, 'primary',
 '[{"low": 1, "high": 2, "score": 0.2}, {"low": 3, "high": 4, "score": 0.5}, {"low": 5, "high": 5, "score": 1.0}]'::jsonb,
 'Q4.13: Sleep quality rating 1-5'),
('sleep_issues_score', 'AGG_SLEEP_LATENCY', 0.3, 'secondary',
 '[{"low": 0, "high": 15, "score": 1.0}, {"low": 16, "high": 30, "score": 0.7}, {"low": 31, "high": 60, "score": 0.4}, {"low": 61, "high": 9999, "score": 0.2}]'::jsonb,
 'Q4.14: Time to fall asleep in minutes');

-- Sleep Protocols: Track adherence to sleep hygiene
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('sleep_protocols_score', 'AGG_SLEEP_ROUTINE_ADHERENCE', 0.4, 'primary',
 '[{"low": 0, "high": 2, "score": 0.2}, {"low": 3, "high": 4, "score": 0.5}, {"low": 5, "high": 6, "score": 0.8}, {"low": 7, "high": 10, "score": 1.0}]'::jsonb,
 'Q4.07: Number of sleep protocols followed'),
('sleep_protocols_score', 'AGG_LAST_CAFFEINE_CONSUMPTION_BUFFER', 0.2, 'secondary',
 '[{"low": 0, "high": 4, "score": 0.2}, {"low": 4.1, "high": 6, "score": 0.6}, {"low": 6.1, "high": 24, "score": 1.0}]'::jsonb,
 'Hours before bed last caffeine consumed'),
('sleep_protocols_score', 'AGG_DIGITAL_SHUTOFF_BUFFER', 0.2, 'secondary',
 '[{"low": 0, "high": 0.5, "score": 0.2}, {"low": 0.6, "high": 1, "score": 0.6}, {"low": 1.1, "high": 24, "score": 1.0}]'::jsonb,
 'Hours before bed digital devices turned off'),
('sleep_protocols_score', 'AGG_LAST_MEAL_BUFFER', 0.2, 'secondary',
 '[{"low": 0, "high": 2, "score": 0.3}, {"low": 2.1, "high": 3, "score": 0.7}, {"low": 3.1, "high": 24, "score": 1.0}]'::jsonb,
 'Hours before bed last meal consumed');


-- -------------------------------------------------------------------------------------
-- STRESS FUNCTIONS
-- -------------------------------------------------------------------------------------

-- Stress Level: Track daily stress ratings
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('stress_level_score', 'AGG_STRESS_LEVEL_RATING', 1.0, 'primary',
 '[{"low": 1, "high": 2, "score": 1.0}, {"low": 3, "high": 4, "score": 0.7}, {"low": 5, "high": 6, "score": 0.5}, {"low": 7, "high": 8, "score": 0.3}, {"low": 9, "high": 10, "score": 0.1}]'::jsonb,
 'Q6.01: Daily stress level 1-10 (lower is better)');

-- Coping Skills: Track stress management activities
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('coping_skills_score', 'AGG_MEDITATION_SESSIONS', 0.3, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 2, "score": 0.4}, {"low": 3, "high": 4, "score": 0.7}, {"low": 5, "high": 999, "score": 1.0}]'::jsonb,
 'Q6.07: Meditation/mindfulness sessions per week'),
('coping_skills_score', 'AGG_STRESS_MANAGEMENT_SESSIONS', 0.3, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 2, "score": 0.5}, {"low": 3, "high": 999, "score": 1.0}]'::jsonb,
 'Q6.07: Overall stress management sessions'),
('coping_skills_score', 'AGG_JOURNALING_SESSIONS', 0.2, 'secondary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 2, "score": 0.4}, {"low": 3, "high": 999, "score": 0.7}]'::jsonb,
 'Q6.07: Journaling sessions per week'),
('coping_skills_score', 'AGG_CARDIO_SESSION_COUNT', 0.2, 'modifier',
 '[{"low": 0, "high": 1, "score": 0.0}, {"low": 2, "high": 3, "score": 0.5}, {"low": 4, "high": 999, "score": 1.0}]'::jsonb,
 'Q6.07: Exercise as coping mechanism');


-- -------------------------------------------------------------------------------------
-- COGNITIVE FUNCTIONS
-- -------------------------------------------------------------------------------------

-- Cognitive Activities: Track brain training and mental stimulation
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('cognitive_activities_score', 'AGG_BRAIN_TRAINING_SESSION_COUNT', 0.5, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 2, "score": 0.3}, {"low": 3, "high": 4, "score": 0.6}, {"low": 5, "high": 999, "score": 1.0}]'::jsonb,
 'Q5.08: Brain training/cognitive activities count'),
('cognitive_activities_score', 'AGG_SOCIAL_INTERACTION', 0.3, 'secondary',
 '[{"low": 0, "high": 1, "score": 0.2}, {"low": 2, "high": 3, "score": 0.6}, {"low": 4, "high": 999, "score": 1.0}]'::jsonb,
 'Q5.08: Social interactions (cognitive stimulation)'),
('cognitive_activities_score', 'AGG_MEMORY_CLARITY_RATING', 0.2, 'modifier',
 '[{"low": 1, "high": 2, "score": 0.2}, {"low": 3, "high": 4, "score": 0.6}, {"low": 5, "high": 5, "score": 1.0}]'::jsonb,
 'Subjective memory/clarity rating');


-- -------------------------------------------------------------------------------------
-- SCREENING FUNCTIONS (Track compliance)
-- -------------------------------------------------------------------------------------

-- Colonoscopy Compliance
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_colonoscopy_score', 'AGG_COLONOSCOPY_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'Colonoscopy compliance: 0=non-compliant, 1=compliant');

-- Mammogram Compliance
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_mammogram_score', 'AGG_MAMMOGRAM_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'Mammogram compliance: 0=non-compliant, 1=compliant');

-- Breast MRI Compliance
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_breast_mri_score', 'AGG_BREAST_MRI_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'Breast MRI compliance: 0=non-compliant, 1=compliant');

-- Cervical Screening (PAP/HPV)
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_pap_score', 'AGG_CERVICAL_SCREENING_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'PAP smear compliance: 0=non-compliant, 1=compliant'),
('screening_hpv_score', 'AGG_CERVICAL_SCREENING_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'HPV test compliance: 0=non-compliant, 1=compliant');

-- PSA Screening
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_psa_score', 'AGG_PSA_TEST_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'PSA test compliance: 0=non-compliant, 1=compliant');

-- Dental Exam
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_dental_score', 'AGG_DENTAL_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'Dental exam compliance: 0=non-compliant, 1=compliant');

-- Vision Check
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_vision_score', 'AGG_VISION_CHECK_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'Vision check compliance: 0=non-compliant, 1=compliant');

-- Skin Check
INSERT INTO function_aggregation_mappings (function_name, agg_metric_id, weight_in_function, contribution_type, threshold_ranges, notes) VALUES
('screening_skin_check_score', 'AGG_SKIN_CHECK_COMPLIANCE_STATUS', 1.0, 'primary',
 '[{"low": 0, "high": 0, "score": 0.0}, {"low": 1, "high": 1, "score": 1.0}]'::jsonb,
 'Skin check compliance: 0=non-compliant, 1=compliant');


-- =====================================================================================
-- PART 4: POPULATE BIOMETRIC AGGREGATIONS SCORING
-- =====================================================================================
-- Define scoring ranges for biometric measurements

-- -------------------------------------------------------------------------------------
-- BMI SCORING
-- -------------------------------------------------------------------------------------

INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
-- Optimal BMI
('AGG_BMI', 'Optimal BMI (18.5-24.9)', 'Optimal', 18.5, 24.9, 1.0,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Healthy weight range for adults'),

-- Overweight
('AGG_BMI', 'Overweight (25-29.9)', 'Out-of-Range', 25.0, 29.9, 0.6,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Overweight - increased health risks'),

-- Obese Class I
('AGG_BMI', 'Obese Class I (30-34.9)', 'Out-of-Range', 30.0, 34.9, 0.4,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Obesity Class I - significant health risks'),

-- Obese Class II
('AGG_BMI', 'Obese Class II (35-39.9)', 'Out-of-Range', 35.0, 39.9, 0.2,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Obesity Class II - severe health risks'),

-- Obese Class III
('AGG_BMI', 'Obese Class III (40+)', 'Out-of-Range', 40.0, 999, 0.1,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Obesity Class III - very severe health risks'),

-- Underweight
('AGG_BMI', 'Underweight (<18.5)', 'Out-of-Range', 0, 18.4, 0.5,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Underweight - potential health concerns');


-- -------------------------------------------------------------------------------------
-- BLOOD PRESSURE SCORING
-- -------------------------------------------------------------------------------------

-- Systolic Blood Pressure
INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
('AGG_SYSTOLIC_BLOOD_PRESSURE', 'Normal Systolic (<120)', 'Optimal', 90, 119, 1.0,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Normal systolic blood pressure'),

('AGG_SYSTOLIC_BLOOD_PRESSURE', 'Elevated Systolic (120-129)', 'In-Range', 120, 129, 0.7,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Elevated - at risk for hypertension'),

('AGG_SYSTOLIC_BLOOD_PRESSURE', 'Stage 1 Hypertension (130-139)', 'Out-of-Range', 130, 139, 0.5,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Stage 1 hypertension - medical attention needed'),

('AGG_SYSTOLIC_BLOOD_PRESSURE', 'Stage 2 Hypertension (140-179)', 'Out-of-Range', 140, 179, 0.3,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Stage 2 hypertension - medical intervention required'),

('AGG_SYSTOLIC_BLOOD_PRESSURE', 'Hypertensive Crisis (180+)', 'Out-of-Range', 180, 999, 0.1,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Hypertensive crisis - seek emergency care');

-- Diastolic Blood Pressure
INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
('AGG_DIASTOLIC_BLOOD_PRESSURE', 'Normal Diastolic (<80)', 'Optimal', 60, 79, 1.0,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Normal diastolic blood pressure'),

('AGG_DIASTOLIC_BLOOD_PRESSURE', 'Stage 1 Hypertension (80-89)', 'Out-of-Range', 80, 89, 0.5,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Stage 1 hypertension - medical attention needed'),

('AGG_DIASTOLIC_BLOOD_PRESSURE', 'Stage 2 Hypertension (90-119)', 'Out-of-Range', 90, 119, 0.3,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Stage 2 hypertension - medical intervention required'),

('AGG_DIASTOLIC_BLOOD_PRESSURE', 'Hypertensive Crisis (120+)', 'Out-of-Range', 120, 999, 0.1,
 'all', 18, 120, 'AVG', 'monthly', 10, 30, 'Hypertensive crisis - seek emergency care');


-- -------------------------------------------------------------------------------------
-- HEART RATE SCORING
-- -------------------------------------------------------------------------------------

INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
-- Optimal resting heart rate
('AGG_RESTING_HEART_RATE', 'Athlete (40-59 bpm)', 'Optimal', 40, 59, 1.0,
 'all', 18, 120, 'AVG', 'monthly', 15, 30, 'Athletic/excellent cardiovascular fitness'),

('AGG_RESTING_HEART_RATE', 'Excellent (60-69 bpm)', 'Optimal', 60, 69, 1.0,
 'all', 18, 120, 'AVG', 'monthly', 15, 30, 'Excellent cardiovascular health'),

('AGG_RESTING_HEART_RATE', 'Good (70-79 bpm)', 'In-Range', 70, 79, 0.8,
 'all', 18, 120, 'AVG', 'monthly', 15, 30, 'Good cardiovascular health'),

('AGG_RESTING_HEART_RATE', 'Average (80-89 bpm)', 'In-Range', 80, 89, 0.6,
 'all', 18, 120, 'AVG', 'monthly', 15, 30, 'Average cardiovascular fitness'),

('AGG_RESTING_HEART_RATE', 'Below Average (90-99 bpm)', 'Out-of-Range', 90, 99, 0.4,
 'all', 18, 120, 'AVG', 'monthly', 15, 30, 'Below average - consider improving fitness'),

('AGG_RESTING_HEART_RATE', 'Poor (100+ bpm)', 'Out-of-Range', 100, 200, 0.2,
 'all', 18, 120, 'AVG', 'monthly', 15, 30, 'Poor cardiovascular health - medical evaluation recommended');


-- -------------------------------------------------------------------------------------
-- BODY COMPOSITION SCORING
-- -------------------------------------------------------------------------------------

-- Body Fat Percentage - Male
INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
('AGG_BODY_FAT_PERCENTAGE', 'Male - Essential Fat (2-5%)', 'Out-of-Range', 2, 5, 0.5,
 'male', 18, 39, 'AVG', 'monthly', 10, 30, 'Essential fat only - too low for optimal health'),

('AGG_BODY_FAT_PERCENTAGE', 'Male - Athletic (6-13%)', 'Optimal', 6, 13, 1.0,
 'male', 18, 39, 'AVG', 'monthly', 10, 30, 'Athletic body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Male - Fitness (14-17%)', 'Optimal', 14, 17, 0.9,
 'male', 18, 39, 'AVG', 'monthly', 10, 30, 'Fit and healthy'),

('AGG_BODY_FAT_PERCENTAGE', 'Male - Average (18-24%)', 'In-Range', 18, 24, 0.7,
 'male', 18, 39, 'AVG', 'monthly', 10, 30, 'Average body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Male - Above Average (25-31%)', 'Out-of-Range', 25, 31, 0.4,
 'male', 18, 39, 'AVG', 'monthly', 10, 30, 'Above average - consider reducing'),

('AGG_BODY_FAT_PERCENTAGE', 'Male - Obese (32%+)', 'Out-of-Range', 32, 100, 0.2,
 'male', 18, 39, 'AVG', 'monthly', 10, 30, 'Obese range - health risks');

-- Body Fat Percentage - Male 40-59
INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
('AGG_BODY_FAT_PERCENTAGE', 'Male 40-59 - Athletic (7-14%)', 'Optimal', 7, 14, 1.0,
 'male', 40, 59, 'AVG', 'monthly', 10, 30, 'Athletic body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Male 40-59 - Fitness (15-20%)', 'Optimal', 15, 20, 0.9,
 'male', 40, 59, 'AVG', 'monthly', 10, 30, 'Fit and healthy'),

('AGG_BODY_FAT_PERCENTAGE', 'Male 40-59 - Average (21-27%)', 'In-Range', 21, 27, 0.7,
 'male', 40, 59, 'AVG', 'monthly', 10, 30, 'Average body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Male 40-59 - Above Average (28-34%)', 'Out-of-Range', 28, 34, 0.4,
 'male', 40, 59, 'AVG', 'monthly', 10, 30, 'Above average - consider reducing'),

('AGG_BODY_FAT_PERCENTAGE', 'Male 40-59 - Obese (35%+)', 'Out-of-Range', 35, 100, 0.2,
 'male', 40, 59, 'AVG', 'monthly', 10, 30, 'Obese range - health risks');

-- Body Fat Percentage - Female
INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
('AGG_BODY_FAT_PERCENTAGE', 'Female - Essential Fat (10-13%)', 'Out-of-Range', 10, 13, 0.5,
 'female', 18, 39, 'AVG', 'monthly', 10, 30, 'Essential fat only - too low for optimal health'),

('AGG_BODY_FAT_PERCENTAGE', 'Female - Athletic (14-20%)', 'Optimal', 14, 20, 1.0,
 'female', 18, 39, 'AVG', 'monthly', 10, 30, 'Athletic body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Female - Fitness (21-24%)', 'Optimal', 21, 24, 0.9,
 'female', 18, 39, 'AVG', 'monthly', 10, 30, 'Fit and healthy'),

('AGG_BODY_FAT_PERCENTAGE', 'Female - Average (25-31%)', 'In-Range', 25, 31, 0.7,
 'female', 18, 39, 'AVG', 'monthly', 10, 30, 'Average body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Female - Above Average (32-38%)', 'Out-of-Range', 32, 38, 0.4,
 'female', 18, 39, 'AVG', 'monthly', 10, 30, 'Above average - consider reducing'),

('AGG_BODY_FAT_PERCENTAGE', 'Female - Obese (39%+)', 'Out-of-Range', 39, 100, 0.2,
 'female', 18, 39, 'AVG', 'monthly', 10, 30, 'Obese range - health risks');

-- Body Fat Percentage - Female 40-59
INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
('AGG_BODY_FAT_PERCENTAGE', 'Female 40-59 - Athletic (15-21%)', 'Optimal', 15, 21, 1.0,
 'female', 40, 59, 'AVG', 'monthly', 10, 30, 'Athletic body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Female 40-59 - Fitness (22-27%)', 'Optimal', 22, 27, 0.9,
 'female', 40, 59, 'AVG', 'monthly', 10, 30, 'Fit and healthy'),

('AGG_BODY_FAT_PERCENTAGE', 'Female 40-59 - Average (28-34%)', 'In-Range', 28, 34, 0.7,
 'female', 40, 59, 'AVG', 'monthly', 10, 30, 'Average body composition'),

('AGG_BODY_FAT_PERCENTAGE', 'Female 40-59 - Above Average (35-41%)', 'Out-of-Range', 35, 41, 0.4,
 'female', 40, 59, 'AVG', 'monthly', 10, 30, 'Above average - consider reducing'),

('AGG_BODY_FAT_PERCENTAGE', 'Female 40-59 - Obese (42%+)', 'Out-of-Range', 42, 100, 0.2,
 'female', 40, 59, 'AVG', 'monthly', 10, 30, 'Obese range - health risks');


-- -------------------------------------------------------------------------------------
-- WAIST-TO-HIP RATIO SCORING
-- -------------------------------------------------------------------------------------

INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
-- Male waist-to-hip ratio
('AGG_HIP_TO_WAIST_RATIO', 'Male - Low Risk (<0.90)', 'Optimal', 0, 0.89, 1.0,
 'male', 18, 120, 'AVG', 'monthly', 5, 30, 'Low cardiovascular disease risk'),

('AGG_HIP_TO_WAIST_RATIO', 'Male - Moderate Risk (0.90-0.99)', 'In-Range', 0.90, 0.99, 0.6,
 'male', 18, 120, 'AVG', 'monthly', 5, 30, 'Moderate cardiovascular disease risk'),

('AGG_HIP_TO_WAIST_RATIO', 'Male - High Risk (1.0+)', 'Out-of-Range', 1.0, 10, 0.3,
 'male', 18, 120, 'AVG', 'monthly', 5, 30, 'High cardiovascular disease risk'),

-- Female waist-to-hip ratio
('AGG_HIP_TO_WAIST_RATIO', 'Female - Low Risk (<0.80)', 'Optimal', 0, 0.79, 1.0,
 'female', 18, 120, 'AVG', 'monthly', 5, 30, 'Low cardiovascular disease risk'),

('AGG_HIP_TO_WAIST_RATIO', 'Female - Moderate Risk (0.80-0.85)', 'In-Range', 0.80, 0.85, 0.6,
 'female', 18, 120, 'AVG', 'monthly', 5, 30, 'Moderate cardiovascular disease risk'),

('AGG_HIP_TO_WAIST_RATIO', 'Female - High Risk (0.86+)', 'Out-of-Range', 0.86, 10, 0.3,
 'female', 18, 120, 'AVG', 'monthly', 5, 30, 'High cardiovascular disease risk');


-- -------------------------------------------------------------------------------------
-- WEIGHT SCORING (General ranges)
-- -------------------------------------------------------------------------------------

INSERT INTO biometric_aggregations_scoring (
    agg_metric_id, range_name, range_bucket, range_low, range_high, range_score,
    gender, age_low, age_high, calculation_type_id, period_type, min_data_points, lookback_days, notes
) VALUES
-- Weight stability (based on consistency)
('AGG_CURRENT_WEIGHT', 'Stable Weight (±2 lbs/month)', 'Optimal', -2, 2, 1.0,
 'all', 18, 120, 'STDDEV', 'monthly', 20, 30, 'Healthy weight stability - low variation'),

('AGG_CURRENT_WEIGHT', 'Moderate Fluctuation (±2-5 lbs/month)', 'In-Range', 2.1, 5, 0.7,
 'all', 18, 120, 'STDDEV', 'monthly', 20, 30, 'Moderate weight fluctuation'),

('AGG_CURRENT_WEIGHT', 'High Fluctuation (>5 lbs/month)', 'Out-of-Range', 5.1, 999, 0.4,
 'all', 18, 120, 'STDDEV', 'monthly', 20, 30, 'High weight instability - investigation needed');


-- =====================================================================================
-- SUMMARY QUERY FOR VERIFICATION
-- =====================================================================================

-- View function mapping summary
DO $$
DECLARE
    mapping_count INT;
    function_count INT;
    biometric_count INT;
BEGIN
    SELECT COUNT(*) INTO mapping_count FROM function_aggregation_mappings;
    SELECT COUNT(DISTINCT function_name) INTO function_count FROM function_aggregation_mappings;
    SELECT COUNT(*) INTO biometric_count FROM biometric_aggregations_scoring;

    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'MIGRATION SUMMARY';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Function-Aggregation Mappings Created: %', mapping_count;
    RAISE NOTICE 'Functions Mapped: %', function_count;
    RAISE NOTICE 'Biometric Scoring Ranges Created: %', biometric_count;
    RAISE NOTICE '=================================================================';
END $$;
