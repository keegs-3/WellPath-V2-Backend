-- Create unified value history architecture
-- Provides append-only historical tracking for all patient values with data source transparency

-- =====================================================
-- 1. BEHAVIORAL VALUES HISTORY
-- =====================================================
-- Tracks survey question responses, check-in updates, and tracked data auto-updates
CREATE TABLE IF NOT EXISTS public.patient_behavioral_values_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- What this response is for
    question_number NUMERIC(5,2) NOT NULL REFERENCES survey_questions_base(question_number) ON DELETE CASCADE,

    -- The actual response
    response_option_id UUID REFERENCES survey_response_options(id) ON DELETE SET NULL,
    response_value NUMERIC NOT NULL, -- The score/numeric value
    response_text TEXT, -- Optional text for context

    -- Data source tracking
    data_source TEXT NOT NULL, -- 'questionnaire_initial', 'tracked_data_auto_update', 'check_in_update', 'clinician_entry'
    source_metadata JSONB, -- Additional context: {agg_metric_id, check_in_id, etc.}

    -- Timestamps
    effective_date TIMESTAMP WITH TIME ZONE NOT NULL, -- When this value became effective
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), -- When this history row was created

    -- Metadata
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT check_data_source_behavioral CHECK (
        data_source IN ('questionnaire_initial', 'tracked_data_auto_update', 'check_in_update', 'clinician_entry')
    )
);

-- Indexes for efficient querying
CREATE INDEX idx_behavioral_history_patient_question
ON public.patient_behavioral_values_history(patient_id, question_number, effective_date DESC);

CREATE INDEX idx_behavioral_history_effective_date
ON public.patient_behavioral_values_history(effective_date DESC);

CREATE INDEX idx_behavioral_history_data_source
ON public.patient_behavioral_values_history(data_source);

-- View for current (latest) values
CREATE OR REPLACE VIEW public.patient_behavioral_values_current AS
SELECT DISTINCT ON (patient_id, question_number)
    id,
    patient_id,
    question_number,
    response_option_id,
    response_value,
    response_text,
    data_source,
    source_metadata,
    effective_date,
    created_at,
    notes
FROM public.patient_behavioral_values_history
WHERE is_active = true
ORDER BY patient_id, question_number, effective_date DESC, created_at DESC;

-- =====================================================
-- 2. MARKER VALUES HISTORY (Biomarkers + Biometrics pooled)
-- =====================================================
-- Tracks biomarkers and biometrics from clinician web and wellpath app
CREATE TABLE IF NOT EXISTS public.patient_marker_values_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- What type of marker
    marker_type TEXT NOT NULL, -- 'biomarker' or 'biometric'
    marker_name TEXT NOT NULL, -- e.g., 'LDL Cholesterol', 'Weight', 'VO2 Max'

    -- The value
    marker_value NUMERIC NOT NULL,
    marker_unit TEXT, -- e.g., 'mg/dL', 'kg', 'mL/kg/min'

    -- Data source tracking
    data_source TEXT NOT NULL, -- 'clinician_web', 'wellpath_app'
    source_metadata JSONB, -- Additional context

    -- Timestamps
    reading_date TIMESTAMP WITH TIME ZONE NOT NULL, -- When the actual measurement was taken
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(), -- When this history row was created

    -- Metadata
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT check_marker_type CHECK (marker_type IN ('biomarker', 'biometric')),
    CONSTRAINT check_data_source_marker CHECK (data_source IN ('clinician_web', 'wellpath_app'))
);

-- Indexes for efficient querying
CREATE INDEX idx_marker_history_patient_marker
ON public.patient_marker_values_history(patient_id, marker_type, marker_name, reading_date DESC);

CREATE INDEX idx_marker_history_reading_date
ON public.patient_marker_values_history(reading_date DESC);

CREATE INDEX idx_marker_history_marker_type
ON public.patient_marker_values_history(marker_type);

CREATE INDEX idx_marker_history_data_source
ON public.patient_marker_values_history(data_source);

-- View for current (latest) values
CREATE OR REPLACE VIEW public.patient_marker_values_current AS
SELECT DISTINCT ON (patient_id, marker_type, marker_name)
    id,
    patient_id,
    marker_type,
    marker_name,
    marker_value,
    marker_unit,
    data_source,
    source_metadata,
    reading_date,
    created_at,
    notes
FROM public.patient_marker_values_history
WHERE is_active = true
ORDER BY patient_id, marker_type, marker_name, reading_date DESC, created_at DESC;

