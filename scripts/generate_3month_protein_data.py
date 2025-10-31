#!/usr/bin/env python3
"""
Generate 3 months of protein test data for a patient.
Clears existing protein entries and cache first.
"""

import os
from datetime import datetime, timedelta, time
import random
import psycopg2
from psycopg2.extras import execute_values
import uuid

# Database connection
DB_HOST = "aws-1-us-west-1.pooler.supabase.com"
DB_PORT = "5432"
DB_NAME = "postgres"
DB_USER = "postgres.csotzmardnvrpdhlogjm"
DB_PASSWORD = "pd3Wc7ELL20OZYkE"

# Patient ID - using the test patient
PATIENT_ID = "8b79ce33-02b8-4f49-8268-3204130efa82"

# Protein field IDs
PROTEIN_GRAMS_FIELD = "DEF_PROTEIN_GRAMS"
PROTEIN_TYPE_FIELD = "DEF_PROTEIN_TYPE"
PROTEIN_TIMING_FIELD = "DEF_PROTEIN_TIMING"

# Protein type reference IDs (from data_entry_fields_reference)
PROTEIN_TYPES = {
    "Dairy": "7574f34d-01c5-4e5c-8358-10a913af16d1",
    "Eggs": "7d5a944a-385f-425b-8a5f-052d7c3a9147",
    "Fatty Fish": "6d0f6187-3c45-498a-b190-cf194f3eaa3e",
    "Fish": "77e8bdbe-2234-4278-85f2-dee61656133d",
    "Lean Protein": "5ad4687c-295c-49a3-809b-68fb91ff16a4",
    "Plant-based": "6db6cb60-a17e-4463-9987-418a9ffd4a63",
    "Processed Meat": "1a029726-7fc7-4a26-a073-b3b5f8bed35f",
    "Red Meat": "c4dfa241-5692-417a-9d05-0a8fdb2272a1",
    "Supplement": "44daf8e1-e027-42b7-8801-6546a059df19"
}

# Food timing reference IDs (from data_entry_fields_reference)
FOOD_TIMINGS = {
    "breakfast": "9e2c19a8-b165-48bd-bc50-d8aa2ad00fa2",
    "lunch": "e16ae259-9fb3-4986-b341-e5434b30200d",
    "dinner": "05262414-7e62-4509-8a60-5c28d90f6237",
    "morning_snack": "e9cc7eb2-42ff-44a6-8502-700b6af776a2",
    "afternoon_snack": "cf7bf007-d40d-4507-b428-966ce061f584",
    "evening_snack": "e1e74454-3eb5-43e6-8387-712345ddf968"
}

# Meal times
MEAL_TIMES = {
    "breakfast": time(7, 30),
    "lunch": time(12, 30),
    "dinner": time(18, 30),
    "morning_snack": time(10, 0),
    "afternoon_snack": time(15, 0),
    "evening_snack": time(20, 0)
}

