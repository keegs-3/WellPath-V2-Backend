#!/usr/bin/env python3
"""
Export all Airtable tables from WellPath Content System to CSV files.
Saves files as 'table_name.csv' in specified folder, overwriting existing files.
"""

import os
import csv
import json
import time
import requests
from typing import Dict, List, Any

# Configuration
AIRTABLE_API_KEY = os.getenv('AIRTABLE_API_KEY')
BASE_ID = 'appy3YQaPkXp7asjj'  # WellPath Content System
# Use path from Git root - works in both /Documents/GitHub and OneDrive locations
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GIT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, '..', '..'))
OUTPUT_DIR = os.path.join(GIT_ROOT, 'ALL_AIRTABLE', 'csvs')

# API endpoints
BASE_URL = f'https://api.airtable.com/v0/{BASE_ID}'
META_URL = f'https://api.airtable.com/v0/meta/bases/{BASE_ID}/tables'

# Headers for API requests
headers = {
    'Authorization': f'Bearer {AIRTABLE_API_KEY}',
    'Content-Type': 'application/json'
}

def ensure_output_dir():
    """Create output directory if it doesn't exist."""
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
        print(f"Created output directory: {OUTPUT_DIR}")
    else:
        print(f"Output directory exists: {OUTPUT_DIR}")

def get_all_tables():
    """Fetch all tables in the base."""
    print("Fetching table list...")
    response = requests.get(META_URL, headers=headers)
    
    if response.status_code != 200:
        print(f"Error fetching tables: {response.status_code}")
        print(f"Response: {response.text}")
        return None
    
    data = response.json()
    tables = data.get('tables', [])
    print(f"Found {len(tables)} tables")
    return tables

def clean_table_name(name):
    """Convert table name to filename-safe format."""
    # Replace spaces with underscores, remove special characters
    cleaned = name.replace(' ', '_').replace('-', '_')
    # Remove any other problematic characters
    cleaned = ''.join(c for c in cleaned if c.isalnum() or c == '_')
    return cleaned.lower()

def get_all_records(table_id, table_name):
    """Fetch all records from a table, handling pagination."""
    records = []
    offset = None
    
    while True:
        url = f"{BASE_URL}/{table_id}"
        params = {
            'view': 'Grid view'  # Use Grid view to get only visible fields
        }
        if offset:
            params['offset'] = offset
        
        response = requests.get(url, headers=headers, params=params)
        
        if response.status_code != 200:
            print(f"  ❌ Error fetching records: {response.status_code}")
            return None
        
        data = response.json()
        records.extend(data.get('records', []))
        
        offset = data.get('offset')
        if not offset:
            break
        
        # Rate limiting - Airtable allows 5 requests per second
        time.sleep(0.2)
    
    return records

def export_table_to_csv(table, records):
    """Export table records to CSV file."""
    table_name = table['name']
    clean_name = clean_table_name(table_name)
    filename = f"{clean_name}.csv"
    filepath = os.path.join(OUTPUT_DIR, filename)
    
    if not records:
        print(f"  ⚠️  No records to export")
        return False
    
    # Get all unique field names from all records
    all_fields = set()
    for record in records:
        if 'fields' in record:
            all_fields.update(record['fields'].keys())
    
    # Check if record_id already exists as a field in Airtable
    has_record_id_field = 'record_id' in all_fields
    
    # Remove record_id from all_fields to avoid duplication
    all_fields.discard('record_id')
    
    # Sort fields alphabetically for consistent output
    fieldnames = ['record_id'] + sorted(list(all_fields))
    
    # Write to CSV
    try:
        with open(filepath, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            
            for record in records:
                # Handle record_id field
                if has_record_id_field:
                    # Use the record_id from Airtable fields if it exists
                    airtable_record_id = record.get('fields', {}).get('record_id', '')
                    row = {'record_id': airtable_record_id if airtable_record_id else record['id']}
                else:
                    # Use Airtable's internal record ID as fallback
                    row = {'record_id': record['id']}
                
                # Add all other field values
                for field in all_fields:
                    value = record.get('fields', {}).get(field, '')
                    
                    # Handle different data types
                    if isinstance(value, list):
                        # Convert lists to comma-separated strings
                        row[field] = ', '.join(str(v) for v in value)
                    elif isinstance(value, dict):
                        # Convert dicts to JSON strings
                        row[field] = json.dumps(value)
                    else:
                        row[field] = value
                
                writer.writerow(row)
        
        print(f"  ✅ Exported to: {filename} ({len(records)} records)")
        return True
        
    except Exception as e:
        print(f"  ❌ Error writing CSV: {str(e)}")
        return False

def main():
    """Main execution function."""
    print("=" * 60)
    print("AIRTABLE TO CSV EXPORTER")
    print("=" * 60)
    print(f"Base: WellPath Content System ({BASE_ID})")
    print(f"Output: {OUTPUT_DIR}")
    print("=" * 60)
    
    # Check API key
    if AIRTABLE_API_KEY == 'YOUR_API_KEY_HERE':
        print("\n❌ ERROR: Please update AIRTABLE_API_KEY in the script")
        print("   It should look like: patXXXXXXXXX.YYYYYYYYYYYYYYYYYYYY")
        return
    
    # Ensure output directory exists
    ensure_output_dir()
    
    # Get all tables
    tables = get_all_tables()
    if not tables:
        print("❌ Failed to fetch tables. Check your API key.")
        return
    
    # Process each table
    successful = 0
    failed = 0
    empty = 0
    
    print("\nStarting export...\n")
    
    for i, table in enumerate(tables, 1):
        table_id = table['id']
        table_name = table['name']
        
        print(f"[{i}/{len(tables)}] Processing: {table_name}")
        
        # Fetch records
        records = get_all_records(table_id, table_name)
        
        if records is None:
            failed += 1
            continue
        
        if len(records) == 0:
            print(f"  ⚠️  Table is empty, skipping")
            empty += 1
            continue
        
        # Export to CSV
        if export_table_to_csv(table, records):
            successful += 1
        else:
            failed += 1
        
        # Rate limiting between tables
        time.sleep(0.2)
    
    # Summary
    print("\n" + "=" * 60)
    print("EXPORT COMPLETE")
    print("=" * 60)
    print(f"✅ Successfully exported: {successful} tables")
    print(f"⚠️  Empty tables skipped: {empty}")
    print(f"❌ Failed exports: {failed}")
    print(f"\n📁 Files saved to: {OUTPUT_DIR}")
    print("=" * 60)

if __name__ == "__main__":
    main()
