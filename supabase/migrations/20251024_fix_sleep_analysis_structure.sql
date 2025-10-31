-- =====================================================
-- Fix Sleep Analysis Structure
-- =====================================================
-- Sleep stages are DATA SERIES on the PARENT chart
-- Not sections, not separate children
-- Other metrics (Consistency, Duration) are children
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Update/Create Sleep Analysis Parent
-- =====================================================

INSERT INTO parent_display_metrics (
  parent_metric_id,
  parent_name,
  parent_description,
  pillar,
  supported_units,
  default_unit,
  chart_type_id,
  supported_periods,
  default_period,
  display_unit,
  widget_type,
  display_order,
  is_active
) VALUES (
  'DISP_SLEEP_ANALYSIS',
  'Sleep Analysis',
  'Breakdown of sleep stages over time',
  'Restorative Sleep',
  '["hours", "minutes"]'::jsonb,
  'hours',
  'sleep_stages_horizontal',  -- Special chart type for horizontal stacked bars
  ARRAY['daily', 'weekly', 'monthly'],
  'weekly',
  'hours',
  'chart_card',
  1,
  true
)
ON CONFLICT (parent_metric_id) DO UPDATE SET
  parent_name = EXCLUDED.parent_name,
  parent_description = EXCLUDED.parent_description,
  chart_type_id = EXCLUDED.chart_type_id,
  supported_units = EXCLUDED.supported_units,
  default_unit = EXCLUDED.default_unit;

-- =====================================================
-- STEP 2: Link Parent DIRECTLY to Stage Aggregations
-- =====================================================
-- Stages are data series on the parent chart itself
-- NOT sections, NOT children

INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
)
VALUES
  -- Deep Sleep
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_DEEP_SLEEP_DURATION', 'daily', 'SUM'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_DEEP_SLEEP_DURATION', 'weekly', 'AVG'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_DEEP_SLEEP_DURATION', 'monthly', 'AVG'),

  -- Core Sleep
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_CORE_SLEEP_DURATION', 'daily', 'SUM'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_CORE_SLEEP_DURATION', 'weekly', 'AVG'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_CORE_SLEEP_DURATION', 'monthly', 'AVG'),

  -- REM Sleep
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_REM_SLEEP_DURATION', 'daily', 'SUM'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_REM_SLEEP_DURATION', 'weekly', 'AVG'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_REM_SLEEP_DURATION', 'monthly', 'AVG'),

  -- Awake Periods
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_AWAKE_PERIODS_DURATION', 'daily', 'SUM'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_AWAKE_PERIODS_DURATION', 'weekly', 'AVG'),
  ('DISP_SLEEP_ANALYSIS', NULL, 'AGG_AWAKE_PERIODS_DURATION', 'monthly', 'AVG')
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 3: Delete Any Existing Sleep Sections
-- =====================================================
-- Stages should NOT be in sections
-- They're data series on the parent chart

DELETE FROM parent_detail_sections
WHERE parent_metric_id = 'DISP_SLEEP_ANALYSIS'
  AND section_id LIKE '%SLEEP_STAGE%';

-- =====================================================
-- STEP 4: Create Child Metrics (OTHER sleep metrics)
-- =====================================================
-- These are SEPARATE metrics, not the stages

-- Sleep Consistency (variability in sleep time)
INSERT INTO child_display_metrics (
  child_metric_id,
  parent_metric_id,
  child_name,
  child_description,
  section_id,
  data_series_order,
  supported_units,
  default_unit,
  inherit_parent_unit,
  chart_type_id,
  is_active
) VALUES (
  'DISP_SLEEP_CONSISTENCY',
  'DISP_SLEEP_ANALYSIS',
  'Sleep Consistency',
  'Variability in sleep and wake times',
  NULL,  -- No section, direct child
  1,
  '["score"]'::jsonb,
  'score',
  false,
  'trend_line',
  true
)
ON CONFLICT (child_metric_id) DO UPDATE SET
  parent_metric_id = EXCLUDED.parent_metric_id,
  section_id = NULL;

