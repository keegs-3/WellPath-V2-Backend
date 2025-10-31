#!/usr/bin/env python3
"""
Fix Sleep Aggregation Metric Name
===================================
Updates display_metrics to use correct AGG_SLEEP_DURATION instead of AGG_TOTAL_SLEEP_DURATION
"""

import os
import psycopg2

# Database connection
DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

def main():
    print("🔍 Checking Sleep Metric Duplicates\n")

    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()

    try:
        # Check ALL sleep aggregation metrics
        print("📊 All sleep-related aggregation metrics:")
        cur.execute("""
            SELECT
                agg_id,
                metric_name,
                output_unit
            FROM aggregation_metrics
            WHERE agg_id ILIKE '%sleep%'
               OR metric_name ILIKE '%sleep%'
            ORDER BY agg_id;
        """)

        agg_results = cur.fetchall()
        print(f"\nFound {len(agg_results)} sleep aggregation metrics:")
        for agg_id, metric_name, unit in agg_results:
            print(f"  {agg_id}: {metric_name} ({unit})")

        # Check display metrics configuration
        print("\n📱 Display metrics pointing to sleep aggregations:")
        cur.execute("""
            SELECT
                metric_id,
                agg_metric_id
            FROM display_metrics
            WHERE agg_metric_id ILIKE '%sleep%'
            ORDER BY metric_id;
        """)

        display_results = cur.fetchall()
        print(f"\nFound {len(display_results)} display metrics:")
        for metric_id, agg_metric_id in display_results:
            # Check if the aggregation exists
            exists = any(agg[0] == agg_metric_id for agg in agg_results)
            status = "✅" if exists else "❌ MISSING"
            print(f"  {status} {metric_id} → {agg_metric_id}")

        # Check aggregation cache
        print("\n💾 Data in aggregation cache:")
        cur.execute("""
            SELECT
                agg_metric_id,
                COUNT(*) as count,
                COUNT(DISTINCT patient_id) as patients
            FROM aggregation_results_cache
            WHERE agg_metric_id ILIKE '%sleep%'
            GROUP BY agg_metric_id
            ORDER BY agg_metric_id;
        """)

        cache_results = cur.fetchall()
        if cache_results:
            print(f"\nFound {len(cache_results)} cached sleep metrics:")
            for agg_id, count, patients in cache_results:
                print(f"  {agg_id}: {count} entries for {patients} patients")
        else:
            print("  ❌ No sleep data in cache")

    finally:
        cur.close()
        conn.close()

    print("\n🏁 Analysis complete!")

if __name__ == "__main__":
    main()
