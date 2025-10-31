#!/usr/bin/env python3
"""
Generate aggregation_metrics_dependencies for all existing calculations and fields
"""

import psycopg2

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Get all instance_calculations
cur.execute("SELECT calc_id FROM instance_calculations WHERE is_active = true ORDER BY calc_id")
calculations = [row[0] for row in cur.fetchall()]

# Get all data_entry_fields that should be aggregated (not static metadata)
cur.execute("""
    SELECT field_id
    FROM data_entry_fields
    WHERE is_active = true
      AND field_id NOT IN ('DEF_AGE', 'DEF_HEIGHT', 'DEF_GENDER', 'DEF_DATE_OF_BIRTH')
    ORDER BY field_id
""")
fields = [row[0] for row in cur.fetchall()]

print(f"Found {len(calculations)} instance_calculations")
print(f"Found {len(fields)} data_entry_fields\n")

# For each, determine the corresponding AGG_* metric
dependencies = []

# Map CALC_* → AGG_*
for calc_id in calculations:
    agg_id = calc_id.replace('CALC_', 'AGG_')
    dependencies.append({
        'agg_metric_id': agg_id,
        'dependency_type': 'instance_calc',
        'instance_calculation_id': calc_id,
        'data_entry_field_id': None
    })

# Map DEF_* → AGG_* (only for fields that make sense to aggregate over time)
# Skip one-time values, static metadata, and pure identifiers
skip_fields = [
    'DEF_AGE', 'DEF_HEIGHT', 'DEF_GENDER', 'DEF_DATE_OF_BIRTH',
    'DEF_USER_ID', 'DEF_PATIENT_ID'
]

for field_id in fields:
    if field_id in skip_fields:
        continue

    # Convert field name to agg name
    # DEF_CARDIO_START → AGG_CARDIO_START is weird
    # Only aggregate fields that represent quantities, not timestamps or identifiers
    if any(x in field_id for x in ['_START', '_END', '_TIME', '_TYPE', '_ID', '_DATE']):
        # These are metadata fields, not quantities to aggregate
        continue

    agg_id = field_id.replace('DEF_', 'AGG_')
    dependencies.append({
        'agg_metric_id': agg_id,
        'dependency_type': 'data_field',
        'instance_calculation_id': None,
        'data_entry_field_id': field_id
    })

print(f"Generated {len(dependencies)} dependencies\n")

# Check which AGG_* metrics exist
cur.execute("SELECT agg_id FROM aggregation_metrics")
existing_agg_metrics = {row[0] for row in cur.fetchall()}

# Separate into existing vs. missing
valid_dependencies = []
missing_agg_metrics = set()

for dep in dependencies:
    agg_id = dep['agg_metric_id']
    if agg_id in existing_agg_metrics:
        valid_dependencies.append(dep)
    else:
        missing_agg_metrics.add(agg_id)

print(f"✓ {len(valid_dependencies)} dependencies have existing AGG_* metrics")
print(f"✗ {len(missing_agg_metrics)} dependencies need AGG_* metrics created\n")

# Show sample of missing
if missing_agg_metrics:
    print("Sample of missing AGG_* metrics (will be created):")
    for agg_id in sorted(missing_agg_metrics)[:20]:
        print(f"  {agg_id}")
    if len(missing_agg_metrics) > 20:
        print(f"  ... and {len(missing_agg_metrics) - 20} more\n")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Create Aggregation Metrics Dependencies
-- =====================================================
-- Links aggregation_metrics to their source calculations/fields
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

""")

if valid_dependencies:
    sql_parts.append("""-- =====================================================
-- PART 1: Create Dependencies for Existing Metrics
-- =====================================================

INSERT INTO aggregation_metrics_dependencies
(agg_metric_id, dependency_type, instance_calculation_id, data_entry_field_id)
VALUES
""")

    for i, dep in enumerate(valid_dependencies):
        agg_id = dep['agg_metric_id']
        dep_type = dep['dependency_type']
        calc_id = dep['instance_calculation_id']
        field_id = dep['data_entry_field_id']

        calc_sql = f"'{calc_id}'" if calc_id else 'NULL'
        field_sql = f"'{field_id}'" if field_id else 'NULL'

        comma = "," if i < len(valid_dependencies) - 1 else ";"
        sql_parts.append(f"('{agg_id}', '{dep_type}', {calc_sql}, {field_sql}){comma}\n")

sql_parts.append("""

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  dep_count INT;
BEGIN
  SELECT COUNT(*) INTO dep_count FROM aggregation_metrics_dependencies;

  RAISE NOTICE '✅ Aggregation Dependencies Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total dependencies: %', dep_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Verify aggregation pipeline can process these';
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_create_aggregation_dependencies.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"✅ SQL generated: {output_file}")
print(f"Total dependencies to create: {len(valid_dependencies)}")

# Save missing list for reference
with open('outputs/missing_agg_metrics.txt', 'w') as f:
    f.write("Missing AGG_* metrics that need to be created:\n\n")
    for agg_id in sorted(missing_agg_metrics):
        f.write(f"{agg_id}\n")

if missing_agg_metrics:
    print(f"\nℹ️  {len(missing_agg_metrics)} AGG_* metrics need to be created first")
    print("    See outputs/missing_agg_metrics.txt")

cur.close()
conn.close()
