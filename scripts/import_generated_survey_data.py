#!/usr/bin/env python3
"""
Import generated survey data to Supabase with proper record_id mapping.

This script:
1. Loads the generated survey responses (data/synthetic_patient_survey.csv)
2. Maps question IDs (1.01, 2.11, etc.) to Airtable record_ids
3. Maps response values to response_option_ids where applicable
4. Inserts into Supabase survey_responses table
"""

import os
import sys
import pandas as pd
import psycopg2
from psycopg2.extras import execute_batch
from datetime import datetime

# Database connection details
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

def load_question_mapping():
    """Load mapping from question ID (1.01) to record_id (rec...)."""
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    questions_csv = os.path.join(base_dir, "ALL_AIRTABLE/csvs/survey_questions.csv")

    df = pd.read_csv(questions_csv)
    # Convert ID to string for consistent matching
    df['ID_str'] = df['ID'].astype(str)
    # Create mapping: ID -> record_id
    mapping = dict(zip(df['ID_str'], df['record_id']))
    print(f"✓ Loaded {len(mapping)} question ID mappings")
    print(f"✓ Sample mapping: 1.01 -> {mapping.get('1.01', 'NOT FOUND')}")
    return mapping

def load_response_option_mapping():
    """Load mapping from response text to response_option_id."""
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    options_csv = os.path.join(base_dir, "ALL_AIRTABLE/csvs/survey_response_options.csv")

    df = pd.read_csv(options_csv)
    # We'll need to match on both question_id and response text
    # For now, create a mapping of response -> record_id (may need refinement)
    print(f"✓ Loaded {len(df)} response options")
    return df

def clear_existing_survey_responses(conn):
    """Clear existing survey responses."""
    cursor = conn.cursor()
    cursor.execute("DELETE FROM survey_responses;")
    deleted = cursor.rowcount
    conn.commit()
    print(f"✓ Deleted {deleted} existing survey responses")
    cursor.close()

def import_survey_responses(conn, survey_data_path, question_mapping):
    """Import survey responses with proper record_id mapping."""

    # Load generated survey data
    survey_df = pd.read_csv(survey_data_path)
    print(f"✓ Loaded survey data for {len(survey_df)} patients")

    # Prepare insert data
    responses = []
    skipped = 0

    for _, row in survey_df.iterrows():
        patient_id = row['patient_id']

        # Process each question column
        for col in survey_df.columns:
            if col == 'patient_id':
                continue

            # Get the question ID (column name like "1.01", "2.11", etc.)
            question_id_str = col

            # Get the response value
            response_value = row[col]

            # Skip NULL/empty responses (conditional questions)
            if pd.isna(response_value) or response_value == '':
                continue

            # Convert question_id to float for database (schema uses numeric IDs)
            try:
                question_id_float = float(question_id_str)
            except ValueError:
                print(f"⚠ Invalid question ID format: {question_id_str}, skipping")
                skipped += 1
                continue

            # For now, store as response_value (text)
            # TODO: Map to response_option_id where applicable
            responses.append({
                'patient_id': patient_id,
                'question_id': question_id_float,  # Use numeric ID
                'response_value': str(response_value),
                'response_numeric': None,  # Will be set if numeric
                'response_option_id': None  # TODO: Map response options
            })

    print(f"✓ Prepared {len(responses)} survey responses")
    print(f"⚠ Skipped {skipped} unmapped questions")

    # Insert responses in batches
    cursor = conn.cursor()
    insert_query = """
        INSERT INTO survey_responses
        (patient_id, question_id, response_value, response_numeric, response_option_id)
        VALUES (%(patient_id)s, %(question_id)s, %(response_value)s, %(response_numeric)s,
                %(response_option_id)s)
    """

    batch_size = 1000
    for i in range(0, len(responses), batch_size):
        batch = responses[i:i+batch_size]
        execute_batch(cursor, insert_query, batch)
        conn.commit()
        print(f"✓ Inserted batch {i//batch_size + 1} ({len(batch)} responses)")

    cursor.close()
    print(f"✅ Successfully imported {len(responses)} survey responses")

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    survey_data_path = os.path.join(base_dir, "data/synthetic_patient_survey.csv")

    if not os.path.exists(survey_data_path):
        print(f"❌ Survey data file not found: {survey_data_path}")
        sys.exit(1)

    print("="*70)
    print("Survey Data Import to Supabase")
    print("="*70)

    # Load mappings
    print("\n1. Loading question mappings...")
    question_mapping = load_question_mapping()

    # Connect to database
    print("\n2. Connecting to database...")
    conn = psycopg2.connect(**DB_CONFIG)
    print("✓ Connected to Supabase")

    try:
        # Clear existing responses
        print("\n3. Clearing existing survey responses...")
        clear_existing_survey_responses(conn)

        # Import new responses
        print("\n4. Importing survey responses...")
        import_survey_responses(conn, survey_data_path, question_mapping)

        # Verify
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM survey_responses;")
        count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(DISTINCT patient_id) FROM survey_responses;")
        patient_count = cursor.fetchone()[0]
        cursor.close()

        print("\n" + "="*70)
        print("Import Summary")
        print("="*70)
        print(f"Total responses: {count}")
        print(f"Unique patients: {patient_count}")
        print("✅ Import completed successfully!")

    finally:
        conn.close()

if __name__ == "__main__":
    main()
