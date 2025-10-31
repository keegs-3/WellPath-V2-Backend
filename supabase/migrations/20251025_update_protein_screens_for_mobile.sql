-- =====================================================
-- Update Protein Screens for Mobile
-- =====================================================
-- Updates button text, adds About Protein content, and configures tabs
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Update Primary Screen
-- =====================================================

UPDATE display_screens_primary
SET
  detail_button_text = 'View More Protein Data',
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
-- 2. Update Detail Screen to Use Tabs
-- =====================================================

UPDATE display_screens_detail
SET
  layout_type = 'tabs',
  tab_config = jsonb_build_array(
    -- Tab 1: By Meal (3 grouped bars: breakfast, lunch, dinner)
    jsonb_build_object(
      'tab_id', 'by_meal',
      'tab_title', 'By Meal',
      'tab_icon', 'clock',
      'display_order', 1
    ),
    -- Tab 2: By Type (stacked bars with legend)
    jsonb_build_object(
      'tab_id', 'by_type',
      'tab_title', 'By Type',
      'tab_icon', 'list.bullet',
      'display_order', 2
    ),
    -- Tab 3: Ratio (line chart with optimal range 1.2-1.6 g/kg, toggle g/lb)
    jsonb_build_object(
      'tab_id', 'ratio',
      'tab_title', 'Ratio',
      'tab_icon', 'chart.line.uptrend.xyaxis',
      'display_order', 3,
      'optimal_range_gkg', jsonb_build_object('min', 1.2, 'max', 1.6),
      'optimal_range_glb', jsonb_build_object('min', 0.54, 'max', 0.73)
    )
  ),
  section_config = NULL,
  updated_at = NOW()
WHERE display_screen_id = 'SCREEN_PROTEIN';

-- =====================================================
-- 3. Update Detail Screen Display Metrics for Tabs
-- =====================================================

-- Clear existing detail metrics
DELETE FROM display_screens_detail_display_metrics
WHERE detail_screen_id = 'SCREEN_PROTEIN_DETAIL';

-- Tab 1: By Meal - DISP_PROTEIN_MEAL_TIMING
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order
) VALUES
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_MEAL_TIMING', 'by_meal', 1);

-- Tab 2: By Type - DISP_PROTEIN_TYPE
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order
) VALUES
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_TYPE', 'by_type', 1);

-- Tab 3: Ratio - DISP_PROTEIN_PER_KG
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order
) VALUES
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_PER_KG', 'ratio', 1);

-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Protein Screen Configuration Updated!';
  RAISE NOTICE '';
  RAISE NOTICE 'Primary Screen:';
  RAISE NOTICE '  • Button: "View More Protein Data"';
  RAISE NOTICE '  • About Protein: 4 quick tips + 4 info sections';
  RAISE NOTICE '';
  RAISE NOTICE 'Detail Screen - 3 Tabs:';
  RAISE NOTICE '  • Tab 1 (By Meal): Breakfast/Lunch/Dinner grouped bars';
  RAISE NOTICE '  • Tab 2 (By Type): 6 protein types stacked bars';
  RAISE NOTICE '  • Tab 3 (Ratio): Line chart with optimal ranges';
  RAISE NOTICE '    - 1.2-1.6 g/kg (dotted lines, semi-transparent blue fill)';
  RAISE NOTICE '    - 0.54-0.73 g/lb (toggle)';
  RAISE NOTICE '';
  RAISE NOTICE 'Mobile can handle chart rendering in Swift';
  RAISE NOTICE '';
END $$;

COMMIT;
