-- =====================================================
-- Create Apple Health-Style Sleep Analysis Display Metric
-- =====================================================
-- Links sleep stage aggregations to display metrics
-- Creates stacked chart showing Deep, Core, REM, Awake
--
-- Created: 2025-10-24
-- =====================================================

-- =====================================================
-- UPDATE PARENT DISPLAY METRIC
-- =====================================================

UPDATE parent_display_metrics
SET
  parent_name = 'Sleep Analysis',
  parent_description = 'Comprehensive sleep quality analysis with stages',
  widget_type = 'stacked_chart',
  chart_type_id = 'sleep_stages_horizontal',
  supported_units = '["hours", "minutes"]'::jsonb,
  display_unit = 'hours'
WHERE parent_metric_id = 'DISP_TOTAL_SLEEP_DURATION';

-- =====================================================
-- CREATE SECTION FOR SLEEP STAGES
-- =====================================================

INSERT INTO parent_detail_sections (
  section_id,
  parent_metric_id,
  section_name,
  section_description,
  section_chart_type_id,
  display_order,
  is_active
) VALUES (
  'SECTION_SLEEP_STAGES',
  'DISP_TOTAL_SLEEP_DURATION',
  'Sleep Stages',
  'Detailed breakdown of sleep stages throughout the night',
  'bar_stacked',
  1,
  true
) ON CONFLICT (section_id) DO UPDATE SET
  section_name = EXCLUDED.section_name,
  parent_metric_id = EXCLUDED.parent_metric_id,
  section_chart_type_id = EXCLUDED.section_chart_type_id;

-- =====================================================
-- CREATE CHILD DISPLAY METRICS
-- =====================================================

INSERT INTO child_display_metrics (
  child_metric_id,
  child_name,
  child_description,
  parent_metric_id,
  section_id,
  data_series_order,
  chart_label_order,
  supported_units,
  display_unit,
  widget_type,
  is_active
) VALUES
  -- Deep Sleep (bottom of stack - darkest blue)
  (
    'DISP_DEEP_SLEEP',
    'Deep Sleep',
    'Deep sleep duration',
    'DISP_TOTAL_SLEEP_DURATION',
    'SECTION_SLEEP_STAGES',
    1,  -- First in stack (bottom)
    1,
    '["hours", "minutes"]'::jsonb,
    'hours',
    'stacked_bar',
    true
  ),
  -- Core Sleep (middle - blue)
  (
    'DISP_CORE_SLEEP',
    'Core Sleep',
    'Core sleep duration',
    'DISP_TOTAL_SLEEP_DURATION',
    'SECTION_SLEEP_STAGES',
    2,  -- Second in stack
    2,
    '["hours", "minutes"]'::jsonb,
    'hours',
    'stacked_bar',
    true
  ),
  -- REM Sleep (upper middle - cyan)
  (
    'DISP_REM_SLEEP',
    'REM Sleep',
    'REM sleep duration',
    'DISP_TOTAL_SLEEP_DURATION',
    'SECTION_SLEEP_STAGES',
    3,  -- Third in stack
    3,
    '["hours", "minutes"]'::jsonb,
    'hours',
    'stacked_bar',
    true
  ),
  -- Awake (top - orange/red)
  (
    'DISP_AWAKE_PERIODS',
    'Awake',
    'Time awake during sleep session',
    'DISP_TOTAL_SLEEP_DURATION',
    'SECTION_SLEEP_STAGES',
    4,  -- Top of stack
    4,
    '["hours", "minutes"]'::jsonb,
    'hours',
    'stacked_bar',
    true
  )
ON CONFLICT (child_metric_id) DO UPDATE SET
  child_name = EXCLUDED.child_name,
  section_id = EXCLUDED.section_id,
  data_series_order = EXCLUDED.data_series_order,
  chart_label_order = EXCLUDED.chart_label_order;

-- =====================================================
-- LINK TO AGGREGATIONS
-- =====================================================
-- For child metrics: parent_metric_id = NULL
-- For parent metrics: child_metric_id = NULL

INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
) VALUES
  -- Child metrics (sleep stages)
  (NULL, 'DISP_DEEP_SLEEP', 'AGG_DEEP_SLEEP_DURATION', 'daily', 'SUM'),
  (NULL, 'DISP_CORE_SLEEP', 'AGG_CORE_SLEEP_DURATION', 'daily', 'SUM'),
  (NULL, 'DISP_REM_SLEEP', 'AGG_REM_SLEEP_DURATION', 'daily', 'SUM'),
  (NULL, 'DISP_AWAKE_PERIODS', 'AGG_AWAKE_PERIODS_DURATION', 'daily', 'SUM'),

  -- Parent metric (total sleep)
  ('DISP_TOTAL_SLEEP_DURATION', NULL, 'AGG_TOTAL_SLEEP_DURATION', 'daily', 'SUM'),
  ('DISP_TOTAL_SLEEP_DURATION', NULL, 'AGG_TOTAL_SLEEP_DURATION', 'weekly', 'AVG'),
  ('DISP_TOTAL_SLEEP_DURATION', NULL, 'AGG_TOTAL_SLEEP_DURATION', 'monthly', 'AVG')
ON CONFLICT ON CONSTRAINT unique_parent_child_agg DO NOTHING;

-- =====================================================
-- ADD TO DISPLAY SCREEN
-- =====================================================

INSERT INTO display_screens_display_metrics (
  display_screen,
  display_metric,
  display_order,
  is_primary,
  section,
  position
) VALUES (
  'SCREEN_SLEEP',
  'DISP_TOTAL_SLEEP_DURATION',
  1,
  true,
  'main',
  'top'
);

-- Summary
SELECT '
========================================
✅ Sleep Analysis Display Metric Created
========================================

Parent Metric: DISP_TOTAL_SLEEP_DURATION
Name: Sleep Analysis
Chart: sleep_stages_horizontal (stacked)

Child Metrics (Sleep Stages):
  1. DISP_DEEP_SLEEP (Deep Sleep - dark blue, bottom)
  2. DISP_CORE_SLEEP (Core Sleep - blue, middle)
  3. DISP_REM_SLEEP (REM Sleep - cyan, upper)
  4. DISP_AWAKE_PERIODS (Awake - orange, top)

Section: SECTION_SLEEP_STAGES
Chart: bar_stacked

Aggregations Linked:
  - AGG_DEEP_SLEEP_DURATION (child, daily/SUM)
  - AGG_CORE_SLEEP_DURATION (child, daily/SUM)
  - AGG_REM_SLEEP_DURATION (child, daily/SUM)
  - AGG_AWAKE_PERIODS_DURATION (child, daily/SUM)
  - AGG_TOTAL_SLEEP_DURATION (parent, daily/weekly/monthly)

Display: Apple Health-style sleep stages ✅
========================================
' as summary;
