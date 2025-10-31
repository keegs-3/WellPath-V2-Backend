-- Create data_entry_fields_mappings table
-- Maps data_entry_fields to biometrics, survey questions, and aggregation metrics
-- This enables tracked data to update biometric readings and behavioral scores

CREATE TABLE IF NOT EXISTS public.data_entry_fields_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Source: The data entry field
    field_id TEXT NOT NULL REFERENCES data_entry_fields(field_id) ON DELETE CASCADE,

    -- Targets: What this field can update (at least one required)
    biometric_name TEXT REFERENCES biometrics_base(biometric_name) ON DELETE CASCADE,
    question_number NUMERIC REFERENCES survey_questions_base(question_number) ON DELETE CASCADE,
    agg_metric_id TEXT NOT NULL REFERENCES aggregation_metrics(agg_id) ON DELETE CASCADE,

    -- Threshold configuration for when tracked data replaces initial data
    replacement_threshold_days INTEGER DEFAULT 21,
    min_data_points INTEGER DEFAULT 15,
    min_data_points_per_week INTEGER DEFAULT 3,

    -- Metadata
    mapping_type TEXT NOT NULL, -- 'biometric_tracking' or 'behavior_tracking'
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT check_at_least_one_target CHECK (
        biometric_name IS NOT NULL OR question_number IS NOT NULL
    ),
    CONSTRAINT check_mapping_type CHECK (
        mapping_type IN ('biometric_tracking', 'behavior_tracking')
    ),
    CONSTRAINT unique_field_biometric UNIQUE (field_id, biometric_name),
    CONSTRAINT unique_field_question UNIQUE (field_id, question_number)
);

-- Indexes for efficient lookups
CREATE INDEX idx_data_entry_mappings_field_id
ON public.data_entry_fields_mappings(field_id)
WHERE is_active = true;

CREATE INDEX idx_data_entry_mappings_biometric
ON public.data_entry_fields_mappings(biometric_name)
WHERE biometric_name IS NOT NULL AND is_active = true;

CREATE INDEX idx_data_entry_mappings_question
ON public.data_entry_fields_mappings(question_number)
WHERE question_number IS NOT NULL AND is_active = true;

CREATE INDEX idx_data_entry_mappings_agg_metric
ON public.data_entry_fields_mappings(agg_metric_id)
WHERE is_active = true;

-- RLS Policies
ALTER TABLE public.data_entry_fields_mappings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read field mappings"
ON public.data_entry_fields_mappings
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "Service role can manage field mappings"
ON public.data_entry_fields_mappings
FOR ALL
TO service_role
USING (true);

-- Grants
GRANT SELECT ON public.data_entry_fields_mappings TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.data_entry_fields_mappings TO service_role;

-- Comments
COMMENT ON TABLE public.data_entry_fields_mappings IS
'Maps data_entry_fields to biometrics and survey questions, enabling tracked data to update scores';

COMMENT ON COLUMN public.data_entry_fields_mappings.mapping_type IS
'Type of mapping: biometric_tracking (updates biometric readings) or behavior_tracking (updates behavioral scores from surveys)';

COMMENT ON COLUMN public.data_entry_fields_mappings.replacement_threshold_days IS
'Number of days of tracking required before tracked data replaces initial questionnaire/biometric value';

COMMENT ON COLUMN public.data_entry_fields_mappings.min_data_points IS
'Minimum total number of data points required before tracked data replaces initial value';

COMMENT ON COLUMN public.data_entry_fields_mappings.min_data_points_per_week IS
'Minimum average data points per week to ensure consistent tracking quality';

SELECT '✅ Created data_entry_fields_mappings table' as status;
