#!/usr/bin/env python3
"""
Inject complete synthetic patient data into Supabase using preliminary_data generators

This script:
1. Runs preliminary_data patient generators
2. Injects ALL survey responses (327 questions)
3. Injects 62 biomarkers into biomarker_readings table
4. Injects 18 biometrics into biometric_readings table
5. Generates 30 days of metric_types_vfinal tracking data

Usage:
    python inject_synthetic_patients_supabase.py
"""

import os
import sys
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from datetime import date, timedelta
import random

# Preliminary data paths
PRELIMINARY_DATA_SCRIPTS = "/Users/keegs/Documents/GitHub/preliminary_data/scripts"
PRELIMINARY_DATA_DIR = "/Users/keegs/Documents/GitHub/preliminary_data"

# Supabase connection
DB_HOST = "aws-1-us-west-1.pooler.supabase.com"
DB_PORT = "6543"
DB_NAME = "postgres"
DB_USER = "postgres.csotzmardnvrpdhlogjm"
DB_PASS = "qLa4sE9zV1yvxCP4"

# Test patient
TEST_PATIENT_ID = "b48ca674-6940-42a3-891a-9a0a82e47e55"

def get_connection():
    """Connect to Supabase"""
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )

def run_preliminary_data_generators():
    """
    Run the preliminary_data scripts to generate patient data
    Returns paths to generated CSV files
    """
    print("🔧 Running preliminary_data patient generators...")

    # Change to preliminary_data scripts directory
    original_dir = os.getcwd()
    os.chdir(PRELIMINARY_DATA_SCRIPTS)

    try:
        # Run biomarker generator
        print("  Generating biomarker data...")
        result = os.system("python3 generate_biomarker_dataset.py 2>&1")
        if result != 0:
            print(f"  ⚠️  Biomarker generation returned code {result}")

        # Run survey generator
        print("  Generating survey responses...")
        result = os.system("python3 generate_survey_dataset_v2.py 2>&1")
        if result != 0:
            print(f"  ⚠️  Survey generation returned code {result}")

        biomarker_file = os.path.join(PRELIMINARY_DATA_DIR, "data/dummy_lab_results_full.csv")
        survey_file = os.path.join(PRELIMINARY_DATA_DIR, "data/synthetic_patient_survey.csv")

        # Check if files exist
        if not os.path.exists(biomarker_file):
            raise FileNotFoundError(f"Biomarker file not found: {biomarker_file}")
        if not os.path.exists(survey_file):
            raise FileNotFoundError(f"Survey file not found: {survey_file}")

        return biomarker_file, survey_file

    finally:
        os.chdir(original_dir)

