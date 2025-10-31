-- Grant service_role permissions for WellPath scoring edge function
-- The service_role needs direct table grants, not just RLS policies

-- Patients table
GRANT SELECT ON public.patients TO service_role;

-- Patient wellpath score items (read and write)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.patient_wellpath_score_items TO service_role;

-- Patient data tables
GRANT SELECT ON public.patient_biomarker_readings TO service_role;
GRANT SELECT ON public.patient_biometric_readings TO service_role;
GRANT SELECT ON public.patient_survey_responses TO service_role;

-- Detail/reference tables
GRANT SELECT ON public.biomarkers_detail TO service_role;
GRANT SELECT ON public.biometrics_detail TO service_role;
GRANT SELECT ON public.survey_response_options TO service_role;

-- Survey function tables
GRANT SELECT ON public.wellpath_scoring_survey_functions TO service_role;
GRANT SELECT ON public.wellpath_scoring_survey_function_questions TO service_role;

SELECT '✅ Granted service_role permissions for WellPath scoring' as status;
