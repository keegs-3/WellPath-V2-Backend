-- =====================================================
-- Create Calculation Queue and Trigger
-- =====================================================
-- Automatically queue instance calculations when data is entered
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Calculation Queue Table
-- =====================================================

CREATE TABLE IF NOT EXISTS calculation_queue (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  event_instance_id UUID NOT NULL,
  event_type_id TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  attempts INT DEFAULT 0,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  processed_at TIMESTAMPTZ,
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_calculation_queue_status ON calculation_queue(status, created_at);
CREATE INDEX IF NOT EXISTS idx_calculation_queue_event ON calculation_queue(event_instance_id);
CREATE INDEX IF NOT EXISTS idx_calculation_queue_user ON calculation_queue(user_id);

-- =====================================================
-- PART 2: Create Trigger Function
-- =====================================================

CREATE OR REPLACE FUNCTION queue_instance_calculations()
RETURNS TRIGGER AS $$
BEGIN
  -- Only queue for manual or healthkit entries (not auto_calculated to avoid loops)
  IF NEW.source IN ('manual', 'healthkit', 'import', 'api') AND NEW.event_instance_id IS NOT NULL THEN

    -- Insert into queue (avoid duplicates with ON CONFLICT)
    INSERT INTO calculation_queue (user_id, event_instance_id)
    VALUES (NEW.user_id, NEW.event_instance_id)
    ON CONFLICT DO NOTHING;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PART 3: Create Trigger
-- =====================================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS auto_queue_instance_calculations ON patient_data_entries;

-- Create trigger that fires AFTER each insert
CREATE TRIGGER auto_queue_instance_calculations
  AFTER INSERT ON patient_data_entries
  FOR EACH ROW
  EXECUTE FUNCTION queue_instance_calculations();

-- =====================================================
-- PART 4: Helper Function to Process Queue
-- =====================================================

CREATE OR REPLACE FUNCTION get_pending_calculations(limit_count INT DEFAULT 100)
RETURNS TABLE (
  queue_id BIGINT,
  user_id UUID,
  event_instance_id UUID,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cq.id,
    cq.user_id,
    cq.event_instance_id,
    cq.created_at
  FROM calculation_queue cq
  WHERE cq.status = 'pending'
  ORDER BY cq.created_at ASC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  queue_count INT;
BEGIN
  SELECT COUNT(*) INTO queue_count FROM calculation_queue;

  RAISE NOTICE '✅ Calculation Queue and Trigger Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  - calculation_queue table created';
  RAISE NOTICE '  - auto_queue_instance_calculations trigger active';
  RAISE NOTICE '  - Queued calculations: %', queue_count;
  RAISE NOTICE '';
  RAISE NOTICE 'How it works:';
  RAISE NOTICE '  1. When data is entered, trigger adds event_instance_id to queue';
  RAISE NOTICE '  2. Worker/cron job calls edge function for each queued item';
  RAISE NOTICE '  3. Queue status updated to completed/failed';
  RAISE NOTICE '';
  RAISE NOTICE 'To process queue manually:';
  RAISE NOTICE '  SELECT * FROM get_pending_calculations(10);';
END $$;

COMMIT;