-- Sleep Duration (total sleep time)
INSERT INTO child_display_metrics (
  child_metric_id,
  parent_metric_id,
  child_name,
  child_description,
  section_id,
  data_series_order,
  supported_units,
  default_unit,
  inherit_parent_unit,
  chart_type_id,
  is_active
) VALUES (
  'DISP_SLEEP_DURATION',
  'DISP_SLEEP_ANALYSIS',
  'Sleep Duration',
  'Total sleep time per night',
  NULL,  -- No section, direct child
  2,
  '["hours", "minutes"]'::jsonb,
  'hours',
  true,
  'bar_vertical',
  true
)
ON CONFLICT (child_metric_id) DO UPDATE SET
  parent_metric_id = EXCLUDED.parent_metric_id,
  section_id = NULL;

-- =====================================================
-- STEP 5: Link Children to Their Aggregations
-- =====================================================

-- Sleep Consistency → AGG_SLEEP_TIME_CONSISTENCY
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
) VALUES
  (NULL, 'DISP_SLEEP_CONSISTENCY', 'AGG_SLEEP_TIME_CONSISTENCY', 'daily', 'AVG'),
  (NULL, 'DISP_SLEEP_CONSISTENCY', 'AGG_SLEEP_TIME_CONSISTENCY', 'weekly', 'AVG'),
  (NULL, 'DISP_SLEEP_CONSISTENCY', 'AGG_SLEEP_TIME_CONSISTENCY', 'monthly', 'AVG')
ON CONFLICT DO NOTHING;

-- Sleep Duration → AGG_TOTAL_SLEEP_DURATION
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
) VALUES
  (NULL, 'DISP_SLEEP_DURATION', 'AGG_TOTAL_SLEEP_DURATION', 'daily', 'SUM'),
  (NULL, 'DISP_SLEEP_DURATION', 'AGG_TOTAL_SLEEP_DURATION', 'weekly', 'AVG'),
  (NULL, 'DISP_SLEEP_DURATION', 'AGG_TOTAL_SLEEP_DURATION', 'monthly', 'AVG')
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 6: Deactivate Old Individual Stage Parents
-- =====================================================
-- Deep/Core/REM were individual parents - deactivate them

UPDATE parent_display_metrics
SET is_active = false
WHERE parent_metric_id IN (
  'DISP_DEEP_SLEEP_DURATION',
  'DISP_CORE_SLEEP_DURATION',
  'DISP_REM_SLEEP_DURATION',
  'DISP_AWAKE_PERIODS_DURATION',
  'DISP_TOTAL_SLEEP_DURATION'  -- Now a child instead
);

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  parent_agg_count INT;
  child_count INT;
BEGIN
  -- Count parent aggregations (stages)
  SELECT COUNT(*) INTO parent_agg_count
  FROM parent_child_display_metrics_aggregations
  WHERE parent_metric_id = 'DISP_SLEEP_ANALYSIS';

  -- Count children (other metrics)
  SELECT COUNT(*) INTO child_count
  FROM child_display_metrics
  WHERE parent_metric_id = 'DISP_SLEEP_ANALYSIS';

  RAISE NOTICE '✅ Sleep Analysis Structure Fixed';
  RAISE NOTICE '';
  RAISE NOTICE 'Parent Chart Data Series (stages): % aggregations', parent_agg_count;
  RAISE NOTICE 'Child Metrics (other): % children', child_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Structure:';
  RAISE NOTICE '  PARENT: Sleep Analysis (horizontal bar)';
  RAISE NOTICE '    Data series: Deep, Core, REM, Awake';
  RAISE NOTICE '    Children: Consistency, Duration';
END $$;

-- Show the structure
SELECT
  '📊 PARENT (with data series)' as type,
  'DISP_SLEEP_ANALYSIS' as id,
  'Sleep Analysis' as name,
  COUNT(DISTINCT pca.agg_metric_id)::text || ' stages' as detail
FROM parent_display_metrics pdm
LEFT JOIN parent_child_display_metrics_aggregations pca
  ON pca.parent_metric_id = pdm.parent_metric_id
WHERE pdm.parent_metric_id = 'DISP_SLEEP_ANALYSIS'
GROUP BY pdm.parent_metric_id

UNION ALL

SELECT
  '  ◆ child metric' as type,
  child_metric_id as id,
  child_name as name,
  'separate metric' as detail
FROM child_display_metrics
WHERE parent_metric_id = 'DISP_SLEEP_ANALYSIS'
ORDER BY type DESC, id;

COMMIT;
