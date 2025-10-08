-- Migration: Create junction tables for many-to-many relationships
-- Survey questions and intake metrics can link to MULTIPLE metric types and calculated metrics

-- Drop existing FK columns (they were incorrectly designed as 1:1)
ALTER TABLE survey_questions
    DROP CONSTRAINT IF EXISTS fk_survey_questions_metric_types,
    DROP CONSTRAINT IF EXISTS fk_survey_questions_screening_compliance,
    DROP COLUMN IF EXISTS metric_types_vfinal,
    DROP COLUMN IF EXISTS screening_compliance_matrix;

ALTER TABLE intake_metrics_raw
    DROP CONSTRAINT IF EXISTS fk_intake_metrics_metric_types,
    DROP CONSTRAINT IF EXISTS fk_intake_metrics_calculated_metrics,
    DROP COLUMN IF EXISTS metric_types_vfinal,
    DROP COLUMN IF EXISTS calculated_metrics_vfinal;

-- Junction: survey_questions <-> metric_types_vfinal
CREATE TABLE IF NOT EXISTS survey_question_metric_types (
    id BIGSERIAL PRIMARY KEY,
    survey_question_id TEXT NOT NULL REFERENCES survey_questions(record_id) ON DELETE CASCADE,
    metric_type_id TEXT NOT NULL REFERENCES metric_types_vfinal(record_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(survey_question_id, metric_type_id)
);

-- Junction: survey_questions <-> calculated_metrics_vfinal
CREATE TABLE IF NOT EXISTS survey_question_calculated_metrics (
    id BIGSERIAL PRIMARY KEY,
    survey_question_id TEXT NOT NULL REFERENCES survey_questions(record_id) ON DELETE CASCADE,
    calculated_metric_id TEXT NOT NULL REFERENCES calculated_metrics_vfinal(record_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(survey_question_id, calculated_metric_id)
);

-- Junction: survey_questions <-> screening_compliance_matrix
CREATE TABLE IF NOT EXISTS survey_question_screening_compliance (
    id BIGSERIAL PRIMARY KEY,
    survey_question_id TEXT NOT NULL REFERENCES survey_questions(record_id) ON DELETE CASCADE,
    screening_compliance_id TEXT NOT NULL REFERENCES screening_compliance_matrix(record_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(survey_question_id, screening_compliance_id)
);

-- Junction: intake_metrics_raw <-> metric_types_vfinal
CREATE TABLE IF NOT EXISTS intake_metric_metric_types (
    id BIGSERIAL PRIMARY KEY,
    intake_metric_id TEXT NOT NULL REFERENCES intake_metrics_raw(record_id) ON DELETE CASCADE,
    metric_type_id TEXT NOT NULL REFERENCES metric_types_vfinal(record_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(intake_metric_id, metric_type_id)
);

-- Junction: intake_metrics_raw <-> calculated_metrics_vfinal
CREATE TABLE IF NOT EXISTS intake_metric_calculated_metrics (
    id BIGSERIAL PRIMARY KEY,
    intake_metric_id TEXT NOT NULL REFERENCES intake_metrics_raw(record_id) ON DELETE CASCADE,
    calculated_metric_id TEXT NOT NULL REFERENCES calculated_metrics_vfinal(record_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(intake_metric_id, calculated_metric_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_sq_metric_types_sq ON survey_question_metric_types(survey_question_id);
CREATE INDEX IF NOT EXISTS idx_sq_metric_types_mt ON survey_question_metric_types(metric_type_id);

CREATE INDEX IF NOT EXISTS idx_sq_calc_metrics_sq ON survey_question_calculated_metrics(survey_question_id);
CREATE INDEX IF NOT EXISTS idx_sq_calc_metrics_cm ON survey_question_calculated_metrics(calculated_metric_id);

CREATE INDEX IF NOT EXISTS idx_sq_screening_sq ON survey_question_screening_compliance(survey_question_id);
CREATE INDEX IF NOT EXISTS idx_sq_screening_sc ON survey_question_screening_compliance(screening_compliance_id);

CREATE INDEX IF NOT EXISTS idx_im_metric_types_im ON intake_metric_metric_types(intake_metric_id);
CREATE INDEX IF NOT EXISTS idx_im_metric_types_mt ON intake_metric_metric_types(metric_type_id);

CREATE INDEX IF NOT EXISTS idx_im_calc_metrics_im ON intake_metric_calculated_metrics(intake_metric_id);
CREATE INDEX IF NOT EXISTS idx_im_calc_metrics_cm ON intake_metric_calculated_metrics(calculated_metric_id);
