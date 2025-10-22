#!/usr/bin/env python3
"""
Sync education modules from Airtable to Supabase.
Fetches all records from the Education Modules table and inserts/updates them in the database.
"""

import requests
import psycopg2
from datetime import datetime

# Airtable API configuration
AIRTABLE_API_KEY = os.getenv('AIRTABLE_API_KEY')
AIRTABLE_BASE_ID = "appy3YQaPkXp7asjj"  # WellPath Content System
AIRTABLE_TABLE_NAME = "Education Modules"

# Supabase configuration
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

def fetch_from_airtable():
    """Fetch all education modules from Airtable."""
    url = f"https://api.airtable.com/v0/{AIRTABLE_BASE_ID}/{AIRTABLE_TABLE_NAME}"
    headers = {
        "Authorization": f"Bearer {AIRTABLE_API_KEY}"
    }

    all_records = []
    offset = None

    while True:
        params = {}
        if offset:
            params['offset'] = offset

        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()

        all_records.extend(data.get('records', []))

        offset = data.get('offset')
        if not offset:
            break

    return all_records

def sync_to_database(records):
    """Sync education modules to Supabase."""
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    inserted = 0
    updated = 0

    for record in records:
        record_id = record['id']
        fields = record['fields']

        # Extract fields (handle missing fields gracefully)
        title = fields.get('Title', '')
        description = fields.get('Description', '')
        pillars = ','.join(fields.get('Pillars', [])) if isinstance(fields.get('Pillars'), list) else fields.get('Pillars', '')
        delivery_method = fields.get('Delivery Method', '')
        media_format = fields.get('Media Format', '')
        tags = ','.join(fields.get('Tags', [])) if isinstance(fields.get('Tags'), list) else fields.get('Tags', '')
        intake_markers = ','.join(fields.get('Intake Markers', [])) if isinstance(fields.get('Intake Markers'), list) else fields.get('Intake Markers', '')
        intake_metrics = ','.join(fields.get('Intake Metrics', [])) if isinstance(fields.get('Intake Metrics'), list) else fields.get('Intake Metrics', '')
        trigger_condition = fields.get('Trigger Condition', '')
        created = fields.get('Created', datetime.now().isoformat())
        last_modified = fields.get('Last Modified', datetime.now().isoformat())

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
    print("SYNCING EDUCATION MODULES FROM AIRTABLE")
    print("="*80)

    print("\n1. Fetching records from Airtable...")
    records = fetch_from_airtable()
    print(f"   ✓ Fetched {len(records)} records")

    print("\n2. Syncing to database...")
    inserted, updated = sync_to_database(records)
    print(f"   ✓ Inserted {inserted} new records")
    print(f"   ✓ Updated {updated} existing records")

    print("\n" + "="*80)
    print("✅ SYNC COMPLETE!")
    print("="*80)

if __name__ == "__main__":
    main()
