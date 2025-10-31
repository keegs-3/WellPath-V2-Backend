#!/usr/bin/env python3
"""Check for DISP_PROTEIN_SERVINGS and fix assignments"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

conn = psycopg2.connect(DB_URL)
try:
    with conn.cursor() as cur:
        # Check for protein servings
        cur.execute("""
            SELECT metric_id, metric_name
            FROM display_metrics
            WHERE metric_id LIKE '%PROTEIN%' OR metric_name ILIKE '%protein%'
            ORDER BY metric_name;
        """)
        print("🔍 Protein Metrics:")
        for row in cur.fetchall():
            print(f"  {row[0]}: {row[1]}")

        # Check primary assignments
        print("\n📊 Primary Screen Metrics Count:")
        cur.execute("""
            SELECT dsp.title, COUNT(pdm.metric_id) as metric_count
            FROM display_screens_primary dsp
            LEFT JOIN display_screens_primary_display_metrics pdm ON pdm.primary_screen_id = dsp.primary_screen_id
            GROUP BY dsp.primary_screen_id, dsp.title
            HAVING COUNT(pdm.metric_id) > 2
            ORDER BY metric_count DESC
            LIMIT 10;
        """)
        for row in cur.fetchall():
            print(f"  {row[0]}: {row[1]} metrics (should be 1-2)")

finally:
    conn.close()
