#!/usr/bin/env python3
"""
Consolidate fragmented biomarker education sections into the standard 7-section structure
"""

import psycopg2
from collections import defaultdict
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Standard 7-section structure (from Albumin)
STANDARD_SECTIONS = [
    "Overview",
    "The Longevity Connection",
    "Optimal Ranges",
    "Symptoms & Causes",
    "How to Optimize",
    "Special Considerations",
    "The Bottom Line"
]

def classify_section(title, content):
    """
    Classify a section as either one of the 7 standard sections or a fragment
    Returns: (category, is_fragment)
    """
    title_lower = title.lower()

    # Check if it's an exact or close match to standard sections
    for standard in STANDARD_SECTIONS:
        if standard.lower() in title_lower or title_lower in standard.lower():
            return (standard, False)

    # Fragment patterns - these should be merged into parent sections

    # Numbered subsections (e.g., "1. Lifestyle Interventions", "4. Medications")
    if re.match(r'^\d+\.', title):
        # Treatment/optimization related
        if any(kw in title_lower for kw in ['lifestyle', 'diet', 'exercise', 'supplement', 'medication', 'treatment', 'intervention']):
            return ("How to Optimize", True)
        # Symptom/cause related
        if any(kw in title_lower for kw in ['symptom', 'sign', 'cause', 'risk']):
            return ("Symptoms & Causes", True)
        # Default to How to Optimize for numbered lists
        return ("How to Optimize", True)

    # "Causes of..." fragments
    if 'causes of' in title_lower or 'symptoms of' in title_lower:
        return ("Symptoms & Causes", True)

    # "If..." conditional fragments (usually treatment branches)
    if title.startswith('If '):
        return ("How to Optimize", True)

    # Treatment/optimization keywords
    if any(kw in title_lower for kw in ['how to', 'treatment', 'optimize', 'improve', 'manage', 'protocol', 'strategy', 'lifestyle', 'diet', 'exercise']):
        return ("How to Optimize", True)

    # Symptom/cause keywords
    if any(kw in title_lower for kw in ['symptom', 'sign', 'cause', 'risk factor', 'elevated', 'low', 'high', 'deficiency']):
        return ("Symptoms & Causes", True)

    # Range/target keywords
    if any(kw in title_lower for kw in ['range', 'target', 'optimal', 'goal', 'threshold']):
        return ("Optimal Ranges", True)

    # Special population/consideration keywords
    if any(kw in title_lower for kw in ['special', 'consideration', 'caution', 'note', 'warning', 'age', 'pregnancy', 'medication interaction']):
        return ("Special Considerations", True)

    # Longevity/why keywords
    if any(kw in title_lower for kw in ['longevity', 'why', 'importance', 'connection', 'aging', 'lifespan', 'healthspan']):
        return ("The Longevity Connection", True)

    # Bottom line/summary keywords
    if any(kw in title_lower for kw in ['bottom line', 'summary', 'takeaway', 'key point']):
        return ("The Bottom Line", True)

    # Overview/understanding keywords
    if any(kw in title_lower for kw in ['overview', 'understanding', 'what is', 'about', 'introduction']):
        return ("Overview", True)

    # Default: treat as fragment to merge into How to Optimize
    print(f"  ⚠️  Unclassified fragment: '{title}' - defaulting to How to Optimize")
    return ("How to Optimize", True)

