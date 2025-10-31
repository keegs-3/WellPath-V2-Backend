-- =====================================================
-- Update Protein Screen Configuration
-- =====================================================
-- Updates primary and detail screens to match mobile requirements
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add New Chart Types First
-- =====================================================

INSERT INTO chart_types (chart_type_id, chart_name, description, category, supports_stacking, supports_selection)
VALUES
  ('bar_grouped', 'Grouped Bar Chart', 'Multiple bars grouped together per x-axis value', 'time_series', false, true),
  ('line_with_range', 'Line Chart with Optimal Range', 'Line chart with shaded optimal range overlay', 'time_series', false, false)
ON CONFLICT (chart_type_id) DO UPDATE SET
  description = EXCLUDED.description,
  category = EXCLUDED.category;

-- =====================================================
-- 2. Update Primary Screen
-- =====================================================

UPDATE display_screens_primary
SET
  detail_button_text = 'View More Protein Data',
  has_goal = true,
  goal_config = jsonb_build_object(
    'target_min', 1.2,
    'target_max', 1.6,
    'target_unit', 'g/kg',
    'show_on_primary', false
  ),
  quick_tips = jsonb_build_array(
    'Spread protein intake evenly across meals for optimal muscle synthesis',
    'Aim for 20-40g per meal to maximize muscle protein synthesis',
    'Plant-based proteins can be as effective as animal proteins when varied',
    'Consume protein within 2 hours post-workout for best recovery'
  ),
  info_sections = jsonb_build_array(
    jsonb_build_object(
      'title', 'Why Protein Matters',
      'content', 'Protein is essential for building and repairing tissues, making enzymes and hormones, and supporting immune function. Adequate protein intake helps maintain muscle mass, especially important as we age.'
    ),
    jsonb_build_object(
      'title', 'Optimal Intake',
      'content', 'Most active adults benefit from 1.2-1.6 grams per kilogram of body weight (0.54-0.73 g/lb) daily. Athletes may need up to 2.0 g/kg. Spread intake throughout the day for best results.'
    ),
    jsonb_build_object(
      'title', 'Quality Sources',
      'content', 'Focus on lean proteins like fish, poultry, legumes, and dairy. Fatty fish provide omega-3s. Plant proteins (beans, lentils, tofu) offer fiber and phytonutrients. Vary your sources for complete amino acid profiles.'
    ),
    jsonb_build_object(
      'title', 'Timing Tips',
      'content', 'Distribute protein across meals rather than loading one meal. Morning protein helps with satiety. Post-workout protein (within 2 hours) supports recovery. Evening protein can help preserve muscle overnight.'
    )
  ),
  updated_at = NOW()
WHERE display_screen_id = 'SCREEN_PROTEIN';

-- =====================================================
-- 3. Update Detail Screen to Use Tabs
-- =====================================================

UPDATE display_screens_detail
SET
  layout_type = 'tabs',
  tab_config = jsonb_build_array(
    -- Tab 1: By Meal
    jsonb_build_object(
      'tab_id', 'by_meal',
      'tab_title', 'By Meal',
      'tab_icon', 'clock',
      'display_order', 1,
      'chart_config', jsonb_build_object(
        'chart_type', 'bar_grouped',
        'description', 'Protein distribution across breakfast, lunch, and dinner',
        'y_axis_label', 'Protein (g)',
        'show_legend', true,
        'color_scheme', 'pillar_gradient',
        'bars', jsonb_build_array(
          jsonb_build_object('key', 'breakfast', 'label', 'Breakfast', 'color', '#FFA726', 'order', 1),
          jsonb_build_object('key', 'lunch', 'label', 'Lunch', 'color', '#FF8A50', 'order', 2),
          jsonb_build_object('key', 'dinner', 'label', 'Dinner', 'color', '#FF6D3A', 'order', 3)
        )
      )
    ),
    -- Tab 2: By Type
    jsonb_build_object(
      'tab_id', 'by_type',
      'tab_title', 'By Type',
      'tab_icon', 'list.bullet',
      'display_order', 2,
      'chart_config', jsonb_build_object(
        'chart_type', 'bar_stacked',
        'description', 'Breakdown of protein sources',
        'y_axis_label', 'Protein (g)',
        'show_legend', true,
        'legend_position', 'bottom',
        'segments', jsonb_build_array(
          jsonb_build_object('key', 'fatty_fish', 'label', 'Fatty Fish', 'color', '#0288D1'),
          jsonb_build_object('key', 'lean_protein', 'label', 'Lean Protein', 'color', '#66BB6A'),
          jsonb_build_object('key', 'plant_based', 'label', 'Plant-Based', 'color', '#8BC34A'),
          jsonb_build_object('key', 'red_meat', 'label', 'Red Meat', 'color', '#E53935'),
          jsonb_build_object('key', 'processed_meat', 'label', 'Processed Meat', 'color', '#FF7043'),
          jsonb_build_object('key', 'supplement', 'label', 'Supplement', 'color', '#AB47BC')
        )
      )
    ),
    -- Tab 3: Ratio
    jsonb_build_object(
      'tab_id', 'ratio',
      'tab_title', 'Ratio',
      'tab_icon', 'chart.line.uptrend.xyaxis',
      'display_order', 3,
      'chart_config', jsonb_build_object(
        'chart_type', 'line_with_range',
        'description', 'Protein intake per body weight',
        'show_unit_toggle', true,
        'units', jsonb_build_array(
          jsonb_build_object(
            'unit', 'g/kg',
            'label', 'g/kg',
            'optimal_min', 1.2,
            'optimal_max', 1.6,
            'y_axis_label', 'Protein (g/kg body weight)'
          ),
          jsonb_build_object(
            'unit', 'g/lb',
            'label', 'g/lb',
            'optimal_min', 0.54,
            'optimal_max', 0.73,
            'y_axis_label', 'Protein (g/lb body weight)'
          )
        ),
        'range_style', jsonb_build_object(
          'line_color', '#FF8A50',
          'line_style', 'dashed',
          'line_width', 2,
          'fill_color', '#4FC3F7',
          'fill_opacity', 0.2
        )
      )
    )
  ),
  section_config = NULL,  -- Remove sections, use tabs instead
  updated_at = NOW()