def inject_biomarkers_from_csv(conn, biomarker_file):
    """
    Inject biomarker data (lab work) from generated CSV into biomarker_readings table
    Maps to intake_markers_raw.record_id
    """
    print("🧬 Injecting biomarker readings (62 lab markers)...")

    # Read generated biomarker data
    df = pd.read_csv(biomarker_file)
    patient_data = df.iloc[0]

    cursor = conn.cursor()

    # Clear existing biomarkers
    cursor.execute("DELETE FROM biomarker_readings WHERE patient_id = %s", (TEST_PATIENT_ID,))

    # Comprehensive biomarker mappings: CSV column → (Supabase marker_id, unit)
    # These reference intake_markers_raw.record_id
    biomarker_mappings = [
        # Lipid panel
        ('hdl', 'recq0JX3QgFBo5mm4', 'mg/dL'),  # HDL
        ('ldl', 'recw2hqgZfllcjFso', 'mg/dL'),  # LDL
        ('triglycerides', 'recDBJLAkc5CAfBm3', 'mg/dL'),  # Triglycerides
        ('total_cholesterol', 'recBA3iQ4lGJtC2nM', 'mg/dL'),  # Total Cholesterol
        ('lp(a)', 'recUkIxIOnGBQsC1n', 'nmol/L'),  # Lp(a)
        ('apob', 'receYj9nbAEGPBxFl', 'mg/dL'),  # ApoB
        ('omega3_index', 'recAAuZFrdsqJW3yd', '%'),  # Omega-3 Index

        # Glucose/Insulin
        ('fasting_glucose', 'recf4HtvFUqMhyhdh', 'mg/dL'),  # Fasting Glucose
        ('fasting_insulin', 'recierVNozpgZdLZH', 'mIU/L'),  # Fasting Insulin
        ('hba1c', 'recC0mB1LyNGjDyld', '%'),  # HbA1c
        ('homa_ir', 'recAdUWMgWMZS3qKI', 'index'),  # HOMA-IR

        # Vitamins
        ('vitamin_d', 'recmyyZam7oYaGnDd', 'ng/mL'),  # Vitamin D
        ('vitamin_b12', 'recDwWAHjdIXhMhSV', 'pg/mL'),  # Vitamin B12
        ('folate_serum', 'recr9ZjdfpVef9KJR', 'ng/mL'),  # Folate Serum
        ('folate_rbc', 'recTyoThcQqCihtey', 'ng/mL'),  # Folate (RBC)

        # Hormones
        ('testosterone', 'recL8dpnjNSzBJp2L', 'ng/dL'),  # Testosterone
        ('free_testosterone', 'recX6IiQRem8pQ14z', 'pg/mL'),  # Free Testosterone
        ('dhea_s', 'recAm1sha0xsNnVoG', 'mcg/dL'),  # DHEA-S
        ('cortisol_morning', 'recwtXkPSEQgyddmt', 'mcg/dL'),  # Cortisol
        ('tsh', 'recdABLj65LlSCrvr', 'mIU/L'),  # TSH
        ('estradiol', 'recUzK4L9enpnuWG8', 'pg/mL'),  # Estradiol
        ('progesterone', 'recHikXLmHS0a08lF', 'ng/mL'),  # Progesterone
        ('shbg', 'recZd7qSsYU2dqSw0', 'nmol/L'),  # SHBG

        # Inflammation
        ('hscrp', 'recPiW3K4dhWi31Xh', 'mg/L'),  # hsCRP

        # Liver function
        ('alt', 'recfQt6B5C5wmZDqn', 'U/L'),  # ALT
        ('ast', 'recHHlPLn8pdw89yH', 'U/L'),  # AST
        ('ggt', 'rec0mt0T6zXGg2XeQ', 'U/L'),  # GGT
        ('alkaline_phosphatase', 'recsIZzvXU1VCDEpy', 'U/L'),  # ALP
        ('albumin', 'recp5z4Yutaf7CDEX', 'g/dL'),  # Albumin
        ('serum_protein', 'recrdgjigS4nlwmx8', 'g/dL'),  # Serum Protein

        # Kidney function
        ('creatinine', 'recuJaoMbqZ3GOYdw', 'mg/dL'),  # Creatinine
        ('bun', 'recRgCjpkw99U68vD', 'mg/dL'),  # BUN
        ('egfr', 'recyUWBp7cedeahQO', 'mL/min/1.73m2'),  # eGFR
        ('cystatin_c', 'rec78IoEbAaGCIfPe', 'mg/L'),  # Cystatin C
        ('uric_acid', 'recyAXip0DWF9Lp1S', 'mg/dL'),  # Uric Acid

        # Complete blood count
        ('wbc', 'reckGxzoaJGEmBptC', '10^3/uL'),  # White Blood Cell Count
        ('rbc', 'recwIwB9znK0kB3Xg', '10^6/uL'),  # Red Blood Cell Count
        ('hemoglobin', 'rec93yl8sjy6vTsht', 'g/dL'),  # Hemoglobin
        ('hematocrit', 'rec6V13cha6oovOXX', '%'),  # Hematocrit
        ('platelet', 'recDUx81XNYUkBLRH', '10^3/uL'),  # Platelet Count
        ('mcv', 'recZa2jX2ZfsZQr47', 'fL'),  # Mean Corpuscular Volume
        ('mch', 'rec1DXEBKaRkramqH', 'pg'),  # Mean Corpuscular Hemoglobin
        ('mchc', 'rec07hP2wtWOA81Db', 'g/dL'),  # Mean Corpuscular Hemoglobin Concentration
        ('rdw', 'recTTucmjMGfWunuf', '%'),  # RDW

        # White blood cell differential
        ('lymphocytes', 'recPDAl8akGkZng3A', '10^3/uL'),  # Lymphocytes
        ('neutrophils', 'recVhxrj1lPj9iYBc', '10^3/uL'),  # Neutrophils
        ('eosinophils', 'rec4HrV6IpswwrF1u', '10^3/uL'),  # Eosinophils
        ('neut_lymph_ratio', 'reccHPJ5bLiHkc845', 'ratio'),  # Neutrocyte/Lymphocyte Ratio

        # Minerals
        ('magnesium_rbc', 'recbYuWTuZJPZwFNc', 'mg/dL'),  # Magnesium (RBC)
        ('iron', 'recEf9Re7uOBSjPbu', 'mcg/dL'),  # Iron
        ('ferritin', 'recStFWPU3NCH9loj', 'ng/mL'),  # Ferritin
        ('serum_ferritin', 'rec7uKDm1ll1XGOqk', 'ng/mL'),  # Serum Ferritin
        ('total_iron_binding_capacity', 'recx8nMW7TjR18ZJv', 'mcg/dL'),  # Total Iron Binding Capacity
        ('transferrin_saturation', 'recVAfZIHmVof1Bmj', '%'),  # Transferrin Saturation
        ('calcium_serum', 'rec7lljffINZr7vSi', 'mg/dL'),  # Calcium (Serum)
        ('calcium_ionized', 'recVZYWGkdqlDhEL9', 'mg/dL'),  # Calcium (Ionized)
        ('sodium', 'recALCA8WP3CwReZz', 'mEq/L'),  # Sodium
        ('potassium', 'recGspbHqQAWDMXpQ', 'mEq/L'),  # Potassium

        # Other markers
        ('homocysteine', 'recLJcUUTL1szyE8Z', 'umol/L'),  # Homocysteine
        ('ck', 'recntmFnf3bSSe2DB', 'U/L'),  # Creatine Kinase
    ]

    values = []
    test_date = (date.today() - timedelta(days=90)).isoformat()

    for csv_col, marker_id, unit in biomarker_mappings:
        if csv_col in patient_data and pd.notna(patient_data[csv_col]):
            value = float(patient_data[csv_col])
            values.append((TEST_PATIENT_ID, marker_id, value, unit, test_date, 'lab'))

    if values:
        insert_query = """
            INSERT INTO biomarker_readings (patient_id, marker_id, value, unit, test_date, source)
            VALUES %s
        """
        execute_values(cursor, insert_query, values)
        conn.commit()
        print(f"✅ Inserted {len(values)} biomarker readings")

    return len(values)

