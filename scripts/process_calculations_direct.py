#!/usr/bin/env python3
"""
Process Calculations Directly (No Edge Function)
Executes instance calculations directly via database queries
Workaround for JWT authentication issues with edge functions
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

def get_event_data(conn, user_id, event_instance_id):
    """Get all data entries for an event"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT
                pde.field_id,
                pde.value_quantity,
                pde.value_timestamp,
                pde.value_reference,
                pde.entry_date,
                pde.entry_timestamp,
                fr.field_source,
                fr.unit
            FROM patient_data_entries pde
            JOIN field_registry fr ON pde.field_id = fr.field_id
            WHERE pde.user_id = %s
            AND pde.event_instance_id = %s
            AND pde.source != 'auto_calculated'
            ORDER BY pde.field_id
        """, (user_id, event_instance_id))
        return cur.fetchall()

def calculate_duration(start_time, end_time):
    """Calculate duration in minutes between two timestamps"""
    if not start_time or not end_time:
        return None
    duration = (end_time - start_time).total_seconds() / 60
    return round(duration, 2)

def process_duration_calculation(conn, user_id, event_instance_id, calc, entries_map):
    """Process a duration calculation"""
    # Get dependencies
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT
                icd.data_entry_field_id,
                icd.parameter_name,
                icd.parameter_role
            FROM instance_calculations_dependencies icd
            WHERE icd.instance_calculation_id = %s
            ORDER BY icd.parameter_order
        """, (calc['calc_id'],))
        deps = cur.fetchall()

    # Find start and end times
    start_time = None
    end_time = None

    for dep in deps:
        field_id = dep['data_entry_field_id']
        role = dep['parameter_role']

        if field_id in entries_map:
            entry = entries_map[field_id]
            if role == 'start_time' and entry['value_timestamp']:
                start_time = entry['value_timestamp']
            elif role == 'end_time' and entry['value_timestamp']:
                end_time = entry['value_timestamp']

    # Calculate duration
    if start_time and end_time:
        duration_minutes = calculate_duration(start_time, end_time)

        if duration_minutes is not None:
            # Get output field from calc config
            config = calc.get('calculation_config', {})
            output_field = config.get('output_field')

            if output_field:
                # Insert calculated value
                entry_date = entries_map[next(iter(entries_map))]['entry_date']
                entry_timestamp = entries_map[next(iter(entries_map))]['entry_timestamp']

                with conn.cursor() as cur:
                    cur.execute("""
                        INSERT INTO patient_data_entries
                        (user_id, field_id, entry_date, entry_timestamp, value_quantity, source, event_instance_id, metadata)
                        VALUES (%s, %s, %s, %s, %s, 'auto_calculated', %s, %s::jsonb)
                        ON CONFLICT DO NOTHING
                    """, (user_id, output_field, entry_date, entry_timestamp, duration_minutes, event_instance_id, '{"calculated_by": "direct_processor"}'))

                return True, duration_minutes

    return False, None

def process_queue_item(conn, queue_id, user_id, event_instance_id):
    """Process one item from the queue"""
    try:
        # Get event data
        entries = get_event_data(conn, user_id, event_instance_id)

        if not entries:
            return False, "No data entries found"

        # Create entries map
        entries_map = {entry['field_id']: entry for entry in entries}

        # Get applicable instance calculations
        field_ids = list(entries_map.keys())

        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT DISTINCT
                    ic.calc_id,
                    ic.calc_name,
                    ic.calculation_method,
                    ic.calculation_config
                FROM instance_calculations ic
                JOIN instance_calculations_dependencies icd ON ic.calc_id = icd.instance_calculation_id
                WHERE icd.data_entry_field_id = ANY(%s)
                AND ic.is_active = true
            """, (field_ids,))
            calculations = cur.fetchall()

        if not calculations:
            return False, "No applicable calculations found"

        # Process each calculation
        calc_results = []
        for calc in calculations:
            if calc['calculation_method'] == 'calculate_duration':
                success, result = process_duration_calculation(conn, user_id, event_instance_id, calc, entries_map)
                if success:
                    calc_results.append({'calc': calc['calc_name'], 'value': result})

        conn.commit()

        if calc_results:
            return True, f"Calculated {len(calc_results)} values"
        else:
            return False, "No calculations executed"

    except Exception as e:
        conn.rollback()
        return False, str(e)

def main():
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = False

    try:
        print("🔄 Processing Calculation Queue (Direct Mode)")
        print("=" * 70)
        print("⚠️  Using direct database processing (bypassing edge function)")
        print("=" * 70)

        # Get pending items
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, user_id, event_instance_id
                FROM calculation_queue
                WHERE status = 'pending'
                ORDER BY created_at ASC
                LIMIT 100
            """)
            items = cur.fetchall()

        print(f"\nFound {len(items)} pending calculations\n")

        total_succeeded = 0
        total_failed = 0

        for i, item in enumerate(items, 1):
            queue_id = item['id']
            event_id = str(item['event_instance_id'])[:8]

            print(f"[{i}/{len(items)}] Event {event_id}...", end=" ")

            # Mark as processing
            with conn.cursor() as cur:
                cur.execute("""
                    UPDATE calculation_queue
                    SET status = 'processing'
                    WHERE id = %s
                """, (queue_id,))
            conn.commit()

            # Process
            success, message = process_queue_item(conn, queue_id, item['user_id'], item['event_instance_id'])

            if success:
                print(f"✅ {message}")
                with conn.cursor() as cur:
                    cur.execute("""
                        UPDATE calculation_queue
                        SET status = 'completed', processed_at = NOW()
                        WHERE id = %s
                    """, (queue_id,))
                conn.commit()
                total_succeeded += 1
            else:
                print(f"❌ {message[:50]}")
                with conn.cursor() as cur:
                    cur.execute("""
                        UPDATE calculation_queue
                        SET status = 'failed', error_message = %s, processed_at = NOW()
                        WHERE id = %s
                    """, (message, queue_id))
                conn.commit()
                total_failed += 1

        # Summary
        print("\n" + "=" * 70)
        print("PROCESSING COMPLETE")
        print("=" * 70)
        print(f"Total: {len(items)}")
        print(f"Succeeded: {total_succeeded} ✅")
        print(f"Failed: {total_failed} ❌")

        # Check calculated values
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT
                    fr.field_name,
                    COUNT(*) as count,
                    ROUND(AVG(pde.value_quantity)::numeric, 2) as avg_value
                FROM patient_data_entries pde
                JOIN field_registry fr ON pde.field_id = fr.field_id
                WHERE pde.source = 'auto_calculated'
                AND pde.created_at >= NOW() - INTERVAL '1 hour'
                GROUP BY fr.field_name
                ORDER BY fr.field_name
            """)
            results = cur.fetchall()

        if results:
            print("\n📊 Calculated Values:")
            print(f"{'Field':<30} {'Count':<10} {'Avg Value':<10}")
            print("=" * 50)
            for row in results:
                print(f"{row['field_name']:<30} {row['count']:<10} {row['avg_value']:<10}")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == "__main__":
    main()
