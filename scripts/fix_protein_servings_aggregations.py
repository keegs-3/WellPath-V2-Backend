#!/usr/bin/env python3
"""
Fix Missing Protein Servings Aggregations
Generate hourly and daily aggregations for AGG_PROTEIN_SERVINGS
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
USER_ID = '02cc8441-5f01-4634-acfc-59e6f6a5705a'

def generate_hourly_aggregations(conn):
    """Generate hourly protein servings aggregations"""
    print("\n📊 Generating Hourly Aggregations for AGG_PROTEIN_SERVINGS")

    with conn.cursor() as cur:
        # Get all distinct hours from patient data
        cur.execute("""
            SELECT DISTINCT
                DATE_TRUNC('hour', entry_timestamp) as hour_start
            FROM patient_data_entries
            WHERE user_id = %s
              AND field_id = 'DEF_PROTEIN_GRAMS'
              AND source IN ('manual', 'healthkit', 'import', 'api')
              AND entry_timestamp >= CURRENT_DATE - INTERVAL '30 days'
            ORDER BY hour_start
        """, (USER_ID,))

        hours = cur.fetchall()
        print(f"  Found {len(hours)} hours with data")

    for (hour_start,) in hours:
        hour_end = hour_start + timedelta(hours=1)

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Calculate servings for this hour (assuming 25g per serving)
            cur.execute("""
                SELECT
                    SUM(value_quantity) / 25.0 as servings,
                    COUNT(*) as data_points
                FROM patient_data_entries
                WHERE user_id = %s
                  AND field_id = 'DEF_PROTEIN_GRAMS'
                  AND source IN ('manual', 'healthkit', 'import', 'api')
                  AND entry_timestamp >= %s
                  AND entry_timestamp < %s
            """, (USER_ID, hour_start, hour_end))

            result = cur.fetchone()

            if result and result['servings']:
                # Insert hourly SUM aggregation
                cur.execute("""
                    INSERT INTO aggregation_results_cache
                    (user_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
                    VALUES (%s, 'AGG_PROTEIN_SERVINGS', 'hourly', 'SUM', %s, %s, %s, %s, NOW(), false)
                    ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
                    DO UPDATE SET value = EXCLUDED.value, data_points_count = EXCLUDED.data_points_count, last_computed_at = NOW(), is_stale = false
                """, (USER_ID, hour_start, hour_end, result['servings'], result['data_points']))

                conn.commit()
                print(f"  ✅ {hour_start}: {result['servings']:.2f} servings")

def generate_daily_aggregations(conn):
    """Generate daily protein servings aggregations"""
    print("\n📊 Generating Daily Aggregations for AGG_PROTEIN_SERVINGS")

    # Generate for last 30 days
    with conn.cursor() as cur:
        cur.execute("SELECT CURRENT_DATE")
        today = cur.fetchone()[0]

    for days_ago in range(30):
        day_start = today - timedelta(days=days_ago)
        day_end = day_start

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Calculate servings for this day (assuming 25g per serving)
            cur.execute("""
                SELECT
                    SUM(value_quantity) / 25.0 as servings,
                    COUNT(*) as data_points
                FROM patient_data_entries
                WHERE user_id = %s
                  AND field_id = 'DEF_PROTEIN_GRAMS'
                  AND source IN ('manual', 'healthkit', 'import', 'api')
                  AND entry_date = %s
            """, (USER_ID, day_start))

            result = cur.fetchone()

            if result and result['servings']:
                # Insert daily SUM aggregation
                cur.execute("""
                    INSERT INTO aggregation_results_cache
                    (user_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
                    VALUES (%s, 'AGG_PROTEIN_SERVINGS', 'daily', 'SUM', %s, %s, %s, %s, NOW(), false)
                    ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
                    DO UPDATE SET value = EXCLUDED.value, data_points_count = EXCLUDED.data_points_count, last_computed_at = NOW(), is_stale = false
                """, (USER_ID, day_start, day_end, result['servings'], result['data_points']))

                conn.commit()
                print(f"  ✅ {day_start}: {result['servings']:.2f} servings")

def add_hourly_period_config(conn):
    """Add hourly period to aggregation_metrics_periods"""
    print("\n⚙️  Adding hourly period configuration")

    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
            VALUES ('AGG_PROTEIN_SERVINGS', 'hourly')
            ON CONFLICT (agg_metric_id, period_id) DO NOTHING
        """)
        conn.commit()
        print("  ✅ Hourly period configured")

def main():
    print("🔧 Fixing AGG_PROTEIN_SERVINGS Aggregations")
    print(f"User ID: {USER_ID}")

    conn = psycopg2.connect(DB_URL)

    try:
        # Step 1: Add hourly configuration
        add_hourly_period_config(conn)

        # Step 2: Generate hourly data
        generate_hourly_aggregations(conn)

        # Step 3: Generate daily data
        generate_daily_aggregations(conn)

        print("\n✅ Done!")

        # Verify
        with conn.cursor() as cur:
            cur.execute("""
                SELECT period_type, calculation_type_id, COUNT(*) as count
                FROM aggregation_results_cache
                WHERE user_id = %s
                  AND agg_metric_id = 'AGG_PROTEIN_SERVINGS'
                GROUP BY period_type, calculation_type_id
                ORDER BY period_type
            """, (USER_ID,))

            print("\n📋 Summary:")
            for row in cur.fetchall():
                print(f"  {row[0]}/{row[1]}: {row[2]} records")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
