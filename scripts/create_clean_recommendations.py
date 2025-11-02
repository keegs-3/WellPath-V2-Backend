"""
Create Clean Recommendations

Takes the 87 grouped concepts and creates clean, consolidated recommendations
with readable IDs and proper agent_goal fields.
"""

import sys
import os
import re
import json
from collections import defaultdict

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


def extract_base_id(rec_id: str) -> str:
    """Extract base ID."""
    base = re.match(r'^([A-Z]+\d+)', rec_id)
    return base.group(1) if base else rec_id


def title_to_id(title: str) -> str:
    """Convert title to readable ID."""
    # Remove special characters, convert to snake_case
    clean = re.sub(r'[^\w\s-]', '', title.lower())
    clean = re.sub(r'[-\s]+', '_', clean)
    return clean[:50]  # Max 50 chars


def consolidate_group(base_id: str, variants: list) -> dict:
    """Consolidate a group of variants into one clean recommendation."""

    # Get best content (prefer level 1 or first variant)
    first = variants[0]
    title = first['title']
    overview = first['overview'] or ""

    # Aggregate biomarkers/biometrics (union across all variants)
    def merge_list_fields(field_name):
        all_items = set()
        for v in variants:
            if v.get(field_name):
                items = [item.strip() for item in v[field_name].split(',')]
                all_items.update([i for i in items if i])
        return sorted(list(all_items))

    # Create readable ID from title
    readable_id = title_to_id(title)

    # Generate agent goal based on title
    agent_goal = generate_agent_goal(title, overview)

    consolidated = {
        "id": readable_id,
        "name": title,
        "description": overview[:500] if len(overview) > 500 else overview,
        "agent_goal": agent_goal,
        "pillar": infer_pillar(title, first['type']),
        "recommendation_type": first['type'],
        "primary_biomarkers": merge_list_fields('primary_biomarkers'),
        "secondary_biomarkers": merge_list_fields('secondary_biomarkers'),
        "tertiary_biomarkers": merge_list_fields('tertiary_biomarkers'),
        "primary_biometrics": merge_list_fields('primary_biometrics'),
        "secondary_biometrics": merge_list_fields('secondary_biometrics'),
        "tertiary_biometrics": merge_list_fields('tertiary_biometrics'),
        "raw_impact": first['raw_impact'] or 50,
        "evidence_ids": merge_list_fields('evidence'),
        "contraindications": first['contraindications'] or '',
        "source_rec_ids": [v['rec_id'] for v in variants],
        "variant_count": len(variants),
        "agent_context": {
            "has_difficulty_levels": len(variants) > 1,
            "source_base_id": base_id
        }
    }

    return consolidated


def generate_agent_goal(title: str, overview: str) -> str:
    """Generate concise agent goal from title."""
    title_lower = title.lower()

    # Pattern matching for common recommendations
    if 'fiber' in title_lower:
        return "Increase daily fiber intake through whole foods"
    elif 'healthy fat' in title_lower or 'saturated fat' in title_lower:
        return "Prioritize healthy fats (olive oil, avocado, nuts, fish) over saturated fats"
    elif 'zone 2' in title_lower:
        return "Perform Zone 2 cardio (moderate intensity, conversational pace) regularly"
    elif 'sleep' in title_lower and ('7' in title or '9' in title):
        return "Sleep 7-9 hours consistently each night"
    elif 'alcohol' in title_lower and 'reduce' in title_lower:
        return "Reduce or eliminate alcohol consumption"
    elif 'protein' in title_lower and 'increase' in title_lower:
        return "Increase protein intake to support muscle maintenance"
    elif 'vegetable' in title_lower:
        return "Eat more vegetables daily for micronutrients and fiber"
    elif 'fruit' in title_lower:
        return "Include fruits in daily diet for antioxidants and fiber"
    elif 'sugar' in title_lower and 'reduce' in title_lower:
        return "Reduce added sugar and refined carbohydrate intake"
    elif 'processed meat' in title_lower:
        return "Reduce or eliminate processed meat consumption"
    elif 'whole grain' in title_lower:
        return "Choose whole grains over refined grains"
    elif 'legume' in title_lower:
        return "Include legumes (beans, lentils) in diet regularly"
    elif 'strength' in title_lower or 'resistance' in title_lower:
        return "Perform strength training to maintain muscle mass and bone density"
    elif 'step' in title_lower or 'walk' in title_lower:
        return "Walk daily to improve cardiovascular health"
    elif 'meditat' in title_lower or 'mindful' in title_lower:
        return "Practice mindfulness or meditation regularly"
    elif 'stress' in title_lower:
        return "Implement stress management practices"
    elif 'social' in title_lower:
        return "Engage in regular social interaction"
    elif 'sauna' in title_lower:
        return "Use sauna therapy for cardiovascular and longevity benefits"
    elif 'cold' in title_lower or 'plunge' in title_lower:
        return "Practice cold exposure therapy"
    elif 'fast' in title_lower or 'time restrict' in title_lower:
        return "Practice time-restricted eating or intermittent fasting"
    else:
        # Generic - extract from title
        return f"Follow {title.lower()} recommendation"