def inject_biometrics_from_csv(conn, biomarker_file):
    """
    Inject biometric data (physical measurements) from generated CSV into biometric_readings table
    Maps to intake_metrics_raw.record_id
    """
    print("📏 Injecting biometric readings (18 physical metrics)...")

    # Read generated biomarker data (biometrics are in same CSV)
    df = pd.read_csv(biomarker_file)
    patient_data = df.iloc[0]

    cursor = conn.cursor()

    # Clear existing biometrics
    cursor.execute("DELETE FROM biometric_readings WHERE patient_id = %s", (TEST_PATIENT_ID,))

    # Biometric mappings: CSV column → (Supabase metric_id, unit)
    # These reference intake_metrics_raw.record_id
    biometric_mappings = [
        ('bmi', 'reccxH7AESy9vvBPo', 'kg/m2'),  # BMI
        ('vo2_max', 'rec0v0JrVS6xu5Dcj', 'mL/kg/min'),  # VO2 Max
        ('grip_strength', 'recHOTAk6Lpmb9uUz', 'kg'),  # Grip Strength
        ('percent_body_fat', 'recVHWlB26jWt9Ij9', '%'),  # Bodyfat
        ('visceral_fat', 'recoiAahhmbWcaNoa', 'level'),  # Visceral Fat
        ('hrv', 'recqea20SA5Y5BaIw', 'ms'),  # HRV
        ('resting_heart_rate', 'recLuAlDIETnvUUtO', 'bpm'),  # Resting Heart Rate
        ('smm_to_ffm', 'recyKRTIlX4Jux2W0', 'ratio'),  # Skeletal Muscle Mass to Fat-Free Mass
        ('hip_to_waist', 'recbIfUESzC18eAIL', 'ratio'),  # Hip-to-Waist Ratio
        ('rem_sleep', 'rec8o1wlo0olBMl8A', 'hours'),  # REM Sleep
        ('deep_sleep', 'recXiq3Os05QJJki4', 'hours'),  # Deep Sleep
        ('blood_pressure_systolic', 'recELBnyZAf0mIQH6', 'mmHg'),  # Blood Pressure - Systolic
        ('blood_pressure_diastolic', 'recSy02sgRnjfOkHE', 'mmHg'),  # Blood Pressure - Diastolic
        ('weight_lb', 'recWsK4nX930OGci1', 'lbs'),  # Weight
        ('height_in', 'recKjpXsXuiQfYGpu', 'inches'),  # Height
    ]

    values = []
    test_date = (date.today() - timedelta(days=90)).isoformat()

    for csv_col, metric_id, unit in biometric_mappings:
        if csv_col in patient_data and pd.notna(patient_data[csv_col]):
            value = float(patient_data[csv_col])
            values.append((TEST_PATIENT_ID, metric_id, value, unit, test_date, 'manual_entry', 'baseline'))

    if values:
        insert_query = """
            INSERT INTO biometric_readings (patient_id, metric_id, value, unit, test_date, source, assessment_type)
            VALUES %s
        """
        execute_values(cursor, insert_query, values)
        conn.commit()
        print(f"✅ Inserted {len(values)} biometric readings")

    return len(values)

