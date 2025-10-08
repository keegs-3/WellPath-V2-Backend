-- Create biometric_readings table for physical measurements
-- These are point-in-time assessments (like biomarkers) but track physical metrics
-- Examples: VO2 max, BMI, grip strength, body fat %, visceral fat, HRV, etc.

CREATE TABLE IF NOT EXISTS biometric_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patient_details(id) ON DELETE CASCADE,
    metric_id TEXT NOT NULL, -- References intake_metrics_raw.record_id
    value NUMERIC NOT NULL,
    unit TEXT,
    test_date DATE NOT NULL,
    source TEXT DEFAULT 'manual_entry', -- manual_entry, healthkit, oura, dexa_scan, etc.
    assessment_type TEXT, -- baseline, cycle_end, mid_cycle, etc.
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_biometric_readings_patient ON biometric_readings(patient_id);
CREATE INDEX IF NOT EXISTS idx_biometric_readings_metric ON biometric_readings(metric_id);
CREATE INDEX IF NOT EXISTS idx_biometric_readings_date ON biometric_readings(test_date);
CREATE INDEX IF NOT EXISTS idx_biometric_readings_patient_metric ON biometric_readings(patient_id, metric_id);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_biometric_readings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_biometric_readings_updated_at
    BEFORE UPDATE ON biometric_readings
    FOR EACH ROW
    EXECUTE FUNCTION update_biometric_readings_updated_at();

-- Comments
COMMENT ON TABLE biometric_readings IS 'Stores point-in-time biometric assessments like VO2 max, BMI, body composition, HRV, etc.';
COMMENT ON COLUMN biometric_readings.metric_id IS 'References intake_metrics_raw.record_id - the biometric being measured';
COMMENT ON COLUMN biometric_readings.assessment_type IS 'When this measurement was taken (baseline, cycle_end, mid_cycle, etc.)';
COMMENT ON COLUMN biometric_readings.source IS 'How the data was collected (manual_entry, healthkit, oura, dexa_scan, etc.)';
