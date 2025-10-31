#!/usr/bin/env python3
"""
Create missing AGG_* metrics that have corresponding CALC_* or DEF_* sources
"""

import psycopg2

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Read missing agg_metrics
with open('outputs/missing_agg_metrics.txt', 'r') as f:
    missing = [line.strip() for line in f if line.strip() and not line.startswith('Missing')]

print(f"Found {len(missing)} missing AGG_* metrics\n")

# For each, get the source and determine unit
entries = []
for agg_id in missing:
    # Determine source
    if agg_id.startswith('AGG_'):
        base = agg_id.replace('AGG_', '')

        # Check if CALC_* exists
        calc_id = f'CALC_{base}'
        cur.execute("SELECT calc_id, unit_id FROM instance_calculations WHERE calc_id = %s", (calc_id,))
        calc_result = cur.fetchone()

        if calc_result:
            unit = calc_result[1] or 'count'
            display_name = base.replace('_', ' ').title()
            entries.append({
                'agg_id': agg_id,
                'display_name': display_name,
                'unit': unit,
                'source': calc_id
            })
            continue

        # Check if DEF_* exists
        field_id = f'DEF_{base}'
        cur.execute("SELECT field_id, unit FROM data_entry_fields WHERE field_id = %s", (field_id,))
        field_result = cur.fetchone()

        if field_result:
            unit = field_result[1] or 'count'
            display_name = base.replace('_', ' ').title()
            entries.append({
                'agg_id': agg_id,
                'display_name': display_name,
                'unit': unit,
                'source': field_id
            })

print(f"Matched {len(entries)} to sources\n")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Create Missing Aggregation Metrics
-- =====================================================
-- AGG_* metrics that have corresponding CALC_* or DEF_* sources
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Aggregation Metrics
-- =====================================================

INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, output_unit, is_active)
VALUES
""")

for i, entry in enumerate(entries):
    agg_id = entry['agg_id']
    metric_name = agg_id.replace('AGG_', '').lower()
    display_name = entry['display_name']
    description = f"Aggregated {display_name.lower()}"
    unit = entry['unit']

    comma = "," if i < len(entries) - 1 else ";"
    sql_parts.append(f"('{agg_id}', '{metric_name}', '{display_name}', '{description}', '{unit}', true){comma}\n")

sql_parts.append("""

-- =====================================================
-- PART 2: Create Aggregation Metrics Periods Config
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id, chart_type, x_axis_type, x_axis_granularity, bars, days, y_axis_min, y_axis_max, y_axis_label, y_axis_auto_scale)
VALUES
""")

period_configs = {
    'daily': {'bars': 24, 'days': 1, 'granularity': 'hour'},
    'weekly': {'bars': 7, 'days': 7, 'granularity': 'day'},
    'monthly': {'bars': 33, 'days': 33, 'granularity': 'day'},
}

values = []
for entry in entries:
    agg_id = entry['agg_id']
    unit = entry['unit']

    # Determine defaults
    if 'duration' in agg_id.lower():
        y_min, y_max = 0, 120
    elif 'count' in agg_id.lower() or 'session' in agg_id.lower():
        y_min, y_max = 0, 10
    elif 'quantity' in agg_id.lower():
        y_min, y_max = 0, 100
    else:
        y_min, y_max = 0, 100

    for period_id, config in period_configs.items():
        values.append(
            f"('{agg_id}', '{period_id}', 'bar_vertical', 'date', '{config['granularity']}', "
            f"{config['bars']}, {config['days']}, {y_min}, {y_max}, '{unit}', true)"
        )

sql_parts.append(",\n".join(values))
sql_parts.append(";\n\n")

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

  RAISE NOTICE '✅ Missing Aggregation Metrics Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total aggregation_metrics: %', agg_count;
  RAISE NOTICE 'Total aggregation_metrics_periods: %', period_count;
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_create_missing_agg_from_sources.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"✅ SQL generated: {output_file}")
print(f"Total AGG_* metrics to create: {len(entries)}")
print(f"Total period configs to create: {len(entries) * 3}")

cur.close()
conn.close()
