#!/usr/bin/env python3
"""
Process Protein Aggregations for Test User
Manually triggers aggregation calculations for protein data
"""

import psycopg2
from psycopg2.extras import RealDictCursor

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
PATIENT_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'

def main():
    print("🔄 Processing Protein Aggregations")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor(cursor_factory=RealDictCursor)

    # Get all unique dates with protein data
    cur.execute("""
        SELECT DISTINCT entry_date
        FROM patient_data_entries
        WHERE patient_id = %s
          AND field_id = 'DEF_PROTEIN_GRAMS'
        ORDER BY entry_date
    """, (PATIENT_ID,))

    dates = [row['entry_date'] for row in cur.fetchall()]
    print(f"📅 Found {len(dates)} days with protein data")
    print(f"   Range: {dates[0]} to {dates[-1]}")

    # Process aggregations for each date
    total_aggregations = 0

    for date in dates:
        try:
            cur.execute("""
                SELECT process_field_aggregations(%s, %s, %s)
            """, (PATIENT_ID, 'DEF_PROTEIN_GRAMS', date))

            result = cur.fetchone()
            count = result['process_field_aggregations'] if result else 0

            if count > 0:
                total_aggregations += count
                print(f"   {date}: {count} aggregations")
            else:
                print(f"   {date}: No aggregations (no dependencies configured?)")

            conn.commit()

        except Exception as e:
            print(f"   ❌ {date}: Error - {e}")
            conn.rollback()

    print(f"\n✅ Processed {total_aggregations} total aggregations")

    # Verify cache was populated
    print("\n📊 Verifying aggregation cache...")
    cur.execute("""
        SELECT
            agg_metric_id,
            period_type,
            COUNT(*) as periods,
            MIN(period_start) as earliest,
            MAX(period_start) as latest
        FROM aggregation_results_cache
        WHERE patient_id = %s
          AND agg_metric_id LIKE 'AGG_PROTEIN%'
        GROUP BY agg_metric_id, period_type
        ORDER BY agg_metric_id, period_type
    """, (PATIENT_ID,))

    cache_results = cur.fetchall()

    if cache_results:
        print(f"   ✅ Found {len(cache_results)} aggregation/period combinations")
        for row in cache_results[:10]:  # Show first 10
            print(f"      {row['agg_metric_id']} ({row['period_type']}): {row['periods']} periods")
        if len(cache_results) > 10:
            print(f"      ... and {len(cache_results) - 10} more")
    else:
        print("   ❌ No aggregations found in cache!")
        print("   This likely means aggregation_metrics_dependencies is not configured")

    # Sample data for mobile testing
    print("\n📱 Sample Data for Mobile Testing:")
    cur.execute("""
        SELECT
            period_start,
            calculated_value
        FROM aggregation_results_cache
        WHERE patient_id = %s
          AND agg_metric_id = 'AGG_PROTEIN_GRAMS'
          AND period_type = 'daily'
          AND calculation_type = 'SUM'
        ORDER BY period_start DESC
        LIMIT 7
    """, (PATIENT_ID,))

    daily_totals = cur.fetchall()
    if daily_totals:
        print("   Last 7 days (AGG_PROTEIN_GRAMS, daily, SUM):")
        for row in daily_totals:
            print(f"      {row['period_start'].date()}: {row['calculated_value']}g")
    else:
        print("   ⚠️  No daily protein totals found")

    conn.close()
    print(f"\n{'='*60}")
    print("✅ Aggregation processing complete!")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
