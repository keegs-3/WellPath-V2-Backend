#!/usr/bin/env python3
"""
Calculate scores using the existing scoring service and save to patient_details
"""
import sys
sys.path.insert(0, '/Users/keegs/Documents/GitHub/WellPath-V2-Backend')

from database.postgres_client import PostgresClient
from scoring_engine.scoring_service import WellPathScoringService
import psycopg2

DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

print("Initializing scoring service...")
db = PostgresClient()
scoring_service = WellPathScoringService(db)

# Get all patients
conn = psycopg2.connect(**DB_CONFIG)
cur = conn.cursor()
cur.execute('SELECT user_id FROM patient_details LIMIT 5')  # Start with 5 patients
patients = cur.fetchall()

print(f'\nCalculating scores for {len(patients)} patients...\n')

success_count = 0
error_count = 0

for (user_id,) in patients:
    try:
        print(f'Patient {user_id}:')

        # Calculate scores
        results = scoring_service.calculate_patient_scores(user_id)

        overall_score = results['overall_score']
        print(f'  Overall Score: {overall_score}%')

        # Show pillar breakdown
        for pillar_name, score in results['pillar_scores'].items():
            print(f'    {pillar_name}: {score}%')

        # Update patient_details (convert percentage to 0-1 scale)
        cur.execute('''
            UPDATE patient_details
            SET wellpath_score = %s
            WHERE user_id = %s
        ''', (overall_score / 100.0, user_id))
        conn.commit()

        print(f'  ✓ Saved to database\n')
        success_count += 1

    except Exception as e:
        print(f'  ✗ Error: {e}\n')
        error_count += 1

cur.close()
conn.close()

print('=' * 80)
print(f'Success: {success_count}, Errors: {error_count}')
