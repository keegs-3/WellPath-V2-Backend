-- =====================================================
-- Populate Display Metrics with Chart Configuration
-- =====================================================
-- Updates all existing display_metrics with proper chart types
-- and configuration based on their widget_type and content
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Drop Old Dependency Tables We Don't Need
-- =====================================================
-- Now that everything flows through aggregation_metrics,
-- we don't need these direct junction tables

DROP TABLE IF EXISTS display_metrics_data_entry_fields CASCADE;
DROP TABLE IF EXISTS display_metrics_instance_calculations CASCADE;
DROP TABLE IF EXISTS display_metrics_readings CASCADE;

-- Keep display_metrics_survey_questions (still relevant per user request)
-- Keep display_metrics_aggregations (our new architecture)


-- =====================================================
-- PART 2: Update Chart Types Based on widget_type
-- =====================================================

-- Map widget_type to chart_type_id
UPDATE display_metrics
SET chart_type_id = CASE
  WHEN widget_type = 'current_value' THEN 'current_value'
  WHEN widget_type = 'progress_bar' THEN 'progress_bar'
  WHEN widget_type = 'trend_line' THEN 'trend_line'
  WHEN widget_type = 'bar_chart' THEN 'bar_vertical'
  WHEN widget_type = 'stacked_bar' THEN 'bar_stacked'
  WHEN widget_type = 'gauge' THEN 'gauge'
  WHEN widget_type = 'heatmap' THEN 'heatmap'
  WHEN widget_type = 'streak' THEN 'streak_counter'
  WHEN widget_type = 'comparison' THEN 'comparison_view'
  -- Default to current_value if widget_type is null or unknown
  ELSE 'current_value'
END
WHERE chart_type_id IS NULL;


-- =====================================================
-- PART 3: Set Chart-Specific Configurations
-- =====================================================

-- Sleep metrics get special sleep chart types
UPDATE display_metrics
SET
  chart_type_id = 'sleep_stages_vertical',
  chart_config = jsonb_build_object(
    'dynamic_axis', true,
    'buffer_minutes', 30,
    'stacking_direction', 'top_to_bottom'
  ),
  null_handling = 'hide'
WHERE display_name ILIKE '%sleep stage%'
  OR display_name ILIKE '%sleep period%';

-- Sleep duration/amounts get sleep amounts chart
UPDATE display_metrics
SET
  chart_type_id = 'sleep_amounts',
  chart_config = jsonb_build_object(
    'supports_selection', true,
    'selection_moves_to_bottom', true,
    'show_percentages', true
  ),
  null_handling = 'interpolate'
WHERE (display_name ILIKE '%sleep duration%'
  OR display_name ILIKE '%sleep amount%'
  OR display_name ILIKE '%time asleep%')
  AND display_metric_id != 'DISP_SLEEP_DURATION'; -- Skip the example we created

-- Progress/goal-based metrics
UPDATE display_metrics
SET
  chart_type_id = 'progress_bar',
  chart_config = jsonb_build_object(
    'show_percentage', true,
    'color_gradient', true
  ),
  null_handling = 'show_as_zero'
WHERE display_name ILIKE '%goal%'
  OR display_name ILIKE '%target%'
  OR display_name ILIKE '%progress%';

-- Streak/consistency metrics
UPDATE display_metrics
SET
  chart_type_id = 'streak_counter',
  chart_config = jsonb_build_object(
    'show_best_streak', true,
    'show_calendar', true
  ),
  null_handling = 'hide'
WHERE display_name ILIKE '%streak%'
  OR display_name ILIKE '%consecutive%'
  OR display_name ILIKE '%consistency%';

-- Activity/exercise duration metrics should be trend lines for week+ views
UPDATE display_metrics
SET
  chart_type_id = 'trend_line',
  chart_config = jsonb_build_object(
    'show_data_points', true,
    'smooth_line', false
  ),
  null_handling = 'ignore'
WHERE (display_name ILIKE '%duration%'
  OR display_name ILIKE '%time%'
  OR display_name ILIKE '%minutes%')
  AND pillar IN ('Movement + Exercise', 'Mind-Body Practice')
  AND 'weekly' = ANY(supported_periods);

-- Meal timing heatmaps
UPDATE display_metrics
SET
  chart_type_id = 'heatmap',
  chart_config = jsonb_build_object(
    'rows', 'days_of_week',
    'columns', 'hours_of_day',
    'color_scale', 'sequential'
  ),
  null_handling = 'show_as_null'
WHERE display_name ILIKE '%meal timing%'
  OR display_name ILIKE '%eating pattern%';


-- =====================================================
-- PART 4: Set Null Handling Based on Data Type
-- =====================================================

