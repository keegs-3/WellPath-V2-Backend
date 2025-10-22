#!/usr/bin/env python3
"""
Run Calculations on Test Data and Verify Results
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
import requests

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
TEST_USER_ID = '02cc8441-5f01-4634-acfc-59e6f6a5705a'
EDGE_FUNCTION_URL = 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/run-instance-calculations'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzA0MTgsImV4cCI6MjA0Mzc0NjQxOH0.qMz2wBuZx5YhHLOMLVF1Zy3XQlXKjGcW-kXZLbXjQOE'


def main():
    conn = psycopg2.connect(DB_URL)

    try:
        # Get all test event_instance_ids
        print("🔍 Finding test events...")
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT DISTINCT event_instance_id, entry_date
                FROM patient_data_entries
                WHERE user_id = %s
                AND metadata->>'test' = 'true'
                ORDER BY entry_date
            """, (TEST_USER_ID,))
            events = cur.fetchall()

        print(f"Found {len(events)} test events\n")

        # Run calculations for each event
        results = {
            'total_events': len(events),
            'successful': 0,
            'failed': 0,
            'total_calculations_created': 0
        }

        for event in events:
            event_id = event['event_instance_id']
            entry_date = event['entry_date']

            print(f"📊 Processing event from {entry_date}...")

            # Call edge function
            headers = {
                'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
                'Content-Type': 'application/json'
            }
            payload = {
                'user_id': TEST_USER_ID,
                'event_instance_id': event_id
            }

            response = requests.post(EDGE_FUNCTION_URL, json=payload, headers=headers)

            if response.status_code == 200:
                result_data = response.json()
                calculations_created = result_data.get('calculations_created', 0)
                results['successful'] += 1
                results['total_calculations_created'] += calculations_created
                print(f"   ✅ {calculations_created} calculations created")
            else:
                results['failed'] += 1
                print(f"   ❌ Failed: {response.status_code} - {response.text[:100]}")

        # Query calculated results
        print(f"\n📈 Summary of Calculated Values:")
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Get all calculated fields with field registry info
            cur.execute("""
                SELECT
                    fr.field_name,
                    fr.display_name,
                    fr.field_source,
                    COUNT(pde.id) as count,
                    AVG(pde.value_quantity) as avg_value,
                    MIN(pde.value_quantity) as min_value,
                    MAX(pde.value_quantity) as max_value
                FROM patient_data_entries pde
                JOIN field_registry fr ON pde.field_id = fr.field_id
                WHERE pde.user_id = %s
                AND pde.source = 'auto_calculated'
                AND pde.created_at >= NOW() - INTERVAL '1 hour'
                GROUP BY fr.field_name, fr.display_name, fr.field_source
                ORDER BY fr.field_source, fr.field_name
            """, (TEST_USER_ID,))
            calc_results = cur.fetchall()

        print(f"\n{'Field':<30} {'Count':<8} {'Avg':<10} {'Min':<10} {'Max':<10}")
        print("=" * 70)

        for row in calc_results:
            print(f"{row['display_name']:<30} {row['count']:<8} " +
                  f"{row['avg_value']:>9.1f} {row['min_value']:>9.1f} {row['max_value']:>9.1f}")

        # Final summary
        print(f"\n{'='*70}")
        print(f"FINAL RESULTS")
        print(f"{'='*70}")
        print(f"Total Events Processed: {results['total_events']}")
        print(f"Successful: {results['successful']} ✅")
        print(f"Failed: {results['failed']} ❌")
        print(f"Total Calculations Created: {results['total_calculations_created']}")
        print(f"Unique Calculation Types: {len(calc_results)}")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()


if __name__ == "__main__":
    main()
