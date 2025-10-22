#!/usr/bin/env python3
"""
Generate Event Type Dependencies SQL
Auto-generates dependency mappings based on field prefixes
"""

import os
import psycopg2
import re

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

# Map field prefixes to event types
FIELD_PREFIX_TO_EVENT = {
    'DEF_ADDED_SUGAR_': 'EVT_ADDED_SUGAR',
    'DEF_ALCOHOL_': 'EVT_ALCOHOL',
    'DEF_BEVERAGE_': 'EVT_BEVERAGE',
    'DEF_BLOOD_PRESSURE_': 'EVT_BLOOD_PRESSURE',
    'DEF_BMI': 'EVT_BMI',
    'DEF_BMR': 'EVT_BMR',
    'DEF_BODY_FAT_': 'EVT_BODY_FAT',
    'DEF_BRAIN_TRAINING_': 'EVT_BRAIN_TRAINING',
    'DEF_BRUSHING_': 'EVT_BRUSHING',
    'DEF_CAFFEINE_': 'EVT_CAFFEINE',
    'DEF_CALORIES_': 'EVT_CALORIES',
    'DEF_CARDIO_': 'EVT_CARDIO',
    'DEF_CIGARETTE_': 'EVT_CIGARETTE',
    'DEF_FAT_': 'EVT_FAT',
    'DEF_FIBER_': 'EVT_FIBER',
    'DEF_FLEXIBILITY_': 'EVT_FLEXIBILITY',
    'DEF_FLOSSING_': 'EVT_FLOSSING',
    'DEF_FOCUS_': 'EVT_FOCUS',
    'DEF_FOOD_': 'EVT_FOOD',
    'DEF_FRUIT_': 'EVT_FRUIT',
    'DEF_GENDER': 'EVT_GENDER',
    'DEF_GRATITUDE_': 'EVT_GRATITUDE',
    'DEF_HEIGHT': 'EVT_HEIGHT',
    'DEF_HIIT_': 'EVT_HIIT',
    'DEF_HIP_': 'EVT_HIP',
    'DEF_HIP_WAIST_RATIO': 'EVT_HIP_WAIST_RATIO',
    'DEF_JOURNALING_': 'EVT_JOURNALING',
    'DEF_LEAN_BODY_MASS': 'EVT_LEAN_MASS',
    'DEF_LEGUME_': 'EVT_LEGUME',
    'DEF_MEAL_': 'EVT_MEAL',
    'DEF_MEASUREMENT_': 'EVT_MEASUREMENT',
    'DEF_MEMORY_': 'EVT_MEMORY',
    'DEF_MINDFULNESS_': 'EVT_MINDFULNESS',
    'DEF_MOBILITY_': 'EVT_MOBILITY',
    'DEF_MOOD_': 'EVT_MOOD',
    'DEF_NECK_': 'EVT_NECK',
    'DEF_NUT_SEED_': 'EVT_NUT_SEED',
    'DEF_OUTDOOR_': 'EVT_OUTDOOR',
    'DEF_PROCESSED_MEAT_': 'EVT_PROCESSED_MEAT',
    'DEF_PROTEIN_': 'EVT_PROTEIN',
    'DEF_SCREEN_TIME_': 'EVT_SCREEN_TIME',
    'DEF_SCREENING_': 'EVT_SCREENING',
    'DEF_SKINCARE_': 'EVT_SKINCARE',
    'DEF_SLEEP_': 'EVT_SLEEP',
    'DEF_SOCIAL_': 'EVT_SOCIAL',
    'DEF_STEPS': 'EVT_STEPS',
    'DEF_STRENGTH_': 'EVT_STRENGTH',
    'DEF_STRESS_': 'EVT_STRESS',
    'DEF_SUBSTANCE_': 'EVT_SUBSTANCE',
    'DEF_SUNLIGHT_': 'EVT_SUNLIGHT',
    'DEF_SUNSCREEN_': 'EVT_SUNSCREEN',
    'DEF_THERAPEUTIC_': 'EVT_THERAPEUTIC',
    'DEF_ULTRA_PROCESSED_': 'EVT_ULTRA_PROCESSED',
    'DEF_UNHEALTHY_BEV_': 'EVT_UNHEALTHY_BEVERAGE',
    'DEF_VEGETABLE_': 'EVT_VEGETABLE',
    'DEF_WAIST_': 'EVT_WAIST',
    'DEF_WATER_': 'EVT_WATER',
    'DEF_WEIGHT_': 'EVT_WEIGHT',
    'DEF_WEIGHT': 'EVT_WEIGHT',
    'DEF_WHOLE_GRAIN_': 'EVT_WHOLE_GRAIN',
    'DEF_AGE': 'EVT_AGE',
}

