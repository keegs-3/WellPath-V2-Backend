-- =====================================================================================
-- Create Sections for All Nutrition Metrics
-- =====================================================================================
-- Creates modal sections (tabs) for all nutrition parent metrics
-- Pattern: Timing, Types, Variety sections for each
-- =====================================================================================

-- =====================================================================================
-- FRUITS SECTIONS
-- =====================================================================================

-- Timing Section
INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES (
  'SECTION_FRUIT_TIMING', 'DISP_FRUIT_SERVINGS', 'Timing',
  'Fruit intake by meal', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- Types Section (Berries, Citrus, Tropical, etc.)
INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES (
  'SECTION_FRUIT_TYPES', 'DISP_FRUIT_SERVINGS', 'Types',
  'Fruit types consumed', 'leaf.fill', 2, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- Variety Section
INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES (
  'SECTION_FRUIT_VARIETY', 'DISP_FRUIT_SERVINGS', 'Variety',
  'Variety of fruit sources', 'chart.pie', 3, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- LEGUMES SECTIONS
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES
(
  'SECTION_LEGUME_TIMING', 'DISP_LEGUME_SERVINGS', 'Timing',
  'Legume intake by meal', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
),
(
  'SECTION_LEGUME_TYPES', 'DISP_LEGUME_SERVINGS', 'Types',
  'Types of legumes consumed', 'leaf.fill', 2, 'vertical_stack', 'bar_stacked', false, true
),
(
  'SECTION_LEGUME_VARIETY', 'DISP_LEGUME_SERVINGS', 'Variety',
  'Variety of legume sources', 'chart.pie', 3, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- ADDED SUGAR SECTIONS
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES
(
  'SECTION_SUGAR_TIMING', 'DISP_ADDED_SUGAR_SERVINGS', 'Timing',
  'Added sugar by meal/time', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
),
(
  'SECTION_SUGAR_SOURCES', 'DISP_ADDED_SUGAR_SERVINGS', 'Sources',
  'Sources of added sugar', 'drop.fill', 2, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- HEALTHY FAT SECTIONS
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES
(
  'SECTION_FAT_TIMING', 'DISP_HEALTHY_FAT_USAGE', 'Timing',
  'Healthy fat usage by meal', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
),
(
  'SECTION_FAT_TYPES', 'DISP_HEALTHY_FAT_USAGE', 'Types',
  'Types of healthy fats', 'drop.fill', 2, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- PROCESSED MEAT SECTIONS
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES
(
  'SECTION_PROCESSED_TIMING', 'DISP_PROCESSED_MEAT_SERVING', 'Timing',
  'Processed meat by meal', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
),
(
  'SECTION_PROCESSED_TYPES', 'DISP_PROCESSED_MEAT_SERVING', 'Types',
  'Types of processed meat', 'list.bullet', 2, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- PLANT BASED MEAL SECTIONS
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES
(
  'SECTION_PLANTMEAL_TIMING', 'DISP_PLANT_BASED_MEAL', 'Timing',
  'Plant-based meals by time', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
),
(
  'SECTION_PLANTMEAL_TYPES', 'DISP_PLANT_BASED_MEAL', 'Composition',
  'Meal composition breakdown', 'leaf.fill', 2, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- LARGE MEALS SECTIONS
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES
(
  'SECTION_LARGEMEAL_TIMING', 'DISP_LARGE_MEALS', 'Timing',
  'Large meals by time of day', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
),
(
  'SECTION_LARGEMEAL_FREQUENCY', 'DISP_LARGE_MEALS', 'Frequency',
  'Frequency patterns', 'calendar', 2, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- MINDFUL EATING SECTIONS
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id, parent_metric_id, section_name, section_description, section_icon,
  display_order, section_layout, section_chart_type_id, is_default_tab, is_active
) VALUES
(
  'SECTION_MINDFUL_TIMING', 'DISP_MINDFUL_EATING_EPISODES', 'Timing',
  'Mindful eating by meal', 'clock', 1, 'vertical_stack', 'bar_stacked', true, true
),
(
  'SECTION_MINDFUL_PRACTICES', 'DISP_MINDFUL_EATING_EPISODES', 'Practices',
  'Mindful eating practices used', 'brain.head.profile', 2, 'vertical_stack', 'bar_stacked', false, true
)
ON CONFLICT (section_id) DO UPDATE SET section_name = EXCLUDED.section_name;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show all nutrition metrics with section counts
SELECT
  pdm.parent_metric_id,
  pdm.parent_name,
  COUNT(pds.section_id) as section_count,
  STRING_AGG(pds.section_name, ', ' ORDER BY pds.display_order) as sections
FROM parent_display_metrics pdm
LEFT JOIN parent_detail_sections pds ON pds.parent_metric_id = pdm.parent_metric_id
WHERE pdm.pillar = 'Healthful Nutrition'
  AND pdm.is_active = true
GROUP BY pdm.parent_metric_id, pdm.parent_name
ORDER BY pdm.parent_name;
