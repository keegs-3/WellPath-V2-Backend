-- =====================================================
-- Add Triggers to Invalidate Cache on Data Changes
-- =====================================================
-- Problem: When data is deleted/updated, aggregation cache becomes stale
-- Solution: Auto-invalidate cache entries when source data changes
-- =====================================================

BEGIN;

-- Function to invalidate aggregation cache when patient data is deleted/updated
CREATE OR REPLACE FUNCTION invalidate_aggregation_cache_for_patient_data()
RETURNS TRIGGER AS $$
DECLARE
  v_patient_id UUID;
  v_field_id TEXT;
  v_deleted_count INTEGER;
BEGIN
  -- Get patient_id and field_id from the deleted/updated row
  IF TG_OP = 'DELETE' THEN
    v_patient_id := OLD.patient_id;
    v_field_id := OLD.field_id;
  ELSE  -- UPDATE
    v_patient_id := OLD.patient_id;
    v_field_id := OLD.field_id;
  END IF;

  -- Delete relevant cache entries
  -- This is a simplified approach - delete all cache for this patient and field
  -- A more sophisticated approach would identify specific aggregation metrics affected
  DELETE FROM aggregation_results_cache
  WHERE patient_id = v_patient_id
    AND agg_metric_id IN (
      -- Find aggregation metrics that depend on this field
      SELECT DISTINCT amp.agg_metric_id
      FROM aggregation_metrics_periods amp
      JOIN aggregation_metrics am ON amp.agg_metric_id = am.agg_id
      WHERE am.metric_name LIKE '%' || REPLACE(v_field_id, 'DEF_', '') || '%'
         OR am.agg_id LIKE '%' || REPLACE(REPLACE(v_field_id, 'DEF_', ''), 'FIELD_', '') || '%'
    );

  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

  IF v_deleted_count > 0 THEN
    RAISE NOTICE 'Invalidated % cache entries for patient % field %', v_deleted_count, v_patient_id, v_field_id;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger on DELETE
CREATE TRIGGER invalidate_cache_on_data_entry_delete
  AFTER DELETE ON patient_data_entries
  FOR EACH ROW
  EXECUTE FUNCTION invalidate_aggregation_cache_for_patient_data();

-- Trigger on UPDATE (if entry values change significantly)
CREATE TRIGGER invalidate_cache_on_data_entry_update
  AFTER UPDATE ON patient_data_entries
  FOR EACH ROW
  WHEN (
    OLD.value_quantity IS DISTINCT FROM NEW.value_quantity
    OR OLD.value_text IS DISTINCT FROM NEW.value_text
    OR OLD.value_boolean IS DISTINCT FROM NEW.value_boolean
    OR OLD.value_rating IS DISTINCT FROM NEW.value_rating
    OR OLD.value_category IS DISTINCT FROM NEW.value_category
    OR OLD.value_reference IS DISTINCT FROM NEW.value_reference
    OR OLD.value_timestamp IS DISTINCT FROM NEW.value_timestamp
  )
  EXECUTE FUNCTION invalidate_aggregation_cache_for_patient_data();

-- Function to invalidate cache when biomarker/biometric readings are deleted/updated
CREATE OR REPLACE FUNCTION invalidate_aggregation_cache_for_readings()
RETURNS TRIGGER AS $$
DECLARE
  v_patient_id UUID;
  v_deleted_count INTEGER;
BEGIN
  -- Get patient_id from the deleted/updated row
  IF TG_OP = 'DELETE' THEN
    v_patient_id := OLD.patient_id;
  ELSE  -- UPDATE
    v_patient_id := OLD.patient_id;
  END IF;

  -- Delete all cache entries for this patient
  -- Biomarker/biometric changes affect many aggregations
  DELETE FROM aggregation_results_cache
  WHERE patient_id = v_patient_id;

  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

  IF v_deleted_count > 0 THEN
    RAISE NOTICE 'Invalidated % cache entries for patient %', v_deleted_count, v_patient_id;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Triggers for biomarker readings
CREATE TRIGGER invalidate_cache_on_biomarker_delete
  AFTER DELETE ON patient_biomarker_readings
  FOR EACH ROW
  EXECUTE FUNCTION invalidate_aggregation_cache_for_readings();

CREATE TRIGGER invalidate_cache_on_biomarker_update
  AFTER UPDATE ON patient_biomarker_readings
  FOR EACH ROW
  WHEN (OLD.value IS DISTINCT FROM NEW.value)
  EXECUTE FUNCTION invalidate_aggregation_cache_for_readings();

-- Triggers for biometric readings
CREATE TRIGGER invalidate_cache_on_biometric_delete
  AFTER DELETE ON patient_biometric_readings
  FOR EACH ROW
  EXECUTE FUNCTION invalidate_aggregation_cache_for_readings();

CREATE TRIGGER invalidate_cache_on_biometric_update
  AFTER UPDATE ON patient_biometric_readings
  FOR EACH ROW
  WHEN (OLD.value IS DISTINCT FROM NEW.value)
  EXECUTE FUNCTION invalidate_aggregation_cache_for_readings();

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Cache Invalidation Triggers Created!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  - patient_data_entries: DELETE and UPDATE triggers';
  RAISE NOTICE '  - patient_biomarker_readings: DELETE and UPDATE triggers';
  RAISE NOTICE '  - patient_biometric_readings: DELETE and UPDATE triggers';
  RAISE NOTICE '';
  RAISE NOTICE 'Cache will now automatically invalidate when source data changes.';
  RAISE NOTICE '';
END $$;

COMMIT;
