#!/usr/bin/env python3
"""Apply direct screen FK migration"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

print("🔗 Simplifying to Direct Screen FK...")
print("=" * 80)

sql = open('/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251025_simplify_to_direct_screen_fk.sql').read()

conn = psycopg2.connect(DB_URL)
try:
    with conn.cursor() as cur:
        cur.execute(sql)
        conn.commit()
        print("\n✅ Migration applied successfully!")
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
    conn.rollback()
finally:
    conn.close()
