#!/usr/bin/env python3
"""
Import ALL test data from preliminary_data into Supabase (UPDATED for new table names):
- 50 patient profiles (with random emails)
- Biomarker readings → patient_biomarker_readings
- Biometric readings → patient_biometric_readings
- Survey responses → patient_survey_responses

NOTE: Table name changes:
- biomarker_readings → patient_biomarker_readings
- biometric_readings → patient_biometric_readings
- survey_responses → patient_survey_responses
- intake_markers_raw → biomarkers_base
- intake_metrics_raw → biometrics_base
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
DEFAULT_PRACTICE_ID = 'a1b2c3d4-5678-90ab-cdef-123456789abc'
DEFAULT_CLINICIAN_ID = 'c1234567-89ab-cdef-0123-456789abcdef'

def main():
    # Load all data files from V2-Backend
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

    # Delete existing test data first
    print("\n" + "="*80)
    print("STEP 0: Cleaning Previous Test Data")
    print("="*80)

    print("Deleting existing test patient data...")
    # Delete from new table names (cascade order)
    cur.execute("DELETE FROM patient_survey_responses WHERE user_id IN (SELECT id FROM auth_users WHERE email LIKE 'test.patient.%@wellpath.com')")
    cur.execute("DELETE FROM patient_biometric_readings WHERE user_id IN (SELECT id FROM auth_users WHERE email LIKE 'test.patient.%@wellpath.com')")
    cur.execute("DELETE FROM patient_biomarker_readings WHERE user_id IN (SELECT id FROM auth_users WHERE email LIKE 'test.patient.%@wellpath.com')")
    # Delete from patient_details first (if it exists)
    try:
        cur.execute("DELETE FROM patient_details WHERE user_id IN (SELECT id FROM auth_users WHERE email LIKE 'test.patient.%@wellpath.com')")
    except:
        pass  # Table might not exist or might not have user_id column
    cur.execute("DELETE FROM auth_users WHERE email LIKE 'test.patient.%@wellpath.com'")
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

        # Calculate DOB from age
        age_from_csv = int(row['age'])
        dob = f"{2025 - age_from_csv}-01-01"

        try:
            # Create auth_users entry (this is the main user table now)
            cur.execute("""
                INSERT INTO auth_users (
                    id, email, created_at
                )
                VALUES (%s, %s, %s)
                ON CONFLICT (id) DO UPDATE
                SET email = EXCLUDED.email
            """, (
                patient_id, email, datetime.now()
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

    # Get marker name to ID mapping from biomarkers_base
    cur.execute("SELECT id, biomarker_name FROM biomarkers_base")
    marker_mapping = {row[1].lower(): row[0] for row in cur.fetchall()}
    print(f"✓ Loaded {len(marker_mapping)} biomarker mappings")

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
        'total_iron_binding_capacity': 'TIBC',
        'transferrin_saturation': 'Transferrin Saturation',
        'hscrp': 'hsCRP',
        'wbc': 'WBC',
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
        'folate_serum': 'Folate (Serum)',
        'folate_rbc': 'Folate (RBC)',
        'egfr': 'eGFR',
        'cystatin_c': 'Cystatin C',
        'bun': 'BUN',
        'creatinine': 'Creatinine',
        'homocysteine': 'Homocysteine',
        'cortisol_morning': 'Cortisol',
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
        'mch': 'MCH',
        'mchc': 'MCHC',
        'mcv': 'MCV',
        'rbc': 'RBC',
        'platelet': 'Platelet Count',
        'ferritin': 'Ferritin',
        'free_testosterone': 'Free Testosterone',
        'shbg': 'SHBG',
        'progesterone': 'Progesterone'
    }

    biomarker_count = 0
    skipped_markers = 0
    test_date = datetime.now().date()

    for idx, row in biomarkers_df.iterrows():
        patient_id = row['patient_id']

        # Insert each biomarker
        for csv_name, db_name in MARKER_NAME_MAP.items():
            if csv_name not in row or pd.isna(row[csv_name]):
                continue

            biomarker_id = marker_mapping.get(db_name.lower())
            if not biomarker_id:
                skipped_markers += 1
                continue

            try:
                cur.execute("""
                    INSERT INTO patient_biomarker_readings (
                        user_id, biomarker_id, value, unit, test_date, created_at
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    patient_id, biomarker_id, float(row[csv_name]),
                    'mg/dL',  # Default unit
                    test_date, datetime.now()
                ))
                biomarker_count += 1
            except Exception as e:
                conn.rollback()
                if 'violates foreign key constraint' in str(e):
                    # Patient doesn't exist, skip all their biomarkers
                    break
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

    # Get metric mapping from biometrics_base
    cur.execute("SELECT id, biometric_name FROM biometrics_base")
    metric_mapping = {row[1].lower(): row[0] for row in cur.fetchall()}
    print(f"✓ Loaded {len(metric_mapping)} biometric mappings")

    # Metric name mapping (CSV column -> database name, unit)
    METRIC_NAME_MAP = {
        'weight_lb': ('Weight', 'lb'),
        'height_in': ('Height', 'in'),
        'bmi': ('BMI', 'kg/m²'),
        'percent_body_fat': ('Body Fat Percentage', '%'),
        'smm_to_ffm': ('Skeletal Muscle Mass Ratio', 'ratio'),
        'hip_to_waist': ('Hip-to-Waist Ratio', 'ratio'),
        'vo2_max': ('VO2 Max', 'ml/kg/min'),
        'grip_strength': ('Grip Strength', 'kg'),
        'visceral_fat': ('Visceral Fat', 'level'),
        'hrv': ('Heart Rate Variability', 'ms'),
        'resting_heart_rate': ('Resting Heart Rate', 'bpm'),
        'rem_sleep': ('REM Sleep', 'min'),
        'deep_sleep': ('Deep Sleep', 'min'),
        'blood_pressure_systolic': ('Blood Pressure (Systolic)', 'mmHg'),
        'blood_pressure_diastolic': ('Blood Pressure (Diastolic)', 'mmHg'),
        'sleep_score': ('Sleep Duration', 'hours')
    }

    biometric_count = 0
    skipped_metrics = 0

    for idx, row in biomarkers_df.iterrows():
        patient_id = row['patient_id']

        # Import each biometric
        for csv_name, (db_name, unit) in METRIC_NAME_MAP.items():
            if csv_name not in row or pd.isna(row[csv_name]):
                continue

            biometric_id = metric_mapping.get(db_name.lower())
            if not biometric_id:
                skipped_metrics += 1
                continue

            try:
                cur.execute("""
                    INSERT INTO patient_biometric_readings (
                        user_id, biometric_id, value, unit, recorded_at, created_at
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (
                    patient_id, biometric_id, float(row[csv_name]),
                    unit, datetime.now(), datetime.now()
                ))
                biometric_count += 1
            except Exception as e:
                conn.rollback()
                if 'violates foreign key constraint' in str(e):
                    # Patient doesn't exist, skip all their biometrics
                    break
                continue

        if (idx + 1) % 10 == 0:
            print(f"  Imported biometrics for {idx + 1} patients...")
            conn.commit()

    conn.commit()
    print(f"✓ Imported {biometric_count} biometric readings")
    print(f"  Skipped {skipped_metrics} metrics not in database")

    # Final summary
    print("\n" + "="*80)
    print("IMPORT SUMMARY")
    print("="*80)

    cur.execute("SELECT COUNT(*) FROM auth_users WHERE email LIKE 'test.patient.%@wellpath.com'")
    print(f"Total test patients in database: {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM patient_biomarker_readings")
    print(f"Total biomarker readings: {cur.fetchone()[0]}")

    cur.execute("SELECT COUNT(*) FROM patient_biometric_readings")
    print(f"Total biometric readings: {cur.fetchone()[0]}")

    # Check first test patient
    first_patient_id = biomarkers_df.iloc[0]['patient_id']
    print(f"\nFirst Test Patient {first_patient_id}:")
    cur.execute("""
        SELECT
            (SELECT COUNT(*) FROM patient_biomarker_readings WHERE user_id = %s) as biomarkers,
            (SELECT COUNT(*) FROM patient_biometric_readings WHERE user_id = %s) as biometrics
    """, (first_patient_id, first_patient_id))
    result = cur.fetchone()
    print(f"  Biomarkers: {result[0]}")
    print(f"  Biometrics: {result[1]}")

    cur.close()
    conn.close()

    print("\n✅ Import complete!")

if __name__ == "__main__":
    main()
