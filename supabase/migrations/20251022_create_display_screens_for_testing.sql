-- =====================================================
-- Create Display Screens for Testing
-- =====================================================
-- Create screens for each pillar with display metrics
-- This enables the full UI hierarchy: Pillars → Screens → Metrics
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Display Screens
-- =====================================================

INSERT INTO display_screens (
  screen_id,
  name,
  overview,
  pillar,
  icon,
  default_time_period,
  layout_type,
  screen_type,
  display_order,
  is_active
)
VALUES
-- Movement + Exercise Screens
('SCREEN_SLEEP', 'Sleep Overview', 'Track your sleep duration, quality, and consistency',
 'Restorative Sleep', '🛌', 'weekly', 'detailed', 'summary', 1, true),

('SCREEN_CARDIO', 'Cardio Activity', 'Monitor your cardiovascular exercise sessions and duration',
 'Movement + Exercise', '🏃', 'weekly', 'detailed', 'summary', 1, true),

-- Healthful Nutrition Screens
('SCREEN_VEGETABLES', 'Vegetables', 'Track vegetable servings and variety',
 'Healthful Nutrition', '🥬', 'daily', 'detailed', 'summary', 1, true),

('SCREEN_FRUITS', 'Fruits', 'Track fruit servings and variety',
 'Healthful Nutrition', '🍎', 'daily', 'detailed', 'summary', 2, true),

('SCREEN_PROTEIN', 'Protein Sources', 'Monitor protein intake and variety',
 'Healthful Nutrition', '🥩', 'daily', 'detailed', 'summary', 3, true)

ON CONFLICT (screen_id) DO UPDATE SET
  name = EXCLUDED.name,
  overview = EXCLUDED.overview,
  pillar = EXCLUDED.pillar,
  icon = EXCLUDED.icon,
  default_time_period = EXCLUDED.default_time_period,
  layout_type = EXCLUDED.layout_type,
  screen_type = EXCLUDED.screen_type,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active;


-- =====================================================
-- PART 2: Link Display Metrics to Screens
-- =====================================================

-- Sleep Screen: Duration (primary) + Sessions
INSERT INTO display_screens_display_metrics (
  display_screen,
  display_metric,
  visualization_type,
  section,
  position,
  is_primary,
  display_order
)
SELECT 'SCREEN_SLEEP', 'DISP_SLEEP_DURATION', 'chart', 'main', 'full_width', true, 1
WHERE NOT EXISTS (SELECT 1 FROM display_screens_display_metrics WHERE display_screen = 'SCREEN_SLEEP' AND display_metric = 'DISP_SLEEP_DURATION')
UNION ALL
SELECT 'SCREEN_SLEEP', 'DISP_SLEEP_SESSIONS', 'chart', 'secondary', 'half_width', false, 2
WHERE NOT EXISTS (SELECT 1 FROM display_screens_display_metrics WHERE display_screen = 'SCREEN_SLEEP' AND display_metric = 'DISP_SLEEP_SESSIONS');

-- Cardio Screen: Sessions (primary)
INSERT INTO display_screens_display_metrics (
  display_screen,
  display_metric,
  visualization_type,
  section,
  position,
  is_primary,
  display_order
)
SELECT 'SCREEN_CARDIO', 'DISP_CARDIO_SESSIONS', 'chart', 'main', 'full_width', true, 1
WHERE NOT EXISTS (SELECT 1 FROM display_screens_display_metrics WHERE display_screen = 'SCREEN_CARDIO' AND display_metric = 'DISP_CARDIO_SESSIONS');

-- Vegetables Screen: Variety (primary)
INSERT INTO display_screens_display_metrics (
  display_screen,
  display_metric,
  visualization_type,
  section,
  position,
  is_primary,
  display_order
)
SELECT 'SCREEN_VEGETABLES', 'DISP_VEGETABLE_VARIETY', 'chart', 'main', 'full_width', true, 1
WHERE NOT EXISTS (SELECT 1 FROM display_screens_display_metrics WHERE display_screen = 'SCREEN_VEGETABLES' AND display_metric = 'DISP_VEGETABLE_VARIETY');

-- Fruits Screen: Variety (primary)
INSERT INTO display_screens_display_metrics (
  display_screen,
  display_metric,
  visualization_type,
  section,
  position,
  is_primary,
  display_order
)
SELECT 'SCREEN_FRUITS', 'DISP_FRUIT_VARIETY', 'chart', 'main', 'full_width', true, 1
WHERE NOT EXISTS (SELECT 1 FROM display_screens_display_metrics WHERE display_screen = 'SCREEN_FRUITS' AND display_metric = 'DISP_FRUIT_VARIETY');

-- Protein Screen: Variety (primary)
INSERT INTO display_screens_display_metrics (
  display_screen,
  display_metric,
  visualization_type,
  section,
  position,
  is_primary,
  display_order
)
SELECT 'SCREEN_PROTEIN', 'DISP_PROTEIN_VARIETY', 'chart', 'main', 'full_width', true, 1
WHERE NOT EXISTS (SELECT 1 FROM display_screens_display_metrics WHERE display_screen = 'SCREEN_PROTEIN' AND display_metric = 'DISP_PROTEIN_VARIETY');


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  screens_count INT;
  links_count INT;
BEGIN
  SELECT COUNT(*) INTO screens_count FROM display_screens WHERE screen_id LIKE 'SCREEN_%';
  SELECT COUNT(*) INTO links_count FROM display_screens_display_metrics WHERE display_screen LIKE 'SCREEN_%';

  RAISE NOTICE '✅ Display Screens Created for Testing';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Display Screens: %', screens_count;
  RAISE NOTICE '  Screen-Metric Links: %', links_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Screens by Pillar:';
  RAISE NOTICE '  Restorative Sleep:';
  RAISE NOTICE '    • SCREEN_SLEEP - Sleep Duration (primary) + Sessions';
  RAISE NOTICE '  Movement + Exercise:';
  RAISE NOTICE '    • SCREEN_CARDIO - Cardio Sessions';
  RAISE NOTICE '  Healthful Nutrition:';
  RAISE NOTICE '    • SCREEN_VEGETABLES - Vegetable Variety';
  RAISE NOTICE '    • SCREEN_FRUITS - Fruit Variety';
  RAISE NOTICE '    • SCREEN_PROTEIN - Protein Variety';
  RAISE NOTICE '';
  RAISE NOTICE 'Ready to build web UI!';
END $$;

COMMIT;
