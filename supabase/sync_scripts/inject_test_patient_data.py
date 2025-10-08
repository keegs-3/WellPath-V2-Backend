#!/usr/bin/env python3
"""
Inject test patient data into Supabase
Creates complete dataset for test@wellpath.com:
- Survey responses
- Biomarker readings
- Metric readings (30 days)

This enables testing of the WellPath scoring pipeline with real Supabase data.
"""

import os
import sys
from datetime import date, timedelta
import random
import psycopg2
from psycopg2.extras import execute_values

# Supabase connection details
DB_HOST = "aws-1-us-west-1.pooler.supabase.com"
DB_PORT = "6543"
DB_NAME = "postgres"
DB_USER = "postgres.csotzmardnvrpdhlogjm"
DB_PASS = "qLa4sE9zV1yvxCP4"

# Test patient ID
TEST_PATIENT_ID = "b48ca674-6940-42a3-891a-9a0a82e47e55"

# Random seed for reproducibility
random.seed(42)

def get_connection():
    """Connect to Supabase PostgreSQL"""
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )

def inject_survey_responses(conn):
    """
    Inject sample survey responses
    Simulates a patient with moderate health:
    - Good nutrition awareness
    - Moderate exercise
    - Sleep issues
    - Some stress
    """
    print("📋 Injecting survey responses...")

    survey_data = [
        # Overview section
        ("1.01", None, "Restorative Sleep, Stress Management", None),
        ("1.02", None, "Healthful Nutrition", None),
        ("1.04", None, "General well-being, Reduce stress", None),
        ("1.05", None, "Apps, Tracking", None),
        ("1.06", None, "I want to sleep better and manage my stress to support my longevity.", None),

        # Nutrition
        ("2.01", None, "Yes, I eat a balanced diet with variety", None),
        ("2.02", None, "3-4 servings", None),
        ("2.03", None, "4-6 servings", None),
        ("2.04", None, "2-3 servings", None),
        ("2.05", None, "1-2 times per week", None),
        ("2.10", None, "1-2 times per week", None),

        # Exercise
        ("3.01", None, "3-4 days per week", None),
        ("3.02", None, "30-45 minutes", None),
        ("3.03", None, "Light to moderate", None),
        ("3.04", None, "1-2 days per week", None),
        ("3.05", None, "Less than 30 minutes", None),

        # Sleep
        ("4.01", None, "6-7 hours", None),
        ("4.02", None, "Sometimes, 3-4 nights per week", None),
        ("4.03", None, "10:30 PM - 11:00 PM", None),
        ("4.04", None, "6:00 AM - 6:30 AM", None),
        ("4.05", None, "Yes, my sleep schedule varies significantly", None),

        # Stress
        ("5.01", None, "Moderate (manageable but present)", None),
        ("5.02", None, "Work demands, Financial concerns", None),
        ("5.03", None, "Sometimes, a few times per week", None),
        ("5.04", None, "Occasionally (e.g., deep breathing)", None),

        # Social/Connection
        ("6.01", None, "Sometimes, several times per week", None),
        ("6.02", None, "Yes, strong support from family/friends", None),
        ("6.03", None, "Yes, I have a sense of purpose", None),

        # Cognitive
        ("7.01", None, "Good (occasionally notice small issues)", None),
        ("7.02", None, "Sometimes (e.g., reading, puzzles)", None),
        ("7.03", None, "Moderate interest, occasional participation", None),
    ]

    cursor = conn.cursor()

    # Clear existing responses for test patient
    cursor.execute("""
        DELETE FROM survey_responses WHERE patient_id = %s
    """, (TEST_PATIENT_ID,))

    # Insert new responses
    insert_query = """
        INSERT INTO survey_responses (patient_id, question_id, response_value, response_numeric)
        VALUES %s
        ON CONFLICT (patient_id, question_id) DO NOTHING
    """

    values = [
        (TEST_PATIENT_ID, q_id, response, score)
        for q_id, _, response, score in survey_data
    ]

    execute_values(cursor, insert_query, values)
    conn.commit()

    print(f"✅ Inserted {len(values)} survey responses")

