#!/usr/bin/env python3
"""
Parse and section the behaviors and markers content from temp backup tables
"""

import psycopg2
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres?sslmode=require"

def section_behaviors_content(conn, cur):
    """Parse behaviors and create sectioned rows"""
    print("\n" + "="*80)
    print("SECTIONING BEHAVIORS CONTENT")
    print("="*80)

    # Get current data (blobs)
    cur.execute("""
        SELECT pillar_id, about_content
        FROM wellpath_pillars_behaviors_about
        WHERE is_active = true
        ORDER BY pillar_id
    """)

    behaviors = cur.fetchall()

    # Delete existing blobs (will replace with sections)
    cur.execute("""
        DELETE FROM wellpath_pillars_behaviors_about
    """)
    print(f"  Deleted {len(behaviors)} blob rows")

    total_sections = 0

    for pillar_id, content in behaviors:
        print(f"\nProcessing pillar: {pillar_id}")

        # Split content into lines
        lines = content.replace('\r\n', '\n').replace('\r', '\n').split('\n')

        sections = []
        current_section = {'title': None, 'lines': []}

        # Section headers we're looking for
        headers = [
            'What We Measure',
            'Categories of Behaviors',
            '% Weighting',
            'What Improvement Looks Like'
        ]

        for line in lines:
            line_stripped = line.strip()

            # Check if this line is a section header
            is_header = False
            for header in headers:
                if line_stripped == header or (header in line_stripped and '?' in line_stripped and 'Weighting' in line_stripped):
                    is_header = True
                    # Save previous section
                    if current_section['title'] is not None:
                        sections.append({
                            'title': current_section['title'],
                            'content': '\n'.join(current_section['lines']).strip(),
                            'order': len(sections) + 1
                        })
                    # Start new section
                    current_section = {'title': line_stripped, 'lines': []}
                    break

            if not is_header and current_section['title'] is not None:
                current_section['lines'].append(line)

        # Add last section
        if current_section['title'] is not None:
            sections.append({
                'title': current_section['title'],
                'content': '\n'.join(current_section['lines']).strip(),
                'order': len(sections) + 1
            })

        print(f"  Found {len(sections)} sections")

        # Insert sectioned rows
        for section in sections:
            if not section['content']:  # Skip empty sections
                continue

            cur.execute("""
                INSERT INTO wellpath_pillars_behaviors_about (
                    pillar_id,
                    section_title,
                    about_content,
                    display_order,
                    is_active
                )
                VALUES (%s, %s, %s, %s, %s)
            """, (
                pillar_id,
                section['title'],
                section['content'],
                section['order'],
                True
            ))
            total_sections += 1
            print(f"    ✓ {section['order']}. {section['title'][:50]}...")

    conn.commit()
    print(f"\n✅ Created {total_sections} behavior sections")
    return total_sections

def section_markers_content(conn, cur):
    """Parse markers and create sectioned rows"""
    print("\n" + "="*80)
    print("SECTIONING MARKERS CONTENT")
    print("="*80)

    # Get current data (blobs)
    cur.execute("""
        SELECT pillar_id, about_content
        FROM wellpath_pillars_markers_about
        WHERE is_active = true
        ORDER BY pillar_id
    """)

    markers = cur.fetchall()

    # Delete existing blobs (will replace with sections)
    cur.execute("""
        DELETE FROM wellpath_pillars_markers_about
    """)
    print(f"  Deleted {len(markers)} blob rows")

    total_sections = 0

    for pillar_id, content in markers:
        print(f"\nProcessing pillar: {pillar_id}")

        # Split content into lines
        lines = content.replace('\r\n', '\n').replace('\r', '\n').split('\n')

        sections = []
        current_section = {'title': None, 'lines': []}

        # Section headers
        headers = [
            'What We Measure',
            'Categories of Markers',
            '% Weighting',
            'What Improvement Looks Like'
        ]

        for line in lines:
            line_stripped = line.strip()

            # Check if this line is a section header
            is_header = False
            for header in headers:
                if line_stripped == header or (header in line_stripped and '?' in line_stripped and 'Weighting' in line_stripped):
                    is_header = True
                    # Save previous section
                    if current_section['title'] is not None:
                        sections.append({
                            'title': current_section['title'],
                            'content': '\n'.join(current_section['lines']).strip(),
                            'order': len(sections) + 1
                        })
                    # Start new section
                    current_section = {'title': line_stripped, 'lines': []}
                    break

            if not is_header and current_section['title'] is not None:
                current_section['lines'].append(line)

        # Add last section
        if current_section['title'] is not None:
            sections.append({
                'title': current_section['title'],
                'content': '\n'.join(current_section['lines']).strip(),
                'order': len(sections) + 1
            })

        print(f"  Found {len(sections)} sections")

        # Insert sectioned rows
        for section in sections:
            if not section['content']:  # Skip empty sections
                continue

            cur.execute("""
                INSERT INTO wellpath_pillars_markers_about (
                    pillar_id,
                    section_title,
                    about_content,
                    display_order,
                    is_active
                )
                VALUES (%s, %s, %s, %s, %s)
            """, (
                pillar_id,
                section['title'],
                section['content'],
                section['order'],
                True
            ))
            total_sections += 1
            print(f"    ✓ {section['order']}. {section['title'][:50]}...")

    conn.commit()
    print(f"\n✅ Created {total_sections} marker sections")
    return total_sections

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("PARSING BEHAVIORS AND MARKERS CONTENT INTO SECTIONS")
        print("="*80)

        behaviors_count = section_behaviors_content(conn, cur)
        markers_count = section_markers_content(conn, cur)

        # Show final counts
        print("\n" + "="*80)
        print("FINAL ROW COUNTS")
        print("="*80)

        cur.execute("SELECT COUNT(*) FROM wellpath_pillars_about WHERE is_active = true")
        pillars_count = cur.fetchone()[0]
        print(f"  wellpath_pillars_about: {pillars_count} rows")
        print(f"  wellpath_pillars_behaviors_about: {behaviors_count} rows")
        print(f"  wellpath_pillars_markers_about: {markers_count} rows")

        print("\n✅ Sectioning complete!")
        print(f"   Expected: ~28 sections per table (7 pillars × 4 sections)")
        print(f"   Actual: {pillars_count} + {behaviors_count} + {markers_count} = {pillars_count + behaviors_count + markers_count} total sections")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    main()
