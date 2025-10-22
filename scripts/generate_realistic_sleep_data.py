#!/usr/bin/env python3
"""
Generate Realistic Sleep Data with Periods
Mimics HealthKit's sleep analysis structure:
- One "In Bed" session (bedtime → waketime)
- Multiple overlapping periods (core, deep, REM, awake)
"""

import os
import psycopg2
from datetime import datetime, timedelta
from uuid import uuid4

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
TEST_USER_ID = '02cc8441-5f01-4634-acfc-59e6f6a5705a'

def insert_entry(cur, user_id, field_id, value, value_type, entry_date, entry_timestamp, event_instance_id, metadata):
    """Insert a data entry"""
    if value_type == 'timestamp':
        cur.execute("""
            INSERT INTO patient_data_entries
            (user_id, field_id, entry_date, entry_timestamp, value_timestamp, source, event_instance_id, metadata)
            VALUES (%s, %s, %s, %s, %s, 'manual', %s, %s::jsonb)
        """, (user_id, field_id, entry_date, entry_timestamp, value, event_instance_id, metadata))
    elif value_type == 'reference':
        cur.execute("""
            INSERT INTO patient_data_entries
            (user_id, field_id, entry_date, entry_timestamp, value_reference, source, event_instance_id, metadata)
            VALUES (%s, %s, %s, %s, %s, 'manual', %s, %s::jsonb)
        """, (user_id, field_id, entry_date, entry_timestamp, value, event_instance_id, metadata))

def generate_sleep_session(cur, user_id, night_date, bedtime_hour=22, waketime_hour=7):
    """
    Generate one realistic sleep session with periods

    Mimics HealthKit structure:
    - In Bed sample (bedtime → waketime)
    - Multiple stage samples (core, deep, REM, awake) that overlap the in-bed time
    """
    event_id = str(uuid4())

    # Session boundaries
    bedtime = datetime.combine(night_date, datetime.min.time()) + timedelta(hours=bedtime_hour)
    waketime = datetime.combine(night_date + timedelta(days=1), datetime.min.time()) + timedelta(hours=waketime_hour)

    metadata = '{"test": true, "realistic_sleep": true}'

    # Insert session boundaries
    insert_entry(cur, user_id, 'DEF_SLEEP_BEDTIME', bedtime, 'timestamp',
                 night_date, bedtime, event_id, metadata)
    insert_entry(cur, user_id, 'DEF_SLEEP_WAKETIME', waketime, 'timestamp',
                 night_date, waketime, event_id, metadata)

    # Generate realistic sleep periods
    # Typical pattern: Core → Deep → REM cycles, with occasional awake periods

    current_time = bedtime + timedelta(minutes=15)  # Fall asleep after 15 min
    periods = []

    # First cycle: Core → Deep (2 hours)
    periods.append({
        'start': current_time,
        'end': current_time + timedelta(hours=1.5),
        'type': 'core'
    })
    current_time += timedelta(hours=1.5)

    periods.append({
        'start': current_time,
        'end': current_time + timedelta(minutes=45),
        'type': 'deep'
    })
    current_time += timedelta(minutes=45)

    # Awake briefly
    periods.append({
        'start': current_time,
        'end': current_time + timedelta(minutes=10),
        'type': 'awake'
    })
    current_time += timedelta(minutes=10)

    # Second cycle: REM → Core (2.5 hours)
    periods.append({
        'start': current_time,
        'end': current_time + timedelta(hours=1.5),
        'type': 'rem'
    })
    current_time += timedelta(hours=1.5)

    periods.append({
        'start': current_time,
        'end': current_time + timedelta(hours=1),
        'type': 'core'
    })
    current_time += timedelta(hours=1)

    # Another brief awake
    periods.append({
        'start': current_time,
        'end': current_time + timedelta(minutes=5),
        'type': 'awake'
    })
    current_time += timedelta(minutes=5)

    # Final cycle: Deep → REM → Core (remaining time)
    periods.append({
        'start': current_time,
        'end': current_time + timedelta(minutes=30),
        'type': 'deep'
    })
    current_time += timedelta(minutes=30)

    periods.append({
        'start': current_time,
        'end': current_time + timedelta(hours=1),
        'type': 'rem'
    })
    current_time += timedelta(hours=1)

    # Final core sleep until wake
    remaining = (waketime - current_time).total_seconds() / 60
    if remaining > 0:
        periods.append({
            'start': current_time,
            'end': waketime - timedelta(minutes=5),  # Wake up 5 min before getting out of bed
            'type': 'core'
        })

    # Insert all periods
    for period in periods:
        insert_entry(cur, user_id, 'DEF_SLEEP_PERIOD_START', period['start'], 'timestamp',
                     night_date, period['start'], event_id, metadata)
        insert_entry(cur, user_id, 'DEF_SLEEP_PERIOD_END', period['end'], 'timestamp',
                     night_date, period['end'], event_id, metadata)
        insert_entry(cur, user_id, 'DEF_SLEEP_PERIOD_TYPE', period['type'], 'reference',
                     night_date, period['start'], event_id, metadata)

    # Calculate totals
    total_hours = (waketime - bedtime).total_seconds() / 3600
    stage_totals = {}
    for period in periods:
        stage = period['type']
        duration_min = (period['end'] - period['start']).total_seconds() / 60
        stage_totals[stage] = stage_totals.get(stage, 0) + duration_min

    return {
        'event_id': event_id,
        'bedtime': bedtime,
        'waketime': waketime,
        'total_hours': total_hours,
        'periods': len(periods),
        'stage_totals': stage_totals
    }

def main():
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = False

    try:
        cur = conn.cursor()

        print("🌙 Generating Realistic Sleep Data")
        print("=" * 70)

        # Generate 3 nights of sleep
        nights = []
        for i in range(3):
            night_date = datetime.now().date() - timedelta(days=i+1)
            print(f"\nNight {i+1}: {night_date}")

            result = generate_sleep_session(cur, TEST_USER_ID, night_date)
            nights.append(result)

            print(f"  Bedtime: {result['bedtime'].strftime('%H:%M')}")
            print(f"  Waketime: {result['waketime'].strftime('%H:%M')}")
            print(f"  Total: {result['total_hours']:.1f} hours")
            print(f"  Periods: {result['periods']}")
            print(f"  Stage breakdown:")
            for stage, minutes in result['stage_totals'].items():
                print(f"    {stage.capitalize()}: {minutes:.0f} min ({minutes/60:.1f}h)")

        conn.commit()

        print("\n" + "=" * 70)
        print(f"✅ Generated {len(nights)} realistic sleep sessions")
        print(f"   Total data entries: {sum(n['periods'] * 3 + 2 for n in nights)}")
        print("   (Each session = 2 boundaries + N periods × 3 fields)")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == "__main__":
    main()
