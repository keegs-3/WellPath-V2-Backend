#!/usr/bin/env python3
"""
Generate Realistic Sleep Stage Data
Creates physiologically accurate sleep stages following natural sleep cycles
"""

import os
import psycopg2
from datetime import datetime, timedelta
import random
import uuid

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:6543/postgres'
USER_ID = '1758fa60-a306-440e-8ae6-9e68fd502bc2'  # test@wellpath.dev

def generate_sleep_cycle(cycle_start, cycle_number, is_first_cycle, is_last_cycle):
    """
    Generate one ~90 minute sleep cycle with realistic stage distribution

    Sleep Architecture:
    - Early cycles: More deep sleep, less REM
    - Later cycles: Less deep sleep, more REM
    - Core sleep throughout
    - Occasional brief awakenings
    """
    stages = []
    current_time = cycle_start

    # Cycle duration: 80-100 minutes (average 90)
    cycle_duration = random.randint(80, 100)
    cycle_end = cycle_start + timedelta(minutes=cycle_duration)

    # Deep sleep percentage (more in early cycles)
    if is_first_cycle:
        deep_sleep_mins = random.randint(20, 30)  # First cycle has most deep sleep
    elif cycle_number <= 2:
        deep_sleep_mins = random.randint(10, 20)  # Second/third cycle has some deep sleep
    else:
        deep_sleep_mins = random.randint(0, 5)    # Later cycles have little/no deep sleep

    # REM sleep percentage (more in later cycles)
    if is_first_cycle:
        rem_sleep_mins = random.randint(5, 10)    # First cycle has least REM
    elif is_last_cycle:
        rem_sleep_mins = random.randint(25, 35)   # Last cycle has most REM
    else:
        rem_sleep_mins = random.randint(15, 25)   # Middle cycles have moderate REM

    # Awake periods (brief, occasional)
    has_awakening = random.random() < 0.3  # 30% chance of awakening
    awake_mins = random.randint(1, 3) if has_awakening else 0

    # Core sleep fills the rest
    core_sleep_mins = cycle_duration - deep_sleep_mins - rem_sleep_mins - awake_mins

    # Build the cycle in realistic order
    # Typical cycle: Core → Deep → Core → REM → (maybe Awake)

    # Phase 1: Core sleep (transition into deep)
    core_phase1_mins = random.randint(5, 10)
    stages.append({
        'stage': 'core',
        'start': current_time,
        'end': current_time + timedelta(minutes=core_phase1_mins)
    })
    current_time += timedelta(minutes=core_phase1_mins)

    # Phase 2: Deep sleep (if any)
    if deep_sleep_mins > 0:
        stages.append({
            'stage': 'deep',
            'start': current_time,
            'end': current_time + timedelta(minutes=deep_sleep_mins)
        })
        current_time += timedelta(minutes=deep_sleep_mins)

    # Phase 3: Core sleep (post-deep, pre-REM)
    core_phase2_mins = core_sleep_mins - core_phase1_mins
    if core_phase2_mins > 0:
        stages.append({
            'stage': 'core',
            'start': current_time,
            'end': current_time + timedelta(minutes=core_phase2_mins)
        })
        current_time += timedelta(minutes=core_phase2_mins)

    # Phase 4: REM sleep
    stages.append({
        'stage': 'rem',
        'start': current_time,
        'end': current_time + timedelta(minutes=rem_sleep_mins)
    })
    current_time += timedelta(minutes=rem_sleep_mins)

    # Phase 5: Brief awakening (if any)
    if awake_mins > 0:
        stages.append({
            'stage': 'awake',
            'start': current_time,
            'end': current_time + timedelta(minutes=awake_mins)
        })
        current_time += timedelta(minutes=awake_mins)

    return stages

def generate_night_sleep(bedtime, waketime):
    """
    Generate complete night of sleep with multiple cycles
    """
    all_stages = []

    # Calculate total sleep duration
    sleep_duration = waketime - bedtime
    total_minutes = int(sleep_duration.total_seconds() / 60)

    # Number of sleep cycles (each ~90 mins)
    num_cycles = max(4, min(6, total_minutes // 90))

    # Generate each cycle
    current_time = bedtime
    for cycle_num in range(num_cycles):
        is_first = (cycle_num == 0)
        is_last = (cycle_num == num_cycles - 1)

        cycle_stages = generate_sleep_cycle(current_time, cycle_num + 1, is_first, is_last)
        all_stages.extend(cycle_stages)

        # Move to next cycle
        if cycle_stages:
            current_time = cycle_stages[-1]['end']

    return all_stages

def insert_sleep_stages(conn, date, stages):
    """
    Insert sleep stages into patient_data_entries
    """
    with conn.cursor() as cur:
        for stage in stages:
            stage_type = stage['stage']
            start_time = stage['start']
            end_time = stage['end']

            # Map stage to field IDs
            field_mapping = {
                'deep': ('DEF_DEEP_SLEEP_START', 'DEF_DEEP_SLEEP_END'),
                'core': ('DEF_CORE_SLEEP_START', 'DEF_CORE_SLEEP_END'),
                'rem': ('DEF_REM_SLEEP_START', 'DEF_REM_SLEEP_END'),
                'awake': ('DEF_AWAKE_PERIODS_START', 'DEF_AWAKE_PERIODS_END')
            }

            start_field, end_field = field_mapping[stage_type]
            event_id = str(uuid.uuid4())

            # Insert start time
            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_timestamp, source, event_instance_id
                ) VALUES (%s, %s, %s, %s, %s, 'healthkit', %s)
            """, (USER_ID, start_field, date, start_time, start_time, event_id))

            # Insert end time
            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_timestamp, source, event_instance_id
                ) VALUES (%s, %s, %s, %s, %s, 'healthkit', %s)
            """, (USER_ID, end_field, date, end_time, end_time, event_id))

