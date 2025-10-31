#!/usr/bin/env python3
"""
Generate Hourly Protein Test Data
Creates protein entries at various hours throughout the day
"""

import psycopg2
from datetime import datetime, timedelta
import random

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
USER_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'

# Protein types
PROTEIN_TYPES = [
    'fatty_fish',
    'lean_protein',
    'plant_based',
    'processed_meat',
    'red_meat',
    'supplement'
]

# Typical meal times with variations
MEAL_HOURS = [
    (7, 9, 'breakfast'),   # Breakfast 7-9am
    (12, 14, 'lunch'),     # Lunch 12-2pm
    (18, 20, 'dinner'),    # Dinner 6-8pm
]

def generate_protein_data(start_date, num_days=31):
    """Generate protein data with hourly distribution"""

    conn = psycopg2.connect(DB_URL)
    entries_created = 0

    try:
        with conn.cursor() as cur:
            for day_offset in range(num_days):
                current_date = start_date + timedelta(days=day_offset)

                # Generate 3 meals per day
                for hour_start, hour_end, meal_time in MEAL_HOURS:
                    # Random hour within meal time window
                    hour = random.randint(hour_start, hour_end)

                    # Random protein amount (15-45 grams)
                    protein_grams = random.randint(15, 45)

                    # Random protein type
                    protein_type = random.choice(PROTEIN_TYPES)

                    # Create timestamp
                    entry_timestamp = current_date.replace(hour=hour, minute=random.randint(0, 59))

                    # Insert protein grams (only value_quantity)
                    cur.execute("""
                        INSERT INTO patient_data_entries (
                            patient_id,
                            field_id,
                            value_quantity,
                            entry_date,
                            entry_timestamp,
                            source
                        ) VALUES (%s, %s, %s, %s, %s, %s)
                    """, (
                        USER_ID,
                        'DEF_PROTEIN_GRAMS',
                        protein_grams,
                        current_date.date(),
                        entry_timestamp,
                        'manual'
                    ))
                    entries_created += 1

                    # Insert protein type
                    cur.execute("""
                        INSERT INTO patient_data_entries (
                            patient_id,
                            field_id,
                            value_reference,
                            entry_date,
                            entry_timestamp,
                            source
                        ) VALUES (%s, %s, %s, %s, %s, %s)
                    """, (
                        USER_ID,
                        'DEF_PROTEIN_TYPE',
                        protein_type,
                        current_date.date(),
                        entry_timestamp,
                        'manual'
                    ))
                    entries_created += 1

                    # Insert protein time (meal time)
                    cur.execute("""
                        INSERT INTO patient_data_entries (
                            patient_id,
                            field_id,
                            value_reference,
                            entry_date,
                            entry_timestamp,
                            source
                        ) VALUES (%s, %s, %s, %s, %s, %s)
                    """, (
                        USER_ID,
                        'DEF_PROTEIN_TIME',
                        meal_time,
                        current_date.date(),
                        entry_timestamp,
                        'manual'
                    ))
                    entries_created += 1

            conn.commit()

            # Verify data
            cur.execute("""
                SELECT
                    COUNT(*) as total,
                    COUNT(DISTINCT entry_date) as days,
                    COUNT(DISTINCT DATE_PART('hour', entry_timestamp)) as unique_hours
                FROM patient_data_entries
                WHERE patient_id = %s
                  AND field_id = 'DEF_PROTEIN_GRAMS'
            """, (USER_ID,))

            total, days, unique_hours = cur.fetchone()

            print(f"✅ Created {entries_created} protein data entries")
            print(f"   • {total} protein entries")
            print(f"   • {days} days")
            print(f"   • {unique_hours} unique hours")

            # Show sample
            cur.execute("""
                SELECT
                    entry_date,
                    DATE_PART('hour', entry_timestamp)::INTEGER as hour,
                    value_quantity,
                    value_reference
                FROM patient_data_entries
                WHERE patient_id = %s
                  AND field_id = 'DEF_PROTEIN_GRAMS'
                ORDER BY entry_timestamp
                LIMIT 10
            """, (USER_ID,))

            print("\nSample entries:")
            for row in cur.fetchall():
                print(f"   {row[0]} {row[1]:02d}:00 - {row[2]}g ({row[3]})")

    finally:
        conn.close()

if __name__ == '__main__':
    print("🥩 Generating Hourly Protein Test Data")
    print("=" * 60)

    start_date = datetime(2025, 9, 24)
    generate_protein_data(start_date, num_days=31)

    print("\n" + "=" * 60)
    print("✅ Data generation complete!")
