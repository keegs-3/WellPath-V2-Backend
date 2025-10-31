#!/usr/bin/env python3
"""
Enhanced duplicate heading fix
Handles ALL duplicate headings, not just consecutive ones
"""

import psycopg2
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def find_all_headings(content):
    """Find all markdown headings and their positions"""
    headings = []
    pattern = r'\*\*([^\*]+)\*\*'

    for match in re.finditer(pattern, content):
        heading_text = match.group(1)
        start_pos = match.start()
        end_pos = match.end()
        headings.append({
            'text': heading_text,
            'start': start_pos,
            'end': end_pos,
            'full_match': match.group(0)
        })

    return headings

def remove_duplicate_headings(content):
    """Remove duplicate headings, keeping only the last occurrence"""
    headings = find_all_headings(content)

    if not headings:
        return content

    # Find duplicates
    heading_texts = [h['text'] for h in headings]
    seen = {}
    duplicates_to_remove = []

    # Track all occurrences of each heading
    for i, heading in enumerate(headings):
        text = heading['text']
        if text not in seen:
            seen[text] = []
        seen[text].append(i)

    # For each heading that appears more than once, remove all but the last
    for text, indices in seen.items():
        if len(indices) > 1:
            # Keep the last occurrence, remove all others
            for idx in indices[:-1]:
                duplicates_to_remove.append(headings[idx])

    if not duplicates_to_remove:
        return content

    # Sort by position (reverse order so we can remove from end to start)
    duplicates_to_remove.sort(key=lambda h: h['start'], reverse=True)

    # Remove each duplicate heading
    fixed_content = content
    for dup in duplicates_to_remove:
        # Remove the heading and any trailing whitespace/newlines
        # Pattern: **Heading**\n\n or **Heading**\n
        start = dup['start']
        end = dup['end']

        # Check if there are newlines after the heading
        remaining = fixed_content[end:]
        trailing_match = re.match(r'^(\s*\n+)', remaining)
        if trailing_match:
            end += len(trailing_match.group(1))

        # Remove the duplicate
        fixed_content = fixed_content[:start] + fixed_content[end:]

    return fixed_content

def fix_excessive_newlines(content):
    """Clean up excessive newlines that may be left after removing duplicates"""
    # Replace 3+ newlines with 2
    fixed = re.sub(r'\n{3,}', '\n\n', content)
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

    for section_id, name, title, content in sections:
        if not content:
            continue

        # Fix duplicate headings
        fixed_content = remove_duplicate_headings(content)

        # Clean up excessive newlines
        fixed_content = fix_excessive_newlines(fixed_content)

        # Only update if content changed
        if fixed_content != content:
            cur.execute(f"""
                UPDATE {table_name}
                SET section_content = %s
                WHERE id = %s
            """, (fixed_content, section_id))
            fixed_count += 1

            # Show what was fixed
            original_headings = find_all_headings(content)
            fixed_headings = find_all_headings(fixed_content)
            removed_count = len(original_headings) - len(fixed_headings)

            if removed_count > 0:
                print(f"  ✓ {name} - {title}: Removed {removed_count} duplicate heading(s)")

    return fixed_count

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("ENHANCED DUPLICATE HEADING FIX")
    print("="*80)

    # Fix biomarkers
    print("\n🔧 Fixing biomarker sections...")
    biomarker_fixed = fix_all_sections(
        cur,
        'biomarkers_education_sections',
        'biomarker_id',
        'biomarkers_base',
        'biomarker_name'
    )

    # Fix biometrics
    print("\n🔧 Fixing biometric sections...")
    biometric_fixed = fix_all_sections(
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
    print(f"Biometric sections fixed: {biometric_fixed}")
    print(f"\nTotal fixed: {biomarker_fixed + biometric_fixed}")

    cur.close()
    conn.close()

    print("\n✅ Enhanced fix complete! Run comprehensive_education_audit.py again to verify.")

if __name__ == '__main__':
    main()
