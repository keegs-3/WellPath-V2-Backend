#!/usr/bin/env python3
"""
Fix the link between patient_details and auth_users
Also add first_name and last_name to auth_users for test patients
"""

import psycopg2

DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

DEFAULT_PRACTICE_ID = 'a1b2c3d4-5678-90ab-cdef-123456789abc'

def main():
    print("Fixing patient-user links and adding names...\n")

    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get all test patients
    cur.execute("""
        SELECT pd.id, au.id as auth_user_id, au.email
        FROM patient_details pd
        LEFT JOIN auth_users au ON pd.id = au.id
        WHERE pd.practice_id = %s
        ORDER BY au.email
    """, (DEFAULT_PRACTICE_ID,))

    patients = cur.fetchall()
    print(f"Found {len(patients)} test patients\n")

    updated = 0
    for idx, (patient_id, auth_user_id, email) in enumerate(patients):
        if not auth_user_id:
            print(f"⚠ Patient {patient_id} has no matching auth user")
            continue

        # Update patient_details.user_id to link to auth_users
        cur.execute("""
            UPDATE patient_details
            SET user_id = %s
            WHERE id = %s
        """, (auth_user_id, patient_id))

        # Update auth_users with first_name and last_name
        first_name = f"Test{idx}"
        last_name = f"Patient{idx}"

        cur.execute("""
            UPDATE auth_users
            SET first_name = %s,
                last_name = %s
            WHERE id = %s
        """, (first_name, last_name, auth_user_id))

        print(f"✓ Updated patient {idx}: {email} -> {first_name} {last_name}")
        updated += 1

    conn.commit()
    cur.close()
    conn.close()

    print(f"\n{'='*70}")
    print(f"Updated {updated} patients")
    print(f"{'='*70}")

if __name__ == "__main__":
    main()