def generate_protein_data():
    """Generate 3 months of realistic protein data."""
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    cur = conn.cursor()

    try:
        print("🗑️  Clearing existing protein data...")

        # Temporarily disable triggers to avoid timeouts
        cur.execute("ALTER TABLE patient_data_entries DISABLE TRIGGER auto_process_aggregations_on_insert;")
        cur.execute("ALTER TABLE patient_data_entries DISABLE TRIGGER auto_process_aggregations_on_update;")
        cur.execute("ALTER TABLE patient_data_entries DISABLE TRIGGER auto_process_aggregations_on_delete;")

        # Delete existing protein entries
        cur.execute("""
            DELETE FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id IN (%s, %s, %s)
        """, (PATIENT_ID, PROTEIN_GRAMS_FIELD, PROTEIN_TYPE_FIELD, PROTEIN_TIMING_FIELD))
        deleted_entries = cur.rowcount
        print(f"   Deleted {deleted_entries} existing protein entries")

        # Delete protein aggregation cache
        cur.execute("""
            DELETE FROM aggregation_results_cache
            WHERE patient_id = %s
            AND agg_metric_id LIKE %s
        """, (PATIENT_ID, 'AGG_PROTEIN%'))
        deleted_cache = cur.rowcount
        print(f"   Deleted {deleted_cache} aggregation cache entries")

        # Re-enable triggers
        cur.execute("ALTER TABLE patient_data_entries ENABLE TRIGGER auto_process_aggregations_on_insert;")
        cur.execute("ALTER TABLE patient_data_entries ENABLE TRIGGER auto_process_aggregations_on_update;")
        cur.execute("ALTER TABLE patient_data_entries ENABLE TRIGGER auto_process_aggregations_on_delete;")

        conn.commit()

        print("\n📊 Generating 3 months of protein data...")

        # Generate data for last 90 days
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=90)

        entries = []
        current_date = start_date

        while current_date <= end_date:
            # Generate 3-5 protein entries per day (breakfast, lunch, dinner, maybe 1-2 snacks)
            num_meals = random.choices([3, 4, 5], weights=[0.4, 0.4, 0.2])[0]
            meals = random.sample(list(MEAL_TIMES.keys()), num_meals)

            for meal in meals:
                meal_time = MEAL_TIMES[meal]
                entry_timestamp = datetime.combine(current_date, meal_time)

                # Generate protein amount (15-50g per meal)
                if "snack" in meal:
                    protein_grams = random.randint(10, 20)
                elif meal == "breakfast":
                    protein_grams = random.randint(20, 35)
                else:  # lunch or dinner
                    protein_grams = random.randint(25, 50)

                # Choose protein type based on meal
                if meal == "breakfast":
                    protein_type = random.choice([
                        PROTEIN_TYPES["Eggs"],
                        PROTEIN_TYPES["Dairy"],
                        PROTEIN_TYPES["Plant-based"]
                    ])
                elif "snack" in meal:
                    protein_type = random.choice([
                        PROTEIN_TYPES["Plant-based"],
                        PROTEIN_TYPES["Dairy"],
                        PROTEIN_TYPES["Supplement"]
                    ])
                else:  # lunch or dinner
                    protein_type = random.choice([
                        PROTEIN_TYPES["Lean Protein"],
                        PROTEIN_TYPES["Fish"],
                        PROTEIN_TYPES["Fatty Fish"],
                        PROTEIN_TYPES["Red Meat"],
                        PROTEIN_TYPES["Plant-based"]
                    ])

                # Create event instance ID to link grams and type
                event_instance_id = str(uuid.uuid4())

                # Protein grams entry
                entries.append((
                    str(uuid.uuid4()),
                    PATIENT_ID,
                    PROTEIN_GRAMS_FIELD,
                    current_date,
                    protein_grams,
                    None,  # value_reference
                    None,  # value_text
                    None,  # value_boolean
                    entry_timestamp,
                    'wellpath_input',
                    event_instance_id
                ))

                # Protein type entry
                entries.append((
                    str(uuid.uuid4()),
                    PATIENT_ID,
                    PROTEIN_TYPE_FIELD,
                    current_date,
                    None,  # value_quantity
                    protein_type,  # value_reference
                    None,  # value_text
                    None,  # value_boolean
                    entry_timestamp,
                    'wellpath_input',
                    event_instance_id
                ))

                # Protein timing entry
                entries.append((
                    str(uuid.uuid4()),
                    PATIENT_ID,
                    PROTEIN_TIMING_FIELD,
                    current_date,
                    None,  # value_quantity
                    FOOD_TIMINGS[meal],  # value_reference
                    None,  # value_text
                    None,  # value_boolean
                    entry_timestamp,
                    'wellpath_input',
                    event_instance_id
                ))

            current_date += timedelta(days=1)

        print(f"   Generated {len(entries)} entries ({len(entries)//3} protein meals)")

        # Insert all entries
        print("\n💾 Inserting data...")
        execute_values(
            cur,
            """
            INSERT INTO patient_data_entries (
                id, patient_id, field_id, entry_date,
                value_quantity, value_reference, value_text, value_boolean,
                entry_timestamp, source, event_instance_id
            ) VALUES %s
            """,
            entries
        )

        conn.commit()
        print(f"   ✅ Inserted {len(entries)} entries")

        # Verify data
        cur.execute("""
            SELECT
                COUNT(*) as total_entries,
                COUNT(DISTINCT entry_date) as days_with_data,
                MIN(entry_date) as first_date,
                MAX(entry_date) as last_date
            FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id IN (%s, %s, %s)
        """, (PATIENT_ID, PROTEIN_GRAMS_FIELD, PROTEIN_TYPE_FIELD, PROTEIN_TIMING_FIELD))

        stats = cur.fetchone()
        print(f"\n📈 Data Summary:")
        print(f"   Total entries: {stats[0]}")
        print(f"   Days with data: {stats[1]}")
        print(f"   Date range: {stats[2]} to {stats[3]}")

        print("\n✅ Done! Aggregations will auto-process via triggers.")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    generate_protein_data()
