#!/usr/bin/env python3
"""
Rename all DISP_DM_* metrics to semantic DISP_* names
"""

import psycopg2
import re

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Get all DISP_DM_* metrics
cur.execute("""
    SELECT display_metric_id, display_name
    FROM display_metrics
    WHERE display_metric_id LIKE 'DISP_DM_%'
    ORDER BY display_metric_id
""")
old_metrics = cur.fetchall()

print(f"Found {len(old_metrics)} metrics with DISP_DM_ format\n")

# Generate new semantic names
renames = []
seen_new_ids = set()

for old_id, display_name in old_metrics:
    # Convert display name to semantic ID
    # "Brain Training Duration" → "BRAIN_TRAINING_DURATION"
    # "Vegetable Servings: Breakfast" → "VEGETABLE_SERVINGS_BREAKFAST"

    clean_name = display_name.upper()
    # Remove special characters
    clean_name = re.sub(r'[^\w\s]', '', clean_name)  # Remove punctuation
    clean_name = re.sub(r'\s+', '_', clean_name)      # Spaces to underscores
    clean_name = re.sub(r'_+', '_', clean_name)       # Multiple underscores to single
    clean_name = clean_name.strip('_')                # Remove leading/trailing

    new_id = f'DISP_{clean_name}'

    # Handle duplicates (shouldn't happen but just in case)
    if new_id in seen_new_ids:
        # Append old number
        old_num = old_id.split('_')[-1]
        new_id = f'{new_id}_{old_num}'

    seen_new_ids.add(new_id)

    renames.append({
        'old_id': old_id,
        'new_id': new_id,
        'display_name': display_name
    })

print(f"Generated {len(renames)} renames\n")
print("Sample renames:")
for rename in renames[:10]:
    print(f"  {rename['old_id']:30} → {rename['new_id']:50} ({rename['display_name']})")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Rename Display Metrics to Semantic Names
-- =====================================================
-- Convert DISP_DM_* to semantic DISP_* names
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Update display_metrics
-- =====================================================

""")

for rename in renames:
    old_id = rename['old_id']
    new_id = rename['new_id']
    sql_parts.append(f"UPDATE display_metrics SET display_metric_id = '{new_id}' WHERE display_metric_id = '{old_id}';\n")

sql_parts.append("""

-- =====================================================
-- PART 2: Update display_metrics_aggregations
-- =====================================================

""")

for rename in renames:
    old_id = rename['old_id']
    new_id = rename['new_id']
    sql_parts.append(f"UPDATE display_metrics_aggregations SET display_metric_id = '{new_id}' WHERE display_metric_id = '{old_id}';\n")

sql_parts.append("""

-- =====================================================
-- PART 3: Update display_screens_display_metrics (if exists)
-- =====================================================

""")

for rename in renames:
    old_id = rename['old_id']
    new_id = rename['new_id']
    sql_parts.append(f"UPDATE display_screens_display_metrics SET display_metric = '{new_id}' WHERE display_metric = '{old_id}';\n")

sql_parts.append("""

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  semantic_count INT;
  numbered_count INT;
BEGIN
  SELECT COUNT(*) INTO semantic_count
  FROM display_metrics
  WHERE display_metric_id LIKE 'DISP_%' AND display_metric_id NOT LIKE 'DISP_DM_%';

  SELECT COUNT(*) INTO numbered_count
  FROM display_metrics
  WHERE display_metric_id LIKE 'DISP_DM_%';

  RAISE NOTICE '✅ Display Metrics Renamed to Semantic Format';
  RAISE NOTICE '';
  RAISE NOTICE 'Semantic DISP_* names: %', semantic_count;
  RAISE NOTICE 'Old DISP_DM_* format remaining: %', numbered_count;
  RAISE NOTICE '';
  RAISE NOTICE 'All metrics now use semantic naming!';
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_rename_display_metrics_semantic.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"\n✅ SQL generated: {output_file}")
print(f"Total renames: {len(renames)}")

# Save mapping for reference
with open('outputs/display_metrics_rename_mapping.txt', 'w') as f:
    f.write("Display Metrics Rename Mapping\n")
    f.write("=" * 120 + "\n\n")
    for rename in renames:
        f.write(f"{rename['old_id']:30} → {rename['new_id']:50} | {rename['display_name']}\n")

print("Mapping saved to: outputs/display_metrics_rename_mapping.txt")

cur.close()
conn.close()
