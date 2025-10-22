#!/usr/bin/env python3
"""
Sync education modules from Airtable CSV export to Supabase.
"""

import csv
import psycopg2
from datetime import datetime

# CSV file location
CSV_FILE = "/Users/keegs/Documents/GitHub/WellPath-V2-Backend/ALL_AIRTABLE/csvs/education_modules.csv"

# Supabase configuration
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}


def sync_from_csv():
    """Sync education modules from CSV to database."""
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    inserted = 0
    updated = 0

    with open(CSV_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for row in reader:
            record_id = row.get('record_id', '')
            if not record_id:
                print(f"  ⚠️  Skipping row with no record_id")
                continue

            # Extract fields (column names are lowercase in CSV)
            title = row.get('title', '')
            description = row.get('description', '')
            pillars = row.get('pillars', '')
            delivery_method = row.get('delivery_method', '')
            media_format = row.get('media_format', '')
            tags = row.get('tags', '')
            intake_markers = row.get('intake_markers', '')
            intake_metrics = row.get('intake_metrics', '')
            trigger_condition = row.get('trigger_condition', '') or None  # NULL if empty
            created = row.get('created', datetime.now().isoformat())
            last_modified = row.get('last_modified', datetime.now().isoformat())

            # Check if record exists
            cur.execute("SELECT record_id FROM education_modules WHERE record_id = %s", (record_id,))
            exists = cur.fetchone()

            if exists:
                # Update existing record
                cur.execute("""
                    UPDATE education_modules
                    SET title = %s,
                        description = %s,
                        pillars = %s,
                        delivery_method = %s,
                        media_format = %s,
                        tags = %s,
                        intake_markers = %s,
                        intake_metrics = %s,
                        trigger_condition = %s,
                        last_modified = %s
                    WHERE record_id = %s
                """, (title, description, pillars, delivery_method, media_format, tags,
                      intake_markers, intake_metrics, trigger_condition, last_modified, record_id))
                updated += 1
            else:
                # Insert new record
                cur.execute("""
                    INSERT INTO education_modules (
                        record_id, title, description, pillars, delivery_method,
                        media_format, tags, intake_markers, intake_metrics,
                        trigger_condition, created, last_modified
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (record_id, title, description, pillars, delivery_method, media_format,
                      tags, intake_markers, intake_metrics, trigger_condition, created, last_modified))
                inserted += 1

            if (inserted + updated) % 10 == 0:
                conn.commit()
                print(f"  Processed {inserted + updated} records...")

    conn.commit()
    cur.close()
    conn.close()

    return inserted, updated


def main():
    print("="*80)
    print("SYNCING EDUCATION MODULES FROM CSV")
    print("="*80)

    print(f"\n1. Reading from CSV: {CSV_FILE}")

    print("\n2. Syncing to database...")
    inserted, updated = sync_from_csv()
    print(f"   ✓ Inserted {inserted} new records")
    print(f"   ✓ Updated {updated} existing records")

    print("\n" + "="*80)
    print("✅ SYNC COMPLETE!")
    print("="*80)


if __name__ == "__main__":
    main()
