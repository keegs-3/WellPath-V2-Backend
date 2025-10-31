#!/usr/bin/env python3
"""
Generate comprehensive test data for patient 1758fa60-a306-440e-8ae6-9e68fd502bc2
Populates all 170 data_entry_fields with realistic values across multiple days
"""

import psycopg2
import uuid
from datetime import datetime, timedelta
import random

USER_ID = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
DAYS_TO_GENERATE = 30  # Generate 30 days of data

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Get all active data entry fields
cur.execute("""
    SELECT
        field_id,
        field_name,
        display_name,
        field_type,
        data_type,
        unit,
        category_id
    FROM data_entry_fields
    WHERE is_active = true
    ORDER BY category_id, field_id
""")
fields = cur.fetchall()

print(f"Found {len(fields)} active data entry fields")
print("=" * 80)

# Generate test data for the last 30 days
end_date = datetime.now().date()
start_date = end_date - timedelta(days=DAYS_TO_GENERATE)

entries = []

def generate_value(field_id, field_name, field_type, data_type, unit, day_offset):
    """
    Generate realistic test values based on field type
    """
    # Random variation by day for realism
    random.seed(hash(f"{field_id}_{day_offset}"))

    # Sleep fields (1-2 events per day)
    if 'sleep' in field_id.lower():
        if 'duration' in field_id.lower():
            return {'quantity': random.randint(360, 540)}  # 6-9 hours in minutes
        if 'latency' in field_id.lower():
            return {'quantity': random.randint(5, 30)}  # 5-30 minutes
        if 'wake_count' in field_id.lower():
            return {'quantity': random.randint(0, 3)}
        if 'time' in field_id.lower():
            hour = random.randint(22, 23) if 'bedtime' in field_id.lower() else random.randint(6, 8)
            # Return as full timestamp (use entry date + time)
            date_obj = start_date + timedelta(days=day_offset)
            return {'timestamp': f"{date_obj}T{hour}:{random.randint(0, 59):02d}:00"}
        return None

    # Exercise fields (3-5 sessions per week)
    if any(x in field_id.lower() for x in ['cardio', 'strength', 'hiit', 'mobility']):
        # Only generate on some days (not every day)
        if random.random() > 0.5:
            return None

        if 'duration' in field_id.lower():
            return {'quantity': random.randint(20, 60)}  # 20-60 minutes
        if 'session_count' in field_id.lower():
            return {'quantity': 1}
        if 'type' in field_id.lower():
            types = ['running', 'cycling', 'swimming', 'walking']
            return {'text': random.choice(types)}
        return {'quantity': random.randint(1, 3)}

    # Steps (every day)
    if 'steps' in field_id.lower():
        return {'quantity': random.randint(5000, 12000)}

    # Nutrition fields (3 meals per day)
    if any(x in field_id.lower() for x in ['protein', 'vegetable', 'fruit', 'fiber']):
        if 'servings' in field_id.lower() or 'grams' in field_id.lower():
            return {'quantity': random.uniform(1, 5)}
        if 'variety' in field_id.lower():
            return {'quantity': random.randint(1, 4)}
        return {'quantity': random.randint(1, 3)}

    # Water consumption
    if 'water' in field_id.lower():
        return {'quantity': random.randint(6, 10)}  # 6-10 glasses

    # Meal timing
    if 'meal_time' in field_id.lower():
        if 'first' in field_id.lower():
            hour = random.randint(6, 9)
        elif 'last' in field_id.lower():
            hour = random.randint(18, 21)
        else:
            hour = random.randint(12, 14)
        date_obj = start_date + timedelta(days=day_offset)
        return {'timestamp': f"{date_obj}T{hour}:{random.randint(0, 59):02d}:00"}

    # Mindfulness/meditation (not every day)
    if any(x in field_id.lower() for x in ['meditation', 'mindfulness', 'breathwork']):
        if random.random() > 0.6:
            return None
        if 'duration' in field_id.lower():
            return {'quantity': random.randint(5, 30)}
        return {'quantity': 1}

    # Screen time
    if 'screen_time' in field_id.lower():
        return {'quantity': random.randint(60, 300)}  # 1-5 hours in minutes

    # Stress level (daily)
    if 'stress' in field_id.lower() and 'level' in field_id.lower():
        return {'rating': random.randint(1, 5)}

    # Social interaction (not every day)
    if 'social' in field_id.lower():
        if random.random() > 0.5:
            return None
        return {'quantity': random.randint(1, 4)}

    # Outdoor time
    if 'outdoor' in field_id.lower():
        return {'quantity': random.randint(10, 120)}  # 10-120 minutes

    # Sunlight exposure
    if 'sunlight' in field_id.lower() or 'light_exposure' in field_id.lower():
        return {'quantity': random.randint(15, 60)}  # 15-60 minutes

    # Biometrics (measured less frequently)
    if any(x in field_id.lower() for x in ['weight', 'blood_pressure', 'heart_rate']):
        # Only measure every few days
        if day_offset % 3 != 0:
            return None
        if 'weight' in field_id.lower():
            return {'quantity': random.uniform(70, 75)}  # kg
        if 'systolic' in field_id.lower():
            return {'quantity': random.randint(110, 130)}
        if 'diastolic' in field_id.lower():
            return {'quantity': random.randint(70, 85)}
        if 'heart_rate' in field_id.lower():
            return {'quantity': random.randint(60, 80)}

    # Substances (alcohol/caffeine - not every day)
    if 'alcohol' in field_id.lower():
        if random.random() > 0.7:  # Only 30% of days
            return None
        return {'quantity': random.randint(1, 2)}  # 1-2 drinks

    if 'caffeine' in field_id.lower():
        if random.random() > 0.8:  # 80% of days
            return None
        return {'quantity': random.randint(1, 3)}  # 1-3 cups

    # Screenings (very infrequent - only on specific days)
    if 'screening' in field_id.lower():
        # Only generate on day 15
        if day_offset != 15:
            return None
        if 'type' in field_id.lower():
            return {'text': 'dental_exam'}
        if 'date' in field_id.lower():
            return {'timestamp': (start_date + timedelta(days=day_offset)).isoformat()}
        return {'text': 'completed'}

    # Personal care (daily)
    if any(x in field_id.lower() for x in ['brushing', 'flossing', 'sunscreen']):
        if 'brushing' in field_id.lower():
            return {'quantity': 2}  # Twice daily
        if 'flossing' in field_id.lower():
            return {'boolean': True}
        if 'sunscreen' in field_id.lower():
            return {'boolean': random.choice([True, False])}

    # Default fallback based on data type
    if data_type == 'quantity':
        return {'quantity': random.uniform(1, 10)}
    elif data_type == 'boolean':
        return {'boolean': random.choice([True, False])}
    elif data_type == 'rating':
        return {'rating': random.randint(1, 5)}
    elif data_type == 'text':
        return {'text': 'test_value'}
    elif data_type == 'timestamp':
        date_obj = start_date + timedelta(days=day_offset)
        return {'timestamp': f"{date_obj}T{random.randint(8, 20)}:00:00"}

    return None


