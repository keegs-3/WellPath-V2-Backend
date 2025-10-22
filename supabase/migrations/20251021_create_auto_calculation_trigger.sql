-- =====================================================
-- Create Auto-Calculation Trigger
-- =====================================================
-- Automatically run instance calculations when data is entered
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create function to trigger calculations
-- =====================================================

CREATE OR REPLACE FUNCTION trigger_instance_calculations()
RETURNS TRIGGER AS $$
DECLARE
  function_url TEXT;
  service_role_key TEXT;
  request_id BIGINT;
BEGIN
  -- Only trigger for manual or healthkit entries (not for auto_calculated entries to avoid loops)
  IF NEW.source IN ('manual', 'healthkit', 'import', 'api') AND NEW.event_instance_id IS NOT NULL THEN

    -- Get Supabase URL from environment or config
    function_url := 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/run-instance-calculations';

    -- Note: Service role key should be stored securely
    -- For now, we'll use pg_net to make the async HTTP call

    -- Make async HTTP request to edge function using pg_net
    SELECT net.http_post(
      url := function_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
      ),
      body := jsonb_build_object(
        'user_id', NEW.user_id::text,
        'event_instance_id', NEW.event_instance_id::text
      )
    ) INTO request_id;

    -- Log the request
    RAISE LOG 'Triggered instance calculations for event % (request_id: %)', NEW.event_instance_id, request_id;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- =====================================================
-- PART 2: Create trigger on patient_data_entries
-- =====================================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS auto_run_instance_calculations ON patient_data_entries;

-- Create trigger that fires AFTER each insert
-- Using AFTER trigger so the data is committed first
-- Using FOR EACH ROW so it fires once per inserted row
CREATE TRIGGER auto_run_instance_calculations
  AFTER INSERT ON patient_data_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_instance_calculations();


-- =====================================================
-- PART 3: Create configuration table for service key
-- =====================================================

-- Table to store configuration (like service role key)
CREATE TABLE IF NOT EXISTS system_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add service role key placeholder
INSERT INTO system_config (key, value, description)
VALUES ('service_role_key', 'REPLACE_WITH_ACTUAL_KEY', 'Supabase service role key for internal API calls')
ON CONFLICT (key) DO NOTHING;


-- =====================================================
-- PART 4: Alternative - Event Queue Approach
-- =====================================================
-- If HTTP calls don't work well, we can queue events for processing

CREATE TABLE IF NOT EXISTS calculation_queue (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  event_instance_id UUID NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  attempts INT DEFAULT 0,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  processed_at TIMESTAMPTZ
);

CREATE INDEX idx_calculation_queue_status ON calculation_queue(status, created_at);
CREATE INDEX idx_calculation_queue_event ON calculation_queue(event_instance_id);


-- Function to queue calculations instead of calling HTTP
CREATE OR REPLACE FUNCTION queue_instance_calculations()
RETURNS TRIGGER AS $$
BEGIN
  -- Only queue for manual or healthkit entries
  IF NEW.source IN ('manual', 'healthkit', 'import', 'api') AND NEW.event_instance_id IS NOT NULL THEN

    -- Insert into queue (or update if exists)
    INSERT INTO calculation_queue (user_id, event_instance_id)
    VALUES (NEW.user_id, NEW.event_instance_id)
    ON CONFLICT DO NOTHING;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- =====================================================
-- Summary & Usage Notes
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Auto-calculation trigger created';
  RAISE NOTICE '';
  RAISE NOTICE 'Two approaches available:';
  RAISE NOTICE '1. HTTP Trigger (default): Calls edge function via pg_net';
  RAISE NOTICE '   - Set service role key: UPDATE system_config SET value = ''YOUR_KEY'' WHERE key = ''service_role_key'';';
  RAISE NOTICE '   - Requires pg_net extension';
  RAISE NOTICE '';
  RAISE NOTICE '2. Queue Approach: Queues events for batch processing';
  RAISE NOTICE '   - To enable: DROP TRIGGER auto_run_instance_calculations ON patient_data_entries;';
  RAISE NOTICE '   - Then: CREATE TRIGGER auto_run_instance_calculations AFTER INSERT ON patient_data_entries FOR EACH ROW EXECUTE FUNCTION queue_instance_calculations();';
  RAISE NOTICE '   - Process queue with scheduled job or worker';
END $$;

COMMIT;
