#!/usr/bin/env python3
"""
Generate display_metrics_aggregations links with Apple Health pattern
"""

import psycopg2
import csv

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Read the mapping CSV we created earlier
mapping_file = 'outputs/display_metrics_mapping.csv'
metric_mappings = {}

with open(mapping_file, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        disp_id = row['new_display_metric_id']
        agg_id = row['agg_metric_id']
        disp_name = row['display_name']
        metric_mappings[disp_id] = {
            'agg_id': agg_id,
            'display_name': disp_name
        }

print(f"Loaded {len(metric_mappings)} display → agg mappings from CSV")

# Get all aggregation_metrics to verify they exist
cur.execute("SELECT agg_id FROM aggregation_metrics")
agg_metrics = {row[0] for row in cur.fetchall()}

print(f"Found {len(agg_metrics)} aggregation_metrics in database\n")

# Map display_metric → aggregation_metric
mappings = []
unmatched = []

for disp_id, mapping_info in metric_mappings.items():
    agg_id = mapping_info['agg_id']  # Use the agg_id from CSV mapping
    disp_name = mapping_info['display_name']

    # Check if the AGG_* metric exists in database
    if agg_id not in agg_metrics:
        unmatched.append({'disp_id': disp_id, 'disp_name': disp_name, 'expected_agg': agg_id})
        continue

    # Determine calculation type by period (Apple Health pattern)
    # Daily: SUM for counts/sessions, AVG for rates/durations
    # Weekly/Monthly/6M/Yearly: AVG (shows average per day)

    is_count = any(x in disp_name.lower() for x in ['session', 'count', 'variety', 'episodes', 'meals', 'drinks'])
    is_duration = 'duration' in disp_name.lower()
    is_servings = 'serving' in disp_name.lower()

    # Daily calculation type
    if is_count or is_servings:
        daily_calc = 'SUM'  # Shows TOTAL for the day
    else:
        daily_calc = 'AVG'  # Shows AVERAGE for the day

    # All other periods use AVG (average per day)
    other_calc = 'AVG'

    # Create mappings for each period
    for period_type in ['daily', 'weekly', 'monthly']:
        calc_type = daily_calc if period_type == 'daily' else other_calc

        mappings.append({
            'display_metric_id': disp_id,
            'agg_metric_id': agg_id,
            'period_type': period_type,
            'calculation_type_id': calc_type,
            'is_primary': True
        })

print(f"✓ Matched {len(mappings) // 3} display_metrics to aggregation_metrics")
print(f"✗ Unmatched {len(unmatched)} display_metrics\n")

if unmatched:
    print("Unmatched display_metrics (no corresponding AGG_*):")
    for item in unmatched[:20]:
        print(f"  {item['disp_id']:50} → {item['expected_agg']}")
    if len(unmatched) > 20:
        print(f"  ... and {len(unmatched) - 20} more\n")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Create Display Metrics Aggregations Links
-- =====================================================
-- Links display_metrics to aggregation_metrics with Apple Health pattern
-- Daily: SUM for counts, AVG for rates
-- Weekly/Monthly: AVG (average per day)
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Delete existing links (start fresh)
DELETE FROM display_metrics_aggregations;

-- =====================================================
-- Create Links with Apple Health Pattern
-- =====================================================

INSERT INTO display_metrics_aggregations
(display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
""")

for i, mapping in enumerate(mappings):
    disp_id = mapping['display_metric_id']
    agg_id = mapping['agg_metric_id']
    period_type = mapping['period_type']
    calc_type = mapping['calculation_type_id']
    is_primary = mapping['is_primary']
    display_order = ['daily', 'weekly', 'monthly'].index(period_type) + 1

    comma = "," if i < len(mappings) - 1 else ";"
    sql_parts.append(
        f"('{disp_id}', '{agg_id}', '{period_type}', '{calc_type}', {is_primary}, {display_order}){comma}\n"
    )

sql_parts.append("""

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  link_count INT;
  metrics_with_links INT;
BEGIN
  SELECT COUNT(*) INTO link_count FROM display_metrics_aggregations;
  SELECT COUNT(DISTINCT display_metric_id) INTO metrics_with_links FROM display_metrics_aggregations;

  RAISE NOTICE '✅ Display Metrics Aggregations Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total links: %', link_count;
  RAISE NOTICE 'Display metrics with links: %', metrics_with_links;
  RAISE NOTICE '';
  RAISE NOTICE 'Apple Health Pattern Applied:';
  RAISE NOTICE '  Daily: SUM for counts, AVG for rates';
  RAISE NOTICE '  Weekly/Monthly: AVG (average per day)';
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_create_display_metrics_aggregations.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"✅ SQL generated: {output_file}")
print(f"Total links to create: {len(mappings)}")
print(f"Display metrics with links: {len(mappings) // 3}")

# Save unmatched for reference
if unmatched:
    with open('outputs/unmatched_display_metrics.txt', 'w') as f:
        f.write("Display metrics without matching aggregation_metrics:\n\n")
        for item in unmatched:
            f.write(f"{item['disp_id']} → {item['expected_agg']} ({item['disp_name']})\n")
    print(f"\nℹ️  Unmatched display metrics saved to outputs/unmatched_display_metrics.txt")

cur.close()
conn.close()
