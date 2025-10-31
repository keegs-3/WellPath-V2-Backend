#!/usr/bin/env python3
"""
Generate Comprehensive Test Data for User
Creates realistic data across all major categories for the past 30 days
"""

import psycopg2
from datetime import datetime, timedelta
import random
import uuid

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
USER_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'  # test.patient.21@wellpath.com

def generate_protein_entries(conn, date):
    """Generate 3 protein meals per day"""
    entries = []
    meal_times = [
        (8, 0),   # Breakfast
        (12, 30), # Lunch
        (18, 30)  # Dinner
    ]

    protein_types = ['lean_protein', 'fatty_fish', 'plant_based', 'red_meat']

    for hour, minute in meal_times:
        event_id = str(uuid.uuid4())
        timestamp = datetime.combine(date, datetime.min.time()).replace(hour=hour, minute=minute)
        grams = random.randint(20, 40)

        # Protein grams
        entries.append((
            USER_ID, 'DEF_PROTEIN_GRAMS', date, timestamp,
            grams, None, None, 'manual', event_id
        ))

        # Protein type
        entries.append((
            USER_ID, 'DEF_PROTEIN_TYPE', date, timestamp,
            None, random.choice(protein_types), None, 'manual', event_id
        ))

        # Protein time
        entries.append((
            USER_ID, 'DEF_PROTEIN_TIME', date, timestamp,
            None, None, timestamp, 'manual', event_id
        ))

    return entries

def generate_sleep_entries(conn, date):
    """Generate realistic sleep stage data"""
    entries = []

    # Sleep from 10:30 PM (previous day) to 6:30 AM (current day)
    bedtime = datetime.combine(date - timedelta(days=1), datetime.min.time()).replace(hour=22, minute=30)
    waketime = datetime.combine(date, datetime.min.time()).replace(hour=6, minute=30)

    # Generate 4-5 sleep cycles (~90 min each)
    current_time = bedtime
    num_cycles = 5

    for cycle in range(num_cycles):
        event_id = str(uuid.uuid4())

        # Deep sleep (20-30 min early cycles, 0-5 later)
        if cycle == 0:
            deep_mins = random.randint(25, 35)
        elif cycle <= 2:
            deep_mins = random.randint(10, 20)
        else:
            deep_mins = random.randint(0, 5)

        if deep_mins > 0:
            deep_start = current_time
            deep_end = current_time + timedelta(minutes=deep_mins)
            entries.extend([
                (USER_ID, 'DEF_DEEP_SLEEP_START', date, deep_start, None, None, deep_start, 'healthkit', event_id),
                (USER_ID, 'DEF_DEEP_SLEEP_END', date, deep_end, None, None, deep_end, 'healthkit', event_id)
            ])
            current_time = deep_end

        # Core sleep (40-50 min)
        core_mins = random.randint(35, 45)
        core_start = current_time
        core_end = current_time + timedelta(minutes=core_mins)
        event_id = str(uuid.uuid4())
        entries.extend([
            (USER_ID, 'DEF_CORE_SLEEP_START', date, core_start, None, None, core_start, 'healthkit', event_id),
            (USER_ID, 'DEF_CORE_SLEEP_END', date, core_end, None, None, core_end, 'healthkit', event_id)
        ])
        current_time = core_end

        # REM sleep (5-10 min early, 20-30 min later)
        if cycle >= 3:
            rem_mins = random.randint(20, 30)
        else:
            rem_mins = random.randint(5, 15)

        rem_start = current_time
        rem_end = current_time + timedelta(minutes=rem_mins)
        event_id = str(uuid.uuid4())
        entries.extend([
            (USER_ID, 'DEF_REM_SLEEP_START', date, rem_start, None, None, rem_start, 'healthkit', event_id),
            (USER_ID, 'DEF_REM_SLEEP_END', date, rem_end, None, None, rem_end, 'healthkit', event_id)
        ])
        current_time = rem_end

        # Occasional awake period
        if random.random() < 0.3:
            awake_mins = random.randint(1, 3)
            awake_start = current_time
            awake_end = current_time + timedelta(minutes=awake_mins)
            event_id = str(uuid.uuid4())
            entries.extend([
                (USER_ID, 'DEF_AWAKE_PERIODS_START', date, awake_start, None, None, awake_start, 'healthkit', event_id),
                (USER_ID, 'DEF_AWAKE_PERIODS_END', date, awake_end, None, None, awake_end, 'healthkit', event_id)
            ])
            current_time = awake_end

    return entries

def generate_cardio_entries(conn, date):
    """Generate cardio workout (every other day)"""
    if date.day % 2 != 0:  # Every other day
        return []

    entries = []
    event_id = str(uuid.uuid4())

    # Morning run: 7:00 AM
    start_time = datetime.combine(date, datetime.min.time()).replace(hour=7, minute=0)
    duration = random.randint(25, 45)  # 25-45 minutes
    end_time = start_time + timedelta(minutes=duration)

    cardio_types = ['running', 'cycling', 'swimming', 'walking']
    cardio_type = random.choice(cardio_types)
    distance_km = random.uniform(3.0, 8.0)
    calories = int(duration * random.uniform(8, 12))  # ~8-12 cal/min

    entries.extend([
        (USER_ID, 'DEF_CARDIO_START', date, start_time, None, None, start_time, 'manual', event_id),
        (USER_ID, 'DEF_CARDIO_END', date, end_time, None, None, end_time, 'manual', event_id),
        (USER_ID, 'DEF_CARDIO_TYPE', date, start_time, None, cardio_type, None, 'manual', event_id),
        (USER_ID, 'DEF_CARDIO_DISTANCE_KM', date, start_time, distance_km, None, None, 'manual', event_id),
        (USER_ID, 'DEF_CARDIO_CALORIES', date, start_time, calories, None, None, 'auto_calculated', event_id),
        (USER_ID, 'DEF_CARDIO_INTENSITY', date, start_time, random.randint(6, 9), None, None, 'manual', event_id),
    ])

    return entries

