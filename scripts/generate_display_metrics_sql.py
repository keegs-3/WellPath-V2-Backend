#!/usr/bin/env python3
"""
Generate SQL to create all display_metrics
"""

import csv

# Read the mapping CSV
mapping_file = 'outputs/display_metrics_mapping.csv'
all_metrics = []

with open(mapping_file, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        all_metrics.append(row)

print(f"Found {len(all_metrics)} display metrics to create\n")

# De-duplicate by display_metric_id
seen_ids = set()
unique_metrics = []
for metric in all_metrics:
    display_id = metric['new_display_metric_id']
    if display_id not in seen_ids:
        unique_metrics.append(metric)
        seen_ids.add(display_id)

print(f"After de-duplication: {len(unique_metrics)} unique display metrics\n")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Create All Display Metrics
-- =====================================================
-- Generated from display_metrics mapping
-- Creates display_metrics entries for all tracked metrics
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Display Metrics
-- =====================================================

""")

# Group by pillar for organization
by_pillar = {}
for metric in unique_metrics:
    pillar = metric['pillar'] or 'No Pillar'
    if pillar not in by_pillar:
        by_pillar[pillar] = []
    by_pillar[pillar].append(metric)

for pillar in sorted(by_pillar.keys()):
    metrics = by_pillar[pillar]
    sql_parts.append(f"-- {pillar} ({len(metrics)} metrics)\n")
    sql_parts.append("INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)\nVALUES\n")

    for i, metric in enumerate(metrics):
        display_id = metric['new_display_metric_id']
        display_name = metric['display_name'].replace("'", "''")  # Escape quotes
        pillar_val = metric['pillar'] if metric['pillar'] else None
        widget_type = 'chart'  # All are charts
        chart_type = metric['chart_type_id']
        display_unit = metric['display_unit']
        supported_periods = "ARRAY['daily', 'weekly', 'monthly']"
        default_period = 'weekly'

        # Handle NULL pillar
        pillar_sql = f"'{pillar_val}'" if pillar_val and pillar_val != 'No Pillar' else 'NULL'

        comma = "," if i < len(metrics) - 1 else ""
        sql_parts.append(
            f"('{display_id}', '{display_name}', {pillar_sql}, '{widget_type}', '{chart_type}', "
            f"'{display_unit}', {supported_periods}, '{default_period}', true){comma}\n"
        )

    sql_parts.append("""ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

""")

# Add summary
sql_parts.append("""
-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  dm_count INT;
BEGIN
  SELECT COUNT(*) INTO dm_count FROM display_metrics;

  RAISE NOTICE '✅ Display Metrics Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total display_metrics: %', dm_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Link display_metrics to aggregation_metrics via display_metrics_aggregations';
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_create_all_display_metrics.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"✅ SQL generated: {output_file}")
print(f"\nTotal display_metrics to create: {len(unique_metrics)}")

print("\n=== BREAKDOWN BY PILLAR ===")
for pillar in sorted(by_pillar.keys()):
    print(f"{pillar:30} : {len(by_pillar[pillar]):3} metrics")
