#!/usr/bin/env python3
"""
Generate Complete Aggregations for All Reference Values
Creates aggregations for every value in data_entry_fields_reference
"""

import psycopg2
from psycopg2.extras import RealDictCursor

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

# Category-to-field mappings
CATEGORY_FIELD_MAPPINGS = {
    'protein_types': 'DEF_PROTEIN_GRAMS',
    'protein_timing': 'DEF_PROTEIN_GRAMS',
    'food_timing': None,  # Universal, used by multiple fields
    'fat_types': 'DEF_FAT_GRAMS',
    'fiber_sources': 'DEF_FIBER_GRAMS',
    'added_sugar_types': 'DEF_ADDED_SUGAR_QUANTITY',
    'caffeine_types': 'DEF_CAFFEINE_QUANTITY',
    'cardio_types': 'DEF_CARDIO_DURATION',
    'strength_types': 'DEF_STRENGTH_DURATION',
    'hiit_types': 'DEF_HIIT_DURATION',
    'mobility_types': 'DEF_MOBILITY_DURATION',
    'food_types': 'DEF_FOOD_QUANTITY',
    'beverage_types': 'DEF_BEVERAGE_QUANTITY',
    'unhealthy_beverage_types': 'DEF_UNHEALTHY_BEV_QUANTITY',
    'ultra_processed_types': 'DEF_ULTRA_PROCESSED_QUANTITY',
    'processed_meat_types': 'DEF_PROCESSED_MEAT_QUANTITY',
    'water_units': 'DEF_WATER_QUANTITY',
    'muscle_groups': 'DEF_STRENGTH_MUSCLE_GROUPS',
    'screen_time_types': 'DEF_SCREEN_TIME_QUANTITY',
    'substance_types': 'DEF_SUBSTANCE_QUANTITY',
    'sunlight_types': 'DEF_SUNLIGHT_DURATION',
    'sunscreen_types': 'DEF_SUNSCREEN_TIME',
    'skincare_steps': 'DEF_SKINCARE_STEP',
    'social_event_types': 'DEF_SOCIAL_EVENT_TIME',
    'sleep_period_types': 'DEF_SLEEP_PERIOD_DURATION',
    'meal_types': None,  # May not need aggregations
    'meal_qualifiers': None,  # May not need aggregations
    'workout_intensity': None,  # Used as filter, not aggregated directly
}

# Unit mappings
CATEGORY_UNIT_MAPPINGS = {
    'protein_types': 'gram',
    'protein_timing': 'gram',
    'fat_types': 'gram',
    'fiber_sources': 'gram',
    'added_sugar_types': 'serving',
    'caffeine_types': 'milligram',
    'cardio_types': 'minute',
    'strength_types': 'minute',
    'hiit_types': 'minute',
    'mobility_types': 'minute',
    'food_types': 'serving',
    'beverage_types': 'serving',
    'unhealthy_beverage_types': 'serving',
    'ultra_processed_types': 'serving',
    'processed_meat_types': 'serving',
    'water_units': 'count',  # Varies
    'muscle_groups': 'count',
    'screen_time_types': 'minute',
    'substance_types': 'count',
    'sunlight_types': 'minute',
    'sunscreen_types': 'count',
    'skincare_steps': 'count',
    'social_event_types': 'count',
    'sleep_period_types': 'minute',
}

# Standard periods for most metrics
STANDARD_PERIODS = ['hourly', 'daily', 'weekly']
STORAGE_PERIODS = ['monthly', '6month', 'yearly']
ALL_PERIODS = STANDARD_PERIODS + STORAGE_PERIODS

# Standard calculation types for quantities
QUANTITY_CALC_TYPES = ['SUM', 'AVG']
COUNT_CALC_TYPES = ['COUNT', 'COUNT_DISTINCT']

