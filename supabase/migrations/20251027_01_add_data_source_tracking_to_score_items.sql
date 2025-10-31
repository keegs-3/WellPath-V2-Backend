-- Add data source tracking columns to patient_wellpath_score_items
-- This enables transparency about where each score item's data came from

-- Add new columns
ALTER TABLE public.patient_wellpath_score_items
ADD COLUMN IF NOT EXISTS data_source TEXT,
ADD COLUMN IF NOT EXISTS source_updated_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS data_points_count INTEGER DEFAULT 0;

-- Create index on data_source for filtering
CREATE INDEX IF NOT EXISTS idx_score_items_data_source
ON public.patient_wellpath_score_items(data_source)
WHERE data_source IS NOT NULL;

-- Create index on source_updated_at for temporal queries
CREATE INDEX IF NOT EXISTS idx_score_items_source_updated_at
ON public.patient_wellpath_score_items(source_updated_at)
WHERE source_updated_at IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN public.patient_wellpath_score_items.data_source IS
'Source of this score item data: questionnaire_initial, clinician_biomarker, clinician_biometric, tracked_biometric, tracked_behavior';

COMMENT ON COLUMN public.patient_wellpath_score_items.source_updated_at IS
'Timestamp when the data source was last updated or changed';

COMMENT ON COLUMN public.patient_wellpath_score_items.data_points_count IS
'Number of individual data points that contributed to this score (0 for single-point sources like questionnaires)';

-- Update existing records to have a data_source based on item_type
UPDATE public.patient_wellpath_score_items
SET
    data_source = CASE
        WHEN item_type = 'biomarker' THEN 'clinician_biomarker'
        WHEN item_type = 'biometric' THEN 'clinician_biometric'
        WHEN item_type = 'survey_question' THEN 'questionnaire_initial'
        WHEN item_type = 'survey_function' THEN 'questionnaire_initial'
        WHEN item_type = 'education' THEN 'education_completion'
        ELSE 'unknown'
    END,
    source_updated_at = scored_at,
    data_points_count = 1
WHERE data_source IS NULL;

SELECT '✅ Added data source tracking columns to patient_wellpath_score_items' as status;