# Fields that are required for their event type
REQUIRED_FIELDS = {
    'DEF_SLEEP_BEDTIME', 'DEF_SLEEP_WAKETIME',
    'DEF_CARDIO_START', 'DEF_CARDIO_END',
    'DEF_HIIT_START', 'DEF_HIIT_END',
    'DEF_STRENGTH_START', 'DEF_STRENGTH_END',
    'DEF_FLEXIBILITY_START', 'DEF_FLEXIBILITY_END',
    'DEF_MOBILITY_START', 'DEF_MOBILITY_END',
    'DEF_MINDFULNESS_START', 'DEF_MINDFULNESS_END',
    'DEF_BRAIN_TRAINING_START', 'DEF_BRAIN_TRAINING_END',
    'DEF_JOURNALING_START', 'DEF_JOURNALING_END',
    'DEF_OUTDOOR_START', 'DEF_OUTDOOR_END',
    'DEF_SUNLIGHT_START', 'DEF_SUNLIGHT_END',
    'DEF_WATER_QUANTITY', 'DEF_WATER_UNITS',
    'DEF_VEGETABLE_QUANTITY',
    'DEF_FRUIT_QUANTITY',
    'DEF_WHOLE_GRAIN_QUANTITY',
}

# Map instance calculations to event types
CALC_TO_EVENT = {
    # Duration calculations
    'CALC_SLEEP_DURATION': 'EVT_SLEEP',
    'CALC_SLEEP_PERIOD_DURATION': 'EVT_SLEEP',
    'CALC_CARDIO_DURATION': 'EVT_CARDIO',
    'CALC_HIIT_DURATION': 'EVT_HIIT',
    'CALC_STRENGTH_DURATION': 'EVT_STRENGTH',
    'CALC_MOBILITY_DURATION': 'EVT_MOBILITY',
    'CALC_MINDFULNESS_DURATION': 'EVT_MINDFULNESS',
    'CALC_BRAIN_TRAINING_DURATION': 'EVT_BRAIN_TRAINING',
    'CALC_JOURNALING_DURATION': 'EVT_JOURNALING',
    'CALC_OUTDOOR_DURATION': 'EVT_OUTDOOR',
    'CALC_SUNLIGHT_DURATION': 'EVT_SUNLIGHT',
    # Biometric calculations
    'CALC_BMI': 'EVT_BMI',
    'CALC_BMR': 'EVT_BMR',
    'CALC_HIP_WAIST_RATIO': 'EVT_HIP_WAIST_RATIO',
    'CALC_BODY_FAT_PERCENTAGE': 'EVT_BODY_FAT',
    'CALC_LEAN_BODY_MASS': 'EVT_LEAN_MASS',
    'CALC_WEIGHT_LB_TO_KG': 'EVT_WEIGHT',
    'CALC_WEIGHT_KG_TO_LB': 'EVT_WEIGHT',
    'CALC_WAIST_IN_TO_CM': 'EVT_WAIST',
    'CALC_HIP_IN_TO_CM': 'EVT_HIP',
    'CALC_NECK_IN_TO_CM': 'EVT_NECK',
    # Nutrition calculations
    'CALC_PROTEIN_SERVINGS_TO_GRAMS': 'EVT_PROTEIN',
    'CALC_PROTEIN_GRAMS_TO_SERVINGS': 'EVT_PROTEIN',
    'CALC_FAT_GRAMS_TO_SERVINGS': 'EVT_FAT',
    'CALC_FAT_SERVINGS_TO_GRAMS': 'EVT_FAT',
    'CALC_FIBER_GRAMS_TO_SERVINGS': 'EVT_FIBER',
    'CALC_FIBER_SERVINGS_TO_GRAMS': 'EVT_FIBER',
    'CALC_FRUIT_TYPE_TO_NUTRITION': 'EVT_FRUIT',
    'CALC_FRUITS_TO_FIBER': 'EVT_FRUIT',
    'CALC_VEGETABLE_TYPE_TO_NUTRITION': 'EVT_VEGETABLE',
    'CALC_VEGETABLES_TO_FIBER': 'EVT_VEGETABLE',
    'CALC_LEGUME_TYPE_TO_NUTRITION': 'EVT_LEGUME',
    'CALC_LEGUMES_TO_FIBER_PROTEIN': 'EVT_LEGUME',
    'CALC_NUT_SEED_TYPE_TO_NUTRITION': 'EVT_NUT_SEED',
    'CALC_NUTS_SEEDS_TO_NUTRITION': 'EVT_NUT_SEED',
    'CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION': 'EVT_WHOLE_GRAIN',
    'CALC_WHOLE_GRAINS_TO_FIBER': 'EVT_WHOLE_GRAIN',
    'CALC_WATER_UNIT_CONVERSION': 'EVT_WATER',
    # Exercise calculations
    'CALC_DISTANCE_KM_TO_MILES': 'EVT_CARDIO',
    'CALC_DISTANCE_MILES_TO_KM': 'EVT_CARDIO',
}

