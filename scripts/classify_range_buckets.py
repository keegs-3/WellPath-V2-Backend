#!/usr/bin/env python3
"""
Classify biomarker and biometric ranges into buckets:
- Optimal
- In-Range
- Out-of-Range
"""

import psycopg2

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

def classify_range(range_name):
    """
    Classify a range name into one of three buckets:
    - Optimal
    - In-Range
    - Out-of-Range
    """
    name_lower = range_name.lower()

    # OPTIMAL - has "optimal" in the name
    if 'optimal' in name_lower and 'suboptimal' not in name_lower and 'near-optimal' not in name_lower:
        return 'Optimal'

    # IN-RANGE - has "in-range" or "normal" explicitly in the name
    # User note: there can be multiple in-range values (in-range low, in-range high)
    if any(keyword in name_lower for keyword in [
        'in-range',
        'normal',  # includes "high normal", "high-normal"
        'good'
    ]):
        return 'In-Range'

    # Near-optimal is close but still in acceptable range
    if 'near-optimal' in name_lower:
        return 'In-Range'

    # Everything else is OUT-OF-RANGE
    return 'Out-of-Range'


# Process biomarkers_detail
print("=" * 80)
print("BIOMARKERS_DETAIL Classification")
print("=" * 80)

cur.execute("SELECT DISTINCT range_name FROM biomarkers_detail ORDER BY range_name")
biomarker_ranges = cur.fetchall()

classification = {
    'Optimal': [],
    'In-Range': [],
    'Out-of-Range': []
}

for (range_name,) in biomarker_ranges:
    bucket = classify_range(range_name)
    classification[bucket].append(range_name)

print(f"\n📊 Total biomarker ranges: {len(biomarker_ranges)}\n")

for bucket, ranges in classification.items():
    print(f"\n{bucket}: {len(ranges)} ranges")
    print("-" * 80)
    for range_name in ranges:
        print(f"  {range_name}")

# Process biometrics_detail
print("\n" + "=" * 80)
print("BIOMETRICS_DETAIL Classification")
print("=" * 80)

cur.execute("SELECT DISTINCT range_name FROM biometrics_detail ORDER BY range_name")
biometric_ranges = cur.fetchall()

classification_bio = {
    'Optimal': [],
    'In-Range': [],
    'Out-of-Range': []
}

for (range_name,) in biometric_ranges:
    bucket = classify_range(range_name)
    classification_bio[bucket].append(range_name)

print(f"\n📊 Total biometric ranges: {len(biometric_ranges)}\n")

for bucket, ranges in classification_bio.items():
    print(f"\n{bucket}: {len(ranges)} ranges")
    print("-" * 80)
    for range_name in ranges:
        print(f"  {range_name}")


# Generate SQL migration
sql_parts = []

sql_parts.append("""-- =====================================================
-- Add range_bucket Column to Biomarker/Biometric Tables
-- =====================================================
-- Classify ranges into: Optimal, In-Range, Out-of-Range
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Columns
-- =====================================================

-- Add range_bucket to biomarkers_detail
ALTER TABLE biomarkers_detail
ADD COLUMN IF NOT EXISTS range_bucket TEXT;

-- Add range_bucket to biometrics_detail
ALTER TABLE biometrics_detail
ADD COLUMN IF NOT EXISTS range_bucket TEXT;

-- =====================================================
-- PART 2: Update Biomarkers
-- =====================================================

""")

# Generate biomarker updates
print("\n" + "=" * 80)
print("Generating SQL for biomarkers_detail...")

for bucket, ranges in classification.items():
    if ranges:
        sql_parts.append(f"-- {bucket} ({len(ranges)} ranges)\n")
        for range_name in ranges:
            # Escape single quotes
            escaped_name = range_name.replace("'", "''")
            sql_parts.append(f"UPDATE biomarkers_detail SET range_bucket = '{bucket}' WHERE range_name = '{escaped_name}';\n")
        sql_parts.append("\n")

sql_parts.append("""
-- =====================================================
-- PART 3: Update Biometrics
-- =====================================================

""")

# Generate biometric updates
print("Generating SQL for biometrics_detail...")

for bucket, ranges in classification_bio.items():
    if ranges:
        sql_parts.append(f"-- {bucket} ({len(ranges)} ranges)\n")
        for range_name in ranges:
            escaped_name = range_name.replace("'", "''")
            sql_parts.append(f"UPDATE biometrics_detail SET range_bucket = '{bucket}' WHERE range_name = '{escaped_name}';\n")
        sql_parts.append("\n")

sql_parts.append("""
-- =====================================================
-- PART 4: Verify Results
-- =====================================================

DO $$
DECLARE
  biomarker_optimal INT;
  biomarker_inrange INT;
  biomarker_outofrange INT;
  biometric_optimal INT;
  biometric_inrange INT;
  biometric_outofrange INT;
BEGIN
  -- Count biomarkers by bucket
  SELECT COUNT(DISTINCT range_name) INTO biomarker_optimal
  FROM biomarkers_detail WHERE range_bucket = 'Optimal';

  SELECT COUNT(DISTINCT range_name) INTO biomarker_inrange
  FROM biomarkers_detail WHERE range_bucket = 'In-Range';

  SELECT COUNT(DISTINCT range_name) INTO biomarker_outofrange
  FROM biomarkers_detail WHERE range_bucket = 'Out-of-Range';

  -- Count biometrics by bucket
  SELECT COUNT(DISTINCT range_name) INTO biometric_optimal
  FROM biometrics_detail WHERE range_bucket = 'Optimal';

  SELECT COUNT(DISTINCT range_name) INTO biometric_inrange
  FROM biometrics_detail WHERE range_bucket = 'In-Range';

  SELECT COUNT(DISTINCT range_name) INTO biometric_outofrange
  FROM biometrics_detail WHERE range_bucket = 'Out-of-Range';

  RAISE NOTICE '✅ Range Buckets Added';
  RAISE NOTICE '';
  RAISE NOTICE 'Biomarkers:';
  RAISE NOTICE '  Optimal: %', biomarker_optimal;
  RAISE NOTICE '  In-Range: %', biomarker_inrange;
  RAISE NOTICE '  Out-of-Range: %', biomarker_outofrange;
  RAISE NOTICE '';
  RAISE NOTICE 'Biometrics:';
  RAISE NOTICE '  Optimal: %', biometric_optimal;
  RAISE NOTICE '  In-Range: %', biometric_inrange;
  RAISE NOTICE '  Out-of-Range: %', biometric_outofrange;
END $$;

COMMIT;
""")

# Write migration file
output_file = 'supabase/migrations/20251022_add_range_bucket_classification.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"\n✅ Migration generated: {output_file}")

# Summary
total_biomarker = sum(len(ranges) for ranges in classification.values())
total_biometric = sum(len(ranges) for ranges in classification_bio.values())

print(f"\n📊 Summary:")
print(f"  Biomarkers: {total_biomarker} ranges classified")
print(f"  Biometrics: {total_biometric} ranges classified")
print(f"\n  Optimal: {len(classification['Optimal']) + len(classification_bio['Optimal'])}")
print(f"  In-Range: {len(classification['In-Range']) + len(classification_bio['In-Range'])}")
print(f"  Out-of-Range: {len(classification['Out-of-Range']) + len(classification_bio['Out-of-Range'])}")

cur.close()
conn.close()
