#!/usr/bin/env python3
"""
Calculate scores for all patients using Edge Function and save to DB
"""
import psycopg2
import requests
import json
from concurrent.futures import ThreadPoolExecutor, as_completed

SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

def calculate_score(user_id):
    """Calculate score for one patient"""
    url = f'{SUPABASE_URL}/functions/v1/calculate-wellpath-score'
    headers = {
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json'
    }
    data = {'patient_id': user_id}

    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)
        if response.status_code == 200:
            result = response.json()
            score = result['overall_score']
            return (user_id, score, None)
        else:
            return (user_id, None, f"HTTP {response.status_code}")
    except Exception as e:
        return (user_id, None, str(e))

# Get all patients
conn = psycopg2.connect(**DB_CONFIG)
cur = conn.cursor()
cur.execute('SELECT user_id FROM patient_details')
patients = [row[0] for row in cur.fetchall()]

print(f'Calculating scores for {len(patients)} patients...\n')

# Use thread pool to parallelize (10 concurrent requests)
success = 0
failed = 0

with ThreadPoolExecutor(max_workers=10) as executor:
    futures = {executor.submit(calculate_score, uid): uid for uid in patients}

    for future in as_completed(futures):
        user_id, score, error = future.result()

        if score is not None:
            # Update database
            cur.execute('UPDATE patient_details SET wellpath_score = %s WHERE user_id = %s', (score, user_id))
            conn.commit()
            print(f'✓ {user_id}: {score*100:.1f}%')
            success += 1
        else:
            print(f'✗ {user_id}: {error}')
            failed += 1

cur.close()
conn.close()

print(f'\n{"="*60}')
print(f'Success: {success}/{len(patients)}')
print(f'Failed: {failed}/{len(patients)}')
print(f'{"="*60}')
