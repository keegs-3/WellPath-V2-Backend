#!/usr/bin/env python3
"""
Validate and Generate Event Dependencies
Checks which data_entry_fields actually exist before creating dependencies
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

def get_existing_fields():
    """Get all existing data_entry_field_ids"""
    conn = psycopg2.connect(DB_URL)
    with conn.cursor() as cur:
        cur.execute("SELECT field_id FROM data_entry_fields ORDER BY field_id")
        result = {row[0] for row in cur.fetchall()}
    conn.close()
    return result

def get_existing_calculations():
    """Get all existing instance_calculation calc_ids"""
    conn = psycopg2.connect(DB_URL)
    with conn.cursor() as cur:
        cur.execute("SELECT calc_id FROM instance_calculations ORDER BY calc_id")
        result = {row[0] for row in cur.fetchall()}
    conn.close()
    return result

# Define all field dependencies we want to create
FIELD_DEPENDENCIES = {
    'sleep_period': [
        ('DEF_SLEEP_BEDTIME', True, 1),
        ('DEF_SLEEP_WAKETIME', True, 2),
        ('DEF_SLEEP_QUALITY', False, 3),
        ('DEF_SLEEP_PERIOD_START', False, 4),
        ('DEF_SLEEP_PERIOD_END', False, 5),
        ('DEF_SLEEP_PERIOD_TYPE', False, 6),
        ('DEF_SLEEP_FACTORS', False, 7),
    ],
    'cardio_session': [
        ('DEF_CARDIO_START', True, 1),
        ('DEF_CARDIO_END', True, 2),
        ('DEF_CARDIO_TYPE', False, 3),
        ('DEF_CARDIO_DISTANCE', False, 4),
        ('DEF_CARDIO_DISTANCE_UNIT', False, 5),
        ('DEF_CARDIO_AVG_HEART_RATE', False, 6),
        ('DEF_CARDIO_MAX_HEART_RATE', False, 7),
        ('DEF_CARDIO_CALORIES_BURNED', False, 8),
    ],
    'hiit_session': [
        ('DEF_HIIT_START', True, 1),
        ('DEF_HIIT_END', True, 2),
        ('DEF_HIIT_TYPE', False, 3),
        ('DEF_HIIT_ROUNDS', False, 4),
        ('DEF_HIIT_WORK_INTERVAL', False, 5),
        ('DEF_HIIT_REST_INTERVAL', False, 6),
        ('DEF_HIIT_AVG_HEART_RATE', False, 7),
        ('DEF_HIIT_MAX_HEART_RATE', False, 8),
    ],
    'strength_session': [
        ('DEF_STRENGTH_START', True, 1),
        ('DEF_STRENGTH_END', True, 2),
        ('DEF_STRENGTH_TYPE', False, 3),
        ('DEF_STRENGTH_MUSCLE_GROUP', False, 4),
        ('DEF_STRENGTH_SETS', False, 5),
        ('DEF_STRENGTH_REPS', False, 6),
        ('DEF_STRENGTH_WEIGHT', False, 7),
        ('DEF_STRENGTH_WEIGHT_UNIT', False, 8),
    ],
    'mobility_session': [
        ('DEF_MOBILITY_START', True, 1),
        ('DEF_MOBILITY_END', True, 2),
        ('DEF_MOBILITY_TYPE', False, 3),
        ('DEF_MOBILITY_FOCUS_AREA', False, 4),
    ],
    'mindfulness_session': [
        ('DEF_MINDFULNESS_START', True, 1),
        ('DEF_MINDFULNESS_END', True, 2),
        ('DEF_MINDFULNESS_TYPE', False, 3),
    ],
    'brain_training_session': [
        ('DEF_BRAIN_TRAINING_START', True, 1),
        ('DEF_BRAIN_TRAINING_END', True, 2),
        ('DEF_BRAIN_TRAINING_TYPE', False, 3),
    ],
    'journaling_session': [
        ('DEF_JOURNALING_START', True, 1),
        ('DEF_JOURNALING_END', True, 2),
        ('DEF_JOURNALING_TYPE', False, 3),
    ],
    'outdoor_time': [
        ('DEF_OUTDOOR_START', True, 1),
        ('DEF_OUTDOOR_END', True, 2),
        ('DEF_OUTDOOR_ACTIVITY_TYPE', False, 3),
    ],
    'sunlight_exposure': [
        ('DEF_SUNLIGHT_START', True, 1),
        ('DEF_SUNLIGHT_END', True, 2),
        ('DEF_SUNLIGHT_TIME_OF_DAY', False, 3),
    ],
    'biometric_reading': [
        ('DEF_WEIGHT', False, 1),
        ('DEF_HEIGHT', False, 2),
        ('DEF_WAIST_CIRCUMFERENCE', False, 3),
        ('DEF_HIP_CIRCUMFERENCE', False, 4),
        ('DEF_NECK_CIRCUMFERENCE', False, 5),
        ('DEF_BODY_FAT_PERCENTAGE', False, 6),
        ('DEF_MUSCLE_MASS', False, 7),
        ('DEF_BONE_MASS', False, 8),
        ('DEF_BLOOD_PRESSURE_SYSTOLIC', False, 9),
        ('DEF_BLOOD_PRESSURE_DIASTOLIC', False, 10),
        ('DEF_RESTING_HEART_RATE', False, 11),
        ('DEF_VO2_MAX', False, 12),
    ],
    'protein_intake': [
        ('DEF_PROTEIN_SERVINGS', False, 1),
        ('DEF_PROTEIN_TYPE', False, 2),
        ('DEF_PROTEIN_GRAMS', False, 3),
    ],
    'vegetable_intake': [
        ('DEF_VEGETABLE_QUANTITY', True, 1),
        ('DEF_VEGETABLE_CATEGORY', False, 2),
    ],
    'fruit_intake': [
        ('DEF_FRUIT_QUANTITY', True, 1),
        ('DEF_FRUIT_TYPE', False, 2),
    ],
    'whole_grain_intake': [
        ('DEF_WHOLE_GRAIN_QUANTITY', True, 1),
        ('DEF_WHOLE_GRAIN_TYPE', False, 2),
    ],
    'fat_intake': [
        ('DEF_HEALTHY_FAT_SERVINGS', True, 1),
        ('DEF_HEALTHY_FAT_TYPE', False, 2),
    ],
    'legume_intake': [
        ('DEF_LEGUME_QUANTITY', True, 1),
        ('DEF_LEGUME_TYPE', False, 2),
    ],
    'nut_seed_intake': [
        ('DEF_NUT_SEED_QUANTITY', True, 1),
        ('DEF_NUT_SEED_TYPE', False, 2),
    ],
    'fiber_intake': [
        ('DEF_FIBER_GRAMS', True, 1),
    ],
    'water_intake': [
        ('DEF_WATER_QUANTITY', True, 1),
        ('DEF_WATER_UNITS', True, 2),
    ],
    'sugar_intake': [
        ('DEF_SUGAR_GRAMS', True, 1),
    ],
    'alcohol_intake': [
        ('DEF_ALCOHOL_SERVINGS', True, 1),
        ('DEF_ALCOHOL_TYPE', False, 2),
    ],
    'sodium_intake': [
        ('DEF_SODIUM_MILLIGRAMS', True, 1),
    ],
}

CALC_DEPENDENCIES = {
    'sleep_period': [('CALC_SLEEP_DURATION', True, 100)],
    'cardio_session': [('CALC_CARDIO_DURATION', True, 100)],
    'hiit_session': [('CALC_HIIT_DURATION', True, 100)],
    'strength_session': [('CALC_STRENGTH_DURATION', True, 100)],
    'mobility_session': [('CALC_MOBILITY_DURATION', True, 100)],
    'mindfulness_session': [('CALC_MINDFULNESS_DURATION', True, 100)],
    'brain_training_session': [('CALC_BRAIN_TRAINING_DURATION', True, 100)],
    'journaling_session': [('CALC_JOURNALING_DURATION', True, 100)],
    'outdoor_time': [('CALC_OUTDOOR_DURATION', True, 100)],
    'sunlight_exposure': [('CALC_SUNLIGHT_DURATION', True, 100)],
    'biometric_reading': [
        ('CALC_BMI', False, 101),
        ('CALC_BMR', False, 102),
        ('CALC_HIP_WAIST_RATIO', False, 103),
        ('CALC_BODY_FAT_PERCENTAGE', False, 104),
        ('CALC_LEAN_BODY_MASS', False, 105),
        ('CALC_WEIGHT_LB_TO_KG', False, 106),
        ('CALC_WEIGHT_KG_TO_LB', False, 107),
        ('CALC_HEIGHT_IN_TO_CM', False, 108),
        ('CALC_HEIGHT_CM_TO_IN', False, 109),
        ('CALC_WAIST_IN_TO_CM', False, 110),
        ('CALC_WAIST_CM_TO_IN', False, 111),
        ('CALC_HIP_IN_TO_CM', False, 112),
        ('CALC_HIP_CM_TO_IN', False, 113),
        ('CALC_NECK_IN_TO_CM', False, 114),
        ('CALC_NECK_CM_TO_IN', False, 115),
    ],
    'protein_intake': [
        ('CALC_PROTEIN_SERVINGS_TO_GRAMS', False, 101),
        ('CALC_PROTEIN_GRAMS_TO_SERVINGS', False, 102),
    ],
}

def main():
    print("🔍 Validating field and calculation references...")

    existing_fields = get_existing_fields()
    existing_calcs = get_existing_calculations()

    print(f"\nFound {len(existing_fields)} data_entry_fields")
    print(f"Found {len(existing_calcs)} instance_calculations")

    # Validate field dependencies
    missing_fields = []
    for event_type, fields in FIELD_DEPENDENCIES.items():
        for field_id, is_required, order in fields:
            if field_id not in existing_fields:
                missing_fields.append((event_type, field_id))

    # Validate calculation dependencies
    missing_calcs = []
    for event_type, calcs in CALC_DEPENDENCIES.items():
        for calc_id, is_required, order in calcs:
            if calc_id not in existing_calcs:
                missing_calcs.append((event_type, calc_id))

    if missing_fields:
        print(f"\n❌ Missing {len(missing_fields)} field references:")
        for event_type, field_id in missing_fields:
            print(f"   {event_type}: {field_id}")
    else:
        print("\n✅ All field references valid")

    if missing_calcs:
        print(f"\n❌ Missing {len(missing_calcs)} calculation references:")
        for event_type, calc_id in missing_calcs:
            print(f"   {event_type}: {calc_id}")
    else:
        print("\n✅ All calculation references valid")

    # Generate SQL for valid dependencies only
    if missing_fields or missing_calcs:
        print("\n📝 Generating corrected SQL (excluding missing references)...")

        # Filter out missing fields
        valid_field_deps = {}
        for event_type, fields in FIELD_DEPENDENCIES.items():
            valid_fields = [(f, r, o) for f, r, o in fields if f in existing_fields]
            if valid_fields:
                valid_field_deps[event_type] = valid_fields

        # Filter out missing calculations
        valid_calc_deps = {}
        for event_type, calcs in CALC_DEPENDENCIES.items():
            valid_calcs = [(c, r, o) for c, r, o in calcs if c in existing_calcs]
            if valid_calcs:
                valid_calc_deps[event_type] = valid_calcs

        # Print summary
        print(f"\n📊 Will create:")
        print(f"   {sum(len(v) for v in valid_field_deps.values())} field dependencies (removed {len(missing_fields)})")
        print(f"   {sum(len(v) for v in valid_calc_deps.values())} calculation dependencies (removed {len(missing_calcs)})")

if __name__ == "__main__":
    main()
