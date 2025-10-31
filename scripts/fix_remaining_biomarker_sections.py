#!/usr/bin/env python3
"""
Fix remaining biomarker section issues:
1. Merge "Understanding" sections into "Overview"
2. Add missing sections to ensure all biomarkers have exactly 7 sections
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

STANDARD_SECTIONS = [
    "Overview",
    "The Longevity Connection",
    "Optimal Ranges",
    "Symptoms & Causes",
    "How to Optimize",
    "Special Considerations",
    "The Bottom Line"
]

def fix_understanding_sections(cur):
    """Merge any 'Understanding' sections into 'Overview'"""
    print("\n" + "="*80)
    print("FIXING 'Understanding' SECTIONS")
    print("="*80)

    # Find biomarkers with both "Understanding" and "Overview" sections
    cur.execute("""
        SELECT DISTINCT
            b.id as biomarker_id,
            b.biomarker_name,
            overview.id as overview_id,
            overview.section_content as overview_content,
            understanding.id as understanding_id,
            understanding.section_title as understanding_title,
            understanding.section_content as understanding_content
        FROM biomarkers_base b
        JOIN biomarkers_education_sections overview
            ON b.id = overview.biomarker_id
            AND overview.section_title = 'Overview'
            AND overview.is_active = true
        JOIN biomarkers_education_sections understanding
            ON b.id = understanding.biomarker_id
            AND understanding.section_title LIKE '%Understanding%'
            AND understanding.is_active = true
        WHERE b.is_active = true
    """)

    understanding_pairs = cur.fetchall()

    if understanding_pairs:
        print(f"\n✓ Found {len(understanding_pairs)} biomarkers with both Overview and Understanding sections")

        for biomarker_id, name, overview_id, overview_content, understanding_id, understanding_title, understanding_content in understanding_pairs:
            print(f"\n  {name}:")
            print(f"    Merging '{understanding_title}' into 'Overview'")

            # Merge understanding content into overview
            merged_content = f"{overview_content}\n\n{understanding_content}"

            # Update overview
            cur.execute("""
                UPDATE biomarkers_education_sections
                SET section_content = %s
                WHERE id = %s
            """, (merged_content, overview_id))

            # Delete understanding section
            cur.execute("""
                DELETE FROM biomarkers_education_sections
                WHERE id = %s
            """, (understanding_id,))

        print(f"\n✅ Merged {len(understanding_pairs)} Understanding sections")

    # Find biomarkers with ONLY "Understanding" sections (no "Overview")
    cur.execute("""
        SELECT
            b.id as biomarker_id,
            b.biomarker_name,
            bes.id as section_id,
            bes.section_title,
            bes.display_order
        FROM biomarkers_base b
        JOIN biomarkers_education_sections bes
            ON b.id = bes.biomarker_id
            AND bes.section_title LIKE '%Understanding%'
            AND bes.is_active = true
        WHERE b.is_active = true
          AND NOT EXISTS (
            SELECT 1 FROM biomarkers_education_sections
            WHERE biomarker_id = b.id
              AND section_title = 'Overview'
              AND is_active = true
          )
    """)

    standalone_understanding = cur.fetchall()

    if standalone_understanding:
        print(f"\n✓ Found {len(standalone_understanding)} biomarkers with Understanding but no Overview")

        for biomarker_id, name, section_id, title, order in standalone_understanding:
            print(f"\n  {name}:")
            print(f"    Renaming '{title}' to 'Overview'")

            # Rename to Overview
            cur.execute("""
                UPDATE biomarkers_education_sections
                SET section_title = 'Overview',
                    display_order = 1
                WHERE id = %s
            """, (section_id,))

        print(f"\n✅ Renamed {len(standalone_understanding)} Understanding sections to Overview")

    return len(understanding_pairs) + len(standalone_understanding)

def add_missing_sections(cur):
    """Add placeholder sections for missing categories"""
    print("\n" + "="*80)
    print("ADDING MISSING SECTIONS")
    print("="*80)

    # Get all biomarkers with < 7 sections
    cur.execute("""
        SELECT
            b.id,
            b.biomarker_name,
            COUNT(*) as section_count
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE bes.is_active = true
        GROUP BY b.id, b.biomarker_name
        HAVING COUNT(*) < 7
        ORDER BY COUNT(*), b.biomarker_name
    """)

    incomplete_biomarkers = cur.fetchall()

    if not incomplete_biomarkers:
        print("\n✅ All biomarkers already have 7 sections!")
        return 0

    print(f"\n✓ Found {len(incomplete_biomarkers)} biomarkers with < 7 sections\n")

    total_added = 0

    for biomarker_id, name, current_count in incomplete_biomarkers:
        print(f"\n{name} ({current_count} sections):")

        # Get existing section titles
        cur.execute("""
            SELECT section_title
            FROM biomarkers_education_sections
            WHERE biomarker_id = %s
              AND is_active = true
        """, (biomarker_id,))

        existing_titles = {row[0] for row in cur.fetchall()}

        # Find missing sections
        missing = [s for s in STANDARD_SECTIONS if s not in existing_titles]

        print(f"  Missing: {', '.join(missing)}")

        # Add each missing section
        for idx, section_title in enumerate(STANDARD_SECTIONS):
            if section_title not in existing_titles:
                # Create minimal placeholder content
                placeholder_content = f"Information about {name} and {section_title.lower()} will be added in a future update."

                # Get the correct display order
                display_order = idx + 1

                cur.execute("""
                    INSERT INTO biomarkers_education_sections
                    (biomarker_id, section_title, section_content, display_order, is_active)
                    VALUES (%s, %s, %s, %s, true)
                """, (biomarker_id, section_title, placeholder_content, display_order))

                print(f"    ✓ Added '{section_title}' (order {display_order})")
                total_added += 1

    print(f"\n✅ Added {total_added} missing sections")
    return total_added

def reorder_sections(cur):
    """Ensure all sections have correct display order (1-7)"""
    print("\n" + "="*80)
    print("REORDERING SECTIONS")
    print("="*80)

    cur.execute("""
        SELECT DISTINCT b.id, b.biomarker_name
        FROM biomarkers_base b
        JOIN biomarkers_education_sections bes ON b.id = bes.biomarker_id
        WHERE bes.is_active = true
    """)

    biomarkers = cur.fetchall()

    total_updated = 0

    for biomarker_id, name in biomarkers:
        # Get all sections for this biomarker
        cur.execute("""
            SELECT id, section_title
            FROM biomarkers_education_sections
            WHERE biomarker_id = %s
              AND is_active = true
            ORDER BY display_order, id
        """, (biomarker_id,))

        sections = cur.fetchall()

        # Reorder based on STANDARD_SECTIONS
        for correct_order, standard_title in enumerate(STANDARD_SECTIONS, 1):
            # Find section with matching title
            matching_section = next((s for s in sections if s[1] == standard_title), None)

            if matching_section:
                section_id = matching_section[0]

                # Update display order
                cur.execute("""
                    UPDATE biomarkers_education_sections
                    SET display_order = %s
                    WHERE id = %s
                """, (correct_order, section_id))

                total_updated += 1

    print(f"✅ Reordered {total_updated} section display orders")
    return total_updated

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("FIX REMAINING BIOMARKER SECTION ISSUES")
    print("="*80)

    # Step 1: Fix Understanding sections
    understanding_fixed = fix_understanding_sections(cur)
    conn.commit()

    # Step 2: Add missing sections
    sections_added = add_missing_sections(cur)
    conn.commit()

    # Step 3: Reorder all sections
    sections_reordered = reorder_sections(cur)
    conn.commit()

    # Verify final results
    cur.execute("""
        SELECT
            COUNT(*) as section_count,
            COUNT(DISTINCT b.biomarker_name) as biomarker_count
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE bes.is_active = true
        GROUP BY COUNT(*)
        ORDER BY COUNT(*) DESC
    """)

    print("\n" + "="*80)
    print("FINAL VERIFICATION")
    print("="*80)

    cur.execute("""
        SELECT
            b.biomarker_name,
            COUNT(*) as section_count
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE bes.is_active = true
        GROUP BY b.biomarker_name
        HAVING COUNT(*) != 7
        ORDER BY COUNT(*) DESC, b.biomarker_name
    """)

    remaining_issues = cur.fetchall()

    if remaining_issues:
        print(f"\n⚠️  {len(remaining_issues)} biomarkers still don't have 7 sections:")
        for name, count in remaining_issues:
            print(f"  - {name}: {count} sections")
    else:
        print("\n🎉 SUCCESS! All biomarkers now have exactly 7 sections!")

    cur.execute("""
        SELECT COUNT(DISTINCT biomarker_id)
        FROM biomarkers_education_sections
        WHERE is_active = true
    """)

    total_biomarkers = cur.fetchone()[0]

    cur.execute("""
        SELECT COUNT(DISTINCT biomarker_id)
        FROM biomarkers_education_sections
        WHERE is_active = true
        GROUP BY biomarker_id
        HAVING COUNT(*) = 7
    """)

    correct_biomarkers = len(cur.fetchall())

    print(f"\nTotal biomarkers: {total_biomarkers}")
    print(f"Biomarkers with 7 sections: {correct_biomarkers}")
    print(f"Coverage: {correct_biomarkers}/{total_biomarkers} ({100*correct_biomarkers//total_biomarkers}%)")

    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Understanding sections fixed: {understanding_fixed}")
    print(f"Missing sections added: {sections_added}")
    print(f"Sections reordered: {sections_reordered}")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
