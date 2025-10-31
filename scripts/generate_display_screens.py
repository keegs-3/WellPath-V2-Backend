#!/usr/bin/env python3
"""
Generate display_screens and link metrics to screens
"""

import psycopg2

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Get all display_metrics organized by pillar
cur.execute("""
    SELECT display_metric_id, display_name, pillar
    FROM display_metrics
    WHERE is_active = true
    ORDER BY pillar, display_name
""")
all_metrics = cur.fetchall()

print(f"Found {len(all_metrics)} display_metrics\n")

# Define screens and organize metrics
screens = {
    # Restorative Sleep
    'SCREEN_SLEEP': {
        'name': 'Sleep Overview',
        'overview': 'Track your sleep duration, quality, stages, and consistency',
        'pillar': 'Restorative Sleep',
        'icon': '🛌',
        'keywords': ['sleep', 'rem', 'deep', 'core', 'awake', 'bedtime', 'wake']
    },

    # Movement + Exercise
    'SCREEN_CARDIO': {
        'name': 'Cardio Activity',
        'overview': 'Monitor your cardiovascular exercise sessions, duration, and intensity',
        'pillar': 'Movement + Exercise',
        'icon': '🏃',
        'keywords': ['cardio', 'zone 2', 'active time']
    },
    'SCREEN_STRENGTH': {
        'name': 'Strength Training',
        'overview': 'Track your strength training sessions and duration',
        'pillar': 'Movement + Exercise',
        'icon': '💪',
        'keywords': ['strength']
    },
    'SCREEN_HIIT': {
        'name': 'HIIT & Mobility',
        'overview': 'Track HIIT workouts and mobility sessions',
        'pillar': 'Movement + Exercise',
        'icon': '⚡',
        'keywords': ['hiit', 'mobility', 'flexibility']
    },
    'SCREEN_ACTIVITY': {
        'name': 'Daily Activity',
        'overview': 'Monitor steps, walking, and overall activity',
        'pillar': 'Movement + Exercise',
        'icon': '🚶',
        'keywords': ['steps', 'walking', 'sedentary', 'post meal activity']
    },

    # Healthful Nutrition
    'SCREEN_PROTEIN': {
        'name': 'Protein Intake',
        'overview': 'Track protein grams, servings, and variety',
        'pillar': 'Healthful Nutrition',
        'icon': '🥩',
        'keywords': ['protein']
    },
    'SCREEN_VEGETABLES': {
        'name': 'Vegetables',
        'overview': 'Monitor vegetable servings and variety',
        'pillar': 'Healthful Nutrition',
        'icon': '🥗',
        'keywords': ['vegetable']
    },
    'SCREEN_FRUITS': {
        'name': 'Fruits',
        'overview': 'Track fruit servings and variety',
        'pillar': 'Healthful Nutrition',
        'icon': '🍎',
        'keywords': ['fruit']
    },
    'SCREEN_FIBER': {
        'name': 'Fiber & Whole Grains',
        'overview': 'Monitor fiber intake and whole grain variety',
        'pillar': 'Healthful Nutrition',
        'icon': '🌾',
        'keywords': ['fiber', 'whole grain', 'legume']
    },
    'SCREEN_HYDRATION': {
        'name': 'Hydration',
        'overview': 'Track water consumption',
        'pillar': 'Healthful Nutrition',
        'icon': '💧',
        'keywords': ['water consumption']
    },
    'SCREEN_MEAL_TIMING': {
        'name': 'Meal Timing',
        'overview': 'Track meal times, eating window, and fasting',
        'pillar': 'Healthful Nutrition',
        'icon': '⏰',
        'keywords': ['meal time', 'eating window', 'first meal', 'last meal', 'fasting']
    },
    'SCREEN_NUTRITION_QUALITY': {
        'name': 'Nutrition Quality',
        'overview': 'Monitor processed foods, added sugar, and healthy fats',
        'pillar': 'Healthful Nutrition',
        'icon': '🍽️',
        'keywords': ['added sugar', 'processed', 'ultraprocessed', 'fat', 'whole food', 'plant based']
    },

    # Stress Management
    'SCREEN_MINDFULNESS': {
        'name': 'Mindfulness & Meditation',
        'overview': 'Track meditation, mindfulness, and breathwork',
        'pillar': 'Stress Management',
        'icon': '🧘',
        'keywords': ['meditation', 'mindfulness', 'breathwork']
    },

    # Cognitive Health
    'SCREEN_COGNITIVE': {
        'name': 'Cognitive Health',
        'overview': 'Track brain training, focus, memory, and mood',
        'pillar': 'Cognitive Health',
        'icon': '🧠',
        'keywords': ['brain', 'focus', 'memory', 'mood', 'journaling']
    },
    'SCREEN_LIGHT_EXPOSURE': {
        'name': 'Light & Circadian',
        'overview': 'Monitor sunlight exposure and light timing',
        'pillar': 'Cognitive Health',
        'icon': '☀️',
        'keywords': ['sunlight', 'light exposure']
    },

    # Connection + Purpose
    'SCREEN_WELLNESS': {
        'name': 'Wellness & Connection',
        'overview': 'Track outdoor time, social interaction, stress levels',
        'pillar': 'Connection + Purpose',
        'icon': '🌿',
        'keywords': ['outdoor', 'social', 'stress level', 'gratitude', 'screen time']
    },

    # Core Care
    'SCREEN_BIOMETRICS': {
        'name': 'Biometrics',
        'overview': 'Track weight, body composition, blood pressure',
        'pillar': 'Core Care',
        'icon': '⚖️',
        'keywords': ['weight', 'bmi', 'body fat', 'blood pressure', 'hip', 'waist']
    },
    'SCREEN_COMPLIANCE': {
        'name': 'Health Compliance',
        'overview': 'Track screenings, medications, and preventive care',
        'pillar': 'Core Care',
        'icon': '🏥',
        'keywords': ['compliance', 'screening', 'mammogram', 'colonoscopy', 'dental', 'physical', 'medication', 'supplement']
    },
    'SCREEN_SKINCARE': {
        'name': 'Skincare & Sun Protection',
        'overview': 'Track skincare routine and sunscreen application',
        'pillar': 'Core Care',
        'icon': '🧴',
        'keywords': ['sunscreen', 'skincare', 'brushing', 'flossing']
    },
    'SCREEN_SUBSTANCES': {
        'name': 'Substance Tracking',
        'overview': 'Monitor alcohol, cigarettes, and caffeine',
        'pillar': 'Core Care',
        'icon': '🚭',
        'keywords': ['alcohol', 'cigarette', 'caffeine']
    }
}

