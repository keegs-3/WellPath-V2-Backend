#!/usr/bin/env python3
"""
Create standardized education sections for all biomarkers and biometrics
Every biomarker gets the same 7 sections, every biometric gets the same 6 sections
"""

import psycopg2
import re

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres?sslmode=require"

# Standard sections for biomarkers (7)
BIOMARKER_SECTIONS = [
    "Overview",
    "The Longevity Connection",
    "Optimal Ranges",
    "Symptoms & Causes",
    "How to Optimize",
    "Special Considerations",
    "The Bottom Line"
]

# Standard sections for biometrics (6)
BIOMETRIC_SECTIONS = [
    "Overview",
    "The Longevity Connection",
    "Optimal Ranges",
    "How to Optimize",
    "Special Considerations",
    "The Bottom Line"
]

def extract_section_content(full_content, section_keywords):
    """Extract content matching section keywords"""
    content_lower = full_content.lower()

    # Find all matching content
    matches = []
    for keyword in section_keywords:
        # Look for bold headers with this keyword
        pattern = f"\\*\\*.*{keyword.lower()}.*\\*\\*"
        for match in re.finditer(pattern, content_lower):
            start = match.start()
            # Find the end (next bold header or end of content)
            next_header = re.search(r"\*\*[^*]+\*\*", full_content[match.end():])
            if next_header:
                end = match.end() + next_header.start()
            else:
                end = len(full_content)
            matches.append(full_content[start:end].strip())

    return '\n\n'.join(matches) if matches else ""

def parse_biomarker_to_standard_sections(biomarker_name, education_content):
    """Parse biomarker education into 7 standard sections"""
    if not education_content or len(education_content.strip()) < 100:
        # Return empty sections if no content
        return {section: "" for section in BIOMARKER_SECTIONS}

    sections = {}

    # 1. Overview - Get "Understanding [Biomarker]" section
    sections["Overview"] = extract_section_content(
        education_content,
        ["understanding", biomarker_name.lower(), "what is"]
    )

    # 2. The Longevity Connection
    sections["The Longevity Connection"] = extract_section_content(
        education_content,
        ["longevity connection", "why this matters", "longevity"]
    )

    # 3. Optimal Ranges
    sections["Optimal Ranges"] = extract_section_content(
        education_content,
        ["optimal ranges", "optimal", "target", "normal range"]
    )

    # 4. Symptoms & Causes
    sections["Symptoms & Causes"] = extract_section_content(
        education_content,
        ["symptoms", "causes", "elevated", "deficiency", "high", "low"]
    )

    # 5. How to Optimize
    sections["How to Optimize"] = extract_section_content(
        education_content,
        ["how to", "optimize", "lower", "raise", "improve", "manage", "lifestyle", "diet", "exercise"]
    )

    # 6. Special Considerations
    sections["Special Considerations"] = extract_section_content(
        education_content,
        ["special considerations", "monitoring", "medications", "if you"]
    )

    # 7. The Bottom Line
    sections["The Bottom Line"] = extract_section_content(
        education_content,
        ["bottom line", "summary", "key takeaway"]
    )

    # If sections are empty, try to extract from full content
    for section_name in BIOMARKER_SECTIONS:
        if not sections.get(section_name):
            # Use a portion of the full content if we can't find specific section
            if section_name == "Overview" and len(education_content) > 200:
                sections[section_name] = education_content[:500].split('\n\n')[0]

    return sections

