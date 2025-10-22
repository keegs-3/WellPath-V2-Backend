#!/usr/bin/env python3
"""
Clean up Airtable field names and generate matching Supabase schema.
This script will:
1. Rename Airtable fields to use clean, consistent naming
2. Generate SQL schema that matches the cleaned names
"""

import requests
import json
import re
import time

# Configuration
AIRTABLE_API_KEY = os.getenv('AIRTABLE_API_KEY')
BASE_ID = 'appy3YQaPkXp7asjj'  # WellPath Content System

headers = {
    'Authorization': f'Bearer {AIRTABLE_API_KEY}',
    'Content-Type': 'application/json'
}

# Tables to clean up (prioritized list)
PRIORITY_TABLES = [
    ('tblw5x9ZIxeCZT9Jv', 'recommendations_v2'),
    ('tbliipv0kr5mHoSCY', 'metric_types_vfinal'),
    ('tblrqKOn9Jok1Dt9m', 'trigger_conditions'),
    ('tbl2RykLsyjEP4W29', 'nudges_v2'),
    ('tblAjjUE7bQ21mYyf', 'checkins_v2'),
    ('tbl63FsQ9U4Gyjdgx', 'checkin_questions_v2'),
    ('tbl3zO5xDgq9imK8L', 'response_options_v2'),
    ('tblykT3bgqG80B3pf', 'challenges_v3'),
    ('tblWl2i7a9yfLFKvC', 'adherence_scoring_v2'),
    ('tblGmoQqYZwynqejS', 'operator_definitions'),
    ('tblmX8QTJQt6NP8wT', 'linked_evidence'),
    ('tblZcFME4WUxMQdnq', 'pillars'),
    ('tbllglECYQRZPqPLK', 'intake_markers_raw'),
    ('tblRzknI1wxxNAFNj', 'intake_metrics_raw'),
]

def clean_field_name(name):
    """
    Convert field names to clean snake_case.
    Examples:
    - "Raw_impact" -> "raw_impact"
    - "Primary Markers" -> "primary_markers"
    - "ui_display (from units)" -> "ui_display_from_units"
    - "Last Modified By" -> "last_modified_by"
    """
    # Remove parenthetical content and merge with main name
    name = re.sub(r'\s*\((from[^)]+)\)', r'_\1', name)
    name = re.sub(r'\s*\([^)]+\)', '', name)
    
    # Replace spaces and special characters with underscores
    name = re.sub(r'[^a-zA-Z0-9_]', '_', name)
    
    # Convert to lowercase
    name = name.lower()
    
    # Remove multiple underscores
    name = re.sub(r'_+', '_', name)
    
    # Remove leading/trailing underscores
    name = name.strip('_')
    
    return name

def get_table_fields(table_id):
    """Get all fields for a table."""
    url = f'https://api.airtable.com/v0/meta/bases/{BASE_ID}/tables/{table_id}'
    response = requests.get(url, headers=headers)
    
    if response.status_code != 200:
        print(f"Error fetching table {table_id}: {response.status_code}")
        return None
    
    return response.json()

def update_field_name(table_id, field_id, new_name, old_name):
    """Update a single field name in Airtable."""
    url = f'https://api.airtable.com/v0/meta/bases/{BASE_ID}/tables/{table_id}/fields/{field_id}'
    
    payload = {
        "name": new_name
    }
    
    response = requests.patch(url, headers=headers, json=payload)
    
    if response.status_code == 200:
        print(f"  ✓ Renamed '{old_name}' -> '{new_name}'")
        return True
    else:
        print(f"  ✗ Failed to rename '{old_name}': {response.status_code} - {response.text}")
        return False

