#!/usr/bin/env python3
"""
Generate 3 months of weight test data for a patient.
Clears existing weight entries and cache first.
"""

import os
from datetime import datetime, timedelta
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

# Weight field ID
WEIGHT_FIELD = "DEF_WEIGHT"

def generate_weight_data():
    """Generate 3 months of realistic weight data."""
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    cur = conn.cursor()

    try:
        print("🗑️  Clearing existing weight data...")

        # Delete existing weight entries
        cur.execute("""
            DELETE FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id = %s
        """, (PATIENT_ID, WEIGHT_FIELD))
        deleted_entries = cur.rowcount
        print(f"   Deleted {deleted_entries} existing weight entries")

        # Delete weight aggregation cache
        cur.execute("""
            DELETE FROM aggregation_results_cache
            WHERE patient_id = %s
            AND agg_metric_id LIKE %s
        """, (PATIENT_ID, 'AGG_WEIGHT%'))
        deleted_cache = cur.rowcount
        print(f"   Deleted {deleted_cache} aggregation cache entries")

        conn.commit()

        print("\n📊 Generating 3 months of weight data...")

        # Generate data for last 90 days
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=90)

        # Starting weight in kg (let's say 75kg)
        base_weight = 75.0

        # Small trend (losing 0.5kg over 3 months = -0.0055kg per day)
        daily_trend = -0.0055

        entries = []
        current_date = start_date
        day_count = 0

        while current_date <= end_date:
            # Not every day - 80% chance of weighing in
            if random.random() < 0.8:
                # Calculate weight with slight trend
                trend_weight = base_weight + (daily_trend * day_count)

                # Add daily variation (+/- 0.3kg)
                daily_variation = random.uniform(-0.3, 0.3)
                weight = round(trend_weight + daily_variation, 1)

                # Morning weigh-in time (between 6-7am)
                hour = random.randint(6, 7)
                minute = random.randint(0, 59)
                entry_timestamp = datetime.combine(
                    current_date,
                    datetime.min.time().replace(hour=hour, minute=minute)
                )

                entries.append((
                    str(uuid.uuid4()),  # id
                    PATIENT_ID,
                    WEIGHT_FIELD,
                    current_date,
                    weight,  # value_quantity
                    None,  # value_reference
                    None,  # value_text
                    None,  # value_boolean
                    entry_timestamp,
                    'wellpath_input',
                    None  # event_instance_id
                ))

            current_date += timedelta(days=1)
            day_count += 1

        print(f"   Generated {len(entries)} weight entries")

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
                MAX(entry_date) as last_date,
                ROUND(AVG(value_quantity)::numeric, 1) as avg_weight,
                ROUND(MIN(value_quantity)::numeric, 1) as min_weight,
                ROUND(MAX(value_quantity)::numeric, 1) as max_weight
            FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id = %s
        """, (PATIENT_ID, WEIGHT_FIELD))

        stats = cur.fetchone()
        print(f"\n📈 Data Summary:")
        print(f"   Total entries: {stats[0]}")
        print(f"   Days with data: {stats[1]}")
        print(f"   Date range: {stats[2]} to {stats[3]}")
        print(f"   Average weight: {stats[4]} kg")
        print(f"   Weight range: {stats[5]} - {stats[6]} kg")

        print("\n✅ Done! Aggregations will auto-process via triggers.")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    generate_weight_data()
