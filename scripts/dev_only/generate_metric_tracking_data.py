#!/usr/bin/env python3
"""
Generate realistic metric tracking data for ALL metric types for all imported patients.
Creates 30 days of daily metrics to test data display and adherence tracking.
"""

import psycopg2
from datetime import datetime, timedelta
import random
import json

# Database connection
conn = psycopg2.connect(
    host="aws-1-us-west-1.pooler.supabase.com",
    database="postgres",
    user="postgres.csotzmardnvrpdhlogjm",
    password="qLa4sE9zV1yvxCP4",
    port=6543
)

cur = conn.cursor()

print("=" * 80)
print("GENERATING COMPREHENSIVE METRIC TRACKING DATA")
print("=" * 80)

# Get all patients
cur.execute("SELECT id FROM patient_details ORDER BY id")
patient_ids = [row[0] for row in cur.fetchall()]
print(f"\n✓ Found {len(patient_ids)} patients")

# Load ALL metric types from database with unit details
cur.execute("""
    SELECT
        mt.record_id,
        mt.identifier,
        mt.name,
        mt.data_entry_type,
        mt.units,
        mt.validation_schema,
        u.unit_type,
        u.identifier as unit_identifier
    FROM metric_types_vfinal mt
    LEFT JOIN units_vfinal u ON mt.units = u.record_id
    WHERE mt.identifier IS NOT NULL AND mt.identifier != ''
    ORDER BY mt.name
""")

metric_types = []
for row in cur.fetchall():
    validation = {}
    if row[5]:
        try:
            validation = json.loads(row[5])
        except:
            pass

    metric_types.append({
        'record_id': row[0],
        'identifier': row[1],
        'name': row[2],
        'data_entry_type': row[3],
        'units': row[4],
        'validation': validation,
        'unit_type': row[6],
        'unit_identifier': row[7]
    })

print(f"✓ Loaded {len(metric_types)} metric types")

def generate_value_for_metric(metric, date):
    """Generate realistic value based on metric type and validation schema"""
    identifier = metric['identifier']
    data_type = metric['data_entry_type']
    validation = metric['validation']
    unit = metric['units'] if metric['units'] else 'count'
    unit_type = metric.get('unit_type')
    unit_identifier = metric.get('unit_identifier')

    # Handle range-based metrics - USE THE ACTUAL VALIDATION RANGE
    if 'range' in validation:
        min_val = float(validation['range'].get('min', 0))
        max_val = float(validation['range'].get('max', 100))

        # FLOATS: percentages, ratios, and ranges with decimals
        # Check if range itself has decimals (like 0.5-2.5 for servings)
        has_decimal_range = (min_val % 1 != 0) or (max_val % 1 != 0)

        # Check if unit_type is percent (body fat, etc.) - should be float for precision
        is_percentage_unit = unit_type == 'percent'

        # Check metric type keywords
        float_keywords = ['bmi', 'ratio']
        has_float_keyword = any(keyword in identifier.lower() for keyword in float_keywords)

        should_be_float = has_decimal_range or is_percentage_unit or has_float_keyword

        if should_be_float:
            value = random.uniform(max(0, min_val), max_val)
            return round(value, 2)
        else:
            # INTEGERS: Everything else
            # Steps, grams, mg (caffeine), milliliters, calories, minutes, count, etc.
            # Even weight is stored in grams (30000-300000g) so integers are fine
            return random.randint(max(0, int(min_val)), int(max_val))

    # Time-only metrics (minutes since midnight)
    elif data_type == 'time_only':
        if 'wake' in identifier.lower():
            return random.randint(5 * 60, 9 * 60)  # 5am-9am
        elif 'bedtime' in identifier.lower() or 'sleep' in identifier.lower():
            return random.randint(21 * 60, 23 * 60)  # 9pm-11pm
        elif 'meal' in identifier.lower() or 'breakfast' in identifier.lower():
            return random.randint(7 * 60, 9 * 60)  # 7am-9am
        elif 'lunch' in identifier.lower():
            return random.randint(12 * 60, 14 * 60)  # 12pm-2pm
        elif 'dinner' in identifier.lower():
            return random.randint(18 * 60, 20 * 60)  # 6pm-8pm
        elif 'session_start' in identifier.lower() or 'workout' in identifier.lower():
            return random.randint(6 * 60, 20 * 60)  # 6am-8pm
        else:
            return random.randint(0, 1439)

    # Category select / measurement
    elif data_type in ['category_select', 'measurement', 'category']:
        return 1  # Binary present/absent

    # Quantity - use a reasonable default range
    elif data_type == 'quantity':
        # Most quantities should be between 0-100
        return random.randint(0, 100)

    # Default
    return 1

