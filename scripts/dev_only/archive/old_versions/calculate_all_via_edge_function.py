#!/usr/bin/env python3
"""
Calculate all patient scores by calling Edge Function with pg_net
This makes it fast since it runs IN the database
"""
import psycopg2

DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

# Create a database function that calls the Edge Function using pg_net
sql = """
CREATE OR REPLACE FUNCTION calculate_all_wellpath_scores()
RETURNS TABLE(user_id uuid, score numeric, status text) AS $$
DECLARE
    patient_record RECORD;
    score_result numeric;
BEGIN
    FOR patient_record IN
        SELECT pd.user_id FROM patient_details pd
    LOOP
        BEGIN
            -- Call the Edge Function using HTTP (simpler than pg_net for now)
            -- For now, we'll return NULL and update via Python
            -- In production, you'd use pg_net extension

            RETURN QUERY SELECT
                patient_record.user_id,
                NULL::numeric as score,
                'pending'::text as status;

        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT
                patient_record.user_id,
                NULL::numeric,
                'error: ' || SQLERRM;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
"""

print("This approach won't work well - Edge Functions need HTTP calls")
print("The database can't easily call them in bulk.")
print()
print("Best approach: Use the Edge Function for ON-DEMAND single-patient calculations")
print("And use a Python/Node batch script for bulk updates (what we'll do now)")
print()

conn = psycopg2.connect(**DB_CONFIG)
cur = conn.cursor()

# Get all patients
cur.execute('SELECT user_id FROM patient_details')
patients = cur.fetchall()

print(f'Would need to call Edge Function {len(patients)} times')
print(f'At ~1 second per call, that\'s {len(patients)} seconds')
print()
print('Better solution: Create a PostgreSQL function with the scoring logic')
print('OR: Keep using Edge Function for single patients only')

cur.close()
conn.close()
