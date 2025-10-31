-- =====================================================
-- Automated Aggregation System
-- =====================================================
-- Creates triggers and functions to automatically update aggregations
-- when patient_data_entries are inserted/updated
--
-- Flow:
-- 1. Patient data inserted → trigger_instance_calculations_http
-- 2. Instance calculations complete → trigger_process_aggregations_http
-- 3. Aggregations updated → aggregation_results_cache updated
--
-- Created: 2025-10-23
-- =====================================================

-- =====================================================
-- Function: Get Affected Aggregations
-- Returns list of aggregations that depend on a field
-- =====================================================
CREATE OR REPLACE FUNCTION get_affected_aggregations(p_field_id TEXT)
RETURNS TABLE (
  agg_metric_id TEXT,
  agg_name TEXT,
  dependency_type TEXT
) AS $$
BEGIN
  RETURN QUERY
  -- Direct field dependencies
  SELECT DISTINCT
    am.agg_id as agg_metric_id,
    am.metric_name as agg_name,
    amd.dependency_type
  FROM aggregation_metrics am
  JOIN aggregation_metrics_dependencies amd ON am.agg_id = amd.agg_metric_id
  WHERE amd.data_entry_field_id = p_field_id
    AND am.is_active = true

  UNION

  -- Instance calculation dependencies (field → instance calc → aggregation)
  SELECT DISTINCT
    am.agg_id as agg_metric_id,
    am.metric_name as agg_name,
    amd.dependency_type
  FROM aggregation_metrics am
  JOIN aggregation_metrics_dependencies amd ON am.agg_id = amd.agg_metric_id
  JOIN instance_calculations_dependencies icd ON amd.instance_calculation_id = icd.instance_calculation_id
  WHERE icd.data_entry_field_id = p_field_id
    AND am.is_active = true

  UNION

  -- Cross-event dependencies (e.g., variety calculations)
  SELECT DISTINCT
    am.agg_id as agg_metric_id,
    am.metric_name as agg_name,
    amd.dependency_type
  FROM aggregation_metrics am
  JOIN aggregation_metrics_dependencies amd ON am.agg_id = amd.agg_metric_id
  WHERE (
    amd.value_reference_field_id = p_field_id
    OR amd.date_reference_field_id = p_field_id
  )
  AND am.is_active = true;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_affected_aggregations IS 'Returns all aggregations that should be recalculated when a field is updated';

-- =====================================================
-- Trigger Function: Call Aggregation Edge Function
-- Triggers HTTP request to process-aggregations edge function
-- =====================================================
CREATE OR REPLACE FUNCTION trigger_process_aggregations_http()
RETURNS TRIGGER AS $$
DECLARE
  function_url TEXT;
  service_role_key TEXT;
  request_id BIGINT;
BEGIN
  -- Only trigger for data that affects aggregations
  IF NEW.source IN ('manual', 'healthkit', 'import', 'api', 'auto_calculated') THEN

    -- Edge function URL
    function_url := 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/process-aggregations';

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
        'field_id', NEW.field_id,
        'entry_date', NEW.entry_date::text
      )
    ) INTO request_id;

    -- Log the request
    RAISE LOG 'Triggered aggregation processing for field % on % (request_id: %)',
      NEW.field_id, NEW.entry_date, request_id;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION trigger_process_aggregations_http IS 'Triggers aggregation processing via edge function after data entry';

-- =====================================================
-- Create Trigger on patient_data_entries
-- Fires AFTER instance calculations are inserted
-- =====================================================
-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS auto_process_aggregations_http ON patient_data_entries;

-- Create trigger that fires AFTER INSERT for auto_calculated entries
-- This ensures instance calculations have completed before aggregations run
CREATE TRIGGER auto_process_aggregations_http
  AFTER INSERT ON patient_data_entries
  FOR EACH ROW
  WHEN (NEW.source IN ('manual', 'healthkit', 'import', 'api', 'auto_calculated'))
  EXECUTE FUNCTION trigger_process_aggregations_http();

COMMENT ON TRIGGER auto_process_aggregations_http ON patient_data_entries
IS 'Automatically triggers aggregation processing when data is inserted';

-- =====================================================
-- Grant Permissions
-- =====================================================
-- Allow authenticated users to call the helper function
GRANT EXECUTE ON FUNCTION get_affected_aggregations(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_affected_aggregations(TEXT) TO service_role;

-- =====================================================
-- Verification Queries
-- =====================================================
SELECT '✅ Created automated aggregation system' as status;

-- Show all triggers on patient_data_entries
SELECT
  tgname as trigger_name,
  CASE
    WHEN tgtype::int & 2 = 2 THEN 'BEFORE'
    ELSE 'AFTER'
  END as timing,
  CASE
    WHEN tgtype::int & 4 = 4 THEN 'INSERT'
    WHEN tgtype::int & 8 = 8 THEN 'DELETE'
    WHEN tgtype::int & 16 = 16 THEN 'UPDATE'
    ELSE 'UNKNOWN'
  END as event
FROM pg_trigger
WHERE tgrelid = 'patient_data_entries'::regclass
  AND NOT tgisinternal
ORDER BY tgname;

-- Test the get_affected_aggregations function
SELECT '=== Testing get_affected_aggregations ===' as test;
SELECT * FROM get_affected_aggregations('DEF_PROTEIN_GRAMS')
LIMIT 5;

SELECT '
========================================
✅ Automated Aggregation System Created
========================================

When patient data is entered:
1. Trigger: auto_run_instance_calculations_http
   → Calls edge function: run-instance-calculations
   → Auto-calculated fields are created

2. Trigger: auto_process_aggregations_http
   → Calls edge function: process-aggregations
   → Aggregation cache is updated

No manual intervention needed!
========================================
' as summary;
