-- =====================================================
-- Add Display Configuration Columns
-- =====================================================
-- Adds columns for chart display and reference field handling
-- at the display_metrics level
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Add columns to display_metrics table
-- =====================================================

-- Chart configuration
ALTER TABLE display_metrics
ADD COLUMN IF NOT EXISTS chart_type TEXT,
ADD COLUMN IF NOT EXISTS chart_config JSONB DEFAULT '{}'::jsonb;

-- Null handling
ALTER TABLE display_metrics
ADD COLUMN IF NOT EXISTS null_handling TEXT DEFAULT 'ignore',
ADD COLUMN IF NOT EXISTS null_display_value TEXT;

-- Reference field grouping/filtering
ALTER TABLE display_metrics
ADD COLUMN IF NOT EXISTS group_by_field_id TEXT,
ADD COLUMN IF NOT EXISTS filter_config JSONB DEFAULT '{}'::jsonb;

-- Add foreign key for group_by_field_id
ALTER TABLE display_metrics
ADD CONSTRAINT display_metrics_group_by_field_fkey
FOREIGN KEY (group_by_field_id)
REFERENCES data_entry_fields(field_id);

-- Add check constraint for null_handling
ALTER TABLE display_metrics
ADD CONSTRAINT display_metrics_null_handling_check
CHECK (null_handling IN ('ignore', 'show_as_zero', 'show_as_null', 'hide', 'interpolate'));

-- Add check constraint for chart_type (common types)
ALTER TABLE display_metrics
ADD CONSTRAINT display_metrics_chart_type_check
CHECK (chart_type IS NULL OR chart_type IN (
  'line', 'bar', 'area', 'pie', 'donut', 'scatter',
  'heatmap', 'gauge', 'stat_card', 'table', 'timeline',
  'gantt', 'radar', 'bubble', 'treemap'
));


-- =====================================================
-- Add helpful comments
-- =====================================================

COMMENT ON COLUMN display_metrics.chart_type IS
'Type of chart to display (line, bar, pie, etc.)';

COMMENT ON COLUMN display_metrics.chart_config IS
'Chart-specific configuration (colors, axes, legends, etc.) as JSON';

COMMENT ON COLUMN display_metrics.null_handling IS
'How to handle null values: ignore (skip), show_as_zero, show_as_null, hide (hide entire metric), interpolate';

COMMENT ON COLUMN display_metrics.null_display_value IS
'Value to display for nulls (e.g., "N/A", "No data", "-")';

COMMENT ON COLUMN display_metrics.group_by_field_id IS
'For reference fields: group results by this field (e.g., group cardio by cardio_type)';

COMMENT ON COLUMN display_metrics.filter_config IS
'Filter configuration as JSON. Examples:
- {"field_id": "DEF_CARDIO_TYPE", "operator": "equals", "value": "running"}
- {"field_id": "DEF_MEAL_TYPE", "operator": "in", "values": ["breakfast", "lunch"]}
- {"field_id": "DEF_SLEEP_QUALITY", "operator": "gte", "value": 4}';


-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Display Configuration Columns Added';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Added to display_metrics:';
  RAISE NOTICE '  - chart_type (line, bar, pie, etc.)';
  RAISE NOTICE '  - chart_config (JSON for chart-specific config)';
  RAISE NOTICE '  - null_handling (ignore, show_as_zero, etc.)';
  RAISE NOTICE '  - null_display_value (display text for nulls)';
  RAISE NOTICE '  - group_by_field_id (for reference field grouping)';
  RAISE NOTICE '  - filter_config (JSON for filtering)';
  RAISE NOTICE '';
  RAISE NOTICE 'Examples:';
  RAISE NOTICE '  - Show cardio duration as line chart, ignore nulls';
  RAISE NOTICE '  - Show cardio count grouped by cardio_type as bar chart';
  RAISE NOTICE '  - Show only "Running" cardio with filter_config';
  RAISE NOTICE '  - Show sleep periods grouped by sleep_period_type';
END $$;

COMMIT;
