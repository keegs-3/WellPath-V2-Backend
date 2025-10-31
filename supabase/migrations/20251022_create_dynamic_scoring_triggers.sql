-- =====================================================================================
-- DYNAMIC SCORING AUTO-TRIGGER
-- =====================================================================================
-- When aggregation_results_cache is updated, automatically call edge functions
-- to update patient_biometric_readings and patient_survey_responses
-- =====================================================================================

-- Create function to call edge functions via HTTP
CREATE OR REPLACE FUNCTION trigger_dynamic_scoring_update()
RETURNS TRIGGER AS $$
DECLARE
  v_user_id UUID;
  v_project_url TEXT;
  v_service_key TEXT;
BEGIN
  -- Get the user_id from the new/updated row
  v_user_id := NEW.user_id;

  -- Get Supabase project URL and service key from vault
  v_project_url := current_setting('app.settings.supabase_url', true);
  v_service_key := current_setting('app.settings.service_role_key', true);

  -- Call update-biometric-scores edge function (async, don't wait)
  -- Uses pg_net extension to make HTTP requests
  PERFORM
    net.http_post(
      url := v_project_url || '/functions/v1/update-biometric-scores',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || v_service_key
      ),
      body := jsonb_build_object('userId', v_user_id)
    );

  -- Call update-survey-scores edge function (async, don't wait)
  PERFORM
    net.http_post(
      url := v_project_url || '/functions/v1/update-survey-scores',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || v_service_key
      ),
      body := jsonb_build_object('userId', v_user_id)
    );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on aggregation_results_cache
DROP TRIGGER IF EXISTS trigger_dynamic_scoring ON aggregation_results_cache;

CREATE TRIGGER trigger_dynamic_scoring
  AFTER INSERT OR UPDATE ON aggregation_results_cache
  FOR EACH ROW
  EXECUTE FUNCTION trigger_dynamic_scoring_update();

COMMENT ON FUNCTION trigger_dynamic_scoring_update() IS
  'Automatically calls dynamic scoring edge functions when aggregation cache is updated';

COMMENT ON TRIGGER trigger_dynamic_scoring ON aggregation_results_cache IS
  'Triggers dynamic scoring updates when new aggregation data is available';