def main():
    print("🚀 Generating Complete Aggregations")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor(cursor_factory=RealDictCursor)

    # Get all reference values
    cur.execute("""
        SELECT reference_category, reference_key, display_name
        FROM data_entry_fields_reference
        WHERE is_active = true
        ORDER BY reference_category, sort_order
    """)
    ref_values = cur.fetchall()

    # Group by category
    categories = {}
    for row in ref_values:
        cat = row['reference_category']
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(row)

    # Get existing aggregations
    cur.execute("SELECT agg_id FROM aggregation_metrics")
    existing_aggs = set(row['agg_id'] for row in cur.fetchall())

    sql_statements = []
    new_count = 0

    for category, values in sorted(categories.items()):
        field_id = CATEGORY_FIELD_MAPPINGS.get(category)
        unit = CATEGORY_UNIT_MAPPINGS.get(category, 'count')

        if field_id is None:
            print(f"⏭️  Skipping {category} (no field mapping)")
            continue

        print(f"\n📊 {category}: {len(values)} values")

        for ref_val in values:
            ref_key = ref_val['reference_key']
            display_name = ref_val['display_name']

            # Generate aggregation ID
            agg_id = f"AGG_{category.upper().replace('_TYPES', '').replace('_SOURCES', '')}_{ref_key.upper()}"

            if agg_id in existing_aggs:
                print(f"  ✓ {agg_id} (exists)")
                continue

            metric_name = f"{category.replace('_types', '').replace('_sources', '')}_{ref_key}"

            # Create aggregation metric
            sql_statements.append(f"""
-- {display_name}
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  '{agg_id}',
  '{metric_name}',
  '{display_name}',
  '{display_name} aggregation',
  '{unit}',
  true
) ON CONFLICT (agg_id) DO NOTHING;
""")

            # Add periods
            for period in ALL_PERIODS:
                sql_statements.append(f"""
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('{agg_id}', '{period}')
ON CONFLICT DO NOTHING;
""")

            # Add calculation types
            for calc_type in QUANTITY_CALC_TYPES:
                sql_statements.append(f"""
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('{agg_id}', '{calc_type}')
ON CONFLICT DO NOTHING;
""")

            # Add dependency with filter
            ref_field_map = {
                'protein_types': 'DEF_PROTEIN_TYPE',
                'protein_timing': 'DEF_PROTEIN_TIMING',
                'fat_types': 'DEF_FAT_TYPE',
                'fiber_sources': 'DEF_FIBER_TYPE',
                'added_sugar_types': 'DEF_ADDED_SUGAR_TYPE',
                'caffeine_types': 'DEF_CAFFEINE_TYPE',
                'cardio_types': 'DEF_CARDIO_TYPE',
                'strength_types': 'DEF_STRENGTH_TYPE',
                'hiit_types': 'DEF_HIIT_TYPE',
                'mobility_types': 'DEF_MOBILITY_TYPE',
            }

            ref_field = ref_field_map.get(category)
            if ref_field:
                filter_json = f'{{"reference_field": "{ref_field}", "reference_value": "{ref_key}"}}'
                sql_statements.append(f"""
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  '{agg_id}',
  '{field_id}',
  'data_field',
  '{filter_json}'::jsonb
) ON CONFLICT DO NOTHING;
""")
            else:
                sql_statements.append(f"""
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  '{agg_id}',
  '{field_id}',
  'data_field'
) ON CONFLICT DO NOTHING;
""")

            new_count += 1
            print(f"  + {agg_id}")

    # Write to file
    output_file = '/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251025_generate_complete_aggregations.sql'
    with open(output_file, 'w') as f:
        f.write("""-- =====================================================
-- Generate Complete Aggregations for All Reference Values
-- =====================================================
-- Auto-generated aggregations for all values in data_entry_fields_reference
-- =====================================================

BEGIN;

""")
        f.write('\n'.join(sql_statements))
        f.write(f"""

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_total_aggs INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total_aggs FROM aggregation_metrics;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Generated Complete Aggregations!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total aggregations: %', v_total_aggs;
  RAISE NOTICE '  New aggregations added: {new_count}';
  RAISE NOTICE '';
  RAISE NOTICE 'All reference values now have aggregations';
  RAISE NOTICE '';
END $$;

COMMIT;
""")

    print(f"\n✅ Generated {new_count} new aggregations")
    print(f"📝 SQL written to: {output_file}")

    conn.close()

if __name__ == "__main__":
    main()
