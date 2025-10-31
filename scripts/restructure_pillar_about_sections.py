#!/usr/bin/env python3
"""
Restructure pillar about tables from blob format to sectioned format
Similar to wellpath_score_about structure
"""

import psycopg2
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres?sslmode=require"

def parse_sections(content, expected_headers):
    """Parse content blob into sections based on headers"""
    sections = []

    # Clean up line endings
    content = content.replace('\r\n', '\n').replace('\r', '\n')

    # Split by headers
    for i, header in enumerate(expected_headers):
        # Find this header
        pattern = re.escape(header)
        match = re.search(pattern, content, re.IGNORECASE)

        if not match:
            print(f"  ⚠️  Could not find header: {header}")
            continue

        start = match.end()

        # Find next header or end of content
        if i < len(expected_headers) - 1:
            next_pattern = re.escape(expected_headers[i + 1])
            next_match = re.search(next_pattern, content[start:], re.IGNORECASE)
            if next_match:
                end = start + next_match.start()
            else:
                end = len(content)
        else:
            end = len(content)

        section_content = content[start:end].strip()

        sections.append({
            'title': header,
            'content': section_content,
            'order': i + 1
        })

    return sections

def restructure_pillars_about(conn, cur):
    """Restructure wellpath_pillars_about into sections"""
    print("\n" + "="*80)
    print("RESTRUCTURING wellpath_pillars_about")
    print("="*80)

    # First, add section_title and display_order columns if they don't exist
    cur.execute("""
        ALTER TABLE wellpath_pillars_about
        ADD COLUMN IF NOT EXISTS section_title TEXT,
        ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 1;
    """)
    conn.commit()

    # Get all current pillars
    cur.execute("""
        SELECT pillar_id, about_content
        FROM wellpath_pillars_about
        WHERE is_active = true
        ORDER BY pillar_id
    """)

    pillars = cur.fetchall()

    # Expected section headers for pillars_about
    headers = [
        "What Is",  # Flexible match for "What Is Movement + Exercise?" etc.
        "How This Pillar Is Scored",
        "Why This Weighting?",
        "Why This Matters for Longevity"
    ]

    total_sections = 0

    for pillar_id, content in pillars:
        print(f"\nProcessing pillar: {pillar_id}")

        # Parse sections
        sections = []

        # Split by major headers
        lines = content.split('\n')
        current_section = {'title': '', 'content': [], 'order': 0}
        section_num = 0

        for line in lines:
            line_stripped = line.strip()

            # Check if this is a header
            is_header = False
            for header in headers:
                if header.lower() in line_stripped.lower() and line_stripped.endswith('?'):
                    is_header = True
                    # Save previous section
                    if current_section['title']:
                        sections.append({
                            'title': current_section['title'],
                            'content': '\n'.join(current_section['content']).strip(),
                            'order': current_section['order']
                        })
                    # Start new section
                    section_num += 1
                    current_section = {
                        'title': line_stripped,
                        'content': [],
                        'order': section_num
                    }
                    break

            if not is_header and current_section['title']:
                current_section['content'].append(line)

        # Add last section
        if current_section['title']:
            sections.append({
                'title': current_section['title'],
                'content': '\n'.join(current_section['content']).strip(),
                'order': current_section['order']
            })

        print(f"  Found {len(sections)} sections")

        if not sections:
            print(f"  ⚠️  No sections found, skipping...")
            continue

        # Delete old blob row
        cur.execute("""
            DELETE FROM wellpath_pillars_about
            WHERE pillar_id = %s
        """, (pillar_id,))

        # Insert sectioned rows
        for section in sections:
            cur.execute("""
                INSERT INTO wellpath_pillars_about (
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
            print(f"    ✓ {section['order']}. {section['title']}")

    conn.commit()
    print(f"\n✅ Created {total_sections} section rows in wellpath_pillars_about")

def restructure_behaviors_about(conn, cur):
    """Restructure wellpath_pillars_behaviors_about into sections"""
    print("\n" + "="*80)
    print("RESTRUCTURING wellpath_pillars_behaviors_about")
    print("="*80)

    # Get all current pillars
    cur.execute("""
        SELECT pillar_id, about_content
        FROM wellpath_pillars_behaviors_about
        WHERE is_active = true
        ORDER BY pillar_id
    """)

    pillars = cur.fetchall()

    headers = [
        "What We Measure",
        "Categories of Behaviors",
        "% Weighting",
        "What Improvement Looks Like"
    ]

    total_sections = 0

    for pillar_id, content in pillars:
        print(f"\nProcessing pillar: {pillar_id}")

        sections = []
        lines = content.split('\n')
        current_section = {'title': '', 'content': [], 'order': 0}
        section_num = 0

        for line in lines:
            line_stripped = line.strip()

            # Check if this is a header
            is_header = False

            # Check for exact matches or pattern matches
            if line_stripped == "What We Measure":
                is_header = True
            elif line_stripped == "Categories of Behaviors":
                is_header = True
            elif "% Weighting" in line_stripped and line_stripped.endswith('?'):
                is_header = True
            elif line_stripped == "What Improvement Looks Like":
                is_header = True

            if is_header:
                # Save previous section
                if current_section['title']:
                    sections.append({
                        'title': current_section['title'],
                        'content': '\n'.join(current_section['content']).strip(),
                        'order': current_section['order']
                    })
                # Start new section
                section_num += 1
                current_section = {
                    'title': line_stripped,
                    'content': [],
                    'order': section_num
                }
            elif current_section['title']:
                current_section['content'].append(line)

        # Add last section
        if current_section['title']:
            sections.append({
                'title': current_section['title'],
                'content': '\n'.join(current_section['content']).strip(),
                'order': current_section['order']
            })

        print(f"  Found {len(sections)} sections")

        if not sections:
            print(f"  ⚠️  No sections found, skipping...")
            continue

        # Delete old blob row
        cur.execute("""
            DELETE FROM wellpath_pillars_behaviors_about
            WHERE pillar_id = %s
        """, (pillar_id,))

        # Insert sectioned rows
        for section in sections:
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
            print(f"    ✓ {section['order']}. {section['title']}")

    conn.commit()
    print(f"\n✅ Created {total_sections} section rows in wellpath_pillars_behaviors_about")

def restructure_markers_about(conn, cur):
    """Restructure wellpath_pillars_markers_about into sections"""
    print("\n" + "="*80)
    print("RESTRUCTURING wellpath_pillars_markers_about")
    print("="*80)

    # Get all current pillars
    cur.execute("""
        SELECT pillar_id, about_content
        FROM wellpath_pillars_markers_about
        WHERE is_active = true
        ORDER BY pillar_id
    """)

    pillars = cur.fetchall()

    total_sections = 0

    for pillar_id, content in pillars:
        print(f"\nProcessing pillar: {pillar_id}")

        sections = []
        lines = content.split('\n')
        current_section = {'title': '', 'content': [], 'order': 0}
        section_num = 0

        for line in lines:
            line_stripped = line.strip()

            # Check if this is a header
            is_header = False

            if line_stripped == "What We Measure":
                is_header = True
            elif line_stripped == "Categories of Markers":
                is_header = True
            elif "% Weighting" in line_stripped and line_stripped.endswith('?'):
                is_header = True
            elif line_stripped == "What Improvement Looks Like":
                is_header = True

            if is_header:
                # Save previous section
                if current_section['title']:
                    sections.append({
                        'title': current_section['title'],
                        'content': '\n'.join(current_section['content']).strip(),
                        'order': current_section['order']
                    })
                # Start new section
                section_num += 1
                current_section = {
                    'title': line_stripped,
                    'content': [],
                    'order': section_num
                }
            elif current_section['title']:
                current_section['content'].append(line)

        # Add last section
        if current_section['title']:
            sections.append({
                'title': current_section['title'],
                'content': '\n'.join(current_section['content']).strip(),
                'order': current_section['order']
            })

        print(f"  Found {len(sections)} sections")

        if not sections:
            print(f"  ⚠️  No sections found, skipping...")
            continue

        # Delete old blob row
        cur.execute("""
            DELETE FROM wellpath_pillars_markers_about
            WHERE pillar_id = %s
        """, (pillar_id,))

        # Insert sectioned rows
        for section in sections:
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
            print(f"    ✓ {section['order']}. {section['title']}")

    conn.commit()
    print(f"\n✅ Created {total_sections} section rows in wellpath_pillars_markers_about")

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("PILLAR ABOUT SECTIONS RESTRUCTURING")
        print("="*80)

        # Restructure each table
        restructure_pillars_about(conn, cur)
        restructure_behaviors_about(conn, cur)
        restructure_markers_about(conn, cur)

        # Show final counts
        print("\n" + "="*80)
        print("FINAL ROW COUNTS")
        print("="*80)

        for table in ['wellpath_pillars_about', 'wellpath_pillars_behaviors_about', 'wellpath_pillars_markers_about']:
            cur.execute(f"SELECT COUNT(*) FROM {table} WHERE is_active = true")
            count = cur.fetchone()[0]
            print(f"  {table}: {count} rows")

        print("\n✅ Restructuring complete!")

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
