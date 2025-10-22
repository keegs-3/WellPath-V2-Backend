-- =====================================================
-- Archive Old Display Metrics
-- =====================================================
-- Create archive tables for old display_metrics structure
-- Remove foreign keys from archives (they're just reference)
-- Clear current tables to start fresh
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Archive Tables
-- =====================================================

-- Archive display_metrics
CREATE TABLE IF NOT EXISTS z_old_display_metrics (LIKE display_metrics INCLUDING ALL);

-- Archive display_metrics_aggregations
CREATE TABLE IF NOT EXISTS z_old_display_metrics_aggregations (LIKE display_metrics_aggregations INCLUDING ALL);


-- =====================================================
-- PART 2: Copy Data to Archive Tables
-- =====================================================

-- Copy all display_metrics data
INSERT INTO z_old_display_metrics
SELECT * FROM display_metrics
ON CONFLICT DO NOTHING;

-- Copy all display_metrics_aggregations data
INSERT INTO z_old_display_metrics_aggregations
SELECT * FROM display_metrics_aggregations
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 3: Remove Foreign Keys from Archive Tables
-- =====================================================
-- Archive tables are for reference only, don't need FK constraints

-- Drop foreign keys from z_old_display_metrics
ALTER TABLE z_old_display_metrics
DROP CONSTRAINT IF EXISTS display_metrics_chart_type_id_fkey,
DROP CONSTRAINT IF EXISTS display_metrics_group_by_field_id_fkey,
DROP CONSTRAINT IF EXISTS display_metrics_pillar_fkey,
DROP CONSTRAINT IF EXISTS fk_display_metrics_pillar;

-- Drop foreign keys from z_old_display_metrics_aggregations
ALTER TABLE z_old_display_metrics_aggregations
DROP CONSTRAINT IF EXISTS display_metrics_aggregations_new_agg_metric_id_fkey,
DROP CONSTRAINT IF EXISTS display_metrics_aggregations_new_calculation_type_id_fkey,
DROP CONSTRAINT IF EXISTS display_metrics_aggregations_period_type_fkey;

-- Drop indexes from archive tables (no need for performance on archive)
DROP INDEX IF EXISTS idx_display_metrics_pillar;


-- =====================================================
-- PART 4: Clear Current Tables to Start Fresh
-- =====================================================

-- Delete from junction table first (has FK to display_metrics)
DELETE FROM display_metrics_aggregations;

-- Delete from main table
DELETE FROM display_metrics
WHERE display_metric_id NOT IN (
  'DISP_CARDIO_SESSIONS',
  'DISP_STRENGTH_SESSIONS',
  'DISP_SLEEP_SESSIONS',
  'DISP_VEGETABLE_VARIETY',
  'DISP_FRUIT_VARIETY',
  'DISP_PROTEIN_VARIETY',
  'DISP_FIBER_SOURCE_VARIETY',
  'DISP_LEGUME_VARIETY',
  'DISP_NUT_SEED_VARIETY',
  'DISP_WHOLE_GRAIN_VARIETY'
);

-- Note: We keep the 10 display metrics we just created


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  archived_metrics INT;
  archived_agg_links INT;
  current_metrics INT;
  current_agg_links INT;
BEGIN
  SELECT COUNT(*) INTO archived_metrics FROM z_old_display_metrics;
  SELECT COUNT(*) INTO archived_agg_links FROM z_old_display_metrics_aggregations;
  SELECT COUNT(*) INTO current_metrics FROM display_metrics;
  SELECT COUNT(*) INTO current_agg_links FROM display_metrics_aggregations;

  RAISE NOTICE '✅ Display Metrics Archived and Cleared';
  RAISE NOTICE '';
  RAISE NOTICE 'Archive Summary:';
  RAISE NOTICE '  z_old_display_metrics: % rows', archived_metrics;
  RAISE NOTICE '  z_old_display_metrics_aggregations: % rows', archived_agg_links;
  RAISE NOTICE '';
  RAISE NOTICE 'Current Tables (fresh start):';
  RAISE NOTICE '  display_metrics: % rows (kept new ones)', current_metrics;
  RAISE NOTICE '  display_metrics_aggregations: % rows', current_agg_links;
  RAISE NOTICE '';
  RAISE NOTICE 'Archive tables have no foreign keys (reference only)';
  RAISE NOTICE 'Ready to build fresh display_metrics!';
END $$;

COMMIT;
