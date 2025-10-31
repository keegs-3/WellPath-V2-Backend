#!/usr/bin/env python3
"""
Fix education content issues:
1. Delete placeholder sections
2. Fix duplicate headings in content
"""

import psycopg2
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def delete_placeholder_sections(cur):
    """Delete sections with placeholder text or very short content"""
    print("\n" + "="*80)
    print("STEP 1: DELETE PLACEHOLDER SECTIONS")
    print("="*80)

    # Delete biomarker placeholders
    cur.execute("""
        DELETE FROM biomarkers_education_sections
        WHERE is_active = true
          AND (
            section_content LIKE '%will be added in a future update%'
            OR LENGTH(section_content) < 150
          )
        RETURNING biomarker_id, section_title
    """)

    biomarker_deleted = cur.fetchall()

    # Delete biometric placeholders
    cur.execute("""
        DELETE FROM biometrics_education_sections
        WHERE is_active = true
          AND (
            section_content LIKE '%will be added in a future update%'
            OR LENGTH(section_content) < 150
          )
        RETURNING biometric_id, section_title
    """)

    biometric_deleted = cur.fetchall()

    total_deleted = len(biomarker_deleted) + len(biometric_deleted)

    print(f"\n✓ Deleted {len(biomarker_deleted)} biomarker placeholder sections")
    print(f"✓ Deleted {len(biometric_deleted)} biometric placeholder sections")
    print(f"✅ Total deleted: {total_deleted} placeholder sections")

    return total_deleted

def fix_duplicate_headings(cur):
    """Fix duplicate headings in biomarker/biometric content"""
    print("\n" + "="*80)
    print("STEP 2: FIX DUPLICATE HEADINGS")
    print("="*80)

    # Get biomarkers with duplicate headings
    cur.execute("""
        SELECT
            b.id,
            b.biomarker_name,
            bes.id as section_id,
            bes.section_title,
            bes.section_content
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE bes.is_active = true
          AND (
            bes.section_content LIKE '%How to Lower%How to Lower%'
            OR bes.section_content LIKE '%How to Improve%How to Improve%'
            OR bes.section_content LIKE '%How to Optimize%How to Optimize%'
            OR bes.section_content LIKE '%How to Raise%How to Raise%'
          )
    """)

    biomarkers_with_dupes = cur.fetchall()

    print(f"\n✓ Found {len(biomarkers_with_dupes)} biomarkers with duplicate headings")

    fixed_count = 0

    for biomarker_id, biomarker_name, section_id, section_title, content in biomarkers_with_dupes:
        print(f"\n  {biomarker_name} ({section_title}):")

        # Find duplicate patterns
        # Pattern: **Some Heading:**\n\n**Some Heading:**
        # We want to remove the first occurrence

        # Common patterns
        patterns = [
            r'\*\*How to Lower[^*]+\*\*\s*\n\s*\n\s*\*\*How to Lower[^*]+\*\*',
            r'\*\*How to Improve[^*]+\*\*\s*\n\s*\n\s*\*\*How to Improve[^*]+\*\*',
            r'\*\*How to Optimize[^*]+\*\*\s*\n\s*\n\s*\*\*How to Optimize[^*]+\*\*',
            r'\*\*How to Raise[^*]+\*\*\s*\n\s*\n\s*\*\*How to Raise[^*]+\*\*',
        ]

        fixed_content = content

        for pattern in patterns:
            matches = re.search(pattern, fixed_content, re.IGNORECASE | re.DOTALL)
            if matches:
                # Extract the duplicate heading
                full_match = matches.group(0)
                # Split it and take only the second occurrence
                parts = full_match.split('**')
                # Reconstruct with only one heading
                # The pattern is: **Heading:**\n\n**Heading:** -> **Heading:**
                heading = parts[1] if len(parts) > 1 else ''
                fixed_content = re.sub(pattern, f'**{heading}**', fixed_content, count=1, flags=re.IGNORECASE | re.DOTALL)
                print(f"    Fixed duplicate heading: {heading[:50]}...")

        if fixed_content != content:
            # Update the section
            cur.execute("""
                UPDATE biomarkers_education_sections
                SET section_content = %s
                WHERE id = %s
            """, (fixed_content, section_id))
            fixed_count += 1
            print(f"    ✓ Updated")

    print(f"\n✅ Fixed {fixed_count} duplicate headings")

    return fixed_count

def verify_results(cur):
    """Verify the fixes"""
    print("\n" + "="*80)
    print("VERIFICATION")
    print("="*80)

    # Check for remaining placeholders
    cur.execute("""
        SELECT COUNT(*) FROM biomarkers_education_sections
        WHERE is_active = true
          AND (
            section_content LIKE '%will be added in a future update%'
            OR LENGTH(section_content) < 150
          )
    """)

    biomarker_placeholders = cur.fetchone()[0]

    cur.execute("""
        SELECT COUNT(*) FROM biometrics_education_sections
        WHERE is_active = true
          AND (
            section_content LIKE '%will be added in a future update%'
            OR LENGTH(section_content) < 150
          )
    """)

    biometric_placeholders = cur.fetchone()[0]

    # Check for remaining duplicates
    cur.execute("""
        SELECT COUNT(*) FROM biomarkers_education_sections
        WHERE is_active = true
          AND (
            section_content LIKE '%How to Lower%How to Lower%'
            OR section_content LIKE '%How to Improve%How to Improve%'
            OR section_content LIKE '%How to Optimize%How to Optimize%'
            OR section_content LIKE '%How to Raise%How to Raise%'
          )
    """)

    remaining_duplicates = cur.fetchone()[0]

    print(f"\n✓ Remaining biomarker placeholders: {biomarker_placeholders}")
    print(f"✓ Remaining biometric placeholders: {biometric_placeholders}")
    print(f"✓ Remaining duplicate headings: {remaining_duplicates}")

    if biomarker_placeholders == 0 and biometric_placeholders == 0 and remaining_duplicates == 0:
        print("\n🎉 All issues fixed!")
        return True
    else:
        print("\n⚠️  Some issues remain")
        return False

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("FIX EDUCATION CONTENT ISSUES")
    print("="*80)

    # Step 1: Delete placeholders
    deleted = delete_placeholder_sections(cur)
    conn.commit()

    # Step 2: Fix duplicate headings
    fixed = fix_duplicate_headings(cur)
    conn.commit()

    # Step 3: Verify
    success = verify_results(cur)

    # Summary
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Placeholder sections deleted: {deleted}")
    print(f"Duplicate headings fixed: {fixed}")
    print(f"Status: {'✅ Complete' if success else '⚠️  Issues remain'}")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
