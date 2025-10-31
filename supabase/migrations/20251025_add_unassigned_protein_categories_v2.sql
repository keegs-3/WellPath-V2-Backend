-- Add 'unassigned' to protein_types and food_timing reference categories
-- This is used when users enter protein without specifying type or timing

-- Add unassigned to protein_types
INSERT INTO data_entry_fields_reference (
    reference_category,
    reference_key,
    display_name,
    display_order
) VALUES (
    'protein_types',
    'unassigned',
    'Unassigned',
    999
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Add unassigned to food_timing
INSERT INTO data_entry_fields_reference (
    reference_category,
    reference_key,
    display_name,
    display_order
) VALUES (
    'food_timing',
    'unassigned',
    'Unassigned',
    999
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Create AGG_PROTEIN_TYPE_UNASSIGNED aggregation metric
INSERT INTO aggregation_metrics (
    agg_id,
    metric_name,
    display_name,
    description,
    output_unit
) VALUES (
    'AGG_PROTEIN_TYPE_UNASSIGNED',
    'protein_type_unassigned',
    'Unassigned Protein Type',
    'Total protein from unspecified sources',
    'grams'
) ON CONFLICT (agg_id) DO NOTHING;

-- Create AGG_PROTEIN_UNASSIGNED_GRAMS aggregation metric (for unassigned timing)
INSERT INTO aggregation_metrics (
    agg_id,
    metric_name,
    display_name,
    description,
    output_unit
) VALUES (
    'AGG_PROTEIN_UNASSIGNED_GRAMS',
    'protein_unassigned_timing',
    'Unassigned Timing Protein',
    'Total protein consumed at unspecified times',
    'grams'
) ON CONFLICT (agg_id) DO NOTHING;

-- Add dependencies for AGG_PROTEIN_TYPE_UNASSIGNED
-- This should filter by protein_type = 'unassigned'
INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    data_entry_field_id,
    dependency_type,
    filter_conditions
) VALUES (
    'AGG_PROTEIN_TYPE_UNASSIGNED',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"protein_type": "unassigned"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Add period types for unassigned protein type
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_type)
SELECT 'AGG_PROTEIN_TYPE_UNASSIGNED', period_type
FROM unnest(ARRAY['hourly', 'daily', 'weekly', 'monthly', '6month', 'yearly']) AS period_type
ON CONFLICT DO NOTHING;

-- Add dependencies for AGG_PROTEIN_UNASSIGNED_GRAMS
-- This should filter by protein_timing = 'unassigned'
INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    data_entry_field_id,
    dependency_type,
    filter_conditions
) VALUES (
    'AGG_PROTEIN_UNASSIGNED_GRAMS',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"protein_timing": "unassigned"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Add period types for unassigned protein timing
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_type)
SELECT 'AGG_PROTEIN_UNASSIGNED_GRAMS', period_type
FROM unnest(ARRAY['daily', 'weekly', 'monthly', '6month', 'yearly']) AS period_type
ON CONFLICT DO NOTHING;

-- Add to display_metrics_aggregations for protein type chart
INSERT INTO display_metrics_aggregations (
    metric_id,
    agg_metric_id,
    period_type,
    calculation_type_id,
    display_order,
    series_label,
    series_color
) VALUES (
    'METRIC_PROTEIN_TYPES',
    'AGG_PROTEIN_TYPE_UNASSIGNED',
    'hourly',
    'SUM',
    999,
    'Unassigned',
    '#999999'
) ON CONFLICT DO NOTHING;

-- Add to display_metrics_aggregations for protein timing chart
INSERT INTO display_metrics_aggregations (
    metric_id,
    agg_metric_id,
    period_type,
    calculation_type_id,
    display_order,
    series_label,
    series_color
) VALUES (
    'METRIC_PROTEIN_TIMING',
    'AGG_PROTEIN_UNASSIGNED_GRAMS',
    'daily',
    'SUM',
    999,
    'Unassigned',
    '#999999'
) ON CONFLICT DO NOTHING;

SELECT
    '✅ Added unassigned categories and aggregation metrics' as status,
    COUNT(*) FILTER (WHERE reference_category = 'protein_types' AND reference_key = 'unassigned') as protein_type_count,
    COUNT(*) FILTER (WHERE reference_category = 'food_timing' AND reference_key = 'unassigned') as food_timing_count
FROM data_entry_fields_reference
WHERE reference_key = 'unassigned';
