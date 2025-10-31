#!/usr/bin/env python3
"""
Bulk process all protein and weight aggregations for historical data.
"""

import psycopg2
from datetime import datetime, timedelta

# Database connection
DB_HOST = "aws-1-us-west-1.pooler.supabase.com"
DB_PORT = "5432"
DB_NAME = "postgres"
DB_USER = "postgres.csotzmardnvrpdhlogjm"
DB_PASSWORD = "pd3Wc7ELL20OZYkE"

# Patient ID
PATIENT_ID = "8b79ce33-02b8-4f49-8268-3204130efa82"

def bulk_process_aggregations():
    """Process all aggregations for all dates with data."""
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    cur = conn.cursor()

    try:
        print("📅 Finding dates with protein/weight data...")

        # Get all unique dates with protein or weight data
        cur.execute("""
            SELECT DISTINCT entry_date
            FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id IN ('DEF_PROTEIN_GRAMS', 'DEF_WEIGHT')
            ORDER BY entry_date;
        """, (PATIENT_ID,))

        dates = [row[0] for row in cur.fetchall()]
        print(f"   Found {len(dates)} dates to process")
        print(f"   Range: {dates[0]} to {dates[-1]}")

        # Get all protein and weight aggregation metrics
        cur.execute("""
            SELECT DISTINCT agg_id
            FROM aggregation_metrics
            WHERE agg_id LIKE 'AGG_PROTEIN%' OR agg_id LIKE 'AGG_WEIGHT%'
            ORDER BY agg_id;
        """)

        agg_metrics = [row[0] for row in cur.fetchall()]
        print(f"\n📊 Processing {len(agg_metrics)} aggregation metrics...")

        total_processed = 0

        for i, date in enumerate(dates, 1):
            date_processed = 0

            for agg_metric_id in agg_metrics:
                # Call process_single_aggregation for each metric/date combo
                cur.execute("""
                    SELECT process_single_aggregation(%s, %s, %s);
                """, (PATIENT_ID, agg_metric_id, date))

                result = cur.fetchone()[0]
                date_processed += result

            total_processed += date_processed

            if i % 10 == 0:
                print(f"   Processed {i}/{len(dates)} dates... ({total_processed} cache entries so far)")
                conn.commit()  # Commit every 10 dates

        conn.commit()

        print(f"\n✅ Done! Processed {total_processed} total aggregation cache entries")
        print(f"   Across {len(dates)} dates and {len(agg_metrics)} metrics")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    bulk_process_aggregations()
