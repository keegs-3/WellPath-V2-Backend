#!/usr/bin/env python3
"""
Generate a week of realistic protein tracking data
"""

import psycopg2
from datetime import datetime, timedelta
import random
import os

# Read DATABASE_URL from .env file
def read_database_url():
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    with open(env_path) as f:
        for line in f:
            if line.startswith('DATABASE_URL='):
                return line.split('=', 1)[1].strip()
    raise ValueError("DATABASE_URL not found in .env file")

DATABASE_URL = read_database_url()

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Get patient ID
    cur.execute("SELECT id FROM patients LIMIT 1")
    patient_id = cur.fetchone()[0]

    # Get protein reference UUIDs
    cur.execute("""
        SELECT id, reference_key FROM data_entry_fields_reference
        WHERE reference_category = 'protein_type'
    """)
    protein_types = {row[1]: row[0] for row in cur.fetchall()}

    # Get meal timing reference UUIDs
    cur.execute("""
        SELECT id, reference_key FROM data_entry_fields_reference
        WHERE reference_category = 'protein_timing'
    """)
    meal_timings = {row[1]: row[0] for row in cur.fetchall()}

    print("Generating 7 days of protein data...")

    # Generate data for the past 7 days
    today = datetime.now().date()

    for days_ago in range(6, -1, -1):  # 6 days ago to today
        date = today - timedelta(days=days_ago)
        print(f"\nGenerating data for {date}...")

        # Breakfast (7-9 AM)
        breakfast_hour = random.randint(7, 8)
        breakfast_protein = random.choice([
            ('eggs', 25, 'breakfast'),
            ('greek_yogurt', 20, 'breakfast'),
            ('protein_powder_whey', 30, 'breakfast'),
        ])

        breakfast_timestamp = datetime(date.year, date.month, date.day, breakfast_hour, random.randint(0, 59))

        cur.execute("""
            INSERT INTO patient_data_entries (
                patient_id, field_id, value_quantity, value_reference,
                entry_date, entry_timestamp, source
            ) VALUES
            (%s, 'DEF_PROTEIN_GRAMS', %s, NULL, %s, %s, 'manual'),
            (%s, 'DEF_PROTEIN_TYPE', NULL, %s, %s, %s, 'manual'),
            (%s, 'DEF_PROTEIN_TIMING', NULL, %s, %s, %s, 'manual')
        """, (
            patient_id, breakfast_protein[1], date, breakfast_timestamp,
            patient_id, protein_types[breakfast_protein[0]], date, breakfast_timestamp,
            patient_id, meal_timings[breakfast_protein[2]], date, breakfast_timestamp
        ))

        # Lunch (12-2 PM)
        lunch_hour = random.randint(12, 13)
        lunch_protein = random.choice([
            ('lean_poultry', 35, 'lunch'),
            ('fatty_fish', 30, 'lunch'),
            ('lean_beef', 40, 'lunch'),
            ('plant_protein', 25, 'lunch'),
        ])

        lunch_timestamp = datetime(date.year, date.month, date.day, lunch_hour, random.randint(0, 59))

        cur.execute("""
            INSERT INTO patient_data_entries (
                patient_id, field_id, value_quantity, value_reference,
                entry_date, entry_timestamp, source
            ) VALUES
            (%s, 'DEF_PROTEIN_GRAMS', %s, NULL, %s, %s, 'manual'),
            (%s, 'DEF_PROTEIN_TYPE', NULL, %s, %s, %s, 'manual'),
            (%s, 'DEF_PROTEIN_TIMING', NULL, %s, %s, %s, 'manual')
        """, (
            patient_id, lunch_protein[1], date, lunch_timestamp,
            patient_id, protein_types[lunch_protein[0]], date, lunch_timestamp,
            patient_id, meal_timings[lunch_protein[2]], date, lunch_timestamp
        ))

        # Dinner (6-8 PM)
        dinner_hour = random.randint(18, 19)
        dinner_protein = random.choice([
            ('lean_poultry', 40, 'dinner'),
            ('fatty_fish', 35, 'dinner'),
            ('lean_beef', 45, 'dinner'),
            ('red_meat', 40, 'dinner'),
            ('tofu', 25, 'dinner'),
        ])

        dinner_timestamp = datetime(date.year, date.month, date.day, dinner_hour, random.randint(0, 59))

        cur.execute("""
            INSERT INTO patient_data_entries (
                patient_id, field_id, value_quantity, value_reference,
                entry_date, entry_timestamp, source
            ) VALUES
            (%s, 'DEF_PROTEIN_GRAMS', %s, NULL, %s, %s, 'manual'),
            (%s, 'DEF_PROTEIN_TYPE', NULL, %s, %s, %s, 'manual'),
            (%s, 'DEF_PROTEIN_TIMING', NULL, %s, %s, %s, 'manual')
        """, (
            patient_id, dinner_protein[1], date, dinner_timestamp,
            patient_id, protein_types[dinner_protein[0]], date, dinner_timestamp,
            patient_id, meal_timings[dinner_protein[2]], date, dinner_timestamp
        ))

        # Maybe a snack (30% chance)
        if random.random() < 0.3:
            snack_hour = random.randint(15, 16)
            snack_protein = random.choice([
                ('protein_powder_whey', 25, 'snack'),
                ('greek_yogurt', 15, 'snack'),
                ('cottage_cheese', 20, 'snack'),
            ])

            snack_timestamp = datetime(date.year, date.month, date.day, snack_hour, random.randint(0, 59))

            cur.execute("""
                INSERT INTO patient_data_entries (
                    patient_id, field_id, value_quantity, value_reference,
                    entry_date, entry_timestamp, source
                ) VALUES
                (%s, 'DEF_PROTEIN_GRAMS', %s, NULL, %s, %s, 'manual'),
                (%s, 'DEF_PROTEIN_TYPE', NULL, %s, %s, %s, 'manual'),
                (%s, 'DEF_PROTEIN_TIMING', NULL, %s, %s, %s, 'manual')
            """, (
                patient_id, snack_protein[1], date, snack_timestamp,
                patient_id, protein_types[snack_protein[0]], date, snack_timestamp,
                patient_id, meal_timings[snack_protein[2]], date, snack_timestamp
            ))

            print(f"  {date}: {breakfast_protein[1]}g + {lunch_protein[1]}g + {dinner_protein[1]}g + {snack_protein[1]}g = {breakfast_protein[1] + lunch_protein[1] + dinner_protein[1] + snack_protein[1]}g")
        else:
            print(f"  {date}: {breakfast_protein[1]}g + {lunch_protein[1]}g + {dinner_protein[1]}g = {breakfast_protein[1] + lunch_protein[1] + dinner_protein[1]}g")

    conn.commit()

    # Verify
    cur.execute("""
        SELECT
            entry_date,
            SUM(value_quantity) as total_protein
        FROM patient_data_entries
        WHERE field_id = 'DEF_PROTEIN_GRAMS'
          AND source != 'deleted'
        GROUP BY entry_date
        ORDER BY entry_date DESC
        LIMIT 7
    """)

    print("\n" + "="*60)
    print("VERIFICATION - Protein by Day:")
    print("="*60)
    for row in cur.fetchall():
        print(f"  {row[0]}: {row[1]}g")

    cur.close()
    conn.close()

    print("\n✅ Week of protein data generated!")

if __name__ == '__main__':
    main()
