#!/usr/bin/env python3
"""
Verify Display Metrics Rollup Structure
Checks if parent → section → children → junction → aggregations is complete
"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

def verify_protein_structure(conn):
    """Check protein rollup structure"""
    print("\n🔍 VERIFYING PROTEIN STRUCTURE")
    print("=" * 80)

    with conn.cursor() as cur:
        # 1. Check parent
        print("\n1️⃣ PARENT METRIC:")
        cur.execute("""
            SELECT parent_metric_id, parent_name, chart_type_id
            FROM parent_display_metrics
            WHERE parent_metric_id LIKE '%PROTEIN%'
            ORDER BY parent_metric_id
        """)
        parents = cur.fetchall()
        if parents:
            for row in parents:
                print(f"   ✅ {row[0]}: {row[1]} ({row[2]})")
        else:
            print("   ❌ NO PROTEIN PARENTS FOUND")

        # 2. Check sections
        print("\n2️⃣ SECTIONS:")
        cur.execute("""
            SELECT
                s.section_id,
                s.section_name,
                s.section_chart_type_id,
                COUNT(c.child_metric_id) as child_count
            FROM parent_detail_sections s
            LEFT JOIN child_display_metrics c ON c.section_id = s.section_id
            WHERE s.parent_metric_id LIKE '%PROTEIN%' AND s.is_active = true
            GROUP BY s.section_id, s.section_name, s.section_chart_type_id, s.display_order
            ORDER BY s.display_order
        """)
        sections = cur.fetchall()
        if sections:
            for row in sections:
                print(f"   ✅ {row[0]}: {row[1]} ({row[2]}) - {row[3]} children")
        else:
            print("   ❌ NO SECTIONS FOUND")

        # 3. Check children (first 10)
        print("\n3️⃣ CHILD METRICS (sample):")
        cur.execute("""
            SELECT
                child_metric_id,
                child_name,
                section_id,
                data_series_order
            FROM child_display_metrics
            WHERE parent_metric_id LIKE '%PROTEIN%' AND is_active = true
            ORDER BY section_id, data_series_order
            LIMIT 10
        """)
        children = cur.fetchall()
        if children:
            for row in children:
                print(f"   ✅ {row[0]}: {row[1]} (section: {row[2]}, order: {row[3]})")
        else:
            print("   ❌ NO CHILDREN FOUND")

        # 4. Check junction table mappings
        print("\n4️⃣ JUNCTION TABLE MAPPINGS (child → aggregation):")
        cur.execute("""
            SELECT
                j.child_metric_id,
                j.agg_metric_id,
                j.period_type,
                j.calculation_type_id
            FROM parent_child_display_metrics_aggregations j
            JOIN child_display_metrics c ON c.child_metric_id = j.child_metric_id
            WHERE c.parent_metric_id LIKE '%PROTEIN%'
            ORDER BY j.child_metric_id, j.period_type
            LIMIT 15
        """)
        mappings = cur.fetchall()
        if mappings:
            for row in mappings:
                print(f"   ✅ {row[0]} → {row[1]} ({row[2]}, {row[3]})")
        else:
            print("   ❌ NO JUNCTION MAPPINGS FOUND")

        # 5. Check if aggregations actually exist
        print("\n5️⃣ AGGREGATIONS EXISTENCE:")
        cur.execute("""
            SELECT DISTINCT j.agg_metric_id
            FROM parent_child_display_metrics_aggregations j
            JOIN child_display_metrics c ON c.child_metric_id = j.child_metric_id
            WHERE c.parent_metric_id LIKE '%PROTEIN%'
            LIMIT 10
        """)
        agg_ids = [row[0] for row in cur.fetchall()]

        for agg_id in agg_ids:
            cur.execute("""
                SELECT COUNT(*) FROM aggregation_metrics WHERE agg_id = %s
            """, (agg_id,))
            exists = cur.fetchone()[0] > 0
            status = "✅" if exists else "❌"
            print(f"   {status} {agg_id}: {'EXISTS' if exists else 'MISSING'}")

def verify_sleep_structure(conn):
    """Check sleep rollup structure"""
    print("\n\n🔍 VERIFYING SLEEP STRUCTURE")
    print("=" * 80)

    with conn.cursor() as cur:
        # Check if sleep uses correct parent structure
        print("\n1️⃣ SLEEP PARENT:")
        cur.execute("""
            SELECT parent_metric_id, parent_name, chart_type_id
            FROM parent_display_metrics
            WHERE parent_metric_id LIKE '%SLEEP%'
            ORDER BY parent_metric_id
        """)
        parents = cur.fetchall()
        if parents:
            for row in parents:
                print(f"   {'✅' if 'ANALYSIS' in row[0] else '⚠️ '} {row[0]}: {row[1]}")
        else:
            print("   ❌ NO SLEEP PARENTS FOUND")

        # Check sections
        print("\n2️⃣ SLEEP SECTIONS:")
        cur.execute("""
            SELECT
                s.section_id,
                s.parent_metric_id,
                s.section_name,
                COUNT(c.child_metric_id) as child_count
            FROM parent_detail_sections s
            LEFT JOIN child_display_metrics c ON c.section_id = s.section_id
            WHERE s.parent_metric_id LIKE '%SLEEP%' AND s.is_active = true
            GROUP BY s.section_id, s.parent_metric_id, s.section_name
            ORDER BY s.display_order
        """)
        sections = cur.fetchall()
        if sections:
            for row in sections:
                print(f"   ✅ {row[0]} (parent: {row[1]}) - {row[3]} children")
        else:
            print("   ❌ NO SECTIONS FOUND")

def main():
    print("🔍 DISPLAY METRICS ROLLUP STRUCTURE VERIFICATION")
    print("=" * 80)

    conn = psycopg2.connect(DB_URL)

    try:
        verify_protein_structure(conn)
        verify_sleep_structure(conn)

        print("\n" + "=" * 80)
        print("✅ VERIFICATION COMPLETE")
        print("=" * 80)

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()

    finally:
        conn.close()

if __name__ == '__main__':
    main()
