-- Create triggers to automatically recalculate WellPath scores when data changes
-- Uses pg_net extension to call the edge function

-- Enable pg_net extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Create a function to trigger score recalculation via edge function
CREATE OR REPLACE FUNCTION public.trigger_wellpath_score_recalculation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_patient_id uuid;
  v_request_id bigint;
  v_function_url text;
  v_anon_key text;
BEGIN
  -- Get the patient_id from the affected row
  IF TG_OP = 'DELETE' THEN
    v_patient_id := OLD.patient_id;
  ELSE
    v_patient_id := NEW.patient_id;
  END IF;

  -- Get the function URL and anon key from environment
  -- These should be set in your Supabase project settings
  v_function_url := current_setting('app.settings.supabase_url', true) || '/functions/v1/calculate-wellpath-score';
  v_anon_key := current_setting('app.settings.supabase_anon_key', true);

  -- Make async HTTP request to the edge function
  -- This uses pg_net to make a non-blocking HTTP call
  SELECT net.http_post(
    url := v_function_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_anon_key
    ),
    body := jsonb_build_object(
      'patient_id', v_patient_id::text
    )
  ) INTO v_request_id;

  RAISE LOG 'Queued WellPath score recalculation for patient % (request_id: %)', v_patient_id, v_request_id;

  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Create triggers on patient_biomarker_readings
DROP TRIGGER IF EXISTS trigger_recalculate_score_on_biomarker_change ON public.patient_biomarker_readings;
CREATE TRIGGER trigger_recalculate_score_on_biomarker_change
AFTER INSERT OR UPDATE OR DELETE ON public.patient_biomarker_readings
FOR EACH ROW
EXECUTE FUNCTION public.trigger_wellpath_score_recalculation();

-- Create triggers on patient_biometric_readings
DROP TRIGGER IF EXISTS trigger_recalculate_score_on_biometric_change ON public.patient_biometric_readings;
CREATE TRIGGER trigger_recalculate_score_on_biometric_change
AFTER INSERT OR UPDATE OR DELETE ON public.patient_biometric_readings
FOR EACH ROW
EXECUTE FUNCTION public.trigger_wellpath_score_recalculation();

-- Create triggers on patient_survey_responses
DROP TRIGGER IF EXISTS trigger_recalculate_score_on_survey_change ON public.patient_survey_responses;
CREATE TRIGGER trigger_recalculate_score_on_survey_change
AFTER INSERT OR UPDATE OR DELETE ON public.patient_survey_responses
FOR EACH ROW
EXECUTE FUNCTION public.trigger_wellpath_score_recalculation();

-- Note: These triggers are disabled by default to prevent overwhelming the system
-- You can enable them by running:
-- ALTER TABLE patient_biomarker_readings ENABLE TRIGGER trigger_recalculate_score_on_biomarker_change;
-- ALTER TABLE patient_biometric_readings ENABLE TRIGGER trigger_recalculate_score_on_biometric_change;
-- ALTER TABLE patient_survey_responses ENABLE TRIGGER trigger_recalculate_score_on_survey_change;

-- Disable triggers by default for safety
ALTER TABLE patient_biomarker_readings DISABLE TRIGGER trigger_recalculate_score_on_biomarker_change;
ALTER TABLE patient_biometric_readings DISABLE TRIGGER trigger_recalculate_score_on_biometric_change;
ALTER TABLE patient_survey_responses DISABLE TRIGGER trigger_recalculate_score_on_survey_change;

SELECT '✅ Created auto-scoring triggers (disabled by default)' as status;
SELECT '⚠️  To enable triggers, set app.settings.supabase_url and app.settings.supabase_anon_key' as note;
