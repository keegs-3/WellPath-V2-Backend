#!/usr/bin/env python3
"""Check z_old_display_metrics for metrics that need consolidation"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

print("🔍 Checking z_old_display_metrics...")
print("=" * 80)

conn = psycopg2.connect(DB_URL)
try:
    with conn.cursor() as cur:
        # Check if table exists
        cur.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables
                WHERE table_name = 'z_old_display_metrics'
            );
        """)
        exists = cur.fetchone()[0]

        if not exists:
            print("❌ Table z_old_display_metrics does not exist")
            print("\nAvailable z_old tables:")
            cur.execute("""
                SELECT table_name
                FROM information_schema.tables
                WHERE table_name LIKE 'z_old%'
                ORDER BY table_name;
            """)
            tables = cur.fetchall()
            for table in tables:
                print(f"  • {table[0]}")
        else:
            # Show all metrics grouped by pillar
            print("\n📊 All metrics in z_old_display_metrics (grouped by pillar):")
            print("-" * 80)
            cur.execute("""
                SELECT pillar, metric_id, metric_name
                FROM z_old_display_metrics
                ORDER BY pillar, metric_name;
            """)
            results = cur.fetchall()

            current_pillar = None
            for pillar, metric_id, metric_name in results:
                if pillar != current_pillar:
                    print(f"\n{pillar}:")
                    current_pillar = pillar
                print(f"  • {metric_name} ({metric_id})")

            # Show metrics that could be consolidated
            print("\n\n🔄 Metrics that could be consolidated:")
            print("-" * 80)

            # Meal timing patterns
            cur.execute("""
                SELECT metric_id, metric_name, pillar
                FROM z_old_display_metrics
                WHERE metric_name ILIKE '%breakfast%'
                   OR metric_name ILIKE '%lunch%'
                   OR metric_name ILIKE '%dinner%'
                ORDER BY metric_name;
            """)
            meal_metrics = cur.fetchall()
            if meal_metrics:
                print("\n📅 MEAL TIMING (breakfast/lunch/dinner):")
                for metric_id, metric_name, pillar in meal_metrics:
                    print(f"  → {metric_name} ({metric_id}) - {pillar}")

            # Legume timing patterns
            cur.execute("""
                SELECT metric_id, metric_name, pillar
                FROM z_old_display_metrics
                WHERE metric_name ILIKE '%legume%'
                ORDER BY metric_name;
            """)
            legume_metrics = cur.fetchall()
            if legume_metrics:
                print("\n🫘 LEGUME TIMING:")
                for metric_id, metric_name, pillar in legume_metrics:
                    print(f"  → {metric_name} ({metric_id}) - {pillar}")

            # Core care, stress, etc
            cur.execute("""
                SELECT pillar, COUNT(*) as count
                FROM z_old_display_metrics
                WHERE pillar IN ('Core Care', 'Stress Management', 'Social Connection', 'Cognitive Health')
                GROUP BY pillar
                ORDER BY pillar;
            """)
            pillar_counts = cur.fetchall()
            if pillar_counts:
                print("\n🎯 OTHER PILLARS:")
                for pillar, count in pillar_counts:
                    print(f"  • {pillar}: {count} metrics")

except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
finally:
    conn.close()
