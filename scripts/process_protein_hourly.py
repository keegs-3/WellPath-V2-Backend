#!/usr/bin/env python3
"""
Process Protein Hourly Aggregations
Quick script to populate hourly protein data
"""

import psycopg2
from datetime import datetime

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
USER_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'  # test.patient.21@wellpath.com

def main():
    print(f"🥩 Processing Hourly Protein Aggregations")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        with conn.cursor() as cur:
            # Get all unique dates with protein data
            cur.execute("""
                SELECT DISTINCT entry_date
                FROM patient_data_entries
                WHERE patient_id = %s
                  AND field_id IN ('DEF_PROTEIN_GRAMS', 'DEF_PROTEIN_TYPE')
                ORDER BY entry_date;
            """, (USER_ID,))

            dates = [row[0] for row in cur.fetchall()]
            print(f"📅 Found {len(dates)} days with protein data")
            print(f"   Range: {dates[0]} to {dates[-1]}\n")

            total_processed = 0
            for i, entry_date in enumerate(dates, 1):
                # Process protein grams (includes all protein type aggregations via dependencies)
                cur.execute("""
                    SELECT process_field_aggregations(%s, %s, %s);
                """, (USER_ID, 'DEF_PROTEIN_GRAMS', entry_date))

                result = cur.fetchone()[0]
                total_processed += result

                print(f"  [{i}/{len(dates)}] {entry_date}: {result} aggregations processed")

            conn.commit()

            print("\n" + "=" * 60)
            print(f"✅ COMPLETE! Processed {total_processed} aggregations")
            print("=" * 60)

            # Check hourly cache
            cur.execute("""
                SELECT
                    COUNT(*) as total_hourly,
                    COUNT(DISTINCT agg_metric_id) as unique_metrics
                FROM aggregation_results_cache
                WHERE patient_id = %s
                  AND agg_metric_id LIKE 'AGG_PROTEIN%'
                  AND period_type = 'hourly';
            """, (USER_ID,))

            total_hourly, unique_metrics = cur.fetchone()
            print(f"\n📊 Hourly Cache Summary:")
            print(f"   Total hourly entries: {total_hourly}")
            print(f"   Unique protein metrics: {unique_metrics}")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
