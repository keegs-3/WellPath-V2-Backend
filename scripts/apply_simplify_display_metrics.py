#!/usr/bin/env python3
"""Apply display metrics simplification migration"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

print("🔧 Simplifying Display Metrics Structure...")
print("=" * 80)

sql = open('/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251024_simplify_display_metrics_to_flat_structure.sql').read()

conn = psycopg2.connect(DB_URL)
try:
    with conn.cursor() as cur:
        cur.execute(sql)
        conn.commit()
        print("\n✅ Migration applied successfully!")
        print("\nNew simplified structure:")
        print("  - display_metrics (flat table)")
        print("  - display_metrics_aggregations (junction table)")
        print("\nDropped complex tables:")
        print("  ✗ parent_display_metrics")
        print("  ✗ child_display_metrics")
        print("  ✗ parent_detail_sections")
        print("  ✗ parent_child_display_metrics_aggregations")
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
    conn.rollback()
finally:
    conn.close()
