-- Create mapping system between check-ins and survey questions
-- Allows check-in responses to automatically update patient_behavioral_values_history

-- =====================================================
-- 1. SURVEY QUESTIONS TO CHECK-IN QUESTIONS MAPPING
-- =====================================================
-- Maps which check-in questions can update which survey questions
CREATE TABLE IF NOT EXISTS public.survey_questions_checkin_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Survey question being updated
    survey_question_number NUMERIC(5,2) NOT NULL REFERENCES survey_questions_base(question_number) ON DELETE CASCADE,

    -- Check-in question providing the update
    checkin_question_id TEXT NOT NULL,

    -- How to convert check-in response to survey score
    conversion_method TEXT NOT NULL, -- 'direct', 'scaled', 'threshold', 'custom'
    conversion_config JSONB, -- Configuration for conversion method

    -- Optionally map specific check-in response options to survey response options
    checkin_response_to_survey_response JSONB, -- e.g., {"checkin_option_id": "survey_response_option_id"}

    -- Thresholds and conditions
    min_checkin_responses INTEGER DEFAULT 1, -- Minimum check-in responses needed before updating
    lookback_days INTEGER DEFAULT 14, -- How far back to look for check-in responses
    update_frequency TEXT DEFAULT 'weekly', -- How often to recalculate: 'daily', 'weekly', 'monthly'

    -- Metadata
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT check_conversion_method CHECK (
        conversion_method IN ('direct', 'scaled', 'threshold', 'custom')
    ),
    CONSTRAINT check_update_frequency CHECK (
        update_frequency IN ('daily', 'weekly', 'monthly')
    )
);

-- Indexes
CREATE INDEX idx_survey_checkin_mappings_survey_q
ON public.survey_questions_checkin_mappings(survey_question_number);

CREATE INDEX idx_survey_checkin_mappings_checkin_q
ON public.survey_questions_checkin_mappings(checkin_question_id);

-- =====================================================
-- 2. PATIENT CHECK-IN RESPONSES HISTORY
-- =====================================================
-- Track when patients complete check-ins (if not already tracked)
CREATE TABLE IF NOT EXISTS public.patient_checkin_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- Check-in details
    checkin_id TEXT NOT NULL,
    checkin_question_id TEXT NOT NULL,

    -- Response
    response_value NUMERIC, -- Numeric value if applicable
    response_text TEXT, -- Text response if applicable
    response_option_id TEXT, -- Selected option ID

    -- Timestamps
    completed_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Metadata
    source_metadata JSONB,
    is_active BOOLEAN NOT NULL DEFAULT true
);

-- Indexes
CREATE INDEX idx_patient_checkin_responses_patient_question
ON public.patient_checkin_responses(patient_id, checkin_question_id, completed_at DESC);

CREATE INDEX idx_patient_checkin_responses_completed_at
ON public.patient_checkin_responses(completed_at DESC);

-- =====================================================
-- 3. FUNCTION TO UPDATE BEHAVIORAL VALUES FROM CHECK-INS
-- =====================================================
CREATE OR REPLACE FUNCTION public.update_behavioral_values_from_checkin(
    p_patient_id UUID,
    p_checkin_question_id TEXT,
    p_response_value NUMERIC,
    p_completed_at TIMESTAMP WITH TIME ZONE
) RETURNS void AS $$
DECLARE
    v_mapping RECORD;
    v_avg_response NUMERIC;
    v_converted_score NUMERIC;
    v_survey_response_option_id UUID;
