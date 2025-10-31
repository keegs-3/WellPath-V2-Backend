#!/usr/bin/env python3
"""
Cleanup duplicate and placeholder education sections for biomarkers and biometrics
"""

import psycopg2
from collections import defaultdict

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def clean_duplicates(table_name, id_field_name, name_table, name_field):
    """Clean duplicate sections and placeholders from education tables"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print(f"\n{'='*80}")
    print(f"CLEANING {table_name}")
    print(f"{'='*80}\n")

    # Get all education sections grouped by biomarker/biometric
    cur.execute(f"""
        SELECT
            es.id,
            n.{name_field} as name,
            es.section_title,
            es.section_content,
            es.display_order,
            LENGTH(es.section_content) as content_length
        FROM {table_name} es
        JOIN {name_table} n ON es.{id_field_name} = n.id
        WHERE es.is_active = true
        ORDER BY n.{name_field}, es.display_order
    """)

    all_sections = cur.fetchall()

    # Group by name
    by_name = defaultdict(list)
    for row in all_sections:
        section_id, name, title, content, order, length = row
        by_name[name].append({
            'id': section_id,
            'title': title,
            'content': content,
            'order': order,
            'length': length
        })

    total_deleted = 0
    total_updated = 0

    for name, sections in sorted(by_name.items()):
        # Find duplicates by title
        title_groups = defaultdict(list)
        for section in sections:
            title_groups[section['title']].append(section)

        duplicates = {title: secs for title, secs in title_groups.items() if len(secs) > 1}

        if not duplicates:
            continue

        print(f"\n{name}:")
        print(f"  Found {len(duplicates)} duplicate section titles")

        for title, dupe_sections in duplicates.items():
            print(f"\n  '{title}' appears {len(dupe_sections)} times:")

            # Sort by content length (descending) - keep the longest one
            dupe_sections.sort(key=lambda x: x['length'], reverse=True)

            # Keep the first (longest), delete the rest
            keeper = dupe_sections[0]
            to_delete = dupe_sections[1:]

            print(f"    Keeping: {keeper['length']} chars (order {keeper['order']})")

            for dup in to_delete:
                print(f"    Deleting: {dup['length']} chars (order {dup['order']})")
                cur.execute(f"""
                    DELETE FROM {table_name}
                    WHERE id = %s
                """, (dup['id'],))
                total_deleted += 1

        # Check for placeholder content
        placeholder_sections = [
            s for s in sections
            if s['content'].strip().startswith('*Content for') or
               s['content'].strip() == '' or
               len(s['content'].strip()) < 50
        ]

        if placeholder_sections:
            print(f"\n  Found {len(placeholder_sections)} placeholder/empty sections:")
            for ps in placeholder_sections:
                print(f"    Deleting: '{ps['title']}' ({ps['length']} chars)")
                cur.execute(f"""
                    DELETE FROM {table_name}
                    WHERE id = %s
                """, (ps['id'],))
                total_deleted += 1

    conn.commit()

    print(f"\n{'='*80}")
    print(f"SUMMARY FOR {table_name}")
    print(f"{'='*80}")
    print(f"Total sections deleted: {total_deleted}")
    print(f"Total sections updated: {total_updated}")

    # Show final counts
    cur.execute(f"""
        SELECT
            n.{name_field},
            COUNT(*) as section_count
        FROM {table_name} es
        JOIN {name_table} n ON es.{id_field_name} = n.id
        WHERE es.is_active = true
        GROUP BY n.{name_field}
        ORDER BY section_count DESC
        LIMIT 10
    """)

    print(f"\nTop 10 by section count (after cleanup):")
    for row in cur.fetchall():
        print(f"  {row[0]}: {row[1]} sections")

    cur.close()
    conn.close()

    return total_deleted

def main():
    print("="*80)
    print("EDUCATION CONTENT CLEANUP")
    print("="*80)
    print("\nThis script will:")
    print("  1. Remove duplicate section titles (keeping the longest content)")
    print("  2. Remove placeholder/empty sections")
    print("  3. Preserve the most complete content for each section")

    # Clean biometrics education
    biometrics_deleted = clean_duplicates(
        table_name='biometrics_education_sections',
        id_field_name='biometric_id',
        name_table='biometrics_base',
        name_field='biometric_name'
    )

    # Clean biomarkers education
    biomarkers_deleted = clean_duplicates(
        table_name='biomarkers_education_sections',
        id_field_name='biomarker_id',
        name_table='biomarkers_base',
        name_field='biomarker_name'
    )

    print(f"\n{'='*80}")
    print("TOTAL CLEANUP SUMMARY")
    print(f"{'='*80}")
    print(f"Biometrics sections deleted: {biometrics_deleted}")
    print(f"Biomarkers sections deleted: {biomarkers_deleted}")
    print(f"Total deleted: {biometrics_deleted + biomarkers_deleted}")
    print(f"\n✅ Education content cleanup complete!")

if __name__ == '__main__':
    main()