def infer_pillar(title: str, rec_type: str) -> str:
    """Infer pillar from title and type."""
    title_lower = title.lower()

    if 'sleep' in title_lower:
        return 'sleep'
    elif any(word in title_lower for word in ['cardio', 'strength', 'walk', 'step', 'exercise', 'mobility', 'zone 2']):
        return 'movement'
    elif any(word in title_lower for word in ['fiber', 'protein', 'vegetable', 'fruit', 'fat', 'sugar', 'meat', 'grain', 'legume', 'alcohol', 'caffeine']):
        return 'nutrition'
    elif any(word in title_lower for word in ['stress', 'meditation', 'mindful', 'breath']):
        return 'stress'
    elif 'social' in title_lower:
        return 'connection'
    elif any(word in title_lower for word in ['sauna', 'cold', 'supplement', 'vitamin']):
        return 'optimization'
    else:
        return 'lifestyle'


def main():
    """Main consolidation process."""
    print("="*70)
    print("WellPath Recommendation Consolidation - Create Clean Recs")
    print("="*70)

    db = get_db_connection()

    # Load all recommendations
    query = """
    SELECT
        rec_id, title, overview,
        primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
        primary_biometrics, secondary_biometrics, tertiary_biometrics,
        raw_impact, recommendation_type, level, evidence, contraindications
    FROM recommendations_base
    WHERE is_active = true
    ORDER BY rec_id
    """

    with db.cursor() as cursor:
        cursor.execute(query)
        rows = cursor.fetchall()

    # Group by base ID
    groups = defaultdict(list)
    for row in rows:
        base_id = extract_base_id(row[0])
        groups[base_id].append({
            'rec_id': row[0], 'title': row[1], 'overview': row[2],
            'primary_biomarkers': row[3], 'secondary_biomarkers': row[4], 'tertiary_biomarkers': row[5],
            'primary_biometrics': row[6], 'secondary_biometrics': row[7], 'tertiary_biometrics': row[8],
            'raw_impact': row[9], 'type': row[10], 'level': row[11],
            'evidence': row[12], 'contraindications': row[13]
        })

    print(f"\n✓ Grouped {len(rows)} recommendations into {len(groups)} concepts")

    # Consolidate each group
    consolidated = []
    for base_id in sorted(groups.keys()):
        clean_rec = consolidate_group(base_id, groups[base_id])
        consolidated.append(clean_rec)

    # Save to JSON for review
    output_json = '/Users/keegs/Documents/WellPath/wellpath-v2-backend/database/consolidated_recommendations.json'
    with open(output_json, 'w') as f:
        json.dump(consolidated, f, indent=2)

    print(f"✓ Saved {len(consolidated)} consolidated recommendations to JSON")

    # Generate SQL
    sql_lines = [
        "-- Consolidated Recommendations",
        "-- Clean, agent-ready recommendations with readable IDs\n"
    ]

    pillar_inserts = []

    for rec in consolidated:
        # Escape single quotes
        name = rec['name'].replace("'", "''")
        desc = rec['description'].replace("'", "''")
        goal = rec['agent_goal'].replace("'", "''")
        contra = rec['contraindications'].replace("'", "''") if rec['contraindications'] else ''

        sql = f"""
INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    '{rec['id']}',
    '{name}',
    '{desc}',
    '{goal}',
    '{rec['recommendation_type']}',
    '{','.join(rec['primary_biomarkers'])}',
    '{','.join(rec['secondary_biomarkers'])}',
    '{','.join(rec['tertiary_biomarkers'])}',
    '{','.join(rec['primary_biometrics'])}',
    '{','.join(rec['secondary_biometrics'])}',
    '{','.join(rec['tertiary_biometrics'])}',
    {rec['raw_impact']},
    '{','.join(rec['evidence_ids'][:10])}',
    '{contra}',
    '{json.dumps(rec['agent_context'])}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    title = EXCLUDED.title,
    overview = EXCLUDED.overview,
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;
"""
        sql_lines.append(sql)

        # Add pillar junction table insert
        pillar_inserts.append(f"""
-- Link {rec['id']} to {rec['pillar']} pillar
INSERT INTO pillars_recommendations (recommendation_id, pillar_name)
SELECT id, '{rec['pillar']}'
FROM recommendations_base
WHERE rec_id = '{rec['id']}'
ON CONFLICT DO NOTHING;
""")

    # Add pillar junction inserts
    sql_lines.append("\n-- Pillar Junction Table Links\n")
    sql_lines.extend(pillar_inserts)

    output_sql = '/Users/keegs/Documents/WellPath/wellpath-v2-backend/database/migrations/20251031_consolidated_recommendations.sql'
    with open(output_sql, 'w') as f:
        f.write('\n'.join(sql_lines))

    print(f"✓ Generated SQL migration: {output_sql}")

    # Print summary
    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print(f"Original recommendations: {len(rows)}")
    print(f"Consolidated concepts: {len(consolidated)}")
    print(f"Average variants per concept: {len(rows) / len(consolidated):.1f}")

    print("\nTop 10 High-Impact Recommendations:")
    sorted_by_impact = sorted(consolidated, key=lambda x: x['raw_impact'], reverse=True)
    for i, rec in enumerate(sorted_by_impact[:10], 1):
        print(f"{i}. {rec['name']} (impact: {rec['raw_impact']}/100)")
        print(f"   ID: {rec['id']}")
        print(f"   Goal: {rec['agent_goal']}")
        print()

    db.close()


if __name__ == "__main__":
    main()
