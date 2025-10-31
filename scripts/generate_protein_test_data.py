#!/usr/bin/env python3
"""
Generate Comprehensive Protein Test Data
Creates realistic protein intake data for mobile testing
"""

import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta
import random

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

# Test user
PATIENT_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'  # test.patient.21@wellpath.com

# Realistic protein intake patterns
MEAL_PATTERNS = {
    'breakfast': {
        'hour_range': (6, 9),
        'protein_range': (20, 40),
        'common_types': ['eggs', 'greek_yogurt', 'protein_powder_whey', 'lean_poultry']
    },
    'lunch': {
        'hour_range': (11, 14),
        'protein_range': (30, 55),
        'common_types': ['lean_poultry', 'fatty_fish', 'lean_protein', 'tofu', 'tempeh']
    },
    'dinner': {
        'hour_range': (17, 21),
        'protein_range': (35, 65),
        'common_types': ['fatty_fish', 'lean_beef', 'lean_poultry', 'red_meat', 'plant_based', 'seitan']
    },
    'morning_snack': {
        'hour_range': (9, 11),
        'protein_range': (10, 20),
        'common_types': ['greek_yogurt', 'cottage_cheese', 'plant_protein']
    },
    'afternoon_snack': {
        'hour_range': (14, 17),
        'protein_range': (10, 25),
        'common_types': ['protein_powder_plant', 'protein_powder_whey', 'cottage_cheese', 'nuts']
    }
}

def get_reference_uuid(cur, category, key):
    """Get UUID for a reference value"""
    cur.execute("""
        SELECT id FROM data_entry_fields_reference
        WHERE reference_category = %s AND reference_key = %s
        LIMIT 1
    """, (category, key))
    result = cur.fetchone()
    if result:
        return result['id']
    else:
        print(f"⚠️  Warning: Reference not found: {category} / {key}")
        return None

