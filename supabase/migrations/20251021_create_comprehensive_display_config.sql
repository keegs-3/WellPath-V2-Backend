-- =====================================================
-- Create Comprehensive Display Configuration System
-- =====================================================
-- Based on wellpath_chart_and_calculation_reference.md
-- Implements chart types, time periods, and display settings
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Chart Types Reference Table
-- =====================================================

CREATE TABLE IF NOT EXISTS chart_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chart_type_id TEXT UNIQUE NOT NULL,
  chart_name TEXT NOT NULL,
  description TEXT,
  category TEXT, -- 'single_value', 'time_series', 'comparison', 'composition', 'sleep_specific'
  supports_selection BOOLEAN DEFAULT false, -- For sleep amounts view
  supports_stacking BOOLEAN DEFAULT false, -- For stacked bar charts
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add constraint for valid categories
ALTER TABLE chart_types
ADD CONSTRAINT chart_types_category_check
CHECK (category IN ('single_value', 'time_series', 'comparison', 'composition', 'sleep_specific'));

-- Insert chart types from reference doc
INSERT INTO chart_types (chart_type_id, chart_name, description, category, supports_selection, supports_stacking) VALUES
('current_value', 'Current Value', 'Large number display with optional trend indicator', 'single_value', false, false),
('progress_bar', 'Progress Bar', 'Horizontal bar showing progress toward goal', 'single_value', false, false),
('trend_line', 'Trend Line', 'Line graph showing change over time', 'time_series', false, false),
('bar_vertical', 'Vertical Bar Chart', 'Discrete time periods with comparison', 'time_series', false, false),
('bar_horizontal', 'Horizontal Bar Chart', 'Comparing multiple categories', 'comparison', false, false),
('bar_stacked', 'Stacked Bar Chart', 'Part-to-whole relationships over time', 'composition', true, true),
('gauge', 'Gauge/Radial Chart', 'Performance against a scale with visual urgency', 'single_value', false, false),
('heatmap', 'Heatmap', 'Patterns across two dimensions (time + category)', 'time_series', false, false),
('streak_counter', 'Streak Counter', 'Consecutive days meeting a goal', 'single_value', false, false),
('comparison_view', 'Comparison View', 'Before/after or current vs target', 'comparison', false, false),
('sleep_stages_horizontal', 'Sleep Stages (Day)', 'Horizontal timeline for single night', 'sleep_specific', false, false),
('sleep_stages_vertical', 'Sleep Stages (Week/Month)', 'Vertical bars with top-to-bottom time flow', 'sleep_specific', false, false),
('sleep_amounts', 'Sleep Amounts', 'Stacked or single-stage duration view', 'sleep_specific', true, true);


-- =====================================================
-- PART 2: Create Time Periods Reference Table
-- =====================================================

CREATE TABLE IF NOT EXISTS time_periods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  period_id TEXT UNIQUE NOT NULL,
  period_name TEXT NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  days INTEGER, -- Number of days in the period (NULL for custom periods)
  aggregation_unit TEXT, -- 'day', 'week', 'month'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add constraint for valid aggregation units
ALTER TABLE time_periods
ADD CONSTRAINT time_periods_aggregation_unit_check
CHECK (aggregation_unit IN ('day', 'week', 'month', 'quarter', 'year'));

-- Insert time periods from reference doc
INSERT INTO time_periods (period_id, period_name, display_name, description, days, aggregation_unit) VALUES
('daily', 'Daily', 'D', 'Today or single day view', 1, 'day'),
('weekly', 'Weekly', 'W', 'Rolling 7 days or calendar week', 7, 'day'),
('monthly', 'Monthly', 'M', 'Rolling 30 days or calendar month', 30, 'day'),
('6_month', '6 Months', '6M', 'Rolling 26 weeks (182 days)', 182, 'week'),
('yearly', 'Yearly', 'Y', 'Rolling 365 days or calendar year', 365, 'month'),
('custom', 'Custom', 'Custom', 'User-specified date range', NULL, 'day');


-- =====================================================
-- PART 3: Update display_metrics table with chart config
-- =====================================================
-- Chart configuration lives on display_metrics
-- Junction table just links to which aggregations to use

-- Drop columns I mistakenly added earlier (if they exist)
ALTER TABLE display_metrics
DROP COLUMN IF EXISTS chart_type CASCADE,
DROP COLUMN IF EXISTS chart_config CASCADE,
DROP COLUMN IF EXISTS null_handling CASCADE,
DROP COLUMN IF EXISTS null_display_value CASCADE,
DROP COLUMN IF EXISTS group_by_field_id CASCADE,
DROP COLUMN IF EXISTS filter_config CASCADE;

-- Add proper columns to display_metrics
ALTER TABLE display_metrics
ADD COLUMN IF NOT EXISTS chart_type_id TEXT REFERENCES chart_types(chart_type_id),
ADD COLUMN IF NOT EXISTS supported_periods TEXT[] DEFAULT ARRAY['daily', 'weekly', 'monthly'],
ADD COLUMN IF NOT EXISTS default_period TEXT DEFAULT 'weekly',
ADD COLUMN IF NOT EXISTS chart_config JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS null_handling TEXT DEFAULT 'ignore',
ADD COLUMN IF NOT EXISTS null_display_value TEXT,
ADD COLUMN IF NOT EXISTS group_by_field_id TEXT REFERENCES data_entry_fields(field_id),
ADD COLUMN IF NOT EXISTS filter_config JSONB DEFAULT '{}'::jsonb;

