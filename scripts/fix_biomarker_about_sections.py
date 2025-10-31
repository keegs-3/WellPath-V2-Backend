#!/usr/bin/env python3
"""
Fix Biomarker About Sections
Updates biomarkers_base table with correct about_why, about_optimal_target, and about_quick_tips
"""

import os
import csv
import psycopg2

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

def main():
    conn = psycopg2.connect(DB_URL)

    try:
        print("🔧 Fixing Biomarker About Sections")
        print("=" * 70)

        # Read CSV
        csv_path = '/Users/keegs/Documents/GitHub/WellPath-V2-Backend/biomarkers.csv'

        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            biomarkers = list(reader)

        print(f"\n📄 Found {len(biomarkers)} biomarkers in CSV")

        updated_count = 0
        not_found_count = 0

        with conn.cursor() as cur:
            for biomarker in biomarkers:
                biomarker_name = biomarker['biomarker_name']
                about_why = biomarker['about_why']
                about_optimal = biomarker['about_optimal_range']
                about_tips = biomarker['about_quick_tips']

                # Update biomarkers_base
                cur.execute("""
                    UPDATE biomarkers_base
                    SET
                        about_why = %s,
                        about_optimal_target = %s,
                        about_quick_tips = %s,
                        updated_at = NOW()
                    WHERE biomarker_name = %s
                """, (about_why, about_optimal, about_tips, biomarker_name))

                if cur.rowcount > 0:
                    print(f"  ✅ {biomarker_name}")
                    updated_count += 1
                else:
                    print(f"  ⚠️  {biomarker_name} - NOT FOUND IN DATABASE")
                    not_found_count += 1

        conn.commit()

        print("\n" + "=" * 70)
        print("COMPLETE")
        print("=" * 70)
        print(f"Updated: {updated_count} biomarkers ✅")
        print(f"Not Found: {not_found_count} biomarkers ⚠️")

        # Verify a few random biomarkers
        print("\n📊 Verification - Checking sample biomarkers:")
        with conn.cursor() as cur:
            cur.execute("""
                SELECT biomarker_name,
                       LEFT(about_why, 60) as about_why_preview,
                       LEFT(about_optimal_target, 60) as about_optimal_preview
                FROM biomarkers_base
                WHERE biomarker_name IN ('Total Cholesterol', 'HDL', 'LDL', 'Cortisol', 'Ferritin')
                ORDER BY biomarker_name
            """)

            for row in cur.fetchall():
                print(f"\n{row[0]}:")
                print(f"  Why: {row[1]}...")
                print(f"  Optimal: {row[2]}...")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    main()
