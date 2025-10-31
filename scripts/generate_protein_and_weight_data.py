#!/usr/bin/env python3
"""
Generate comprehensive protein and weight test data for a patient
"""

import os
import sys
from datetime import datetime, timedelta
import random
import uuid

try:
    import psycopg2
    from psycopg2.extras import execute_values
except ImportError:
    print("Error: psycopg2 not installed. Install with:")
    print("  pip3 install --user psycopg2-binary")
    sys.exit(1)

# Load environment variables from .env file manually
def load_env():
    env_vars = {}
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    if os.path.exists(env_path):
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    return env_vars

env = load_env()

# Database connection
DB_HOST = env.get('DB_HOST', 'aws-1-us-west-1.pooler.supabase.com')
DB_PORT = env.get('DB_PORT', '5432')
DB_NAME = env.get('DB_NAME', 'postgres')
DB_USER = env.get('DB_USER', 'postgres.csotzmardnvrpdhlogjm')
DB_PASSWORD = env.get('DB_PASSWORD')

# Test patient
PATIENT_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'

# Protein timing reference IDs (from data_entry_fields_reference)
TIMING_IDS = {
    'breakfast': 'bc850c14-d245-48b2-817a-7270cfff8ea7',
    'morning_snack': '16a02608-cb25-48f5-9733-67d6b194a0c6',
    'lunch': 'c86c356a-7079-43c7-bb1a-c9eb9226f3aa',
    'afternoon_snack': '881f38a0-46f8-4bb8-84f0-1172e3be4374',
    'dinner': 'ee004dc2-157f-4b02-8593-ff1554efda48',
    'evening_snack': '639c85e5-9243-4e55-920c-3fcb758bc3fc'
}

# Protein type reference IDs
TYPE_IDS = {
    'lean_protein': '5ad4687c-295c-49a3-809b-68fb91ff16a4',
    'fatty_fish': '6d0f6187-3c45-498a-b190-cf194f3eaa3e',
    'plant_based': '6db6cb60-a17e-4463-9987-418a9ffd4a63',
    'eggs': '7d5a944a-385f-425b-8a5f-052d7c3a9147',
    'dairy': '7574f34d-01c5-4e5c-8358-10a913af16d1',
    'red_meat': 'c4dfa241-5692-417a-9d05-0a8fdb2272a1',
    'processed_meat': '1a029726-7fc7-4a26-a073-b3b5f8bed35f',
    'supplement': '44daf8e1-e027-42b7-8801-6546a059df19'
}

def generate_weight_data(days_back=21):
    """Generate daily weight readings with gradual decrease"""
    weights = []
    start_date = datetime.now() - timedelta(days=days_back)

    # Start at 80kg, gradually decrease to ~78.5kg
    base_weight = 80.0
    target_weight = 78.5
    daily_decrease = (base_weight - target_weight) / days_back

    for day in range(days_back + 1):
        date = start_date + timedelta(days=day)
        # Add some random daily fluctuation
        weight = base_weight - (daily_decrease * day) + random.uniform(-0.3, 0.3)
        weight = round(weight, 1)

        weights.append({
            'date': date.date(),
            'timestamp': date.replace(hour=8, minute=0, second=0),  # Morning weigh-in
            'weight': weight
        })

    return weights

def generate_meal_protein(meal_timing, day_number):
    """Generate realistic protein amount and type for a meal"""

    # Meal-specific protein ranges and preferred types
    meal_profiles = {
        'breakfast': {
            'protein_range': (15, 35),
            'types': ['eggs', 'dairy', 'plant_based', 'lean_protein']
        },
        'morning_snack': {
            'protein_range': (5, 15),
            'types': ['dairy', 'plant_based', 'supplement']
        },
        'lunch': {
            'protein_range': (25, 45),
            'types': ['lean_protein', 'fatty_fish', 'plant_based', 'eggs']
        },
        'afternoon_snack': {
            'protein_range': (8, 18),
            'types': ['dairy', 'plant_based', 'supplement']
        },
        'dinner': {
            'protein_range': (30, 50),
            'types': ['lean_protein', 'fatty_fish', 'red_meat', 'plant_based']
        },
        'evening_snack': {
            'protein_range': (5, 12),
            'types': ['dairy', 'plant_based']
        }
    }

    profile = meal_profiles.get(meal_timing, meal_profiles['lunch'])
    protein_amount = round(random.uniform(*profile['protein_range']), 1)
    protein_type = random.choice(profile['types'])

    return protein_amount, protein_type