BEGIN
    -- Find all survey questions mapped to this check-in question
    FOR v_mapping IN
        SELECT
            sqcm.survey_question_number,
            sqcm.conversion_method,
            sqcm.conversion_config,
            sqcm.checkin_response_to_survey_response,
            sqcm.min_checkin_responses,
            sqcm.lookback_days
        FROM survey_questions_checkin_mappings sqcm
        WHERE sqcm.checkin_question_id = p_checkin_question_id
          AND sqcm.is_active = true
    LOOP
        -- Calculate average response over lookback period
        SELECT AVG(response_value)
        INTO v_avg_response
        FROM patient_checkin_responses
        WHERE patient_id = p_patient_id
          AND checkin_question_id = p_checkin_question_id
          AND completed_at >= (p_completed_at - (v_mapping.lookback_days || ' days')::INTERVAL)
          AND completed_at <= p_completed_at
          AND is_active = true;

        -- Only proceed if we have enough responses
        IF (SELECT COUNT(*) FROM patient_checkin_responses
            WHERE patient_id = p_patient_id
              AND checkin_question_id = p_checkin_question_id
              AND completed_at >= (p_completed_at - (v_mapping.lookback_days || ' days')::INTERVAL)
              AND completed_at <= p_completed_at
              AND is_active = true) >= v_mapping.min_checkin_responses
        THEN
            -- Convert check-in response to survey score based on method
            CASE v_mapping.conversion_method
                WHEN 'direct' THEN
                    -- Direct mapping: use the response value as the score
                    v_converted_score := v_avg_response;

                WHEN 'scaled' THEN
                    -- Scaled mapping: apply scaling factor from config
                    v_converted_score := v_avg_response * COALESCE((v_mapping.conversion_config->>'scale_factor')::NUMERIC, 1.0);

                WHEN 'threshold' THEN
                    -- Threshold mapping: check if above/below threshold
                    IF v_avg_response >= COALESCE((v_mapping.conversion_config->>'threshold')::NUMERIC, 0.5) THEN
                        v_converted_score := COALESCE((v_mapping.conversion_config->>'score_if_above')::NUMERIC, 1.0);
                    ELSE
                        v_converted_score := COALESCE((v_mapping.conversion_config->>'score_if_below')::NUMERIC, 0.2);
                    END IF;

                ELSE
                    -- Default: use the average as-is
                    v_converted_score := v_avg_response;
            END CASE;

            -- Find the closest matching survey response option based on score
            SELECT id INTO v_survey_response_option_id
            FROM survey_response_options
            WHERE question_number = v_mapping.survey_question_number
            ORDER BY ABS(score - v_converted_score)
            LIMIT 1;

            -- Insert new entry in behavioral values history
            INSERT INTO patient_behavioral_values_history (
                patient_id,
                question_number,
                response_option_id,
                response_value,
                response_text,
                data_source,
                source_metadata,
                effective_date,
                created_at
            )
            VALUES (
                p_patient_id,
                v_mapping.survey_question_number,
                v_survey_response_option_id,
                v_converted_score,
                'Updated from check-in: ' || p_checkin_question_id,
                'check_in_update',
                jsonb_build_object(
                    'checkin_question_id', p_checkin_question_id,
                    'avg_response', v_avg_response,
                    'lookback_days', v_mapping.lookback_days,
                    'conversion_method', v_mapping.conversion_method
                ),
                p_completed_at,
                NOW()
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. TRIGGER TO AUTO-UPDATE FROM CHECK-INS
-- =====================================================
CREATE OR REPLACE FUNCTION public.trigger_update_from_checkin()
RETURNS TRIGGER AS $$
BEGIN
    -- Call the update function when a new check-in response is recorded
    PERFORM update_behavioral_values_from_checkin(
        NEW.patient_id,
        NEW.checkin_question_id,
        NEW.response_value,
        NEW.completed_at
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_checkin_response_insert
AFTER INSERT ON public.patient_checkin_responses
FOR EACH ROW
EXECUTE FUNCTION public.trigger_update_from_checkin();

-- =====================================================
-- 5. RLS POLICIES
-- =====================================================

-- survey_questions_checkin_mappings (read-only for authenticated users)
ALTER TABLE public.survey_questions_checkin_mappings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All users can read checkin mappings"
ON public.survey_questions_checkin_mappings
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Service role can manage checkin mappings"
ON public.survey_questions_checkin_mappings
FOR ALL
TO service_role
USING (true);

-- patient_checkin_responses
ALTER TABLE public.patient_checkin_responses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own checkin responses"
ON public.patient_checkin_responses
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all checkin responses"
ON public.patient_checkin_responses
FOR ALL
TO service_role
USING (true);

-- =====================================================
-- 6. GRANTS
-- =====================================================

GRANT SELECT ON public.survey_questions_checkin_mappings TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.survey_questions_checkin_mappings TO service_role;

GRANT SELECT ON public.patient_checkin_responses TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.patient_checkin_responses TO service_role;

GRANT EXECUTE ON FUNCTION public.update_behavioral_values_from_checkin TO service_role;

-- =====================================================
-- 7. COMMENTS
-- =====================================================

COMMENT ON TABLE public.survey_questions_checkin_mappings IS
'Maps check-in questions to survey questions. When patients complete check-ins, their responses automatically update behavioral values history.';

COMMENT ON TABLE public.patient_checkin_responses IS
'Tracks patient responses to check-in questions. Triggers automatic updates to behavioral values history via mapped survey questions.';

COMMENT ON FUNCTION public.update_behavioral_values_from_checkin IS
'Calculates average check-in responses over lookback period, converts to survey score, and creates new behavioral values history entry.';

SELECT '✅ Created check-in to survey question mapping system' as status;
