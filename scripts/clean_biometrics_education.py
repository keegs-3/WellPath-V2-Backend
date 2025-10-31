#!/usr/bin/env python3
"""
Clean and standardize biometrics_education_sections
- Delete blank and placeholder sections
- Merge Understanding+Overview duplicates
- Consolidate similar title variations
- Consolidate fragmented biometrics to 6-section standard
"""

import psycopg2
from collections import defaultdict
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Standard 6-section structure for biometrics
STANDARD_SECTIONS = [
    "Overview",
    "The Longevity Connection",
    "Optimal Ranges",
    "How to Optimize",
    "Special Considerations",
    "The Bottom Line"
]

def delete_blank_and_placeholder_sections(cur):
    """Delete sections with no content or placeholder text"""
    print("\n" + "="*80)
    print("STEP 1: DELETE BLANK AND PLACEHOLDER SECTIONS")
    print("="*80)

    # Delete blank sections
    cur.execute("""
        DELETE FROM biometrics_education_sections
        WHERE is_active = true
          AND (
            section_content = ''
            OR LENGTH(section_content) = 0
            OR section_content IS NULL
          )
        RETURNING biometric_id, section_title
    """)

    blank_deleted = cur.fetchall()

    if blank_deleted:
        print(f"\n✓ Deleted {len(blank_deleted)} blank sections:")
        for _, title in blank_deleted:
            print(f"  - '{title}'")

    # Delete placeholder sections
    cur.execute("""
        DELETE FROM biometrics_education_sections
        WHERE is_active = true
          AND section_content LIKE '*Content for%will be added soon.*'
        RETURNING biometric_id, section_title
    """)

    placeholder_deleted = cur.fetchall()

    if placeholder_deleted:
        print(f"\n✓ Deleted {len(placeholder_deleted)} placeholder sections:")
        for _, title in placeholder_deleted:
            print(f"  - '{title}'")

    return len(blank_deleted) + len(placeholder_deleted)

def merge_understanding_overview(cur):
    """Merge 'Understanding X' sections into 'Overview'"""
    print("\n" + "="*80)
    print("STEP 2: MERGE 'UNDERSTANDING' INTO 'OVERVIEW'")
    print("="*80)

    # Find biometrics with both Understanding and Overview
    cur.execute("""
        SELECT DISTINCT
            b.id as biometric_id,
            b.biometric_name,
            overview.id as overview_id,
            overview.section_content as overview_content,
            understanding.id as understanding_id,
            understanding.section_title as understanding_title,
            understanding.section_content as understanding_content
        FROM biometrics_base b
        JOIN biometrics_education_sections overview
            ON b.id = overview.biometric_id
            AND overview.section_title = 'Overview'
            AND overview.is_active = true
        JOIN biometrics_education_sections understanding
            ON b.id = understanding.biometric_id
            AND understanding.section_title LIKE '%Understanding%'
            AND understanding.is_active = true
        WHERE b.is_active = true
    """)

    pairs = cur.fetchall()

    if not pairs:
        print("\n✓ No Understanding+Overview pairs found")
        return 0

    print(f"\n✓ Found {len(pairs)} Understanding+Overview pairs to merge")

    for biometric_id, name, overview_id, overview_content, understanding_id, understanding_title, understanding_content in pairs:
        print(f"\n  {name}:")
        print(f"    Merging '{understanding_title}' into 'Overview'")

        # Merge content (Understanding first, then Overview)
        merged_content = f"{understanding_content}\n\n{overview_content}"

        # Update overview
        cur.execute("""
            UPDATE biometrics_education_sections
            SET section_content = %s
            WHERE id = %s
        """, (merged_content, overview_id))

        # Delete understanding section
        cur.execute("""
            DELETE FROM biometrics_education_sections
            WHERE id = %s
        """, (understanding_id,))

    return len(pairs)