def generate_weight_entries(conn, date):
    """Generate weight entry (every 3 days)"""
    if date.day % 3 != 0:
        return []

    entries = []
    event_id = str(uuid.uuid4())

    # Morning weight: 6:45 AM
    timestamp = datetime.combine(date, datetime.min.time()).replace(hour=6, minute=45)

    # Gradually decreasing weight (185 -> 180 lbs over 30 days)
    days_ago = (datetime.now().date() - date).days
    base_weight = 185 - (days_ago * 0.15)
    weight_kg = (base_weight + random.uniform(-0.5, 0.5)) * 0.453592  # lbs to kg

    entries.append((
        USER_ID, 'DEF_WEIGHT', date, timestamp,
        round(weight_kg, 1), None, None, 'manual', event_id
    ))

    return entries

def generate_water_entries(conn, date):
    """Generate water intake throughout the day"""
    entries = []

    # 5-8 water entries per day
    num_entries = random.randint(5, 8)

    for _ in range(num_entries):
        event_id = str(uuid.uuid4())
        hour = random.randint(7, 21)
        minute = random.randint(0, 59)
        timestamp = datetime.combine(date, datetime.min.time()).replace(hour=hour, minute=minute)

        # 8-16 oz per entry
        oz = random.randint(8, 16)
        ml = oz * 29.5735

        entries.append((
            USER_ID, 'DEF_WATER_QUANTITY', date, timestamp,
            round(ml, 0), None, None, 'manual', event_id
        ))

    return entries

def generate_fiber_entries(conn, date):
    """Generate fiber intake with meals"""
    entries = []
    meal_times = [(8, 0), (12, 30), (18, 30)]

    fiber_sources = ['vegetables', 'fruits', 'whole_grains', 'legumes']

    for hour, minute in meal_times:
        if random.random() < 0.8:  # 80% chance of fiber with meal
            event_id = str(uuid.uuid4())
            timestamp = datetime.combine(date, datetime.min.time()).replace(hour=hour, minute=minute)
            grams = random.randint(4, 12)

            entries.extend([
                (USER_ID, 'DEF_FIBER_GRAMS', date, timestamp, grams, None, None, 'manual', event_id),
                (USER_ID, 'DEF_FIBER_SOURCE', date, timestamp, None, random.choice(fiber_sources), None, 'manual', event_id),
                (USER_ID, 'DEF_FIBER_TIME', date, timestamp, None, None, timestamp, 'manual', event_id),
            ])

    return entries

def generate_steps_entries(conn, date):
    """Generate daily step count"""
    entries = []
    event_id = str(uuid.uuid4())
    timestamp = datetime.combine(date, datetime.min.time()).replace(hour=23, minute=59)

    steps = random.randint(6000, 12000)

    entries.append((
        USER_ID, 'DEF_STEPS', date, timestamp,
        steps, None, None, 'healthkit', event_id
    ))

    return entries

def main():
    print(f"🚀 Generating Comprehensive Test Data")
    print(f"User ID: {USER_ID}")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        with conn.cursor() as cur:
            # Generate data for past 30 days
            end_date = datetime.now().date()
            start_date = end_date - timedelta(days=30)

            all_entries = []

            for day_offset in range(30):
                current_date = start_date + timedelta(days=day_offset)

                # Generate all types of data for this day
                all_entries.extend(generate_protein_entries(conn, current_date))
                all_entries.extend(generate_sleep_entries(conn, current_date))
                all_entries.extend(generate_cardio_entries(conn, current_date))
                all_entries.extend(generate_weight_entries(conn, current_date))
                all_entries.extend(generate_water_entries(conn, current_date))
                all_entries.extend(generate_fiber_entries(conn, current_date))
                all_entries.extend(generate_steps_entries(conn, current_date))

            print(f"\n📝 Inserting {len(all_entries):,} data entries...")

            # Batch insert
            cur.executemany("""
                INSERT INTO patient_data_entries (
                    patient_id, field_id, entry_date, entry_timestamp,
                    value_quantity, value_reference, value_timestamp,
                    source, event_instance_id
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT DO NOTHING
            """, all_entries)

            conn.commit()

            print(f"✅ Inserted {cur.rowcount:,} entries")

            # Summary by field
            print("\n📊 Entries Created by Category:")
            print("-" * 60)

            cur.execute("""
                SELECT
                    CASE
                        WHEN field_id LIKE '%PROTEIN%' THEN 'Protein'
                        WHEN field_id LIKE '%SLEEP%' OR field_id LIKE '%AWAKE%' THEN 'Sleep'
                        WHEN field_id LIKE '%CARDIO%' THEN 'Cardio'
                        WHEN field_id LIKE '%WEIGHT%' THEN 'Weight'
                        WHEN field_id LIKE '%WATER%' THEN 'Water'
                        WHEN field_id LIKE '%FIBER%' THEN 'Fiber'
                        WHEN field_id LIKE '%STEPS%' THEN 'Steps'
                        ELSE 'Other'
                    END as category,
                    COUNT(*) as count
                FROM patient_data_entries
                WHERE patient_id = %s
                GROUP BY category
                ORDER BY count DESC
            """, (USER_ID,))

            for row in cur.fetchall():
                print(f"  {row[0]:15} | {row[1]:,} entries")

            print("\n" + "=" * 60)
            print("✅ COMPLETE! Test data generated for 30 days")
            print("=" * 60)
            print("\n🔧 Next step: Process aggregations")
            print("   python3 scripts/process_all_aggregations_for_user.py")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