-- Count-based metrics: show as zero
UPDATE display_metrics
SET null_handling = 'show_as_zero'
WHERE chart_type_id IN ('current_value', 'bar_vertical', 'bar_horizontal')
  AND (display_name ILIKE '%count%'
    OR display_name ILIKE '%number of%'
    OR display_name ILIKE '%sessions%'
    OR display_name ILIKE '%meals%')
  AND null_handling = 'ignore'; -- Only update if still default

-- Time-based metrics: interpolate for trends
UPDATE display_metrics
SET null_handling = 'interpolate'
WHERE chart_type_id = 'trend_line'
  AND null_handling = 'ignore'; -- Only update if still default

-- Percentages/ratios: hide if null
UPDATE display_metrics
SET null_handling = 'hide'
WHERE (display_name ILIKE '%percent%'
  OR display_name ILIKE '%ratio%'
  OR display_name ILIKE '%efficiency%')
  AND null_handling = 'ignore'; -- Only update if still default


-- =====================================================
-- PART 5: Set Group By Fields for Reference Metrics
-- =====================================================

-- Cardio metrics grouped by cardio type
UPDATE display_metrics dm
SET group_by_field_id = 'DEF_CARDIO_TYPE'
WHERE dm.display_name ILIKE '%cardio%'
  AND dm.display_name NOT ILIKE '%total%'
  AND dm.chart_type_id IN ('bar_vertical', 'bar_horizontal', 'bar_stacked');

-- Meal metrics grouped by meal type
UPDATE display_metrics dm
SET group_by_field_id = 'DEF_MEAL_TYPE'
WHERE dm.display_name ILIKE '%meal%'
  AND dm.display_name NOT ILIKE '%total%'
  AND dm.chart_type_id IN ('bar_vertical', 'bar_horizontal', 'bar_stacked');

-- Sleep metrics grouped by sleep period type
UPDATE display_metrics dm
SET group_by_field_id = 'DEF_SLEEP_PERIOD_TYPE'
WHERE (dm.display_name ILIKE '%sleep stage%' OR dm.display_name ILIKE '%sleep period%')
  AND dm.chart_type_id IN ('bar_stacked', 'sleep_stages_vertical', 'sleep_amounts');


-- =====================================================
-- PART 6: Update Default Periods Based on Metric Type
-- =====================================================

-- Single-value metrics default to daily
UPDATE display_metrics
SET default_period = 'daily'
WHERE chart_type_id = 'current_value'
  AND default_period = 'weekly'; -- Only update if still default

-- Trend/time series default to weekly
UPDATE display_metrics
SET default_period = 'weekly'
WHERE chart_type_id IN ('trend_line', 'bar_vertical', 'sleep_stages_vertical')
  AND default_period = 'weekly'; -- Keep as is

-- Heatmaps default to monthly
UPDATE display_metrics
SET default_period = 'monthly'
WHERE chart_type_id = 'heatmap'
  AND 'monthly' = ANY(supported_periods);


-- =====================================================
-- PART 7: Set Null Display Values
-- =====================================================

UPDATE display_metrics
SET null_display_value = CASE
  WHEN chart_type_id = 'current_value' THEN 'No data'
  WHEN chart_type_id IN ('progress_bar', 'gauge') THEN '0'
  WHEN chart_type_id = 'streak_counter' THEN 'Not started'
  WHEN chart_type_id = 'trend_line' THEN NULL -- Interpolated, no display needed
  ELSE 'N/A'
END
WHERE null_display_value IS NULL;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_metrics INT;
  with_chart_type INT;
  by_chart_type RECORD;
BEGIN
  SELECT COUNT(*) INTO total_metrics FROM display_metrics WHERE is_active = true;
  SELECT COUNT(*) INTO with_chart_type FROM display_metrics WHERE chart_type_id IS NOT NULL AND is_active = true;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Display Metrics Chart Configuration Complete';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total active display metrics: %', total_metrics;
  RAISE NOTICE 'Metrics with chart types: %', with_chart_type;
  RAISE NOTICE '';
  RAISE NOTICE 'Breakdown by chart type:';

  FOR by_chart_type IN
    SELECT
      ct.chart_name,
      COUNT(dm.id) as count
    FROM chart_types ct
    LEFT JOIN display_metrics dm ON ct.chart_type_id = dm.chart_type_id AND dm.is_active = true
    GROUP BY ct.chart_name, ct.chart_type_id
    HAVING COUNT(dm.id) > 0
    ORDER BY COUNT(dm.id) DESC
  LOOP
    RAISE NOTICE '  %: %', by_chart_type.chart_name, by_chart_type.count;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE 'Dropped tables:';
  RAISE NOTICE '  - display_metrics_data_entry_fields';
  RAISE NOTICE '  - display_metrics_instance_calculations';
  RAISE NOTICE '  - display_metrics_readings';
  RAISE NOTICE '';
  RAISE NOTICE 'Kept tables:';
  RAISE NOTICE '  - display_metrics_survey_questions (still relevant)';
  RAISE NOTICE '  - display_metrics_aggregations (new architecture)';
END $$;

COMMIT;
