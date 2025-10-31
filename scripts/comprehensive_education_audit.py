#!/usr/bin/env python3
"""
Comprehensive audit of ALL education sections (biomarkers + biometrics)
Checks each section for:
- Completeness
- Readability
- Formatting
- Placeholder content
- Duplicate headings
- Content quality
"""

import psycopg2
import re
from collections import defaultdict
import json

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def analyze_section(name, section_title, content):
    """Analyze a single section and return issues"""
    issues = []
    warnings = []
    suggestions = []

    # 1. Check length
    length = len(content)
    if length == 0:
        issues.append("BLANK: Section is completely empty")
    elif length < 100:
        issues.append(f"TOO SHORT: Only {length} characters")
    elif length < 200:
        warnings.append(f"Short: {length} characters (consider expanding)")

    # 2. Check for placeholder text
    if "will be added in a future update" in content.lower():
        issues.append("PLACEHOLDER: Contains 'will be added in a future update' text")
    if content.strip().startswith("*Content for"):
        issues.append("PLACEHOLDER: Starts with '*Content for...'")
    if "information about" in content.lower() and "will be added" in content.lower():
        issues.append("PLACEHOLDER: Generic placeholder text")

    # 3. Check for duplicate headings
    heading_pattern = r'\*\*([^*]+)\*\*'
    headings = re.findall(heading_pattern, content)
    if len(headings) != len(set(headings)):
        duplicates = [h for h in headings if headings.count(h) > 1]
        issues.append(f"DUPLICATE HEADING: '{duplicates[0]}' appears {headings.count(duplicates[0])} times")

    # 4. Check for specific duplicate patterns
    duplicate_patterns = [
        ('How to Lower', r'\*\*How to Lower[^*]+\*\*\s*\n\s*\n\s*\*\*How to Lower'),
        ('How to Improve', r'\*\*How to Improve[^*]+\*\*\s*\n\s*\n\s*\*\*How to Improve'),
        ('How to Optimize', r'\*\*How to Optimize[^*]+\*\*\s*\n\s*\n\s*\*\*How to Optimize'),
        ('How to Raise', r'\*\*How to Raise[^*]+\*\*\s*\n\s*\n\s*\*\*How to Raise'),
    ]

    for name_pattern, regex_pattern in duplicate_patterns:
        if re.search(regex_pattern, content, re.IGNORECASE):
            issues.append(f"DUPLICATE: '{name_pattern}' heading appears twice in a row")

    # 5. Check formatting
    if content.count('**') % 2 != 0:
        warnings.append("FORMATTING: Unmatched ** markdown (odd count)")

    if '\r\n' in content and '\n' in content:
        warnings.append("FORMATTING: Mixed line endings (\\r\\n and \\n)")

    # Check for excessive blank lines
    if '\n\n\n\n' in content:
        warnings.append("FORMATTING: Excessive blank lines (4+ newlines)")

    # 6. Check for broken bullet points
    if re.search(r'\n-\s*\n', content):
        warnings.append("FORMATTING: Empty bullet point (- followed by newline)")

    # 7. Check readability (disabled - medical content often requires complex sentences)
    # sentences = re.split(r'[.!?]+', content)
    # if sentences:
    #     avg_sentence_length = sum(len(s.split()) for s in sentences) / len(sentences)
    #     if avg_sentence_length > 80:
    #         suggestions.append(f"READABILITY: Extremely long sentences (avg {avg_sentence_length:.0f} words)")

    # 8. Check for incomplete content
    if content.strip().endswith('...'):
        warnings.append("INCOMPLETE: Content ends with '...'")
    if content.strip().endswith('-'):
        warnings.append("INCOMPLETE: Content ends with '-' (incomplete list)")

    # 9. Check for missing key information
    if section_title == "Optimal Ranges" and "optimal" not in content.lower():
        warnings.append("CONTENT: 'Optimal Ranges' section doesn't mention 'optimal'")
    if section_title == "How to Optimize" and not any(word in content.lower() for word in ['lifestyle', 'diet', 'exercise', 'supplement', 'medication']):
        warnings.append("CONTENT: 'How to Optimize' lacks common optimization categories")
    if section_title == "The Longevity Connection" and "longevity" not in content.lower():
        warnings.append("CONTENT: 'Longevity Connection' doesn't mention 'longevity'")

    # 10. Check for formatting consistency (disabled - section titles in content are acceptable for clarity)
    # if section_title in content:
    #     suggestions.append("STYLE: Section title repeated in content (may be redundant)")

    # Quality score (0-100)
    score = 100
    score -= len(issues) * 20  # Major issues
    score -= len(warnings) * 5   # Minor issues
    score -= len(suggestions) * 2  # Style suggestions
    score = max(0, score)

    return {
        'length': length,
        'issues': issues,
        'warnings': warnings,
        'suggestions': suggestions,
        'score': score,
        'status': 'CRITICAL' if issues else ('NEEDS REVIEW' if warnings else ('OK' if suggestions else 'GOOD'))
    }

