#!/usr/bin/env python3
"""
Populate Child Protein Source Data for Testing
================================================
Takes existing parent-level protein_grams entries and breaks them down into:
1. Timing: breakfast, lunch, dinner
2. Sources: chicken, beef, tofu, fish, eggs, etc.

This creates realistic test data so the modal sections show actual charts.
"""

import os
import sys
import random
from datetime import datetime, timedelta
import psycopg2
from psycopg2.extras import execute_values

# Database connection
DATABASE_URL = os.environ.get(
    'DATABASE_URL',
    'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
)
conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

# ========================================================================
# STEP 1: Get existing parent protein data
# ========================================================================

print("📊 Fetching existing protein_grams entries...")

cur.execute("""
    SELECT
        user_id,
        entry_date,
        value_quantity as total_grams,
        entry_timestamp
    FROM patient_data_entries
    WHERE field_id = 'DEF_PROTEIN_GRAMS'
    ORDER BY entry_date;
""")

parent_entries = cur.fetchall()
print(f"✅ Found {len(parent_entries)} parent entries")

if not parent_entries:
    print("❌ No parent protein data found. Run generate test data first.")
    sys.exit(1)

# Convert Decimal to float
parent_entries = [(uid, date, float(grams), ts) for uid, date, grams, ts in parent_entries]

# ========================================================================
# STEP 2: Define realistic protein source distributions
# ========================================================================

# Typical protein sources by meal (realistic proportions)
MEAL_DISTRIBUTIONS = {
    'breakfast': {
        'FIELD_PROTEIN_EGGS_GRAMS': 0.40,           # Eggs are big at breakfast
        'FIELD_PROTEIN_GREEKYOGURT_GRAMS': 0.30,    # Greek yogurt common
        'FIELD_PROTEIN_PROTEINPOWDERWHEY_GRAMS': 0.15,  # Protein shake
        'FIELD_PROTEIN_LEANPOULTRY_GRAMS': 0.10,    # Turkey sausage
        'FIELD_PROTEIN_TOFU_GRAMS': 0.05,           # Tofu scramble
    },
    'lunch': {
        'FIELD_PROTEIN_LEANPOULTRY_GRAMS': 0.35,    # Chicken salad/sandwich
        'FIELD_PROTEIN_FISH_GRAMS': 0.20,           # Tuna, salmon
        'FIELD_PROTEIN_LEANBEEF_GRAMS': 0.15,       # Beef
        'FIELD_PROTEIN_TOFU_GRAMS': 0.15,           # Tofu bowl
        'FIELD_PROTEIN_PLANTPROTEIN_GRAMS': 0.10,   # Plant protein
        'FIELD_PROTEIN_TEMPEH_GRAMS': 0.05,         # Tempeh
    },
    'dinner': {
        'FIELD_PROTEIN_LEANPOULTRY_GRAMS': 0.25,    # Chicken dinner
        'FIELD_PROTEIN_FISH_GRAMS': 0.25,           # Fish dinner
        'FIELD_PROTEIN_LEANBEEF_GRAMS': 0.20,       # Steak, burgers
        'FIELD_PROTEIN_FATTYFISH_GRAMS': 0.15,      # Salmon
        'FIELD_PROTEIN_TOFU_GRAMS': 0.10,           # Tofu stir-fry
        'FIELD_PROTEIN_SEITAN_GRAMS': 0.05,         # Seitan
    }
}

# Typical meal distribution (what % of daily protein comes from each meal)
MEAL_SPLIT = {
    'breakfast': 0.25,  # 25% of daily protein at breakfast
    'lunch': 0.35,      # 35% at lunch
    'dinner': 0.40,     # 40% at dinner
}

# Meal timing
MEAL_TIMES = {
    'breakfast': timedelta(hours=8),   # 8 AM
    'lunch': timedelta(hours=12, minutes=30),  # 12:30 PM
    'dinner': timedelta(hours=18, minutes=30), # 6:30 PM
}

# ========================================================================
# STEP 3: Generate child entries for each parent entry
# ========================================================================

print("\n🔨 Generating child protein source entries...")

child_entries = []

