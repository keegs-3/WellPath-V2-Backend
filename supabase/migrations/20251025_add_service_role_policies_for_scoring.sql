-- Add service_role policies for WellPath scoring edge function
-- This allows the edge function to access all necessary tables

-- Patients table
DROP POLICY IF EXISTS "Service role can read all patients" ON public.patients;
CREATE POLICY "Service role can read all patients"
ON public.patients
FOR SELECT
TO service_role
USING (true);

-- Patient wellpath score items (read and write)
DROP POLICY IF EXISTS "Service role can read score items" ON public.patient_wellpath_score_items;
CREATE POLICY "Service role can read score items"
ON public.patient_wellpath_score_items
FOR SELECT
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can insert score items" ON public.patient_wellpath_score_items;
CREATE POLICY "Service role can insert score items"
ON public.patient_wellpath_score_items
FOR INSERT
TO service_role
WITH CHECK (true);

DROP POLICY IF EXISTS "Service role can update score items" ON public.patient_wellpath_score_items;
CREATE POLICY "Service role can update score items"
ON public.patient_wellpath_score_items
FOR UPDATE
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can delete score items" ON public.patient_wellpath_score_items;
CREATE POLICY "Service role can delete score items"
ON public.patient_wellpath_score_items
FOR DELETE
TO service_role
USING (true);

-- Scoring weights tables
DROP POLICY IF EXISTS "Service role can read marker weights" ON public.wellpath_scoring_marker_pillar_weights_normalized;
CREATE POLICY "Service role can read marker weights"
ON public.wellpath_scoring_marker_pillar_weights_normalized
FOR SELECT
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can read question weights" ON public.wellpath_scoring_question_pillar_weights_normalized;
CREATE POLICY "Service role can read question weights"
ON public.wellpath_scoring_question_pillar_weights_normalized
FOR SELECT
TO service_role
USING (true);

-- Patient data tables
DROP POLICY IF EXISTS "Service role can read biomarker readings" ON public.patient_biomarker_readings;
CREATE POLICY "Service role can read biomarker readings"
ON public.patient_biomarker_readings
FOR SELECT
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can read biometric readings" ON public.patient_biometric_readings;
CREATE POLICY "Service role can read biometric readings"
ON public.patient_biometric_readings
FOR SELECT
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can read survey responses" ON public.patient_survey_responses;
CREATE POLICY "Service role can read survey responses"
ON public.patient_survey_responses
FOR SELECT
TO service_role
USING (true);

-- Detail/reference tables
DROP POLICY IF EXISTS "Service role can read biomarkers detail" ON public.biomarkers_detail;
CREATE POLICY "Service role can read biomarkers detail"
ON public.biomarkers_detail
FOR SELECT
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can read biometrics detail" ON public.biometrics_detail;
CREATE POLICY "Service role can read biometrics detail"
ON public.biometrics_detail
FOR SELECT
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can read survey options" ON public.survey_response_options;
CREATE POLICY "Service role can read survey options"
ON public.survey_response_options
FOR SELECT
TO service_role
USING (true);

-- Survey function tables
DROP POLICY IF EXISTS "Service role can read survey functions" ON public.wellpath_scoring_survey_functions;
CREATE POLICY "Service role can read survey functions"
ON public.wellpath_scoring_survey_functions
FOR SELECT
TO service_role
USING (true);

DROP POLICY IF EXISTS "Service role can read survey function questions" ON public.wellpath_scoring_survey_function_questions;
CREATE POLICY "Service role can read survey function questions"
ON public.wellpath_scoring_survey_function_questions
FOR SELECT
TO service_role
USING (true);

SELECT '✅ Added service_role policies for WellPath scoring edge function' as status;