def map_field_to_event(field_id):
    """Map a field_id to its event_type_id"""
    # Try exact matches first
    if field_id in FIELD_PREFIX_TO_EVENT:
        return FIELD_PREFIX_TO_EVENT[field_id]

    # Try prefix matches
    for prefix, event_type in sorted(FIELD_PREFIX_TO_EVENT.items(), key=lambda x: -len(x[0])):
        if field_id.startswith(prefix):
            return event_type

    return None

def main():
    conn = psycopg2.connect(DB_URL)

    # Get all fields
    with conn.cursor() as cur:
        cur.execute("SELECT field_id FROM data_entry_fields ORDER BY field_id")
        all_fields = [row[0] for row in cur.fetchall()]

    # Get all calculations
    with conn.cursor() as cur:
        cur.execute("SELECT calc_id FROM instance_calculations ORDER BY calc_id")
        all_calcs = [row[0] for row in cur.fetchall()]

    conn.close()

    # Group fields by event type
    event_fields = {}
    unmapped_fields = []

    for field_id in all_fields:
        event_type = map_field_to_event(field_id)
        if event_type:
            if event_type not in event_fields:
                event_fields[event_type] = []
            is_required = field_id in REQUIRED_FIELDS
            event_fields[event_type].append((field_id, is_required))
        else:
            unmapped_fields.append(field_id)

    # Group calculations by event type
    event_calcs = {}
    unmapped_calcs = []

    for calc_id in all_calcs:
        event_type = CALC_TO_EVENT.get(calc_id)
        if event_type:
            if event_type not in event_calcs:
                event_calcs[event_type] = []
            event_calcs[event_type].append(calc_id)
        else:
            unmapped_calcs.append(calc_id)

    # Print summary
    print("=" * 70)
    print("EVENT TYPE DEPENDENCY GENERATION")
    print("=" * 70)
    print(f"\nTotal fields: {len(all_fields)}")
    print(f"Total calculations: {len(all_calcs)}")
    print(f"Event types with fields: {len(event_fields)}")
    print(f"Event types with calculations: {len(event_calcs)}")
    print(f"Unmapped fields: {len(unmapped_fields)}")
    print(f"Unmapped calculations: {len(unmapped_calcs)}")

    if unmapped_fields:
        print(f"\n⚠️  Unmapped fields ({len(unmapped_fields)}):")
        for field in unmapped_fields:
            print(f"   {field}")

    if unmapped_calcs:
        print(f"\n⚠️  Unmapped calculations ({len(unmapped_calcs)}):")
        for calc in unmapped_calcs:
            print(f"   {calc}")

    # Generate SQL
    print("\n" + "=" * 70)
    print("GENERATING SQL...")
    print("=" * 70)

    output_file = '/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251021_populate_event_dependencies.sql'

    with open(output_file, 'w') as f:
        f.write("-- =====================================================\n")
        f.write("-- Populate Event Type Dependencies\n")
        f.write("-- =====================================================\n")
        f.write("-- Auto-generated mapping of fields and calculations to events\n")
        f.write("--\n")
        f.write("-- Created: 2025-10-21\n")
        f.write("-- =====================================================\n\n")
        f.write("BEGIN;\n\n")

        # Write field dependencies
        f.write("-- =====================================================\n")
        f.write("-- PART 1: Field Dependencies\n")
        f.write("-- =====================================================\n\n")

        for event_type in sorted(event_fields.keys()):
            fields = event_fields[event_type]
            f.write(f"-- {event_type} ({len(fields)} fields)\n")
            f.write(f"INSERT INTO event_types_dependencies (event_type_id, data_entry_field_id, dependency_type, is_required, display_order)\n")
            f.write(f"VALUES\n")

            values = []
            for i, (field_id, is_required) in enumerate(fields, 1):
                values.append(f"('{event_type}', '{field_id}', 'field', {str(is_required).lower()}, {i})")

            f.write(",\n".join(values))
            f.write("\nON CONFLICT (event_type_id, data_entry_field_id) WHERE dependency_type = 'field' DO UPDATE SET\n")
            f.write("  is_required = EXCLUDED.is_required,\n")
            f.write("  display_order = EXCLUDED.display_order;\n\n")

        # Write calculation dependencies
        f.write("\n-- =====================================================\n")
        f.write("-- PART 2: Calculation Dependencies\n")
        f.write("-- =====================================================\n\n")

        for event_type in sorted(event_calcs.keys()):
            calcs = event_calcs[event_type]
            f.write(f"-- {event_type} ({len(calcs)} calculations)\n")
            f.write(f"INSERT INTO event_types_dependencies (event_type_id, instance_calculation_id, dependency_type, is_required, display_order)\n")
            f.write(f"VALUES\n")

            values = []
            for i, calc_id in enumerate(calcs, 100):
                values.append(f"('{event_type}', '{calc_id}', 'calculation', false, {i})")

            f.write(",\n".join(values))
            f.write("\nON CONFLICT (event_type_id, instance_calculation_id) WHERE dependency_type = 'calculation' DO UPDATE SET\n")
            f.write("  display_order = EXCLUDED.display_order;\n\n")

        # Summary
        f.write("\n-- =====================================================\n")
        f.write("-- Summary\n")
        f.write("-- =====================================================\n\n")
        f.write("DO $$\n")
        f.write("DECLARE\n")
        f.write("  field_dep_count INT;\n")
        f.write("  calc_dep_count INT;\n")
        f.write("BEGIN\n")
        f.write("  SELECT COUNT(*) INTO field_dep_count FROM event_types_dependencies WHERE dependency_type = 'field';\n")
        f.write("  SELECT COUNT(*) INTO calc_dep_count FROM event_types_dependencies WHERE dependency_type = 'calculation';\n\n")
        f.write("  RAISE NOTICE '✅ Event Dependencies Populated';\n")
        f.write("  RAISE NOTICE '';\n")
        f.write("  RAISE NOTICE 'Summary:';\n")
        f.write("  RAISE NOTICE '  Field Dependencies: %', field_dep_count;\n")
        f.write("  RAISE NOTICE '  Calculation Dependencies: %', calc_dep_count;\n")
        f.write("  RAISE NOTICE '  Total: %', field_dep_count + calc_dep_count;\n")
        f.write("END $$;\n\n")
        f.write("COMMIT;\n")

    print(f"\n✅ Generated SQL file: {output_file}")
    print(f"   Field dependencies: {sum(len(v) for v in event_fields.values())}")
    print(f"   Calculation dependencies: {sum(len(v) for v in event_calcs.values())}")

if __name__ == "__main__":
    main()
