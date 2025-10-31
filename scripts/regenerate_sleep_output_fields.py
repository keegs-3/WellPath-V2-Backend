#!/usr/bin/env python3
"""
Regenerate Sleep OUTPUT Fields
===============================
Deletes all sleep duration entries and re-triggers instance calculations
to create both generic DURATION and type-specific OUTPUT fields.
"""

import os
import asyncio
import httpx
import psycopg2
from psycopg2.extras import execute_batch

# Database connection
DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://csotzmardnvrpdhlogjm.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzMjQ4MTEsImV4cCI6MjA3NDkwMDgxMX0.Kw5NRNL3uv35HFUaalLMSbXJLBOPXCceexs7Y-4U9S4')

async def trigger_calculation(patient_id: str, event_instance_id: str):
    """Trigger instance calculation via Edge Function"""
    url = f"{SUPABASE_URL}/functions/v1/run-instance-calculations"
    headers = {
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "patient_id": patient_id,
        "event_instance_id": event_instance_id
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            response = await client.post(url, headers=headers, json=data)
            response.raise_for_status()
            result = response.json()
            return result
        except Exception as e:
            print(f"  ❌ Error: {e}")
            return None

async def main():
    print("🔄 Regenerating Sleep OUTPUT Fields\n")

    # Connect to database
    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()

    try:
        # Step 1: Get all unique sleep events
        print("📊 Finding all sleep events...")
        cur.execute("""
            SELECT DISTINCT
                patient_id,
                event_instance_id
            FROM patient_data_entries
            WHERE field_id = 'DEF_SLEEP_PERIOD_TYPE'
            ORDER BY patient_id, event_instance_id
        """)
        events = cur.fetchall()
        print(f"   Found {len(events)} sleep events\n")

        # Step 2: Delete all existing duration entries (generic and OUTPUT)
        print("🗑️  Deleting existing duration entries...")
        cur.execute("""
            DELETE FROM patient_data_entries
            WHERE field_id = 'DEF_SLEEP_PERIOD_DURATION'
               OR field_id LIKE 'OUTPUT_%SLEEP%'
               OR field_id LIKE 'OUTPUT_%BED%'
               OR field_id LIKE 'OUTPUT_%AWAKE%'
        """)
        deleted_count = cur.rowcount
        conn.commit()
        print(f"   Deleted {deleted_count} entries\n")

        # Step 3: Re-trigger calculations for all events
        print("⚙️  Re-triggering instance calculations...")
        print(f"   Processing {len(events)} events (this may take a while)...\n")

        success_count = 0
        error_count = 0

        for i, (patient_id, event_instance_id) in enumerate(events, 1):
            # Progress indicator
            if i % 10 == 0 or i == 1:
                print(f"   Progress: {i}/{len(events)}")

            result = await trigger_calculation(str(patient_id), str(event_instance_id))

            if result and result.get('success'):
                success_count += 1
                if 'created_fields' in result:
                    fields = result['created_fields']
                    if len(fields) == 2:
                        # Both generic and OUTPUT created
                        pass
                    elif i <= 5:  # Show first few for debugging
                        print(f"   ⚠️  Event {event_instance_id}: Created {fields}")
            else:
                error_count += 1
                if error_count <= 5:  # Show first few errors
                    print(f"   ❌ Event {event_instance_id}: Failed")

            # Rate limiting: 10 requests per second max
            await asyncio.sleep(0.1)

        print(f"\n✅ Completed!")
        print(f"   Success: {success_count}")
        print(f"   Errors: {error_count}")

        # Step 4: Verify results
        print("\n📊 Verification:")
        cur.execute("""
            SELECT
                field_id,
                COUNT(*) as count
            FROM patient_data_entries
            WHERE field_id LIKE '%SLEEP%' OR field_id LIKE '%BED%' OR field_id LIKE '%AWAKE%'
            GROUP BY field_id
            ORDER BY field_id
        """)

        results = cur.fetchall()
        for field_id, count in results:
            if 'OUTPUT' in field_id:
                print(f"   ✅ {field_id}: {count}")
            else:
                print(f"      {field_id}: {count}")

    finally:
        cur.close()
        conn.close()

    print("\n🎉 Regeneration complete!")

if __name__ == "__main__":
    asyncio.run(main())