def inject_survey_responses_from_csv(conn, survey_file):
    """
    Inject survey responses from generated CSV (all 327 questions)
    """
    print("📋 Injecting survey responses...")

    # Read generated survey data
    df = pd.read_csv(survey_file)
    patient_data = df.iloc[0]

    cursor = conn.cursor()

    # Clear existing survey responses
    cursor.execute("DELETE FROM survey_responses WHERE patient_id = %s", (TEST_PATIENT_ID,))

    values = []

    # Iterate through all columns that are survey responses
    # Format: patient_id, 1.01, 1.02, etc.
    for col in df.columns:
        if col != 'patient_id' and '.' in col:
            question_id = col
            response_value = patient_data[col]

            if pd.notna(response_value) and response_value != '':
                values.append((
                    TEST_PATIENT_ID,
                    question_id,
                    str(response_value),
                    None  # response_numeric - can add logic if needed
                ))

    if values:
        insert_query = """
            INSERT INTO survey_responses (patient_id, question_id, response_value, response_numeric)
            VALUES %s
            ON CONFLICT (patient_id, question_id) DO NOTHING
        """
        execute_values(cursor, insert_query, values)
        conn.commit()
        print(f"✅ Inserted {len(values)} survey responses")

    return len(values)

def inject_metric_readings(conn):
    """
    Generate 30 days of metric tracking data (metric_types_vfinal)
    This simulates daily patient logging behavior
    """
    print("📊 Generating 30 days of metric readings (metric_types_vfinal)...")

    cursor = conn.cursor()

    # Clear existing metrics
    cursor.execute("""
        DELETE FROM metric_readings
        WHERE patient_id = %s
        AND recorded_date >= %s
    """, (TEST_PATIENT_ID, (date.today() - timedelta(days=30)).isoformat()))

    values = []

    # Generate 30 days of data
    for day_offset in range(30):
        current_date = (date.today() - timedelta(days=day_offset)).isoformat()

        # Sleep time (6-8 hours) - using actual metric_types_vfinal identifiers
        sleep_hours = round(random.uniform(6.0, 8.0), 1)
        values.append((TEST_PATIENT_ID, "rec3aaVy0dCKmrdxX", sleep_hours, None, None, current_date, None, "manual", None))  # sleep_time

        # Steps taken (4k-10k)
        steps = random.randint(4000, 10000)
        values.append((TEST_PATIENT_ID, "reciBtcIb0Nj7Y56B", steps, None, None, current_date, None, "manual", None))  # step_taken

        # Water consumed (6-10 cups)
        water = random.randint(6, 10)
        values.append((TEST_PATIENT_ID, "rec7CnfAEp6i9w5fV", water, None, None, current_date, None, "manual", None))  # water_consumed

        # Vegetable servings (3-6 servings)
        veggies = random.randint(3, 6)
        values.append((TEST_PATIENT_ID, "rec0rSFQ8gP9rPSup", veggies, None, None, current_date, None, "manual", None))  # vegetable_serving

        # Fruit servings (2-4 servings)
        fruit = random.randint(2, 4)
        values.append((TEST_PATIENT_ID, "recMi1W2H0fBc2kdF", fruit, None, None, current_date, None, "manual", None))  # fruit_serving

    insert_query = """
        INSERT INTO metric_readings (
            patient_id, metric_id, value, value_text, value_json,
            recorded_date, recorded_time, source, metadata
        ) VALUES %s
        ON CONFLICT (patient_id, metric_id, recorded_date, recorded_time) DO NOTHING
    """

    execute_values(cursor, insert_query, values)
    conn.commit()
    print(f"✅ Inserted {len(values)} metric readings")

    return len(values)

