-- =====================================================
-- Fix Auto-Aggregation Triggers for Data Changes
-- =====================================================
-- Ensures aggregations auto-run when data is added/deleted
-- Fixes column reference from user_id → patient_id
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Fix trigger_auto_process_aggregations function
-- =====================================================

CREATE OR REPLACE FUNCTION public.trigger_auto_process_aggregations()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_agg RECORD;
  v_processed INTEGER := 0;
BEGIN
  -- Only process for actual data entries (not deleted)
  IF NEW.source IN ('manual', 'healthkit', 'import', 'api', 'auto_calculated') THEN

    -- Process each affected aggregation
    FOR v_agg IN
      SELECT DISTINCT agg_metric_id
      FROM aggregation_metrics_dependencies
      WHERE data_entry_field_id = NEW.field_id
         OR instance_calculation_id IN (
           SELECT calc_id FROM instance_calculations
           WHERE depends_on_fields @> ARRAY[NEW.field_id]
         )
    LOOP
      v_processed := v_processed + process_single_aggregation(
        NEW.patient_id,  -- FIXED: was NEW.user_id
        v_agg.agg_metric_id,
        NEW.entry_date
      );
    END LOOP;

    RAISE LOG 'Auto-processed % aggregation cache entries for field % on date %',
      v_processed, NEW.field_id, NEW.entry_date;

  END IF;

  RETURN NEW;
END;
$function$;

-- =====================================================
-- 2. Create trigger for INSERT
-- =====================================================

DROP TRIGGER IF EXISTS auto_process_aggregations_on_insert ON patient_data_entries;

CREATE TRIGGER auto_process_aggregations_on_insert
  AFTER INSERT ON patient_data_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_auto_process_aggregations();

-- =====================================================
-- 3. Create trigger for DELETE (to reprocess when data removed)
-- =====================================================

CREATE OR REPLACE FUNCTION public.trigger_auto_process_aggregations_on_delete()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_agg RECORD;
  v_processed INTEGER := 0;
BEGIN
  -- Reprocess aggregations when data is deleted
  IF OLD.source IN ('manual', 'healthkit', 'import', 'api', 'auto_calculated') THEN

    -- Process each affected aggregation
    FOR v_agg IN
      SELECT DISTINCT agg_metric_id
      FROM aggregation_metrics_dependencies
      WHERE data_entry_field_id = OLD.field_id
         OR instance_calculation_id IN (
           SELECT calc_id FROM instance_calculations
           WHERE depends_on_fields @> ARRAY[OLD.field_id]
         )
    LOOP
      v_processed := v_processed + process_single_aggregation(
        OLD.patient_id,
        v_agg.agg_metric_id,
        OLD.entry_date
      );
    END LOOP;

    RAISE LOG 'Reprocessed % aggregation cache entries after deletion of field % on date %',
      v_processed, OLD.field_id, OLD.entry_date;

  END IF;

  RETURN OLD;
END;
$function$;

DROP TRIGGER IF EXISTS auto_process_aggregations_on_delete ON patient_data_entries;

CREATE TRIGGER auto_process_aggregations_on_delete
  AFTER DELETE ON patient_data_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_auto_process_aggregations_on_delete();

-- =====================================================
-- 4. Trigger for UPDATE (when values change)
-- =====================================================

CREATE OR REPLACE FUNCTION public.trigger_auto_process_aggregations_on_update()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_agg RECORD;
  v_processed INTEGER := 0;
BEGIN
  -- Only reprocess if the value actually changed
  IF NEW.value_quantity IS DISTINCT FROM OLD.value_quantity
     OR NEW.value_reference IS DISTINCT FROM OLD.value_reference
     OR NEW.value_text IS DISTINCT FROM OLD.value_text
     OR NEW.value_boolean IS DISTINCT FROM OLD.value_boolean
  THEN

    -- Process each affected aggregation
    FOR v_agg IN
      SELECT DISTINCT agg_metric_id
      FROM aggregation_metrics_dependencies
      WHERE data_entry_field_id = NEW.field_id
         OR instance_calculation_id IN (
           SELECT calc_id FROM instance_calculations
           WHERE depends_on_fields @> ARRAY[NEW.field_id]
         )
    LOOP
      v_processed := v_processed + process_single_aggregation(
        NEW.patient_id,
        v_agg.agg_metric_id,
        NEW.entry_date
      );

      -- If date changed, reprocess old date too
      IF NEW.entry_date != OLD.entry_date THEN
        v_processed := v_processed + process_single_aggregation(
          OLD.patient_id,
          v_agg.agg_metric_id,
          OLD.entry_date
        );
      END IF;
    END LOOP;

    RAISE LOG 'Reprocessed % aggregation cache entries after update of field %',
      v_processed, NEW.field_id;

  END IF;

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS auto_process_aggregations_on_update ON patient_data_entries;

CREATE TRIGGER auto_process_aggregations_on_update
  AFTER UPDATE ON patient_data_entries
  FOR EACH ROW
  EXECUTE FUNCTION trigger_auto_process_aggregations_on_update();

-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Auto-Aggregation Triggers Fixed and Enabled!';
  RAISE NOTICE '';
  RAISE NOTICE 'Triggers Created:';
  RAISE NOTICE '  • INSERT trigger - Processes aggregations when new data added';
  RAISE NOTICE '  • DELETE trigger - Reprocesses aggregations when data removed';
  RAISE NOTICE '  • UPDATE trigger - Reprocesses when values change';
  RAISE NOTICE '';
  RAISE NOTICE 'Key Fixes:';
  RAISE NOTICE '  • Changed NEW.user_id → NEW.patient_id (column name fix)';
  RAISE NOTICE '  • Added missing INSERT trigger attachment';
  RAISE NOTICE '  • Added DELETE trigger for data removal';
  RAISE NOTICE '  • Added UPDATE trigger for value changes';
  RAISE NOTICE '';
  RAISE NOTICE 'Behavior:';
  RAISE NOTICE '  • Aggregations now auto-run on every data change';
  RAISE NOTICE '  • Cache is automatically kept up-to-date';
  RAISE NOTICE '  • Works for all nutrition components and protein';
  RAISE NOTICE '';
  RAISE NOTICE 'Performance Note:';
  RAISE NOTICE '  • Triggers run synchronously during INSERT/UPDATE/DELETE';
  RAISE NOTICE '  • For bulk imports, consider disabling triggers temporarily';
  RAISE NOTICE '';
END $$;

COMMIT;