def generate_protein_data(days_back=21):
    """Generate protein entries for meals throughout the day"""
    protein_entries = []
    start_date = datetime.now() - timedelta(days=days_back)

    meal_times = {
        'breakfast': (7, 9),
        'morning_snack': (10, 11),
        'lunch': (12, 13),
        'afternoon_snack': (15, 16),
        'dinner': (18, 20),
        'evening_snack': (21, 22)
    }

    for day in range(days_back + 1):
        date = start_date + timedelta(days=day)

        # Not every day has every meal/snack
        meals_to_include = ['breakfast', 'lunch', 'dinner']

        # 60% chance of morning snack
        if random.random() < 0.6:
            meals_to_include.append('morning_snack')

        # 70% chance of afternoon snack
        if random.random() < 0.7:
            meals_to_include.append('afternoon_snack')

        # 40% chance of evening snack
        if random.random() < 0.4:
            meals_to_include.append('evening_snack')

        for meal in meals_to_include:
            hour_range = meal_times[meal]
            hour = random.randint(hour_range[0], hour_range[1])
            minute = random.randint(0, 59)

            timestamp = date.replace(hour=hour, minute=minute, second=0)
            protein_amount, protein_type = generate_meal_protein(meal, day)

            protein_entries.append({
                'date': date.date(),
                'timestamp': timestamp,
                'timing': meal,
                'timing_id': TIMING_IDS[meal],
                'protein_amount': protein_amount,
                'protein_type': protein_type,
                'protein_type_id': TYPE_IDS[protein_type]
            })

    return protein_entries

def insert_data(conn):
    """Insert generated data into database"""
    cur = conn.cursor()

    print("Generating weight data...")
    weights = generate_weight_data(days_back=21)

    print("Generating protein data...")
    protein_entries = generate_protein_data(days_back=21)

    print(f"\nInserting {len(weights)} weight entries...")
    weight_rows = []
    for w in weights:
        weight_rows.append((
            str(uuid.uuid4()),
            PATIENT_ID,
            'DEF_WEIGHT',
            w['weight'],
            w['date'],
            w['timestamp'],
            'import'
        ))

    execute_values(cur, """
        INSERT INTO patient_data_entries
        (id, patient_id, field_id, value_quantity, entry_date, entry_timestamp, source)
        VALUES %s
    """, weight_rows)

    print(f"Inserting {len(protein_entries)} protein entries...")

    # Each protein entry needs 3 records: amount, timing, type
    protein_rows = []
    for p in protein_entries:
        event_id = str(uuid.uuid4())

        # Protein amount
        protein_rows.append((
            str(uuid.uuid4()),
            PATIENT_ID,
            'DEF_PROTEIN_GRAMS',
            p['protein_amount'],
            None,  # value_text
            None,  # value_reference
            p['date'],
            p['timestamp'],
            'import',
            event_id
        ))

        # Protein timing
        protein_rows.append((
            str(uuid.uuid4()),
            PATIENT_ID,
            'DEF_PROTEIN_TIMING',
            None,  # value_quantity
            None,  # value_text
            p['timing_id'],  # value_reference
            p['date'],
            p['timestamp'],
            'import',
            event_id
        ))

        # Protein type
        protein_rows.append((
            str(uuid.uuid4()),
            PATIENT_ID,
            'DEF_PROTEIN_TYPE',
            None,  # value_quantity
            None,  # value_text
            p['protein_type_id'],  # value_reference
            p['date'],
            p['timestamp'],
            'import',
            event_id
        ))

    execute_values(cur, """
        INSERT INTO patient_data_entries
        (id, patient_id, field_id, value_quantity, value_text, value_reference,
         entry_date, entry_timestamp, source, event_instance_id)
        VALUES %s
    """, protein_rows)

    conn.commit()

    # Summary stats
    print("\n" + "="*60)
    print("DATA GENERATION COMPLETE")
    print("="*60)
    print(f"Weight entries: {len(weights)}")
    print(f"Protein entries: {len(protein_entries)} meals/snacks")
    print(f"Total DB records: {len(weight_rows) + len(protein_rows)}")
    print("\nDaily protein by timing breakdown:")

    # Show sample day
    sample_date = weights[-1]['date']
    sample_protein = [p for p in protein_entries if p['date'] == sample_date]
    total_protein = sum(p['protein_amount'] for p in sample_protein)

    print(f"\nSample day ({sample_date}):")
    for p in sorted(sample_protein, key=lambda x: x['timestamp']):
        print(f"  {p['timing']:15s} - {p['protein_amount']:5.1f}g ({p['protein_type']})")
    print(f"  {'TOTAL':15s} - {total_protein:5.1f}g")

    latest_weight = weights[-1]['weight']
    protein_per_kg = total_protein / latest_weight
    print(f"\n  Weight: {latest_weight} kg")
    print(f"  Protein/kg: {protein_per_kg:.2f} g/kg")

    cur.close()

def main():
    print("Connecting to database...")
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

    try:
        insert_data(conn)
    finally:
        conn.close()

    print("\nDone! ✅")

if __name__ == '__main__':
    main()