WHERE display_screen_id = 'SCREEN_PROTEIN';

-- =====================================================
-- 4. Update Detail Screen Display Metrics
-- =====================================================

-- Clear existing detail metrics
DELETE FROM display_screens_detail_display_metrics
WHERE detail_screen_id = 'SCREEN_PROTEIN_DETAIL';

-- Add metrics for Tab 1 (By Meal)
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  metadata
) VALUES
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_MEAL_TIMING', 'by_meal', 1,
   '{"chart_type_override": "bar_grouped", "group_key": "meal"}'::jsonb);

-- Add metrics for Tab 2 (By Type)
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  metadata
) VALUES
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_TYPE', 'by_type', 1,
   '{"chart_type_override": "bar_stacked", "stack_key": "protein_type"}'::jsonb);

-- Add metrics for Tab 3 (Ratio)
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  metadata
) VALUES
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_PER_KG', 'ratio', 1,
   '{"chart_type_override": "line_with_range", "show_unit_toggle": true, "units": ["g/kg", "g/lb"]}'::jsonb);

-- =====================================================
-- 5. Update Display Metrics Chart Types
-- =====================================================

-- Update DISP_PROTEIN_MEAL_TIMING to support grouped bars
UPDATE display_metrics
SET chart_type_id = 'bar_grouped'
WHERE metric_id = 'DISP_PROTEIN_MEAL_TIMING';

-- Update DISP_PROTEIN_PER_KG to support line with range
UPDATE display_metrics
SET chart_type_id = 'line_with_range'
WHERE metric_id = 'DISP_PROTEIN_PER_KG';


-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Protein Screen Configuration Updated!';
  RAISE NOTICE '';
  RAISE NOTICE 'Primary Screen:';
  RAISE NOTICE '  • Button text: "View More Protein Data"';
  RAISE NOTICE '  • About Protein accordion added';
  RAISE NOTICE '  • 4 quick tips added';
  RAISE NOTICE '  • 4 info sections added';
  RAISE NOTICE '';
  RAISE NOTICE 'Detail Screen:';
  RAISE NOTICE '  • Changed from sections to tabs';
  RAISE NOTICE '  • Tab 1: By Meal (grouped bars - breakfast/lunch/dinner)';
  RAISE NOTICE '  • Tab 2: By Type (stacked bars with legend)';
  RAISE NOTICE '  • Tab 3: Ratio (line chart with optimal range)';
  RAISE NOTICE '';
  RAISE NOTICE 'Chart Types:';
  RAISE NOTICE '  • bar_grouped - for meal timing';
  RAISE NOTICE '  • bar_stacked - for protein types';
  RAISE NOTICE '  • line_with_range - for ratio with optimal zone';
  RAISE NOTICE '';
  RAISE NOTICE 'Optimal Ranges:';
  RAISE NOTICE '  • 1.2-1.6 g/kg body weight';
  RAISE NOTICE '  • 0.54-0.73 g/lb body weight';
  RAISE NOTICE '';
END $$;

COMMIT;
