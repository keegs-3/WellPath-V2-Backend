#!/usr/bin/env python3
"""
Process Calculation Queue
Processes pending calculations by calling the edge function
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
import requests
import time

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
EDGE_FUNCTION_URL = 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/run-instance-calculations'
SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

BATCH_SIZE = 10
MAX_RETRIES = 3

def get_pending_items(conn, limit=BATCH_SIZE):
    """Get pending items from queue"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT id, user_id, event_instance_id, attempts
            FROM calculation_queue
            WHERE status = 'pending' AND attempts < %s
            ORDER BY created_at ASC
            LIMIT %s
        """, (MAX_RETRIES, limit))
        return cur.fetchall()

def mark_processing(conn, queue_id):
    """Mark item as processing"""
    with conn.cursor() as cur:
        cur.execute("""
            UPDATE calculation_queue
            SET status = 'processing', attempts = attempts + 1
            WHERE id = %s
        """, (queue_id,))
    conn.commit()

def mark_completed(conn, queue_id):
    """Mark item as completed"""
    with conn.cursor() as cur:
        cur.execute("""
            UPDATE calculation_queue
            SET status = 'completed', processed_at = NOW()
            WHERE id = %s
        """, (queue_id,))
    conn.commit()

def mark_failed(conn, queue_id, error_message):
    """Mark item as failed"""
    with conn.cursor() as cur:
        cur.execute("""
            UPDATE calculation_queue
            SET status = CASE WHEN attempts >= %s THEN 'failed' ELSE 'pending' END,
                error_message = %s,
                processed_at = CASE WHEN attempts >= %s THEN NOW() ELSE NULL END
            WHERE id = %s
        """, (MAX_RETRIES, error_message, MAX_RETRIES, queue_id))
    conn.commit()

def process_item(item):
    """Call edge function to process one item"""
    headers = {
        'Authorization': f'Bearer {SUPABASE_SERVICE_ROLE_KEY}',
        'Content-Type': 'application/json'
    }
    payload = {
        'user_id': str(item['user_id']),
        'event_instance_id': str(item['event_instance_id'])
    }

    try:
        response = requests.post(EDGE_FUNCTION_URL, json=payload, headers=headers, timeout=30)

        if response.status_code == 200:
            result = response.json()
            return True, result
        else:
            return False, f"HTTP {response.status_code}: {response.text[:200]}"
    except Exception as e:
        return False, str(e)

def main():
    conn = psycopg2.connect(DB_URL)

    try:
        print("🔄 Processing Calculation Queue")
        print("=" * 70)

        total_processed = 0
        total_succeeded = 0
        total_failed = 0

        while True:
            # Get batch of pending items
            items = get_pending_items(conn, BATCH_SIZE)

            if not items:
                break

            print(f"\n📦 Processing batch of {len(items)} items...")

            for item in items:
                queue_id = item['id']
                event_id = item['event_instance_id']
                attempt = item['attempts'] + 1

                print(f"\n  [{total_processed + 1}] Event {str(event_id)[:8]}... (attempt {attempt}/{MAX_RETRIES})")

                # Mark as processing
                mark_processing(conn, queue_id)

                # Process
                success, result = process_item(item)

                if success:
                    calcs_created = result.get('calculations_created', 0)
                    print(f"     ✅ Success - {calcs_created} calculations created")
                    mark_completed(conn, queue_id)
                    total_succeeded += 1
                else:
                    print(f"     ❌ Failed - {result[:100]}")
                    mark_failed(conn, queue_id, result)
                    total_failed += 1

                total_processed += 1

                # Small delay to avoid overwhelming the edge function
                time.sleep(0.1)

        # Final summary
        print("\n" + "=" * 70)
        print("PROCESSING COMPLETE")
        print("=" * 70)
        print(f"Total Processed: {total_processed}")
        print(f"Succeeded: {total_succeeded} ✅")
        print(f"Failed: {total_failed} ❌")

        # Check remaining in queue
        with conn.cursor() as cur:
            cur.execute("SELECT status, COUNT(*) FROM calculation_queue GROUP BY status ORDER BY status")
            print("\nQueue Status:")
            for row in cur.fetchall():
                print(f"  {row[0]}: {row[1]}")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == "__main__":
    main()
