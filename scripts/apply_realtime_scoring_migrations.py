#!/usr/bin/env python3
"""
Apply all 5 real-time scoring migrations in sequence
"""

import psycopg2
import os

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

migrations = [
    "20251027_01_add_data_source_tracking_to_score_items.sql",
    "20251027_02_create_data_entry_fields_mappings.sql",
    "20251027_03_create_patient_behavioral_values.sql",
    "20251027_04_create_survey_response_options_numeric_values.sql",
    "20251027_05_create_behavioral_threshold_config.sql"
]

def apply_migrations():
    """Apply all migrations in sequence"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        for migration_file in migrations:
            migration_path = f'/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/{migration_file}'

            print(f"\n{'='*60}")
            print(f"Applying: {migration_file}")
            print(f"{'='*60}")

            with open(migration_path, 'r') as f:
                sql = f.read()

            cur.execute(sql)
            conn.commit()
            print(f"✅ Successfully applied {migration_file}")

        print(f"\n{'='*60}")
        print("✅ All 5 migrations applied successfully!")
        print(f"{'='*60}\n")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error applying migrations: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    apply_migrations()
