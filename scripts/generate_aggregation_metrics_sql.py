#!/usr/bin/env python3
"""
Generate SQL to create all missing aggregation_metrics
"""

import csv
import re

# Read the mapping CSV
mapping_file = 'outputs/display_metrics_mapping.csv'
missing_agg_metrics = []
seen_agg_ids = set()

with open(mapping_file, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row['agg_exists'] == 'NO':
            agg_id = row['agg_metric_id']
            # De-duplicate: only add if we haven't seen this agg_id before
            if agg_id not in seen_agg_ids:
                missing_agg_metrics.append(row)
                seen_agg_ids.add(agg_id)

print(f"Found {len(missing_agg_metrics)} unique missing aggregation metrics (de-duplicated)\n")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Create All Missing Aggregation Metrics
-- =====================================================
-- Generated from display_metrics mapping
-- Creates aggregation_metrics and aggregation_metrics_periods entries
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

""")

# Group by pattern for organization
by_pattern = {}
for metric in missing_agg_metrics:
    pattern = metric['pattern']
    if pattern not in by_pattern:
        by_pattern[pattern] = []
    by_pattern[pattern].append(metric)

# Create aggregation_metrics entries
sql_parts.append("-- =====================================================\n")
sql_parts.append("-- PART 1: Create Aggregation Metrics\n")
sql_parts.append("-- =====================================================\n\n")

for pattern in sorted(by_pattern.keys()):
    metrics = by_pattern[pattern]
    sql_parts.append(f"-- {pattern} Pattern ({len(metrics)} metrics)\n")
    sql_parts.append("INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, output_unit, is_active)\nVALUES\n")

    for i, metric in enumerate(metrics):
        agg_id = metric['agg_metric_id']
        metric_name = agg_id.replace('AGG_', '').lower()
        display_name = metric['display_name']
        output_unit = metric['display_unit']
        description = f"Aggregated {display_name.lower()}"

        comma = "," if i < len(metrics) - 1 else ";"
        sql_parts.append(f"('{agg_id}', '{metric_name}', '{display_name}', '{description}', '{output_unit}', true){comma}\n")

    sql_parts.append("\n")

# Create aggregation_metrics_periods entries
sql_parts.append("\n-- =====================================================\n")
sql_parts.append("-- PART 2: Create Aggregation Metrics Periods Config\n")
sql_parts.append("-- =====================================================\n\n")

# Get period config from aggregation_periods
period_configs = {
    'daily': {'bars': 24, 'days': 1, 'granularity': 'hour'},
    'weekly': {'bars': 7, 'days': 7, 'granularity': 'day'},
    'monthly': {'bars': 33, 'days': 33, 'granularity': 'day'},
}

for pattern in sorted(by_pattern.keys()):
    metrics = by_pattern[pattern]
    sql_parts.append(f"-- {pattern} Pattern\n")
    sql_parts.append("INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id, chart_type, x_axis_type, x_axis_granularity, bars, days, y_axis_min, y_axis_max, y_axis_label, y_axis_auto_scale)\nVALUES\n")

    values = []
    for metric in metrics:
        agg_id = metric['agg_metric_id']
        chart_type = metric['chart_type_id']
        output_unit = metric['display_unit']

        # Determine y-axis defaults based on pattern and unit
        if pattern == 'DURATION':
            if output_unit == 'hours':
                y_min, y_max = 0, 10
            else:  # minutes
                y_min, y_max = 0, 120
        elif pattern == 'SESSION_COUNT':
            y_min, y_max = 0, 5
        elif pattern == 'SERVINGS':
            y_min, y_max = 0, 10
        elif pattern == 'GRAMS':
            y_min, y_max = 0, 150
        elif pattern == 'RATING':
            y_min, y_max = 0, 10
        elif pattern == 'VARIETY':
            y_min, y_max = 0, 15
        else:
            y_min, y_max = 0, 100

        for period_id, config in period_configs.items():
            values.append(
                f"('{agg_id}', '{period_id}', '{chart_type}', 'date', '{config['granularity']}', "
                f"{config['bars']}, {config['days']}, {y_min}, {y_max}, '{output_unit}', true)"
            )

    sql_parts.append(",\n".join(values))
    sql_parts.append(";\n\n")

# Add summary
sql_parts.append("""
-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  agg_count INT;
  period_count INT;
BEGIN
  SELECT COUNT(*) INTO agg_count FROM aggregation_metrics;
  SELECT COUNT(*) INTO period_count FROM aggregation_metrics_periods;

  RAISE NOTICE '✅ Aggregation Metrics Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total aggregation_metrics: %', agg_count;
  RAISE NOTICE 'Total aggregation_metrics_periods: %', period_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Ready to create display_metrics!';
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_create_all_missing_aggregation_metrics.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"✅ SQL generated: {output_file}")
print(f"\nTotal aggregation_metrics to create: {len(missing_agg_metrics)}")
print(f"Total aggregation_metrics_periods to create: {len(missing_agg_metrics) * 3}")

print("\n=== BREAKDOWN BY PATTERN ===")
for pattern in sorted(by_pattern.keys()):
    print(f"{pattern:25} : {len(by_pattern[pattern]):3} metrics")
