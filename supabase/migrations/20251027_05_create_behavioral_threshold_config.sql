-- Create behavioral_threshold_config table
-- Defines thresholds for when tracked data should replace questionnaire/initial data
-- Ensures sufficient data quality before updating behavioral scores

CREATE TABLE IF NOT EXISTS public.behavioral_threshold_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- What this config applies to
    agg_metric_id TEXT NOT NULL REFERENCES aggregation_metrics(agg_id) ON DELETE CASCADE,
    question_number NUMERIC REFERENCES survey_questions_base(question_number) ON DELETE CASCADE,
    biometric_name TEXT REFERENCES biometrics_base(biometric_name) ON DELETE CASCADE,

    -- Threshold requirements
    min_weeks_of_data INTEGER NOT NULL DEFAULT 3,
    min_data_points_per_week NUMERIC NOT NULL DEFAULT 4,
    min_total_data_points INTEGER NOT NULL DEFAULT 15,

    -- Data quality requirements
    min_tracking_days INTEGER NOT NULL DEFAULT 21, -- Total days data must span
    max_gap_days INTEGER DEFAULT 7, -- Maximum gap between data points
    require_recent_data BOOLEAN DEFAULT true, -- Must have data within last 7 days

    -- Stability/consistency requirements
    stability_threshold NUMERIC, -- Max coefficient of variation for consistency (NULL = not required)
    min_unique_days INTEGER, -- Minimum number of unique days with data (NULL = not required)

    -- Metadata
    config_type TEXT NOT NULL, -- 'behavior_tracking' or 'biometric_tracking'
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT unique_agg_metric_config UNIQUE (agg_metric_id),
    CONSTRAINT check_config_type CHECK (
        config_type IN ('behavior_tracking', 'biometric_tracking')
    ),
    CONSTRAINT check_positive_thresholds CHECK (
        min_weeks_of_data > 0 AND
        min_data_points_per_week > 0 AND
        min_total_data_points > 0 AND
        min_tracking_days > 0
    )
);

-- Indexes
CREATE INDEX idx_behavioral_threshold_config_agg_metric
ON public.behavioral_threshold_config(agg_metric_id)
WHERE is_active = true;

CREATE INDEX idx_behavioral_threshold_config_question
ON public.behavioral_threshold_config(question_number)
WHERE question_number IS NOT NULL AND is_active = true;

CREATE INDEX idx_behavioral_threshold_config_biometric
ON public.behavioral_threshold_config(biometric_name)
WHERE biometric_name IS NOT NULL AND is_active = true;

CREATE INDEX idx_behavioral_threshold_config_type
ON public.behavioral_threshold_config(config_type)
WHERE is_active = true;

-- RLS Policies
ALTER TABLE public.behavioral_threshold_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read threshold config"
ON public.behavioral_threshold_config
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "Service role can manage threshold config"
ON public.behavioral_threshold_config
FOR ALL
TO service_role
USING (true);

-- Grants
GRANT SELECT ON public.behavioral_threshold_config TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.behavioral_threshold_config TO service_role;

-- Comments
COMMENT ON TABLE public.behavioral_threshold_config IS
'Configuration for thresholds determining when tracked data replaces initial questionnaire/biometric data';

COMMENT ON COLUMN public.behavioral_threshold_config.min_weeks_of_data IS
'Minimum number of weeks of tracking required before replacing initial value (default: 3 weeks)';

COMMENT ON COLUMN public.behavioral_threshold_config.min_data_points_per_week IS
'Minimum average data points per week to ensure consistent tracking (default: 4 per week)';

COMMENT ON COLUMN public.behavioral_threshold_config.min_total_data_points IS
'Absolute minimum number of total data points required (default: 15 total)';

COMMENT ON COLUMN public.behavioral_threshold_config.min_tracking_days IS
'Minimum number of calendar days the data must span (default: 21 days)';

COMMENT ON COLUMN public.behavioral_threshold_config.max_gap_days IS
'Maximum allowed gap between consecutive data points (default: 7 days)';

COMMENT ON COLUMN public.behavioral_threshold_config.require_recent_data IS
'Whether data must include entries from last 7 days to be considered current (default: true)';

COMMENT ON COLUMN public.behavioral_threshold_config.stability_threshold IS
'Maximum coefficient of variation (std dev / mean) for data to be considered stable (NULL = not required)';

COMMENT ON COLUMN public.behavioral_threshold_config.min_unique_days IS
'Minimum number of unique calendar days with data (for behaviors that should be tracked daily)';

SELECT '✅ Created behavioral_threshold_config table' as status;
