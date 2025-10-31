#!/usr/bin/env python3
"""
Recompute Daily+ Aggregations After Timezone Fix

This script:
1. Deletes all non-hourly aggregations (daily, weekly, monthly, yearly, 6month)
2. Regenerates them using the corrected timezone-aware logic
3. Keeps hourly aggregations (they were already correct)

Run this AFTER applying migration: 20251029_fix_timezone_aware_aggregations.sql
"""

import psycopg2
import os
from datetime import datetime, timedelta

# Read DATABASE_URL from .env file
def read_database_url():
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    with open(env_path) as f:
        for line in f:
            if line.startswith('DATABASE_URL='):
                return line.split('=', 1)[1].strip()
    raise ValueError("DATABASE_URL not found in .env file")

DATABASE_URL = read_database_url()

def main():
    print("="*80)
    print("RECOMPUTE DAILY+ AGGREGATIONS AFTER TIMEZONE FIX")
    print("="*80)

    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Step 1: Count affected aggregations
    print("\n📊 Checking current aggregation cache...")

    cur.execute("""
        SELECT
            period_type,
            COUNT(*) as count
        FROM aggregation_results_cache
        GROUP BY period_type
        ORDER BY period_type
    """)

    stats = cur.fetchall()
    print("\nCurrent cache:")
    for period_type, count in stats:
        print(f"  {period_type}: {count:,} entries")

    # Step 2: Delete non-hourly aggregations
    print("\n🗑️  Deleting non-hourly aggregations (these will be regenerated)...")

    cur.execute("""
        DELETE FROM aggregation_results_cache
        WHERE period_type IN ('daily', 'weekly', 'monthly', 'yearly', '6month')
    """)

    deleted_count = cur.rowcount
    print(f"   ✓ Deleted {deleted_count:,} non-hourly aggregation entries")

    conn.commit()

    # Step 3: Get all unique patient_id + entry_date combinations
    print("\n📅 Finding all patient data entry dates to reprocess...")

    cur.execute("""
        SELECT DISTINCT
            patient_id,
            entry_date
        FROM patient_data_entries
        WHERE source != 'deleted'
        ORDER BY patient_id, entry_date
    """)

    dates_to_process = cur.fetchall()
    print(f"   ✓ Found {len(dates_to_process):,} unique (patient_id, date) combinations")

    # Step 4: Get all active aggregation metrics
    cur.execute("""
        SELECT DISTINCT agg_id
        FROM aggregation_metrics
        WHERE is_active = true
        ORDER BY agg_id
    """)

    agg_metrics = [row[0] for row in cur.fetchall()]
    print(f"   ✓ Found {len(agg_metrics)} active aggregation metrics")

    # Step 5: Recompute all daily+ aggregations
    print("\n🔄 Recomputing daily+ aggregations with timezone-aware logic...")
    print(f"   Processing {len(dates_to_process):,} dates × {len(agg_metrics)} metrics...")

    total_computed = 0
    errors = 0
    batch_size = 100

    for idx, (patient_id, entry_date) in enumerate(dates_to_process):
        if idx % batch_size == 0:
            progress = (idx / len(dates_to_process)) * 100
            print(f"   Progress: {idx:,}/{len(dates_to_process):,} ({progress:.1f}%) - Total computed: {total_computed:,}")

        for agg_metric_id in agg_metrics:
            try:
                # Call process_single_aggregation for this patient/date/metric
                cur.execute("""
                    SELECT process_single_aggregation(%s, %s, %s)
                """, (patient_id, agg_metric_id, entry_date))

                result = cur.fetchone()
                if result:
                    total_computed += result[0]

                # Commit in batches
                if total_computed % 1000 == 0:
                    conn.commit()

            except Exception as e:
                errors += 1
                if errors <= 10:  # Only show first 10 errors
                    print(f"   ⚠️  Error processing {patient_id}, {entry_date}, {agg_metric_id}: {e}")

    # Final commit
    conn.commit()

    print(f"\n   ✓ Completed! Total aggregations computed: {total_computed:,}")
    if errors > 0:
        print(f"   ⚠️  Encountered {errors} errors (check logs)")

    # Step 6: Verify new cache
    print("\n📊 Verifying recomputed cache...")

    cur.execute("""
        SELECT
            period_type,
            COUNT(*) as count
        FROM aggregation_results_cache
        GROUP BY period_type
        ORDER BY period_type
    """)

    new_stats = cur.fetchall()
    print("\nNew cache:")
    for period_type, count in new_stats:
        print(f"  {period_type}: {count:,} entries")

    # Step 7: Sample verification query
    print("\n✅ Sample verification - Protein Grams for test patient on Oct 29:")

    cur.execute("""
        SELECT
            period_type,
            period_start,
            value
        FROM aggregation_results_cache
        WHERE agg_metric_id = 'AGG_PROTEIN_GRAMS'
          AND calculation_type_id = 'SUM'
          AND period_start::date = '2025-10-29'
        ORDER BY period_type
        LIMIT 5
    """)

    samples = cur.fetchall()
    if samples:
        for period_type, period_start, value in samples:
            print(f"  {period_type}: {period_start} = {value}g")
    else:
        print("  (No data for Oct 29 - this is normal if you don't have test data)")

    cur.close()
    conn.close()

    print("\n" + "="*80)
    print("RECOMPUTATION COMPLETE")
    print("="*80)
    print("\n✅ Daily+ aggregations now use entry_date (timezone-aware)")
    print("✅ Hourly aggregations still use entry_timestamp (correct)")
    print("\nNext steps:")
    print("1. Verify the daily aggregations match expected values")
    print("2. Test in mobile app to confirm dates display correctly")
    print("3. Monitor for any issues with the new logic")

if __name__ == '__main__':
    main()
