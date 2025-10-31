#!/usr/bin/env python3
"""
Generate aggregation_metrics_calculation_types for all aggregation metrics
"""

import psycopg2

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Get all aggregation_metrics
cur.execute("""
    SELECT agg_id, metric_name, display_name, output_unit
    FROM aggregation_metrics
    ORDER BY agg_id
""")
agg_metrics = cur.fetchall()

print(f"Found {len(agg_metrics)} aggregation_metrics\n")

# Determine appropriate calculation types for each metric
entries = []

for agg_id, metric_name, display_name, output_unit in agg_metrics:
    name_lower = display_name.lower() if display_name else metric_name.lower()

    # Determine calculation types based on metric type
    calc_types = []

    # Variety/Diversity metrics → COUNT_DISTINCT
    if 'variety' in name_lower or 'diversity' in name_lower or 'source count' in name_lower:
        calc_types = ['COUNT_DISTINCT']

    # Session counts → SUM and COUNT_UNIQUE_DAYS
    elif 'session' in name_lower and 'count' in name_lower:
        calc_types = ['SUM', 'COUNT_UNIQUE_DAYS']

    # Duration metrics → AVG, SUM, MIN, MAX
    elif 'duration' in name_lower or 'time' in name_lower:
        calc_types = ['AVG', 'SUM', 'MIN', 'MAX']

    # Counts/Episodes → SUM, COUNT_UNIQUE_DAYS
    elif any(x in name_lower for x in ['count', 'episodes', 'sessions', 'meals', 'drinks', 'cigarettes']):
        calc_types = ['SUM', 'COUNT_UNIQUE_DAYS']

    # Servings/Quantities → AVG, SUM
    elif any(x in name_lower for x in ['serving', 'quantity', 'grams', 'calories', 'steps']):
        calc_types = ['AVG', 'SUM']

    # Percentages/Ratios → AVG, MIN, MAX
    elif any(x in name_lower for x in ['percentage', 'ratio', 'adherence', 'compliance']):
        calc_types = ['AVG', 'MIN', 'MAX']

    # Ratings/Scores → AVG, MIN, MAX
    elif any(x in name_lower for x in ['rating', 'score']):
        calc_types = ['AVG', 'MIN', 'MAX']

    # Blood pressure, biometrics → AVG, MIN, MAX
    elif any(x in name_lower for x in ['blood pressure', 'heart rate', 'weight', 'bmi', 'body fat']):
        calc_types = ['AVG', 'MIN', 'MAX']

    # Default: AVG, SUM for most numeric values
    else:
        calc_types = ['AVG', 'SUM']

    # Add entries
    for calc_type in calc_types:
        entries.append({
            'aggregation_metric_id': agg_id,
            'calculation_type_id': calc_type
        })

print(f"Generated {len(entries)} calculation type entries\n")

# Show distribution
calc_type_counts = {}
for entry in entries:
    ct = entry['calculation_type_id']
    calc_type_counts[ct] = calc_type_counts.get(ct, 0) + 1

print("Distribution by calculation type:")
for ct in sorted(calc_type_counts.keys()):
    print(f"  {ct:20} : {calc_type_counts[ct]:4} entries")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Create Aggregation Metrics Calculation Types
-- =====================================================
-- Defines which calculation types each aggregation supports
-- (SUM, AVG, MIN, MAX, COUNT_DISTINCT, COUNT_UNIQUE_DAYS)
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Delete existing (start fresh)
DELETE FROM aggregation_metrics_calculation_types;

-- =====================================================
-- Create Calculation Types
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types
(aggregation_metric_id, calculation_type_id)
VALUES
""")

for i, entry in enumerate(entries):
    agg_id = entry['aggregation_metric_id']
    calc_type = entry['calculation_type_id']

    comma = "," if i < len(entries) - 1 else ";"
    sql_parts.append(f"('{agg_id}', '{calc_type}'){comma}\n")

sql_parts.append("""

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  calc_type_count INT;
  metrics_with_types INT;
BEGIN
  SELECT COUNT(*) INTO calc_type_count FROM aggregation_metrics_calculation_types;
  SELECT COUNT(DISTINCT aggregation_metric_id) INTO metrics_with_types
  FROM aggregation_metrics_calculation_types;

  RAISE NOTICE '✅ Aggregation Metrics Calculation Types Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total calculation type entries: %', calc_type_count;
  RAISE NOTICE 'Aggregation metrics with calc types: %', metrics_with_types;
  RAISE NOTICE '';
  RAISE NOTICE 'Calculation types: SUM, AVG, MIN, MAX, COUNT_DISTINCT, COUNT_UNIQUE_DAYS';
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_create_calculation_types.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"\n✅ SQL generated: {output_file}")
print(f"Total calculation type entries: {len(entries)}")

cur.close()
conn.close()
