#!/usr/bin/env python3
"""Apply sleep analysis structure fix via Python"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

sql = open('/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251024_fix_sleep_analysis_structure.sql').read()

conn = psycopg2.connect(DB_URL)
try:
    with conn.cursor() as cur:
        cur.execute(sql)
        conn.commit()
        print("✅ Sleep structure migration applied successfully!")
except Exception as e:
    print(f"❌ Error: {e}")
    conn.rollback()
finally:
    conn.close()
