#!/usr/bin/env python3
"""
Generate a Week of Realistic Test Data
Creates varied test data with nulls and outliers for comprehensive testing
"""

import os
import random
from datetime import datetime, timedelta, time
from uuid import uuid4
import psycopg2

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
TEST_USER_ID = '02cc8441-5f01-4634-acfc-59e6f6a5705a'


def insert_entry(cur, user_id, field_id, value, value_type, entry_date, entry_time, event_instance_id):
    """Insert a data entry"""
    entry_timestamp = datetime.combine(entry_date, entry_time)
    metadata = '{"test": true}'

    if value_type == 'quantity':
        cur.execute("""
            INSERT INTO patient_data_entries
            (user_id, field_id, entry_date, entry_timestamp, value_quantity, source, event_instance_id, metadata)
            VALUES (%s, %s, %s, %s, %s, 'manual', %s, %s::jsonb)
        """, (user_id, field_id, entry_date, entry_timestamp, value, event_instance_id, metadata))
    elif value_type == 'timestamp':
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


def generate_week_data():
    """Generate a full week of realistic test data"""
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = False

    try:
        cur = conn.cursor()

        # Clean up old test data
        print("🧹 Cleaning up old test data...")
        cur.execute("""
            DELETE FROM patient_data_entries
            WHERE user_id = %s
            AND metadata->>'test' = 'true'
        """, (TEST_USER_ID,))
        conn.commit()

        print("📅 Generating week of test data...")
        start_date = datetime.now().date() - timedelta(days=7)

        for day_offset in range(7):
            current_date = start_date + timedelta(days=day_offset)
            print(f"\n  Day {day_offset + 1} ({current_date}):")

            # Skip some days randomly (create nulls)
            if random.random() < 0.15:  # 15% chance to skip
                print("    ⏭️  Skipped (null day)")
                continue

            # =====================================================
            # SLEEP DATA
            # =====================================================
            if random.random() < 0.9:  # 90% of days have sleep
                event_id = str(uuid4())

                # Bedtime (with some outliers)
                if random.random() < 0.1:  # 10% outlier - very late
                    bedtime = datetime.combine(current_date, time(2, random.randint(0, 59)))
                else:
                    bedtime = datetime.combine(current_date, time(22, random.randint(0, 59)))

                # Sleep duration 6-9 hours (with outliers)
                if random.random() < 0.1:  # 10% outlier - very short/long
                    sleep_hours = random.choice([4.5, 11])
                else:
                    sleep_hours = 7 + random.uniform(-1, 2)

                waketime = bedtime + timedelta(hours=sleep_hours)

                insert_entry(cur, TEST_USER_ID, 'DEF_SLEEP_BEDTIME', bedtime, 'timestamp',
                           current_date, time(22, 0), event_id)
                insert_entry(cur, TEST_USER_ID, 'DEF_SLEEP_WAKETIME', waketime, 'timestamp',
                           current_date, time(22, 0), event_id)
                insert_entry(cur, TEST_USER_ID, 'DEF_SLEEP_QUALITY', random.randint(1, 5), 'quantity',
                           current_date, time(22, 0), event_id)

                print(f"    😴 Sleep: {sleep_hours:.1f}h ({bedtime.strftime('%H:%M')} - {waketime.strftime('%H:%M')})")

            # =====================================================
            # EXERCISE DATA (with variety)
            # =====================================================
            exercise_types = []

            # Cardio (60% of days)
            if random.random() < 0.6:
                event_id = str(uuid4())
                start_time = datetime.combine(current_date, time(7, random.randint(0, 59)))

                # Duration with outliers
                if random.random() < 0.1:
                    duration_minutes = random.choice([15, 120])  # Very short or very long
                else:
                    duration_minutes = random.randint(30, 60)

                end_time = start_time + timedelta(minutes=duration_minutes)

                insert_entry(cur, TEST_USER_ID, 'DEF_CARDIO_START', start_time, 'timestamp',
                           current_date, time(7, 0), event_id)
                insert_entry(cur, TEST_USER_ID, 'DEF_CARDIO_END', end_time, 'timestamp',
                           current_date, time(7, 0), event_id)
                insert_entry(cur, TEST_USER_ID, 'DEF_CARDIO_DISTANCE', random.uniform(3, 8), 'quantity',
                           current_date, time(7, 0), event_id)

                exercise_types.append(f"Cardio {duration_minutes}min")

            # Strength (40% of days)
            if random.random() < 0.4:
                event_id = str(uuid4())
                start_time = datetime.combine(current_date, time(18, random.randint(0, 59)))
                duration_minutes = random.randint(45, 75)
                end_time = start_time + timedelta(minutes=duration_minutes)

                insert_entry(cur, TEST_USER_ID, 'DEF_STRENGTH_START', start_time, 'timestamp',
                           current_date, time(18, 0), event_id)
                insert_entry(cur, TEST_USER_ID, 'DEF_STRENGTH_END', end_time, 'timestamp',
                           current_date, time(18, 0), event_id)

                exercise_types.append(f"Strength {duration_minutes}min")

            if exercise_types:
                print(f"    💪 Exercise: {', '.join(exercise_types)}")

            # =====================================================
            # NUTRITION DATA
            # =====================================================
            meals = []

            # Protein - realistic daily total (50-150g) broken down by meal
            # Standard: 1 serving = 25g protein
            daily_protein_grams = random.uniform(60, 120)  # Realistic range

            # Outlier: very low or very high
            if random.random() < 0.05:
                daily_protein_grams = random.choice([30, 180])

            # Distribute across meals (breakfast 25%, lunch 35%, dinner 40%)
            meal_times = [
                (time(8, 0), 'breakfast', 0.25),
                (time(12, 30), 'lunch', 0.35),
                (time(18, 30), 'dinner', 0.40)
            ]

            protein_types = ['processed_meat', 'red_meat', 'fatty_fish', 'lean_protein', 'plant_based', 'supplement']
            total_protein_logged = 0

            for meal_time, meal_name, fraction in meal_times:
                if random.random() < 0.85:  # 85% chance to have protein at each meal
                    event_id = str(uuid4())
                    meal_protein = daily_protein_grams * fraction * random.uniform(0.8, 1.2)  # Add variation

                    # Choose protein type (bias toward lean_protein and plant_based)
                    type_weights = [0.10, 0.15, 0.15, 0.35, 0.20, 0.05]  # processed, red, fatty_fish, lean, plant, supplement
                    protein_type = random.choices(protein_types, weights=type_weights)[0]

                    insert_entry(cur, TEST_USER_ID, 'DEF_PROTEIN_GRAMS', meal_protein, 'quantity',
                               current_date, meal_time, event_id)
                    insert_entry(cur, TEST_USER_ID, 'DEF_PROTEIN_TYPE', protein_type, 'reference',
                               current_date, meal_time, event_id)

                    total_protein_logged += meal_protein

            protein_servings = total_protein_logged / 25  # Convert to servings

            # Vegetables (3-5 servings)
            veg_servings = random.randint(3, 5)
            if random.random() < 0.1:  # Outlier: very low or very high
                veg_servings = random.choice([1, 8])

            event_id = str(uuid4())
            insert_entry(cur, TEST_USER_ID, 'DEF_VEGETABLE_QUANTITY', veg_servings, 'quantity',
                       current_date, time(12, 0), event_id)

            # Water (6-10 cups)
            water_oz = random.randint(48, 80)  # fl oz
            if random.random() < 0.1:  # Outlier: dehydrated or overhydrated
                water_oz = random.choice([24, 120])

            event_id = str(uuid4())
            insert_entry(cur, TEST_USER_ID, 'DEF_WATER_QUANTITY', water_oz, 'quantity',
                       current_date, time(12, 0), event_id)
            insert_entry(cur, TEST_USER_ID, 'DEF_WATER_UNITS', 'fluid_ounce', 'reference',
                       current_date, time(12, 0), event_id)

            print(f"    🥗 Nutrition: {total_protein_logged:.0f}g protein ({protein_servings:.1f} servings), {veg_servings}x veg, {water_oz}oz water")

            # =====================================================
            # BIOMETRICS (measured 2-3x per week)
            # =====================================================
            if random.random() < 0.35:  # ~2-3 days per week
                event_id = str(uuid4())

                # Weight with small variations and occasional outliers
                base_weight = 70  # kg
                if random.random() < 0.05:  # 5% outlier
                    weight = base_weight + random.uniform(-5, 5)
                else:
                    weight = base_weight + random.uniform(-1, 1)

                insert_entry(cur, TEST_USER_ID, 'DEF_WEIGHT', weight, 'quantity',
                           current_date, time(7, 0), event_id)

                # Waist circumference
                waist_cm = random.uniform(75, 85)
                insert_entry(cur, TEST_USER_ID, 'DEF_WAIST_CIRCUMFERENCE', waist_cm, 'quantity',
                           current_date, time(7, 0), event_id)

                print(f"    📊 Biometrics: {weight:.1f}kg, {waist_cm:.1f}cm waist")

            # =====================================================
            # MINDFULNESS/WELLNESS
            # =====================================================
            if random.random() < 0.5:  # 50% of days
                event_id = str(uuid4())
                start_time = datetime.combine(current_date, time(20, random.randint(0, 59)))
                duration_minutes = random.choice([10, 15, 20, 30])
                end_time = start_time + timedelta(minutes=duration_minutes)

                insert_entry(cur, TEST_USER_ID, 'DEF_MINDFULNESS_START', start_time, 'timestamp',
                           current_date, time(20, 0), event_id)
                insert_entry(cur, TEST_USER_ID, 'DEF_MINDFULNESS_END', end_time, 'timestamp',
                           current_date, time(20, 0), event_id)

                print(f"    🧘 Mindfulness: {duration_minutes}min")

        conn.commit()
        print(f"\n✅ Generated 7 days of test data for user {TEST_USER_ID}")
        print(f"   Includes: sleep, exercise, nutrition, biometrics, mindfulness")
        print(f"   With: missing days, outliers, and normal variations")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    generate_week_data()