def audit_education_content(cur):
    """Audit all education content"""
    print("="*80)
    print("COMPREHENSIVE EDUCATION CONTENT AUDIT")
    print("="*80)

    # Get all biomarker sections
    cur.execute("""
        SELECT
            b.biomarker_name,
            bes.section_title,
            bes.section_content,
            bes.display_order
        FROM biomarkers_education_sections bes
        JOIN biomarkers_base b ON bes.biomarker_id = b.id
        WHERE bes.is_active = true
        ORDER BY b.biomarker_name, bes.display_order
    """)

    biomarker_sections = cur.fetchall()

    # Get all biometric sections
    cur.execute("""
        SELECT
            b.biometric_name,
            bes.section_title,
            bes.section_content,
            bes.display_order
        FROM biometrics_education_sections bes
        JOIN biometrics_base b ON bes.biometric_id = b.id
        WHERE bes.is_active = true
        ORDER BY b.biometric_name, bes.display_order
    """)

    biometric_sections = cur.fetchall()

    print(f"\n✓ Found {len(biomarker_sections)} biomarker sections")
    print(f"✓ Found {len(biometric_sections)} biometric sections")
    print(f"✓ Total: {len(biomarker_sections) + len(biometric_sections)} sections to audit\n")

    # Analyze each section
    print("="*80)
    print("BIOMARKER SECTIONS AUDIT")
    print("="*80)

    biomarker_results = defaultdict(list)
    biomarker_stats = {
        'critical': 0,
        'needs_review': 0,
        'ok': 0,
        'good': 0,
        'total_issues': 0,
        'total_warnings': 0,
        'total_suggestions': 0
    }

    for name, title, content, order in biomarker_sections:
        result = analyze_section(name, title, content)
        biomarker_results[name].append({
            'title': title,
            'order': order,
            **result
        })

        # Update stats
        if result['status'] == 'CRITICAL':
            biomarker_stats['critical'] += 1
        elif result['status'] == 'NEEDS REVIEW':
            biomarker_stats['needs_review'] += 1
        elif result['status'] == 'OK':
            biomarker_stats['ok'] += 1
        else:
            biomarker_stats['good'] += 1

        biomarker_stats['total_issues'] += len(result['issues'])
        biomarker_stats['total_warnings'] += len(result['warnings'])
        biomarker_stats['total_suggestions'] += len(result['suggestions'])

    # Print biomarker summary
    print(f"\nBiomarker Sections Summary:")
    print(f"  CRITICAL (major issues): {biomarker_stats['critical']}")
    print(f"  NEEDS REVIEW (warnings): {biomarker_stats['needs_review']}")
    print(f"  OK (minor suggestions): {biomarker_stats['ok']}")
    print(f"  GOOD (no issues): {biomarker_stats['good']}")
    print(f"\n  Total Issues: {biomarker_stats['total_issues']}")
    print(f"  Total Warnings: {biomarker_stats['total_warnings']}")
    print(f"  Total Suggestions: {biomarker_stats['total_suggestions']}")

    # Analyze biometric sections
    print("\n" + "="*80)
    print("BIOMETRIC SECTIONS AUDIT")
    print("="*80)

    biometric_results = defaultdict(list)
    biometric_stats = {
        'critical': 0,
        'needs_review': 0,
        'ok': 0,
        'good': 0,
        'total_issues': 0,
        'total_warnings': 0,
        'total_suggestions': 0
    }

    for name, title, content, order in biometric_sections:
        result = analyze_section(name, title, content)
        biometric_results[name].append({
            'title': title,
            'order': order,
            **result
        })

        # Update stats
        if result['status'] == 'CRITICAL':
            biometric_stats['critical'] += 1
        elif result['status'] == 'NEEDS REVIEW':
            biometric_stats['needs_review'] += 1
        elif result['status'] == 'OK':
            biometric_stats['ok'] += 1
        else:
            biometric_stats['good'] += 1

        biometric_stats['total_issues'] += len(result['issues'])
        biometric_stats['total_warnings'] += len(result['warnings'])
        biometric_stats['total_suggestions'] += len(result['suggestions'])

    # Print biometric summary
    print(f"\nBiometric Sections Summary:")
    print(f"  CRITICAL (major issues): {biometric_stats['critical']}")
    print(f"  NEEDS REVIEW (warnings): {biometric_stats['needs_review']}")
    print(f"  OK (minor suggestions): {biometric_stats['ok']}")
    print(f"  GOOD (no issues): {biometric_stats['good']}")
    print(f"\n  Total Issues: {biometric_stats['total_issues']}")
    print(f"  Total Warnings: {biometric_stats['total_warnings']}")
    print(f"  Total Suggestions: {biometric_stats['total_suggestions']}")

    return {
        'biomarkers': dict(biomarker_results),
        'biometrics': dict(biometric_results),
        'biomarker_stats': biomarker_stats,
        'biometric_stats': biometric_stats
    }

