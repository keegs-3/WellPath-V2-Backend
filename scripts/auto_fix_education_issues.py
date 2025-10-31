#!/usr/bin/env python3
"""
Automatically fix all identified education content issues
Based on comprehensive_education_audit.py findings
"""

import psycopg2
import re
import json

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def fix_duplicate_headings_in_content(content):
    """Remove duplicate consecutive headings"""
    # Pattern: **Some Heading**\n\n**Some Heading**
    # Keep only the second occurrence
    pattern = r'\*\*([^\*]+)\*\*\s*\n\s*\n\s*\*\*\1\*\*'

    # Replace duplicate headings
    fixed_content = re.sub(pattern, r'**\1**', content, flags=re.DOTALL)

    # Also handle triple duplicates
    fixed_content = re.sub(pattern, r'**\1**', fixed_content, flags=re.DOTALL)

    return fixed_content

def fix_mixed_line_endings(content):
    """Normalize all line endings to \\n"""
    # Replace \r\n with \n
    fixed_content = content.replace('\r\n', '\n')
    return fixed_content

def fix_empty_bullet_points(content):
    """Remove empty bullet points"""
    # Pattern: - followed by multiple newlines
    fixed_content = re.sub(r'-\s*\n\s*\n', '\n', content)
    return fixed_content

def fix_excessive_blank_lines(content):
    """Replace 4+ newlines with 2"""
    fixed_content = re.sub(r'\n{4,}', '\n\n', content)
    return fixed_content

def fix_incomplete_lists(content):
    """Fix lists that end with a dash"""
    if content.strip().endswith('-'):
        fixed_content = content.strip()[:-1].strip()
        return fixed_content
    return content

def apply_all_fixes(content):
    """Apply all automated fixes"""
    if not content:
        return content

    fixed = content
    fixed = fix_mixed_line_endings(fixed)
    fixed = fix_duplicate_headings_in_content(fixed)
    fixed = fix_empty_bullet_points(fixed)
    fixed = fix_excessive_blank_lines(fixed)
    fixed = fix_incomplete_lists(fixed)

    return fixed

def fix_all_sections(cur, table_name, id_field_name, name_table, name_field):
    """Fix all sections in a table"""
    # Get all sections
    cur.execute(f"""
        SELECT
            bes.id,
            n.{name_field},
            bes.section_title,
            bes.section_content
        FROM {table_name} bes
        JOIN {name_table} n ON bes.{id_field_name} = n.id
        WHERE bes.is_active = true
        ORDER BY n.{name_field}, bes.display_order
    """)

    sections = cur.fetchall()

    fixed_count = 0
    deleted_count = 0

    for section_id, name, title, content in sections:
        should_delete = False

        # Check if should be deleted (placeholder or too short)
        if content and len(content) < 150:
            if any(phrase in content.lower() for phrase in [
                'will be added in a future update',
                'information about',
                'content for'
            ]):
                should_delete = True

        if should_delete:
            # Delete placeholder
            cur.execute(f"DELETE FROM {table_name} WHERE id = %s", (section_id,))
            deleted_count += 1
        else:
            # Apply fixes
            fixed_content = apply_all_fixes(content)

            if fixed_content != content:
                cur.execute(f"""
                    UPDATE {table_name}
                    SET section_content = %s
                    WHERE id = %s
                """, (fixed_content, section_id))
                fixed_count += 1

    return fixed_count, deleted_count

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("AUTO-FIX EDUCATION CONTENT ISSUES")
    print("="*80)

    # Fix biomarkers
    print("\n Fixing biomarker sections...")
    biomarker_fixed, biomarker_deleted = fix_all_sections(
        cur,
        'biomarkers_education_sections',
        'biomarker_id',
        'biomarkers_base',
        'biomarker_name'
    )

    # Fix biometrics
    print("Fixing biometric sections...")
    biometric_fixed, biometric_deleted = fix_all_sections(
        cur,
        'biometrics_education_sections',
        'biometric_id',
        'biometrics_base',
        'biometric_name'
    )

    # Commit changes
    conn.commit()

    # Summary
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Biomarker sections fixed: {biomarker_fixed}")
    print(f"Biomarker sections deleted: {biomarker_deleted}")
    print(f"Biometric sections fixed: {biometric_fixed}")
    print(f"Biometric sections deleted: {biometric_deleted}")
    print(f"\nTotal fixed: {biomarker_fixed + biometric_fixed}")
    print(f"Total deleted: {biomarker_deleted + biometric_deleted}")

    cur.close()
    conn.close()

    print("\n✅ Auto-fix complete! Run comprehensive_education_audit.py again to verify.")

if __name__ == '__main__':
    main()
