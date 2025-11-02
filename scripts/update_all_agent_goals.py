"""
Update ALL 87 recommendation concepts with agent goals.
"""

import sys
import os
import re

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


def extract_base_id(rec_id: str) -> str:
    """Extract base ID."""
    base = re.match(r'^([A-Z]+\d+)', rec_id)
    return base.group(1) if base else rec_id


def generate_agent_goal(title: str, overview: str) -> str:
    """Generate agent goal from title."""
    title_lower = title.lower()

    # Movement
    if 'step' in title_lower or 'walking' in title_lower:
        return "Walk daily to improve cardiovascular health and metabolic function"
    elif 'zone 2' in title_lower or 'cardio' in title_lower:
        return "Perform Zone 2 cardio regularly (moderate intensity, conversational pace)"
    elif 'strength' in title_lower or 'resistance' in title_lower:
        return "Perform strength training to maintain muscle mass and bone density"
    elif 'hiit' in title_lower or 'high intensity' in title_lower:
        return "Perform high-intensity interval training for metabolic and cardiovascular benefits"
    elif 'mobility' in title_lower or 'flexibility' in title_lower:
        return "Practice mobility and flexibility exercises regularly"
    elif 'yoga' in title_lower:
        return "Practice yoga for flexibility, strength, and stress management"

    # Nutrition
    elif 'fiber' in title_lower:
        return "Increase daily fiber intake through whole foods"
    elif 'protein' in title_lower and 'increase' in title_lower:
        return "Increase protein intake to support muscle maintenance and metabolic health"
    elif 'vegetable' in title_lower:
        return "Eat more vegetables daily for micronutrients and fiber"
    elif 'fruit' in title_lower:
        return "Include fruits in daily diet for antioxidants and fiber"
    elif 'healthy fat' in title_lower or 'saturated fat' in title_lower:
        return "Prioritize healthy fats (olive oil, avocado, nuts, fish) over saturated fats"
    elif 'whole grain' in title_lower:
        return "Choose whole grains over refined grains"
    elif 'legume' in title_lower:
        return "Include legumes (beans, lentils) in diet regularly"
    elif 'sugar' in title_lower and 'reduce' in title_lower:
        return "Reduce added sugar and refined carbohydrate intake"
    elif 'processed meat' in title_lower:
        return "Reduce or eliminate processed meat consumption"
    elif 'alcohol' in title_lower:
        return "Reduce or eliminate alcohol consumption"
    elif 'caffeine' in title_lower:
        return "Reduce caffeine intake to healthy levels"
    elif 'hydrat' in title_lower or 'water' in title_lower:
        return "Stay well-hydrated with adequate water intake"
    elif 'meal timing' in title_lower or 'time restrict' in title_lower or 'intermittent fast' in title_lower:
        return "Practice time-restricted eating for metabolic benefits"

    # Sleep
    elif 'sleep' in title_lower and any(x in title_lower for x in ['7', '8', '9', 'hour']):
        return "Sleep 7-9 hours consistently each night for recovery and health"
    elif 'sleep' in title_lower and 'timing' in title_lower:
        return "Maintain consistent sleep and wake times"
    elif 'sleep' in title_lower and 'quality' in title_lower:
        return "Improve sleep quality through sleep hygiene practices"

    # Stress/Mindfulness
    elif 'meditat' in title_lower or 'mindful' in title_lower:
        return "Practice mindfulness or meditation regularly for stress reduction"
    elif 'stress' in title_lower:
        return "Implement stress management practices"
    elif 'breath' in title_lower:
        return "Practice breathing exercises for stress and nervous system regulation"

    # Social/Connection
    elif 'social' in title_lower:
        return "Engage in regular social interaction and maintain relationships"

    # Recovery/Optimization
    elif 'sauna' in title_lower:
        return "Use sauna therapy for cardiovascular and recovery benefits"
    elif 'cold' in title_lower or 'plunge' in title_lower:
        return "Practice cold exposure therapy for metabolic and recovery benefits"
    elif 'massage' in title_lower:
        return "Receive regular massage for recovery and stress relief"

    # Lifestyle
    elif 'screen time' in title_lower or 'sedentary' in title_lower:
        return "Reduce sedentary time and screen exposure"
    elif 'outdoor' in title_lower or 'nature' in title_lower:
        return "Spend time outdoors in nature regularly"
    elif 'sunlight' in title_lower or 'vitamin d' in title_lower:
        return "Get adequate sunlight exposure for vitamin D"

    # Supplements
    elif 'omega' in title_lower or 'fish oil' in title_lower:
        return "Supplement with omega-3 fatty acids"
    elif 'vitamin' in title_lower or 'supplement' in title_lower:
        return f"Take {title.split()[0].lower()} supplement as directed"

    # Default
    else:
        return f"Follow {title.lower()} recommendation"


def main():
    """Update all recommendations with agent goals."""
    print("="*70)
    print("Updating ALL Recommendations with Agent Goals")
    print("="*70)

    db = get_db_connection()

    # Get all unique base IDs and titles
    query = """
    SELECT DISTINCT ON (SUBSTRING(rec_id FROM '^[A-Z]+[0-9]+'))
        rec_id, title, overview
    FROM recommendations_base
    WHERE is_active = true
    ORDER BY SUBSTRING(rec_id FROM '^[A-Z]+[0-9]+'), rec_id
    """

    with db.cursor() as cursor:
        cursor.execute(query)
        rows = cursor.fetchall()

    print(f"\n✓ Found {len(rows)} unique recommendation concepts\n")

    # Update each base ID group
    updated_count = 0
    for row in rows:
        base_id = extract_base_id(row[0])
        title = row[1]
        overview = row[2] or ""

        agent_goal = generate_agent_goal(title, overview)

        # Update all variants with this base ID
        update_query = """
        UPDATE recommendations_base
        SET agent_goal = %s,
            agent_enabled = true
        WHERE rec_id LIKE %s
        """

        with db.cursor() as cursor:
            cursor.execute(update_query, (agent_goal, f"{base_id}%"))
            count = cursor.rowcount
            updated_count += count

        print(f"✓ {base_id}: {title[:60]}")
        print(f"  Goal: {agent_goal}")
        print(f"  Updated {count} variants\n")

    db.commit()

    print("="*70)
    print(f"✓ Updated {updated_count} recommendations with agent goals")
    print("="*70)

    # Verify
    with db.cursor() as cursor:
        cursor.execute("""
            SELECT COUNT(*) as total,
                   COUNT(CASE WHEN agent_goal IS NOT NULL THEN 1 END) as with_goal,
                   COUNT(CASE WHEN agent_enabled = true THEN 1 END) as enabled
            FROM recommendations_base
            WHERE is_active = true
        """)
        stats = cursor.fetchone()

        print(f"\nDatabase Stats:")
        print(f"  Total active recommendations: {stats[0]}")
        print(f"  With agent_goal: {stats[1]}")
        print(f"  Agent-enabled: {stats[2]}")

    db.close()


if __name__ == "__main__":
    main()