def generate_sleep_data(conn, days=30):
    """
    Generate realistic sleep stage data for past N days
    """
    print("\n😴 Generating Realistic Sleep Stage Data...")
    print("=" * 60)

    start_date = datetime.now() - timedelta(days=days)
    total_entries = 0

    # Pick ONE random day for the nap
    nap_day = random.randint(5, days - 5)

    for day_offset in range(days):
        current_date = start_date + timedelta(days=day_offset)

        # Bedtime: 10pm-12am (previous day)
        bedtime_hour = random.randint(22, 23)
        bedtime_minute = random.randint(0, 59)
        bedtime = (current_date - timedelta(days=1)).replace(
            hour=bedtime_hour,
            minute=bedtime_minute,
            second=0,
            microsecond=0
        )

        # Waketime: 6am-8am (current day)
        waketime_hour = random.randint(6, 8)
        waketime_minute = random.randint(0, 59)
        waketime = current_date.replace(
            hour=waketime_hour,
            minute=waketime_minute,
            second=0,
            microsecond=0
        )

        # Generate sleep cycles
        stages = generate_night_sleep(bedtime, waketime)

        # Insert into database
        insert_sleep_stages(conn, current_date.date(), stages)

        # Count entries
        entries_for_night = len(stages) * 2  # start + end for each stage
        total_entries += entries_for_night

        # Add a nap on the selected random day
        if day_offset == nap_day:
            nap_start_hour = random.randint(11, 13)
            nap_start = current_date.replace(hour=nap_start_hour, minute=0, second=0, microsecond=0)
            nap_duration_mins = random.randint(60, 120)  # 1-2 hour nap
            nap_end = nap_start + timedelta(minutes=nap_duration_mins)

            # Simple nap: mostly core sleep with some REM
            core_mins = int(nap_duration_mins * 0.7)
            rem_mins = nap_duration_mins - core_mins

            nap_stages = [
                {'stage': 'core', 'start': nap_start, 'end': nap_start + timedelta(minutes=core_mins)},
                {'stage': 'rem', 'start': nap_start + timedelta(minutes=core_mins), 'end': nap_end}
            ]

            insert_sleep_stages(conn, current_date.date(), nap_stages)
            total_entries += len(nap_stages) * 2
            print(f"    ✨ Added {nap_duration_mins}-min nap at {nap_start_hour}:00")

        # Calculate sleep stats for this night
        deep_mins = sum((s['end'] - s['start']).total_seconds() / 60 for s in stages if s['stage'] == 'deep')
        core_mins = sum((s['end'] - s['start']).total_seconds() / 60 for s in stages if s['stage'] == 'core')
        rem_mins = sum((s['end'] - s['start']).total_seconds() / 60 for s in stages if s['stage'] == 'rem')
        awake_mins = sum((s['end'] - s['start']).total_seconds() / 60 for s in stages if s['stage'] == 'awake')
        total_sleep = deep_mins + core_mins + rem_mins + awake_mins

        print(f"  {current_date.date()} | "
              f"Deep: {int(deep_mins)}m ({deep_mins/total_sleep*100:.0f}%) | "
              f"Core: {int(core_mins)}m ({core_mins/total_sleep*100:.0f}%) | "
              f"REM: {int(rem_mins)}m ({rem_mins/total_sleep*100:.0f}%) | "
              f"Awake: {int(awake_mins)}m ({awake_mins/total_sleep*100:.0f}%) | "
              f"Total: {int(total_sleep)}m")

    conn.commit()
    print("=" * 60)
    print(f"✅ Created {total_entries} sleep stage entries ({days} nights)")

    return total_entries

def main():
    print("🚀 Generating Realistic Sleep Stage Data")
    print(f"User ID: {USER_ID}")
    print(f"Period: Last 30 days")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        total_entries = generate_sleep_data(conn, days=30)

        print("\n" + "=" * 60)
        print("✅ COMPLETE!")
        print("=" * 60)

        # Summary statistics
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    COUNT(*) as total_entries,
                    MIN(entry_date) as first_date,
                    MAX(entry_date) as last_date,
                    COUNT(DISTINCT entry_date) as nights_with_data,
                    COUNT(DISTINCT event_instance_id) as total_sleep_stages
                FROM patient_data_entries
                WHERE user_id = %s
                  AND field_id IN (
                    'DEF_DEEP_SLEEP_START', 'DEF_DEEP_SLEEP_END',
                    'DEF_CORE_SLEEP_START', 'DEF_CORE_SLEEP_END',
                    'DEF_REM_SLEEP_START', 'DEF_REM_SLEEP_END',
                    'DEF_AWAKE_PERIODS_START', 'DEF_AWAKE_PERIODS_END'
                  )
            """, (USER_ID,))

            stats = cur.fetchone()

            print(f"\n📊 Summary:")
            print(f"  Total Entries: {stats[0]:,}")
            print(f"  Date Range: {stats[1]} to {stats[2]}")
            print(f"  Nights with Data: {stats[3]}")
            print(f"  Total Sleep Stages: {stats[4]}")

        print("\n🎉 Sleep stage data generation complete!")
        print("   Instance calculations will be auto-processed by the edge function.")
        print("   Aggregations will be automatically calculated.")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