-- =====================================================
-- 3. EDUCATION VALUES HISTORY
-- =====================================================
-- Tracks education module completion
CREATE TABLE IF NOT EXISTS public.patient_education_values_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- What education item
    education_item_id TEXT NOT NULL, -- Reference to education content
    education_item_title TEXT,

    -- Completion status
    completion_status TEXT NOT NULL, -- 'started', 'in_progress', 'completed'
    completion_percentage NUMERIC, -- 0-100
    completion_date TIMESTAMP WITH TIME ZONE,

    -- Data source tracking
    data_source TEXT NOT NULL, -- 'wellpath_app', 'wellpath_web'
    source_metadata JSONB,

    -- Timestamps
    effective_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Metadata
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT check_completion_status CHECK (
        completion_status IN ('started', 'in_progress', 'completed')
    ),
    CONSTRAINT check_data_source_education CHECK (
        data_source IN ('wellpath_app', 'wellpath_web')
    )
);

-- Indexes for efficient querying
CREATE INDEX idx_education_history_patient_item
ON public.patient_education_values_history(patient_id, education_item_id, effective_date DESC);

CREATE INDEX idx_education_history_completion_status
ON public.patient_education_values_history(completion_status);

CREATE INDEX idx_education_history_effective_date
ON public.patient_education_values_history(effective_date DESC);

-- View for current (latest) values
CREATE OR REPLACE VIEW public.patient_education_values_current AS
SELECT DISTINCT ON (patient_id, education_item_id)
    id,
    patient_id,
    education_item_id,
    education_item_title,
    completion_status,
    completion_percentage,
    completion_date,
    data_source,
    source_metadata,
    effective_date,
    created_at,
    notes
FROM public.patient_education_values_history
WHERE is_active = true
ORDER BY patient_id, education_item_id, effective_date DESC, created_at DESC;

-- =====================================================
-- 4. RLS POLICIES
-- =====================================================

-- Behavioral values history
ALTER TABLE public.patient_behavioral_values_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own behavioral history"
ON public.patient_behavioral_values_history
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all behavioral history"
ON public.patient_behavioral_values_history
FOR ALL
TO service_role
USING (true);

-- Marker values history
ALTER TABLE public.patient_marker_values_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own marker history"
ON public.patient_marker_values_history
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all marker history"
ON public.patient_marker_values_history
FOR ALL
TO service_role
USING (true);

-- Education values history
ALTER TABLE public.patient_education_values_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own education history"
ON public.patient_education_values_history
FOR SELECT
TO authenticated
USING (patient_id = auth.uid()::uuid);

CREATE POLICY "Service role can manage all education history"
ON public.patient_education_values_history
FOR ALL
TO service_role
USING (true);

-- =====================================================
-- 5. GRANTS
-- =====================================================

-- Behavioral
GRANT SELECT ON public.patient_behavioral_values_history TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.patient_behavioral_values_history TO service_role;
GRANT SELECT ON public.patient_behavioral_values_current TO authenticated, service_role;

-- Marker
GRANT SELECT ON public.patient_marker_values_history TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.patient_marker_values_history TO service_role;
GRANT SELECT ON public.patient_marker_values_current TO authenticated, service_role;

-- Education
GRANT SELECT ON public.patient_education_values_history TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.patient_education_values_history TO service_role;
GRANT SELECT ON public.patient_education_values_current TO authenticated, service_role;

-- =====================================================
-- 6. COMMENTS
-- =====================================================

COMMENT ON TABLE public.patient_behavioral_values_history IS
'Append-only history of all behavioral values (survey responses, check-ins, tracked data updates). New row on every change.';

COMMENT ON TABLE public.patient_marker_values_history IS
'Append-only history of all biomarkers and biometrics (pooled). New row on every reading.';

COMMENT ON TABLE public.patient_education_values_history IS
'Append-only history of education module completion. New row on every status change.';

COMMENT ON COLUMN public.patient_behavioral_values_history.data_source IS
'Source: questionnaire_initial (first survey), tracked_data_auto_update (from agg metrics), check_in_update (from check-ins), clinician_entry (manual)';

COMMENT ON COLUMN public.patient_marker_values_history.marker_type IS
'Type of marker: biomarker (lab results) or biometric (measurements like weight, VO2 max)';

COMMENT ON COLUMN public.patient_marker_values_history.data_source IS
'Source: clinician_web (from provider portal) or wellpath_app (from mobile app)';

SELECT '✅ Created unified value history tables (behavioral, marker, education) with current views' as status;