# Generate data for each day
for day_offset in range(DAYS_TO_GENERATE):
    current_date = start_date + timedelta(days=day_offset)

    for field_id, field_name, display_name, field_type, data_type, unit, category_id in fields:
        value_data = generate_value(field_id, field_name, field_type, data_type, unit, day_offset)

        if value_data is None:
            continue  # Skip this field for this day

        entry = {
            'id': str(uuid.uuid4()),
            'user_id': USER_ID,
            'field_id': field_id,
            'entry_date': current_date,
            'entry_timestamp': datetime.combine(current_date, datetime.min.time()),
            'value_quantity': value_data.get('quantity'),
            'value_text': value_data.get('text'),
            'value_boolean': value_data.get('boolean'),
            'value_rating': value_data.get('rating'),
            'value_timestamp': value_data.get('timestamp'),
            'source': 'import'
        }

        entries.append(entry)

print(f"\nGenerated {len(entries)} data entries across {DAYS_TO_GENERATE} days")
print(f"Average {len(entries) / DAYS_TO_GENERATE:.1f} entries per day")

# Group by category for summary
category_counts = {}
for field_id, field_name, display_name, field_type, data_type, unit, category_id in fields:
    field_entries = [e for e in entries if e['field_id'] == field_id]
    if category_id not in category_counts:
        category_counts[category_id] = 0
    category_counts[category_id] += len(field_entries)

print("\n" + "=" * 80)
print("Entries by Category:")
print("=" * 80)
for category, count in sorted(category_counts.items(), key=lambda x: x[1], reverse=True):
    if count > 0:
        print(f"  {category or '(uncategorized)':35} {count:4} entries")

# Insert entries
print("\n" + "=" * 80)
print("Inserting entries into database...")
print("=" * 80)

insert_sql = """
INSERT INTO patient_data_entries (
    id, user_id, field_id, entry_date, entry_timestamp,
    value_quantity, value_text, value_boolean, value_rating, value_timestamp,
    source
) VALUES (
    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
)
ON CONFLICT (id) DO NOTHING
"""

batch_size = 100
total_inserted = 0

for i in range(0, len(entries), batch_size):
    batch = entries[i:i+batch_size]
    for entry in batch:
        cur.execute(insert_sql, (
            entry['id'],
            entry['user_id'],
            entry['field_id'],
            entry['entry_date'],
            entry['entry_timestamp'],
            entry['value_quantity'],
            entry['value_text'],
            entry['value_boolean'],
            entry['value_rating'],
            entry['value_timestamp'],
            entry['source']
        ))
    conn.commit()
    total_inserted += len(batch)
    print(f"  Inserted {total_inserted}/{len(entries)} entries...")

print(f"\n✅ Successfully inserted {total_inserted} data entries")

# Verify
cur.execute("""
    SELECT COUNT(*) FROM patient_data_entries
    WHERE user_id = %s
""", (USER_ID,))
final_count = cur.fetchone()[0]

print(f"\n📊 Final Count:")
print(f"  Patient {USER_ID} now has {final_count} data entries")

cur.close()
conn.close()
