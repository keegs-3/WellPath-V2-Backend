#!/usr/bin/env python3
"""
Generate survey_response_options → aggregation_metrics mappings
for dynamic WellPath score updating
"""

import psycopg2
import re
import uuid

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Define survey question → aggregation metric mappings
# Format: (question_number, agg_metric_id, calculation_type, period_type, min_data_points, lookback_days)
QUESTION_METRIC_MAPPINGS = [
    # Nutrition
    (2.11, 'AGG_PROTEIN_GRAMS', 'AVG', 'monthly', 20, 30),
    (2.19, 'AGG_FRUIT_SERVINGS', 'AVG', 'monthly', 20, 30),
    (2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 'AVG', 'monthly', 20, 30),
    (2.23, 'AGG_LEGUME_SERVINGS', 'AVG', 'monthly', 20, 30),
    (2.25, 'AGG_SEED_SERVINGS', 'AVG', 'monthly', 15, 30),
    (2.29, 'AGG_WATER_CONSUMPTION', 'AVG', 'monthly', 20, 30),

    # Exercise
    (3.01, 'AGG_CARDIO_SESSION_COUNT', 'SUM', 'weekly', 3, 30),
    (3.05, 'AGG_STRENGTH_SESSION_COUNT', 'SUM', 'weekly', 3, 30),
    (3.09, 'AGG_HIIT_SESSION_COUNT', 'SUM', 'weekly', 2, 30),
    (3.13, 'AGG_MOBILITY_SESSION_COUNT', 'SUM', 'weekly', 2, 30),
    (3.17, 'AGG_STEPS', 'AVG', 'daily', 20, 30),

    # Sleep
    (4.01, 'AGG_SLEEP_DURATION', 'AVG', 'monthly', 20, 30),
    (4.05, 'AGG_SLEEP_QUALITY_RATING', 'AVG', 'monthly', 15, 30),

    # Mindfulness
    (5.01, 'AGG_MEDITATION_DURATION', 'SUM', 'weekly', 3, 30),
    (5.05, 'AGG_BREATHWORK_DURATION', 'SUM', 'weekly', 2, 30),

    # Stress
    (5.09, 'AGG_STRESS_LEVEL_RATING', 'AVG', 'monthly', 15, 30),

    # Screen time
    (5.13, 'AGG_SCREEN_TIME', 'AVG', 'daily', 15, 30),

    # Social/Connection
    (5.17, 'AGG_SOCIAL_INTERACTION_SESSIONS', 'SUM', 'weekly', 3, 30),
    (5.21, 'AGG_OUTDOOR_TIME', 'AVG', 'daily', 15, 30),

    # Substances
    (6.01, 'AGG_ALCOHOL_SERVINGS', 'SUM', 'weekly', 3, 30),
    (6.05, 'AGG_CAFFEINE_SERVINGS', 'AVG', 'daily', 15, 30),
]

def parse_range_from_text(option_text):
    """
    Extract numeric ranges from response option text.
    Examples:
      "0" → (0, 0.9)
      "1-2" → (1.0, 2.9)
      "3-4" → (3.0, 4.9)
      "5 or more" → (5.0, 999)
      "≤1" → (0, 1.0)
      "4 or more" → (4.0, 999)
      "Never" → (0, 0)
      "Daily" → (7, 7) for weekly context
    """
    text = option_text.strip()

    # Handle "X or more"
    match = re.search(r'(\d+)\s+or\s+more', text, re.IGNORECASE)
    if match:
        low = float(match.group(1))
        return (low, 999.0)

    # Handle "X-Y" range
    match = re.search(r'(\d+)\s*-\s*(\d+)', text)
    if match:
        low = float(match.group(1))
        high = float(match.group(2))
        return (low, high + 0.9)  # 1-2 means 1.0 to 2.9

    # Handle "≤X" or "<=X"
    match = re.search(r'[≤<=]\s*(\d+)', text)
    if match:
        high = float(match.group(1))
        return (0.0, high)

    # Handle "≥X" or ">=X"
    match = re.search(r'[≥>=]\s*(\d+)', text)
    if match:
        low = float(match.group(1))
        return (low, 999.0)

    # Handle single number
    match = re.search(r'^(\d+)$', text)
    if match:
        val = float(match.group(1))
        return (val, val + 0.9)  # "0" means 0 to 0.9

    # Handle frequency words for weekly metrics
    if 'never' in text.lower():
        return (0, 0)
    if 'daily' in text.lower() or '7 days' in text.lower():
        return (7, 7)
    if '5-6' in text:
        return (5, 6)
    if '3-4' in text:
        return (3, 4)
    if '1-2' in text:
        return (1, 2)

    # Default: couldn't parse
    return None

