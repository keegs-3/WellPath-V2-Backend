-- =====================================================
-- Simplify Display Architecture - Direct Screen FK
-- =====================================================
-- Change from: display_screens ← junction → display_metrics
-- Change to:   display_screens ← display_metrics (direct FK)
--
-- Remove all presentation fields from display_metrics
-- Swift handles ALL display logic
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Add direct screen_id FK to display_metrics
-- =====================================================

ALTER TABLE display_metrics
ADD COLUMN screen_id text REFERENCES display_screens(screen_id) ON DELETE CASCADE;

COMMENT ON COLUMN display_metrics.screen_id IS
'Direct FK to display_screens. Each metric belongs to one screen.';

-- =====================================================
-- STEP 2: Migrate data from junction table
-- =====================================================

-- Copy screen links from junction table to direct FK
UPDATE display_metrics dm
SET screen_id = dsdm.display_screen
FROM display_screens_display_metrics dsdm
WHERE dsdm.display_metric = dm.metric_id;

CREATE INDEX idx_display_metrics_screen_id ON display_metrics(screen_id);

-- =====================================================
-- STEP 3: Remove presentation fields (Swift handles all)
-- =====================================================

ALTER TABLE display_metrics
DROP COLUMN IF EXISTS chart_type_id,
DROP COLUMN IF EXISTS chart_config,
DROP COLUMN IF EXISTS supported_units,
DROP COLUMN IF EXISTS default_unit,
DROP COLUMN IF EXISTS display_order,
DROP COLUMN IF EXISTS is_featured,
DROP COLUMN IF EXISTS icon,
DROP COLUMN IF EXISTS color;

COMMENT ON TABLE display_metrics IS
'Individual metrics that belong to a screen. All presentation (charts, colors, units) is handled in Swift views.';

-- =====================================================
-- STEP 4: Archive junction table
-- =====================================================

-- Backup junction table
CREATE TABLE z_old_display_screens_display_metrics AS
SELECT * FROM display_screens_display_metrics;

-- Drop junction table (no longer needed with direct FK)
DROP TABLE IF EXISTS display_screens_display_metrics CASCADE;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  screens_count INT;
  metrics_count INT;
  linked_count INT;
  unlinked_count INT;
BEGIN
  SELECT COUNT(*) INTO screens_count FROM display_screens;
  SELECT COUNT(*) INTO metrics_count FROM display_metrics;
  SELECT COUNT(*) INTO linked_count FROM display_metrics WHERE screen_id IS NOT NULL;
  SELECT COUNT(*) INTO unlinked_count FROM display_metrics WHERE screen_id IS NULL;

  RAISE NOTICE '✅ Display Architecture Simplified';
  RAISE NOTICE '';
  RAISE NOTICE 'Structure:';
  RAISE NOTICE '  display_screens: % screens', screens_count;
  RAISE NOTICE '  display_metrics: % metrics', metrics_count;
  RAISE NOTICE '    Linked to screens: %', linked_count;
  RAISE NOTICE '    Unlinked: %', unlinked_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Hierarchy:';
  RAISE NOTICE '  pillar → display_screens → display_metrics → aggregations';
  RAISE NOTICE '';
  RAISE NOTICE 'Removed:';
  RAISE NOTICE '  ✗ display_screens_display_metrics (junction table)';
  RAISE NOTICE '  ✗ chart_type_id, chart_config, supported_units (from display_metrics)';
  RAISE NOTICE '';
  RAISE NOTICE 'Swift now handles ALL presentation logic';
END $$;

-- Show screens with their metrics
SELECT
  ds.name as screen_name,
  ds.pillar,
  COUNT(dm.metric_id) as metric_count,
  string_agg(dm.metric_name, ', ' ORDER BY dm.metric_name) as metrics
FROM display_screens ds
LEFT JOIN display_metrics dm ON dm.screen_id = ds.screen_id
GROUP BY ds.screen_id, ds.name, ds.pillar
ORDER BY ds.pillar, ds.name
LIMIT 15;

COMMIT;