def should_track_metric_today(metric, date, day_of_week):
    """Determine if this metric should be tracked today based on frequency patterns"""
    identifier = metric['identifier']

    # Daily metrics (high frequency)
    daily_metrics = ['step', 'water', 'meal', 'wake_time', 'bedtime', 'caffeine', 'sleep']
    if any(keyword in identifier.lower() for keyword in daily_metrics):
        return random.random() < 0.85  # 85% daily tracking

    # Exercise metrics (3-5x per week)
    exercise_metrics = ['session', 'workout', 'training', 'exercise', 'cardio', 'strength', 'hiit', 'mobility']
    if any(keyword in identifier.lower() for keyword in exercise_metrics):
        return random.random() < 0.5  # ~3-4x per week

    # Food tracking (3x per day for meal-related)
    food_metrics = ['serving', 'protein', 'fiber', 'vegetable', 'fruit', 'legume', 'grain']
    if any(keyword in identifier.lower() for keyword in food_metrics):
        return random.random() < 0.7  # 70% compliance

    # Weekly or occasional metrics
    occasional_metrics = ['sunscreen', 'gratitude', 'journal', 'meditation', 'mindful']
    if any(keyword in identifier.lower() for keyword in occasional_metrics):
        return random.random() < 0.4  # 3x per week

    # Default: moderate frequency
    return random.random() < 0.6

# Generate 30 days of data for each patient
DAYS_TO_GENERATE = 30
today = datetime.now().date()
start_date = today - timedelta(days=DAYS_TO_GENERATE)

total_records = 0
metrics_with_data = set()

print(f"\n✓ Generating {DAYS_TO_GENERATE} days of data for {len(metric_types)} metric types...")

for patient_idx, patient_id in enumerate(patient_ids, 1):
    print(f"\n[{patient_idx}/{len(patient_ids)}] Patient: {patient_id}")
    patient_records = 0

    # Generate data for each day
    for day_offset in range(DAYS_TO_GENERATE):
        current_date = start_date + timedelta(days=day_offset)
        day_of_week = current_date.weekday()

        # Track each metric type
        for metric in metric_types:
            # Decide if we track this metric today
            if not should_track_metric_today(metric, current_date, day_of_week):
                continue

            # Generate value
            value = generate_value_for_metric(metric, current_date)

            # Generate time (spread throughout the day)
            hour = random.randint(6, 22)
            minute = random.randint(0, 59)
            recorded_time = f"{hour:02d}:{minute:02d}:00"

            try:
                cur.execute("""
                    INSERT INTO metric_readings
                    (patient_id, metric_id, value, recorded_date, recorded_time, source, created_at)
                    VALUES (%s, %s, %s, %s, %s, %s, NOW())
                    ON CONFLICT (patient_id, metric_id, recorded_date, recorded_time) DO NOTHING
                """, (
                    patient_id,
                    metric['record_id'],
                    value,
                    current_date,
                    recorded_time,
                    'synthetic'
                ))
                patient_records += 1
                metrics_with_data.add(metric['identifier'])
            except Exception as e:
                # Skip if error (likely constraint violation)
                pass

    print(f"  ✓ Created {patient_records} metric records")
    total_records += patient_records

    # Commit after each patient to avoid huge transactions
    conn.commit()

print("\n" + "=" * 80)
print(f"✓ COMPLETE: Generated {total_records} total metric tracking records")
print(f"✓ Average {total_records // len(patient_ids)} records per patient")
print(f"✓ {len(metrics_with_data)} metric types have data")
print("=" * 80)

cur.close()
conn.close()