# Collect mappings
mappings = []

for question_num, agg_metric_id, calc_type, period_type, min_data, lookback in QUESTION_METRIC_MAPPINGS:
    # Check if aggregation metric exists
    cur.execute("SELECT agg_id FROM aggregation_metrics WHERE agg_id = %s", (agg_metric_id,))
    if not cur.fetchone():
        print(f"⚠️  AGG metric {agg_metric_id} not found for Q{question_num}, skipping...")
        continue

    # Get response options for this question
    cur.execute("""
        SELECT option_id, option_text, score, question_response_order
        FROM survey_response_options
        WHERE question_number = %s
        ORDER BY question_response_order
    """, (question_num,))

    options = cur.fetchall()

    if not options:
        print(f"⚠️  No response options for Q{question_num}, skipping...")
        continue

    print(f"\n📊 Q{question_num} → {agg_metric_id}")
    print(f"   {len(options)} response options")

    for option_id, option_text, score, order in options:
        # Try to parse range from option text
        range_result = parse_range_from_text(option_text)

        if range_result is None:
            print(f"   ⚠️  Could not parse range from: '{option_text}' (skipping)")
            continue

        threshold_low, threshold_high = range_result

        mapping = {
            'id': str(uuid.uuid4()),
            'response_option_id': option_id,
            'question_number': question_num,
            'agg_metric_id': agg_metric_id,
            'threshold_low': threshold_low,
            'threshold_high': threshold_high,
            'calculation_type_id': calc_type,
            'period_type': period_type,
            'min_data_points': min_data,
            'lookback_days': lookback,
            'notes': f"Auto-mapped from response option: {option_text.replace(chr(39), '')} range {threshold_low} to {threshold_high}"  # Remove single quotes
        }

        mappings.append(mapping)
        print(f"   ✓ {option_id}: '{option_text}' → [{threshold_low}, {threshold_high}] (score: {score})")

print(f"\n{'='*80}")
print(f"Generated {len(mappings)} mappings")
print(f"{'='*80}\n")

# Generate SQL
sql_parts = []

sql_parts.append("""-- =====================================================
-- Survey Response Options → Aggregation Metrics Mappings
-- =====================================================
-- Auto-generated mappings for dynamic score updating
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

INSERT INTO survey_response_options_aggregations (
    id,
    response_option_id,
    question_number,
    agg_metric_id,
    threshold_low,
    threshold_high,
    calculation_type_id,
    period_type,
    min_data_points,
    lookback_days,
    notes
) VALUES
""")

values = []
for mapping in mappings:
    values.append(f"""(
    '{mapping['id']}',
    '{mapping['response_option_id']}',
    {mapping['question_number']},
    '{mapping['agg_metric_id']}',
    {mapping['threshold_low']},
    {mapping['threshold_high']},
    '{mapping['calculation_type_id']}',
    '{mapping['period_type']}',
    {mapping['min_data_points']},
    {mapping['lookback_days']},
    '{mapping['notes']}'
)""")

sql_parts.append(",\n".join(values))
sql_parts.append(";\n\n")

sql_parts.append("""
-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
    mapping_count INT;
    question_count INT;
    metric_count INT;
BEGIN
    SELECT COUNT(*) INTO mapping_count
    FROM survey_response_options_aggregations;

    SELECT COUNT(DISTINCT question_number) INTO question_count
    FROM survey_response_options_aggregations;

    SELECT COUNT(DISTINCT agg_metric_id) INTO metric_count
    FROM survey_response_options_aggregations;

    RAISE NOTICE '✅ Survey Response Mappings Created';
    RAISE NOTICE '';
    RAISE NOTICE 'Total mappings: %', mapping_count;
    RAISE NOTICE 'Questions mapped: %', question_count;
    RAISE NOTICE 'Aggregation metrics: %', metric_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Dynamic scoring is now enabled!';
END $$;

COMMIT;
""")

# Write migration file
output_file = 'supabase/migrations/20251022_populate_survey_aggregation_mappings.sql'
with open(output_file, 'w') as f:
    f.write(''.join(sql_parts))

print(f"✅ SQL generated: {output_file}")
print(f"Total mappings: {len(mappings)}")

# Show summary by question
from collections import defaultdict
by_question = defaultdict(int)
for m in mappings:
    by_question[m['question_number']] += 1

print(f"\n{'='*80}")
print("Mappings by Question:")
print(f"{'='*80}")
for q_num in sorted(by_question.keys()):
    count = by_question[q_num]
    print(f"  Q{q_num}: {count} response options mapped")

cur.close()
conn.close()
