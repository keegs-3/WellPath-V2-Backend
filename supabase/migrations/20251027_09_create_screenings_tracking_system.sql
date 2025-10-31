-- Create screenings tracking system
-- Allows tracking of health screenings and automatically updates behavioral values history

-- =====================================================
-- 1. SCREENING TYPES REFERENCE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.screening_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    screening_type_id TEXT UNIQUE NOT NULL,
    screening_name TEXT NOT NULL,
    description TEXT,

    -- Related survey question
    survey_question_number NUMERIC(5,2) REFERENCES survey_questions_base(question_number) ON DELETE SET NULL,

    -- Recommended frequency
    recommended_frequency_months INTEGER, -- How often this screening should be done

    -- Metadata
    category TEXT, -- 'cardiac', 'sleep', 'immunization', 'general'
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT check_category CHECK (
        category IN ('cardiac', 'sleep', 'immunization', 'cancer', 'metabolic', 'cognitive', 'general')
    )
);

-- Index
CREATE INDEX idx_screening_types_category ON public.screening_types(category);
CREATE INDEX idx_screening_types_survey_q ON public.screening_types(survey_question_number);

-- =====================================================
-- 2. PATIENT SCREENINGS HISTORY
-- =====================================================
CREATE TABLE IF NOT EXISTS public.patient_screenings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- Screening details
    screening_type_id TEXT NOT NULL REFERENCES screening_types(screening_type_id) ON DELETE CASCADE,

    -- Results
    screening_status TEXT NOT NULL, -- 'completed', 'scheduled', 'declined', 'overdue'
    screening_date TIMESTAMP WITH TIME ZONE, -- When screening was done
    next_due_date TIMESTAMP WITH TIME ZONE, -- When next screening is due

    -- Results details (optional)
    result_summary TEXT,
    result_details JSONB, -- Structured results if applicable

    -- Data source
    data_source TEXT NOT NULL, -- 'clinician_web', 'wellpath_app', 'patient_reported'
    source_metadata JSONB,

    -- Timestamps
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Metadata
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT check_screening_status CHECK (
        screening_status IN ('completed', 'scheduled', 'declined', 'overdue', 'pending')
    ),
    CONSTRAINT check_data_source_screening CHECK (
        data_source IN ('clinician_web', 'wellpath_app', 'patient_reported', 'imported')
    )
);

-- Indexes
CREATE INDEX idx_patient_screenings_patient_type
ON public.patient_screenings(patient_id, screening_type_id, screening_date DESC);

CREATE INDEX idx_patient_screenings_screening_date
ON public.patient_screenings(screening_date DESC);

CREATE INDEX idx_patient_screenings_next_due_date
ON public.patient_screenings(next_due_date) WHERE screening_status != 'completed';

CREATE INDEX idx_patient_screenings_status
ON public.patient_screenings(screening_status);

-- =====================================================
-- 3. VIEW FOR CURRENT SCREENING STATUS
-- =====================================================
CREATE OR REPLACE VIEW public.patient_screenings_current AS
SELECT DISTINCT ON (patient_id, screening_type_id)
    id,
    patient_id,
    screening_type_id,
    screening_status,
    screening_date,
    next_due_date,
    result_summary,
    result_details,
    data_source,
    source_metadata,
    recorded_at,
    notes
FROM public.patient_screenings
WHERE is_active = true
ORDER BY patient_id, screening_type_id, screening_date DESC NULLS LAST, recorded_at DESC;

-- =====================================================
-- 4. FUNCTION TO UPDATE BEHAVIORAL VALUES FROM SCREENING
-- =====================================================
CREATE OR REPLACE FUNCTION public.update_behavioral_values_from_screening()
RETURNS TRIGGER AS $$
DECLARE
    v_survey_question_number NUMERIC(5,2);
    v_response_option_id UUID;
    v_score NUMERIC;
