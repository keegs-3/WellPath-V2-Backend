#!/usr/bin/env python3
"""
Create auth.users entries for all test patients in patient_details table.
Password for all test patients: "password" (DEV_BYPASS_AUTH=true bypasses validation)
"""

import os
from supabase import create_client, Client
import psycopg2

# Supabase setup
SUPABASE_URL = "https://csotzmardnvrpdhlogjm.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")  # Need service role key for admin API

# DB connection for reading patient data
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

# Default practice ID (same as import script)
DEFAULT_PRACTICE_ID = 'a1b2c3d4-5678-90ab-cdef-123456789abc'

def main():
    if not SUPABASE_SERVICE_ROLE_KEY:
        print("ERROR: SUPABASE_SERVICE_ROLE_KEY environment variable not set.")
        print("Get this from: Supabase Dashboard > Project Settings > API > service_role key")
        return

    # Connect to DB to get patient list
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get all test patients
    cur.execute("""
        SELECT DISTINCT pd.id
        FROM patient_details pd
        WHERE pd.practice_id = %s
        ORDER BY pd.id
        LIMIT 10
    """, (DEFAULT_PRACTICE_ID,))

    patients = cur.fetchall()
    print(f"Found {len(patients)} test patients")

    if not patients:
        print("No patients found! Run import_all_test_data.py first.")
        return

    # Initialize Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    created_count = 0
    error_count = 0

    for idx, (patient_id,) in enumerate(patients):
        email = f"test.patient.{idx}@wellpath.com"
        password = "password"  # Simple password for dev (DEV_BYPASS_AUTH=true allows any password)

        try:
            # Create user in auth.users using admin API
            user = supabase.auth.admin.create_user({
                "email": email,
                "password": password,
                "email_confirm": True,  # Auto-confirm email
                "user_metadata": {
                    "role": "patient",
                    "practice_id": DEFAULT_PRACTICE_ID
                }
            })

            print(f"✓ Created auth user {idx}: {email}")
            created_count += 1

        except Exception as e:
            if "already registered" in str(e).lower() or "duplicate" in str(e).lower():
                print(f"  User {email} already exists (skipping)")
            else:
                print(f"✗ Error creating {email}: {e}")
                error_count += 1

    cur.close()
    conn.close()

    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Created: {created_count}")
    print(f"  Errors: {error_count}")
    print(f"  Skipped (already exist): {len(patients) - created_count - error_count}")
    print(f"\nTest credentials:")
    print(f"  Email: test.patient.0@wellpath.com (or test.patient.1, 2, 3...)")
    print(f"  Password: password")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