def parse_biometric_to_standard_sections(biometric_name, education_content):
    """Parse biometric education into 6 standard sections"""
    if not education_content or len(education_content.strip()) < 100:
        return {section: "" for section in BIOMETRIC_SECTIONS}

    sections = {}

    # 1. Overview
    sections["Overview"] = extract_section_content(
        education_content,
        ["understanding", biometric_name.lower(), "what is"]
    )

    # 2. The Longevity Connection
    sections["The Longevity Connection"] = extract_section_content(
        education_content,
        ["longevity connection", "why this matters", "longevity"]
    )

    # 3. Optimal Ranges
    sections["Optimal Ranges"] = extract_section_content(
        education_content,
        ["optimal ranges", "optimal", "target", "normal"]
    )

    # 4. How to Optimize
    sections["How to Optimize"] = extract_section_content(
        education_content,
        ["how to", "optimize", "improve", "achieve", "lifestyle"]
    )

    # 5. Special Considerations
    sections["Special Considerations"] = extract_section_content(
        education_content,
        ["special considerations", "monitoring", "medications", "if you"]
    )

    # 6. The Bottom Line
    sections["The Bottom Line"] = extract_section_content(
        education_content,
        ["bottom line", "summary", "key takeaway"]
    )

    return sections

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("CREATING STANDARDIZED EDUCATION SECTIONS")
        print("="*80)

        # Process biomarkers
        print("\n" + "="*80)
        print("BIOMARKERS - Creating 7 standard sections for each")
        print("="*80)

        cur.execute("""
            SELECT id, biomarker_name, education
            FROM biomarkers_base
            WHERE is_active = true
            AND education IS NOT NULL
            AND LENGTH(education) > 100
            ORDER BY biomarker_name
        """)

        biomarkers = cur.fetchall()
        print(f"\nProcessing {len(biomarkers)} biomarkers...")

        biomarker_count = 0
        for biomarker_id, biomarker_name, education in biomarkers:
            sections = parse_biomarker_to_standard_sections(biomarker_name, education)

            # Insert all 7 sections
            for order, section_title in enumerate(BIOMARKER_SECTIONS, 1):
                content = sections.get(section_title, "")
                if not content:
                    content = f"*Content for {section_title} will be added soon.*"

                cur.execute("""
                    INSERT INTO biomarkers_education_sections (
                        biomarker_id,
                        section_title,
                        section_content,
                        display_order,
                        is_active
                    )
                    VALUES (%s, %s, %s, %s, %s)
                """, (biomarker_id, section_title, content, order, True))

            biomarker_count += 1
            print(f"  ✓ {biomarker_name}: Created 7 sections")

        # Process biometrics
        print("\n" + "="*80)
        print("BIOMETRICS - Creating 6 standard sections for each")
        print("="*80)

        cur.execute("""
            SELECT id, biometric_name, education
            FROM biometrics_base
            WHERE is_active = true
            AND education IS NOT NULL
            AND LENGTH(education) > 100
            ORDER BY biometric_name
        """)

        biometrics = cur.fetchall()
        print(f"\nProcessing {len(biometrics)} biometrics...")

        biometric_count = 0
        for biometric_id, biometric_name, education in biometrics:
            sections = parse_biometric_to_standard_sections(biometric_name, education)

            # Insert all 6 sections
            for order, section_title in enumerate(BIOMETRIC_SECTIONS, 1):
                content = sections.get(section_title, "")
                if not content:
                    content = f"*Content for {section_title} will be added soon.*"

                cur.execute("""
                    INSERT INTO biometrics_education_sections (
                        biometric_id,
                        section_title,
                        section_content,
                        display_order,
                        is_active
                    )
                    VALUES (%s, %s, %s, %s, %s)
                """, (biometric_id, section_title, content, order, True))

            biometric_count += 1
            print(f"  ✓ {biometric_name}: Created 6 sections")

        conn.commit()

        print("\n" + "="*80)
        print("SUMMARY")
        print("="*80)
        print(f"  Biomarkers: {biomarker_count} × 7 sections = {biomarker_count * 7} total")
        print(f"  Biometrics: {biometric_count} × 6 sections = {biometric_count * 6} total")
        print(f"  Grand Total: {biomarker_count * 7 + biometric_count * 6} sections")
        print("\n✅ Standardized sections created!")

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
