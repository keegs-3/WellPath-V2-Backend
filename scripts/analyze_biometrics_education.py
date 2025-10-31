#!/usr/bin/env python3
"""
Analyze biometrics_education_sections to identify cleanup needs
"""

import psycopg2
from collections import defaultdict

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def analyze():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("BIOMETRICS EDUCATION ANALYSIS")
    print("="*80)

    # Get all biometric sections
    cur.execute("""
        SELECT
            b.biometric_name,
            bes.id,
            bes.section_title,
            bes.section_content,
            bes.display_order,
            LENGTH(bes.section_content) as content_length
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE bes.is_active = true
        ORDER BY b.biometric_name, bes.display_order
    """)

    all_sections = cur.fetchall()

    # Group by biometric
    by_biometric = defaultdict(list)
    for biometric_name, section_id, title, content, order, length in all_sections:
        by_biometric[biometric_name].append({
            'id': section_id,
            'title': title,
            'content': content,
            'order': order,
            'length': length
        })

    print(f"\n✓ Found {len(by_biometric)} biometrics with {len(all_sections)} total sections\n")

    # ISSUE 1: Blank or placeholder sections
    print("="*80)
    print("ISSUE 1: BLANK OR PLACEHOLDER SECTIONS")
    print("="*80)

    blank_sections = []
    placeholder_sections = []

    for biometric_name, sections in sorted(by_biometric.items()):
        for section in sections:
            if section['length'] == 0:
                blank_sections.append((biometric_name, section['title']))
            elif section['content'].strip().startswith('*Content for'):
                placeholder_sections.append((biometric_name, section['title']))

    if blank_sections:
        print(f"\n⚠️  {len(blank_sections)} BLANK sections (0 characters):")
        for name, title in blank_sections:
            print(f"  - {name}: '{title}'")
    else:
        print("\n✓ No blank sections")

    if placeholder_sections:
        print(f"\n⚠️  {len(placeholder_sections)} PLACEHOLDER sections:")
        for name, title in placeholder_sections:
            print(f"  - {name}: '{title}'")
    else:
        print("\n✓ No placeholder sections")

    # ISSUE 2: "Understanding X" + "Overview" pairs
    print("\n" + "="*80)
    print("ISSUE 2: 'UNDERSTANDING' + 'OVERVIEW' DUPLICATION")
    print("="*80)

    understanding_overview_pairs = []

    for biometric_name, sections in sorted(by_biometric.items()):
        titles = [s['title'] for s in sections]
        has_understanding = any('Understanding' in t for t in titles)
        has_overview = any(t == 'Overview' for t in titles)

        if has_understanding and has_overview:
            understanding_title = next(t for t in titles if 'Understanding' in t)
            understanding_overview_pairs.append((biometric_name, understanding_title, 'Overview'))

    if understanding_overview_pairs:
        print(f"\n⚠️  {len(understanding_overview_pairs)} biometrics with BOTH 'Understanding' and 'Overview':")
        for name, understanding_title, _ in understanding_overview_pairs:
            print(f"  - {name}: '{understanding_title}' + 'Overview'")
    else:
        print("\n✓ No Understanding+Overview pairs")

    # ISSUE 3: Likely duplicate content (similar titles)
    print("\n" + "="*80)
    print("ISSUE 3: SIMILAR/DUPLICATE TITLES")
    print("="*80)

    similar_pairs = []

    for biometric_name, sections in sorted(by_biometric.items()):
        titles = [s['title'] for s in sections]

        # Check for "Optimal Ranges" variations
        optimal_range_titles = [t for t in titles if 'Optimal' in t and 'Range' in t]
        if len(optimal_range_titles) > 1:
            similar_pairs.append((biometric_name, 'Multiple Optimal Ranges', ', '.join(optimal_range_titles)))

        # Check for "How to" variations
        how_to_titles = [t for t in titles if 'How to' in t or 'How to' in t]
        if len(how_to_titles) > 1:
            similar_pairs.append((biometric_name, 'Multiple How To', ', '.join(how_to_titles)))

        # Check for "The Longevity Connection" variations
        longevity_titles = [t for t in titles if 'Longevity Connection' in t]
        if len(longevity_titles) > 1:
            similar_pairs.append((biometric_name, 'Multiple Longevity', ', '.join(longevity_titles)))

    if similar_pairs:
        print(f"\n⚠️  {len(similar_pairs)} biometrics with similar/duplicate titles:")
        for name, issue_type, titles in similar_pairs:
            print(f"  - {name} [{issue_type}]: {titles}")
    else:
        print("\n✓ No similar title patterns found")

    # ISSUE 4: Section count distribution
    print("\n" + "="*80)
    print("ISSUE 4: SECTION COUNT DISTRIBUTION")
    print("="*80)

    section_counts = defaultdict(list)
    for biometric_name, sections in by_biometric.items():
        count = len(sections)
        section_counts[count].append(biometric_name)

    print("\nSection count distribution:")
    for count in sorted(section_counts.keys(), reverse=True):
        biometrics = section_counts[count]
        print(f"  {count} sections: {len(biometrics)} biometrics")
        if count >= 10:
            print(f"    (Likely fragmented: {', '.join(biometrics)})")

    # ISSUE 5: Fragmented biometrics (> 7 sections)
    print("\n" + "="*80)
    print("ISSUE 5: FRAGMENTED BIOMETRICS (>7 SECTIONS)")
    print("="*80)

    fragmented = []
    for biometric_name, sections in sorted(by_biometric.items()):
        if len(sections) > 7:
            fragmented.append((biometric_name, len(sections)))

    if fragmented:
        print(f"\n⚠️  {len(fragmented)} biometrics with > 7 sections:")
        for name, count in sorted(fragmented, key=lambda x: x[1], reverse=True):
            print(f"  - {name}: {count} sections")
    else:
        print("\n✓ No fragmented biometrics")

    # SUMMARY
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)

    total_issues = (
        len(blank_sections) +
        len(placeholder_sections) +
        len(understanding_overview_pairs) +
        len(similar_pairs) +
        len(fragmented)
    )

    print(f"\nTotal issues found: {total_issues}")
    print(f"  - Blank sections: {len(blank_sections)}")
    print(f"  - Placeholder sections: {len(placeholder_sections)}")
    print(f"  - Understanding+Overview duplicates: {len(understanding_overview_pairs)}")
    print(f"  - Similar title patterns: {len(similar_pairs)}")
    print(f"  - Fragmented biometrics (>7 sections): {len(fragmented)}")

    # Propose standard structure
    print("\n" + "="*80)
    print("PROPOSED STANDARD STRUCTURE")
    print("="*80)

    # Count common section titles
    title_frequency = defaultdict(int)
    for sections in by_biometric.values():
        for section in sections:
            # Normalize titles
            title = section['title']
            if 'Understanding' in title or title == 'Overview':
                title_frequency['Overview'] += 1
            elif 'Longevity Connection' in title:
                title_frequency['The Longevity Connection'] += 1
            elif 'Optimal' in title and 'Range' in title:
                title_frequency['Optimal Ranges'] += 1
            elif 'How to' in title:
                title_frequency['How to Optimize'] += 1
            elif 'Special Considerations' in title:
                title_frequency['Special Considerations'] += 1
            elif 'Bottom Line' in title:
                title_frequency['The Bottom Line'] += 1

    print("\nMost common section categories:")
    for title, count in sorted(title_frequency.items(), key=lambda x: x[1], reverse=True):
        percentage = (count / len(by_biometric)) * 100
        print(f"  {title}: {count}/{len(by_biometric)} biometrics ({percentage:.0f}%)")

    print("\n" + "="*80)
    print("RECOMMENDED ACTIONS")
    print("="*80)

    print("\n1. Delete blank sections (6 sections)")
    print("2. Delete or fill placeholder sections (3 sections)")
    print("3. Merge 'Understanding X' into 'Overview' (BMI, VO2 Max, etc.)")
    print("4. Consolidate duplicate 'Optimal Ranges' variations (BMI)")
    print("5. Merge duplicate 'Longevity Connection' sections (VO2 Max)")
    print("6. Consolidate fragmented biometrics (WellPath PACE, DunedinPACE, etc.)")
    print("7. Standardize section count (propose 6 sections)")

    print("\nProposed 6-section standard:")
    print("  1. Overview (merge 'Understanding X')")
    print("  2. The Longevity Connection")
    print("  3. Optimal Ranges")
    print("  4. How to Optimize (merge 'How to Improve')")
    print("  5. Special Considerations")
    print("  6. The Bottom Line")

    cur.close()
    conn.close()

if __name__ == '__main__':
    analyze()
