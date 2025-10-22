#!/usr/bin/env python3
"""
Test the calculate-wellpath-score Edge Function and save results to patient_details
"""
import requests
import psycopg2
import json

SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTI4NTI0NzQsImV4cCI6MjAyODQyODQ3NH0.8VZqHYqBxEhE_5L6Z1X0QxH-kZN9Hj7jZ1YxQ_qQZmk'

# Database connection
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

def test_edge_function(patient_id):
    """Call the Edge Function directly via HTTP"""
    print(f"Testing Edge Function for patient {patient_id}...")

    # Make direct HTTP request to the Edge Function
    url = f"{SUPABASE_URL}/functions/v1/calculate-wellpath-score"
    headers = {
        'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
        'Content-Type': 'application/json'
    }
    data = {'patient_id': patient_id}

    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)

        if response.status_code == 200:
            result = response.json()
            print(f"\n✅ Success! Overall Score: {result['overall_score']:.2%}")
            print(f"\nPillar Scores:")
            for pillar in result['pillar_scores']:
                print(f"  {pillar['pillar_name']}: {pillar['final_score']:.2%}")
            return result
        else:
            print(f"\n❌ Error {response.status_code}: {response.text}")

            # If auth fails, try calling the database function directly
            print("\nAuth failed. Let me calculate the score directly in the database instead...")
            return calculate_score_in_db(patient_id)

    except Exception as e:
        print(f"\n❌ Error calling Edge Function: {e}")
        print("\nTrying direct database calculation instead...")
        return calculate_score_in_db(patient_id)

def calculate_score_in_db(patient_id):
    """Calculate score directly in the database"""
    print("Calculating score directly in database (simplified version)...")

    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get basic patient info
    cur.execute("""
        SELECT
            user_id,
            (SELECT COUNT(*) FROM patient_biomarker_readings WHERE user_id = %s) as biomarker_count,
            (SELECT COUNT(*) FROM patient_biometric_readings WHERE user_id = %s) as biometric_count,
            (SELECT COUNT(*) FROM patient_survey_responses WHERE user_id = %s) as survey_count
        FROM patient_details
        WHERE user_id = %s
    """, (patient_id, patient_id, patient_id, patient_id))

    result = cur.fetchone()
    if result:
        print(f"\n✅ Patient Data Found:")
        print(f"  - {result[1]} biomarker readings")
        print(f"  - {result[2]} biometric readings")
        print(f"  - {result[3]} survey responses")

        # For now, just show that data exists
        # Full scoring logic is in the Edge Function
        print(f"\n⚠️  Edge Function is needed for full score calculation")
        print(f"   Data is ready - just need proper authentication to call the function")

    cur.close()
    conn.close()
    return None

if __name__ == "__main__":
    # Get first patient
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    cur.execute("SELECT user_id FROM patient_details LIMIT 1")
    patient_id = cur.fetchone()[0]
    cur.close()
    conn.close()

    print(f"Testing with patient: {patient_id}\n")
    test_edge_function(patient_id)
