#!/usr/bin/env python3
"""Quick check of education content in database"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()

print("Checking education content...")
print("=" * 80)

# Check a few biomarkers
cur.execute("""
    SELECT biomarker_name,
           CASE WHEN education IS NULL THEN 0 ELSE LENGTH(education) END as len,
           CASE WHEN education LIKE '%Longevity Connection%' THEN 'NEW' ELSE 'OLD' END as version
    FROM biomarkers_base
    WHERE biomarker_name IN ('HDL', 'Testosterone', 'hsCRP', 'Estradiol', 'ALT', 'LDL')
      AND is_active = true
    ORDER BY biomarker_name
""")

for row in cur.fetchall():
    name, length, version = row
    print(f"{name:15} | Length: {length:5} chars | Version: {version}")

print()
print("Checking biometrics...")
print("=" * 80)

cur.execute("""
    SELECT biometric_name,
           CASE WHEN education IS NULL THEN 0 ELSE LENGTH(education) END as len,
           CASE WHEN education LIKE '%Longevity Connection%' THEN 'NEW' ELSE 'OLD' END as version
    FROM biometrics_base
    WHERE biometric_name IN ('Weight', 'BMI', 'VO2 Max', 'HRV')
      AND is_active = true
    ORDER BY biometric_name
""")

for row in cur.fetchall():
    name, length, version = row
    print(f"{name:15} | Length: {length:5} chars | Version: {version}")

cur.close()
conn.close()
