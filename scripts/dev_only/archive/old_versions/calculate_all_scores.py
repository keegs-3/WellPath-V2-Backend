#!/usr/bin/env python3
"""
Calculate WellPath scores for all patients and update patient_details
"""
import psycopg2
import requests
import json

SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

def calculate_all_scores():
    print('Fetching all patients...')

    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get all patients
    cur.execute('SELECT user_id FROM patient_details')
    patients = cur.fetchall()

    print(f'Found {len(patients)} patients\n')

    success_count = 0
    error_count = 0

    for (user_id,) in patients:
        try:
            print(f'Calculating score for patient {user_id}...')

            # Call the Edge Function
            url = f'{SUPABASE_URL}/functions/v1/calculate-wellpath-score'
            headers = {
                'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
                'Content-Type': 'application/json'
            }
            data = {'patient_id': user_id}

            response = requests.post(url, headers=headers, json=data, timeout=30)

            if response.status_code != 200:
                print(f'  Error: {response.status_code} - {response.text}')
                error_count += 1
                continue

            score_data = response.json()
            overall_score = score_data['overall_score']

            # Update patient_details with the score
            cur.execute('''
                UPDATE patient_details
                SET wellpath_score = %s
                WHERE user_id = %s
            ''', (overall_score, user_id))
            conn.commit()

            print(f'  Score: {overall_score * 100:.1f}%')
            success_count += 1

        except Exception as e:
            print(f'  Exception: {e}')
            error_count += 1

    cur.close()
    conn.close()

    print()
    print('=' * 80)
    print('SUMMARY')
    print('=' * 80)
    print(f'Total patients: {len(patients)}')
    print(f'Successfully calculated: {success_count}')
    print(f'Errors: {error_count}')

if __name__ == '__main__':
    calculate_all_scores()
