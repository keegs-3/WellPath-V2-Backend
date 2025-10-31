-- =====================================================
-- Create Meal Quality Nutrition Component
-- =====================================================
-- Complete database structure for meal quality tracking
-- Counts MEALS by quality category (not servings/grams)
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create Data Entry Field
-- =====================================================

-- Meal quality field (reference to quality categories)
-- Note: This is a reference field only - we count meals, not measure quantities
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  reference_table,
  reference_category,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES (
  'DEF_MEAL_QUALITY',
  'meal_quality',
  'Meal Quality',
  'Quality category of meal (Whole Foods, Minimally Processed, Ultra-Processed)',
  'reference',
  'uuid',
  'data_entry_fields_reference',
  'meal_quality_types',
  NULL,
  false,
  'Healthful Nutrition',
  true
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  reference_table = EXCLUDED.reference_table,
  reference_category = EXCLUDED.reference_category,
  updated_at = NOW();

-- =====================================================
-- STEP 2: Create Reference Data for Meal Quality Types
-- =====================================================

INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active,
  metadata
) VALUES
  (
    'meal_quality_types',
    'whole_foods',
    'Whole Foods',
    'Meals primarily composed of whole, unprocessed ingredients',
    1,
    true,
    '{"examples": ["Fresh vegetables, fruits, whole grains, lean proteins"], "health_score": 10}'::jsonb
  ),
  (
    'meal_quality_types',
    'minimally_processed',
    'Minimally Processed',
    'Meals with some processed ingredients but mostly whole foods',
    2,
    true,
    '{"examples": ["Canned beans, frozen vegetables, whole grain bread"], "health_score": 7}'::jsonb
  ),
  (
    'meal_quality_types',
    'ultra_processed',
    'Ultra-Processed',
    'Meals primarily composed of highly processed foods',
    3,
    true,
    '{"examples": ["Fast food, packaged meals, refined snacks"], "health_score": 3}'::jsonb
  )
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();

-- =====================================================
-- STEP 3: Create Aggregation Metrics
-- =====================================================

-- Main total meal count aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_MEAL_QUALITY_COUNT',
  'meal_quality_count',
  'Total Meals',
  'Total number of meals tracked by quality',
  'meal',
  true
) ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active;

-- Quality type breakdown aggregations (3 types)
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_MEAL_QUALITY_WHOLE_FOODS',
    'meal_quality_whole_foods',
    'Whole Foods Meals',
    'Number of meals composed of whole foods',
    'meal',
    true
  ),
  (
    'AGG_MEAL_QUALITY_MINIMALLY_PROCESSED',
    'meal_quality_minimally_processed',
    'Minimally Processed Meals',
    'Number of meals with minimally processed ingredients',
    'meal',
    true
  ),
  (
    'AGG_MEAL_QUALITY_ULTRA_PROCESSED',
    'meal_quality_ultra_processed',
    'Ultra-Processed Meals',
    'Number of meals composed of ultra-processed foods',
    'meal',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active;

-- =====================================================
-- STEP 4: Create Aggregation Dependencies
-- =====================================================

-- Main total depends on DEF_MEAL_QUALITY (counting occurrences)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_MEAL_QUALITY_COUNT',
  'DEF_MEAL_QUALITY',
  'data_field'
) ON CONFLICT DO NOTHING;

