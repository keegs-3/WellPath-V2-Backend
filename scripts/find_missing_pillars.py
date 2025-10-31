#!/usr/bin/env python3
"""Find where core care, stress, connection, cognitive data exists"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

print("🔍 Searching for Core Care, Stress, Connection, Cognitive...")
print("=" * 80)

conn = psycopg2.connect(DB_URL)
try:
    with conn.cursor() as cur:
        # Check pillars_base table
        print("\n📋 All Pillars in pillars_base:")
        print("-" * 80)
        cur.execute("SELECT pillar_name FROM pillars_base ORDER BY pillar_name;")
        pillars = cur.fetchall()
        for pillar in pillars:
            print(f"  • {pillar[0]}")

        # Check aggregation_metrics
        print("\n📊 Aggregation metrics for missing pillars:")
        print("-" * 80)
        cur.execute("""
            SELECT am.agg_id, am.display_name, pb.pillar_name
            FROM aggregation_metrics am
            LEFT JOIN pillars_base pb ON am.pillar = pb.pillar_name
            WHERE am.pillar IN ('Core Care', 'Stress Management', 'Social Connection', 'Cognitive Health')
               OR am.display_name ILIKE '%stress%'
               OR am.display_name ILIKE '%connection%'
               OR am.display_name ILIKE '%cognitive%'
               OR am.display_name ILIKE '%core care%'
            ORDER BY am.pillar, am.display_name
            LIMIT 20;
        """)
        results = cur.fetchall()
        if results:
            for row in results:
                print(f"  ✓ {row[0]}: {row[1]} (Pillar: {row[2]})")
        else:
            print("  ❌ NO aggregation metrics found")

        # Check data_entry_fields
        print("\n📝 Data entry fields for missing pillars:")
        print("-" * 80)
        cur.execute("""
            SELECT def.field_id, def.field_name, def.pillar
            FROM data_entry_fields def
            WHERE def.pillar IN ('Core Care', 'Stress Management', 'Social Connection', 'Cognitive Health')
            ORDER BY def.pillar, def.field_name
            LIMIT 20;
        """)
        results = cur.fetchall()
        if results:
            for row in results:
                print(f"  ✓ {row[0]}: {row[1]} (Pillar: {row[2]})")
        else:
            print("  ❌ NO data entry fields found")

        # Count by pillar in aggregation_metrics
        print("\n📊 Aggregation metrics by pillar:")
        print("-" * 80)
        cur.execute("""
            SELECT pillar, COUNT(*) as count
            FROM aggregation_metrics
            GROUP BY pillar
            ORDER BY pillar;
        """)
        results = cur.fetchall()
        for row in results:
            print(f"  • {row[0]}: {row[1]} aggregations")

except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
finally:
    conn.close()
