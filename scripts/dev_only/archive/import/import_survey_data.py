#!/usr/bin/env python3
"""
Import synthetic survey data from preliminary_data into Supabase.
This loads the 50 test patients' survey responses.
"""

import sys
import pandas as pd
import psycopg2
from datetime import datetime

# Supabase connection
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

def main():
    # Load survey data
    print("Loading survey data from preliminary_data...")
    survey_df = pd.read_csv('/Users/keegs/Documents/GitHub/preliminary_data/data/synthetic_patient_survey.csv')

    print(f"✓ Loaded {len(survey_df)} patients with {len(survey_df.columns)-1} questions")

    # Connect to Supabase
    print("\nConnecting to Supabase...")
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get question ID mapping (question_id -> record_id)
    print("Loading question ID mapping from database...")
    cur.execute("SELECT record_id FROM survey_questions")
    db_question_ids = [row[0] for row in cur.fetchall()]
    print(f"✓ Found {len(db_question_ids)} questions in database")

    # Since we can't easily map CSV columns to Airtable record IDs,
    # let's take a different approach: store responses with question_id as the simple ID (2.11, etc)
    # and handle the mapping in the application layer

    # First, check if we need to modify the schema
    print("\nNote: Survey responses will use simple question IDs (e.g., '2.11')")
    print("instead of Airtable record IDs for easier mapping.")

    total_responses = 0
    skipped_questions = 0

    # Delete existing survey responses for these patients (clean slate)
    patient_ids = survey_df['patient_id'].tolist()
    print(f"\nCleaning existing survey responses for {len(patient_ids)} patients...")
    # Cast to UUIDs using IN clause
    placeholders = ','.join(['%s'] * len(patient_ids))
    cur.execute(
        f"DELETE FROM survey_responses WHERE patient_id::text IN ({placeholders})",
        patient_ids
    )
    deleted_count = cur.rowcount
    print(f"✓ Deleted {deleted_count} existing responses")

    # Import survey responses
    print("\nImporting survey responses...")

    for idx, row in survey_df.iterrows():
        patient_id = row['patient_id']

        if (idx + 1) % 10 == 0:
            print(f"  Processing patient {idx + 1}/{len(survey_df)}...")

        patient_response_count = 0

        # Iterate through all columns except patient_id
        for col in survey_df.columns:
            if col == 'patient_id':
                continue

            # Skip if no response
            response = row[col]
            if pd.isna(response) or str(response).strip() == '':
                continue

            # Insert survey response
            # We'll use question_id as the simple ID (e.g., "2.11") for now
            # The response_option_id will be NULL since we're storing raw text
            try:
                cur.execute("""
                    INSERT INTO survey_responses (patient_id, question_id, response_value, created_at)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (patient_id, question_id) DO UPDATE
                    SET response_value = EXCLUDED.response_value
                """, (patient_id, col, str(response), datetime.now()))

                patient_response_count += 1
                total_responses += 1
            except Exception as e:
                conn.rollback()  # Rollback failed transaction
                if 'violates foreign key constraint' in str(e):
                    # Question doesn't exist in database
                    skipped_questions += 1
                else:
                    print(f"Error inserting response for patient {patient_id}, question {col}: {e}")
                    break  # Skip rest of patient's responses

        # Commit after each patient
        try:
            conn.commit()
        except Exception as e:
            print(f"Error committing patient {patient_id}: {e}")
            conn.rollback()

    print(f"\n✓ Successfully imported {total_responses} survey responses")
    print(f"  Skipped {skipped_questions} responses for questions not in database")

    # Summary
    print("\nSummary:")
    cur.execute("""
        SELECT COUNT(DISTINCT patient_id) as patients, COUNT(*) as responses
        FROM survey_responses
    """)
    result = cur.fetchone()
    print(f"  Total patients with survey data: {result[0]}")
    print(f"  Total survey responses: {result[1]}")

    # Check our test patient
    cur.execute("""
        SELECT COUNT(*) FROM survey_responses
        WHERE patient_id = '83a28af3-82ef-4ddb-8860-ac23275a5c32'
    """)
    test_patient_count = cur.fetchone()[0]
    print(f"\n  Test patient 83a28af3 has {test_patient_count} responses")

    cur.close()
    conn.close()

    print("\n✅ Import complete!")

if __name__ == "__main__":
    main()
