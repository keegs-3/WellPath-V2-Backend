-- =====================================================
-- Enable Automatic Calculation Trigger
-- =====================================================
-- Calls edge function directly via pg_net for instant calculations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create HTTP Trigger Function
-- =====================================================

CREATE OR REPLACE FUNCTION trigger_instance_calculations_http()
RETURNS TRIGGER AS $$
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
        'user_id', NEW.user_id::text,
        'event_instance_id', NEW.event_instance_id::text
      )
    ) INTO request_id;

    -- Log the request (appears in database logs)
    RAISE LOG 'Triggered instance calculations for event % (request_id: %)', NEW.event_instance_id, request_id;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- PART 2: Replace Queue Trigger with HTTP Trigger
-- =====================================================

-- Drop the queue-based trigger
DROP TRIGGER IF EXISTS auto_queue_instance_calculations ON patient_data_entries;

-- Create new HTTP-based trigger
DROP TRIGGER IF EXISTS auto_run_instance_calculations_http ON patient_data_entries;

CREATE TRIGGER auto_run_instance_calculations_http
  AFTER INSERT ON patient_data_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_instance_calculations_http();

-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Automatic Calculation Trigger Enabled';
  RAISE NOTICE '';
  RAISE NOTICE 'How it works:';
  RAISE NOTICE '  1. User enters data → patient_data_entries INSERT';
  RAISE NOTICE '  2. Trigger fires → calls edge function via pg_net (async HTTP)';
  RAISE NOTICE '  3. Edge function runs calculations';
  RAISE NOTICE '  4. Calculated values written back to patient_data_entries';
  RAISE NOTICE '';
  RAISE NOTICE 'Fully automatic - no manual processing needed! 🎉';
  RAISE NOTICE '';
  RAISE NOTICE 'Note: calculation_queue table still exists for monitoring/fallback';
END $$;

COMMIT;
