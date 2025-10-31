-- Create normalized history tables for pillar and component scores
-- Replaces JSONB pillar_scores with queryable, chartable history tables

-- =====================================================
-- 1. Pillar Scores History
-- =====================================================
CREATE TABLE IF NOT EXISTS public.patient_pillar_scores_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    pillar_id TEXT NOT NULL REFERENCES pillars_base(pillar_id) ON DELETE CASCADE,

    -- Scores
    pillar_score NUMERIC NOT NULL,
    pillar_max_score NUMERIC NOT NULL,
    pillar_percentage NUMERIC NOT NULL,

    -- Item breakdown
    item_count INTEGER NOT NULL,
    biomarker_count INTEGER DEFAULT 0,
    biometric_count INTEGER DEFAULT 0,
    survey_question_count INTEGER DEFAULT 0,
    survey_function_count INTEGER DEFAULT 0,
    education_count INTEGER DEFAULT 0,

    -- Metadata
    calculated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    calculation_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX idx_pillar_scores_history_patient_pillar
ON public.patient_pillar_scores_history(patient_id, pillar_id, calculated_at DESC);

CREATE INDEX idx_pillar_scores_history_calculated_at
ON public.patient_pillar_scores_history(calculated_at DESC);

-- =====================================================
-- 2. Component Scores History (Markers/Behaviors/Education)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.patient_component_scores_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    pillar_id TEXT NOT NULL REFERENCES pillars_base(pillar_id) ON DELETE CASCADE,

    -- Component type
    component_type TEXT NOT NULL, -- 'markers', 'behaviors', 'education'

    -- Scores
    component_score NUMERIC NOT NULL,
    component_max_score NUMERIC NOT NULL,
    component_percentage NUMERIC NOT NULL,

    -- Item breakdown
    item_count INTEGER NOT NULL,
    biomarker_count INTEGER DEFAULT 0,
    biometric_count INTEGER DEFAULT 0,
    survey_question_count INTEGER DEFAULT 0,
    survey_function_count INTEGER DEFAULT 0,
    education_count INTEGER DEFAULT 0,

    -- Metadata
    calculated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    calculation_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT check_component_type CHECK (
        component_type IN ('markers', 'behaviors', 'education')
    )
);

-- Indexes for efficient querying
CREATE INDEX idx_component_scores_history_patient_pillar_component
ON public.patient_component_scores_history(patient_id, pillar_id, component_type, calculated_at DESC);

CREATE INDEX idx_component_scores_history_calculated_at
ON public.patient_component_scores_history(calculated_at DESC);

-- =====================================================
-- 3. Latest Scores Views
-- =====================================================

-- Latest pillar scores per patient
CREATE OR REPLACE VIEW public.patient_pillar_scores_latest AS
SELECT DISTINCT ON (patient_id, pillar_id)
    id,
    patient_id,
    pillar_id,
    pillar_score,
    pillar_max_score,
    pillar_percentage,
    item_count,
    biomarker_count,
    biometric_count,
    survey_question_count,
    survey_function_count,
    education_count,
    calculated_at,
    calculation_version
FROM public.patient_pillar_scores_history
ORDER BY patient_id, pillar_id, calculated_at DESC;

-- Latest component scores per patient/pillar/component
CREATE OR REPLACE VIEW public.patient_component_scores_latest AS
SELECT DISTINCT ON (patient_id, pillar_id, component_type)
    id,
    patient_id,
    pillar_id,
    component_type,
    component_score,
    component_max_score,
    component_percentage,
    item_count,
    biomarker_count,
    biometric_count,
    survey_question_count,
    survey_function_count,
    education_count,
    calculated_at,
    calculation_version
FROM public.patient_component_scores_history
ORDER BY patient_id, pillar_id, component_type, calculated_at DESC;

-- =====================================================
-- 4. RLS Policies
-- =====================================================

-- Pillar scores history
ALTER TABLE public.patient_pillar_scores_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own pillar score history"
ON public.patient_pillar_scores_history
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all pillar score history"
ON public.patient_pillar_scores_history
FOR ALL
TO service_role
USING (true);

-- Component scores history
ALTER TABLE public.patient_component_scores_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own component score history"
ON public.patient_component_scores_history
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all component score history"
ON public.patient_component_scores_history
FOR ALL
TO service_role
USING (true);

-- =====================================================
-- 5. Grants
-- =====================================================

GRANT SELECT ON public.patient_pillar_scores_history TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.patient_pillar_scores_history TO service_role;

GRANT SELECT ON public.patient_component_scores_history TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.patient_component_scores_history TO service_role;

GRANT SELECT ON public.patient_pillar_scores_latest TO authenticated, service_role;
GRANT SELECT ON public.patient_component_scores_latest TO authenticated, service_role;

-- =====================================================
-- 6. Comments
-- =====================================================

COMMENT ON TABLE public.patient_pillar_scores_history IS
'Historical record of pillar scores over time - enables trend charts for each pillar';

COMMENT ON TABLE public.patient_component_scores_history IS
'Historical record of component (markers/behaviors/education) scores within each pillar over time';

COMMENT ON COLUMN public.patient_component_scores_history.component_type IS
'Component type: markers (biomarkers/biometrics), behaviors (survey questions/functions), education (learning modules)';

SELECT '✅ Created normalized score history tables for pillar and component tracking' as status;