def consolidate_similar_titles(cur):
    """Consolidate sections with similar titles (e.g., multiple Optimal Ranges)"""
    print("\n" + "="*80)
    print("STEP 3: CONSOLIDATE SIMILAR TITLES")
    print("="*80)

    # BMI: Merge "Optimal Ranges by Age" into "Optimal Ranges"
    print("\n  BMI: Merging 'Optimal Ranges by Age' into 'Optimal Ranges'")

    cur.execute("""
        SELECT
            bes.id,
            bes.section_title,
            bes.section_content
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE b.biometric_name = 'BMI'
          AND bes.is_active = true
          AND (bes.section_title = 'Optimal Ranges' OR bes.section_title = 'Optimal Ranges by Age')
        ORDER BY bes.section_title
    """)

    bmi_ranges = cur.fetchall()

    if len(bmi_ranges) == 2:
        optimal_id, optimal_title, optimal_content = bmi_ranges[0]
        by_age_id, by_age_title, by_age_content = bmi_ranges[1]

        # Keep "Optimal Ranges", delete "Optimal Ranges by Age"
        cur.execute("""
            DELETE FROM biometrics_education_sections
            WHERE id = %s
        """, (by_age_id,))

        print(f"    ✓ Deleted '{by_age_title}' (duplicate of '{optimal_title}')")

    # VO2 Max: Merge duplicate "Longevity Connection" sections
    print("\n  VO2 Max: Merging duplicate 'Longevity Connection' sections")

    cur.execute("""
        SELECT
            bes.id,
            bes.section_title,
            bes.section_content
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE b.biometric_name = 'VO2 Max'
          AND bes.is_active = true
          AND bes.section_title LIKE '%Longevity Connection%'
        ORDER BY LENGTH(bes.section_content) DESC
    """)

    vo2_longevity = cur.fetchall()

    if len(vo2_longevity) > 1:
        # Keep longest, delete rest
        keeper_id = vo2_longevity[0][0]
        to_delete = [row[0] for row in vo2_longevity[1:]]

        for delete_id in to_delete:
            cur.execute("""
                DELETE FROM biometrics_education_sections
                WHERE id = %s
            """, (delete_id,))

        print(f"    ✓ Deleted {len(to_delete)} duplicate Longevity Connection section(s)")

    # VO2 Max: Merge "How to Improve" and "How to Optimize"
    print("\n  VO2 Max: Merging 'How to Improve' into 'How to Optimize'")

    cur.execute("""
        SELECT
            bes.id,
            bes.section_title,
            bes.section_content
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE b.biometric_name = 'VO2 Max'
          AND bes.is_active = true
          AND (bes.section_title LIKE '%How to%')
        ORDER BY LENGTH(bes.section_content) DESC
    """)

    vo2_how_to = cur.fetchall()

    if len(vo2_how_to) > 1:
        # Merge all into longest
        keeper_id, keeper_title, keeper_content = vo2_how_to[0]
        to_delete = [row[0] for row in vo2_how_to[1:]]

        for delete_id in to_delete:
            cur.execute("""
                DELETE FROM biometrics_education_sections
                WHERE id = %s
            """, (delete_id,))

        # Rename to standard "How to Optimize"
        cur.execute("""
            UPDATE biometrics_education_sections
            SET section_title = 'How to Optimize'
            WHERE id = %s
        """, (keeper_id,))

        print(f"    ✓ Merged {len(to_delete)} How To section(s) into 'How to Optimize'")

    return 3  # 3 biometrics fixed

def classify_section(title, content):
    """Classify a section into one of the 6 standard categories"""
    title_lower = title.lower()

    # Exact matches
    for standard in STANDARD_SECTIONS:
        if standard.lower() in title_lower or title_lower in standard.lower():
            return (standard, False)

    # Category patterns
    if any(kw in title_lower for kw in ['understanding', 'overview', 'what is']):
        return ("Overview", True)

    if 'longevity' in title_lower:
        return ("The Longevity Connection", True)

    if 'optimal' in title_lower or 'range' in title_lower or 'target' in title_lower:
        return ("Optimal Ranges", True)

    if any(kw in title_lower for kw in ['how to', 'improve', 'optimize', 'lifestyle', 'exercise', 'training']):
        return ("How to Optimize", True)

    if any(kw in title_lower for kw in ['special', 'consideration', 'caution', 'note', 'medication', 'population']):
        return ("Special Considerations", True)

    if 'bottom line' in title_lower or 'takeaway' in title_lower or 'summary' in title_lower:
        return ("The Bottom Line", True)

    # Default: treat as fragment to merge into How to Optimize
    print(f"    ⚠️  Unclassified: '{title}' - defaulting to How to Optimize")
    return ("How to Optimize", True)

