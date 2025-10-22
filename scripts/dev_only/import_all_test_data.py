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

    # Check if practice and clinician exist (using medical_practices instead of practices)
    cur.execute("SELECT id FROM medical_practices WHERE id = %s", (DEFAULT_PRACTICE_ID,))
    if not cur.fetchone():
        print(f"\n⚠️  Practice {DEFAULT_PRACTICE_ID} does not exist. Creating test practice...")
        cur.execute("""
            INSERT INTO medical_practices (id, name, email, created_at)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, (DEFAULT_PRACTICE_ID, 'Test Practice', 'test@wellpath.com', datetime.now()))
        conn.commit()
        print("✓ Created test practice")

    cur.execute("SELECT id FROM auth_users WHERE id = %s", (DEFAULT_CLINICIAN_ID,))
    if not cur.fetchone():
        print(f"\n⚠️  Clinician {DEFAULT_CLINICIAN_ID} does not exist. Creating test clinician...")
        cur.execute("""
            INSERT INTO auth_users (id, email, full_name, role, created_at)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, (DEFAULT_CLINICIAN_ID, 'clinician@test.com', 'Test Clinician', 'clinician', datetime.now()))
        conn.commit()
        print("✓ Created test clinician")

    # Delete existing test data first
    print("\n" + "="*80)
    print("STEP 0: Cleaning Previous Test Data")
    print("="*80)

    print("Deleting existing test data for practice", DEFAULT_PRACTICE_ID)
    # Delete based on patient_details medical_practice_id
    cur.execute("DELETE FROM patient_survey_responses WHERE user_id IN (SELECT user_id FROM patient_details WHERE medical_practice_id = %s)", (DEFAULT_PRACTICE_ID,))
    cur.execute("DELETE FROM patient_biometric_readings WHERE user_id IN (SELECT user_id FROM patient_details WHERE medical_practice_id = %s)", (DEFAULT_PRACTICE_ID,))
    cur.execute("DELETE FROM patient_biomarker_readings WHERE user_id IN (SELECT user_id FROM patient_details WHERE medical_practice_id = %s)", (DEFAULT_PRACTICE_ID,))
    # Get user_ids before deleting patient_details
    cur.execute("SELECT user_id FROM patient_details WHERE medical_practice_id = %s", (DEFAULT_PRACTICE_ID,))
    user_ids = [row[0] for row in cur.fetchall() if row[0] is not None]
    cur.execute("DELETE FROM patient_details WHERE medical_practice_id = %s", (DEFAULT_PRACTICE_ID,))
    # Delete auth_users for these patients
    if user_ids:
        cur.execute(f"DELETE FROM auth_users WHERE id IN ({','.join(['%s'] * len(user_ids))})", user_ids)
    conn.commit()
    print("✓ Deleted all existing test data")

    # Import patient details
    print("\n" + "="*80)
    print("STEP 1: Importing Patient Details")
    print("="*80)

    patient_count = 0
    for idx, row in biomarkers_df.iterrows():
        patient_id = row['patient_id']

        # Generate random email
        email = f"test.patient.{idx}@wellpath.com"

        # Calculate DOB from age (age will be auto-calculated by DB from dob)
        age_from_csv = int(row['age'])
        dob = f"{2025 - age_from_csv}-01-01"  # Approximate DOB

        try:
            # Create auth_users entry first (needed for API access and foreign key)
            cur.execute("""
                INSERT INTO auth_users (
                    id, email, full_name, role, created_at
                )
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (id) DO UPDATE
                SET email = EXCLUDED.email
            """, (
                patient_id, email, f"Patient {idx+1}",
                'patient', datetime.now()
            ))

            # Then create patient_details with user_id linking to auth_users
            cur.execute("""
                INSERT INTO patient_details (
                    user_id, medical_practice_id, assigned_clinician_id,
                    biological_sex, date_of_birth, created_at
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (user_id) DO UPDATE
                SET biological_sex = EXCLUDED.biological_sex,
                    date_of_birth = EXCLUDED.date_of_birth
            """, (
                patient_id, DEFAULT_PRACTICE_ID, DEFAULT_CLINICIAN_ID,
                row['sex'][:1].upper(),  # 'M' or 'F'
                dob,
                datetime.now()
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

    # Get list of valid biomarker names
    cur.execute("SELECT biomarker_name FROM biomarkers_base")
    valid_biomarkers = {row[0].lower(): row[0] for row in cur.fetchall()}
    print(f"✓ Loaded {len(valid_biomarkers)} biomarker names")

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
        'total_iron_binding_capacity': 'Total Iron Binding Capacity (TIBC)',
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
        'alkaline_phosphatase': 'ALP',
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
        'cortisol_morning': 'Cortisol',
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

            biomarker_name = valid_biomarkers.get(db_name.lower())
            if not biomarker_name:
                skipped_markers += 1
                continue

            try:
                cur.execute("""
                    INSERT INTO patient_biomarker_readings (
                        user_id, biomarker_name, value, unit, test_date, created_at
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    patient_id, biomarker_name, float(row[csv_name]), 'standard',
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

    # Get list of valid biometric names
    cur.execute("SELECT biometric_name FROM biometrics_base")
    valid_biometrics = {row[0].lower(): row[0] for row in cur.fetchall()}
    print(f"✓ Loaded {len(valid_biometrics)} biometric names")

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

            biometric_name = valid_biometrics.get(db_name.lower())
            if not biometric_name:
                skipped_metrics += 1
                continue

            try:
                cur.execute("""
                    INSERT INTO patient_biometric_readings (
                        user_id, biometric_name, value, unit, recorded_at, created_at
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    patient_id, biometric_name, float(row[csv_name]), unit,
                    test_date, datetime.now()
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

    # Get question number to type mapping from survey_questions_base
    cur.execute('SELECT question_number, type FROM survey_questions_base')
    question_mapping = {}
    question_types = {}
    for row in cur.fetchall():
        question_num_str = str(row[0]).strip()  # Strip whitespace
        # Store the original question_number
        question_mapping[question_num_str] = question_num_str

        # Handle decimal padding: 8.1 should map to 8.10 (not 8.01!)
        if '.' in question_num_str:
            parts = question_num_str.split('.')
            decimal_part = parts[1]

            # If decimal part is single digit, pad with trailing zero (8.1 -> 8.10)
            if len(decimal_part) == 1:
                padded_trailing = f"{parts[0]}.{decimal_part}0"
                question_mapping[padded_trailing] = question_num_str

            # If decimal part is two digits, also create single digit version (8.01 -> 8.1)
            elif len(decimal_part) == 2 and decimal_part.endswith('0'):
                single_digit = f"{parts[0]}.{decimal_part[0]}"
                question_mapping[single_digit] = question_num_str

        question_types[question_num_str] = row[1]  # Map question_number -> type

    # Debug: print section 8 mappings
    section_8_keys = [k for k in question_mapping.keys() if k.startswith('8.')]
    print(f"✓ Loaded {len(question_mapping)} question ID mappings")
    print(f"  Section 8 mappings: {len(section_8_keys)} keys")
    print(f"  Sample section 8 keys: {sorted(section_8_keys)[:10]}")

    # Get response option mapping (question_number + option_text -> response_option_id)
    cur.execute('SELECT id, option_text, question_number FROM survey_response_options')
    response_options = {}
    fallback_options = {}  # Fallback options by question_number
    for row in cur.fetchall():
        option_id, option_text, question_number = row
        if question_number and option_text:
            # Create key as (question_number, normalized_option_text)
            key = (question_number, option_text.strip().lower())
            response_options[key] = option_id

            # Track fallback options (ones with brackets or "other")
            option_lower = option_text.lower()
            if ('[' in option_lower or 'other' in option_lower):
                if question_number not in fallback_options:
                    fallback_options[question_number] = []
                fallback_options[question_number].append((option_id, option_text))

    print(f"✓ Loaded {len(response_options)} response option mappings")
    print(f"✓ Found fallback options for {len(fallback_options)} questions")

    survey_count = 0
    skipped_questions = 0
    matched_options = 0
    unmatched_options = 0
    skipped_section_8 = []  # Track skipped section 8 questions

    for idx, row in survey_df.iterrows():
        patient_id = row['patient_id']

        if (idx + 1) % 10 == 0:
            print(f"  Processing patient {idx + 1}/{len(survey_df)}...")

        # Insert each survey response
        for col in survey_df.columns:
            if col == 'patient_id':
                continue

            # Map CSV column to question_number
            col_stripped = col.strip()
            question_number = question_mapping.get(col_stripped)
            if not question_number:
                skipped_questions += 1
                # Track section 8 skips for debugging
                if col_stripped.startswith('8.') and col_stripped not in skipped_section_8:
                    skipped_section_8.append(col_stripped)
                continue

            response = row[col]
            # Keep empty responses - scoring logic needs them
            if pd.isna(response):
                response_value = ""
            else:
                response_value = str(response).strip()

            # Only try to match response_option_id if there's an actual response value
            response_option_id = None
            if response_value and response_value != "":
                # Try exact match first
                key = (question_number, response_value.lower())
                response_option_id = response_options.get(key)

                if response_option_id:
                    matched_options += 1
                else:
                    # No exact match - try fallback based on question type
                    question_type = question_types.get(question_number, '')
                    fallbacks = fallback_options.get(question_number, [])

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
                    INSERT INTO patient_survey_responses (
                        user_id, question_number, response_text, response_option_id, completed_at
                    )
                    VALUES (%s, %s, %s, %s, %s)
                """, (patient_id, question_number, response_value, response_option_id, datetime.now()))

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
    if skipped_section_8:
        print(f"  ⚠ WARNING: Skipped {len(skipped_section_8)} section 8 questions:")
        print(f"    {sorted(skipped_section_8)[:20]}")  # Show first 20

    # Final summary
    print("\n" + "="*80)
    print("IMPORT SUMMARY")
    print("="*80)

    cur.execute("SELECT COUNT(*) FROM patient_details")
    print(f"Total patients in database: {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM patient_biomarker_readings")
    print(f"Total biomarker readings: {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM patient_biometric_readings")
    print(f"Total biometric readings: {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM patient_survey_responses")
    print(f"Total survey responses: {cur.fetchone()[0]}")

    # Check our test patient
    test_patient_id = biomarkers_df.iloc[0]['patient_id']
    print(f"\nTest Patient {test_patient_id}:")
    cur.execute("""
        SELECT
            (SELECT COUNT(*) FROM patient_biomarker_readings WHERE user_id = %s) as biomarkers,
            (SELECT COUNT(*) FROM patient_biometric_readings WHERE user_id = %s) as biometrics,
            (SELECT COUNT(*) FROM patient_survey_responses WHERE user_id = %s) as surveys
    """, (test_patient_id, test_patient_id, test_patient_id))
    result = cur.fetchone()
    print(f"  Biomarkers: {result[0]}")
    print(f"  Biometrics: {result[1]}")
    print(f"  Survey responses: {result[2]}")

    cur.close()
    conn.close()

    print("\n✅ Import complete!")

if __name__ == "__main__":
    main()