def verify_data(conn):
    """Verify injected data"""
    print("\n🔍 Verifying data...")

    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM survey_responses WHERE patient_id = %s", (TEST_PATIENT_ID,))
    survey_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM biomarker_readings WHERE patient_id = %s", (TEST_PATIENT_ID,))
    biomarker_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM biometric_readings WHERE patient_id = %s", (TEST_PATIENT_ID,))
    biometric_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM metric_readings WHERE patient_id = %s", (TEST_PATIENT_ID,))
    metric_count = cursor.fetchone()[0]

    print(f"  Survey responses: {survey_count}")
    print(f"  Biomarker readings (lab): {biomarker_count}")
    print(f"  Biometric readings (physical): {biometric_count}")
    print(f"  Metric readings (daily tracking): {metric_count}")

    return survey_count, biomarker_count, biometric_count, metric_count

def main():
    print("=" * 70)
    print("WellPath Synthetic Patient Data Injection (Using preliminary_data)")
    print("=" * 70)
    print(f"Patient ID: {TEST_PATIENT_ID}")
    print(f"Patient Email: test@wellpath.com")
    print("=" * 70)

    try:
        # Step 1: Generate data using preliminary_data scripts
        biomarker_file, survey_file = run_preliminary_data_generators()
        print(f"✅ Generated patient data files")
        print(f"   Biomarkers/Biometrics: {biomarker_file}")
        print(f"   Surveys: {survey_file}")

        # Step 2: Connect to Supabase
        print("\n🔌 Connecting to Supabase...")
        conn = get_connection()
        print("✅ Connected")

        # Step 3: Inject data
        biomarker_count = inject_biomarkers_from_csv(conn, biomarker_file)
        biometric_count = inject_biometrics_from_csv(conn, biomarker_file)
        survey_count = inject_survey_responses_from_csv(conn, survey_file)
        metric_count = inject_metric_readings(conn)

        # Step 4: Verify
        verify_data(conn)

        print("\n" + "=" * 70)
        print("✅ SUCCESS! Complete synthetic patient data injected")
        print("=" * 70)
        print("\nData Summary:")
        print(f"  - {survey_count} survey responses (all 327 questions)")
        print(f"  - {biomarker_count} biomarker readings (62 lab markers)")
        print(f"  - {biometric_count} biometric readings (18 physical metrics)")
        print(f"  - {metric_count} metric readings (30 days of tracking)")
        print("\nNext steps:")
        print("1. Run Python scoring pipeline")
        print("2. Verify pillar scores calculated correctly")
        print("3. Test recommendation matching")

        conn.close()

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
