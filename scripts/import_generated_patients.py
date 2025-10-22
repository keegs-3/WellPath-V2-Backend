#!/usr/bin/env python3
"""
Import generated patient data to Supabase.

This script:
1. Loads patient data from generated biomarker CSV
2. Creates patient_details records
3. Then imports biomarker_readings with proper marker_ids
"""

import os
import sys
import pandas as pd
import psycopg2
from psycopg2.extras import execute_batch
from datetime import datetime, date
import uuid

# Database connection details
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

def clear_existing_data(conn):
    """Clear existing patient data."""
    cursor = conn.cursor()

    # Delete in correct order due to foreign keys
    cursor.execute("DELETE FROM biomarker_readings;")
    print(f"✓ Deleted {cursor.rowcount} biomarker readings")

    cursor.execute("DELETE FROM survey_responses;")
    print(f"✓ Deleted {cursor.rowcount} survey responses")

    cursor.execute("DELETE FROM patient_details;")
    print(f"✓ Deleted {cursor.rowcount} patient details")

    conn.commit()
    cursor.close()

def import_patients(conn, biomarker_data_path):
    """Import patient_details from biomarker CSV."""

    # Load biomarker data
    df = pd.read_csv(biomarker_data_path)
    print(f"✓ Loaded data for {len(df)} patients")

    # Use same practice_id for all test patients
    test_practice_id = 'a1b2c3d4-5678-90ab-cdef-123456789abc'

    # Prepare patient records
    patients = []
    for _, row in df.iterrows():
        # Calculate DOB from age
        birth_year = 2025 - int(row['age'])
        dob = date(birth_year, 1, 1)

        patients.append({
            'id': row['patient_id'],
            'practice_id': test_practice_id,
            'assigned_clinician_id': None,
            'gender': row['sex'],
            'dob': dob,
            'age': int(row['age'])
        })

    # Insert patients
    cursor = conn.cursor()
    insert_query = """
        INSERT INTO patient_details
        (id, practice_id, assigned_clinician_id, gender, dob, age)
        VALUES (%(id)s, %(practice_id)s, %(assigned_clinician_id)s, %(gender)s, %(dob)s, %(age)s)
    """

    execute_batch(cursor, insert_query, patients)
    conn.commit()
    cursor.close()

    print(f"✅ Imported {len(patients)} patient records")

def load_marker_mapping():
    """Load mapping from column name to marker record_id."""
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    markers_csv = os.path.join(base_dir, "ALL_AIRTABLE/csvs/intake_markers_raw.csv")

    df = pd.read_csv(markers_csv)
    # Create mapping: marker_name -> record_id
    # Note: Need to handle column name variations
    mapping = {}
    for _, row in df.iterrows():
        name = row['name'].lower().replace(' ', '_').replace('-', '_')
        mapping[name] = row['record_id']

    print(f"✓ Loaded {len(mapping)} marker mappings")
    return mapping

def import_biomarker_readings(conn, biomarker_data_path, marker_mapping):
    """Import biomarker readings."""

    df = pd.read_csv(biomarker_data_path)
    print(f"✓ Loaded biomarker data for {len(df)} patients")

    # Biomarker columns to import (exclude metadata columns)
    exclude_cols = {'patient_id', 'collection_date', 'age', 'sex', 'athlete',
                    'cycle_phase', 'menopausal_status', 'height_in', 'weight_lb',
                    'bmi', 'sleep_score', 'health_profile', 'fitness_level',
                    'diet_quality', 'stress_level', 'genetic_risk_score'}

    biomarker_cols = [col for col in df.columns if col not in exclude_cols]

    # Prepare biomarker readings
    readings = []
    skipped = 0

    for _, row in df.iterrows():
        patient_id = row['patient_id']
        collection_date = row.get('collection_date', '2025-01-15')

        for col in biomarker_cols:
            value = row[col]

            # Skip NULL values
            if pd.isna(value):
                continue

            # Try to find marker_id
            col_normalized = col.lower().replace(' ', '_').replace('-', '_')
            marker_id = marker_mapping.get(col_normalized)

            if not marker_id:
                # Try without normalization
                marker_id = marker_mapping.get(col)

            if not marker_id:
                skipped += 1
                continue

            readings.append({
                'patient_id': patient_id,
                'marker_id': marker_id,
                'value': float(value),
                'test_date': collection_date  # Correct column name
            })

    print(f"✓ Prepared {len(readings)} biomarker readings")
    print(f"⚠ Skipped {skipped} unmapped markers")

    # Insert readings in batches
    cursor = conn.cursor()
    insert_query = """
        INSERT INTO biomarker_readings
        (patient_id, marker_id, value, test_date)
        VALUES (%(patient_id)s, %(marker_id)s, %(value)s, %(test_date)s)
    """

    batch_size = 1000
    for i in range(0, len(readings), batch_size):
        batch = readings[i:i+batch_size]
        execute_batch(cursor, insert_query, batch)
        conn.commit()
        print(f"✓ Inserted batch {i//batch_size + 1} ({len(batch)} readings)")

    cursor.close()
    print(f"✅ Successfully imported {len(readings)} biomarker readings")

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    biomarker_data_path = os.path.join(base_dir, "data/dummy_lab_results_full.csv")

    if not os.path.exists(biomarker_data_path):
        print(f"❌ Biomarker data file not found: {biomarker_data_path}")
        sys.exit(1)

    print("="*70)
    print("Patient Data Import to Supabase")
    print("="*70)

    # Connect to database
    print("\n1. Connecting to database...")
    conn = psycopg2.connect(**DB_CONFIG)
    print("✓ Connected to Supabase")

    try:
        # Clear existing data
        print("\n2. Clearing existing patient data...")
        clear_existing_data(conn)

        # Import patients
        print("\n3. Importing patient records...")
        import_patients(conn, biomarker_data_path)

        # Load marker mapping
        print("\n4. Loading marker mappings...")
        marker_mapping = load_marker_mapping()

        # Import biomarker readings
        print("\n5. Importing biomarker readings...")
        import_biomarker_readings(conn, biomarker_data_path, marker_mapping)

        # Verify
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM patient_details;")
        patient_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM biomarker_readings;")
        reading_count = cursor.fetchone()[0]
        cursor.close()

        print("\n" + "="*70)
        print("Import Summary")
        print("="*70)
        print(f"Total patients: {patient_count}")
        print(f"Total biomarker readings: {reading_count}")
        print("✅ Patient import completed successfully!")

    finally:
        conn.close()

if __name__ == "__main__":
    main()