for user_id, entry_date, total_grams, entry_timestamp in parent_entries:
    # For each day, distribute protein across meals
    for meal, meal_fraction in MEAL_SPLIT.items():
        meal_grams = total_grams * meal_fraction

        # Add some randomness (±15%)
        meal_grams *= random.uniform(0.85, 1.15)

        # Get timestamp for this meal
        meal_datetime = datetime.combine(entry_date, datetime.min.time()) + MEAL_TIMES[meal]

        # Distribute meal grams across protein sources for this meal
        meal_sources = MEAL_DISTRIBUTIONS[meal]

        for field_id, source_fraction in meal_sources.items():
            source_grams = meal_grams * source_fraction

            # Add some daily variation (±20%)
            source_grams *= random.uniform(0.80, 1.20)

            # Round to 2 decimal places
            source_grams = round(source_grams, 2)

            if source_grams > 0.1:  # Only add if > 0.1g (ignore trace amounts)
                child_entries.append((
                    user_id,
                    field_id,
                    entry_date,
                    meal_datetime,
                    source_grams,
                    'manual',  # Valid source: manual, healthkit, import, api, system, auto_calculated
                               # Note: Using 'manual' so aggregations pick it up (they filter for manual/healthkit/import/api)
                    None,  # healthkit_source_name
                    None,  # healthkit_uuid
                    None,  # event_instance_id
                ))

print(f"✅ Generated {len(child_entries)} child entries")

# ========================================================================
# STEP 4: Insert child entries
# ========================================================================

print("\n💾 Inserting child entries into database...")

# First, delete any existing child entries for these users/dates to avoid duplicates
user_ids = list(set([e[0] for e in parent_entries]))
placeholders = ','.join(['%s'] * len(user_ids))
cur.execute(f"""
    DELETE FROM patient_data_entries
    WHERE user_id IN ({placeholders})
      AND field_id IN (
        SELECT field_id
        FROM data_entry_fields
        WHERE parent_field_id = 'DEF_PROTEIN_GRAMS'
      );
""", user_ids)
print(f"🗑️  Deleted {cur.rowcount} old child entries")

# Insert new entries
insert_sql = """
    INSERT INTO patient_data_entries (
        user_id,
        field_id,
        entry_date,
        entry_timestamp,
        value_quantity,
        source,
        healthkit_source_name,
        healthkit_uuid,
        event_instance_id
    ) VALUES %s
"""

execute_values(cur, insert_sql, child_entries)
conn.commit()

print(f"✅ Inserted {len(child_entries)} child entries")

# ========================================================================
# STEP 5: Verification
# ========================================================================

print("\n🔍 Verification:")

# Check total entries per source
cur.execute("""
    SELECT
        def.field_name,
        COUNT(*) as entry_count,
        ROUND(SUM(pde.value_quantity)::numeric, 2) as total_grams,
        ROUND(AVG(pde.value_quantity)::numeric, 2) as avg_grams
    FROM patient_data_entries pde
    JOIN data_entry_fields def ON def.field_id = pde.field_id
    WHERE def.parent_field_id = 'DEF_PROTEIN_GRAMS'
    GROUP BY def.field_name
    ORDER BY total_grams DESC;
""")

print("\n📊 Protein Sources Summary:")
print(f"{'Source':<40} {'Entries':<10} {'Total (g)':<15} {'Avg (g)':<10}")
print("-" * 75)
for row in cur.fetchall():
    print(f"{row[0]:<40} {row[1]:<10} {row[2]:<15} {row[3]:<10}")

# Check if aggregations exist for these sources
cur.execute("""
    SELECT COUNT(*)
    FROM aggregation_metrics
    WHERE agg_id LIKE 'AGG_%_GRAMS'
      AND agg_id NOT LIKE '%PROTEIN_GRAMS';
""")
agg_count = cur.fetchone()[0]
print(f"\n✅ {agg_count} protein source aggregations configured")

# Check if display metrics exist
cur.execute("""
    SELECT COUNT(*)
    FROM child_display_metrics
    WHERE section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS';
""")
display_count = cur.fetchone()[0]
print(f"✅ {display_count} display metrics in Sources section")

cur.close()
conn.close()

print("\n" + "=" * 80)
print("🎉 DONE! Child protein source data populated.")
print("=" * 80)
print("\n📱 Mobile app should now show:")
print("   • Timing section: Breakfast, Lunch, Dinner breakdown")
print("   • Sources section: Chicken, Fish, Tofu, Eggs, etc.")
print("\n⚠️  NOTE: You'll need to run aggregation pipeline to see this in charts:")
print("   python scripts/process_aggregations.py")
print("=" * 80)
