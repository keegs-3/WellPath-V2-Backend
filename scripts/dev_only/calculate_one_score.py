#!/usr/bin/env python3
"""
Test calculating score for one patient
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

user_id = '527cab3c-8a78-4b8b-91d9-fdeb59f8f257'

print(f'Testing score calculation for patient {user_id}...\n')

# Call the Edge Function
url = f'{SUPABASE_URL}/functions/v1/calculate-wellpath-score'
headers = {
    'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
    'Content-Type': 'application/json'
}
data = {'patient_id': user_id}

print(f'Calling: {url}')
print(f'Headers: {headers}')
print(f'Body: {data}\n')

response = requests.post(url, headers=headers, json=data, timeout=30)

print(f'Status Code: {response.status_code}')
print(f'Response: {response.text}\n')

if response.status_code == 200:
    score_data = response.json()
    overall_score = score_data['overall_score']

    print(f'✓ Overall Score: {overall_score * 100:.1f}%')
    print(f'\nPillar Scores:')
    for pillar in score_data.get('pillar_scores', []):
        print(f"  {pillar['pillar_name']}: {pillar['final_score'] * 100:.1f}%")

    # Update patient_details
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    cur.execute('UPDATE patient_details SET wellpath_score = %s WHERE user_id = %s', (overall_score, user_id))
    conn.commit()
    cur.close()
    conn.close()

    print(f'\n✓ Updated patient_details.wellpath_score')
else:
    print(f'✗ Error: {response.status_code}')