-- Add constraints to display_metrics
ALTER TABLE display_metrics
DROP CONSTRAINT IF EXISTS display_metrics_null_handling_check,
ADD CONSTRAINT display_metrics_null_handling_check
CHECK (null_handling IN ('ignore', 'show_as_zero', 'show_as_null', 'hide', 'interpolate'));

ALTER TABLE display_metrics
DROP CONSTRAINT IF EXISTS display_metrics_default_period_check,
ADD CONSTRAINT display_metrics_default_period_check
CHECK (default_period = ANY(supported_periods));


-- =====================================================
-- PART 4: Add helpful comments
-- =====================================================

COMMENT ON TABLE chart_types IS
'Reference table for all chart visualization types available in WellPath';

COMMENT ON COLUMN chart_types.supports_selection IS
'Whether this chart type supports selecting a single element (e.g., sleep stage selection in amounts view)';

COMMENT ON COLUMN chart_types.supports_stacking IS
'Whether this chart type supports stacked composition display';

COMMENT ON TABLE time_periods IS
'Reference table defining time windows for data aggregation and display';

COMMENT ON COLUMN time_periods.days IS
'Number of days in the period (NULL for custom periods)';

COMMENT ON COLUMN time_periods.aggregation_unit IS
'Unit to use for aggregating data within this period (day, week, month)';

COMMENT ON COLUMN display_metrics.chart_type_id IS
'Type of chart to use for displaying this metric';

COMMENT ON COLUMN display_metrics.supported_periods IS
'Array of period_ids that this metric can be displayed in (e.g., [daily, weekly, monthly])';

COMMENT ON COLUMN display_metrics.default_period IS
'Default period to show when metric is first displayed';

COMMENT ON COLUMN display_metrics.chart_config IS
'Chart-specific configuration as JSON. Examples:
- Sleep stages: {"dynamic_axis": true, "buffer_minutes": 30}
- Progress bar: {"target_value": 10000, "color_gradient": true}
- Gauge: {"min": 0, "max": 100, "zones": [{"min": 0, "max": 60, "color": "red"}, ...]}';

COMMENT ON COLUMN display_metrics.null_handling IS
'How to handle null values in the chart (ignore, show_as_zero, show_as_null, hide, interpolate)';

COMMENT ON COLUMN display_metrics.group_by_field_id IS
'For reference fields: group chart data by this field (e.g., group cardio by cardio_type_id)';

COMMENT ON COLUMN display_metrics.filter_config IS
'Filter configuration as JSON for showing subset of data. Examples:
- {"field_id": "DEF_CARDIO_TYPE", "operator": "equals", "value": "running"}
- {"field_id": "DEF_SLEEP_PERIOD_TYPE", "operator": "in", "values": ["rem", "deep"]}';


-- =====================================================
-- PART 5: Create example display configurations
-- =====================================================

-- Example: Sleep Duration as Trend Line
DO $$
DECLARE
  display_id TEXT := 'DISP_SLEEP_DURATION';
  agg_id TEXT := 'AGG_SLEEP_SESSION_DURATION';
BEGIN
  -- Insert display_metric with chart configuration
  INSERT INTO display_metrics (
    id, display_metric_id, display_name, description, is_active,
    chart_type_id, supported_periods, default_period, chart_config, null_handling
  ) VALUES (
    gen_random_uuid(), display_id, 'Sleep Duration',
    'Track your sleep duration over time', true,
    'trend_line', ARRAY['weekly', 'monthly', '6_month'], 'weekly',
    '{"show_target_line": true, "target_hours": 8}'::jsonb, 'interpolate'
  ) ON CONFLICT (display_metric_id) DO NOTHING;

  -- Link to aggregation metrics
  INSERT INTO display_metrics_aggregations (
    id, display_metric_id, agg_metric_id, calculation_type_id, period_type, is_primary
  ) VALUES (
    gen_random_uuid(), display_id, agg_id, 'AVG', 'weekly', true
  ) ON CONFLICT DO NOTHING;
END $$;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  chart_count INT;
  period_count INT;
BEGIN
  SELECT COUNT(*) INTO chart_count FROM chart_types;
  SELECT COUNT(*) INTO period_count FROM time_periods;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Display Configuration System Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Chart types defined: %', chart_count;
  RAISE NOTICE 'Time periods defined: %', period_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Chart types:';
  RAISE NOTICE '  - Single value: current_value, progress_bar, gauge, streak_counter';
  RAISE NOTICE '  - Time series: trend_line, bar_vertical, heatmap';
  RAISE NOTICE '  - Comparison: bar_horizontal, comparison_view';
  RAISE NOTICE '  - Composition: bar_stacked';
  RAISE NOTICE '  - Sleep specific: sleep_stages_horizontal, sleep_stages_vertical, sleep_amounts';
  RAISE NOTICE '';
  RAISE NOTICE 'Time periods:';
  RAISE NOTICE '  - daily, weekly, monthly, 6_month, yearly, custom';
  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Populate display_metrics_aggregations with configurations';
END $$;

COMMIT;
