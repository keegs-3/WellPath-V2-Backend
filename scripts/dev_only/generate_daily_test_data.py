"""
Generate Daily Activity Test Data
Inserts raw data into patient_data_entries table
"""

import psycopg2
from datetime import datetime, timedelta
import random
import uuid

# Database connection
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

# Test patient (has existing onboarding data)
TEST_USER_ID = "1758fa60-a306-440e-8ae6-9e68fd502bc2"

# Generate data for last 30 days
END_DATE = datetime.now().date()
START_DATE = END_DATE - timedelta(days=29)


def generate_sleep_data():
    """Generate sleep session data (bedtime, waketime, quality)"""
    print("\n" + "="*80)
    print("Generating Sleep Data")
    print("="*80)

    entries = []
    current_date = START_DATE

    while current_date <= END_DATE:
        # Bedtime between 9 PM and 1 AM
        bedtime_hour = random.randint(21, 25) % 24
        bedtime_minute = random.randint(0, 59)
        bedtime = datetime.combine(current_date, datetime.min.time()).replace(
            hour=bedtime_hour, minute=bedtime_minute
        )

        # Sleep duration between 6-9 hours
        sleep_minutes = random.randint(360, 540)
        waketime = bedtime + timedelta(minutes=sleep_minutes)

        # Sleep quality rating 1-5
        quality = random.randint(3, 5)

        # Bedtime entry
        entries.append({
            'user_id': TEST_USER_ID,
            'field_id': 'DEF_SLEEP_BEDTIME',
            'entry_date': current_date.isoformat(),
            'value_timestamp': bedtime.isoformat(),
            'source': 'manual'
        })

        # Waketime entry
        entries.append({
            'user_id': TEST_USER_ID,
            'field_id': 'DEF_SLEEP_WAKETIME',
            'entry_date': waketime.date().isoformat(),
            'value_timestamp': waketime.isoformat(),
            'source': 'test_data'
        })

        # Sleep quality entry
        entries.append({
            'user_id': TEST_USER_ID,
            'field_id': 'DEF_SLEEP_QUALITY',
            'entry_date': current_date.isoformat(),
            'value_rating': quality,
            'source': 'test_data'
        })

        current_date += timedelta(days=1)

    print(f"  Generated {len(entries)} sleep-related entries ({len(entries)//3} nights)")
    return entries


def generate_steps_data():
    """Generate daily step counts"""
    print("\n" + "="*80)
    print("Generating Steps Data")
    print("="*80)

    entries = []
    current_date = START_DATE

    while current_date <= END_DATE:
        # Steps between 3000-15000
        steps = random.randint(3000, 15000)

        entries.append({
            'user_id': TEST_USER_ID,
            'field_id': 'DEF_STEPS',
            'entry_date': current_date.isoformat(),
            'value_quantity': steps,
            'source': 'test_data'
        })

        current_date += timedelta(days=1)

    print(f"  Generated {len(entries)} daily step records")
    return entries


def generate_cardio_data():
    """Generate cardio workout sessions (3-5 per week)"""
    print("\n" + "="*80)
    print("Generating Cardio Data")
    print("="*80)

    entries = []
    current_date = START_DATE

    while current_date <= END_DATE:
        # 60% chance of workout on any given day
        if random.random() < 0.6:
            # Start time between 6 AM and 7 PM
            start_hour = random.randint(6, 19)
            start_minute = random.randint(0, 59)
            start_time = datetime.combine(current_date, datetime.min.time()).replace(
                hour=start_hour, minute=start_minute
            )

            # Duration between 20-60 minutes
            duration = random.randint(20, 60)
            end_time = start_time + timedelta(minutes=duration)

            # Distance between 2-8 km
            distance = round(random.uniform(2.0, 8.0), 2)

            # Cardio start time
            entries.append({
                'user_id': TEST_USER_ID,
                'field_id': 'DEF_CARDIO_START_TIME',
                'entry_date': current_date.isoformat(),
                'value_timestamp': start_time.isoformat(),
                'source': 'test_data'
            })

            # Cardio end time
            entries.append({
                'user_id': TEST_USER_ID,
                'field_id': 'DEF_CARDIO_END_TIME',
                'entry_date': current_date.isoformat(),
                'value_timestamp': end_time.isoformat(),
                'source': 'test_data'
            })

            # Cardio distance
            entries.append({
                'user_id': TEST_USER_ID,
                'field_id': 'DEF_CARDIO_DISTANCE',
                'entry_date': current_date.isoformat(),
                'value_quantity': distance,
                'source': 'test_data'
            })

        current_date += timedelta(days=1)

    print(f"  Generated {len(entries)} cardio-related entries ({len(entries)//3} sessions)")
    return entries


def insert_data(conn, all_entries):
    """Insert all entries into patient_data_entries"""
    print("\n" + "="*80)
    print("INSERTING DATA")
    print("="*80)

    cur = conn.cursor()

    try:
        print(f"Inserting {len(all_entries)} data entries...")

        for entry in all_entries:
            # Build column list and values based on what's in the entry
            columns = ['id', 'user_id', 'field_id', 'entry_date', 'source']
            values = [str(uuid.uuid4()), entry['user_id'], entry['field_id'],
                     entry['entry_date'], entry['source']]

            # Add optional columns
            if 'value_quantity' in entry:
                columns.append('value_quantity')
                values.append(entry['value_quantity'])
            if 'value_rating' in entry:
                columns.append('value_rating')
                values.append(entry['value_rating'])
            if 'value_timestamp' in entry:
                columns.append('value_timestamp')
                values.append(entry['value_timestamp'])

            placeholders = ', '.join(['%s'] * len(values))
            sql = f"INSERT INTO patient_data_entries ({', '.join(columns)}) VALUES ({placeholders})"

            cur.execute(sql, values)

        conn.commit()
        print(f"✓ Inserted {len(all_entries)} data entries")

    except Exception as e:
        print(f"\n❌ Error inserting data: {e}")
        conn.rollback()
        raise
    finally:
        cur.close()


def main():
    print("="*80)
    print("DAILY ACTIVITY TEST DATA GENERATOR")
    print("="*80)
    print(f"User ID: {TEST_USER_ID}")
    print(f"Date Range: {START_DATE} to {END_DATE}")
    print()

    # Connect to database
    conn = psycopg2.connect(**DB_CONFIG)

    # Generate all data
    sleep_entries = generate_sleep_data()
    steps_entries = generate_steps_data()
    cardio_entries = generate_cardio_data()

    # Combine all entries
    all_entries = sleep_entries + steps_entries + cardio_entries

    print("\n" + "="*80)
    print("GENERATION SUMMARY")
    print("="*80)
    print(f"Sleep entries: {len(sleep_entries)}")
    print(f"Steps entries: {len(steps_entries)}")
    print(f"Cardio entries: {len(cardio_entries)}")
    print(f"TOTAL: {len(all_entries)} data entries")

    # Insert all the data
    insert_data(conn, all_entries)

    # Verify
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM patient_data_entries WHERE user_id = %s", (TEST_USER_ID,))
    total = cur.fetchone()[0]
    print(f"\n✅ Total patient_data_entries for user: {total}")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
