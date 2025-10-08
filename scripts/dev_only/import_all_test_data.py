#!/usr/bin/env python3
"""
Import ALL test data from preliminary_data into Supabase:
- 50 patient profiles (with random emails)
- Biomarker readings
- Survey responses

All patients will be connected to the same practice and clinician.
"""

import sys
import pandas as pd
import psycopg2
from datetime import datetime
import uuid

# Supabase connection
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

# Default practice and clinician IDs
DEFAULT_PRACTICE_ID = 'a1b2c3d4-5678-90ab-cdef-123456789abc'  # From previous tests
DEFAULT_CLINICIAN_ID = 'c1234567-89ab-cdef-0123-456789abcdef'  # From previous tests

def main():
    # Load all data files from V2-Backend (newly generated)
    import os
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    print("Loading data from V2-Backend generated files...")
    biomarkers_df = pd.read_csv(os.path.join(base_dir, 'data/dummy_lab_results_full.csv'))
    survey_df = pd.read_csv(os.path.join(base_dir, 'data/synthetic_patient_survey.csv'))

    print(f"✓ Loaded {len(biomarkers_df)} patients with biomarker data")
    print(f"✓ Loaded {len(survey_df)} patients with survey data")

    # Connect to Supabase
    print("\nConnecting to Supabase...")
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Check if practice and clinician exist
    cur.execute("SELECT id FROM practices WHERE id = %s", (DEFAULT_PRACTICE_ID,))
    if not cur.fetchone():
        print(f"\n⚠️  Practice {DEFAULT_PRACTICE_ID} does not exist. Creating test practice...")
        cur.execute("""
            INSERT INTO practices (id, name, email, practice_type, created_at)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, (DEFAULT_PRACTICE_ID, 'Test Practice', 'test@wellpath.com', 'Primary Care', datetime.now()))
        conn.commit()
        print("✓ Created test practice")

    cur.execute("SELECT id FROM auth_users WHERE id = %s", (DEFAULT_CLINICIAN_ID,))
    if not cur.fetchone():
        print(f"\n⚠️  Clinician {DEFAULT_CLINICIAN_ID} does not exist. Creating test clinician...")
        cur.execute("""
            INSERT INTO auth_users (id, email, first_name, last_name, role, practice_id, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, (DEFAULT_CLINICIAN_ID, 'clinician@test.com', 'Test', 'Clinician', 'clinician',
              DEFAULT_PRACTICE_ID, datetime.now()))
        conn.commit()
        print("✓ Created test clinician")

    # Import patient details
    print("\n" + "="*80)
    print("STEP 1: Importing Patient Details")
    print("="*80)

    patient_count = 0
    for idx, row in biomarkers_df.iterrows():
        patient_id = row['patient_id']

        # Generate random email
        email = f"test.patient.{idx}@wellpath.com"

        # Calculate age from dob
        age = int(row['age'])
        dob = f"{2025 - age}-01-01"  # Approximate DOB

        try:
            cur.execute("""
                INSERT INTO patient_details (
                    id, practice_id, assigned_clinician_id,
                    gender, dob, age, created_at
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO UPDATE
                SET gender = EXCLUDED.gender,
                    dob = EXCLUDED.dob,
                    age = EXCLUDED.age
            """, (
                patient_id, DEFAULT_PRACTICE_ID, DEFAULT_CLINICIAN_ID,
                row['sex'][:1].upper(),  # 'M' or 'F'
                dob,
                age,
                datetime.now()
            ))

            # Also create auth_users entry (needed for API access)
            cur.execute("""
                INSERT INTO auth_users (
                    id, email, first_name, last_name, role, practice_id, created_at
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (id) DO UPDATE
                SET email = EXCLUDED.email
            """, (
                patient_id, email, f"Patient", f"{idx+1}",
                'patient', DEFAULT_PRACTICE_ID, datetime.now()
            ))

            patient_count += 1

            if (patient_count) % 10 == 0:
                print(f"  Imported {patient_count} patients...")
                conn.commit()

        except Exception as e:
            print(f"Error importing patient {patient_id}: {e}")
            conn.rollback()
            continue

    conn.commit()
    print(f"✓ Imported {patient_count} patient records")

    # Import biomarker readings
    print("\n" + "="*80)
    print("STEP 2: Importing Biomarker Readings")
    print("="*80)

    # First, get marker name to record_id mapping
    cur.execute("SELECT record_id, name FROM intake_markers_raw")
    marker_mapping = {row[1].lower(): row[0] for row in cur.fetchall()}
    print(f"✓ Loaded {len(marker_mapping)} marker mappings")

    # Marker name normalization (CSV column -> database name)
    MARKER_NAME_MAP = {
        'total_cholesterol': 'Total Cholesterol',
        'ldl': 'LDL',
        'hdl': 'HDL',
        'lp(a)': 'Lp(a)',
        'triglycerides': 'Triglycerides',
        'apob': 'ApoB',
        'omega3_index': 'Omega-3 Index',
        'rdw': 'RDW',
        'magnesium_rbc': 'Magnesium (RBC)',
        'vitamin_d': 'Vitamin D',
        'serum_ferritin': 'Serum Ferritin',
        'total_iron_binding_capacity': 'Total Iron Binding Capacity',
        'transferrin_saturation': 'Transferrin Saturation',
        'hscrp': 'hsCRP',
        'wbc': 'White Blood Cell Count',
        'neutrophils': 'Neutrophils',
        'lymphocytes': 'Lymphocytes',
        'neut_lymph_ratio': 'Neutrophil/Lymphocyte Ratio',
        'eosinophils': 'Eosinophils',
        'hba1c': 'HbA1c',
        'fasting_glucose': 'Fasting Glucose',
        'fasting_insulin': 'Fasting Insulin',
        'homa_ir': 'HOMA-IR',
        'alt': 'ALT',
        'ggt': 'GGT',
        'testosterone': 'Testosterone',
        'uric_acid': 'Uric Acid',
        'alkaline_phosphatase': 'Alkaline Phosphatase',
        'albumin': 'Albumin',
        'serum_protein': 'Serum Protein',
        'hemoglobin': 'Hemoglobin',
        'hematocrit': 'Hematocrit',
        'vitamin_b12': 'Vitamin B12',
        'folate_serum': 'Folate Serum',
        'folate_rbc': 'Folate (RBC)',
        'egfr': 'eGFR',
        'cystatin_c': 'Cystatin C',
        'bun': 'BUN',
        'creatinine': 'Creatinine',
        'homocysteine': 'Homocysteine',
        'cortisol_morning': 'Cortisol (Morning)',
        # Additional markers (previously missing)
        'tsh': 'TSH',
        'calcium_serum': 'Calcium (Serum)',
        'calcium_ionized': 'Calcium (Ionized)',
        'dhea_s': 'DHEA-S',
        'estradiol': 'Estradiol',
        'ast': 'AST',
        'sodium': 'Sodium',
        'potassium': 'Potassium',
        'ck': 'Creatine Kinase',
        'iron': 'Iron',
        'mch': 'Mean Corpuscular Hemoglobin (MCH)',
        'mchc': 'Mean Corpuscular Hemoglobin Concentration (MCHC)',
        'mcv': 'Mean Corpuscular Volume',
        'rbc': 'Red Blood Cell Count',
        'platelet': 'Platelet Count',
        'ferritin': 'Ferritin',
        'free_testosterone': 'Free Testosterone',
        'shbg': 'SHBG',
        'progesterone': 'Progesterone'
    }

    biomarker_count = 0
    skipped_markers = 0
    test_date = datetime.now()

    for idx, row in biomarkers_df.iterrows():
        patient_id = row['patient_id']

        # Insert each biomarker
        for csv_name, db_name in MARKER_NAME_MAP.items():
            if csv_name not in row or pd.isna(row[csv_name]):
                continue

            marker_id = marker_mapping.get(db_name.lower())
            if not marker_id:
                skipped_markers += 1
                continue

            try:
                cur.execute("""
                    INSERT INTO biomarker_readings (
                        patient_id, marker_id, value, unit, test_date, created_at
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    patient_id, marker_id, float(row[csv_name]),
                    'mg/dL',  # Default unit
                    test_date, datetime.now()
                ))
                biomarker_count += 1
            except Exception as e:
                # Rollback and skip to next biomarker
                conn.rollback()
                if 'violates foreign key constraint' in str(e):
                    # Patient doesn't exist, skip all their biomarkers
                    break
                # Otherwise just continue to next biomarker
                continue

        if (idx + 1) % 10 == 0:
            print(f"  Imported biomarkers for {idx + 1} patients...")
            conn.commit()

    conn.commit()
    print(f"✓ Imported {biomarker_count} biomarker readings")
    print(f"  Skipped {skipped_markers} markers not in database")

    # Import biometric readings
    print("\n" + "="*80)
    print("STEP 2.5: Importing Biometric Readings")
    print("="*80)

    # Get metric mapping from database
    cur.execute("SELECT record_id, name FROM intake_metrics_raw")
    metric_mapping = {row[1].lower(): row[0] for row in cur.fetchall()}
    print(f"✓ Loaded {len(metric_mapping)} metric mappings")

    # Metric name mapping (CSV column -> database name, unit)
    METRIC_NAME_MAP = {
        'weight_lb': ('Weight', 'lb'),
        'height_in': ('Height', 'in'),
        'bmi': ('BMI', 'kg/m²'),
        'percent_body_fat': ('Bodyfat', '%'),
        'smm_to_ffm': ('Skeletal Muscle Mass to Fat-Free Mass', 'ratio'),
        'hip_to_waist': ('Hip-to-Waist Ratio', 'ratio'),
        'vo2_max': ('VO2 Max', 'ml/kg/min'),
        'grip_strength': ('Grip Strength', 'kg'),
        'visceral_fat': ('Visceral Fat', 'level'),
        'hrv': ('HRV', 'ms'),
        'resting_heart_rate': ('Resting Heart Rate', 'bpm'),
        'rem_sleep': ('REM Sleep', 'min'),
        'deep_sleep': ('Deep Sleep', 'min'),
        'blood_pressure_systolic': ('Blood Pressure (Systolic)', 'mmHg'),
        'blood_pressure_diastolic': ('Blood Pressure (Diastolic)', 'mmHg'),
        'sleep_score': ('Total Sleep', 'hours')  # Assuming sleep_score is total sleep duration
    }

    biometric_count = 0
    skipped_metrics = 0

    for idx, row in biomarkers_df.iterrows():
        patient_id = row['patient_id']

        # Import each biometric
        for csv_name, (db_name, unit) in METRIC_NAME_MAP.items():
            if csv_name not in row or pd.isna(row[csv_name]):
                continue

            metric_id = metric_mapping.get(db_name.lower())
            if not metric_id:
                skipped_metrics += 1
                continue

            try:
                cur.execute("""
                    INSERT INTO biometric_readings (
                        patient_id, metric_id, value, unit, test_date, created_at
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    patient_id, metric_id, float(row[csv_name]),
                    unit, test_date, datetime.now()
                ))
                biometric_count += 1
            except Exception as e:
                # Rollback and skip to next metric
                conn.rollback()
                if 'violates foreign key constraint' in str(e):
                    # Patient doesn't exist, skip all their biometrics
                    break
                # Otherwise just continue to next biometric
                continue

        if (idx + 1) % 10 == 0:
            print(f"  Imported biometrics for {idx + 1} patients...")
            conn.commit()

    conn.commit()
    print(f"✓ Imported {biometric_count} biometric readings")
    print(f"  Skipped {skipped_metrics} metrics not in database")

    # Import survey responses
    print("\n" + "="*80)
    print("STEP 3: Importing Survey Responses")
    print("="*80)

    # Get question ID to record_id and type mapping
    cur.execute('SELECT "ID", record_id, type FROM survey_questions')
    question_mapping = {}
    question_types = {}
    for row in cur.fetchall():
        question_id_str = str(row[0])
        question_mapping[question_id_str] = row[1]
        question_types[row[1]] = row[2]  # Map record_id -> type
    print(f"✓ Loaded {len(question_mapping)} question ID mappings")

    # Get response option mapping (question_id + response_text -> response_option_id)
    cur.execute('SELECT record_id, response, linked_survey_question FROM survey_response_options')
    response_options = {}
    fallback_options = {}  # Fallback options by question_id
    for row in cur.fetchall():
        option_id, response_text, question_id = row
        if question_id and response_text:
            # Create key as (question_id, normalized_response_text)
            key = (question_id, response_text.strip().lower())
            response_options[key] = option_id

            # Track fallback options (ones with brackets or "other")
            response_lower = response_text.lower()
            if ('[' in response_lower or 'other' in response_lower):
                if question_id not in fallback_options:
                    fallback_options[question_id] = []
                fallback_options[question_id].append((option_id, response_text))

    print(f"✓ Loaded {len(response_options)} response option mappings")
    print(f"✓ Found fallback options for {len(fallback_options)} questions")

    survey_count = 0
    skipped_questions = 0
    matched_options = 0
    unmatched_options = 0

    for idx, row in survey_df.iterrows():
        patient_id = row['patient_id']

        if (idx + 1) % 10 == 0:
            print(f"  Processing patient {idx + 1}/{len(survey_df)}...")

        # Insert each survey response
        for col in survey_df.columns:
            if col == 'patient_id':
                continue

            # Map numeric question ID to record_id
            question_record_id = question_mapping.get(col)
            if not question_record_id:
                skipped_questions += 1
                continue

            response = row[col]
            # Convert NaN to empty string - scoring logic needs to see the question was answered with ""
            if pd.isna(response):
                response_value = ""
            else:
                response_value = str(response).strip()

            # Only try to match if there's an actual response value
            response_option_id = None
            if response_value and response_value != "":
                # Try exact match first
                key = (question_record_id, response_value.lower())
                response_option_id = response_options.get(key)

                if response_option_id:
                    matched_options += 1
                else:
                    # No exact match - try fallback based on question type
                    question_type = question_types.get(question_record_id, '')
                    fallbacks = fallback_options.get(question_record_id, [])

                    if fallbacks:
                        # Select appropriate fallback based on question type and response
                        if question_type == 'free-response':
                            # Check if numeric
                            try:
                                float(response_value)
                                # It's numeric - look for [Free numeric]
                                for opt_id, opt_text in fallbacks:
                                    if 'numeric' in opt_text.lower():
                                        response_option_id = opt_id
                                        break
                            except ValueError:
                                # It's text - look for [Free text] or [free response]
                                for opt_id, opt_text in fallbacks:
                                    if 'text' in opt_text.lower() or 'response' in opt_text.lower():
                                        response_option_id = opt_id
                                        break

                        elif question_type == 'date-entry':
                            # Look for [date]
                            for opt_id, opt_text in fallbacks:
                                if 'date' in opt_text.lower():
                                    response_option_id = opt_id
                                    break

                        elif question_type in ['multi-select', 'single-select', 'multi-select w/ other (free response)']:
                            # Look for "Other"
                            for opt_id, opt_text in fallbacks:
                                if 'other' in opt_text.lower():
                                    response_option_id = opt_id
                                    break

                        elif question_type == 'rank':
                            # Look for appropriate rank fallback
                            for opt_id, opt_text in fallbacks:
                                if '[' in opt_text:
                                    response_option_id = opt_id
                                    break

                    if response_option_id:
                        matched_options += 1
                    else:
                        unmatched_options += 1

            try:
                cur.execute("""
                    INSERT INTO survey_responses (
                        patient_id, question_id, response_value, response_option_id, created_at
                    )
                    VALUES (%s, %s, %s, %s, %s)
                    ON CONFLICT (patient_id, question_id) DO UPDATE
                    SET response_value = EXCLUDED.response_value,
                        response_option_id = EXCLUDED.response_option_id
                """, (patient_id, question_record_id, response_value, response_option_id, datetime.now()))

                survey_count += 1
            except Exception as e:
                conn.rollback()
                if 'violates foreign key constraint' not in str(e):
                    print(f"Error inserting survey response for patient {patient_id}, question {col}: {e}")
                break

        conn.commit()

    print(f"✓ Imported {survey_count} survey responses")
    print(f"  Skipped {skipped_questions} unmapped questions")
    print(f"  Matched {matched_options} response options")
    print(f"  Unmatched {unmatched_options} responses (free-form or multi-select)")

    # Final summary
    print("\n" + "="*80)
    print("IMPORT SUMMARY")
    print("="*80)

    cur.execute("SELECT COUNT(*) FROM patient_details")
    print(f"Total patients in database: {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM biomarker_readings")
    print(f"Total biomarker readings: {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM survey_responses")
    print(f"Total survey responses: {cur.fetchone()[0]}")

    # Check our test patient
    print("\nTest Patient 83a28af3-82ef-4ddb-8860-ac23275a5c32:")
    cur.execute("""
        SELECT
            (SELECT COUNT(*) FROM biomarker_readings WHERE patient_id = %s) as biomarkers,
            (SELECT COUNT(*) FROM survey_responses WHERE patient_id = %s) as surveys
    """, (biomarkers_df.iloc[0]['patient_id'], biomarkers_df.iloc[0]['patient_id']))
    result = cur.fetchone()
    print(f"  Biomarkers: {result[0]}")
    print(f"  Survey responses: {result[1]}")

    cur.close()
    conn.close()

    print("\n✅ Import complete!")

if __name__ == "__main__":
    main()
