#!/usr/bin/env python3
"""Test script to debug section 8 question mapping"""

import pandas as pd
import psycopg2

# Database connection
conn = psycopg2.connect(
    host="aws-1-us-west-1.pooler.supabase.com",
    database="postgres",
    user="postgres.csotzmardnvrpdhlogjm",
    password="qLa4sE9zV1yvxCP4",
    port=6543
)

cur = conn.cursor()

# Build question mapping like the import script does (FIXED VERSION)
cur.execute('SELECT "ID", record_id, type FROM survey_questions')
question_mapping = {}
for row in cur.fetchall():
    question_id_str = str(row[0]).strip()
    question_mapping[question_id_str] = row[1]

    if '.' in question_id_str:
        parts = question_id_str.split('.')
        decimal_part = parts[1]

        # If decimal part is single digit, pad with trailing zero (8.1 -> 8.10)
        if len(decimal_part) == 1:
            padded_trailing = f"{parts[0]}.{decimal_part}0"
            question_mapping[padded_trailing] = row[1]

        # If decimal part is two digits, also create single digit version (8.01 -> 8.1)
        elif len(decimal_part) == 2 and decimal_part.endswith('0'):
            single_digit = f"{parts[0]}.{decimal_part[0]}"
            question_mapping[single_digit] = row[1]

print(f"Total question mappings: {len(question_mapping)}")

# Get section 8 keys from mapping
section_8_in_mapping = sorted([k for k in question_mapping.keys() if k.startswith('8.')])
print(f"\nSection 8 keys in mapping: {len(section_8_in_mapping)}")
print(f"First 10: {section_8_in_mapping[:10]}")

# Load CSV and get section 8 columns
df = pd.read_csv('data/synthetic_patient_survey.csv')
csv_cols = [col.strip() for col in df.columns]
section_8_in_csv = sorted([col for col in csv_cols if col.startswith('8.')])
print(f"\nSection 8 columns in CSV: {len(section_8_in_csv)}")
print(f"First 10: {section_8_in_csv[:10]}")

# Find which ones don't match
missing_in_mapping = [col for col in section_8_in_csv if col not in question_mapping]
print(f"\nSection 8 columns in CSV but NOT in mapping: {len(missing_in_mapping)}")
if missing_in_mapping:
    print(f"First 20: {missing_in_mapping[:20]}")

# Test specific lookups
test_cols = ['8.01', '8.1', '8.10']
print(f"\nTest lookups:")
for col in test_cols:
    result = question_mapping.get(col)
    print(f"  '{col}' -> {result}")

conn.close()
