-- =====================================================
-- Create Hydration Nutrition Component
-- =====================================================
-- This is the SIMPLEST nutrition component - no types, no timing
-- Just track total fluid ounces consumed
--
-- Created: 2025-10-25
-- Component: Hydration
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Data Entry Field
-- =====================================================

-- First create in data_entry_fields
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  pillar_name,
  is_active
) VALUES (
  'DEF_HYDRATION_OUNCES',
  'hydration_ounces',
  'Hydration',
  'Water and fluid intake in fluid ounces',
  'quantity',
  'numeric',
  'fluid_ounce',
  'Healthful Nutrition',
  true
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Then register in field_registry
INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_source,
  data_entry_field_id,
  unit,
  is_active
) VALUES (
  'DEF_HYDRATION_OUNCES',
  'hydration_ounces',
  'Hydration',
  'Water and fluid intake in fluid ounces',
  'user_input',
  'DEF_HYDRATION_OUNCES',
  'fluid_ounce',
  true
) ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  unit = EXCLUDED.unit,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- =====================================================
-- 2. Create Aggregation Metric
-- =====================================================

INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_HYDRATION_TOTAL',
  'hydration_total',
  'Total Hydration',
  'Total fluid intake in fluid ounces',
  'fluid_ounce',
  true
) ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  output_unit = EXCLUDED.output_unit,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- =====================================================
-- 3. Create Aggregation Dependency
-- =====================================================

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_HYDRATION_TOTAL',
  'DEF_HYDRATION_OUNCES',
  'data_field'
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. Create Aggregation Calculation Types
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
) VALUES
  ('AGG_HYDRATION_TOTAL', 'SUM'),
  ('AGG_HYDRATION_TOTAL', 'AVG')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. Create Aggregation Periods
-- =====================================================

INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id
) VALUES
  ('AGG_HYDRATION_TOTAL', 'hourly'),
  ('AGG_HYDRATION_TOTAL', 'daily'),
  ('AGG_HYDRATION_TOTAL', 'weekly'),
  ('AGG_HYDRATION_TOTAL', 'monthly'),
  ('AGG_HYDRATION_TOTAL', '6month'),
  ('AGG_HYDRATION_TOTAL', 'yearly')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 6. Create Display Metric
-- =====================================================

INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_HYDRATION',
  'Hydration',
  'Track your daily water and fluid intake',
  'Healthful Nutrition',
  'bar_vertical',
  true,
  true
) ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  pillar = EXCLUDED.pillar,
  chart_type_id = EXCLUDED.chart_type_id,
  is_active = EXCLUDED.is_active,
  is_primary = EXCLUDED.is_primary,
  updated_at = NOW();

-- =====================================================
-- 7. Map Display Metric to Aggregations
-- =====================================================

INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Hourly SUM
  ('DISP_HYDRATION', 'AGG_HYDRATION_TOTAL', 'hourly', 'SUM', 1),
  -- Daily SUM
  ('DISP_HYDRATION', 'AGG_HYDRATION_TOTAL', 'daily', 'SUM', 2),
  -- Weekly AVG
  ('DISP_HYDRATION', 'AGG_HYDRATION_TOTAL', 'weekly', 'AVG', 3),
  -- Monthly AVG
  ('DISP_HYDRATION', 'AGG_HYDRATION_TOTAL', 'monthly', 'AVG', 4)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 8. Create Display Screen
-- =====================================================

INSERT INTO display_screens (
  screen_id,
  name,
  overview,
  pillar,
  icon,
  default_time_period,
  layout_type,
  display_order,
  screen_type,
  is_active
) VALUES (
  'SCREEN_HYDRATION',
  'Hydration',
  'Track your daily water and fluid intake to stay optimally hydrated',
  'Healthful Nutrition',
  'water',
  'D',
  'simple',
  10,
  'simple',
  true
) ON CONFLICT (screen_id) DO UPDATE SET
  name = EXCLUDED.name,
  overview = EXCLUDED.overview,
  pillar = EXCLUDED.pillar,
  default_time_period = EXCLUDED.default_time_period,
  layout_type = EXCLUDED.layout_type,
  screen_type = EXCLUDED.screen_type,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- =====================================================
-- 9. Link Display Metric to Screen (Primary)
-- =====================================================

