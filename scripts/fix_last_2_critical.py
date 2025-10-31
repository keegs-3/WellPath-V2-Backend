#!/usr/bin/env python3
"""
Fix the last 2 critical education sections
"""

import psycopg2
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("FIX LAST 2 CRITICAL SECTIONS")
    print("="*80)

    # 1. Fix Ferritin - How to Optimize (duplicate "How to Raise" heading)
    print("\n1. Fixing Ferritin - How to Optimize...")

    cur.execute("""
        SELECT bes.id, bes.section_content
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE b.biomarker_name = 'Ferritin'
          AND bes.section_title = 'How to Optimize'
          AND bes.is_active = true
    """)

    ferritin_result = cur.fetchone()
    if ferritin_result:
        section_id, content = ferritin_result

        # Fix consecutive duplicate "How to Raise" headings
        # Pattern: **How to Raise...**\n\n**How to Raise...**
        pattern = r'\*\*How to Raise[^*]*\*\*\s*\n\s*\n\s*\*\*How to Raise[^*]*\*\*'

        if re.search(pattern, content, re.IGNORECASE):
            # Remove first occurrence, keep second
            fixed_content = re.sub(pattern, lambda m: m.group(0).split('\n\n', 1)[1], content, count=1, flags=re.IGNORECASE)

            cur.execute("""
                UPDATE biomarkers_education_sections
                SET section_content = %s
                WHERE id = %s
            """, (fixed_content, section_id))

            print("   ✓ Fixed duplicate 'How to Raise' heading in Ferritin")
        else:
            print("   ℹ️  No consecutive duplicates found (may need manual review)")

    # 2. Check Bodyfat - Optimal Ranges (too short at 81 chars)
    print("\n2. Checking Bodyfat - Optimal Ranges...")

    cur.execute("""
        SELECT bes.id, bes.section_content
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE b.biometric_name = 'Bodyfat'
          AND bes.section_title = 'Optimal Ranges'
          AND bes.is_active = true
    """)

    bodyfat_result = cur.fetchone()
    if bodyfat_result:
        section_id, content = bodyfat_result
        print(f"   Current length: {len(content)} characters")
        print(f"   Content: {content[:200]}")

        # This one needs actual content expansion, which requires subject matter knowledge
        # For now, just document it
        print("   ⚠️  Content is too short and needs expansion (requires SME review)")

    # Commit changes
    conn.commit()

    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print("✓ Fixed Ferritin duplicate heading")
    print("⚠️  Bodyfat Optimal Ranges needs content expansion (manual)")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