-- Quality type breakdowns depend on DEF_MEAL_QUALITY with filter on type
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_MEAL_QUALITY_WHOLE_FOODS',
    'DEF_MEAL_QUALITY',
    'data_field',
    '{"reference_field": "DEF_MEAL_QUALITY", "reference_value": "whole_foods"}'::jsonb
  ),
  (
    'AGG_MEAL_QUALITY_MINIMALLY_PROCESSED',
    'DEF_MEAL_QUALITY',
    'data_field',
    '{"reference_field": "DEF_MEAL_QUALITY", "reference_value": "minimally_processed"}'::jsonb
  ),
  (
    'AGG_MEAL_QUALITY_ULTRA_PROCESSED',
    'DEF_MEAL_QUALITY',
    'data_field',
    '{"reference_field": "DEF_MEAL_QUALITY", "reference_value": "ultra_processed"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 5: Create Aggregation Calculation Types
-- =====================================================

-- Add COUNT calculation type for all aggregations
-- Note: Using COUNT instead of SUM because we're counting meals, not summing quantities
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT agg_id, 'COUNT'
FROM (VALUES
  ('AGG_MEAL_QUALITY_COUNT'),
  ('AGG_MEAL_QUALITY_WHOLE_FOODS'),
  ('AGG_MEAL_QUALITY_MINIMALLY_PROCESSED'),
  ('AGG_MEAL_QUALITY_ULTRA_PROCESSED')
) AS aggs(agg_id)
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 6: Create Aggregation Periods
-- =====================================================

-- Add all standard periods (hourly, daily, weekly, monthly, 6month, yearly)
INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id
)
SELECT agg_id, period
FROM (VALUES
  ('AGG_MEAL_QUALITY_COUNT'),
  ('AGG_MEAL_QUALITY_WHOLE_FOODS'),
  ('AGG_MEAL_QUALITY_MINIMALLY_PROCESSED'),
  ('AGG_MEAL_QUALITY_ULTRA_PROCESSED')
) AS aggs(agg_id)
CROSS JOIN (VALUES
  ('hourly'),
  ('daily'),
  ('weekly'),
  ('monthly'),
  ('6month'),
  ('yearly')
) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 7: Create Display Metric for Stacked Bar Chart
-- =====================================================

-- Main display metric showing quality breakdown
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_MEAL_QUALITY',
  'Meal Quality',
  'Distribution of meals by quality category (Whole Foods, Minimally Processed, Ultra-Processed)',
  'Healthful Nutrition',
  'bar_stacked',
  true,
  false
) ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- =====================================================
-- STEP 8: Map Quality Type Aggregations to Display Metric
-- =====================================================

-- Map all 3 quality type aggregations to the display metric
-- Using COUNT for daily and weekly periods
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily COUNT for all 3 types
  ('DISP_MEAL_QUALITY', 'AGG_MEAL_QUALITY_WHOLE_FOODS', 'daily', 'COUNT', 1),
  ('DISP_MEAL_QUALITY', 'AGG_MEAL_QUALITY_MINIMALLY_PROCESSED', 'daily', 'COUNT', 2),
  ('DISP_MEAL_QUALITY', 'AGG_MEAL_QUALITY_ULTRA_PROCESSED', 'daily', 'COUNT', 3),

  -- Weekly COUNT for all 3 types
  ('DISP_MEAL_QUALITY', 'AGG_MEAL_QUALITY_WHOLE_FOODS', 'weekly', 'COUNT', 4),
  ('DISP_MEAL_QUALITY', 'AGG_MEAL_QUALITY_MINIMALLY_PROCESSED', 'weekly', 'COUNT', 5),
  ('DISP_MEAL_QUALITY', 'AGG_MEAL_QUALITY_ULTRA_PROCESSED', 'weekly', 'COUNT', 6)
ON CONFLICT DO NOTHING;

-- =====================================================
-- Summary and Verification
-- =====================================================

DO $$
DECLARE
  v_fields_count INTEGER;
  v_ref_count INTEGER;
  v_agg_metrics_count INTEGER;
  v_deps_count INTEGER;
  v_calc_types_count INTEGER;
  v_periods_count INTEGER;
  v_display_agg_count INTEGER;