# Assign metrics to screens
screen_metrics = {screen_id: [] for screen_id in screens.keys()}

for metric_id, display_name, pillar in all_metrics:
    name_lower = display_name.lower()
    assigned = False

    # Try to match to screens
    for screen_id, screen_info in screens.items():
        keywords = screen_info['keywords']
        if any(keyword in name_lower for keyword in keywords):
            screen_metrics[screen_id].append(metric_id)
            assigned = True
            break

    if not assigned:
        # Fallback: add to pillar-based screen
        print(f"Unassigned: {metric_id} - {display_name} ({pillar})")

print("\n=== Screen Organization ===")
for screen_id, metrics in screen_metrics.items():
    if metrics:
        print(f"\n{screen_id}: {len(metrics)} metrics")
        for metric_id in metrics[:5]:
            print(f"  - {metric_id}")
        if len(metrics) > 5:
            print(f"  ... and {len(metrics) - 5} more")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Create Display Screens
-- =====================================================
-- Organize display_metrics into categorical screens
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Delete existing screens
DELETE FROM display_screens_display_metrics;
DELETE FROM display_screens;

-- =====================================================
-- PART 1: Create Display Screens
-- =====================================================

INSERT INTO display_screens
(screen_id, name, overview, pillar, icon, default_time_period, layout_type, screen_type, display_order, is_active)
VALUES
""")

for i, (screen_id, info) in enumerate(screens.items()):
    name = info['name']
    overview = info['overview']
    pillar = info['pillar']
    icon = info['icon']

    comma = "," if i < len(screens) - 1 else ";"
    sql_parts.append(
        f"('{screen_id}', '{name}', '{overview}', '{pillar}', '{icon}', "
        f"'weekly', 'detailed', 'summary', {i+1}, true){comma}\n"
    )

sql_parts.append("""

-- =====================================================
-- PART 2: Link Metrics to Screens
-- =====================================================

INSERT INTO display_screens_display_metrics
(display_screen, display_metric, visualization_type, section, position, is_primary, display_order)
VALUES
""")

values = []
for screen_id, metrics in screen_metrics.items():
    for idx, metric_id in enumerate(metrics):
        values.append(
            f"('{screen_id}', '{metric_id}', 'chart', 'main', 'full_width', "
            f"{idx == 0}, {idx + 1})"
        )

sql_parts.append(",\n".join(values))
sql_parts.append(";\n\n")

sql_parts.append("""
-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  screen_count INT;
  link_count INT;
BEGIN
  SELECT COUNT(*) INTO screen_count FROM display_screens;
  SELECT COUNT(*) INTO link_count FROM display_screens_display_metrics;

  RAISE NOTICE '✅ Display Screens Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total screens: %', screen_count;
  RAISE NOTICE 'Total metric-screen links: %', link_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Screens organized by pillar and category';
END $$;

COMMIT;
""")

# Write to file
output_file = 'supabase/migrations/20251022_create_display_screens.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"\n✅ SQL generated: {output_file}")
print(f"Total screens: {len(screens)}")
total_links = sum(len(metrics) for metrics in screen_metrics.values())
print(f"Total metric-screen links: {total_links}")

cur.close()
conn.close()
