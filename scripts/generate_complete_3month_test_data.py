#!/usr/bin/env python3
"""
Generate complete 3 months of test data:
- Protein with type/timing (70%)
- Protein with "other" type (15%)
- Protein unassigned from HealthKit (15%)
- Weight measurements
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

# Patient ID
PATIENT_ID = "8b79ce33-02b8-4f49-8268-3204130efa82"

# Field IDs
PROTEIN_GRAMS_FIELD = "DEF_PROTEIN_GRAMS"
PROTEIN_TYPE_FIELD = "DEF_PROTEIN_TYPE"
PROTEIN_TIMING_FIELD = "DEF_PROTEIN_TIMING"
WEIGHT_FIELD = "DEF_WEIGHT"

# Protein type reference IDs
PROTEIN_TYPES = {
    "Dairy": "7574f34d-01c5-4e5c-8358-10a913af16d1",
    "Eggs": "7d5a944a-385f-425b-8a5f-052d7c3a9147",
    "Fatty Fish": "6d0f6187-3c45-498a-b190-cf194f3eaa3e",
    "Fish": "77e8bdbe-2234-4278-85f2-dee61656133d",
    "Lean Protein": "5ad4687c-295c-49a3-809b-68fb91ff16a4",
    "Plant-based": "6db6cb60-a17e-4463-9987-418a9ffd4a63",
    "Red Meat": "c4dfa241-5692-417a-9d05-0a8fdb2272a1",
    "Other": None  # Will fetch ID
}

# Food timing reference IDs
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

def generate_complete_data():
    """Generate 3 months of complete test data."""
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    cur = conn.cursor()

    try:
        # Get "other" protein type ID
        cur.execute("""
            SELECT id FROM data_entry_fields_reference
            WHERE reference_category = 'protein_types'
            AND reference_key = 'other'
        """)
        other_id = cur.fetchone()[0]
        PROTEIN_TYPES["Other"] = str(other_id)

        print("🗑️  Clearing existing test data...")

        # Disable triggers
        cur.execute("ALTER TABLE patient_data_entries DISABLE TRIGGER auto_process_aggregations_on_insert;")
        cur.execute("ALTER TABLE patient_data_entries DISABLE TRIGGER auto_process_aggregations_on_update;")
        cur.execute("ALTER TABLE patient_data_entries DISABLE TRIGGER auto_process_aggregations_on_delete;")

        # Delete existing data
        cur.execute("""
            DELETE FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id IN (%s, %s, %s, %s)
        """, (PATIENT_ID, PROTEIN_GRAMS_FIELD, PROTEIN_TYPE_FIELD, PROTEIN_TIMING_FIELD, WEIGHT_FIELD))
        print(f"   Deleted {cur.rowcount} existing entries")

        # Delete aggregation cache
        cur.execute("""
            DELETE FROM aggregation_results_cache
            WHERE patient_id = %s
            AND (agg_metric_id LIKE %s OR agg_metric_id LIKE %s)
        """, (PATIENT_ID, 'AGG_PROTEIN%', 'AGG_WEIGHT%'))
        print(f"   Deleted {cur.rowcount} aggregation cache entries")

        conn.commit()

        print("\n📊 Generating 3 months of data...")

        # Date range
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=90)

        entries = []
        current_date = start_date

        # Weight baseline
        base_weight = 75.0
        daily_trend = -0.0055

        while current_date <= end_date:
            day_count = (current_date - start_date).days

            # === WEIGHT DATA (80% of days) ===
            if random.random() < 0.8:
                trend_weight = base_weight + (daily_trend * day_count)
                daily_variation = random.uniform(-0.3, 0.3)
                weight = round(trend_weight + daily_variation, 1)

                hour = random.randint(6, 7)
                minute = random.randint(0, 59)
                entry_timestamp = datetime.combine(
                    current_date,
                    datetime.min.time().replace(hour=hour, minute=minute)
                )

                entries.append((
                    str(uuid.uuid4()),
                    PATIENT_ID,
                    WEIGHT_FIELD,
                    current_date,
                    weight,
                    None, None, None,
                    entry_timestamp,
                    'wellpath_input',
                    None
                ))

            # === PROTEIN DATA ===
            num_meals = random.choices([3, 4, 5], weights=[0.4, 0.4, 0.2])[0]
            meals = random.sample(list(MEAL_TIMES.keys()), num_meals)

            for meal in meals:
                meal_time = MEAL_TIMES[meal]
                entry_timestamp = datetime.combine(current_date, meal_time)

                # Protein amount
                if "snack" in meal:
                    protein_grams = random.randint(10, 20)
                elif meal == "breakfast":
                    protein_grams = random.randint(20, 35)
                else:  # lunch or dinner
                    protein_grams = random.randint(25, 50)

                # Determine entry type: assigned (70%), other (15%), unassigned (15%)
                entry_type = random.choices(
                    ['assigned', 'other', 'unassigned'],
                    weights=[0.70, 0.15, 0.15]
                )[0]

                if entry_type == 'unassigned':
                    # === UNASSIGNED (HealthKit) - just protein grams ===
                    entries.append((
                        str(uuid.uuid4()),
                        PATIENT_ID,
                        PROTEIN_GRAMS_FIELD,
                        current_date,
                        protein_grams,
                        None, None, None,
                        entry_timestamp,
                        'healthkit',
                        None  # No event_instance_id
                    ))

                elif entry_type == 'other':
                    # === OTHER - protein with "other" type and timing ===
                    event_instance_id = str(uuid.uuid4())

                    # Grams
                    entries.append((
                        str(uuid.uuid4()),
                        PATIENT_ID,
                        PROTEIN_GRAMS_FIELD,
                        current_date,
                        protein_grams,
                        None, None, None,
                        entry_timestamp,
                        'wellpath_input',
                        event_instance_id
                    ))

                    # Type = Other
                    entries.append((
                        str(uuid.uuid4()),
                        PATIENT_ID,
                        PROTEIN_TYPE_FIELD,
                        current_date,
                        None,
                        PROTEIN_TYPES["Other"],
                        None, None,
                        entry_timestamp,
                        'wellpath_input',
                        event_instance_id
                    ))

                    # Timing
                    entries.append((
                        str(uuid.uuid4()),
                        PATIENT_ID,
                        PROTEIN_TIMING_FIELD,
                        current_date,
                        None,
                        FOOD_TIMINGS[meal],
                        None, None,
                        entry_timestamp,
                        'wellpath_input',
                        event_instance_id
                    ))

                else:  # assigned
                    # === FULLY ASSIGNED - protein with specific type and timing ===
                    event_instance_id = str(uuid.uuid4())

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
                            PROTEIN_TYPES["Dairy"]
                        ])
                    else:  # lunch or dinner
                        protein_type = random.choice([
                            PROTEIN_TYPES["Lean Protein"],
                            PROTEIN_TYPES["Fish"],
                            PROTEIN_TYPES["Fatty Fish"],
                            PROTEIN_TYPES["Red Meat"],
                            PROTEIN_TYPES["Plant-based"]
                        ])

                    # Grams
                    entries.append((
                        str(uuid.uuid4()),
                        PATIENT_ID,
                        PROTEIN_GRAMS_FIELD,
                        current_date,
                        protein_grams,
                        None, None, None,
                        entry_timestamp,
                        'wellpath_input',
                        event_instance_id
                    ))

                    # Type
                    entries.append((
                        str(uuid.uuid4()),
                        PATIENT_ID,
                        PROTEIN_TYPE_FIELD,
                        current_date,
                        None,
                        protein_type,
                        None, None,
                        entry_timestamp,
                        'wellpath_input',
                        event_instance_id
                    ))

                    # Timing
                    entries.append((
                        str(uuid.uuid4()),
                        PATIENT_ID,
                        PROTEIN_TIMING_FIELD,
                        current_date,
                        None,
                        FOOD_TIMINGS[meal],
                        None, None,
                        entry_timestamp,
                        'wellpath_input',
                        event_instance_id
                    ))

            current_date += timedelta(days=1)

        print(f"   Generated {len(entries)} total entries")

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

        # Re-enable triggers
        print("\n🔄 Re-enabling triggers...")
        cur.execute("ALTER TABLE patient_data_entries ENABLE TRIGGER auto_process_aggregations_on_insert;")
        cur.execute("ALTER TABLE patient_data_entries ENABLE TRIGGER auto_process_aggregations_on_update;")
        cur.execute("ALTER TABLE patient_data_entries ENABLE TRIGGER auto_process_aggregations_on_delete;")
        conn.commit()

        # Verify data
        cur.execute("""
            SELECT
                field_id,
                COUNT(*) as count,
                MIN(entry_date) as first_date,
                MAX(entry_date) as last_date
            FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id IN (%s, %s, %s, %s)
            GROUP BY field_id
            ORDER BY field_id;
        """, (PATIENT_ID, PROTEIN_GRAMS_FIELD, PROTEIN_TYPE_FIELD, PROTEIN_TIMING_FIELD, WEIGHT_FIELD))

        print(f"\n📈 Data Summary:")
        for row in cur.fetchall():
            print(f"   {row[0]}: {row[1]} entries ({row[2]} to {row[3]})")

        print("\n✅ Done! Data inserted with triggers disabled for speed.")
        print("   Run aggregations manually or they'll process on next update.")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    generate_complete_data()
