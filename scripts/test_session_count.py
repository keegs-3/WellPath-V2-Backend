#!/usr/bin/env python3
"""
Test Session Count Calculations
Creates a cardio session and verifies session count is auto-calculated
"""

import os
import psycopg2
from datetime import datetime, timedelta
from uuid import uuid4
import time

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
TEST_USER_ID = '02cc8441-5f01-4634-acfc-59e6f6a5705a'

def main():
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = False

    try:
        cur = conn.cursor()

        print("🏃 Testing Session Count Calculations")
        print("=" * 70)

        # Create a new cardio session
        event_id = str(uuid4())
        now = datetime.now()
        start_time = now - timedelta(minutes=45)
        end_time = now

        print(f"\n📝 Creating cardio session {event_id[:8]}...")
        print(f"   Start: {start_time.strftime('%Y-%m-%d %H:%M')}")
        print(f"   End:   {end_time.strftime('%Y-%m-%d %H:%M')}")

        # Insert cardio start
        cur.execute("""
            INSERT INTO patient_data_entries
            (user_id, field_id, entry_date, entry_timestamp, value_timestamp, source, event_instance_id)
            VALUES (%s, %s, %s, %s, %s, 'manual', %s)
        """, (TEST_USER_ID, 'DEF_CARDIO_START', start_time.date(), start_time, start_time, event_id))

        # Insert cardio end
        cur.execute("""
            INSERT INTO patient_data_entries
            (user_id, field_id, entry_date, entry_timestamp, value_timestamp, source, event_instance_id)
            VALUES (%s, %s, %s, %s, %s, 'manual', %s)
        """, (TEST_USER_ID, 'DEF_CARDIO_END', end_time.date(), end_time, end_time, event_id))

        conn.commit()
        print("   ✅ Cardio session created")

        # Wait for edge function to process
        print("\n⏳ Waiting 3 seconds for calculations to complete...")
        time.sleep(3)

        # Check for auto-calculated session count
        print("\n🔍 Checking for auto-calculated session count...")
        cur.execute("""
            SELECT field_id, value_quantity, source, metadata
            FROM patient_data_entries
            WHERE user_id = %s
              AND event_instance_id = %s
              AND source = 'auto_calculated'
            ORDER BY field_id
        """, (TEST_USER_ID, event_id))

        results = cur.fetchall()

        if results:
            print(f"   ✅ Found {len(results)} auto-calculated fields:")
            for row in results:
                field_id, value, source, metadata = row
                print(f"      • {field_id}: {value} (source: {source})")
                if metadata:
                    print(f"        metadata: {metadata}")
        else:
            print("   ❌ No auto-calculated fields found")

        # Verify session count specifically
        print("\n🎯 Verifying session count...")
        cur.execute("""
            SELECT value_quantity, metadata
            FROM patient_data_entries
            WHERE user_id = %s
              AND event_instance_id = %s
              AND field_id = 'DEF_CARDIO_SESSION_COUNT'
              AND source = 'auto_calculated'
        """, (TEST_USER_ID, event_id))

        session_count_result = cur.fetchone()

        if session_count_result:
            value, metadata = session_count_result
            print(f"   ✅ Session count = {value}")
            print(f"      Metadata: {metadata}")
        else:
            print("   ❌ Session count not found")

        # Show all cardio sessions today
        print("\n📊 All cardio sessions today:")
        cur.execute("""
            SELECT
                event_instance_id,
                COUNT(DISTINCT field_id) as field_count,
                STRING_AGG(DISTINCT field_id, ', ' ORDER BY field_id) as fields
            FROM patient_data_entries
            WHERE user_id = %s
              AND field_id LIKE 'DEF_CARDIO%'
              AND entry_date = %s
            GROUP BY event_instance_id
            ORDER BY event_instance_id
        """, (TEST_USER_ID, now.date()))

        sessions = cur.fetchall()
        print(f"   Found {len(sessions)} sessions:")
        for event_id_val, field_count, fields in sessions:
            print(f"   • {event_id_val[:8]}: {field_count} fields")
            print(f"     {fields}")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == "__main__":
    main()
