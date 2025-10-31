-- =====================================================
-- Simplify Display Metrics - Drop Parent/Child Complexity
-- =====================================================
-- Replace parent/child/section structure with simple flat table
-- Swift handles UI complexity, database just provides data
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create New Simplified display_metrics Table
-- =====================================================

CREATE TABLE display_metrics_new (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_id text UNIQUE NOT NULL,
  metric_name text NOT NULL,
  description text,

  -- Categorization
  pillar text REFERENCES pillars_base(pillar_name) ON UPDATE CASCADE ON DELETE CASCADE,
  category text,  -- e.g., "sleep", "nutrition", "exercise"

  -- Chart configuration
  chart_type_id text REFERENCES chart_types(chart_type_id),
  chart_config jsonb DEFAULT '{}'::jsonb,

  -- Unit configuration
  supported_units jsonb DEFAULT '["default"]'::jsonb,
  default_unit text,

  -- Display configuration
  display_order integer,
  is_featured boolean DEFAULT false,
  is_active boolean DEFAULT true,

  -- Metadata
  icon text,
  color text,

  -- Timestamps
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

CREATE INDEX idx_display_metrics_new_pillar ON display_metrics_new(pillar);
CREATE INDEX idx_display_metrics_new_active ON display_metrics_new(is_active) WHERE is_active = true;
CREATE INDEX idx_display_metrics_new_category ON display_metrics_new(category);

COMMENT ON TABLE display_metrics_new IS
'Simplified flat display metrics table. Each metric maps to one or more aggregations via junction table.';

-- =====================================================
-- STEP 2: Create Junction Table (metric → aggregations)
-- =====================================================

CREATE TABLE display_metrics_aggregations_new (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_id text NOT NULL REFERENCES display_metrics_new(metric_id) ON DELETE CASCADE,
  agg_metric_id text NOT NULL REFERENCES aggregation_metrics(agg_id) ON DELETE CASCADE,
  period_type text NOT NULL REFERENCES aggregation_periods(period_id),
  calculation_type_id text NOT NULL REFERENCES calculation_types(type_id),

  -- Order for stacked charts (Deep before Core before REM)
  display_order integer,

  -- Metadata for this data series
  series_label text,  -- Override label for this series
  series_color text,  -- Color for this series in chart

  created_at timestamptz DEFAULT NOW(),

  UNIQUE(metric_id, agg_metric_id, period_type, calculation_type_id)
);

CREATE INDEX idx_display_metrics_agg_new_metric ON display_metrics_aggregations_new(metric_id);
CREATE INDEX idx_display_metrics_agg_new_agg ON display_metrics_aggregations_new(agg_metric_id);

COMMENT ON TABLE display_metrics_aggregations_new IS
'Maps display metrics to their aggregations. One metric can have multiple aggregations (e.g., Sleep Analysis → Deep, Core, REM, Awake).';

-- =====================================================
-- STEP 3: Migrate Data from Parent/Child Structure
-- =====================================================

-- Migrate parent metrics
INSERT INTO display_metrics_new (
  metric_id,
  metric_name,
  description,
  pillar,
  category,
  chart_type_id,
  chart_config,
  supported_units,
  default_unit,
  display_order,
  is_active
)
SELECT
  parent_metric_id,
  parent_name,
  parent_description,
  pillar,
  CASE
    WHEN parent_metric_id LIKE '%SLEEP%' THEN 'sleep'
    WHEN parent_metric_id LIKE '%PROTEIN%' THEN 'nutrition'
    WHEN parent_metric_id LIKE '%WATER%' THEN 'hydration'
    WHEN parent_metric_id LIKE '%STEP%' THEN 'activity'
    ELSE 'other'
  END,
  chart_type_id,
  chart_config,
  supported_units,
  default_unit,
  display_order,
  is_active
FROM parent_display_metrics
WHERE is_active = true;

-- Migrate parent → aggregation mappings
INSERT INTO display_metrics_aggregations_new (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order,
  series_label
)
SELECT DISTINCT
  pca.parent_metric_id,
  pca.agg_metric_id,
  pca.period_type,
  pca.calculation_type_id,
  ROW_NUMBER() OVER (PARTITION BY pca.parent_metric_id, pca.period_type ORDER BY pca.agg_metric_id),
  am.display_name
FROM parent_child_display_metrics_aggregations pca
JOIN aggregation_metrics am ON am.agg_id = pca.agg_metric_id
WHERE pca.parent_metric_id IS NOT NULL
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- Migrate child metrics that should be standalone
INSERT INTO display_metrics_new (
  metric_id,
  metric_name,
  description,
  pillar,
  category,
  chart_type_id,
  supported_units,
  default_unit,
  is_active
)
SELECT DISTINCT
  cdm.child_metric_id,
  cdm.child_name,
  cdm.child_description,
  pdm.pillar,
  CASE
    WHEN cdm.child_metric_id LIKE '%SLEEP%' THEN 'sleep'
    WHEN cdm.child_metric_id LIKE '%PROTEIN%' THEN 'nutrition'
    ELSE 'other'
  END,
  cdm.chart_type_id,
  cdm.supported_units,
  cdm.default_unit,
  cdm.is_active
FROM child_display_metrics cdm
LEFT JOIN parent_display_metrics pdm ON pdm.parent_metric_id = cdm.parent_metric_id
WHERE cdm.is_active = true
  AND cdm.section_id IS NULL  -- Only direct children, not section children
ON CONFLICT (metric_id) DO NOTHING;

-- Migrate child → aggregation mappings
INSERT INTO display_metrics_aggregations_new (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  series_label
)
SELECT DISTINCT
  pca.child_metric_id,
  pca.agg_metric_id,
  pca.period_type,
  pca.calculation_type_id,
  am.display_name
FROM parent_child_display_metrics_aggregations pca
JOIN aggregation_metrics am ON am.agg_id = pca.agg_metric_id
WHERE pca.child_metric_id IS NOT NULL
  AND pca.child_metric_id IN (SELECT metric_id FROM display_metrics_new)
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- =====================================================
-- STEP 4: Update display_screens_display_metrics FK
-- =====================================================

-- Add new column temporarily
ALTER TABLE display_screens_display_metrics
ADD COLUMN new_display_metric text REFERENCES display_metrics_new(metric_id);

-- Migrate from old column
UPDATE display_screens_display_metrics dsdm
SET new_display_metric = dsdm.display_metric
WHERE EXISTS (SELECT 1 FROM display_metrics_new WHERE metric_id = dsdm.display_metric);

-- =====================================================
-- STEP 5: Archive Old Tables
-- =====================================================

-- Archive complex tables
CREATE TABLE z_old_parent_display_metrics AS SELECT * FROM parent_display_metrics;
CREATE TABLE z_old_child_display_metrics AS SELECT * FROM child_display_metrics;
CREATE TABLE z_old_parent_detail_sections AS SELECT * FROM parent_detail_sections;
CREATE TABLE z_old_parent_child_display_metrics_aggregations AS SELECT * FROM parent_child_display_metrics_aggregations;

-- =====================================================
-- STEP 6: Drop Complex Tables
-- =====================================================

DROP TABLE IF EXISTS parent_child_display_metrics_aggregations CASCADE;
DROP TABLE IF EXISTS parent_detail_sections CASCADE;
DROP TABLE IF EXISTS child_display_metrics CASCADE;
DROP TABLE IF EXISTS parent_display_metrics CASCADE;

-- =====================================================
-- STEP 7: Rename New Tables to Production Names
-- =====================================================

ALTER TABLE display_metrics_new RENAME TO display_metrics;
ALTER TABLE display_metrics_aggregations_new RENAME TO display_metrics_aggregations;

-- Update FK in display_screens_display_metrics
ALTER TABLE display_screens_display_metrics DROP COLUMN display_metric;
ALTER TABLE display_screens_display_metrics RENAME COLUMN new_display_metric TO display_metric;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  metrics_count INT;
  mappings_count INT;
  screens_count INT;
BEGIN
  SELECT COUNT(*) INTO metrics_count FROM display_metrics;
  SELECT COUNT(*) INTO mappings_count FROM display_metrics_aggregations;
  SELECT COUNT(*) INTO screens_count FROM display_screens_display_metrics WHERE display_metric IS NOT NULL;

  RAISE NOTICE '✅ Display Metrics Simplified';
  RAISE NOTICE '';
  RAISE NOTICE 'New Structure:';
  RAISE NOTICE '  display_metrics: % metrics', metrics_count;
  RAISE NOTICE '  display_metrics_aggregations: % mappings', mappings_count;
  RAISE NOTICE '  display_screens_display_metrics: % screen links', screens_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Dropped Complex Tables:';
  RAISE NOTICE '  ✗ parent_display_metrics';
  RAISE NOTICE '  ✗ child_display_metrics';
  RAISE NOTICE '  ✗ parent_detail_sections';
  RAISE NOTICE '  ✗ parent_child_display_metrics_aggregations';
  RAISE NOTICE '';
  RAISE NOTICE 'Archived to z_old_* tables for reference';
END $$;

-- Show example structure
SELECT
  dm.metric_id,
  dm.metric_name,
  dm.chart_type_id,
  COUNT(dma.agg_metric_id) as aggregation_count,
  string_agg(DISTINCT dma.period_type, ', ' ORDER BY dma.period_type) as periods
FROM display_metrics dm
LEFT JOIN display_metrics_aggregations dma ON dma.metric_id = dm.metric_id
GROUP BY dm.metric_id, dm.metric_name, dm.chart_type_id
ORDER BY dm.metric_name
LIMIT 10;

COMMIT;
