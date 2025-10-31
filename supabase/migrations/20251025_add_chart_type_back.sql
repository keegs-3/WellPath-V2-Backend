-- =====================================================
-- Add chart_type_id back to display_metrics
-- =====================================================
-- Swift needs to know WHICH chart to render
-- Swift handles styling/colors/units, but needs the type
-- =====================================================

BEGIN;

-- Add chart_type_id column back
ALTER TABLE display_metrics
ADD COLUMN chart_type_id text REFERENCES chart_types(chart_type_id);

CREATE INDEX idx_display_metrics_chart_type ON display_metrics(chart_type_id);

COMMENT ON COLUMN display_metrics.chart_type_id IS
'Chart type identifier. Swift maps this to the appropriate view component (bar_vertical, line, stacked_bar, etc.)';

-- Set chart types for existing metrics based on common patterns
UPDATE display_metrics SET chart_type_id = 'bar_vertical' WHERE metric_id LIKE '%_GRAMS' OR metric_id LIKE '%_SERVINGS';
UPDATE display_metrics SET chart_type_id = 'bar_stacked_vertical' WHERE metric_id LIKE '%_MEAL_TIMING' OR metric_id LIKE '%_TIMING';
UPDATE display_metrics SET chart_type_id = 'bar_stacked_horizontal' WHERE metric_id = 'DISP_SLEEP_ANALYSIS';
UPDATE display_metrics SET chart_type_id = 'line' WHERE metric_id LIKE '%_CONSISTENCY' OR metric_id LIKE '%_TREND';
UPDATE display_metrics SET chart_type_id = 'gauge' WHERE metric_id LIKE '%_PCT' OR metric_id LIKE '%_EFFICIENCY' OR metric_id LIKE '%_RATIO';
UPDATE display_metrics SET chart_type_id = 'number' WHERE metric_id LIKE '%_COUNT' OR metric_id LIKE '%_SESSIONS' OR metric_id LIKE '%_EPISODES';
UPDATE display_metrics SET chart_type_id = 'bar_vertical' WHERE metric_id LIKE '%_DURATION' OR metric_id LIKE '%_TIME';
UPDATE display_metrics SET chart_type_id = 'number' WHERE metric_id LIKE '%_RATING' OR metric_id LIKE '%_LEVEL' OR metric_id LIKE '%_SCORE';
UPDATE display_metrics SET chart_type_id = 'timeline' WHERE metric_id LIKE '%_MEAL_TIME' OR metric_id LIKE '%_LAST_%_TIME';
UPDATE display_metrics SET chart_type_id = 'number' WHERE metric_id LIKE '%_BUFFER';
UPDATE display_metrics SET chart_type_id = 'status_indicator' WHERE metric_id LIKE '%_COMPLIANCE' OR metric_id LIKE '%_ADHERENCE';
UPDATE display_metrics SET chart_type_id = 'number' WHERE metric_id LIKE '%_MONTHS_SINCE%' OR metric_id LIKE '%_YEARS_SINCE%';
UPDATE display_metrics SET chart_type_id = 'number' WHERE metric_id IN ('DISP_WEIGHT', 'DISP_HEIGHT', 'DISP_BMI', 'DISP_SYSTOLIC_BP', 'DISP_DIASTOLIC_BP', 'DISP_AGE');
UPDATE display_metrics SET chart_type_id = 'bar_vertical' WHERE metric_id IN ('DISP_STEPS', 'DISP_CALORIES', 'DISP_WATER_CONSUMPTION');
UPDATE display_metrics SET chart_type_id = 'number' WHERE metric_id IN ('DISP_VO2_MAX', 'DISP_RESTING_HR');

-- Default remaining to bar_vertical
UPDATE display_metrics SET chart_type_id = 'bar_vertical' WHERE chart_type_id IS NULL;

-- Show summary
DO $$
DECLARE
  total_metrics INT;
  with_chart_type INT;
BEGIN
  SELECT COUNT(*) INTO total_metrics FROM display_metrics WHERE is_active = true;
  SELECT COUNT(*) INTO with_chart_type FROM display_metrics WHERE chart_type_id IS NOT NULL AND is_active = true;

  RAISE NOTICE '✅ Added chart_type_id to display_metrics';
  RAISE NOTICE '';
  RAISE NOTICE 'Metrics with chart types: % / %', with_chart_type, total_metrics;
  RAISE NOTICE '';
  RAISE NOTICE 'Chart type breakdown:';
END $$;

SELECT
  chart_type_id,
  COUNT(*) as metric_count
FROM display_metrics
WHERE is_active = true
GROUP BY chart_type_id
ORDER BY metric_count DESC;

COMMIT;
