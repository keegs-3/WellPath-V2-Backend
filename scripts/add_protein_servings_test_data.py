#!/usr/bin/env python3
"""
Add Protein Servings Test Data
Adds protein servings entries alongside existing protein grams entries
so both AGG_PROTEIN_GRAMS and AGG_PROTEIN_SERVINGS have data
"""

import psycopg2
from datetime import datetime, timedelta
import uuid

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
USER_ID = '1758fa60-a306-440e-8ae6-9e68fd502bc2'  # test@wellpath.dev

def main():
    print("🥩 Adding Protein Servings Test Data")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        with conn.cursor() as cur:
            # Get all existing protein grams entries
            cur.execute("""
                SELECT
                    entry_date,
                    entry_timestamp,
                    value_quantity as grams,
                    event_instance_id
                FROM patient_data_entries
                WHERE user_id = %s
                  AND field_id = 'DEF_PROTEIN_GRAMS'
                ORDER BY entry_date, entry_timestamp;
            """, (USER_ID,))

            protein_entries = cur.fetchall()
            print(f"Found {len(protein_entries)} protein grams entries")

            # For each protein grams entry, add corresponding servings entry
            servings_added = 0
            for entry_date, entry_timestamp, grams, event_id in protein_entries:
                # Convert grams to servings (25g = 1 serving)
                servings = grams / 25.0

                # Insert servings entry with same event_instance_id
                cur.execute("""
                    INSERT INTO patient_data_entries (
                        user_id,
                        field_id,
                        entry_date,
                        entry_timestamp,
                        value_quantity,
                        source,
                        event_instance_id
                    ) VALUES (%s, %s, %s, %s, %s, 'import', %s)
                    ON CONFLICT DO NOTHING;
                """, (
                    USER_ID,
                    'DEF_PROTEIN_SERVINGS',
                    entry_date,
                    entry_timestamp,
                    servings,
                    event_id  # Same event_instance_id links them
                ))

                if cur.rowcount > 0:
                    servings_added += 1

            conn.commit()

            print(f"✅ Added {servings_added} protein servings entries")
            print("\nNow process aggregations:")
            print("  python3 scripts/process_all_aggregations_for_user.py")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
