#!/usr/bin/env python3
"""
Generate Massive Synthetic Test Data
Creates comprehensive health data for the past 30 days
"""

import os
import psycopg2
from datetime import datetime, timedelta
import random
import uuid

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:6543/postgres'
USER_ID = '1758fa60-a306-440e-8ae6-9e68fd502bc2'  # test@wellpath.dev

# Protein types
PROTEIN_TYPES = [
    'TYPE_PLANT_BASED',
    'TYPE_LEAN_PROTEIN',
    'TYPE_FATTY_FISH',
    'TYPE_RED_MEAT',
    'TYPE_PROCESSED_MEAT',
    'TYPE_SUPPLEMENT'
]

def generate_protein_data(conn, days=30):
    """Generate protein intake data - 3 meals per day"""
    print("\n🥩 Generating Protein Data...")

    entries = []
    start_date = datetime.now() - timedelta(days=days)

    for day_offset in range(days):
        current_datetime = start_date + timedelta(days=day_offset)
        current_date = current_datetime.date()

        # Breakfast (6-9am): 15-35g
        breakfast_time = current_datetime.replace(hour=random.randint(6, 9), minute=random.randint(0, 59))
        breakfast_protein = round(random.uniform(15, 35), 1)
        breakfast_type = random.choice(PROTEIN_TYPES)

        entries.append({
            'date': current_date,
            'timestamp': breakfast_time,
            'field': 'DEF_PROTEIN_GRAMS',
            'value': breakfast_protein,
            'type': breakfast_type
        })

        # Lunch (11am-2pm): 20-45g
        lunch_time = current_datetime.replace(hour=random.randint(11, 14), minute=random.randint(0, 59))
        lunch_protein = round(random.uniform(20, 45), 1)
        lunch_type = random.choice(PROTEIN_TYPES)

        entries.append({
            'date': current_date,
            'timestamp': lunch_time,
            'field': 'DEF_PROTEIN_GRAMS',
            'value': lunch_protein,
            'type': lunch_type
        })

        # Dinner (5-8pm): 25-50g
        dinner_time = current_datetime.replace(hour=random.randint(17, 20), minute=random.randint(0, 59))
        dinner_protein = round(random.uniform(25, 50), 1)
        dinner_type = random.choice(PROTEIN_TYPES)

        entries.append({
            'date': current_date,
            'timestamp': dinner_time,
            'field': 'DEF_PROTEIN_GRAMS',
            'value': dinner_protein,
            'type': dinner_type
        })

        # Occasional snack (30% chance): 5-15g
        if random.random() < 0.3:
            snack_time = current_datetime.replace(hour=random.randint(15, 16), minute=random.randint(0, 59))
            snack_protein = round(random.uniform(5, 15), 1)
            snack_type = random.choice(['TYPE_SUPPLEMENT', 'TYPE_PLANT_BASED'])

            entries.append({
                'date': current_date,
                'timestamp': snack_time,
                'field': 'DEF_PROTEIN_GRAMS',
                'value': snack_protein,
                'type': snack_type
            })

    # Insert all entries
    with conn.cursor() as cur:
        for entry in entries:
            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_quantity, source, event_instance_id
                ) VALUES (%s, %s, %s, %s, %s, 'import', %s)
            """, (
                USER_ID,
                entry['field'],
                entry['date'],
                entry['timestamp'],
                entry['value'],
                str(uuid.uuid4())
            ))

            # Add protein type
            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_reference, source, event_instance_id
                ) VALUES (%s, %s, %s, %s, %s, 'import', %s)
            """, (
                USER_ID,
                'DEF_PROTEIN_TYPE',
                entry['date'],
                entry['timestamp'],
                entry['type'],
                str(uuid.uuid4())
            ))

    conn.commit()
    print(f"  ✅ Created {len(entries)} protein entries ({len(entries)*2} total with types)")

