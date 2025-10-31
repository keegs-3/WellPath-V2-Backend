-- Create patient_behavioral_values table
-- Stores the current "behavioral value" for each patient's tracked behaviors
-- Enables threshold-based updates where tracked data replaces questionnaire responses

CREATE TABLE IF NOT EXISTS public.patient_behavioral_values (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- What this value represents (either a question or biometric)
    question_number NUMERIC REFERENCES survey_questions_base(question_number) ON DELETE CASCADE,
    biometric_name TEXT REFERENCES biometrics_base(biometric_name) ON DELETE CASCADE,
    agg_metric_id TEXT NOT NULL REFERENCES aggregation_metrics(agg_id) ON DELETE CASCADE,

    -- Current value and its source
    current_value NUMERIC NOT NULL,
    current_value_source TEXT NOT NULL, -- 'questionnaire', 'tracked', 'clinician'
    original_questionnaire_value NUMERIC, -- Preserve initial survey response
    original_questionnaire_response_text TEXT, -- Original categorical response

    -- Tracking metadata
    established_date TIMESTAMP WITH TIME ZONE NOT NULL,
    data_points_count INTEGER NOT NULL DEFAULT 0,
    lookback_period_start TIMESTAMP WITH TIME ZONE,
    lookback_period_end TIMESTAMP WITH TIME ZONE,
    last_updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Aggregation info for tracked values
    calculation_type_id TEXT REFERENCES calculation_types(type_id) ON DELETE SET NULL,
    period_type TEXT, -- 'daily', 'weekly', 'monthly'

    -- Metadata
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT check_one_identifier CHECK (
        (question_number IS NOT NULL AND biometric_name IS NULL) OR
        (question_number IS NULL AND biometric_name IS NOT NULL)
    ),
    CONSTRAINT check_value_source CHECK (
        current_value_source IN ('questionnaire', 'tracked', 'clinician')
    ),
    CONSTRAINT unique_patient_question UNIQUE (patient_id, question_number),
    CONSTRAINT unique_patient_biometric UNIQUE (patient_id, biometric_name)
);

-- Indexes for efficient lookups
CREATE INDEX idx_patient_behavioral_values_patient
ON public.patient_behavioral_values(patient_id)
WHERE is_active = true;

CREATE INDEX idx_patient_behavioral_values_question
ON public.patient_behavioral_values(question_number)
WHERE question_number IS NOT NULL AND is_active = true;

CREATE INDEX idx_patient_behavioral_values_biometric
ON public.patient_behavioral_values(biometric_name)
WHERE biometric_name IS NOT NULL AND is_active = true;

CREATE INDEX idx_patient_behavioral_values_source
ON public.patient_behavioral_values(current_value_source)
WHERE is_active = true;

CREATE INDEX idx_patient_behavioral_values_updated
ON public.patient_behavioral_values(last_updated_at DESC)
WHERE is_active = true;

-- RLS Policies
ALTER TABLE public.patient_behavioral_values ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own behavioral values"
ON public.patient_behavioral_values
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all behavioral values"
ON public.patient_behavioral_values
FOR ALL
TO service_role
USING (true);

-- Grants
GRANT SELECT ON public.patient_behavioral_values TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.patient_behavioral_values TO service_role;

-- Comments
COMMENT ON TABLE public.patient_behavioral_values IS
'Stores current behavioral values for each patient, tracking whether values come from questionnaires or tracked data';

COMMENT ON COLUMN public.patient_behavioral_values.current_value IS
'Current numeric value being used for scoring (could be from questionnaire or tracked data)';

COMMENT ON COLUMN public.patient_behavioral_values.current_value_source IS
'Source of current value: questionnaire (initial survey), tracked (from data_entry_fields), or clinician (from provider entry)';

COMMENT ON COLUMN public.patient_behavioral_values.data_points_count IS
'Number of individual data points that contributed to current_value (0 for questionnaire, 15+ for tracked)';

COMMENT ON COLUMN public.patient_behavioral_values.lookback_period_start IS
'Start of the period used to calculate current_value (NULL for questionnaire responses)';

COMMENT ON COLUMN public.patient_behavioral_values.original_questionnaire_value IS
'Preserve the original questionnaire response value for reference/fallback';

SELECT '✅ Created patient_behavioral_values table' as status;
