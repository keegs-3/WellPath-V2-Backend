#!/usr/bin/env python3
"""
Generate survey_response_options_aggregations mappings for FUNCTION-BASED questions
These work exactly like standalone question mappings - just response options → agg metrics
"""

import psycopg2
import uuid

conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

mappings = []

# =====================================================
# MOVEMENT FUNCTIONS
# =====================================================

# Movement Cardio: Q3.04 (frequency) + Q3.08 (duration)
CARDIO_FREQ_MAPPINGS = [
    ('RO_3.04-1', 3.04, 'AGG_CARDIO_SESSION_COUNT', 0, 1, 'AVG', 'weekly', 3, 30, 'Rarely or never'),
    ('RO_3.04-2', 3.04, 'AGG_CARDIO_SESSION_COUNT', 1, 2, 'AVG', 'weekly', 3, 30, '1-2 times per week'),
    ('RO_3.04-3', 3.04, 'AGG_CARDIO_SESSION_COUNT', 3, 4, 'AVG', 'weekly', 3, 30, '3-4 times per week'),
    ('RO_3.04-4', 3.04, 'AGG_CARDIO_SESSION_COUNT', 5, 999, 'AVG', 'weekly', 3, 30, '5 or more times per week'),
]

CARDIO_DURATION_MAPPINGS = [
    ('RO_3.08-1', 3.08, 'AGG_CARDIO_DURATION', 0, 60, 'SUM', 'weekly', 3, 30, '0-60 minutes per week'),
    ('RO_3.08-2', 3.08, 'AGG_CARDIO_DURATION', 61, 120, 'SUM', 'weekly', 3, 30, '61-120 minutes per week'),
    ('RO_3.08-3', 3.08, 'AGG_CARDIO_DURATION', 121, 150, 'SUM', 'weekly', 3, 30, '121-150 minutes per week'),
    ('RO_3.08-4', 3.08, 'AGG_CARDIO_DURATION', 151, 9999, 'SUM', 'weekly', 3, 30, '151+ minutes per week'),
]

# Movement Strength: Q3.05 (frequency) + Q3.09 (duration)
STRENGTH_FREQ_MAPPINGS = [
    ('RO_3.05-1', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 0, 0, 'AVG', 'weekly', 3, 30, 'Rarely or never'),
    ('RO_3.05-2', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 1, 1, 'AVG', 'weekly', 3, 30, '1 time per week'),
    ('RO_3.05-3', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 2, 2, 'AVG', 'weekly', 3, 30, '2 times per week'),
    ('RO_3.05-4', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 3, 999, 'AVG', 'weekly', 3, 30, '3+ times per week'),
]

STRENGTH_DURATION_MAPPINGS = [
    ('RO_3.09-1', 3.09, 'AGG_STRENGTH_DURATION', 0, 30, 'SUM', 'weekly', 3, 30, '0-30 minutes per week'),
    ('RO_3.09-2', 3.09, 'AGG_STRENGTH_DURATION', 31, 60, 'SUM', 'weekly', 3, 30, '31-60 minutes per week'),
    ('RO_3.09-3', 3.09, 'AGG_STRENGTH_DURATION', 61, 90, 'SUM', 'weekly', 3, 30, '61-90 minutes per week'),
    ('RO_3.09-4', 3.09, 'AGG_STRENGTH_DURATION', 91, 9999, 'SUM', 'weekly', 3, 30, '91+ minutes per week'),
]

# Movement HIIT: Q3.07 (frequency) + Q3.11 (duration)
HIIT_FREQ_MAPPINGS = [
    ('RO_3.07-1', 3.07, 'AGG_HIIT_SESSION_COUNT', 0, 0, 'AVG', 'weekly', 2, 30, 'Rarely or never'),
    ('RO_3.07-2', 3.07, 'AGG_HIIT_SESSION_COUNT', 1, 1, 'AVG', 'weekly', 2, 30, '1 time per week'),
    ('RO_3.07-3', 3.07, 'AGG_HIIT_SESSION_COUNT', 2, 2, 'AVG', 'weekly', 2, 30, '2 times per week'),
    ('RO_3.07-4', 3.07, 'AGG_HIIT_SESSION_COUNT', 3, 999, 'AVG', 'weekly', 2, 30, '3+ times per week'),
]

HIIT_DURATION_MAPPINGS = [
    ('RO_3.11-1', 3.11, 'AGG_HIIT_DURATION', 0, 20, 'SUM', 'weekly', 2, 30, '0-20 minutes per week'),
    ('RO_3.11-2', 3.11, 'AGG_HIIT_DURATION', 21, 40, 'SUM', 'weekly', 2, 30, '21-40 minutes per week'),
    ('RO_3.11-3', 3.11, 'AGG_HIIT_DURATION', 41, 60, 'SUM', 'weekly', 2, 30, '41-60 minutes per week'),
    ('RO_3.11-4', 3.11, 'AGG_HIIT_DURATION', 61, 9999, 'SUM', 'weekly', 2, 30, '61+ minutes per week'),
]

# Movement Flexibility/Mobility: Q3.06 (frequency) + Q3.10 (duration)
MOBILITY_FREQ_MAPPINGS = [
    ('RO_3.06-1', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 0, 0, 'AVG', 'weekly', 2, 30, 'Rarely or never'),
    ('RO_3.06-2', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 1, 1, 'AVG', 'weekly', 2, 30, '1 time per week'),
    ('RO_3.06-3', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 2, 3, 'AVG', 'weekly', 2, 30, '2-3 times per week'),
    ('RO_3.06-4', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 4, 999, 'AVG', 'weekly', 2, 30, '4+ times per week'),
]