def generate_sql_for_table(table_name, fields):
    """Generate SQL CREATE TABLE statement for cleaned fields."""
    sql = f"CREATE TABLE {table_name} (\n"
    
    field_definitions = []
    
    for field in fields:
        field_name = clean_field_name(field['name'])
        field_type = field.get('type', 'singleLineText')
        
        # Map Airtable types to PostgreSQL types
        if field_name == 'record_id':
            sql_type = 'TEXT PRIMARY KEY'
        elif field_type in ['singleLineText', 'multilineText', 'richText', 'email', 'phoneNumber', 'url']:
            sql_type = 'TEXT'
        elif field_type in ['number', 'percent', 'currency', 'rating']:
            sql_type = 'NUMERIC'
        elif field_type in ['date', 'dateTime']:
            sql_type = 'TIMESTAMP'
        elif field_type == 'checkbox':
            sql_type = 'BOOLEAN'
        elif field_type in ['singleSelect', 'multipleSelects']:
            sql_type = 'TEXT[]' if field_type == 'multipleSelects' else 'TEXT'
        elif field_type in ['multipleRecordLinks', 'multipleLookupValues']:
            sql_type = 'TEXT[]'
        elif field_type == 'singleCollaborator':
            sql_type = 'TEXT'
        elif field_type == 'multipleCollaborators':
            sql_type = 'TEXT[]'
        elif field_type == 'multipleAttachments':
            sql_type = 'JSONB'
        elif field_type == 'formula':
            # Skip formula fields in database as they're calculated
            continue
        elif field_type == 'count':
            sql_type = 'INTEGER'
        elif field_type == 'lookup':
            sql_type = 'TEXT[]'  # Usually multiple values
        elif field_type == 'rollup':
            sql_type = 'JSONB'
        elif field_type in ['createdTime', 'lastModifiedTime']:
            sql_type = 'TIMESTAMP'
        elif field_type in ['createdBy', 'lastModifiedBy']:
            sql_type = 'TEXT'
        else:
            sql_type = 'TEXT'  # Default to TEXT for unknown types
        
        field_definitions.append(f"    {field_name} {sql_type}")
    
    sql += ",\n".join(field_definitions)
    sql += "\n);\n"
    
    return sql

def main():
    print("=" * 60)
    print("AIRTABLE FIELD NAME CLEANUP & SCHEMA GENERATION")
    print("=" * 60)
    
    print("\n⚠️  WARNING: This will rename fields in your Airtable!")
    print("Make sure you have a backup or are comfortable with the changes.")
    response = input("\nDo you want to:\n1. Just generate SQL (no Airtable changes)\n2. Rename fields AND generate SQL\n\nChoice (1 or 2): ")
    
    update_airtable = (response == '2')
    
    all_sql = []
    all_sql.append("-- WellPath Supabase Schema")
    all_sql.append("-- Generated from cleaned Airtable field names")
    all_sql.append("-- =" * 30)
    all_sql.append("")
    
    for table_id, table_name in PRIORITY_TABLES:
        print(f"\nProcessing {table_name} ({table_id})...")
        
        # Get table structure
        table_data = get_table_fields(table_id)
        if not table_data:
            continue
        
        fields = table_data.get('fields', [])
        
        # Track field mappings
        field_mappings = []
        
        for field in fields:
            old_name = field['name']
            new_name = clean_field_name(old_name)
            
            if old_name != new_name:
                field_mappings.append((field['id'], old_name, new_name))
        
        # Update field names if requested
        if update_airtable and field_mappings:
            print(f"  Renaming {len(field_mappings)} fields...")
            for field_id, old_name, new_name in field_mappings:
                update_field_name(table_id, field_id, new_name, old_name)
                time.sleep(0.2)  # Rate limiting
        elif field_mappings:
            print(f"  Would rename {len(field_mappings)} fields (dry run)")
            for _, old_name, new_name in field_mappings[:5]:  # Show first 5
                print(f"    '{old_name}' -> '{new_name}'")
            if len(field_mappings) > 5:
                print(f"    ... and {len(field_mappings) - 5} more")
        
        # Generate SQL
        sql = generate_sql_for_table(table_name, fields)
        all_sql.append(f"-- Table: {table_name}")
        all_sql.append(sql)
    
    # Add indexes
    all_sql.append("-- =" * 30)
    all_sql.append("-- INDEXES")
    all_sql.append("-- =" * 30)
    all_sql.append("")
    all_sql.append("-- Primary lookups")
    all_sql.append("CREATE INDEX idx_recommendations_v2_id ON recommendations_v2(id);")
    all_sql.append("CREATE INDEX idx_metric_types_identifier ON metric_types_vfinal(identifier);")
    all_sql.append("CREATE INDEX idx_trigger_conditions_id ON trigger_conditions(id);")
    all_sql.append("")
    all_sql.append("-- Array searches for linked records")
    all_sql.append("CREATE INDEX idx_recommendations_markers ON recommendations_v2 USING GIN(primary_markers);")
    all_sql.append("CREATE INDEX idx_trigger_nudges ON trigger_conditions USING GIN(nudges);")
    
    # Save SQL to file
    sql_filename = 'wellpath_supabase_schema.sql'
    with open(sql_filename, 'w') as f:
        f.write('\n'.join(all_sql))
    
    print(f"\n✅ SQL schema saved to: {sql_filename}")
    
    if update_airtable:
        print("✅ Airtable field names have been updated")
    
    print("\nNext steps:")
    print("1. Review the generated SQL schema")
    print("2. Run it in Supabase to create your tables")
    print("3. Use your CSV export script to get the data")
    print("4. Import CSVs into Supabase")

if __name__ == "__main__":
    main()
