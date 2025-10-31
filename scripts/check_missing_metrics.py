#!/usr/bin/env python3
"""Check what happened to core care, stress, connection, and cognitive metrics"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

print("🔍 Checking for Missing Metrics...")
print("=" * 80)

conn = psycopg2.connect(DB_URL)
try:
    with conn.cursor() as cur:
        # Check new table
        print("\n📊 New display_metrics table:")
        print("-" * 80)
        cur.execute("""
            SELECT metric_id, metric_name, category, pillar, is_active
            FROM display_metrics
            WHERE metric_name ILIKE '%core care%'
               OR metric_name ILIKE '%stress%'
               OR metric_name ILIKE '%connection%'
               OR metric_name ILIKE '%cognitive%'
               OR pillar ILIKE '%core care%'
               OR pillar ILIKE '%stress%'
               OR pillar ILIKE '%connection%'
               OR pillar ILIKE '%cognitive%'
            ORDER BY metric_name;
        """)
        results = cur.fetchall()
        if results:
            for row in results:
                print(f"  ✓ {row[1]} ({row[0]}) - Pillar: {row[3]}, Active: {row[4]}")
        else:
            print("  ❌ NO METRICS FOUND in new table")

        # Check old archived table
        print("\n📦 Archived z_old_parent_display_metrics table:")
        print("-" * 80)
        cur.execute("""
            SELECT parent_metric_id, parent_name, pillar, is_active
            FROM z_old_parent_display_metrics
            WHERE (parent_name ILIKE '%core care%'
               OR parent_name ILIKE '%stress%'
               OR parent_name ILIKE '%connection%'
               OR parent_name ILIKE '%cognitive%'
               OR pillar ILIKE '%core care%'
               OR pillar ILIKE '%stress%'
               OR pillar ILIKE '%connection%'
               OR pillar ILIKE '%cognitive%')
              AND is_active = true
            ORDER BY parent_name;
        """)
        results = cur.fetchall()
        if results:
            print(f"  Found {len(results)} metrics in archived table:")
            for row in results:
                print(f"  📌 {row[1]} ({row[0]}) - Pillar: {row[2]}")
        else:
            print("  ❌ NO METRICS FOUND in archived table")

        # List all pillars in old table
        print("\n📋 All ACTIVE pillars in archived table:")
        print("-" * 80)
        cur.execute("""
            SELECT DISTINCT pillar, COUNT(*) as metric_count
            FROM z_old_parent_display_metrics
            WHERE is_active = true
            GROUP BY pillar
            ORDER BY pillar;
        """)
        pillars = cur.fetchall()
        for pillar, count in pillars:
            print(f"  • {pillar}: {count} metrics")

        # List all pillars in new table
        print("\n📋 All pillars in NEW table:")
        print("-" * 80)
        cur.execute("""
            SELECT DISTINCT pillar, COUNT(*) as metric_count
            FROM display_metrics
            GROUP BY pillar
            ORDER BY pillar;
        """)
        new_pillars = cur.fetchall()
        for pillar, count in new_pillars:
            print(f"  • {pillar}: {count} metrics")

        # Count comparison
        print("\n📊 Migration Summary:")
        print("-" * 80)
        cur.execute("SELECT COUNT(*) FROM z_old_parent_display_metrics WHERE is_active = true")
        old_count = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM display_metrics WHERE is_active = true")
        new_count = cur.fetchone()[0]
        print(f"  Old table (active): {old_count} metrics")
        print(f"  New table (active): {new_count} metrics")
        print(f"  Difference: {old_count - new_count} metrics missing")

except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
finally:
    conn.close()
