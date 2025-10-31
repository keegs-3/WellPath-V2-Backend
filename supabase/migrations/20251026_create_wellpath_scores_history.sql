-- Create table to track WellPath scores over time
-- This table stores the overall pillar scores and keeps historical records

CREATE TABLE IF NOT EXISTS public.patient_wellpath_scores (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- Overall score
    overall_score numeric NOT NULL,
    overall_max_score numeric NOT NULL,
    overall_percentage numeric NOT NULL,

    -- Pillar scores (stored as JSONB for flexibility)
    pillar_scores jsonb NOT NULL,
    -- Format: [
    --   {"pillar_name": "Core Care", "score": 0.9, "max": 0.9, "percentage": 100.0, "item_count": 72},
    --   ...
    -- ]

    -- Counts
    total_items_scored integer NOT NULL,
    biomarker_count integer NOT NULL DEFAULT 0,
    biometric_count integer NOT NULL DEFAULT 0,
    survey_question_count integer NOT NULL DEFAULT 0,
    survey_function_count integer NOT NULL DEFAULT 0,

    -- Metadata
    calculation_version text NOT NULL DEFAULT '3.0',
    calculated_at timestamp with time zone NOT NULL DEFAULT now(),

    -- Index for querying
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Indexes for performance
CREATE INDEX idx_patient_wellpath_scores_patient_id ON public.patient_wellpath_scores(patient_id);
CREATE INDEX idx_patient_wellpath_scores_calculated_at ON public.patient_wellpath_scores(calculated_at DESC);
CREATE INDEX idx_patient_wellpath_scores_patient_calculated ON public.patient_wellpath_scores(patient_id, calculated_at DESC);

-- RLS Policies
ALTER TABLE public.patient_wellpath_scores ENABLE ROW LEVEL SECURITY;

-- Patients can read their own scores
CREATE POLICY "Patients can read their own WellPath scores"
ON public.patient_wellpath_scores
FOR SELECT
TO authenticated
USING (
    patient_id IN (
        SELECT patient_id FROM patients WHERE patient_id = auth.uid()
    )
);

-- Practice users can read scores for their patients
CREATE POLICY "Practice users can read accessible patient scores"
ON public.patient_wellpath_scores
FOR SELECT
TO authenticated
USING (
    patient_id IN (
        SELECT p.patient_id
        FROM patients p
        INNER JOIN patient_practice_assignments ppa ON p.patient_id = ppa.patient_id
        INNER JOIN practice_users pu ON ppa.practice_id = pu.practice_id
        WHERE pu.user_id = auth.uid()
    )
);

-- Service role can do everything
CREATE POLICY "Service role can manage all scores"
ON public.patient_wellpath_scores
FOR ALL
TO service_role
USING (true);

-- Grant permissions
GRANT SELECT ON public.patient_wellpath_scores TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.patient_wellpath_scores TO service_role;

-- Create a view to get the latest score for each patient
CREATE OR REPLACE VIEW public.patient_wellpath_scores_latest AS
SELECT DISTINCT ON (patient_id)
    id,
    patient_id,
    overall_score,
    overall_max_score,
    overall_percentage,
    pillar_scores,
    total_items_scored,
    biomarker_count,
    biometric_count,
    survey_question_count,
    survey_function_count,
    calculation_version,
    calculated_at,
    created_at
FROM public.patient_wellpath_scores
ORDER BY patient_id, calculated_at DESC;

-- Grant permissions on view
GRANT SELECT ON public.patient_wellpath_scores_latest TO authenticated;
GRANT SELECT ON public.patient_wellpath_scores_latest TO service_role;

-- RLS for view (inherits from base table)
ALTER VIEW public.patient_wellpath_scores_latest SET (security_invoker = true);

SELECT '✅ Created patient_wellpath_scores table with history tracking' as status;