INSERT INTO display_screens_primary_display_metrics (
  primary_screen_id,
  metric_id,
  display_order,
  context_label,
  context_description
) VALUES (
  'SCREEN_HYDRATION',
  'DISP_HYDRATION',
  1,
  'Daily Hydration',
  'Track your water and fluid intake in fluid ounces'
) ON CONFLICT (primary_screen_id, metric_id) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  context_label = EXCLUDED.context_label,
  context_description = EXCLUDED.context_description,
  updated_at = NOW();

-- =====================================================
-- 10. Add Educational Content
-- =====================================================

UPDATE display_metrics
SET
  education_content = jsonb_build_object(
    'overview', 'Proper hydration is essential for nearly every bodily function, from regulating temperature to delivering nutrients to cells.',
    'why_it_matters', 'Staying hydrated improves energy levels, supports cognitive function, aids digestion, and helps maintain healthy skin.',
    'optimal_range', 'Most adults need 64-100 fluid ounces (8-12 cups) daily. Needs increase with exercise, heat, and certain health conditions.',
    'quick_tips', E'Quick hydration tips:\n• Start your day with 16oz of water\n• Drink water before, during, and after exercise\n• Keep a reusable water bottle with you\n• Eat water-rich foods like fruits and vegetables\n• Monitor urine color (pale yellow is ideal)\n• Set reminders if you forget to drink',
    'conversion_note', '1 cup = 8 fluid ounces. Standard water bottle = 16-20 oz.'
  ),
  detail_education_content = jsonb_build_object(
    'interpretation', 'Your hydration chart shows total fluid intake over time. Look for consistency and aim to meet your daily target.',
    'data_quality', 'Track all fluids: water, herbal tea, milk, juice, etc. Coffee and alcohol have mild diuretic effects.',
    'actionable_insights', 'If you consistently fall short, try: front-loading hydration in the morning, setting hourly reminders, or flavoring water with lemon/cucumber.'
  )
WHERE metric_id = 'DISP_HYDRATION';

-- =====================================================
-- VERIFICATION & SUMMARY
-- =====================================================

DO $$
DECLARE
  v_field_count INTEGER;
  v_agg_count INTEGER;
  v_dep_count INTEGER;
  v_calc_type_count INTEGER;
  v_period_count INTEGER;
  v_display_agg_count INTEGER;
BEGIN
  -- Count everything
  SELECT COUNT(*) INTO v_field_count
  FROM field_registry
  WHERE field_id = 'DEF_HYDRATION_OUNCES';

  SELECT COUNT(*) INTO v_agg_count
  FROM aggregation_metrics
  WHERE agg_id = 'AGG_HYDRATION_TOTAL';

  SELECT COUNT(*) INTO v_dep_count
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id = 'AGG_HYDRATION_TOTAL';

  SELECT COUNT(*) INTO v_calc_type_count
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id = 'AGG_HYDRATION_TOTAL';

  SELECT COUNT(*) INTO v_period_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id = 'AGG_HYDRATION_TOTAL';

  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id = 'DISP_HYDRATION';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ Hydration Component Created!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: %', v_field_count;
  RAISE NOTICE '  Aggregation Metrics: %', v_agg_count;
  RAISE NOTICE '  Dependencies: %', v_dep_count;
  RAISE NOTICE '  Calculation Types: % (SUM, AVG)', v_calc_type_count;
  RAISE NOTICE '  Periods: % (hourly, daily, weekly, monthly, 6month, yearly)', v_period_count;
  RAISE NOTICE '  Display Aggregations: % period/calc combinations', v_display_agg_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Structure:';
  RAISE NOTICE '  📝 DEF_HYDRATION_OUNCES';
  RAISE NOTICE '      ↓';
  RAISE NOTICE '  📊 AGG_HYDRATION_TOTAL';
  RAISE NOTICE '      ↓';
  RAISE NOTICE '  📱 DISP_HYDRATION → SCREEN_HYDRATION';
  RAISE NOTICE '';
  RAISE NOTICE 'Features:';
  RAISE NOTICE '  • Simple bar chart (no types, no timing)';
  RAISE NOTICE '  • Unit: fluid ounces';
  RAISE NOTICE '  • Educational content included';
  RAISE NOTICE '  • Supports hourly, daily, weekly, monthly tracking';
  RAISE NOTICE '';
  RAISE NOTICE 'This is the SIMPLEST nutrition component!';
  RAISE NOTICE 'Ready for data entry and aggregation processing.';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END $$;

COMMIT;
