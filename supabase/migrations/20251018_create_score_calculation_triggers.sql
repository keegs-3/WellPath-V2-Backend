-- =====================================================
-- WellPath Score Calculation Triggers
-- =====================================================
-- Automatically recalculates WellPath scores when patient data changes
-- Triggers fire on INSERT/UPDATE to:
--   - patient_biomarker_readings
--   - patient_biometric_readings
--   - patient_survey_responses
--   - (future) patient tracked metric aggregations
--
-- Created: 2025-10-18
-- =====================================================

BEGIN;

-- =====================================================
-- Helper Function: Queue Score Calculation
-- =====================================================
-- Creates a queue entry for score calculation
-- A separate process (cron job or app-level) will process the queue

CREATE TABLE IF NOT EXISTS wellpath_score_calculation_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  triggered_by text NOT NULL,  -- 'biomarker', 'biometric', 'survey', 'tracked_metric'
  created_at timestamptz DEFAULT now(),
  processed_at timestamptz,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  error_message text,
  UNIQUE(user_id, status) WHERE status = 'pending' OR status = 'processing'  -- Prevent duplicate pending entries
);

CREATE INDEX IF NOT EXISTS idx_score_queue_pending ON wellpath_score_calculation_queue(status, created_at)
WHERE status = 'pending';

COMMENT ON TABLE wellpath_score_calculation_queue IS
'Queue for WellPath score calculations. Triggered by data changes, processed by Edge Function or cron job.';


CREATE OR REPLACE FUNCTION queue_wellpath_score_calculation()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into queue (or update timestamp if already pending)
  INSERT INTO wellpath_score_calculation_queue (user_id, triggered_by)
  VALUES (NEW.user_id, TG_TABLE_NAME)
  ON CONFLICT (user_id, status)
  WHERE status = 'pending' OR status = 'processing'
  DO UPDATE SET created_at = now(), triggered_by = EXCLUDED.triggered_by;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION queue_wellpath_score_calculation IS
'Adds patient to score calculation queue when their data changes. Prevents duplicate pending entries per patient.';


-- =====================================================
-- Trigger 1: Biomarker Readings
-- =====================================================
CREATE OR REPLACE TRIGGER biomarker_readings_score_update
AFTER INSERT OR UPDATE ON patient_biomarker_readings
FOR EACH ROW
EXECUTE FUNCTION queue_wellpath_score_calculation();

COMMENT ON TRIGGER biomarker_readings_score_update ON patient_biomarker_readings IS
'Queues WellPath score recalculation when new biomarker data is added or updated';


-- =====================================================
-- Trigger 2: Biometric Readings
-- =====================================================
CREATE OR REPLACE TRIGGER biometric_readings_score_update
AFTER INSERT OR UPDATE ON patient_biometric_readings
FOR EACH ROW
EXECUTE FUNCTION queue_wellpath_score_calculation();

COMMENT ON TRIGGER biometric_readings_score_update ON patient_biometric_readings IS
'Queues WellPath score recalculation when new biometric data is added or updated';


-- =====================================================
-- Trigger 3: Survey Responses
-- =====================================================
CREATE OR REPLACE TRIGGER survey_responses_score_update
AFTER INSERT OR UPDATE ON patient_survey_responses
FOR EACH ROW
EXECUTE FUNCTION queue_wellpath_score_calculation();

COMMENT ON TRIGGER survey_responses_score_update ON patient_survey_responses IS
'Queues WellPath score recalculation when survey responses are added or updated';


-- =====================================================
-- Future: Tracked Metric Aggregations
-- =====================================================
-- Uncomment when aggregation_metrics_periods table is ready
/*
CREATE OR REPLACE TRIGGER tracked_metrics_score_update
AFTER INSERT OR UPDATE ON aggregation_metrics_periods
FOR EACH ROW
EXECUTE FUNCTION trigger_wellpath_score_calculation();

COMMENT ON TRIGGER tracked_metrics_score_update ON aggregation_metrics_periods IS
'Recalculates WellPath score when tracked metric aggregations are updated (e.g., 30-day rolling average for vegetable intake)';
*/

COMMIT;
