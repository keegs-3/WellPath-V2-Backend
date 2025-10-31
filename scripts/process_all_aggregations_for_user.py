#!/usr/bin/env python3
"""
Process All Aggregations for a User
Manually processes all aggregations for test user data
"""

import psycopg2
from datetime import datetime, timedelta

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
USER_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'  # test.patient.21@wellpath.com

def main():
    print(f"🚀 Processing All Aggregations for User: {USER_ID}")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        with conn.cursor() as cur:
            # Get all unique dates with data
            cur.execute("""
                SELECT DISTINCT entry_date
                FROM patient_data_entries
                WHERE patient_id = %s
                ORDER BY entry_date;
            """, (USER_ID,))

            dates = [row[0] for row in cur.fetchall()]
            print(f"📅 Found {len(dates)} days of data")
            print(f"   Range: {dates[0]} to {dates[-1]}")

            # Get all unique fields
            cur.execute("""
                SELECT DISTINCT field_id
                FROM patient_data_entries
                WHERE patient_id = %s;
            """, (USER_ID,))

            fields = [row[0] for row in cur.fetchall()]
            print(f"📊 Found {len(fields)} unique fields\n")

            # Process aggregations for each field/date combination
            total_processed = 0
            for field_id in fields:
                print(f"Processing {field_id}...")
                field_aggs = 0

                for entry_date in dates:
                    # Call the PostgreSQL function
                    cur.execute("""
                        SELECT process_field_aggregations(%s, %s, %s);
                    """, (USER_ID, field_id, entry_date))

                    result = cur.fetchone()[0]
                    if result and result > 0:
                        field_aggs += result

                if field_aggs > 0:
                    print(f"  ✅ {field_aggs} aggregations")
                    total_processed += field_aggs
                else:
                    print(f"  ⏭️  No aggregations configured")

            conn.commit()

            print("\n" + "=" * 60)
            print(f"✅ COMPLETE! Processed {total_processed} aggregations")
            print("=" * 60)

            # Summary
            cur.execute("""
                SELECT
                    agg_metric_id,
                    period_type,
                    COUNT(*) as periods
                FROM aggregation_results_cache
                WHERE patient_id = %s
                GROUP BY agg_metric_id, period_type
                ORDER BY agg_metric_id, period_type;
            """, (USER_ID,))

            print("\n📊 Aggregations Created:")
            for row in cur.fetchall():
                print(f"  {row[0]} ({row[1]}): {row[2]} periods")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
