#!/usr/bin/env python3
"""
Fix Day View - Add Hourly Aggregations for Protein
Mobile day view queries hourly period, but only daily/weekly/monthly exist
"""

import psycopg2
from datetime import datetime, timedelta

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
USER_ID = '1758fa60-a306-440e-8ae6-9e68fd502bc2'

def main():
    print("🔧 Fixing Day View - Adding Hourly Aggregations")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        with conn.cursor() as cur:
            # Step 1: Add hourly period to AGG_PROTEIN_GRAMS
            print("\n📝 Step 1: Adding hourly period configuration...")

            # Check if it already exists
            cur.execute("""
                SELECT COUNT(*)
                FROM aggregation_metrics_periods
                WHERE agg_metric_id = 'AGG_PROTEIN_GRAMS' AND period_id = 'hourly'
            """)
            exists = cur.fetchone()[0] > 0

            if not exists:
                cur.execute("""
                    INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
                    VALUES ('AGG_PROTEIN_GRAMS', 'hourly');
                """)
                print("✅ Hourly period configured")
            else:
                print("✅ Hourly period already configured")

            # Step 2: Check what periods are now configured
            cur.execute("""
                SELECT period_id
                FROM aggregation_metrics_periods
                WHERE agg_metric_id = 'AGG_PROTEIN_GRAMS'
                ORDER BY period_id
            """)
            periods = [row[0] for row in cur.fetchall()]
            print(f"   Configured periods: {', '.join(periods)}")

            # Step 3: Get all dates with protein data
            cur.execute("""
                SELECT DISTINCT entry_date
                FROM patient_data_entries
                WHERE user_id = %s
                  AND field_id = 'DEF_PROTEIN_GRAMS'
                ORDER BY entry_date
            """, (USER_ID,))

            dates = [row[0] for row in cur.fetchall()]
            print(f"\n📅 Found {len(dates)} days of protein data")
            print(f"   Range: {dates[0]} to {dates[-1]}")

            # Step 4: Process hourly aggregations for each date
            print(f"\n⚙️  Step 2: Processing hourly aggregations...")
            total_hourly = 0

            for entry_date in dates:
                # Call the PostgreSQL function to process hourly aggregations
                cur.execute("""
                    SELECT process_field_aggregations(%s, %s, %s);
                """, (USER_ID, 'DEF_PROTEIN_GRAMS', entry_date))

                result = cur.fetchone()[0]
                if result and result > 0:
                    total_hourly += result

            conn.commit()

            print(f"✅ Created {total_hourly} hourly aggregation results")

            # Step 5: Verify hourly data exists
            print(f"\n🔍 Step 3: Verifying hourly aggregations...")
            cur.execute("""
                SELECT
                    period_type,
                    COUNT(*) as count,
                    MIN(period_start)::date as earliest,
                    MAX(period_end)::date as latest
                FROM aggregation_results_cache
                WHERE user_id = %s
                  AND agg_metric_id = 'AGG_PROTEIN_GRAMS'
                GROUP BY period_type
                ORDER BY
                    CASE period_type
                        WHEN 'hourly' THEN 1
                        WHEN 'daily' THEN 2
                        WHEN 'weekly' THEN 3
                        WHEN 'monthly' THEN 4
                    END
            """, (USER_ID,))

            print("\nAGG_PROTEIN_GRAMS aggregations:")
            print("-" * 60)
            for row in cur.fetchall():
                print(f"  {row[0]:10} | {row[1]:5} results | {row[2]} to {row[3]}")

            print("\n" + "=" * 60)
            print("✅ DAY VIEW FIX COMPLETE!")
            print("=" * 60)
            print("\n📱 Mobile day view should now show hourly protein data")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
