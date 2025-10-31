-- Add "other" to protein_types for user selection
-- Create "unassigned" aggregation metrics for edge cases (not for user selection)

-- Add "other" to protein_types (for user selection in app)
INSERT INTO data_entry_fields_reference (
    reference_category,
    reference_key,
    display_name,
    display_order
) VALUES (
    'protein_types',
    'other',
    'Other',
    100
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Create AGG_PROTEIN_TYPE_OTHER for "other" protein type
INSERT INTO aggregation_metrics (
    agg_id,
    metric_name,
    display_name,
    description,
    output_unit
) VALUES (
    'AGG_PROTEIN_TYPE_OTHER',
    'protein_type_other',
    'Other Protein Type',
    'Total protein from other sources',
    'gram'
) ON CONFLICT (agg_id) DO NOTHING;

-- Create AGG_PROTEIN_TYPE_UNASSIGNED for edge cases (no protein type specified)
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
    'Total protein from unspecified sources (data quality metric)',
    'gram'
) ON CONFLICT (agg_id) DO NOTHING;

-- Create AGG_PROTEIN_UNASSIGNED_GRAMS for edge cases (no timing specified)
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
    'Total protein consumed at unspecified times (data quality metric)',
    'gram'
) ON CONFLICT (agg_id) DO NOTHING;

-- Add dependencies for AGG_PROTEIN_TYPE_OTHER (filters by protein_type = 'other')
INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    data_entry_field_id,
    dependency_type,
    filter_conditions
) VALUES (
    'AGG_PROTEIN_TYPE_OTHER',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"protein_type": "other"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Add dependencies for AGG_PROTEIN_TYPE_UNASSIGNED (catches protein without type)
INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    data_entry_field_id,
    dependency_type,
    filter_conditions
) VALUES (
    'AGG_PROTEIN_TYPE_UNASSIGNED',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"protein_type": null}'::jsonb
) ON CONFLICT DO NOTHING;

-- Add dependencies for AGG_PROTEIN_UNASSIGNED_GRAMS (catches protein without timing)
INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    data_entry_field_id,
    dependency_type,
    filter_conditions
) VALUES (
    'AGG_PROTEIN_UNASSIGNED_GRAMS',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"protein_timing": null}'::jsonb
) ON CONFLICT DO NOTHING;

-- Add period types for all three metrics
DO $$
DECLARE
    agg_id_val text;
    period_val text;
BEGIN
    FOR agg_id_val IN SELECT unnest(ARRAY['AGG_PROTEIN_TYPE_OTHER', 'AGG_PROTEIN_TYPE_UNASSIGNED']) LOOP
        FOR period_val IN SELECT unnest(ARRAY['hourly', 'daily', 'weekly', 'monthly', '6month', 'yearly']) LOOP
            INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
            VALUES (agg_id_val, period_val)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;

    -- AGG_PROTEIN_UNASSIGNED_GRAMS doesn't need hourly
    FOR period_val IN SELECT unnest(ARRAY['daily', 'weekly', 'monthly', '6month', 'yearly']) LOOP
        INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
        VALUES ('AGG_PROTEIN_UNASSIGNED_GRAMS', period_val)
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

SELECT
    '✅ Added "other" to protein_types and created unassigned aggregation metrics' as status,
    COUNT(*) FILTER (WHERE reference_category = 'protein_types' AND reference_key = 'other') as protein_type_other_count,
    COUNT(*) FILTER (WHERE agg_id LIKE '%UNASSIGNED%') as unassigned_agg_count
FROM data_entry_fields_reference
FULL OUTER JOIN aggregation_metrics ON false
WHERE reference_key = 'other' OR agg_id LIKE '%UNASSIGNED%';