def consolidate_biomarker(biomarker_id, biomarker_name, sections, cur):
    """
    Consolidate fragmented sections for a single biomarker
    """
    print(f"\n{'='*80}")
    print(f"CONSOLIDATING: {biomarker_name} ({len(sections)} sections → 7)")
    print(f"{'='*80}")

    # Group sections by their category
    categorized = defaultdict(list)

    for section in sections:
        category, is_fragment = classify_section(section['title'], section['content'])
        categorized[category].append({
            'id': section['id'],
            'title': section['title'],
            'content': section['content'],
            'is_fragment': is_fragment,
            'order': section['order']
        })

    # Show classification
    for category in STANDARD_SECTIONS:
        if category in categorized:
            items = categorized[category]
            main_sections = [s for s in items if not s['is_fragment']]
            fragments = [s for s in items if s['is_fragment']]

            print(f"\n{category}:")
            if main_sections:
                for s in main_sections:
                    print(f"  ✓ Main: '{s['title']}' ({len(s['content'])} chars)")
            if fragments:
                print(f"  📎 Fragments to merge ({len(fragments)}):")
                for s in fragments:
                    print(f"     - '{s['title']}' ({len(s['content'])} chars)")

    # Consolidate each category
    updates = []
    deletes = []

    for idx, category in enumerate(STANDARD_SECTIONS, 1):
        if category not in categorized:
            print(f"\n⚠️  Missing category: {category}")
            continue

        items = categorized[category]
        main_sections = [s for s in items if not s['is_fragment']]
        fragments = [s for s in items if s['is_fragment']]

        if not main_sections:
            # No main section found - create one from the first fragment
            print(f"\n⚠️  No main section for '{category}' - will create from fragments")
            if fragments:
                # Use first fragment as base, merge rest
                base = fragments[0]
                merged_content = f"{base['content']}\n\n"

                for frag in fragments[1:]:
                    merged_content += f"**{frag['title']}**\n\n{frag['content']}\n\n"
                    deletes.append(frag['id'])

                # Update the base fragment to become the main section
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
            # Multiple main sections - shouldn't happen but merge them
            print(f"  ⚠️  Multiple main sections for '{category}' - merging")
            merged_content = main['content'] + "\n\n"
            for extra_main in main_sections[1:]:
                merged_content += f"{extra_main['content']}\n\n"
                deletes.append(extra_main['id'])
        else:
            merged_content = main['content']

        # Add fragments
        if fragments:
            merged_content += "\n\n"
            for frag in fragments:
                # Add fragment title as a subsection header
                merged_content += f"**{frag['title']}**\n\n{frag['content']}\n\n"
                deletes.append(frag['id'])

        # Update main section with merged content
        updates.append({
            'id': main['id'],
            'title': category,  # Normalize to standard name
            'content': merged_content.strip(),
            'order': idx
        })

    # Execute updates
    print(f"\n📝 Executing {len(updates)} updates and {len(deletes)} deletes...")

    for update in updates:
        cur.execute("""
            UPDATE biomarkers_education_sections
            SET
                section_title = %s,
                section_content = %s,
                display_order = %s
            WHERE id = %s
        """, (update['title'], update['content'], update['order'], update['id']))

    for delete_id in deletes:
        cur.execute("""
            DELETE FROM biomarkers_education_sections
            WHERE id = %s
        """, (delete_id,))

    print(f"✅ Consolidated {biomarker_name}: {len(sections)} sections → 7 sections")
    return len(updates), len(deletes)

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("BIOMARKER EDUCATION CONSOLIDATION")
    print("="*80)
    print("\nThis script will:")
    print("  1. Identify biomarkers with > 7 sections (fragmented)")
    print("  2. Classify sections into 7 standard categories")
    print("  3. Merge fragmented subsections into parent sections")
    print("  4. Ensure all biomarkers have exactly 7 sections")

    # Get all biomarkers with > 7 sections
    cur.execute("""
        SELECT
            b.id,
            b.biomarker_name,
            COUNT(*) as section_count
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE bes.is_active = true
        GROUP BY b.id, b.biomarker_name
        HAVING COUNT(*) > 7
        ORDER BY COUNT(*) DESC
    """)

    broken_biomarkers = cur.fetchall()
    print(f"\n✓ Found {len(broken_biomarkers)} biomarkers with fragmented sections\n")

    if not broken_biomarkers:
        print("✅ All biomarkers already have 7 sections!")
        return

    total_updates = 0
    total_deletes = 0

    for biomarker_id, biomarker_name, section_count in broken_biomarkers:
        # Get all sections for this biomarker
        cur.execute("""
            SELECT
                id,
                section_title,
                section_content,
                display_order
            FROM biomarkers_education_sections
            WHERE biomarker_id = %s
              AND is_active = true
            ORDER BY display_order
        """, (biomarker_id,))

        sections = [
            {
                'id': row[0],
                'title': row[1],
                'content': row[2],
                'order': row[3]
            }
            for row in cur.fetchall()
        ]

        updates, deletes = consolidate_biomarker(biomarker_id, biomarker_name, sections, cur)
        total_updates += updates
        total_deletes += deletes

    # Commit all changes
    conn.commit()

    # Verify results
    cur.execute("""
        SELECT
            b.biomarker_name,
            COUNT(*) as section_count
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE bes.is_active = true
        GROUP BY b.biomarker_name
        ORDER BY section_count DESC, b.biomarker_name
    """)

    results = cur.fetchall()

    print("\n" + "="*80)
    print("CONSOLIDATION COMPLETE")
    print("="*80)
    print(f"Total updates: {total_updates}")
    print(f"Total deletes: {total_deletes}")
    print(f"\nFinal section counts:")

    correct_count = 0
    incorrect_count = 0

    for biomarker_name, count in results:
        if count == 7:
            correct_count += 1
        else:
            incorrect_count += 1
            print(f"  ⚠️  {biomarker_name}: {count} sections")

    print(f"\n✅ {correct_count} biomarkers with 7 sections (correct)")
    if incorrect_count > 0:
        print(f"⚠️  {incorrect_count} biomarkers still have != 7 sections")
    else:
        print("🎉 ALL biomarkers now have exactly 7 sections!")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