BEGIN
  -- Count created records
  SELECT COUNT(*) INTO v_fields_count
  FROM data_entry_fields
  WHERE field_id = 'DEF_MEAL_QUALITY';

  SELECT COUNT(*) INTO v_ref_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'meal_quality_types';

  SELECT COUNT(*) INTO v_agg_metrics_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_MEAL_QUALITY%';

  SELECT COUNT(*) INTO v_deps_count
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_MEAL_QUALITY%';

  SELECT COUNT(*) INTO v_calc_types_count
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_MEAL_QUALITY%';

  SELECT COUNT(*) INTO v_periods_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_MEAL_QUALITY%';

  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id = 'DISP_MEAL_QUALITY';

  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ Meal Quality Component Created Successfully!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Data entry fields: %', v_fields_count;
  RAISE NOTICE '  Reference types: %', v_ref_count;
  RAISE NOTICE '  Aggregation metrics: %', v_agg_metrics_count;
  RAISE NOTICE '  Dependencies: %', v_deps_count;
  RAISE NOTICE '  Calculation types: %', v_calc_types_count;
  RAISE NOTICE '  Periods: %', v_periods_count;
  RAISE NOTICE '  Display metric aggregations: %', v_display_agg_count;
  RAISE NOTICE '';
  RAISE NOTICE '📊 Data Entry Field:';
  RAISE NOTICE '  • DEF_MEAL_QUALITY - Meal quality category reference';
  RAISE NOTICE '';
  RAISE NOTICE '🍽️  Meal Quality Categories (3):';
  RAISE NOTICE '  1. Whole Foods - Unprocessed, natural ingredients';
  RAISE NOTICE '  2. Minimally Processed - Some processing, mostly whole foods';
  RAISE NOTICE '  3. Ultra-Processed - Highly processed foods';
  RAISE NOTICE '';
  RAISE NOTICE '📈 Aggregation Metrics (4 total):';
  RAISE NOTICE '  Main Total:';
  RAISE NOTICE '    • AGG_MEAL_QUALITY_COUNT - Total meal count';
  RAISE NOTICE '';
  RAISE NOTICE '  Quality Type Breakdowns (3):';
  RAISE NOTICE '    • AGG_MEAL_QUALITY_WHOLE_FOODS';
  RAISE NOTICE '    • AGG_MEAL_QUALITY_MINIMALLY_PROCESSED';
  RAISE NOTICE '    • AGG_MEAL_QUALITY_ULTRA_PROCESSED';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Display Metric:';
  RAISE NOTICE '  • DISP_MEAL_QUALITY - Stacked bar chart';
  RAISE NOTICE '    - Shows distribution across 3 quality categories';
  RAISE NOTICE '    - Daily and weekly COUNT views';
  RAISE NOTICE '';
  RAISE NOTICE '⚙️  Configuration:';
  RAISE NOTICE '  • Calculation type: COUNT (counting meals, not quantities)';
  RAISE NOTICE '  • Periods: hourly, daily, weekly, monthly, 6month, yearly';
  RAISE NOTICE '  • Unit: meal';
  RAISE NOTICE '  • Pillar: Healthful Nutrition';
  RAISE NOTICE '  • Chart: bar_stacked';
  RAISE NOTICE '';
  RAISE NOTICE '🔗 Dependencies:';
  RAISE NOTICE '  • All metrics depend on DEF_MEAL_QUALITY';
  RAISE NOTICE '  • Quality types filtered by reference value';
  RAISE NOTICE '  • No "Uncategorized" - user must select quality';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Key Differences from Other Components:';
  RAISE NOTICE '  • Uses COUNT not SUM (counting meals, not servings/grams)';
  RAISE NOTICE '  • No timing breakdown (not meal-time specific)';
  RAISE NOTICE '  • Required selection (no uncategorized option)';
  RAISE NOTICE '  • 3 categories (Whole Foods, Minimally Processed, Ultra-Processed)';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Ready for:';
  RAISE NOTICE '  1. Test data generation';
  RAISE NOTICE '  2. Aggregation processing';
  RAISE NOTICE '  3. Display screen configuration';
  RAISE NOTICE '  4. Mobile app integration';
  RAISE NOTICE '';
  RAISE NOTICE '============================================================';
  RAISE NOTICE '';
END $$;

COMMIT;
