-- =====================================================================================
-- Add Hourly Period to Aggregation System
-- =====================================================================================
-- Creates 'hourly' period type for single-day hourly breakdowns
-- Used for daily view parent cards that need hour-by-hour data
-- =====================================================================================

-- Add hourly period
INSERT INTO aggregation_periods (
  period_id,
  period_name,
  x_axis_granularity,
  bars,
  days,
  description,
  x_axis_label_positions,
  x_axis_label_values,
  calculation_type,
  label_format
) VALUES (
  'hourly',
  'Hourly',
  'hour',
  24,
  1,
  'Single day view with hourly granularity (24 hours)',
  ARRAY[0, 6, 12, 18],
  ARRAY['12 AM', '6', '12 PM', '6'],
  'SUM',
  '{period_name}'
)
ON CONFLICT (period_id) DO UPDATE SET
  period_name = EXCLUDED.period_name,
  x_axis_granularity = EXCLUDED.x_axis_granularity,
  bars = EXCLUDED.bars,
  days = EXCLUDED.days,
  description = EXCLUDED.description,
  calculation_type = EXCLUDED.calculation_type;

-- Add hourly period to protein grams aggregation
INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id,
  chart_type,
  x_axis_type,
  x_axis_granularity,
  bars,
  days,
  y_axis_label,
  y_axis_auto_scale
) VALUES (
  'AGG_PROTEIN_GRAMS',
  'hourly',
  'bar_vertical',
  'temporal',
  'hour',
  24,
  1,
  'Grams',
  true
)
ON CONFLICT DO NOTHING;

-- Add calculation type for hourly
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
) VALUES (
  'AGG_PROTEIN_GRAMS',
  'SUM'
)
ON CONFLICT DO NOTHING;

-- Verify
SELECT
  'Hourly period configured for:' as status,
  am.agg_id,
  am.display_name,
  COUNT(DISTINCT amp.period_id) as period_count
FROM aggregation_metrics am
JOIN aggregation_metrics_periods amp ON amp.agg_metric_id = am.agg_id
WHERE am.agg_id = 'AGG_PROTEIN_GRAMS'
GROUP BY am.agg_id, am.display_name;