def consolidate_fragmented_biometrics(cur):
    """Consolidate biometrics with > 6 sections into 6-section standard"""
    print("\n" + "="*80)
    print("STEP 4: CONSOLIDATE FRAGMENTED BIOMETRICS")
    print("="*80)

    # Get biometrics with > 6 sections
    cur.execute("""
        SELECT
            b.id,
            b.biometric_name,
            COUNT(*) as section_count
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE bes.is_active = true
        GROUP BY b.id, b.biometric_name
        HAVING COUNT(*) > 6
        ORDER BY COUNT(*) DESC
    """)

    fragmented = cur.fetchall()

    if not fragmented:
        print("\n✓ No fragmented biometrics found")
        return 0

    print(f"\n✓ Found {len(fragmented)} fragmented biometrics\n")

    total_consolidated = 0

    for biometric_id, name, section_count in fragmented:
        print(f"\n{name} ({section_count} sections → 6):")

        # Get all sections
        cur.execute("""
            SELECT id, section_title, section_content, display_order
            FROM biometrics_education_sections
            WHERE biometric_id = %s
              AND is_active = true
            ORDER BY display_order
        """, (biometric_id,))

        sections = cur.fetchall()

        # Classify sections
        categorized = defaultdict(list)

        for section_id, title, content, order in sections:
            category, is_fragment = classify_section(title, content)
            categorized[category].append({
                'id': section_id,
                'title': title,
                'content': content,
                'is_fragment': is_fragment,
                'order': order
            })

        # Show classification
        for category in STANDARD_SECTIONS:
            if category in categorized:
                items = categorized[category]
                main_sections = [s for s in items if not s['is_fragment']]
                fragments = [s for s in items if s['is_fragment']]

                if main_sections:
                    print(f"  ✓ {category}: {len(main_sections)} main")
                if fragments:
                    print(f"    📎 {len(fragments)} fragment(s) to merge")

        # Consolidate each category
        updates = []
        deletes = []

        for idx, category in enumerate(STANDARD_SECTIONS, 1):
            if category not in categorized:
                continue

            items = categorized[category]
            main_sections = [s for s in items if not s['is_fragment']]
            fragments = [s for s in items if s['is_fragment']]

            if not main_sections:
                # No main section - create from fragments
                if fragments:
                    base = fragments[0]
                    merged_content = f"{base['content']}\n\n"

                    for frag in fragments[1:]:
                        if frag['content']:
                            merged_content += f"**{frag['title']}**\n\n{frag['content']}\n\n"
                        deletes.append(frag['id'])

                    updates.append({
                        'id': base['id'],
                        'title': category,
                        'content': merged_content.strip(),
                        'order': idx
                    })
                continue

            # Found main section - merge fragments into it
            main = main_sections[0]

            if len(main_sections) > 1:
                # Multiple main sections - merge them
                merged_content = main['content'] + "\n\n"
                for extra_main in main_sections[1:]:
                    if extra_main['content']:
                        merged_content += f"{extra_main['content']}\n\n"
                    deletes.append(extra_main['id'])
            else:
                merged_content = main['content']

            # Add fragments
            if fragments:
                merged_content += "\n\n"
                for frag in fragments:
                    if frag['content']:
                        merged_content += f"**{frag['title']}**\n\n{frag['content']}\n\n"
                    deletes.append(frag['id'])

            updates.append({
                'id': main['id'],
                'title': category,
                'content': merged_content.strip(),
                'order': idx
            })

        # Execute updates
        for update in updates:
            cur.execute("""
                UPDATE biometrics_education_sections
                SET
                    section_title = %s,
                    section_content = %s,
                    display_order = %s
                WHERE id = %s
            """, (update['title'], update['content'], update['order'], update['id']))

        for delete_id in deletes:
            cur.execute("""
                DELETE FROM biometrics_education_sections
                WHERE id = %s
            """, (delete_id,))

        print(f"  ✅ Consolidated {len(deletes)} sections")
        total_consolidated += 1

    return total_consolidated