def inject_biomarker_readings(conn):
    """
    Inject sample biomarker/lab readings
    Simulates recent lab work (last 3 months)
    """
    print("🧬 Injecting biomarker readings...")

    # Test date: 3 months ago
    test_date = (date.today() - timedelta(days=90)).isoformat()

    biomarker_data = [
        # Basic metabolic panel
        ("GLUCOSE_FASTING", 95.0, "mg/dL", test_date, "lab"),
        ("HBA1C", 5.4, "%", test_date, "lab"),

        # Lipid panel
        ("TOTAL_CHOLESTEROL", 195.0, "mg/dL", test_date, "lab"),
        ("LDL_CHOLESTEROL", 120.0, "mg/dL", test_date, "lab"),
        ("HDL_CHOLESTEROL", 55.0, "mg/dL", test_date, "lab"),
        ("TRIGLYCERIDES", 110.0, "mg/dL", test_date, "lab"),

        # Hormones
        ("VITAMIN_D", 32.0, "ng/mL", test_date, "lab"),
        ("TSH", 2.1, "mIU/L", test_date, "lab"),

        # Inflammation
        ("CRP_HS", 1.8, "mg/L", test_date, "lab"),

        # Liver/Kidney
        ("ALT", 28.0, "U/L", test_date, "lab"),
        ("AST", 24.0, "U/L", test_date, "lab"),
        ("CREATININE", 0.9, "mg/dL", test_date, "lab"),

        # Complete blood count
        ("WBC", 6.5, "10^3/uL", test_date, "lab"),
        ("HEMOGLOBIN", 14.2, "g/dL", test_date, "lab"),
        ("PLATELETS", 245.0, "10^3/uL", test_date, "lab"),
    ]

    cursor = conn.cursor()

    # Clear existing biomarkers for test patient
    cursor.execute("""
        DELETE FROM biomarker_readings WHERE patient_id = %s
    """, (TEST_PATIENT_ID,))

    # Insert new readings
    insert_query = """
        INSERT INTO biomarker_readings (patient_id, marker_id, value, unit, test_date, source)
        VALUES %s
    """

    values = [
        (TEST_PATIENT_ID, marker_id, value, unit, test_date, source)
        for marker_id, value, unit, test_date, source in biomarker_data
    ]

    execute_values(cursor, insert_query, values)
    conn.commit()

    print(f"✅ Inserted {len(values)} biomarker readings")

