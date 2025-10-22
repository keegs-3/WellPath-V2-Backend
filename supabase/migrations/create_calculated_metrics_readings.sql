-- Create calculated_metrics_readings table to store computed metric values
-- These are derived from metric_readings but need to be cached for:
-- 1. Adherence scoring (comparing actual vs target over time)
-- 2. WellPath score updates (tracking progress)
-- 3. Performance (avoid recalculating on every query)
-- 4. Historical tracking (what was the value on a specific date)

CREATE TABLE IF NOT EXISTS calculated_metrics_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL,
    calculated_metric_id TEXT NOT NULL,
    value NUMERIC,
    value_text TEXT,
    value_json JSONB,
    calculated_date DATE NOT NULL,
    calculated_time TIME,
    calculation_metadata JSONB, -- Store which inputs were used, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Foreign keys
    CONSTRAINT fk_calculated_metrics_readings_patient_id
        FOREIGN KEY (patient_id)
        REFERENCES patient_details(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_calculated_metrics_readings_metric_id
        FOREIGN KEY (calculated_metric_id)
        REFERENCES calculated_metrics_vfinal(record_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    -- Unique constraint to prevent duplicate calculations for same metric/patient/date
    CONSTRAINT uq_calculated_metrics_readings_lookup
        UNIQUE (patient_id, calculated_metric_id, calculated_date, calculated_time)
);

-- Indexes for common queries
CREATE INDEX idx_calculated_metrics_readings_patient
    ON calculated_metrics_readings(patient_id);

CREATE INDEX idx_calculated_metrics_readings_metric
    ON calculated_metrics_readings(calculated_metric_id);

CREATE INDEX idx_calculated_metrics_readings_patient_metric
    ON calculated_metrics_readings(patient_id, calculated_metric_id);

CREATE INDEX idx_calculated_metrics_readings_patient_metric_date
    ON calculated_metrics_readings(patient_id, calculated_metric_id, calculated_date DESC);

CREATE INDEX idx_calculated_metrics_readings_date
    ON calculated_metrics_readings(calculated_date DESC);

-- Trigger to update updated_at timestamp
CREATE TRIGGER update_calculated_metrics_readings_updated_at
    BEFORE UPDATE ON calculated_metrics_readings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comments for documentation
COMMENT ON TABLE calculated_metrics_readings IS 'Stores calculated/derived metric values computed from metric_readings. Used for adherence scoring, progress tracking, and performance optimization.';
COMMENT ON COLUMN calculated_metrics_readings.calculated_metric_id IS 'References calculated_metrics_vfinal.record_id (e.g., Daily Meals, Daily Saturated Fat)';
COMMENT ON COLUMN calculated_metrics_readings.calculation_metadata IS 'JSON storing which metric_readings were used, calculation timestamp, etc.';
