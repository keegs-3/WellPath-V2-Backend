#!/usr/bin/env python3
"""
Parse existing biomarker education content into sections
"""

import psycopg2
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres?sslmode=require"

# Common section headers to look for
SECTION_HEADERS = [
    "Understanding",  # "**Understanding [Biomarker]**"
    "The Longevity Connection",
    "Optimal Ranges",
    "Why Standard Labs",  # Some have this
    "Why It Matters",  # Or this
    "Symptoms of",  # "Symptoms of Deficiency", "Symptoms of High [X]", etc.
    "Causes of",  # "Causes of Elevated [X]", etc.
    "How to Lower",
    "How to Raise",
    "How to Optimize",
    "How to Manage",
    "How to Determine",
    "Monitoring",
    "Special Considerations",
    "The Bottom Line",
    # Additional variations
    "Risks of High",
    "Risks of Low",
    "Why This Matters",
    "Medications",
    "If"  # "If [Biomarker] is High", "If [Biomarker] is Low"
]

def parse_biomarker_education(content, biomarker_name):
    """Parse education content into sections"""
    if not content or len(content.strip()) < 100:
        return []

    # Clean up line endings
    content = content.replace('\r\n', '\n').replace('\r', '\n')

    sections = []
    lines = content.split('\n')

    current_section = {'title': None, 'lines': [], 'order': 0}
    section_num = 0

    for line in lines:
        line_stripped = line.strip()

        # Check if this line is a section header (bold text ending with :)
        is_header = False

        # Pattern 1: **Header:**
        if line_stripped.startswith('**') and (':**' in line_stripped or '**' == line_stripped[-2:]):
            # Extract the header text
            header_text = line_stripped.replace('**', '').replace(':', '').strip()

            # Check if it matches any of our known headers
            for known_header in SECTION_HEADERS:
                if known_header.lower() in header_text.lower():
                    is_header = True
                    # Save previous section
                    if current_section['title'] is not None and current_section['lines']:
                        sections.append({
                            'title': current_section['title'],
                            'content': '\n'.join(current_section['lines']).strip(),
                            'order': current_section['order']
                        })
                    # Start new section
                    section_num += 1
                    current_section = {
                        'title': header_text,
                        'lines': [],
                        'order': section_num
                    }
                    break

        if not is_header and current_section['title'] is not None:
            current_section['lines'].append(line)

    # Add last section
    if current_section['title'] is not None and current_section['lines']:
        sections.append({
            'title': current_section['title'],
            'content': '\n'.join(current_section['lines']).strip(),
            'order': current_section['order']
        })

    return sections

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("PARSING BIOMARKER EDUCATION INTO SECTIONS")
        print("="*80)

        # Get all biomarkers with education content
        cur.execute("""
            SELECT id, biomarker_name, education
            FROM biomarkers_base
            WHERE is_active = true
            AND education IS NOT NULL
            AND LENGTH(education) > 100
            ORDER BY biomarker_name
        """)

        biomarkers = cur.fetchall()
        print(f"\nFound {len(biomarkers)} biomarkers with education content")

        total_sections = 0

        for biomarker_id, biomarker_name, education in biomarkers:
            print(f"\nProcessing: {biomarker_name}")

            sections = parse_biomarker_education(education, biomarker_name)

            if not sections:
                print(f"  ⚠️  No sections found, skipping")
                continue

            print(f"  Found {len(sections)} sections:")

            # Insert sections
            for section in sections:
                cur.execute("""
                    INSERT INTO biomarkers_education_sections (
                        biomarker_id,
                        section_title,
                        section_content,
                        display_order,
                        is_active
                    )
                    VALUES (%s, %s, %s, %s, %s)
                """, (
                    biomarker_id,
                    section['title'],
                    section['content'],
                    section['order'],
                    True
                ))
                total_sections += 1
                print(f"    ✓ {section['order']}. {section['title'][:60]}...")

        conn.commit()

        print("\n" + "="*80)
        print(f"✅ Created {total_sections} education sections for {len(biomarkers)} biomarkers")
        print("="*80)

        # Show summary
        cur.execute("""
            SELECT
                COUNT(*) as total_sections,
                COUNT(DISTINCT biomarker_id) as unique_biomarkers,
                ROUND(AVG(sections_per_biomarker), 1) as avg_sections
            FROM (
                SELECT biomarker_id, COUNT(*) as sections_per_biomarker
                FROM biomarkers_education_sections
                WHERE is_active = true
                GROUP BY biomarker_id
            ) sub
        """)

        stats = cur.fetchone()
        if stats:
            print(f"\nFinal Stats:")
            print(f"  Total sections: {stats[0]}")
            print(f"  Biomarkers with sections: {stats[1]}")
            print(f"  Average sections per biomarker: {stats[2]}")

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