def inject_metric_readings(conn):
    """
    Inject 30 days of daily lifestyle metric tracking
    Simulates realistic patient behavior with some variation
    """
    print("📊 Injecting metric readings (30 days)...")

    cursor = conn.cursor()

    # Clear existing metrics for test patient
    cursor.execute("""
        DELETE FROM metric_readings WHERE patient_id = %s AND recorded_date >= %s
    """, (TEST_PATIENT_ID, (date.today() - timedelta(days=30)).isoformat()))

    values = []

    # Generate 30 days of data
    for day_offset in range(30):
        current_date = (date.today() - timedelta(days=day_offset)).isoformat()

        # Sleep metrics (varies 6-8 hours)
        sleep_hours = round(random.uniform(6.0, 8.0), 1)
        values.append((TEST_PATIENT_ID, "SLEEP_DURATION", sleep_hours, None, None, current_date, None, "manual", None))

        # Exercise (3-4 days per week)
        if random.random() < 0.5:  # ~50% of days
            exercise_mins = random.randint(30, 60)
            values.append((TEST_PATIENT_ID, "EXERCISE_DURATION", exercise_mins, None, None, current_date, None, "manual", None))

        # Steps (varies 4k-10k)
        steps = random.randint(4000, 10000)
        values.append((TEST_PATIENT_ID, "DAILY_STEPS", steps, None, None, current_date, None, "manual", None))

        # Water intake (6-10 cups)
        water_cups = random.randint(6, 10)
        values.append((TEST_PATIENT_ID, "WATER_INTAKE", water_cups, None, None, current_date, None, "manual", None))

        # Vegetables (3-6 servings)
        veggie_servings = random.randint(3, 6)
        values.append((TEST_PATIENT_ID, "VEGETABLE_SERVINGS", veggie_servings, None, None, current_date, None, "manual", None))

        # Fruit (2-4 servings)
        fruit_servings = random.randint(2, 4)
        values.append((TEST_PATIENT_ID, "FRUIT_SERVINGS", fruit_servings, None, None, current_date, None, "manual", None))

        # Mindfulness (0-20 minutes, not every day)
        if random.random() < 0.4:  # ~40% of days
            mindfulness_mins = random.randint(5, 20)
            values.append((TEST_PATIENT_ID, "MINDFULNESS_MINUTES", mindfulness_mins, None, None, current_date, None, "manual", None))

    # Insert all metrics
    insert_query = """
        INSERT INTO metric_readings (
            patient_id, metric_id, value, value_text, value_json,
            recorded_date, recorded_time, source, metadata
        ) VALUES %s
        ON CONFLICT (patient_id, metric_id, recorded_date, recorded_time) DO NOTHING
    """

    execute_values(cursor, insert_query, values)
    conn.commit()

    print(f"✅ Inserted {len(values)} metric readings across 30 days")

def verify_data(conn):
    """Verify that data was inserted correctly"""
    print("\n🔍 Verifying data...")

    cursor = conn.cursor()

    # Check survey responses
    cursor.execute("""
        SELECT COUNT(*) FROM survey_responses WHERE patient_id = %s
    """, (TEST_PATIENT_ID,))
    survey_count = cursor.fetchone()[0]
    print(f"  Survey responses: {survey_count}")

    # Check biomarker readings
    cursor.execute("""
        SELECT COUNT(*) FROM biomarker_readings WHERE patient_id = %s
    """, (TEST_PATIENT_ID,))
    biomarker_count = cursor.fetchone()[0]
    print(f"  Biomarker readings: {biomarker_count}")

    # Check metric readings
    cursor.execute("""
        SELECT COUNT(*) FROM metric_readings WHERE patient_id = %s
    """, (TEST_PATIENT_ID,))
    metric_count = cursor.fetchone()[0]
    print(f"  Metric readings: {metric_count}")

    # Check date range
    cursor.execute("""
        SELECT MIN(recorded_date), MAX(recorded_date)
        FROM metric_readings
        WHERE patient_id = %s
    """, (TEST_PATIENT_ID,))
    date_range = cursor.fetchone()
    if date_range[0]:
        print(f"  Metric date range: {date_range[0]} to {date_range[1]}")

    return survey_count > 0 and biomarker_count > 0 and metric_count > 0

def main():
    print("=" * 70)
    print("WellPath Test Patient Data Injection")
    print("=" * 70)
    print(f"Patient ID: {TEST_PATIENT_ID}")
    print(f"Patient Email: test@wellpath.com")
    print("=" * 70)

    try:
        # Connect to Supabase
        print("\n🔌 Connecting to Supabase...")
        conn = get_connection()
        print("✅ Connected successfully")

        # Inject data
        inject_survey_responses(conn)
        inject_biomarker_readings(conn)
        inject_metric_readings(conn)

        # Verify
        if verify_data(conn):
            print("\n" + "=" * 70)
            print("✅ SUCCESS! Test patient data injected successfully")
            print("=" * 70)
            print("\nNext steps:")
            print("1. Run Python scoring pipeline to calculate pillar scores")
            print("2. Verify scores appear in mobile app")
            print("3. Test recommendation matching")
        else:
            print("\n❌ ERROR: Data verification failed")
            sys.exit(1)

        conn.close()

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