MOBILITY_DURATION_MAPPINGS = [
    ('RO_3.10-1', 3.10, 'AGG_MOBILITY_DURATION', 0, 20, 'SUM', 'weekly', 2, 30, '0-20 minutes per week'),
    ('RO_3.10-2', 3.10, 'AGG_MOBILITY_DURATION', 21, 40, 'SUM', 'weekly', 2, 30, '21-40 minutes per week'),
    ('RO_3.10-3', 3.10, 'AGG_MOBILITY_DURATION', 41, 60, 'SUM', 'weekly', 2, 30, '41-60 minutes per week'),
    ('RO_3.10-4', 3.10, 'AGG_MOBILITY_DURATION', 61, 9999, 'SUM', 'weekly', 2, 30, '61+ minutes per week'),
]

# =====================================================
# SUBSTANCE FUNCTIONS
# =====================================================

# Q8.05: Current alcohol use level
# Converting descriptive ranges to drinks per week
ALCOHOL_USE_MAPPINGS = [
    ('RO_8.05-1', 8.05, 'AGG_ALCOHOLIC_DRINKS', 35, 999, 'SUM', 'weekly', 3, 30, 'Heavy: 5+ drinks per day (35+/week)'),
    ('RO_8.05-2', 8.05, 'AGG_ALCOHOLIC_DRINKS', 14, 28, 'SUM', 'weekly', 3, 30, 'Moderate: 2-4 drinks per day (14-28/week)'),
    ('RO_8.05-3', 8.05, 'AGG_ALCOHOLIC_DRINKS', 5, 10, 'SUM', 'weekly', 3, 30, 'Light: 1 drink per day (5-10/week)'),
    ('RO_8.05-4', 8.05, 'AGG_ALCOHOLIC_DRINKS', 1, 4, 'SUM', 'weekly', 3, 30, 'Minimal: A few per month (1-4/week)'),
    ('RO_8.05-5', 8.05, 'AGG_ALCOHOLIC_DRINKS', 0, 1, 'SUM', 'weekly', 3, 30, 'Occasional: Rarely (0-1/week)'),
]

# =====================================================
# NUTRITION FUNCTIONS
# =====================================================

# Q2.11: Protein intake (grams per day)
# Note: These thresholds are estimates and may need adjustment
PROTEIN_MAPPINGS = [
    # Will need actual response option IDs from database
    # Placeholder structure - needs actual option_ids
]

# =====================================================
# Combine all mappings
# =====================================================

all_function_mappings = (
    CARDIO_FREQ_MAPPINGS + CARDIO_DURATION_MAPPINGS +
    STRENGTH_FREQ_MAPPINGS + STRENGTH_DURATION_MAPPINGS +
    HIIT_FREQ_MAPPINGS + HIIT_DURATION_MAPPINGS +
    MOBILITY_FREQ_MAPPINGS + MOBILITY_DURATION_MAPPINGS +
    ALCOHOL_USE_MAPPINGS
)

print(f"Generating {len(all_function_mappings)} function-based question mappings...")
print("=" * 80)

for (option_id, question_num, agg_metric, low, high, calc_type, period, min_pts, lookback, notes) in all_function_mappings:
    # Verify response option exists
    cur.execute("SELECT option_id, option_text FROM survey_response_options WHERE option_id = %s", (option_id,))
    result = cur.fetchone()

    if not result:
        print(f"⚠️  Response option {option_id} not found, skipping...")
        continue

    actual_option_id, option_text = result

    mapping = {
        'id': str(uuid.uuid4()),
        'response_option_id': option_id,
        'question_number': question_num,
        'agg_metric_id': agg_metric,
        'threshold_low': low,
        'threshold_high': high,
        'calculation_type_id': calc_type,
        'period_type': period,
        'min_data_points': min_pts,
        'lookback_days': lookback,
        'notes': notes
    }

    mappings.append(mapping)
    print(f"✓ Q{question_num}: {option_id} → {agg_metric} [{low}, {high}]")

print(f"\n{'='*80}")
print(f"Generated {len(mappings)} mappings for function-based questions")
print(f"{'='*80}\n")

# Generate SQL
output_file = 'supabase/migrations/20251022_add_function_question_mappings.sql'

with open(output_file, 'w') as f:
    f.write("""-- =====================================================
-- Function-Based Question Mappings
-- =====================================================
-- Add mappings for questions within survey functions
-- These work the same as standalone questions - just
-- mapping response options to aggregation metrics
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Add mappings for function-based questions
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
    for m in mappings:
        values.append(f"""(
    '{m['id']}',
    '{m['response_option_id']}',
    {m['question_number']},
    '{m['agg_metric_id']}',
    {m['threshold_low']},
    {m['threshold_high']},
    '{m['calculation_type_id']}',
    '{m['period_type']}',
    {m['min_data_points']},
    {m['lookback_days']},
    '{m['notes']}'
)""")

    f.write(",\n".join(values))
    f.write(";\n\n")

    f.write(f"""
DO $$
BEGIN
    RAISE NOTICE '✅ Function-based question mappings added';
    RAISE NOTICE '   {len(mappings)} mappings created';
    RAISE NOTICE '';
    RAISE NOTICE 'These questions can now be dynamically updated via edge function:';
    RAISE NOTICE '  - Movement frequency + duration (cardio, strength, HIIT, mobility)';
    RAISE NOTICE '  - Alcohol use level';
    RAISE NOTICE '';
    RAISE NOTICE 'Edge function will update effective_response_option_id based on tracked data';
    RAISE NOTICE 'Existing scoring functions will recalculate automatically';
END $$;

COMMIT;
""")

print(f"✅ SQL generated: {output_file}")
print(f"Total function-based mappings: {len(mappings)}")

cur.close()
conn.close()
