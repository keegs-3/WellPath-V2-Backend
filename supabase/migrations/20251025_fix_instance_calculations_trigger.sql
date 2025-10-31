-- =====================================================
-- Fix Instance Calculations Trigger to Use patient_id
-- =====================================================

BEGIN;

CREATE OR REPLACE FUNCTION public.trigger_instance_calculations_http()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  function_url TEXT;
  service_role_key TEXT;
  request_id BIGINT;
BEGIN
  -- Only trigger for manual or healthkit entries (not auto_calculated to avoid loops)
  IF NEW.source IN ('manual', 'healthkit', 'import', 'api') AND NEW.event_instance_id IS NOT NULL THEN

    -- Edge function URL
    function_url := 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/run-instance-calculations';

    -- Service role key (bypasses RLS)
    service_role_key := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk';

    -- Make async HTTP request to edge function using pg_net
    SELECT net.http_post(
      url := function_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || service_role_key
      ),
      body := jsonb_build_object(
        'patient_id', NEW.patient_id::text,
        'event_instance_id', NEW.event_instance_id::text
      )
    ) INTO request_id;

    -- Log the request (appears in database logs)
    RAISE LOG 'Triggered instance calculations for event % (request_id: %)', NEW.event_instance_id, request_id;

  END IF;

  RETURN NEW;
END;
$function$;

DO $$
BEGIN
  RAISE NOTICE '✅ Fixed trigger to use patient_id instead of user_id';
END $$;

COMMIT;
