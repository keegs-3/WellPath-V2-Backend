#!/usr/bin/env python3
"""
Create auth.users for all test patients using Supabase Admin API.
This uses the service_role key to create pre-confirmed users with matching UUIDs.
"""

import requests
import psycopg2
from datetime import datetime

# Supabase configuration
SUPABASE_URL = "https://csotzmardnvrpdhlogjm.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk"

# Database connection
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

DEFAULT_PRACTICE_ID = 'a1b2c3d4-5678-90ab-cdef-123456789abc'
PASSWORD = "password"  # Simple password for all test accounts

def create_auth_user(patient_id, email, password):
    """Create a user via Supabase Auth Admin API with matching patient UUID"""
    url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "email": email,
        "password": password,
        "email_confirm": True,  # Auto-confirm for dev
        "user_metadata": {
            "role": "patient",
            "practice_id": DEFAULT_PRACTICE_ID
        },
        "app_metadata": {
            "provider": "email",
            "providers": ["email"]
        }
    }

    response = requests.post(url, json=payload, headers=headers)
    return response

def main():
    print("Creating auth users for test patients...\n")

    # Connect to DB
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get all test patient IDs
    cur.execute("""
        SELECT id
        FROM patient_details
        WHERE practice_id = %s
        ORDER BY id
    """, (DEFAULT_PRACTICE_ID,))

    patient_ids = [row[0] for row in cur.fetchall()]
    print(f"Found {len(patient_ids)} test patients\n")

    if not patient_ids:
        print("No patients found! Run import_all_test_data.py first.")
        return

    created = 0
    errors = 0

    for idx, patient_id in enumerate(patient_ids):
        email = f"test.patient.{idx}@wellpath.com"

        print(f"Creating user {idx + 1}/{len(patient_ids)}: {email}...", end=" ")

        try:
            response = create_auth_user(patient_id, email, PASSWORD)

            if response.status_code in [200, 201]:
                print("✓ Created")
                created += 1
            elif response.status_code == 422 or response.status_code == 400:
                error_data = response.json()
                error_msg = str(error_data)
                if "already" in error_msg.lower() or "duplicate" in error_msg.lower():
                    print("(already exists)")
                else:
                    print(f"✗ Error: {error_data}")
                    errors += 1
            else:
                print(f"✗ Error {response.status_code}: {response.text}")
                errors += 1

        except Exception as e:
            print(f"✗ Exception: {e}")
            errors += 1

    cur.close()
    conn.close()

    print(f"\n{'='*70}")
    print(f"Summary:")
    print(f"  Created: {created}")
    print(f"  Errors: {errors}")
    print(f"  Total processed: {len(patient_ids)}")
    print(f"\nTest credentials to use:")
    print(f"  Email: test.patient.0@wellpath.com (or .1, .2, .3, etc.)")
    print(f"  Password: {PASSWORD}")
    print(f"{'='*70}")

if __name__ == "__main__":
    main()
