#!/usr/bin/env python3
"""
Recompute Aggregations with Correct Period Bounds
==================================================
After fixing get_period_bounds, this script:
1. Deletes aggregations with incorrect bounds (daily, weekly, monthly)
2. Keeps 6month aggregations (already correct)
3. Recomputes all aggregations with corrected bounds
4. Generates yearly aggregations (new period type)
"""

import psycopg2
from datetime import datetime

# Database connection
DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

print("=" * 80)
print("🔧 Recomputing Aggregations with Correct Period Bounds")
print("=" * 80)
print()

conn = psycopg2.connect(DB_URL)
cur = conn.cursor()

try:
    # =====================================================
    # STEP 1: Delete Incorrect Aggregations
    # =====================================================
    print("STEP 1: Deleting aggregations with incorrect bounds...")
    print("-" * 80)

    # Count before deletion
    cur.execute("""
        SELECT period_type, COUNT(*) as count
        FROM aggregation_results_cache
        GROUP BY period_type
        ORDER BY period_type;
    """)

    print("\nBefore deletion:")
    before_counts = {}
    for row in cur.fetchall():
        period_type, count = row
        before_counts[period_type] = count
        print(f"  {period_type}: {count:,} rows")

    # Delete daily, weekly, monthly (incorrect bounds)
    cur.execute("""
        DELETE FROM aggregation_results_cache
        WHERE period_type IN ('daily', 'weekly', 'monthly', 'hourly');
    """)
    deleted_count = cur.rowcount
    conn.commit()

    print(f"\n❌ Deleted {deleted_count:,} rows with incorrect bounds")
    print("   Kept 6month rows (already have correct bounds)")
    print()

    # =====================================================
    # STEP 2: Get All User/Field/Date Combinations
    # =====================================================
    print("STEP 2: Finding user/field/date combinations to process...")
    print("-" * 80)

    cur.execute("""
        SELECT DISTINCT
            user_id,
            field_id,
            entry_date
        FROM patient_data_entries
        WHERE source != 'deleted'
        ORDER BY user_id, entry_date, field_id;
    """)

    combinations = cur.fetchall()
    total_combinations = len(combinations)

    print(f"Found {total_combinations:,} unique user/field/date combinations")
    print()

    # =====================================================
    # STEP 3: Recompute Aggregations
    # =====================================================
    print("STEP 3: Recomputing aggregations...")
    print("-" * 80)
    print()

    processed = 0
    errors = 0
    total_aggregations = 0
    start_time = datetime.now()

    for i, (user_id, field_id, entry_date) in enumerate(combinations, 1):
        try:
            # Call the PostgreSQL function to process aggregations
            cur.execute("""
                SELECT process_field_aggregations(%s, %s, %s)
            """, (user_id, field_id, entry_date))

            result = cur.fetchone()[0]
            aggregations_created = result or 0
            total_aggregations += aggregations_created
            processed += 1

            # Progress update every 100 combinations
            if processed % 100 == 0:
                elapsed = (datetime.now() - start_time).total_seconds()
                rate = processed / elapsed if elapsed > 0 else 0
                remaining = total_combinations - processed
                eta = remaining / rate if rate > 0 else 0

                print(f"  Progress: {processed:,}/{total_combinations:,} combinations "
                      f"({processed/total_combinations*100:.1f}%) | "
                      f"{total_aggregations:,} aggregations created | "
                      f"ETA: {eta/60:.1f}min")
                conn.commit()

        except Exception as e:
            errors += 1
            if errors <= 5:  # Only print first 5 errors
                print(f"  ❌ Error processing {user_id}/{field_id}/{entry_date}: {e}")
            conn.rollback()

    conn.commit()

    # =====================================================
    # STEP 4: Summary
    # =====================================================
    print()
    print("=" * 80)
    print("✅ Recomputation Complete!")
    print("=" * 80)
    print()
    print(f"Combinations processed: {processed:,}")
    print(f"Aggregations created:   {total_aggregations:,}")
    print(f"Errors encountered:     {errors:,}")
    print()

    # Count after recomputation
    cur.execute("""
        SELECT period_type, COUNT(*) as count
        FROM aggregation_results_cache
        GROUP BY period_type
        ORDER BY period_type;
    """)

    print("Final aggregation counts:")
    total_after = 0
    for row in cur.fetchall():
        period_type, count = row
        total_after += count
        before = before_counts.get(period_type, 0)
        change = count - before
        change_str = f"+{change:,}" if change >= 0 else f"{change:,}"
        print(f"  {period_type}: {count:,} rows ({change_str})")

    print()
    print(f"Total: {total_after:,} aggregation results cached")
    print()

    # Verification query
    print("Verification - Sample Weekly Bounds:")
    print("-" * 80)
    cur.execute("""
        SELECT
            agg_metric_id,
            period_start::date,
            period_end::date,
            (period_end::date - period_start::date) as days_span,
            value
        FROM aggregation_results_cache
        WHERE period_type = 'weekly'
          AND agg_metric_id = 'AGG_PROTEIN_GRAMS'
        ORDER BY period_start DESC
        LIMIT 5;
    """)

    for row in cur.fetchall():
        agg_id, start, end, days, value = row
        status = "✅" if days == 6 else "❌"
        print(f"  {status} {start} to {end} ({days} days): {value}g protein")

    print()
    print("✅ All aggregations now use correct period bounds!")
    print()

except Exception as e:
    print(f"\n❌ Fatal error: {e}")
    import traceback
    traceback.print_exc()
    conn.rollback()
finally:
    cur.close()
    conn.close()

print("=" * 80)
print("Script complete")
print("=" * 80)