def generate_weight_data(conn, days=30):
    """Generate daily weight readings"""
    print("\n⚖️  Generating Weight Data...")

    start_date = datetime.now() - timedelta(days=days)
    entries_created = 0

    # Starting weight with realistic drift
    weight_kg = 75.0

    with conn.cursor() as cur:
        for day_offset in range(days):
            current_datetime = start_date + timedelta(days=day_offset)
            current_date = current_datetime.date()
            morning_time = current_datetime.replace(hour=7, minute=random.randint(0, 30))

            # Weight (slow drift)
            weight_kg += random.uniform(-0.2, 0.2)
            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_quantity, source, event_instance_id
                ) VALUES (%s, 'DEF_WEIGHT_KG', %s, %s, %s, 'healthkit', %s)
            """, (USER_ID, current_date, morning_time, round(weight_kg, 1), str(uuid.uuid4())))
            entries_created += 1

    conn.commit()
    print(f"  ✅ Created {entries_created} weight entries")

def generate_sleep_data(conn, days=30):
    """Generate sleep data"""
    print("\n😴 Generating Sleep Data...")

    start_date = datetime.now() - timedelta(days=days)
    entries_created = 0

    with conn.cursor() as cur:
        for day_offset in range(days):
            current_datetime = start_date + timedelta(days=day_offset)
            current_date = current_datetime.date()

            # Sleep session times
            bedtime = (current_datetime - timedelta(days=1)).replace(hour=22, minute=random.randint(0, 59))
            waketime = current_datetime.replace(hour=random.randint(6, 8), minute=random.randint(0, 59))

            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_timestamp, source, event_instance_id
                ) VALUES (%s, 'DEF_SLEEP_BEDTIME', %s, %s, %s, 'healthkit', %s)
            """, (USER_ID, current_date, bedtime, bedtime, str(uuid.uuid4())))

            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_timestamp, source, event_instance_id
                ) VALUES (%s, 'DEF_SLEEP_WAKETIME', %s, %s, %s, 'healthkit', %s)
            """, (USER_ID, current_date, waketime, waketime, str(uuid.uuid4())))
            entries_created += 2

    conn.commit()
    print(f"  ✅ Created {entries_created} sleep entries")

def generate_exercise_data(conn, days=30):
    """Generate exercise/activity data"""
    print("\n🏃 Generating Exercise Data...")

    start_date = datetime.now() - timedelta(days=days)
    entries_created = 0

    CARDIO_TYPES = ['TYPE_RUNNING', 'TYPE_CYCLING', 'TYPE_SWIMMING', 'TYPE_WALKING']
    STRENGTH_TYPES = ['TYPE_WEIGHTLIFTING', 'TYPE_BODYWEIGHT', 'TYPE_RESISTANCE_BANDS']

    with conn.cursor() as cur:
        for day_offset in range(days):
            current_datetime = start_date + timedelta(days=day_offset)
            current_date = current_datetime.date()

            # Cardio (5 days a week) - use start/end times
            if day_offset % 7 < 5:
                start_time = current_datetime.replace(hour=random.randint(6, 18), minute=random.randint(0, 59))
                end_time = start_time + timedelta(minutes=random.randint(20, 60))
                cardio_type = random.choice(CARDIO_TYPES)

                cur.execute("""
                    INSERT INTO patient_data_entries (
                        user_id, field_id, entry_date, entry_timestamp,
                        value_timestamp, source, event_instance_id
                    ) VALUES (%s, 'DEF_CARDIO_START', %s, %s, %s, 'healthkit', %s)
                """, (USER_ID, current_date, start_time, start_time, str(uuid.uuid4())))

                cur.execute("""
                    INSERT INTO patient_data_entries (
                        user_id, field_id, entry_date, entry_timestamp,
                        value_timestamp, source, event_instance_id
                    ) VALUES (%s, 'DEF_CARDIO_END', %s, %s, %s, 'healthkit', %s)
                """, (USER_ID, current_date, end_time, end_time, str(uuid.uuid4())))

                cur.execute("""
                    INSERT INTO patient_data_entries (
                        user_id, field_id, entry_date, entry_timestamp,
                        value_reference, source, event_instance_id
                    ) VALUES (%s, 'DEF_CARDIO_TYPE', %s, %s, %s, 'healthkit', %s)
                """, (USER_ID, current_date, start_time, cardio_type, str(uuid.uuid4())))
                entries_created += 3

            # Daily steps
            steps = random.randint(4000, 15000)
            steps_time = current_datetime.replace(hour=23, minute=30)
            cur.execute("""
                INSERT INTO patient_data_entries (
                    user_id, field_id, entry_date, entry_timestamp,
                    value_quantity, source, event_instance_id
                ) VALUES (%s, 'DEF_STEPS', %s, %s, %s, 'healthkit', %s)
            """, (USER_ID, current_date, steps_time, steps, str(uuid.uuid4())))
            entries_created += 1

    conn.commit()
    print(f"  ✅ Created {entries_created} exercise entries")

def generate_water_intake(conn, days=30):
    """Generate water intake data"""
    print("\n💧 Generating Water Intake Data...")

    start_date = datetime.now() - timedelta(days=days)
    entries_created = 0

    with conn.cursor() as cur:
        for day_offset in range(days):
            current_datetime = start_date + timedelta(days=day_offset)
            current_date = current_datetime.date()

            # 4-8 water entries per day
            num_drinks = random.randint(4, 8)
            for _ in range(num_drinks):
                drink_time = current_datetime.replace(
                    hour=random.randint(7, 21),
                    minute=random.randint(0, 59)
                )
                oz = random.choice([8, 12, 16, 20])  # Common water bottle sizes

                cur.execute("""
                    INSERT INTO patient_data_entries (
                        user_id, field_id, entry_date, entry_timestamp,
                        value_quantity, source, event_instance_id
                    ) VALUES (%s, 'DEF_WATER_QUANTITY', %s, %s, %s, 'manual', %s)
                """, (USER_ID, current_date, drink_time, oz, str(uuid.uuid4())))
                entries_created += 1

    conn.commit()
    print(f"  ✅ Created {entries_created} water intake entries")

def main():
    print("🚀 Generating Massive Test Data")
    print(f"User ID: {USER_ID}")
    print(f"Period: Last 30 days")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Generate all the data
        generate_protein_data(conn, days=30)
        generate_weight_data(conn, days=30)
        generate_sleep_data(conn, days=30)
        generate_exercise_data(conn, days=30)
        generate_water_intake(conn, days=30)

        print("\n" + "=" * 60)
        print("✅ COMPLETE!")
        print("=" * 60)

        # Summary
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    COUNT(*) as total_entries,
                    MIN(entry_date) as first_date,
                    MAX(entry_date) as last_date,
                    COUNT(DISTINCT entry_date) as days_with_data,
                    COUNT(DISTINCT field_id) as unique_fields
                FROM patient_data_entries
                WHERE user_id = %s
            """, (USER_ID,))

            stats = cur.fetchone()

            print(f"\n📊 Summary:")
            print(f"  Total Entries: {stats[0]:,}")
            print(f"  Date Range: {stats[1]} to {stats[2]}")
            print(f"  Days with Data: {stats[3]}")
            print(f"  Unique Fields: {stats[4]}")

            # Top fields
            cur.execute("""
                SELECT field_id, COUNT(*) as count
                FROM patient_data_entries
                WHERE user_id = %s
                GROUP BY field_id
                ORDER BY count DESC
                LIMIT 10
            """, (USER_ID,))

            print(f"\n  Top Fields:")
            for field_id, count in cur.fetchall():
                print(f"    {field_id}: {count:,} entries")

        print("\n🎉 Data generation complete!")
        print("   Aggregations will be auto-processed by the system.")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
