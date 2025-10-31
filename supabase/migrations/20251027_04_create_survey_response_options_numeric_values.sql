-- Create survey_response_options_numeric_values table
-- Stores numeric conversions of categorical survey response options
-- Enables behavioral scoring by converting "rarely or never" → numeric value

CREATE TABLE IF NOT EXISTS public.survey_response_options_numeric_values (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Link to the survey response option
    response_option_id UUID NOT NULL REFERENCES survey_response_options(id) ON DELETE CASCADE,
    question_number NUMERIC NOT NULL REFERENCES survey_questions_base(question_number) ON DELETE CASCADE,

    -- Numeric conversion
    numeric_value NUMERIC NOT NULL,
    numeric_value_unit TEXT, -- Unit for the numeric value (e.g., 'days/month', 'servings/day', 'hours/night')

    -- Optional range (for responses that represent a range)
    value_range_low NUMERIC,
    value_range_high NUMERIC,

    -- Conversion metadata
    conversion_method TEXT, -- 'midpoint', 'conservative', 'optimistic', 'exact'
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT unique_response_option UNIQUE (response_option_id),
    CONSTRAINT check_conversion_method CHECK (
        conversion_method IN ('midpoint', 'conservative', 'optimistic', 'exact') OR conversion_method IS NULL
    )
);

-- Indexes
CREATE INDEX idx_survey_numeric_values_question
ON public.survey_response_options_numeric_values(question_number)
WHERE is_active = true;

CREATE INDEX idx_survey_numeric_values_response_option
ON public.survey_response_options_numeric_values(response_option_id)
WHERE is_active = true;

-- RLS Policies
ALTER TABLE public.survey_response_options_numeric_values ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read numeric conversions"
ON public.survey_response_options_numeric_values
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "Service role can manage numeric conversions"
ON public.survey_response_options_numeric_values
FOR ALL
TO service_role
USING (true);

-- Grants
GRANT SELECT ON public.survey_response_options_numeric_values TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.survey_response_options_numeric_values TO service_role;

-- Comments
COMMENT ON TABLE public.survey_response_options_numeric_values IS
'Stores numeric conversions of categorical survey responses for behavioral scoring';

COMMENT ON COLUMN public.survey_response_options_numeric_values.numeric_value IS
'Numeric equivalent of the categorical response (e.g., "rarely or never" whole grains = 2 days/month)';

COMMENT ON COLUMN public.survey_response_options_numeric_values.conversion_method IS
'Method used to convert: midpoint (middle of range), conservative (lower estimate), optimistic (higher estimate), exact (precise mapping)';

COMMENT ON COLUMN public.survey_response_options_numeric_values.value_range_low IS
'Lower bound of range this response represents (NULL if not a range)';

COMMENT ON COLUMN public.survey_response_options_numeric_values.value_range_high IS
'Upper bound of range this response represents (NULL if not a range)';

SELECT '✅ Created survey_response_options_numeric_values table' as status;