def add_missing_sections(cur):
    """Add missing sections to biometrics with < 6 sections"""
    print("\n" + "="*80)
    print("STEP 5: ADD MISSING SECTIONS")
    print("="*80)

    # Get biometrics with < 6 sections
    cur.execute("""
        SELECT
            b.id,
            b.biometric_name,
            COUNT(*) as section_count
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE bes.is_active = true
        GROUP BY b.id, b.biometric_name
        HAVING COUNT(*) < 6
        ORDER BY COUNT(*), b.biometric_name
    """)

    incomplete = cur.fetchall()

    if not incomplete:
        print("\n✓ All biometrics have at least 6 sections")
        return 0

    print(f"\n✓ Found {len(incomplete)} biometrics with < 6 sections\n")

    total_added = 0

    for biometric_id, name, current_count in incomplete:
        print(f"\n{name} ({current_count} sections):")

        # Get existing section titles
        cur.execute("""
            SELECT section_title
            FROM biometrics_education_sections
            WHERE biometric_id = %s
              AND is_active = true
        """, (biometric_id,))

        existing_titles = {row[0] for row in cur.fetchall()}

        # Find missing sections
        missing = [s for s in STANDARD_SECTIONS if s not in existing_titles]

        if missing:
            print(f"  Missing: {', '.join(missing)}")

            # Add each missing section
            for idx, section_title in enumerate(STANDARD_SECTIONS):
                if section_title not in existing_titles:
                    placeholder_content = f"Information about {name} and {section_title.lower()} will be added in a future update."
                    display_order = idx + 1

                    cur.execute("""
                        INSERT INTO biometrics_education_sections
                        (biometric_id, section_title, section_content, display_order, is_active)
                        VALUES (%s, %s, %s, %s, true)
                    """, (biometric_id, section_title, placeholder_content, display_order))

                    print(f"    ✓ Added '{section_title}' (order {display_order})")
                    total_added += 1

    return total_added

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("BIOMETRICS EDUCATION CLEANUP")
    print("="*80)

    # Step 1: Delete blank and placeholder sections
    deleted = delete_blank_and_placeholder_sections(cur)
    conn.commit()

    # Step 2: Merge Understanding+Overview
    merged_understanding = merge_understanding_overview(cur)
    conn.commit()

    # Step 3: Consolidate similar titles
    consolidated_similar = consolidate_similar_titles(cur)
    conn.commit()

    # Step 4: Consolidate fragmented biometrics
    consolidated_fragmented = consolidate_fragmented_biometrics(cur)
    conn.commit()

    # Step 5: Add missing sections
    added = add_missing_sections(cur)
    conn.commit()

    # Verify final state
    print("\n" + "="*80)
    print("FINAL VERIFICATION")
    print("="*80)

    cur.execute("""
        SELECT
            b.biometric_name,
            COUNT(*) as section_count
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE bes.is_active = true
        GROUP BY b.biometric_name
        HAVING COUNT(*) != 6
        ORDER BY COUNT(*) DESC, b.biometric_name
    """)

    remaining_issues = cur.fetchall()

    if remaining_issues:
        print(f"\n⚠️  {len(remaining_issues)} biometrics don't have 6 sections:")
        for name, count in remaining_issues:
            print(f"  - {name}: {count} sections")
    else:
        print("\n🎉 SUCCESS! All biometrics now have exactly 6 sections!")

    # Summary
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Blank/placeholder sections deleted: {deleted}")
    print(f"Understanding+Overview merges: {merged_understanding}")
    print(f"Similar titles consolidated: {consolidated_similar}")
    print(f"Fragmented biometrics fixed: {consolidated_fragmented}")
    print(f"Missing sections added: {added}")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