BEGIN
    -- Get the survey question number for this screening type
    SELECT survey_question_number
    INTO v_survey_question_number
    FROM screening_types
    WHERE screening_type_id = NEW.screening_type_id;

    -- Only proceed if there's a linked survey question
    IF v_survey_question_number IS NOT NULL THEN
        -- Determine score based on screening status
        CASE NEW.screening_status
            WHEN 'completed' THEN
                v_score := 1.0; -- "Yes" - screening completed
            WHEN 'scheduled' THEN
                v_score := 0.8; -- Scheduled but not yet done
            WHEN 'declined', 'overdue', 'pending' THEN
                v_score := 0.2; -- "No" - not completed
            ELSE
                v_score := 0.2; -- Default to "No"
        END CASE;

        -- Find the closest matching survey response option
        SELECT id INTO v_response_option_id
        FROM survey_response_options
        WHERE question_number = v_survey_question_number
        ORDER BY ABS(score - v_score)
        LIMIT 1;

        -- Insert into behavioral values history
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
            NEW.patient_id,
            v_survey_question_number,
            v_response_option_id,
            v_score,
            'Updated from screening: ' || NEW.screening_type_id || ' (' || NEW.screening_status || ')',
            CASE NEW.data_source
                WHEN 'clinician_web' THEN 'clinician_entry'
                WHEN 'wellpath_app' THEN 'check_in_update'
                ELSE 'check_in_update'
            END,
            jsonb_build_object(
                'screening_type_id', NEW.screening_type_id,
                'screening_status', NEW.screening_status,
                'screening_date', NEW.screening_date,
                'original_data_source', NEW.data_source,
                'screening_record_id', NEW.id
            ),
            COALESCE(NEW.screening_date, NEW.recorded_at),
            NOW()
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. TRIGGER TO AUTO-UPDATE FROM SCREENINGS
-- =====================================================
CREATE TRIGGER after_screening_insert
AFTER INSERT ON public.patient_screenings
FOR EACH ROW
EXECUTE FUNCTION public.update_behavioral_values_from_screening();

CREATE TRIGGER after_screening_update
AFTER UPDATE OF screening_status, screening_date ON public.patient_screenings
FOR EACH ROW
WHEN (OLD.screening_status IS DISTINCT FROM NEW.screening_status
      OR OLD.screening_date IS DISTINCT FROM NEW.screening_date)
EXECUTE FUNCTION public.update_behavioral_values_from_screening();

-- =====================================================
-- 6. RLS POLICIES
-- =====================================================

-- screening_types (read-only for all authenticated users)
ALTER TABLE public.screening_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All users can read screening types"
ON public.screening_types
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Service role can manage screening types"
ON public.screening_types
FOR ALL
TO service_role
USING (true);

-- patient_screenings
ALTER TABLE public.patient_screenings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own screenings"
ON public.patient_screenings
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Users can insert own screenings"
ON public.patient_screenings
FOR INSERT
TO authenticated
WITH CHECK (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all screenings"
ON public.patient_screenings
FOR ALL
TO service_role
USING (true);

-- =====================================================
-- 7. GRANTS
-- =====================================================

GRANT SELECT ON public.screening_types TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.screening_types TO service_role;

GRANT SELECT, INSERT ON public.patient_screenings TO authenticated;
GRANT UPDATE, DELETE ON public.patient_screenings TO service_role;

GRANT SELECT ON public.patient_screenings_current TO authenticated, service_role;

GRANT EXECUTE ON FUNCTION public.update_behavioral_values_from_screening TO service_role, authenticated;

-- =====================================================
-- 8. COMMENTS
-- =====================================================

COMMENT ON TABLE public.screening_types IS
'Reference table for health screening types (cardiac, sleep, immunizations, etc.). Links to survey questions for scoring integration.';

COMMENT ON TABLE public.patient_screenings IS
'Tracks patient health screenings. When screenings are recorded, automatically updates behavioral values history via linked survey questions.';

COMMENT ON VIEW public.patient_screenings_current IS
'Current (latest) screening status per patient per screening type.';

COMMENT ON FUNCTION public.update_behavioral_values_from_screening IS
'When a screening is recorded, creates behavioral values history entry for the linked survey question. Status "completed" → "Yes" (1.0), others → "No" (0.2).';

SELECT '✅ Created screenings tracking system' as status;