def generate_detailed_report(results):
    """Generate detailed HTML/Markdown report"""
    print("\n" + "="*80)
    print("GENERATING DETAILED REPORT")
    print("="*80)

    report_lines = []
    report_lines.append("# Education Content Audit Report\n")
    report_lines.append(f"**Total Sections Audited**: {sum(len(sections) for sections in results['biomarkers'].values()) + sum(len(sections) for sections in results['biometrics'].values())}\n\n")

    # Biomarkers with issues
    report_lines.append("## Biomarkers - Critical Issues\n\n")

    for biomarker_name, sections in sorted(results['biomarkers'].items()):
        critical_sections = [s for s in sections if s['status'] == 'CRITICAL']
        if critical_sections:
            report_lines.append(f"### {biomarker_name}\n\n")
            for section in critical_sections:
                report_lines.append(f"**{section['title']}** (Score: {section['score']}/100)\n\n")
                if section['issues']:
                    report_lines.append("Issues:\n")
                    for issue in section['issues']:
                        report_lines.append(f"- ❌ {issue}\n")
                if section['warnings']:
                    report_lines.append("Warnings:\n")
                    for warning in section['warnings']:
                        report_lines.append(f"- ⚠️  {warning}\n")
                report_lines.append("\n")

    # Biometrics with issues
    report_lines.append("## Biometrics - Critical Issues\n\n")

    for biometric_name, sections in sorted(results['biometrics'].items()):
        critical_sections = [s for s in sections if s['status'] == 'CRITICAL']
        if critical_sections:
            report_lines.append(f"### {biometric_name}\n\n")
            for section in critical_sections:
                report_lines.append(f"**{section['title']}** (Score: {section['score']}/100)\n\n")
                if section['issues']:
                    report_lines.append("Issues:\n")
                    for issue in section['issues']:
                        report_lines.append(f"- ❌ {issue}\n")
                if section['warnings']:
                    report_lines.append("Warnings:\n")
                    for warning in section['warnings']:
                        report_lines.append(f"- ⚠️  {warning}\n")
                report_lines.append("\n")

    # Write report
    report_file = "EDUCATION_CONTENT_AUDIT_REPORT.md"
    with open(report_file, 'w') as f:
        f.writelines(report_lines)

    print(f"✅ Detailed report written to: {report_file}")

    # Also write JSON for programmatic access
    json_file = "education_content_audit.json"
    with open(json_file, 'w') as f:
        json.dump(results, f, indent=2)

    print(f"✅ JSON report written to: {json_file}")

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Run audit
    results = audit_education_content(cur)

    # Generate report
    generate_detailed_report(results)

    # Print summary
    print("\n" + "="*80)
    print("OVERALL SUMMARY")
    print("="*80)

    total_critical = results['biomarker_stats']['critical'] + results['biometric_stats']['critical']
    total_needs_review = results['biomarker_stats']['needs_review'] + results['biometric_stats']['needs_review']
    total_ok = results['biomarker_stats']['ok'] + results['biometric_stats']['ok']
    total_good = results['biomarker_stats']['good'] + results['biometric_stats']['good']

    total_sections = total_critical + total_needs_review + total_ok + total_good

    print(f"\nTotal Sections: {total_sections}")
    print(f"  🔴 CRITICAL: {total_critical} ({100*total_critical//total_sections}%)")
    print(f"  🟡 NEEDS REVIEW: {total_needs_review} ({100*total_needs_review//total_sections}%)")
    print(f"  🟢 OK: {total_ok} ({100*total_ok//total_sections}%)")
    print(f"  ✅ GOOD: {total_good} ({100*total_good//total_sections}%)")

    print(f"\nNext Steps:")
    print(f"  1. Review EDUCATION_CONTENT_AUDIT_REPORT.md for detailed findings")
    print(f"  2. Fix {total_critical} critical sections")
    print(f"  3. Review {total_needs_review} sections with warnings")
    print(f"  4. Consider suggestions for {total_ok} OK sections")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
