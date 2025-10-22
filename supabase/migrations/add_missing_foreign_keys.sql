-- Add missing foreign key constraints to readings tables
-- These enforce referential integrity between patient data and reference tables

-- 1. biomarker_readings.marker_id should reference intake_markers_raw.record_id
ALTER TABLE biomarker_readings
ADD CONSTRAINT fk_biomarker_readings_marker_id
FOREIGN KEY (marker_id) REFERENCES intake_markers_raw(record_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- 2. biometric_readings.metric_id should reference intake_metrics_raw.record_id
ALTER TABLE biometric_readings
ADD CONSTRAINT fk_biometric_readings_metric_id
FOREIGN KEY (metric_id) REFERENCES intake_metrics_raw(record_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- 3. metric_readings.metric_id should reference metric_types_vfinal.record_id
ALTER TABLE metric_readings
ADD CONSTRAINT fk_metric_readings_metric_id
FOREIGN KEY (metric_id) REFERENCES metric_types_vfinal(record_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- Note: Using ON DELETE RESTRICT to prevent accidental deletion of reference data
-- that has existing patient readings. Use CASCADE only if you want to delete all
-- patient data when a marker/metric definition is removed.

-- Verify biomarker_readings has update trigger (if not, add it)
-- This may already exist from table creation
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'update_biomarker_readings_updated_at'
    ) THEN
        CREATE TRIGGER update_biomarker_readings_updated_at
            BEFORE UPDATE ON biomarker_readings
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- Verify biometric_readings has update trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'update_biometric_readings_updated_at'
        AND tgrelid = 'biometric_readings'::regclass
    ) THEN
        CREATE TRIGGER update_biometric_readings_updated_at
            BEFORE UPDATE ON biometric_readings
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- Verify metric_readings has update trigger
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'update_metric_readings_updated_at'
    ) THEN
        CREATE TRIGGER update_metric_readings_updated_at
            BEFORE UPDATE ON metric_readings
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;
