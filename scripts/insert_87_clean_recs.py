"""
Insert 87 clean consolidated recommendations from grouped data.
"""

import sys
import os
import json
import re

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


# Load grouped recs
with open('/tmp/grouped_recommendations.json', 'r') as f:
    groups = json.load(f)

print(f"✓ Loaded {len(groups)} recommendation groups")

# Helper functions from previous script
def title_to_id(title):
    """Convert title to readable ID."""
    clean = re.sub(r'[^\w\s-]', '', title.lower())
    clean = re.sub(r'[-\s]+', '_', clean)
    return clean[:50]

def generate_agent_goal(title):
    """Generate agent goal from title."""
    title_lower = title.lower()

    if 'fiber' in title_lower:
        return "Increase daily fiber intake through whole foods"
    elif 'healthy fat' in title_lower or 'saturated fat' in title_lower:
        return "Prioritize healthy fats over saturated fats"
    elif 'zone 2' in title_lower:
        return "Perform Zone 2 cardio regularly at moderate intensity"
    elif 'sleep' in title_lower and any(x in title for x in ['7', '8', '9']):
        return "Sleep 7-9 hours consistently each night"
    elif 'alcohol' in title_lower:
        return "Reduce or eliminate alcohol consumption"
    elif 'protein' in title_lower:
        return "Increase protein intake to support muscle health"
    elif 'vegetable' in title_lower:
        return "Eat more vegetables daily"
    elif 'fruit' in title_lower:
        return "Include fruits in daily diet"
    elif 'sugar' in title_lower and 'reduce' in title_lower:
        return "Reduce added sugar intake"
    elif 'strength' in title_lower:
        return "Perform strength training regularly"
    elif 'step' in title_lower or 'walk' in title_lower:
        return "Walk daily for cardiovascular health"
    else:
        return f"Follow {title.lower()} recommendation"

# Prepare inserts
db = get_db_connection()

inserted = 0
for base_id, recs in groups.items():
    if not recs:
        continue

    # Get representative rec (first one)
    rep = recs[0]
    title = rep['title']
    overview = rep.get('overview', '')[:500]

    # Generate clean ID
    clean_id = title_to_id(title)
    agent_goal = generate_agent_goal(title)

    # Aggregate biomarkers/biometrics
    def merge_fields(field):
        all_items = set()
        for r in recs:
            if r.get(field):
                items = [i.strip() for i in str(r[field]).split(',')]
                all_items.update([i for i in items if i])
        return ','.join(sorted(all_items))

    primary_bio = merge_fields('primary_biomarkers')
    secondary_bio = merge_fields('secondary_biomarkers')
    tertiary_bio = merge_fields('tertiary_biomarkers')
    primary_met = merge_fields('primary_biometrics')
    secondary_met = merge_fields('secondary_biometrics')
    raw_impact = rep.get('raw_impact') or 50

    # Insert
    try:
        with db.cursor() as cursor:
            cursor.execute("""
                INSERT INTO recommendations_base (
                    rec_id, title, overview, agent_goal, recommendation_type,
                    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
                    primary_biometrics, secondary_biometrics,
                    raw_impact, agent_enabled, is_active
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                clean_id,
                title,
                overview,
                agent_goal,
                rep.get('type', 'Lifestyle'),
                primary_bio,
                secondary_bio,
                tertiary_bio,
                primary_met,
                secondary_met,
                raw_impact,
                True,
                True
            ))
            inserted += 1
            if inserted <= 10:
                print(f"✓ {clean_id}: {title} (impact: {raw_impact})")
    except Exception as e:
        print(f"❌ Error inserting {clean_id}: {str(e)}")

db.commit()
print(f"\n✅ Inserted {inserted} clean recommendations!")

# Verify
with db.cursor() as cursor:
    cursor.execute("SELECT COUNT(*) FROM recommendations_base WHERE is_active = true")
    count = cursor.fetchone()[0]
    print(f"✓ Database now has {count} active recommendations")

db.close()