def main():
    print("🥩 Generating Protein Test Data")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor(cursor_factory=RealDictCursor)

    # Delete existing protein data for test user
    print("🗑️  Clearing existing protein data...")
    cur.execute("""
        DELETE FROM patient_data_entries
        WHERE patient_id = %s
          AND field_id IN (
            'DEF_PROTEIN_GRAMS',
            'DEF_PROTEIN_TYPE',
            'DEF_PROTEIN_TIMING',
            'DEF_PROTEIN_TIME'
          )
    """, (PATIENT_ID,))
    deleted = cur.rowcount
    print(f"   Deleted {deleted} existing entries")

    # Cache reference UUIDs
    print("\n📋 Loading reference data...")
    protein_timing_refs = {}
    protein_type_refs = {}

    cur.execute("""
        SELECT id, reference_key FROM data_entry_fields_reference
        WHERE reference_category = 'protein_timing'
    """)
    for row in cur.fetchall():
        protein_timing_refs[row['reference_key']] = row['id']

    cur.execute("""
        SELECT id, reference_key FROM data_entry_fields_reference
        WHERE reference_category = 'protein_types'
    """)
    for row in cur.fetchall():
        protein_type_refs[row['reference_key']] = row['id']

    print(f"   Loaded {len(protein_timing_refs)} timing options")
    print(f"   Loaded {len(protein_type_refs)} protein types")

    # Generate data for last 45 days
    end_date = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    start_date = end_date - timedelta(days=45)

    total_entries = 0
    current_date = start_date

    print(f"\n🔄 Generating protein data from {start_date.date()} to {end_date.date()}...")

    while current_date <= end_date:
        # Determine how many meals today (sometimes people skip meals)
        meal_probability = {
            'breakfast': 0.85,  # 85% of days have breakfast
            'lunch': 0.95,      # 95% of days have lunch
            'dinner': 0.98,     # 98% of days have dinner
            'morning_snack': 0.30,   # 30% of days
            'afternoon_snack': 0.40  # 40% of days
        }

        day_meals = []
        for meal, prob in meal_probability.items():
            if random.random() < prob:
                day_meals.append(meal)

        for meal_timing in day_meals:
            pattern = MEAL_PATTERNS[meal_timing]

            # Generate random time within meal window
            hour = random.randint(pattern['hour_range'][0], pattern['hour_range'][1])
            minute = random.randint(0, 59)
            entry_timestamp = current_date.replace(hour=hour, minute=minute)

            # Generate protein amount
            protein_grams = random.randint(pattern['protein_range'][0], pattern['protein_range'][1])

            # Choose protein type (weighted towards common types)
            protein_type_key = random.choice(pattern['common_types'])

            # Get UUIDs
            timing_uuid = protein_timing_refs.get(meal_timing)
            type_uuid = protein_type_refs.get(protein_type_key)

            if not timing_uuid or not type_uuid:
                print(f"⚠️  Skipping entry - missing reference: {meal_timing} / {protein_type_key}")
                continue

            # Insert 3 rows for this protein entry
            # 1. Protein Grams
            cur.execute("""
                INSERT INTO patient_data_entries (
                    patient_id, field_id, value_quantity,
                    entry_date, entry_timestamp, source
                ) VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                PATIENT_ID,
                'DEF_PROTEIN_GRAMS',
                protein_grams,
                current_date.date(),
                entry_timestamp,
                'manual'
            ))

            # 2. Protein Type
            cur.execute("""
                INSERT INTO patient_data_entries (
                    patient_id, field_id, value_reference,
                    entry_date, entry_timestamp, source
                ) VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                PATIENT_ID,
                'DEF_PROTEIN_TYPE',
                type_uuid,
                current_date.date(),
                entry_timestamp,
                'manual'
            ))

            # 3. Protein Timing
            cur.execute("""
                INSERT INTO patient_data_entries (
                    patient_id, field_id, value_reference,
                    entry_date, entry_timestamp, source
                ) VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                PATIENT_ID,
                'DEF_PROTEIN_TIMING',
                timing_uuid,
                current_date.date(),
                entry_timestamp,
                'manual'
            ))

            total_entries += 3

        current_date += timedelta(days=1)

    conn.commit()

    print(f"\n✅ Generated {total_entries} data entries")

    # Summary stats
    print("\n📊 Summary Statistics:")

    cur.execute("""
        SELECT
            COUNT(DISTINCT entry_date) as days_with_data,
            COUNT(*) / 3 as total_protein_logs,
            ROUND(AVG(value_quantity), 1) as avg_protein_per_entry
        FROM patient_data_entries
        WHERE patient_id = %s
          AND field_id = 'DEF_PROTEIN_GRAMS'
    """, (PATIENT_ID,))
    stats = cur.fetchone()

    print(f"   Days with data: {stats['days_with_data']}")
    print(f"   Total protein logs: {stats['total_protein_logs']}")
    print(f"   Average per entry: {stats['avg_protein_per_entry']}g")

    # Breakdown by meal
    cur.execute("""
        SELECT
            ref.display_name,
            COUNT(*) as count,
            ROUND(AVG(pde_qty.value_quantity), 1) as avg_grams
        FROM patient_data_entries pde
        INNER JOIN data_entry_fields_reference ref
            ON pde.value_reference::uuid = ref.id
        INNER JOIN patient_data_entries pde_qty
            ON pde.patient_id = pde_qty.patient_id
            AND pde.entry_timestamp = pde_qty.entry_timestamp
            AND pde_qty.field_id = 'DEF_PROTEIN_GRAMS'
        WHERE pde.patient_id = %s
          AND pde.field_id = 'DEF_PROTEIN_TIMING'
        GROUP BY ref.display_name
        ORDER BY count DESC
    """, (PATIENT_ID,))

    print("\n   By Meal Timing:")
    for row in cur.fetchall():
        print(f"     {row['display_name']}: {row['count']} entries, avg {row['avg_grams']}g")

    # Breakdown by type
    cur.execute("""
        SELECT
            ref.display_name,
            COUNT(*) as count,
            ROUND(AVG(pde_qty.value_quantity), 1) as avg_grams
        FROM patient_data_entries pde
        INNER JOIN data_entry_fields_reference ref
            ON pde.value_reference::uuid = ref.id
        INNER JOIN patient_data_entries pde_qty
            ON pde.patient_id = pde_qty.patient_id
            AND pde.entry_timestamp = pde_qty.entry_timestamp
            AND pde_qty.field_id = 'DEF_PROTEIN_GRAMS'
        WHERE pde.patient_id = %s
          AND pde.field_id = 'DEF_PROTEIN_TYPE'
        GROUP BY ref.display_name
        ORDER BY count DESC
        LIMIT 10
    """, (PATIENT_ID,))

    print("\n   Top 10 Protein Types:")
    for row in cur.fetchall():
        print(f"     {row['display_name']}: {row['count']} entries, avg {row['avg_grams']}g")

    # Sample daily totals
    cur.execute("""
        SELECT
            entry_date,
            ROUND(SUM(value_quantity), 1) as total_protein
        FROM patient_data_entries
        WHERE patient_id = %s
          AND field_id = 'DEF_PROTEIN_GRAMS'
        GROUP BY entry_date
        ORDER BY entry_date DESC
        LIMIT 7
    """, (PATIENT_ID,))

    print("\n   Last 7 Days Daily Totals:")
    for row in cur.fetchall():
        print(f"     {row['entry_date']}: {row['total_protein']}g")

    print(f"\n{'='*60}")
    print("✅ Protein test data generation complete!")
    print(f"{'='*60}")
    print(f"\n📱 Test User: test.patient.21@wellpath.com")
    print(f"   Patient ID: {PATIENT_ID}")
    print(f"\n💡 Next Steps:")
    print(f"   1. Mobile can now query aggregation_results_cache")
    print(f"   2. Test all 4 protein display metrics")
    print(f"   3. Verify stacked bar charts show correct breakdown")
    print(f"   4. Test period switching (daily/weekly/monthly)")

    conn.close()

if __name__ == "__main__":
    main()
