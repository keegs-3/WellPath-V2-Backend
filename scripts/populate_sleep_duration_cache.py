#!/usr/bin/env python3
"""
Populate AGG_SLEEP_DURATION Cache
==================================
Manually aggregates DEF_SLEEP_PERIOD_DURATION to populate the cache.
"""

import os
import psycopg2
from datetime import date, timedelta

# Database connection
DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

USER_ID = '8B79CE33-02B8-4F49-8268-3204130EFA82'

def main():
    print("📊 Populating AGG_SLEEP_DURATION cache\n")

    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()

    try:
        # Get date range
        cur.execute("""
            SELECT
                MIN(entry_date) as start_date,
                MAX(entry_date) as end_date
            FROM patient_data_entries
            WHERE field_id = 'DEF_SLEEP_PERIOD_DURATION'
              AND patient_id = %s
        """, (USER_ID,))

        start_date, end_date = cur.fetchone()
        print(f"📅 Date range: {start_date} to {end_date}\n")

        # Aggregate by day
        cur.execute("""
            INSERT INTO aggregation_results_cache (
                patient_id,
                agg_metric_id,
                period_type,
                calculation_type_id,
                period_start,
                period_end,
                value,
                created_at
            )
            SELECT
                patient_id,
                'AGG_SLEEP_DURATION' as agg_metric_id,
                'daily' as period_type,
                'SUM' as calculation_type_id,
                entry_date as period_start,
                entry_date + INTERVAL '1 day' as period_end,
                SUM(value_quantity) as value,
                NOW() as created_at
            FROM patient_data_entries
            WHERE field_id = 'DEF_SLEEP_PERIOD_DURATION'
              AND patient_id = %s
            GROUP BY patient_id, entry_date
            ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
            DO UPDATE SET
                value = EXCLUDED.value,
                created_at = NOW()
        """, (USER_ID,))

        daily_count = cur.rowcount
        print(f"✅ Created {daily_count} daily aggregations")

        # Aggregate by week
        cur.execute("""
            INSERT INTO aggregation_results_cache (
                patient_id,
                agg_metric_id,
                period_type,
                calculation_type_id,
                period_start,
                period_end,
                value,
                created_at
            )
            SELECT
                patient_id,
                'AGG_SLEEP_DURATION' as agg_metric_id,
                'weekly' as period_type,
                'SUM' as calculation_type_id,
                DATE_TRUNC('week', entry_date) as period_start,
                DATE_TRUNC('week', entry_date) + INTERVAL '1 week' as period_end,
                SUM(value_quantity) as value,
                NOW() as created_at
            FROM patient_data_entries
            WHERE field_id = 'DEF_SLEEP_PERIOD_DURATION'
              AND patient_id = %s
            GROUP BY patient_id, DATE_TRUNC('week', entry_date)
            ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
            DO UPDATE SET
                value = EXCLUDED.value,
                created_at = NOW()
        """, (USER_ID,))

        weekly_count = cur.rowcount
        print(f"✅ Created {weekly_count} weekly aggregations")

        # Aggregate by month
        cur.execute("""
            INSERT INTO aggregation_results_cache (
                patient_id,
                agg_metric_id,
                period_type,
                calculation_type_id,
                period_start,
                period_end,
                value,
                created_at
            )
            SELECT
                patient_id,
                'AGG_SLEEP_DURATION' as agg_metric_id,
                'monthly' as period_type,
                'SUM' as calculation_type_id,
                DATE_TRUNC('month', entry_date) as period_start,
                DATE_TRUNC('month', entry_date) + INTERVAL '1 month' as period_end,
                SUM(value_quantity) as value,
                NOW() as created_at
            FROM patient_data_entries
            WHERE field_id = 'DEF_SLEEP_PERIOD_DURATION'
              AND patient_id = %s
            GROUP BY patient_id, DATE_TRUNC('month', entry_date)
            ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
            DO UPDATE SET
                value = EXCLUDED.value,
                created_at = NOW()
        """, (USER_ID,))

        monthly_count = cur.rowcount
        print(f"✅ Created {monthly_count} monthly aggregations")

        conn.commit()

        # Verify
        print("\n📊 Verification:")
        cur.execute("""
            SELECT
                period_type,
                period_start::date,
                value
            FROM aggregation_results_cache
            WHERE agg_metric_id = 'AGG_SLEEP_DURATION'
              AND patient_id = %s
            ORDER BY period_start
            LIMIT 10
        """, (USER_ID,))

        results = cur.fetchall()
        for period_type, period_start, value in results:
            print(f"  {period_type:8s} {period_start}: {value} minutes")

    finally:
        cur.close()
        conn.close()

    print("\n🎉 Cache populated!")

if __name__ == "__main__":
    main()
