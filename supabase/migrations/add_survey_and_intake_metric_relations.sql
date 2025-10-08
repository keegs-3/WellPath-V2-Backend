-- Migration: Add foreign key relationships for survey_questions and intake_metrics_raw
-- Purpose: Support live WellPath score updates by linking questions/metrics to tracked and calculated metrics
-- Date: 2025-10-07

-- ==============================================================================
-- PART 1: Add columns to survey_questions
-- ==============================================================================

-- Add columns for linking survey_questions to metric_types_vfinal, calculated_metrics_vfinal, and screening_compliance_matrix
ALTER TABLE survey_questions
    ADD COLUMN IF NOT EXISTS metric_types_vfinal TEXT,
    ADD COLUMN IF NOT EXISTS screening_compliance_matrix TEXT;

COMMENT ON COLUMN survey_questions.metric_types_vfinal IS 'Links to tracked metrics in metric_types_vfinal for real-time score updates';
COMMENT ON COLUMN survey_questions.screening_compliance_matrix IS 'Links to screening compliance rules for preventive care tracking';

-- Create foreign key constraints for survey_questions
ALTER TABLE survey_questions
    ADD CONSTRAINT fk_survey_questions_metric_types
        FOREIGN KEY (metric_types_vfinal)
        REFERENCES metric_types_vfinal(record_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

ALTER TABLE survey_questions
    ADD CONSTRAINT fk_survey_questions_screening_compliance
        FOREIGN KEY (screening_compliance_matrix)
        REFERENCES screening_compliance_matrix(record_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_survey_questions_metric_types
    ON survey_questions(metric_types_vfinal);

CREATE INDEX IF NOT EXISTS idx_survey_questions_screening_compliance
    ON survey_questions(screening_compliance_matrix);

-- ==============================================================================
-- PART 2: Add columns to intake_metrics_raw
-- ==============================================================================

-- Add columns for linking intake_metrics_raw to metric_types_vfinal and calculated_metrics_vfinal
ALTER TABLE intake_metrics_raw
    ADD COLUMN IF NOT EXISTS metric_types_vfinal TEXT,
    ADD COLUMN IF NOT EXISTS calculated_metrics_vfinal TEXT;

COMMENT ON COLUMN intake_metrics_raw.metric_types_vfinal IS 'Links to tracked daily metrics that are derived from this biometric';
COMMENT ON COLUMN intake_metrics_raw.calculated_metrics_vfinal IS 'Links to calculated metrics that use this biometric in their formula';

-- Create foreign key constraints for intake_metrics_raw
ALTER TABLE intake_metrics_raw
    ADD CONSTRAINT fk_intake_metrics_metric_types
        FOREIGN KEY (metric_types_vfinal)
        REFERENCES metric_types_vfinal(record_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

ALTER TABLE intake_metrics_raw
    ADD CONSTRAINT fk_intake_metrics_calculated_metrics
        FOREIGN KEY (calculated_metrics_vfinal)
        REFERENCES calculated_metrics_vfinal(record_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_intake_metrics_metric_types
    ON intake_metrics_raw(metric_types_vfinal);

CREATE INDEX IF NOT EXISTS idx_intake_metrics_calculated_metrics
    ON intake_metrics_raw(calculated_metrics_vfinal);

-- ==============================================================================
-- VERIFICATION QUERIES
-- ==============================================================================

-- Verify survey_questions foreign keys
DO $$
BEGIN
    RAISE NOTICE 'Survey Questions Foreign Keys Added:';
    RAISE NOTICE '  - metric_types_vfinal (for tracked metrics)';
    RAISE NOTICE '  - screening_compliance_matrix (for screening rules)';
    RAISE NOTICE '  - calculated_metric (already existed)';
END $$;

-- Verify intake_metrics_raw foreign keys
DO $$
BEGIN
    RAISE NOTICE 'Intake Metrics Raw Foreign Keys Added:';
    RAISE NOTICE '  - metric_types_vfinal (for tracked metrics)';
    RAISE NOTICE '  - calculated_metrics_vfinal (for calculated metrics)';
END $$;

-- Show updated table structures
\d survey_questions
\d intake_metrics_raw
